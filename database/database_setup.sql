-- ============================================================================
-- MoMo SMS Data Processing System - Database Setup
-- ============================================================================
-- Description: Complete database schema for mobile money transaction processing
-- Created: February 2026
-- Database: MySQL 8.0+
-- ============================================================================

-- Drop existing database if exists (for clean setup)
DROP DATABASE IF EXISTS momo_db;
CREATE DATABASE momo_db;
USE momo_db;

-- ============================================================================
-- TABLE 1: Users (Customers/Account Holders)
-- ============================================================================
-- Stores information about all MoMo users (both senders and receivers)

CREATE TABLE Users (
    User_ID INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Unique identifier for each user',
    Full_Name VARCHAR(100) NOT NULL COMMENT 'Full legal name of the account holder',
    Phone_Number VARCHAR(15) NOT NULL UNIQUE COMMENT 'Unique phone number (MoMo account identifier)',
    Account_Balance DECIMAL(15,2) DEFAULT 0.00 COMMENT 'Current account balance in RWF',
    Email VARCHAR(100) COMMENT 'Optional email address',
    Date_Of_Birth DATE COMMENT 'User date of birth for verification',
    Account_Status ENUM('Active', 'Suspended', 'Closed') DEFAULT 'Active' COMMENT 'Account operational status',
    Created_At DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'Account creation timestamp',
    Updated_At DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Last update timestamp',
    
    -- Constraints
    CHECK (Account_Balance >= 0) -- Balance cannot be negative
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='MoMo account holder information';

-- ============================================================================
-- TABLE 2: Transaction_Categories
-- ============================================================================
-- Defines different types of mobile money transactions

CREATE TABLE Transaction_Categories (
    Category_ID INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Unique category identifier',
    Category_Name VARCHAR(50) NOT NULL UNIQUE COMMENT 'Name of transaction category',
    Description TEXT COMMENT 'Detailed description of the category',
    Fee_Percentage DECIMAL(5,2) DEFAULT 0.00 COMMENT 'Default fee percentage for this category',
    Is_Active BOOLEAN DEFAULT TRUE COMMENT 'Whether this category is currently active',
    Created_At DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'Category creation timestamp',
    
    -- Constraints
    CHECK (Fee_Percentage >= 0 AND Fee_Percentage <= 100) -- Fee must be valid percentage
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Transaction type classifications';

-- ============================================================================
-- TABLE 3: Transactions
-- ============================================================================
-- Main transaction records for all MoMo operations

CREATE TABLE Transactions (
    Transaction_ID INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Unique transaction identifier',
    Sender_ID INT NOT NULL COMMENT 'User who initiated the transaction',
    Receiver_ID INT COMMENT 'User who received the transaction (NULL for withdrawals)',
    Transaction_Amount DECIMAL(15,2) NOT NULL COMMENT 'Transaction amount in RWF',
    Fee DECIMAL(15,2) DEFAULT 0.00 COMMENT 'Transaction fee charged',
    Net_Amount DECIMAL(15,2) GENERATED ALWAYS AS (Transaction_Amount - Fee) STORED COMMENT 'Amount after fee deduction',
    Balance_After_Transaction DECIMAL(15,2) COMMENT 'Sender balance after transaction',
    Transaction_DateTime DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'When transaction occurred',
    Transaction_Category_ID INT NOT NULL COMMENT 'Type of transaction',
    Transaction_Reference VARCHAR(50) UNIQUE COMMENT 'Unique transaction reference number',
    Status ENUM('Success', 'Failed', 'Pending', 'Reversed') DEFAULT 'Success' COMMENT 'Transaction status',
    Failure_Reason VARCHAR(255) COMMENT 'Reason if transaction failed',
    Created_At DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    
    -- Foreign Keys
    FOREIGN KEY (Sender_ID) REFERENCES Users(User_ID) ON DELETE RESTRICT,
    FOREIGN KEY (Receiver_ID) REFERENCES Users(User_ID) ON DELETE RESTRICT,
    FOREIGN KEY (Transaction_Category_ID) REFERENCES Transaction_Categories(Category_ID) ON DELETE RESTRICT,
    
    -- Constraints
    CHECK (Transaction_Amount > 0), -- Amount must be positive
    CHECK (Fee >= 0), -- Fee cannot be negative
    CHECK (Balance_After_Transaction >= 0) -- Balance cannot go negative
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='All MoMo transaction records';

-- ============================================================================
-- TABLE 4: System_Logs
-- ============================================================================
-- Tracks all system events for monitoring and debugging

CREATE TABLE System_Logs (
    Log_ID INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Unique log entry identifier',
    Event_Type VARCHAR(50) NOT NULL COMMENT 'Type of event (e.g., Transaction, Login, Error)',
    Event_Description TEXT COMMENT 'Detailed description of the event',
    User_ID INT COMMENT 'Associated user (NULL for system events)',
    Transaction_ID INT COMMENT 'Associated transaction if applicable',
    IP_Address VARCHAR(45) COMMENT 'IP address of the request',
    Severity ENUM('Info', 'Warning', 'Error', 'Critical') DEFAULT 'Info' COMMENT 'Event severity level',
    Created_At DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'When the event occurred',
    
    -- Foreign Keys
    FOREIGN KEY (User_ID) REFERENCES Users(User_ID) ON DELETE SET NULL,
    FOREIGN KEY (Transaction_ID) REFERENCES Transactions(Transaction_ID) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='System event and error logging';

-- ============================================================================
-- TABLE 5: Transaction_Category_Mapping (Junction Table for M:N)
-- ============================================================================
-- Resolves many-to-many relationship: one transaction can have multiple categories
-- Example: A transaction might be both "International Transfer" AND "Premium Service"

CREATE TABLE Transaction_Category_Mapping (
    Mapping_ID INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Unique mapping identifier',
    Transaction_ID INT NOT NULL COMMENT 'Reference to transaction',
    Category_ID INT NOT NULL COMMENT 'Reference to category',
    Applied_At DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'When this category was applied',
    
    -- Foreign Keys
    FOREIGN KEY (Transaction_ID) REFERENCES Transactions(Transaction_ID) ON DELETE CASCADE,
    FOREIGN KEY (Category_ID) REFERENCES Transaction_Categories(Category_ID) ON DELETE CASCADE,
    
    -- Ensure each transaction-category combination is unique
    UNIQUE KEY unique_transaction_category (Transaction_ID, Category_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Many-to-many mapping between transactions and categories';

-- ============================================================================
-- INDEXES FOR PERFORMANCE OPTIMIZATION
-- ============================================================================

-- Users table indexes
CREATE INDEX idx_phone_number ON Users(Phone_Number);
CREATE INDEX idx_account_status ON Users(Account_Status);
CREATE INDEX idx_created_at_users ON Users(Created_At);

-- Transactions table indexes
CREATE INDEX idx_transaction_date ON Transactions(Transaction_DateTime);
CREATE INDEX idx_sender ON Transactions(Sender_ID);
CREATE INDEX idx_receiver ON Transactions(Receiver_ID);
CREATE INDEX idx_status ON Transactions(Status);
CREATE INDEX idx_reference ON Transactions(Transaction_Reference);
CREATE INDEX idx_category ON Transactions(Transaction_Category_ID);

-- Composite index for common queries
CREATE INDEX idx_sender_date ON Transactions(Sender_ID, Transaction_DateTime);
CREATE INDEX idx_receiver_date ON Transactions(Receiver_ID, Transaction_DateTime);

-- System_Logs indexes
CREATE INDEX idx_event_type ON System_Logs(Event_Type);
CREATE INDEX idx_severity ON System_Logs(Severity);
CREATE INDEX idx_created_at_logs ON System_Logs(Created_At);
CREATE INDEX idx_user_logs ON System_Logs(User_ID);

-- ============================================================================
-- SAMPLE DATA INSERTION
-- ============================================================================

-- Insert Sample Users (at least 5 records)
INSERT INTO Users (Full_Name, Phone_Number, Account_Balance, Email, Date_Of_Birth, Account_Status) VALUES
('Sylvie UMUTONI RUTAGANIRA', '+250788123456', 50000.00, 'sylvie.umutoni@email.rw', '1995-03-15', 'Active'),
('Elvire AKAYEZU', '+250795149666', 30000.00, 'elvire.akayezu@email.rw', '1992-07-22', 'Active'),
('Jean Claude NIYONZIMA', '+250788345678', 75000.00, 'jc.niyonzima@email.rw', '1988-11-05', 'Active'),
('Marie UWERA', '+250788456789', 42000.00, 'marie.uwera@email.rw', '1997-01-30', 'Active'),
('Patrick HABIMANA', '+250788567890', 68000.00, 'patrick.habimana@email.rw', '1990-09-12', 'Active'),
('Alice MUKESHIMANA', '+250788678901', 25000.00, 'alice.mukesh@email.rw', '1999-04-18', 'Active'),
('David MUGISHA', '+250788789012', 90000.00, 'david.mugisha@email.rw', '1985-06-25', 'Suspended');

-- Insert Transaction Categories (at least 5 records)
INSERT INTO Transaction_Categories (Category_Name, Description, Fee_Percentage, Is_Active) VALUES
('Money Transfer', 'Person-to-person money transfer within Rwanda', 1.50, TRUE),
('Bill Payment', 'Payment for utilities, services, and bills', 0.50, TRUE),
('Airtime Purchase', 'Mobile airtime and data bundle purchase', 0.00, TRUE),
('Merchant Payment', 'Payment to registered merchants and businesses', 1.00, TRUE),
('Cash Withdrawal', 'ATM or agent cash withdrawal', 2.00, TRUE),
('International Transfer', 'Cross-border money transfer', 3.50, TRUE),
('Salary Payment', 'Bulk salary disbursement to employees', 0.75, TRUE);

-- Insert Sample Transactions (at least 5 records)
INSERT INTO Transactions (Sender_ID, Receiver_ID, Transaction_Amount, Fee, Balance_After_Transaction, Transaction_DateTime, Transaction_Category_ID, Transaction_Reference, Status) VALUES
(1, 2, 6000.00, 90.00, 43910.00, '2026-03-03 17:26:49', 1, 'TX1234567890', 'Success'),
(2, 3, 15000.00, 225.00, 14775.00, '2026-03-04 10:15:30', 1, 'TX1234567891', 'Success'),
(3, 1, 25000.00, 375.00, 49625.00, '2026-03-04 14:22:15', 1, 'TX1234567892', 'Success'),
(4, 5, 8000.00, 120.00, 33880.00, '2026-03-05 09:45:00', 4, 'TX1234567893', 'Success'),
(5, 6, 12000.00, 180.00, 55820.00, '2026-03-05 16:30:22', 1, 'TX1234567894', 'Success'),
(1, NULL, 5000.00, 100.00, 38810.00, '2026-03-06 11:20:00', 5, 'TX1234567895', 'Success'),
(6, 4, 3000.00, 45.00, 21955.00, '2026-03-06 13:10:45', 2, 'TX1234567896', 'Success'),
(3, 2, 20000.00, 300.00, 29325.00, '2026-03-07 08:55:30', 1, 'TX1234567897', 'Failed'),
(7, 1, 10000.00, 150.00, 79850.00, '2026-03-07 15:40:18', 1, 'TX1234567898', 'Success');

-- Update the failure reason for failed transaction
UPDATE Transactions SET Failure_Reason = 'Insufficient balance in sender account' WHERE Transaction_ID = 8;

-- Insert System Logs (at least 5 records)
INSERT INTO System_Logs (Event_Type, Event_Description, User_ID, Transaction_ID, IP_Address, Severity) VALUES
('Transaction_Initiated', 'User 1 initiated transfer to User 2 for 6000 RWF', 1, 1, '192.168.1.100', 'Info'),
('Transaction_Completed', 'Transaction TX1234567890 successfully completed', 1, 1, '192.168.1.100', 'Info'),
('Login_Success', 'User successfully logged into MoMo account', 2, NULL, '192.168.1.105', 'Info'),
('Transaction_Failed', 'Transaction TX1234567897 failed due to insufficient balance', 3, 8, '192.168.1.120', 'Warning'),
('Account_Suspended', 'User account suspended due to suspicious activity', 7, NULL, '10.0.0.50', 'Critical'),
('Database_Backup', 'Daily database backup completed successfully', NULL, NULL, '10.0.0.1', 'Info'),
('API_Error', 'Mobile money API timeout during transaction processing', 5, 5, '192.168.1.150', 'Error');

-- Insert Transaction Category Mappings (Many-to-Many relationships)
INSERT INTO Transaction_Category_Mapping (Transaction_ID, Category_ID) VALUES
(1, 1),  -- Transaction 1 is Money Transfer
(2, 1),  -- Transaction 2 is Money Transfer
(3, 1),  -- Transaction 3 is Money Transfer
(4, 4),  -- Transaction 4 is Merchant Payment
(5, 1),  -- Transaction 5 is Money Transfer
(6, 5),  -- Transaction 6 is Cash Withdrawal
(7, 2),  -- Transaction 7 is Bill Payment
(8, 1),  -- Transaction 8 is Money Transfer (failed)
(9, 1),  -- Transaction 9 is Money Transfer
(1, 7),  -- Transaction 1 is ALSO Salary Payment (demonstrating M:N)
(4, 2);  -- Transaction 4 is ALSO Bill Payment (demonstrating M:N)

-- ============================================================================
-- SAMPLE CRUD OPERATIONS FOR TESTING
-- ============================================================================

-- CREATE: Insert a new user
-- (Already demonstrated above in INSERT statements)

-- READ: Select queries
SELECT 'All Active Users:' AS Query_Description;
SELECT User_ID, Full_Name, Phone_Number, Account_Balance, Account_Status 
FROM Users 
WHERE Account_Status = 'Active'
ORDER BY Account_Balance DESC;

SELECT 'Transactions for User 1 (Sylvie):' AS Query_Description;
SELECT 
    t.Transaction_ID,
    t.Transaction_Reference,
    sender.Full_Name AS Sender,
    receiver.Full_Name AS Receiver,
    t.Transaction_Amount,
    t.Fee,
    t.Status,
    t.Transaction_DateTime
FROM Transactions t
JOIN Users sender ON t.Sender_ID = sender.User_ID
LEFT JOIN Users receiver ON t.Receiver_ID = receiver.User_ID
WHERE t.Sender_ID = 1 OR t.Receiver_ID = 1
ORDER BY t.Transaction_DateTime DESC;

SELECT 'Transaction Summary by Category:' AS Query_Description;
SELECT 
    tc.Category_Name,
    COUNT(t.Transaction_ID) AS Total_Transactions,
    SUM(t.Transaction_Amount) AS Total_Volume,
    AVG(t.Transaction_Amount) AS Average_Transaction,
    SUM(t.Fee) AS Total_Fees_Collected
FROM Transactions t
JOIN Transaction_Categories tc ON t.Transaction_Category_ID = tc.Category_ID
WHERE t.Status = 'Success'
GROUP BY tc.Category_Name
ORDER BY Total_Volume DESC;

-- UPDATE: Modify user balance
SELECT 'Before UPDATE - User 1 Balance:' AS Query_Description;
SELECT User_ID, Full_Name, Account_Balance FROM Users WHERE User_ID = 1;

UPDATE Users 
SET Account_Balance = 55000.00,
    Updated_At = CURRENT_TIMESTAMP
WHERE User_ID = 1;

SELECT 'After UPDATE - User 1 Balance:' AS Query_Description;
SELECT User_ID, Full_Name, Account_Balance FROM Users WHERE User_ID = 1;

-- DELETE: Remove a system log entry
SELECT 'Before DELETE - Total System Logs:' AS Query_Description;
SELECT COUNT(*) AS Total_Logs FROM System_Logs;

DELETE FROM System_Logs WHERE Log_ID = 6; -- Delete the backup log

SELECT 'After DELETE - Total System Logs:' AS Query_Description;
SELECT COUNT(*) AS Total_Logs FROM System_Logs;

-- ============================================================================
-- ADVANCED QUERIES FOR ANALYSIS
-- ============================================================================

-- Find users with low balance (potential notification trigger)
SELECT 'Users with Balance Below 30,000 RWF:' AS Query_Description;
SELECT 
    User_ID,
    Full_Name,
    Phone_Number,
    Account_Balance,
    CASE 
        WHEN Account_Balance < 10000 THEN 'Critical'
        WHEN Account_Balance < 20000 THEN 'Low'
        ELSE 'Warning'
    END AS Balance_Status
FROM Users
WHERE Account_Balance < 30000 AND Account_Status = 'Active'
ORDER BY Account_Balance ASC;

-- Transaction velocity analysis (fraud detection)
SELECT 'High-Frequency Transaction Users (Potential Fraud):' AS Query_Description;
SELECT 
    u.User_ID,
    u.Full_Name,
    COUNT(t.Transaction_ID) AS Transaction_Count,
    SUM(t.Transaction_Amount) AS Total_Sent,
    MAX(t.Transaction_DateTime) AS Last_Transaction
FROM Users u
JOIN Transactions t ON u.User_ID = t.Sender_ID
WHERE t.Transaction_DateTime >= DATE_SUB(NOW(), INTERVAL 7 DAY)
GROUP BY u.User_ID, u.Full_Name
HAVING Transaction_Count > 3
ORDER BY Transaction_Count DESC;

-- Daily transaction volume
SELECT 'Daily Transaction Volume (Last 7 Days):' AS Query_Description;
SELECT 
    DATE(Transaction_DateTime) AS Transaction_Date,
    COUNT(*) AS Total_Transactions,
    SUM(Transaction_Amount) AS Total_Volume,
    SUM(Fee) AS Total_Fees,
    COUNT(CASE WHEN Status = 'Success' THEN 1 END) AS Successful,
    COUNT(CASE WHEN Status = 'Failed' THEN 1 END) AS Failed
FROM Transactions
WHERE Transaction_DateTime >= DATE_SUB(NOW(), INTERVAL 7 DAY)
GROUP BY DATE(Transaction_DateTime)
ORDER BY Transaction_Date DESC;

-- ============================================================================
-- DATABASE STATISTICS
-- ============================================================================

SELECT 'Database Statistics:' AS Query_Description;
SELECT 
    'Users' AS Table_Name,
    COUNT(*) AS Record_Count
FROM Users
UNION ALL
SELECT 
    'Transaction_Categories',
    COUNT(*)
FROM Transaction_Categories
UNION ALL
SELECT 
    'Transactions',
    COUNT(*)
FROM Transactions
UNION ALL
SELECT 
    'System_Logs',
    COUNT(*)
FROM System_Logs
UNION ALL
SELECT 
    'Transaction_Category_Mapping',
    COUNT(*)
FROM Transaction_Category_Mapping;

-- ============================================================================
-- END OF DATABASE SETUP SCRIPT
-- ============================================================================
-- To use this script:
-- 1. Run: mysql -u root -p < database_setup.sql
-- 2. Or execute in MySQL Workbench / phpMyAdmin
-- 3. Verify tables created: SHOW TABLES;
-- 4. Check data: SELECT * FROM Users;
-- ============================================================================
