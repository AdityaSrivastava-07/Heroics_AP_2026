-- ==========================================
-- Phase 3: Heroics Core Application Queries
-- ==========================================

-- 1. Hero Authentication & Profile Lookup (Login)
SELECT "id", "name", "email", "passwordHash", "role", "xp", "level"
FROM "Hero"
WHERE "email" = 'student@nst.edu';

-- 2. Campus Leaderboard (Top 10 Heroes by XP)
SELECT "id", "name", "xp", "level"
FROM "Hero"
WHERE "role" = 'HERO'
ORDER BY "xp" DESC, "createdAt" ASC
LIMIT 10;

-- 3. Active Quest Board (Approved Upcoming Quests with Guild Details)
SELECT 
    q."id", q."title", q."venue", q."capacity", q."xpReward", q."startTime", q."endTime",
    g."name" AS "guildName", g."logoUrl"
FROM "Quest" q
JOIN "Guild" g ON q."guildId" = g."id"
WHERE q."status" = 'APPROVED' AND q."startTime" > NOW()
ORDER BY q."startTime" ASC;

-- 4. Guild Dashboard (Quests Hosted by a Specific Guild with Registration Counts)
SELECT 
    q."id", q."title", q."status", q."capacity",
    COUNT(r."id") AS "registeredCount"
FROM "Quest" q
LEFT JOIN "Registration" r ON q."id" = r."questId"
WHERE q."guildId" = 1
GROUP BY q."id"
ORDER BY q."startTime" DESC;

-- 5. Register a Hero for a Quest
INSERT INTO "Registration" ("heroId", "questId", "qrToken")
VALUES (1, 10, '550e8400-e29b-41d4-a716-446655440000')
RETURNING "id", "qrToken", "createdAt";

-- 6. Verify QR Token at Event Check-In
SELECT 
    r."id" AS "registrationId", r."heroId", r."questId",
    h."name" AS "heroName", q."title" AS "questTitle", q."xpReward"
FROM "Registration" r
JOIN "Hero" h ON r."heroId" = h."id"
JOIN "Quest" q ON r."questId" = q."id"
WHERE r."qrToken" = '550e8400-e29b-41d4-a716-446655440000';

-- 7. Award Badge & Update Hero XP/Level (Attendance Verification)
INSERT INTO "Badge" ("heroId", "questId")
VALUES (1, 10);

UPDATE "Hero"
SET "xp" = "xp" + 50,
    "level" = FLOOR(("xp" + 50) / 100) + 1
WHERE "id" = 1
RETURNING "id", "xp", "level";

-- 8. Hero Profile: Earned Badges History
SELECT 
    b."earnedAt", q."title" AS "questTitle", q."xpReward", g."name" AS "guildName"
FROM "Badge" b
JOIN "Quest" q ON b."questId" = q."id"
JOIN "Guild" g ON q."guildId" = g."id"
WHERE b."heroId" = 1
ORDER BY b."earnedAt" DESC;

-- 9. Admin Pending Approvals Queue
SELECT 
    q."id", q."title", q."venue", q."startTime",
    g."name" AS "guildName", h."name" AS "guildMasterName"
FROM "Quest" q
JOIN "Guild" g ON q."guildId" = g."id"
JOIN "Hero" h ON g."headId" = h."id"
WHERE q."status" = 'PENDING'
ORDER BY q."startTime" ASC;

-- 10. Guild Engagement Analytics (Total Badges Awarded per Guild)
SELECT 
    g."id", g."name",
    COUNT(DISTINCT q."id") AS "totalQuests",
    COUNT(b."id") AS "totalBadgesAwarded"
FROM "Guild" g
LEFT JOIN "Quest" q ON g."id" = q."guildId"
LEFT JOIN "Badge" b ON q."id" = b."questId"
GROUP BY g."id", g."name"
ORDER BY "totalBadgesAwarded" DESC;
