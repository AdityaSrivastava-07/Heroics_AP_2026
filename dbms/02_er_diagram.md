mkdir -p dbms
cat << 'EOF' > dbms/02_er_diagram.md
# Phase 2: Entity-Relationship Diagram (Heroics Platform)

## 1. Visual ER Diagram
![Heroics ER Diagram](./02_er_diagram.png)

## 2. Mermaid ER Diagram

```mermaid
erDiagram
    HERO ||--o| GUILD : "leads (GuildMaster)"
    HERO ||--o{ REGISTRATION : "submits"
    HERO ||--o{ BADGE : "earns"
    GUILD ||--o{ QUEST : "organizes"
    QUEST ||--o{ REGISTRATION : "receives"
    QUEST ||--o{ BADGE : "awards"

    HERO {
        Int id PK
        String name
        String email UK
        String passwordHash
        Role role "HERO | GUILD_MASTER | ADMIN"
        Int xp "Default: 0"
        Int level "Default: 1"
        DateTime createdAt
    }

    GUILD {
        Int id PK
        String name UK
        String description
        String logoUrl "Nullable"
        Int headId FK, UK
    }

    QUEST {
        Int id PK
        String title
        String description
        String venue
        Int capacity
        Int xpReward "Default: 50"
        QuestStatus status "PENDING | APPROVED | REJECTED | COMPLETED"
        DateTime startTime
        DateTime endTime
        Int guildId FK
    }

    REGISTRATION {
        Int id PK
        Int heroId FK "Unique with questId"
        Int questId FK "Unique with heroId"
        String qrToken UK "UUID for check-in"
        DateTime createdAt
    }

    BADGE {
        Int id PK
        Int heroId FK "Unique with questId"
        Int questId FK "Unique with heroId"
        DateTime earnedAt
    }
```

## 3. Entity Relationships Summary

* **Hero to Guild (`1:1`):** One `Hero` (with the `GUILD_MASTER` role) can lead at most one `Guild`, enforced by the `@unique` constraint on `Guild.headId`.
* **Guild to Quest (`1:N`):** One `Guild` can organize and host multiple `Quests` (college events), linked via `Quest.guildId`.
* **Hero to Quest via Registration (`M:N`):** A `Hero` can register for multiple `Quests`, and a `Quest` can have many registered `Heroes`. The `Registration` junction table resolves this relationship, enforces a unique `(heroId, questId)` composite constraint to prevent duplicate sign-ups, and stores a unique `qrToken` for event check-in.
* **Hero to Quest via Badge (`M:N`):** When a `Hero` attends a `Quest`, they earn a `Badge`. The `Badge` junction table tracks attendance rewards and enforces a unique `(heroId, questId)` constraint so a student only earns one badge per event.
EOF
