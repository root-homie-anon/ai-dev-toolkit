# Supabase Rules — Primary Database Reference

**Supabase is the primary database across all projects.** This document is the canonical Supabase reference for every agent. If you are touching Supabase in any way — schema, queries, client usage, RLS, auth, storage, edge functions, analytics, security review — consult this file and apply the sections relevant to your work.

For general Postgres best practices (performance, schema theory, query tuning), **also load the `supabase-postgres-best-practices` skill**. This document covers project conventions and Supabase-platform specifics; the skill covers general Postgres knowledge. They complement each other.

---

## How Agents Use This Document

Organized **by concern**, not by agent. Find the sections relevant to your task:

| Your task touches… | Read these sections |
|---|---|
| Schema design, migrations, indexes, queries | Architecture, Schema Conventions, RLS, Migrations, Indexes, Functions |
| Writing backend code against Supabase | Architecture, Clients & Keys, Server-Side Client Usage, Type Generation, Edge Functions |
| Writing frontend code against Supabase | Architecture, Clients & Keys, Client-Side Usage, Type Generation, Realtime |
| Analytics, events, pipelines | Architecture, Schema Conventions, Analytics Patterns, Extensions (pg_cron), Edge Functions |
| Security review | **All sections.** Everything on this page is a potential finding. |
| CI/CD, deployment, infra | Migrations, Environment & Config, Extensions |
| Any task involving the database at all | At minimum: Clients & Keys, RLS — The Non-Negotiables |

**Rules in this document override agent-level defaults.** If an agent's own guidance conflicts with something here, this wins.

---

## 1. Architecture Overview

Supabase is Postgres 15+ plus a suite of managed layers. Every agent should know the layers exist, even if they only touch one:

- **Database** — Postgres 15+, with extensions
- **Auth** — `auth.users`, `auth.identities`, JWT-based sessions; integrates with RLS via `auth.uid()` and `auth.jwt()`
- **Storage** — files stored with metadata in `storage.objects`, permissioned via RLS on that table
- **Realtime** — change-data-capture broadcasting to subscribed clients via channels
- **Edge Functions** — Deno serverless functions with direct DB access
- **PostgREST** — auto-generated REST API from the `public` schema; **everything in `public` is exposed unless explicitly restricted**

