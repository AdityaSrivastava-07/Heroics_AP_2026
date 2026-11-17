# Phase 1: Heroics Database Normalization Report

## 1. First Normal Form (1NF)
A table is in 1NF if it contains only atomic (indivisible) values, has no repeating groups, and every row is unique.
* **Assessment:** All tables in the Heroics Prisma schema (`Hero`, `Guild`, `Quest`, `Registration`, `Badge`) meet 1NF. Every attribute holds a single value (e.g., no comma-separated lists of quests inside the Hero table). Unique constraints on `email`, `Guild.name`, `Guild.headId`, and `Registration.qrToken` ensure row uniqueness alongside the surrogate `id` primary keys.

## 2. Second Normal Form (2NF)
A table is in 2NF if it is in 1NF and contains no partial dependencies (i.e., no non-prime attribute is dependent on just a part of a composite candidate key).
* **Assessment:** All tables meet 2NF. 
* `Hero`, `Guild`, and `Quest` use a single-column surrogate primary key (`id`), meaning partial dependency is impossible. 
* `Registration` and `Badge` have composite candidate keys (`heroId`, `questId`), but their non-prime attributes (`qrToken`, `createdAt`, `earnedAt`) depend on the *entire* relationship between the hero and the quest, not just the hero or just the quest.

## 3. Third Normal Form (3NF)
A table is in 3NF if it is in 2NF and contains no transitive dependencies (i.e., non-prime attributes must depend *only* on the candidate keys, not on other non-prime attributes).

### Tables in 3NF:
* **Guild:** `id` $\rightarrow$ `name`, `description`, `logoUrl`, `headId`. No non-key attributes determine other non-key attributes.
* **Quest:** `id` $\rightarrow$ `title`, `description`, `venue`, `capacity`, `xpReward`, `status`, `startTime`, `endTime`, `guildId`.
* **Registration:** `id` $\rightarrow$ `heroId`, `questId`, `qrToken`, `createdAt`.
* **Badge:** `id` $\rightarrow$ `heroId`, `questId`, `earnedAt`.

### Tables Violating 3NF:
* **Hero:** `id` $\rightarrow$ `name`, `email`, `passwordHash`, `role`, `xp`, `level`, `createdAt`.
* **Violation:** There is a transitive dependency between `xp` and `level`. In gamification systems, a user's `level` is mathematically derived from their `xp` (e.g., 100 XP = Level 2). Therefore, `id` $\rightarrow$ `xp` $\rightarrow$ `level`. 
* **Justification:** We are intentionally breaking 3NF by storing `level` directly in the database. Calculating the level dynamically from `xp` for every leaderboard query or profile load would be computationally expensive. Storing the derived `level` attribute optimizes our read-heavy API operations.
