# Phase 4: Heroics Query Execution Timings

All queries were benchmarked against the PostgreSQL ⁠ heroics ⁠ database using ⁠ EXPLAIN (ANALYZE, BUFFERS) ⁠ across 3 consecutive runs (with write queries wrapped inside ⁠ BEGIN; ... ROLLBACK; ⁠ to preserve database state).

| Query | Type | What it does | Run 1 (ms) | Run 2 (ms) | Run 3 (ms) | Average (ms) | Scan type |
| :--- | :--- | :--- | ---: | ---: | ---: | ---: | :--- |
| R1 | READ | Login & profile lookup by email | 0.041 | 0.032 | 0.032 | 0.035 | Index Scan (⁠ Hero_email_key ⁠) |
| R2 | READ | Campus leaderboard (Top 10 Heroes by XP) | 0.209 | 0.043 | 0.043 | 0.098 | Seq Scan on ⁠ Hero ⁠ |
| R3 | READ | Active quest board with guild details | 0.679 | 0.060 | 0.063 | 0.267 | Seq Scan on ⁠ Quest ⁠, Index Scan on ⁠ Guild ⁠ |
| R4 | READ | Guild dashboard quests & registration count | 0.086 | 0.084 | 0.099 | 0.090 | Seq Scan on ⁠ Quest ⁠ & ⁠ Registration ⁠ |
| R5 | READ | Verify QR token at event check-in | 0.062 | 0.046 | 0.048 | 0.052 | Index Scan (⁠ Registration_qrToken_key ⁠) |
| R6 | READ | Hero profile earned badges history | 0.084 | 0.073 | 0.073 | 0.077 | Bitmap Heap Scan on ⁠ Badge ⁠, Seq Scan on ⁠ Quest ⁠ |
| R7 | READ | Admin pending quest approvals queue | 0.073 | 0.065 | 0.068 | 0.069 | Seq Scan on ⁠ Quest ⁠ & ⁠ Guild ⁠ |
| R8 | READ | Guild engagement & total badges analytics | 0.725 | 0.159 | 0.163 | 0.349 | Seq Scan on ⁠ Guild ⁠, ⁠ Quest ⁠, ⁠ Badge ⁠ |
| W1 | WRITE | Register a Hero for a Quest | 0.501 | 0.426 | 0.563 | 0.497 | — |
| W2 | WRITE | Award XP & recalculate Hero level | 0.671 | 0.126 | 0.140 | 0.312 | — |

## Key Observations
•⁠  ⁠Sub-Millisecond Latency: Every core read and write operation completes in under ⁠ 0.5 ms ⁠ on average (⁠ 0.035 ms ⁠ to ⁠ 0.497 ms ⁠).
•⁠  ⁠Unique Index Efficiency: Point lookups for login (⁠ R1 ⁠: ⁠ 0.035 ms ⁠) and QR check-in (⁠ R5 ⁠: ⁠ 0.052 ms ⁠) leverage Prisma's ⁠ @unique ⁠ B-Tree indexes (⁠ Hero_email_key ⁠ and ⁠ Registration_qrToken_key ⁠) for near-instantaneous execution.
•⁠  ⁠Cold vs. Warm Cache: Initial runs (⁠ Run 1 ⁠ on ⁠ R2 ⁠, ⁠ R3 ⁠, ⁠ R8 ⁠, ⁠ W2 ⁠) show slightly higher latency due to reading blocks from disk into PostgreSQL shared buffers, dropping by 75%–90% on ⁠ Run 2 ⁠ and ⁠ Run 3 ⁠.