Schemas to know: `public` (app data, API-exposed), `auth` (managed by Supabase, don't modify directly), `storage` (managed by Supabase), `realtime` (managed by Supabase), `extensions` (extension-owned objects). Create your own schemas (e.g. `analytics`, `private`) when it helps organization or limits API exposure.

---

## 2. Clients & Keys (critical — every agent must know)

Supabase has three key types. Knowing which to use, where, is the single most important security boundary on the platform.

### `anon` key
- **Safe to ship to the browser** *if and only if RLS is correctly configured on every table*.
- Used by the browser client and any unauthenticated request.
- Without correct RLS, the anon key is a full data breach.

### `authenticated` role (user session via JWT)
- Not a separate key — same anon key, but the client attaches the user's JWT.
- All queries execute as the authenticated user; RLS policies on `auth.uid()` apply.
- This is what your frontend and server-side user-scoped queries should use.

### `service_role` key
- **Bypasses RLS entirely.** Full database access.
- **NEVER** in frontend code, client bundles, browser network requests, or git history.
- **NEVER** imported into anything that ships to the browser.
- Used only in: Edge Functions, server-side API routes, background jobs, admin scripts — all server-side.
- Every use of service_role in code must be justified with a comment explaining why a user-context client isn't sufficient.

### Rule of thumb
> If the operation is scoped to a user, use an authenticated client with their JWT. Reach for service_role only when the operation is genuinely admin-level (cross-user, system maintenance, webhooks without user context).

### Verifying service_role isn't leaked
Any agent writing, reviewing, or shipping code should be able to verify:
- `grep -r "SUPABASE_SERVICE_ROLE_KEY" src/` returns no frontend paths
- `git log -S 'service_role'` shows no commits exposing it
- `.env*` files containing it are gitignored
- No imports of the server client from a client component (in Next.js App Router)

---

## 3. Schema Conventions (non-negotiable defaults)

When designing any table:

- `snake_case` for tables and columns
- **Plural table names** (`users`, `invoices`, `ad_campaigns`)
- `id uuid primary key default gen_random_uuid()` — never sequential integer PKs for user-facing tables
- `created_at timestamptz default now() not null`
- `updated_at timestamptz default now() not null` with a `BEFORE UPDATE` trigger
- **Foreign keys with explicit `ON DELETE` behavior** — `CASCADE`, `SET NULL`, or `RESTRICT`. Never implicit.
- **`NOT NULL` on everything that can be.** Nullable columns are questions that must have answers.
- Most specific type always: `timestamptz` not `timestamp`, `numeric(12,2)` not `float`, `text` not `varchar(n)` (Postgres has no performance reason to cap varchar length).
- **Enum types** (`CREATE TYPE ... AS ENUM (...)`) for closed sets of values, not check constraints.
- `updated_at` triggers: use a shared `public.set_updated_at()` function rather than duplicating it per table.

Example canonical table:

```sql
create table public.invoices (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  amount numeric(12,2) not null,
  currency text not null default 'usd',
  status invoice_status not null default 'draft',
  issued_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.invoices enable row level security;

create trigger invoices_set_updated_at
  before update on public.invoices
  for each row execute function public.set_updated_at();
```

---

## 4. RLS — The Non-Negotiables

Row Level Security is the primary authorization mechanism on Supabase. **Every table in `public` must have `ENABLE ROW LEVEL SECURITY`** — no exceptions. A table without RLS is a security incident because PostgREST will expose it to `anon` over the API.

### Rules (all enforced, all the time)

1. **`ENABLE ROW LEVEL SECURITY` is set in the same migration that creates the table.** Not later, not "we'll add it before launch," not "this table is internal." Immediately.
2. **Separate policies for `SELECT`, `INSERT`, `UPDATE`, `DELETE`.** Avoid `FOR ALL` — it hides what's actually permitted and makes audit harder.
3. **No `USING (true)`** except on tables that are explicitly public by design. Every instance requires justification.
4. **Use `auth.uid()` correctly.** Verify the column being compared is actually the user's id, not a misnamed foreign key. A policy checking `user_id = auth.uid()` on a table where `user_id` means something else is a common class of bug.
5. **Test policies with real user contexts** before declaring them working:
   ```sql
   set local role authenticated;
   set local request.jwt.claims = '{"sub":"<user-uuid>","role":"authenticated"}';
   select * from public.invoices;  -- should only return rows for that user
   ```
6. **Index columns used in RLS predicates.** RLS policies run on every query — unindexed lookups kill performance and cause devs to "temporarily disable" RLS, which never gets re-enabled.
7. **Separate policies for `anon` vs `authenticated`** when behavior should differ. Granting `anon` access to a user-data table is almost always a bug.
8. **Name policies descriptively:** `"users can read own invoices"`, not `"policy1"`.
9. **Views in `public` must set `security_invoker = on`** (Postgres 15+) so the view respects the querying user's RLS, not the view owner's.

### Ownership
- **Omar designs** RLS policies as part of schema design.
- **Elliot audits** every policy before merge. No exceptions for tables holding user data.

---

## 5. Migrations

### Tooling
- Always use the **Supabase CLI**: `supabase migration new <name>`
- **Never** edit the database directly in the dashboard for committed projects. Dashboard edits don't get into migrations and will be lost on the next `db reset`.
- Local dev: `supabase start` (full stack locally), `supabase db reset` (rebuild from migrations)
- Push to remote: `supabase db push` — **always run with `--dry-run` first against production**

### Rules
- **Migrations are immutable once committed.** Fix forward, never edit history.
- **Keep migrations small and atomic** — one logical change per file.
- **Expand → migrate → contract** for any breaking change:
  1. **Expand** — add the new column/table alongside the old
  2. **Migrate** — dual-write from application code, backfill historical data
  3. **Contract** — drop the old column/table only after the new one is fully in use and verified
- **Lock-aware migrations** — adding a `NOT NULL` column to a large table without a default will lock it. Add nullable first, backfill, then constrain.
- **Backfill as a separate migration** from schema change.
- **Always verify rollback path** — even if you think you won't need it.

### Ownership
- **Omar** designs the schema and writes the migration.
- **Ray** applies migrations to staging/production via the CLI, with CI/CD integration.
- **Nico** must be looped in on any migration affecting tracked columns or analytics tables.
- **Elliot** audits any migration touching RLS, policies, auth tables, or security-sensitive data.

---

## 6. Type Generation

- Generate TypeScript types after every migration:
  ```bash
  supabase gen types typescript --local > src/types/database.ts
  ```
- **Commit the generated types.** Don't hand-edit them.
- **Never hand-write database types.** Generated types are the single source of truth.
- Frontend (Ava) and backend (Doug) both import from the same generated file.
- Use typed clients: `createClient<Database>(...)` — this catches schema drift at build time.

---

## 7. Server-Side Client Usage

For any agent writing backend code (Doug primarily, but also Edge Functions, server components, API routes):

### Next.js App Router patterns

Use `@supabase/ssr` for Next.js. Three distinct client factories:

- **Server Component client** — read-only, user-scoped, no cookie writes. Use in server components for displaying user data.
- **Server Action / Route Handler client** — user-scoped, can write cookies. Use in server actions and API routes.
- **Middleware client** — user-scoped, refreshes the session. Use only in `middleware.ts`.

**Do not reuse a client across request boundaries.** Each request creates its own client with the request's cookies.

### Service role client (admin operations)

- Create a separate factory for service_role use
- Keep it in a path like `src/lib/supabase/admin.ts`
- **Must include a comment at the import site** explaining why service_role is needed (cross-user, webhook, etc.)
- Never import this factory from a client component or a file shared with the browser bundle

### JWT forwarding

- The authenticated client automatically reads the user's JWT from cookies (via `@supabase/ssr`)
- When calling Edge Functions from server code, forward the user's access token in the `Authorization: Bearer <token>` header so the function runs as the user
- When calling external services with user context, never forward the service_role key

### Error handling
- Supabase client returns `{ data, error }` — always check `error` before using `data`
- Never trust `data` when `error` is non-null
- Don't leak Postgres error messages to clients (sanitize in the response layer)

---

## 8. Client-Side (Browser) Usage

For any agent writing frontend code (Ava primarily):

### Browser client setup
- Use `@supabase/ssr`'s `createBrowserClient(...)` — the browser-safe factory
- Initialize once, reuse across the app (React context or module-level singleton)
- **Only the anon key goes into the browser.** If you see `SUPABASE_SERVICE_ROLE_KEY` anywhere in a client component or a file that gets bundled to the browser, that's a critical security issue — stop and route to Elliot.

### Auth flow
- Use Supabase Auth's built-in helpers — don't roll custom session management
- Handle auth state changes via `supabase.auth.onAuthStateChange`
- Protect routes via middleware, not just client-side checks (client checks are UX, not security)

### Realtime subscriptions
- Subscribe via `supabase.channel(...).on('postgres_changes', ...)`
- **RLS applies to realtime subscriptions** — users only receive events for rows they could SELECT
- Clean up subscriptions on unmount to prevent memory leaks
- Don't subscribe to high-volume tables from the browser — subscribe to aggregated views or filtered channels

### Typed queries
- Import the generated types: `import type { Database } from '@/types/database'`
- Use typed clients: `createBrowserClient<Database>(...)`
- Benefit: schema drift is caught at build time

### RLS-aware query patterns
- Queries from the browser run under the user's JWT — RLS applies
- Don't add `where user_id = currentUser.id` manually — RLS already enforces it, and doing it both ways creates bugs when the schema changes
- Do scope queries by other dimensions (date range, category, etc.) via `eq`/`gte`/etc.

### Never
- Import anything from `src/lib/supabase/admin.ts` (or equivalent service_role factory) into a client component
- Store the service_role key in `NEXT_PUBLIC_*` env vars
- Hard-code any key — always via env

---

## 9. Database Functions

For any agent writing `plpgsql` or `sql` functions (Omar primarily):

- **Default to `SECURITY INVOKER`.** `SECURITY DEFINER` runs with the function owner's privileges and bypasses RLS — it's a privilege-escalation risk.
- **Every use of `SECURITY DEFINER` requires justification in a comment** and a `SET search_path = ''` clause to prevent search-path injection.
- **Never concatenate user input into dynamic SQL.** Use `format('... %I ... %L', identifier, literal)` or parameterized execution.
- **PostgREST auto-exposes functions in the `public` schema** — `REVOKE EXECUTE ... FROM anon, authenticated` on anything that shouldn't be API-callable.
- **Function input validation** — validate shape and range at the entry point of every function exposed to the API.

Example:

```sql
create or replace function public.transfer_funds(
  from_account uuid,
  to_account uuid,
  amount numeric
) returns void
language plpgsql
security invoker
set search_path = ''
as $$
begin
  if amount <= 0 then
    raise exception 'amount must be positive';
  end if;
  -- ... transfer logic, operating under caller's RLS ...
end;
$$;
```

---

## 10. Indexes

- **Every foreign key needs an index.** Supabase does not auto-create them.
- **Index RLS predicate columns.** If a policy says `where user_id = auth.uid()`, there must be an index on `user_id`.
- **Composite indexes:** column order matters — most selective first.
- **Partial indexes** for boolean flags and soft deletes: `create index ... where deleted_at is null`.
- **GIN indexes** for JSONB columns that are frequently queried by property.
- **pgvector** — `ivfflat` or `hnsw` for embedding similarity search.
- **Diagnostics:** `supabase inspect db unused-indexes`, `supabase inspect db long-running-queries`, `supabase inspect db cache-hit`.

---

## 11. Extensions

Enable only when needed. Every enabled extension expands the attack surface.

### Commonly used
- `pg_cron` — schedule SQL jobs inside the database (materialized view refreshes, cleanup, analytics rollups)
- `pgvector` — vector similarity search
- `pg_stat_statements` — query performance monitoring
- `citext` — case-insensitive text
- `postgis` — geospatial (enable only if actually used)

### Use carefully
- `pg_net` — outbound HTTP from SQL. **Can exfiltrate data.** Every use audited by Elliot. Destinations should be allowlisted; never construct URLs from user input.
- `http` — similar risks to pg_net
- `plpython3u`, `plperl`, etc. — untrusted languages, avoid unless justified

### Rule
- **Every enabled extension must be justified.** Elliot flags unused extensions in security review.

---

## 12. Storage

- **Every bucket has RLS policies on `storage.objects`** — same rigor as table RLS.
- **Default to private buckets.** Public buckets are an explicit decision with a documented reason.
- **Path conventions scope access via RLS:** use `{auth.uid()}/...` as the path prefix so policies can filter on path.
- **File type and size limits** enforced at bucket-level settings AND in upload policies.
- **Signed URLs** for private content — short expiry (minutes, not hours). Never hand out long-lived signed URLs.
- **Uploads from the browser use the authenticated client**, with RLS scoping what they can write.
- **Never use service_role to serve user-uploaded files to the browser** — that's a RLS bypass disguised as a feature.

---

## 13. Realtime

- Enable on a table: `alter publication supabase_realtime add table public.<table>;`
- **RLS applies to realtime subscriptions** — but verify by testing with a second user account
- **Don't broadcast raw PII-bearing tables.** Publish filtered or aggregated views instead
- **Channel authorization** for private channels — use Realtime Authorization policies, audited like RLS
- **High-volume tables** — don't subscribe directly from the browser; subscribe to rolled-up views

---

## 14. Edge Functions

- **Runtime:** Deno — not Node. Standard library differences matter.
- **Secrets:** `supabase secrets set KEY=value` — never hardcoded, never in the repo
- **CORS:** set headers explicitly; **no wildcard origins in production**
- **JWT verification:** if the function expects an authenticated user, verify the JWT via `supabase.auth.getUser(token)` before acting on the payload
- **Service role usage:** only when absolutely necessary, scoped to specific operations, never reflected in the response
- **Input validation:** validate payload shape at function entry; never trust the body
- **Error responses:** no Postgres error messages or stack traces to clients
- **Rate limiting:** Supabase does not rate-limit Edge Functions automatically — implement at the function level or front with a gateway for public functions
- **Webhook signature verification:** for any function receiving webhooks (Stripe, Meta, etc.), **verify the signature BEFORE parsing the payload**
- **Idempotency** for webhook processors — dedupe on the source's event id

---

## 15. Analytics Patterns on Supabase

Supabase is capable of serving as the full analytics stack up to ~10M events/month. Move to a dedicated warehouse (BigQuery, Snowflake, DuckDB) only when:
- Analytics queries start impacting OLTP performance and read replicas aren't enough
- You need joins across sources Supabase can't ingest
- You're exceeding tens of millions of events per day
- Cost modeling shows the warehouse is actually cheaper at your volume

### Event table canonical schema

```sql
create schema if not exists analytics;

create table analytics.events (
  id uuid primary key default gen_random_uuid(),
  event_name text not null,
  user_id uuid references auth.users(id),
  anonymous_id text,
  session_id text,
  properties jsonb not null default '{}',
  context jsonb not null default '{}',
  schema_version int not null default 1,
  occurred_at timestamptz not null,     -- client clock (when it happened)
  received_at timestamptz not null default now(),  -- server clock (when we got it)
  created_at timestamptz not null default now()
);

-- Indexes
create index events_event_name_occurred_at_idx on analytics.events (event_name, occurred_at);
create index events_user_id_occurred_at_idx on analytics.events (user_id, occurred_at);
create index events_properties_gin_idx on analytics.events using gin (properties);

-- RLS — events are only readable by service_role
alter table analytics.events enable row level security;
-- (no policies granted to anon/authenticated by default)
```

**Always two timestamps:** `occurred_at` (client-reported) and `received_at` (server-stamped). Client clocks lie.

### Partitioning
- Partition by month (`partition by range (occurred_at)`) when the unpartitioned table starts hurting.
- Don't partition upfront — wait for signal.

### pg_cron for scheduled pipelines

```sql
select cron.schedule(
  'refresh-daily-active-users',
  '*/15 * * * *',
  $$refresh materialized view concurrently analytics.mart_daily_active_users$$
);
```

- Use for: materialized view refreshes, rollups, data quality checks, cleanup
- **Log job output** — `cron.job_run_details` is your monitoring surface
- Don't use for long-running jobs (> a few minutes) — use Edge Functions instead

### Materialized views for marts
- Refresh via `pg_cron` on a cadence matching consumer needs
- Use `refresh materialized view concurrently` when possible to avoid locking
- Index the mart tables for the dashboard queries that read them

### Meta API ingestion (project-specific)
Pattern:
1. Edge Function `meta-ingest` — pulls insights via the Meta client wrapper (global rule: Meta API always via the wrapper)
2. Writes raw responses to `analytics_raw.meta_insights` (append-only, full fidelity)
3. Scheduled transform normalizes into `analytics.mart_meta_campaign_performance`
4. **Monitor `X-Ad-Account-Usage`** on responses — alert before hitting limits
5. Retry with exponential backoff on 429s
6. **Dead-letter table** for failed ingests — never drop data silently

### Data quality checks
- `pg_cron` job every hour: `select max(received_at) from analytics.events` — alert if > 1 hour old on active streams
- Row count anomaly detection: compare rolling 24h to 7-day baseline
- Null rate monitoring on required JSONB properties
- Constraint-based validation at ingestion (not just documentation)

---

## 16. Performance Diagnostics

- `supabase inspect db cache-hit` — should be > 99% for indexes and tables
- `supabase inspect db bloat` — flag high bloat ratios
- `supabase inspect db index-usage` — unused indexes are write overhead for no read benefit
- `supabase inspect db long-running-queries` — investigate anything > 1s on a regular basis
- `EXPLAIN ANALYZE` — always under the target role (`set local role authenticated; set local request.jwt.claims = ...`)

### Connection pooling
- Supabase uses PgBouncer
- **Transaction pooling** for serverless (Edge Functions, Next.js API routes)
- **Session pooling** for long-lived connections (background workers)
- Use the right connection string for the mode

---

## 17. Environment & Config

Required env vars (per the project's `keymaster` flow):

- `NEXT_PUBLIC_SUPABASE_URL` — safe to expose
- `NEXT_PUBLIC_SUPABASE_ANON_KEY` — safe to expose (if RLS is correct)
- `SUPABASE_SERVICE_ROLE_KEY` — **NEVER** `NEXT_PUBLIC_`, **NEVER** in client code, **NEVER** in git

Keymaster alias `SUPABASE_URL` → `NEXT_PUBLIC_SUPABASE_URL` when the project expects a different name.

---

## 18. Project Settings Audit (Elliot primarily)

Per-project, at setup + whenever settings change:
- API — allowed JWT issuers not expanded unnecessarily
- Network restrictions enabled for production projects (Pro tier)
- Custom domain TLS configured, no mixed content
- Backup retention adequate (Ray reviews; Elliot flags if too low)
- Log retention sufficient for incident investigation
- Database Webhooks — any configured webhooks reviewed for payload sensitivity
- Email templates — no user-controlled interpolation
- Leaked password protection enabled
- MFA enabled for projects with sensitive data

---

## 19. What Goes Wrong Most Often (top findings)

1. **Table created without RLS enabled** — and then it gets forgotten
2. **Service role key imported into a client component** by mistake
3. **`USING (true)` policy "as a placeholder"** that ships to production
4. **RLS predicate without an index** — slow queries, then RLS gets disabled "temporarily"
5. **`SECURITY DEFINER` function without `set search_path = ''`**
6. **Webhook receiver that parses the payload before verifying the signature**
7. **Direct dashboard edits** that never become migrations, lost on next `db reset`
8. **Untyped client** (`createClient` without the `<Database>` generic) — silent schema drift
9. **Raw event table broadcast via Realtime** without filtering — PII exposure
10. **pg_net usage** to a URL constructed from user input — exfiltration risk

If you see any of these while working, **stop and flag** — don't patch around them.

---

## 20. Ownership Summary

| Concern | Primary owner | Review / audit |
|---|---|---|
| Schema design | Omar | Elliot (for RLS) |
| Migrations | Omar writes, Ray applies | Elliot (security-sensitive), Nico (analytics-affecting) |
| RLS policies | Omar designs | **Elliot audits — non-optional** |
| Indexes | Omar | Performance regression = Omar |
| Database functions | Omar | Elliot (SECURITY DEFINER and dynamic SQL) |
| Server-side client code | Doug | Elliot (auth flow, service role usage) |
| Client-side client code | Ava | Elliot (keys, RLS-aware queries) |
| Edge Functions | Doug or Nico depending on purpose | Elliot |
| Storage policies | Omar (policy SQL) | Elliot |
| Realtime config | Omar + Doug/Ava | Elliot (broadcast scope) |
| Analytics schemas, pipelines, metrics | Nico + Omar (Data Pod) | Elliot (PII / compliance) |
| Project settings | Ray (infra), Marcus (ops) | Elliot |
| Keys & env | `keymaster` flow (global rule) | Elliot |

---

**When this rules file and an agent's own guidance conflict, this file wins.** Propose updates to this file via Marcus if you find a gap or a case where the rule should evolve.
