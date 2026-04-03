---
name: database-engineering
description: Comprehensive database skill — schema design, query optimization, index strategy, migration safety, RLS policies, type generation, and performance analysis. Owned by database-reviewer agent.
owner: database-reviewer
tier: POWERFUL
origin: Merged from database-designer + database-schema-designer
---

# Database Engineering

Expert-level database design, optimization, and migration capabilities. This skill combines strategic database architecture with practical implementation patterns.

## Core Capabilities

- **Schema design** — normalize requirements into tables, relationships, constraints
- **Index optimization** — composite, partial, covering indexes with selectivity analysis
- **Migration safety** — zero-downtime patterns, rollback strategies, lock awareness
- **Query analysis** — EXPLAIN ANALYZE, N+1 detection, join optimization
- **Type generation** — TypeScript interfaces, Python dataclasses from schema
- **Migration generation** — Drizzle, Prisma, TypeORM, Alembic
- **RLS policies** — Row-Level Security for multi-tenant apps
- **ERD generation** — Mermaid diagrams from schema
- **Seed data** — realistic test data generation

---

## Schema Design Process

### Step 1: Requirements to Entities
Extract entities from requirements, identify relationships, then add cross-cutting concerns:

- **Multi-tenancy**: `organization_id` on all tenant-scoped tables
- **Soft deletes**: `deleted_at TIMESTAMPTZ` instead of hard deletes
- **Audit trail**: `created_by`, `updated_by`, `created_at`, `updated_at`
- **Optimistic locking**: `version INTEGER` where concurrent updates are possible

### Step 2: Normalization

**1NF** — Atomic values, no repeating groups
**2NF** — No partial dependencies on composite keys
**3NF** — No transitive dependencies between non-key attributes
**BCNF** — Every determinant is a candidate key

### Step 3: Intentional Denormalization

Denormalize only when:
1. Read-heavy workloads with acceptable write trade-offs
2. Join operations causing measured latency
3. Frequent aggregation of derived values
4. Pre-computed results for hot queries

Common patterns: redundant storage, materialized aggregates, summary tables.

---

## Index Strategy

### B-Tree (default)
Best for range queries, sorting, equality. Column order matters — most selective first.

### Composite Indexes
```sql
-- Query: WHERE status = 'active' AND created_date > '2023-01-01' ORDER BY priority DESC
CREATE INDEX idx_task_status_date_priority
ON tasks (status, created_date, priority DESC);
```

### Covering Indexes
```sql
-- Avoid table lookups entirely
CREATE INDEX idx_user_email_covering
ON users (email)
INCLUDE (first_name, last_name, status);
```

### Partial Indexes
```sql
-- Index only the subset you query
CREATE INDEX idx_active_users_email
ON users (email)
WHERE status = 'active';
```

### Index Rules
- Every foreign key gets an index
- Composite indexes: most selective column first
- Flag unused indexes (write cost, no read benefit)
- Flag missing indexes (sequential scans on large tables)

---

## Migration Safety

### Zero-Downtime Pattern (Expand-Contract)

**Phase 1: Expand** — add new column without constraints, backfill in batches, then add constraints
**Phase 2: Contract** — deploy app changes, verify, then drop old column

### Risk Levels
- **Safe**: new columns, new tables, new indexes
- **Caution**: adding NOT NULL (needs default), adding constraints to existing data
- **Dangerous**: column drops, type changes, table renames — need expand-contract

### Lock Awareness
```sql
-- This locks the entire table — dangerous on large tables:
ALTER TABLE users ADD COLUMN age INTEGER NOT NULL DEFAULT 0;

-- This does NOT lock (Postgres 11+):
ALTER TABLE users ADD COLUMN age INTEGER;
-- Then backfill in batches, then add constraint
```

---

## Query Optimization

### Always Check
- N+1 queries — the #1 performance killer
- Missing WHERE on UPDATE/DELETE
- SELECT * in production code
- Unbounded queries (no LIMIT)
- Subquery vs JOIN vs CTE — pick the right tool

