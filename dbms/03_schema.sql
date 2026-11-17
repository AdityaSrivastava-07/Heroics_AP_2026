-- ============================================================================
-- Heroics AP 2026: Campus Event & Club Management Platform
-- Raw PostgreSQL DDL converted from Prisma Schema
-- File: dbms/03_schema.sql
-- ============================================================================

-- 1. ENUM Types
CREATE TYPE "Role" AS ENUM ('STUDENT', 'CLUB_HEAD', 'ADMIN');
CREATE TYPE "EventStatus" AS ENUM ('PENDING', 'APPROVED', 'REJECTED', 'CANCELLED');
CREATE TYPE "RegStatus" AS ENUM ('REGISTERED', 'WAITLISTED', 'CANCELLED');

-- 2. Tables

-- User Table
CREATE TABLE "User" (
    "id" SERIAL PRIMARY KEY,
    "name" TEXT NOT NULL,
    "email" TEXT NOT NULL UNIQUE,
    "passwordHash" TEXT NOT NULL,
    "role" "Role" NOT NULL DEFAULT 'STUDENT',
    "rollNo" TEXT,
    "branch" TEXT,
    "year" INTEGER,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Club Table (1:1 relationship with User as ClubHead)
CREATE TABLE "Club" (
    "id" SERIAL PRIMARY KEY,
    "name" TEXT NOT NULL UNIQUE,
    "description" TEXT NOT NULL,
    "logoUrl" TEXT,
    "headId" INTEGER NOT NULL UNIQUE,
    CONSTRAINT "Club_headId_fkey"
        FOREIGN KEY ("headId") REFERENCES "User"("id")
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Event Table (N:1 relationship with Club)
CREATE TABLE "Event" (
    "id" SERIAL PRIMARY KEY,
    "title" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "venue" TEXT NOT NULL,
    "category" TEXT NOT NULL,
    "bannerUrl" TEXT,
    "startTime" TIMESTAMP(3) NOT NULL,
    "endTime" TIMESTAMP(3) NOT NULL,
    "capacity" INTEGER NOT NULL CHECK ("capacity" > 0),
    "status" "EventStatus" NOT NULL DEFAULT 'PENDING',
    "rejectionReason" TEXT,
    "clubId" INTEGER NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "Event_clubId_fkey"
        FOREIGN KEY ("clubId") REFERENCES "Club"("id")
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "Event_time_check"
        CHECK ("endTime" > "startTime")
);

-- Registration Table (M:N bridge between User and Event)
CREATE TABLE "Registration" (
    "id" SERIAL PRIMARY KEY,
    "userId" INTEGER NOT NULL,
    "eventId" INTEGER NOT NULL,
    "status" "RegStatus" NOT NULL DEFAULT 'REGISTERED',
    "qrToken" TEXT NOT NULL UNIQUE DEFAULT gen_random_uuid()::TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "Registration_userId_fkey"
        FOREIGN KEY ("userId") REFERENCES "User"("id")
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "Registration_eventId_fkey"
        FOREIGN KEY ("eventId") REFERENCES "Event"("id")
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "Registration_userId_eventId_key"
        UNIQUE ("userId", "eventId")
);

-- Attendance Table (1:1 relationship with Registration)
CREATE TABLE "Attendance" (
    "id" SERIAL PRIMARY KEY,
    "registrationId" INTEGER NOT NULL UNIQUE,
    "checkedInAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "Attendance_registrationId_fkey"
        FOREIGN KEY ("registrationId") REFERENCES "Registration"("id")
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Notification Table (N:1 relationship with User)
CREATE TABLE "Notification" (
    "id" SERIAL PRIMARY KEY,
    "userId" INTEGER NOT NULL,
    "message" TEXT NOT NULL,
    "isRead" BOOLEAN NOT NULL DEFAULT FALSE,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "Notification_userId_fkey"
        FOREIGN KEY ("userId") REFERENCES "User"("id")
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- 3. Performance Indexes for Common Query Patterns
CREATE INDEX "Event_clubId_idx" ON "Event"("clubId");
CREATE INDEX "Event_status_startTime_idx" ON "Event"("status", "startTime");
CREATE INDEX "Registration_eventId_status_idx" ON "Registration"("eventId", "status");
CREATE INDEX "Notification_userId_isRead_idx" ON "Notification"("userId", "isRead");