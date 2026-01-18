-- ============================================================
-- Script Name   : 01_create_database_and_schemas.sql
-- Purpose       : Create Data Warehouse database and layers
-- Author        : Vadla Kalpana
-- Description   : This script creates the main database and
--                 Bronze, Silver, and Gold schemas.
-- ============================================================

-- =====================
-- TRANSACTION START
-- =====================
START TRANSACTION;

-- Step 1: Create the Data Warehouse database
CREATE DATABASE IF NOT EXISTS DataWarehouse;

-- Step 2: Use the newly created database
USE DataWarehouse;

-- Step 3: Create schemas for data layers
CREATE SCHEMA IF NOT EXISTS Bronze;   -- Raw / Source layer
CREATE SCHEMA IF NOT EXISTS Silver;   -- Cleansed / Transformed layer
CREATE SCHEMA IF NOT EXISTS Gold;     -- Curated / Analytics layer

-- =====================
-- COMMIT CHANGES
-- =====================
COMMIT;

-- =====================
-- ROLLBACK (Use only if something fails before commit)
-- =====================
-- ROLLBACK;