### EXPLAIN ANALYZE
Always run before and after optimization. Show the numbers, not opinions.

```sql
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT * FROM orders
WHERE customer_id = 123
AND status = 'active'
ORDER BY created_at DESC
LIMIT 20;
```

---

## Row-Level Security (RLS)

```sql
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;

-- Org isolation
CREATE POLICY tasks_org_isolation ON tasks
  FOR ALL TO app_user
  USING (
    project_id IN (
      SELECT p.id FROM projects p
      JOIN organization_members om ON om.organization_id = p.organization_id
      WHERE om.user_id = current_setting('app.current_user_id')::text
    )
  );

-- Hide soft-deleted records
CREATE POLICY tasks_no_deleted ON tasks
  FOR SELECT TO app_user
  USING (deleted_at IS NULL);
```

---

## Type Generation

### Drizzle (TypeScript)
```typescript
export const tasks = pgTable('tasks', {
  id:        text('id').primaryKey().$defaultFn(() => createId()),
  projectId: text('project_id').notNull().references(() => projects.id),
  title:     varchar('title', { length: 500 }).notNull(),
  status:    taskStatusEnum('status').notNull().default('todo'),
  createdAt: timestamp('created_at', { withTimezone: true }).notNull().defaultNow(),
}, (table) => ({
  projectIdx:       index('tasks_project_id_idx').on(table.projectId),
  projectStatusIdx: index('tasks_project_status_idx').on(table.projectId, table.status),
}))

export type Task = typeof tasks.$inferSelect
export type NewTask = typeof tasks.$inferInsert
```

### Alembic (Python)
```python
def upgrade() -> None:
    op.create_table('tasks',
        sa.Column('id', sa.Text(), primary_key=True),
        sa.Column('project_id', sa.Text(), sa.ForeignKey('projects.id'), nullable=False),
        sa.Column('title', sa.VARCHAR(500), nullable=False),
        sa.Column('status', task_status_enum, nullable=False, server_default='todo'),
        sa.Column('created_at', sa.TIMESTAMP(timezone=True), nullable=False, server_default=sa.text('NOW()')),
    )
    op.create_index('tasks_project_id_idx', 'tasks', ['project_id'])

def downgrade() -> None:
    op.drop_table('tasks')
```

---

## Data Modeling Patterns

### Star Schema (analytics)
Central fact table with dimension tables for OLAP queries.

### Document Model (flexible schema)
```sql
CREATE TABLE documents (
    id UUID PRIMARY KEY,
    document_type VARCHAR(50),
    data JSONB,
    created_at TIMESTAMP DEFAULT NOW()
);
CREATE INDEX idx_docs_data ON documents USING GIN (data);
```

### Adjacency List (hierarchical data)
```sql
CREATE TABLE categories (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    parent_id INT REFERENCES categories(id),
    path VARCHAR(500)  -- Materialized path: "/1/5/12/"
);
```

---

## Database Selection Guide

| Database | Best For | Trade-offs |
|----------|---------|------------|
| **PostgreSQL** | OLTP, complex queries, JSON, geospatial | Vertical scaling |
| **MySQL** | Web apps, e-commerce, replication | Less extensible |
| **Redis** | Caching, sessions, real-time | Memory-bound, limited queries |
| **MongoDB** | Flexible schema, catalogs, profiles | Eventual consistency |
| **DynamoDB** | Key-value at scale, serverless | Limited query flexibility |

---

## Common Pitfalls

- Soft delete without partial index on `deleted_at IS NULL`
- Missing composite index for multi-column WHERE clauses
- Using email/slug as PK instead of UUID/CUID
- Adding NOT NULL column without default or migration plan
- No optimistic locking on concurrent-update tables
- RLS policies not tested with non-superuser role
- Nullable columns without clear "when is this legitimately empty?" answer

---

## Tools (included)

- `schema_analyzer.py` — normalization compliance, constraint validation, naming conventions
- `index_optimizer.py` — missing indexes, redundancy detection, selectivity estimation
- `migration_generator.py` — diff-based migration scripts, rollback plans, validation queries
