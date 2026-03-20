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

-- ============================================================
-- TABLE: Transactions
-- Description: Core financial transaction records from MoMo SMS
-- ============================================================
CREATE TABLE IF NOT EXISTS Transactions (
    Transaction_ID              INT            AUTO_INCREMENT PRIMARY KEY COMMENT 'Unique transaction identifier',
    Sender_ID                   INT            NOT NULL                   COMMENT 'FK to Users — the payer',
    Receiver_ID                 INT            NOT NULL                   COMMENT 'FK to Users — the payee',
    Transaction_Amount          DECIMAL(15,2)  NOT NULL                   COMMENT 'Amount transferred in RWF',
    Fee                         DECIMAL(15,2)  NOT NULL DEFAULT 0.00      COMMENT 'Transaction fee charged',
    Balance_After_Transaction   DECIMAL(15,2)                             COMMENT 'Sender balance after deduction',
    Transaction_DateTime        DATETIME       NOT NULL                   COMMENT 'Date and time of the transaction',
    Transaction_Category_ID     INT                                       COMMENT 'FK to Transaction_Categories',
    Transaction_Reference       VARCHAR(50)    UNIQUE                     COMMENT 'Unique reference code (e.g. TX1001)',
    Status                      ENUM('Success','Failed','Pending')
                                               NOT NULL DEFAULT 'Pending' COMMENT 'Current transaction status',
    Description                 VARCHAR(255)                              COMMENT 'Optional memo or description',
    Created_At                  DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Record insertion timestamp',

    CONSTRAINT fk_tx_sender     FOREIGN KEY (Sender_ID)               REFERENCES Users(User_ID)                  ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_tx_receiver   FOREIGN KEY (Receiver_ID)             REFERENCES Users(User_ID)                  ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_tx_category   FOREIGN KEY (Transaction_Category_ID) REFERENCES Transaction_Categories(Category_ID) ON DELETE SET NULL ON UPDATE CASCADE,

    CONSTRAINT chk_amount       CHECK (Transaction_Amount > 0),
    CONSTRAINT chk_fee          CHECK (Fee >= 0),
    CONSTRAINT chk_not_self     CHECK (Sender_ID <> Receiver_ID)
) COMMENT='Core MoMo transaction records parsed from SMS data';


-- ============================================================
-- TABLE: Transaction_Category_Mapping  (JUNCTION TABLE — resolves M:N)
-- Description: One transaction can belong to multiple categories
--              (e.g. a "Merchant Payment" is both Payment + Transfer)
-- ============================================================
CREATE TABLE IF NOT EXISTS Transaction_Category_Mapping (
    Mapping_ID      INT  AUTO_INCREMENT PRIMARY KEY COMMENT 'Surrogate PK for this junction',
    Transaction_ID  INT  NOT NULL                   COMMENT 'FK to Transactions',
    Category_ID     INT  NOT NULL                   COMMENT 'FK to Transaction_Categories',
    Assigned_At     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'When mapping was assigned',

    CONSTRAINT fk_map_tx   FOREIGN KEY (Transaction_ID) REFERENCES Transactions(Transaction_ID)         ON DELETE CASCADE,
    CONSTRAINT fk_map_cat  FOREIGN KEY (Category_ID)    REFERENCES Transaction_Categories(Category_ID)  ON DELETE CASCADE,
    CONSTRAINT uq_tx_cat   UNIQUE (Transaction_ID, Category_ID)
) COMMENT='Junction table resolving many-to-many between Transactions and Transaction_Categories';

-- ============================================================
-- TABLE: System_Logs
-- Description: Audit trail for ETL pipeline and system events
-- ============================================================
CREATE TABLE IF NOT EXISTS System_Logs (
    Log_ID            INT            AUTO_INCREMENT PRIMARY KEY COMMENT 'Unique log entry ID',
    Event_Type        ENUM('INFO','WARNING','ERROR','DEBUG')
                                     NOT NULL DEFAULT 'INFO'    COMMENT 'Severity level of the event',
    Event_Source      VARCHAR(100)                              COMMENT 'Module or service that generated the log',
    Event_Description TEXT           NOT NULL                   COMMENT 'Detailed description of the event',
    Transaction_ID    INT                                       COMMENT 'Optional FK to related transaction',
    User_ID           INT                                       COMMENT 'Optional FK to related user',
    IP_Address        VARCHAR(45)                               COMMENT 'IPv4 or IPv6 address of client',
    Created_At        DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when event was logged',

    CONSTRAINT fk_log_user  FOREIGN KEY (User_ID)        REFERENCES Users(User_ID)        ON DELETE SET NULL,
    CONSTRAINT fk_log_tx    FOREIGN KEY (Transaction_ID) REFERENCES Transactions(Transaction_ID) ON DELETE SET NULL
) COMMENT='System audit logs for ETL pipeline processing and security events';


-- ============================================================
-- INDEXES — Performance optimisation
-- ============================================================
CREATE INDEX idx_tx_sender        ON Transactions(Sender_ID);
CREATE INDEX idx_tx_receiver      ON Transactions(Receiver_ID);
CREATE INDEX idx_tx_datetime      ON Transactions(Transaction_DateTime);
CREATE INDEX idx_tx_status        ON Transactions(Status);
CREATE INDEX idx_tx_category      ON Transactions(Transaction_Category_ID);
CREATE INDEX idx_log_event_type   ON System_Logs(Event_Type);
CREATE INDEX idx_log_created      ON System_Logs(Created_At);
CREATE INDEX idx_log_tx           ON System_Logs(Transaction_ID);
CREATE INDEX idx_user_phone       ON Users(Phone_Number);
