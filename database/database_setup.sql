-- ============================================================
-- MoMo SMS Data Processing System — Database Setup Script
-- Version: 1.0.0
-- Description: Full DDL + DML for MoMo transaction database
-- ============================================================

-- Create and select database
CREATE DATABASE IF NOT EXISTS momo_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE momo_db;

-- ============================================================
-- TABLE: Users
-- Description: Registered MoMo account holders (senders/receivers)
-- ============================================================
CREATE TABLE IF NOT EXISTS Users (
    User_ID         INT            AUTO_INCREMENT PRIMARY KEY COMMENT 'Unique identifier for each user',
    Full_Name       VARCHAR(100)   NOT NULL                   COMMENT 'Full name of the user',
    Phone_Number    VARCHAR(15)    NOT NULL                   COMMENT 'Unique mobile phone number (E.164 format)',
    Account_Balance DECIMAL(15,2)  NOT NULL DEFAULT 0.00      COMMENT 'Current balance in RWF',
    Email           VARCHAR(100)   UNIQUE                     COMMENT 'Optional email address',
    Is_Active       TINYINT(1)     NOT NULL DEFAULT 1         COMMENT '1 = active, 0 = suspended',
    Created_At      DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Account creation timestamp',
    Updated_At      DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Last updated timestamp',

    CONSTRAINT uq_phone      UNIQUE (Phone_Number),
    CONSTRAINT chk_balance   CHECK  (Account_Balance >= 0)
) COMMENT='MoMo registered account holders';


-- ============================================================
-- TABLE: Transaction_Categories
-- Description: Classifies the type of each transaction
-- ============================================================
CREATE TABLE IF NOT EXISTS Transaction_Categories (
    Category_ID     INT            AUTO_INCREMENT PRIMARY KEY COMMENT 'Unique category identifier',
    Category_Name   VARCHAR(50)    NOT NULL UNIQUE            COMMENT 'Human-readable category name',
    Description     TEXT                                      COMMENT 'Detailed description of the category',
    Is_Active       TINYINT(1)     NOT NULL DEFAULT 1         COMMENT '1 = active category',
    Created_At      DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Category creation timestamp',

    CONSTRAINT chk_cat_name  CHECK (CHAR_LENGTH(Category_Name) >= 2)
) COMMENT='Classifies transaction types (Transfer, Payment, etc.)';

