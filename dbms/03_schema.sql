-- Create Enums
CREATE TYPE "Role" AS ENUM ('HERO', 'GUILD_MASTER', 'ADMIN');
CREATE TYPE "QuestStatus" AS ENUM ('PENDING', 'APPROVED', 'REJECTED', 'COMPLETED');

-- Create Hero Table
CREATE TABLE "Hero" (
    "id" SERIAL PRIMARY KEY,
    "name" VARCHAR(255) NOT NULL,
    "email" VARCHAR(255) NOT NULL UNIQUE,
    "passwordHash" VARCHAR(255) NOT NULL,
    "role" "Role" NOT NULL DEFAULT 'HERO',
    "xp" INTEGER NOT NULL DEFAULT 0,
    "level" INTEGER NOT NULL DEFAULT 1,
    "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Create Guild Table
CREATE TABLE "Guild" (
    "id" SERIAL PRIMARY KEY,
    "name" VARCHAR(255) NOT NULL UNIQUE,
    "description" TEXT NOT NULL,
    "logoUrl" VARCHAR(255),
    "headId" INTEGER NOT NULL UNIQUE,
    CONSTRAINT "Guild_headId_fkey" FOREIGN KEY ("headId") REFERENCES "Hero"("id") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Create Quest Table
CREATE TABLE "Quest" (
    "id" SERIAL PRIMARY KEY,
    "title" VARCHAR(255) NOT NULL,
    "description" TEXT NOT NULL,
    "venue" VARCHAR(255) NOT NULL,
    "capacity" INTEGER NOT NULL,
    "xpReward" INTEGER NOT NULL DEFAULT 50,
    "status" "QuestStatus" NOT NULL DEFAULT 'PENDING',
    "startTime" TIMESTAMP NOT NULL,
    "endTime" TIMESTAMP NOT NULL,
    "guildId" INTEGER NOT NULL,
    CONSTRAINT "Quest_guildId_fkey" FOREIGN KEY ("guildId") REFERENCES "Guild"("id") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Create Registration Table
CREATE TABLE "Registration" (
    "id" SERIAL PRIMARY KEY,
    "heroId" INTEGER NOT NULL,
    "questId" INTEGER NOT NULL,
    "qrToken" VARCHAR(255) NOT NULL UNIQUE,
    "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "Registration_heroId_fkey" FOREIGN KEY ("heroId") REFERENCES "Hero"("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "Registration_questId_fkey" FOREIGN KEY ("questId") REFERENCES "Quest"("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    UNIQUE ("heroId", "questId")
);

-- Create Badge Table
CREATE TABLE "Badge" (
    "id" SERIAL PRIMARY KEY,
    "heroId" INTEGER NOT NULL,
    "questId" INTEGER NOT NULL,
    "earnedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "Badge_heroId_fkey" FOREIGN KEY ("heroId") REFERENCES "Hero"("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "Badge_questId_fkey" FOREIGN KEY ("questId") REFERENCES "Quest"("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    UNIQUE ("heroId", "questId")
);