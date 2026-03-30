-- NOTE: Removed CREATE DATABASE (not supported in Programiz)

-- ================= USERS =================
CREATE TABLE Users (
    User_ID INTEGER PRIMARY KEY AUTOINCREMENT,
    Full_Name TEXT NOT NULL,
    Phone_Number TEXT UNIQUE NOT NULL,
    Account_Balance REAL DEFAULT 0,
    Email TEXT,
    Date_Of_Birth DATE,
    Account_Status TEXT DEFAULT 'Active',
    Created_At DATETIME DEFAULT CURRENT_TIMESTAMP,
    Updated_At DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ================= CATEGORIES =================
CREATE TABLE Transaction_Categories (
    Category_ID INTEGER PRIMARY KEY AUTOINCREMENT,
    Category_Name TEXT UNIQUE NOT NULL,
    Description TEXT,
    Fee_Percentage REAL DEFAULT 0,
    Is_Active INTEGER DEFAULT 1,
    Created_At DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ================= TRANSACTIONS =================
CREATE TABLE Transactions (
    Transaction_ID INTEGER PRIMARY KEY AUTOINCREMENT,
    Sender_ID INTEGER,
    Receiver_ID INTEGER,
    Transaction_Amount REAL,
    Fee REAL,
    Net_Amount REAL,
    Balance_After_Transaction REAL,
    Transaction_DateTime DATETIME DEFAULT CURRENT_TIMESTAMP,
    Transaction_Category_ID INTEGER,
    Transaction_Reference TEXT UNIQUE,
    Status TEXT,
    Failure_Reason TEXT
);

-- ================= LOGS =================
CREATE TABLE System_Logs (
    Log_ID INTEGER PRIMARY KEY AUTOINCREMENT,
    Event_Type TEXT,
    Event_Description TEXT,
    User_ID INTEGER,
    Transaction_ID INTEGER,
    IP_Address TEXT,
    Severity TEXT,
    Created_At DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ================= MAPPING =================
CREATE TABLE Transaction_Category_Mapping (
    Mapping_ID INTEGER PRIMARY KEY AUTOINCREMENT,
    Transaction_ID INTEGER,
    Category_ID INTEGER,
    Applied_At DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ================= INSERTS =================

INSERT INTO Users VALUES
(1,'Sylvie UMUTONI RUTAGANIRA','+250788123456',50000,'sylvie@email.rw','1995-03-15','Active',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP),
(2,'Elvire AKAYEZU','+250795149666',30000,'elvire@email.rw','1992-07-22','Active',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP),
(3,'Jean Claude NIYONZIMA','+250788345678',75000,'jc@email.rw','1988-11-05','Active',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP),
(4,'Marie UWERA','+250788456789',42000,'marie@email.rw','1997-01-30','Active',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP),
(5,'Patrick HABIMANA','+250788567890',68000,'patrick@email.rw','1990-09-12','Active',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP),
(6,'Alice MUKESHIMANA','+250788678901',25000,'alice@email.rw','1999-04-18','Active',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP),
(7,'David MUGISHA','+250788789012',90000,'david@email.rw','1985-06-25','Suspended',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP);

INSERT INTO Transaction_Categories VALUES
(1,'Money Transfer','P2P',1.5,1,CURRENT_TIMESTAMP),
(2,'Bill Payment','Utility',0.5,1,CURRENT_TIMESTAMP),
(3,'Airtime Purchase','Airtime',0,1,CURRENT_TIMESTAMP),
(4,'Merchant Payment','Merchant',1,1,CURRENT_TIMESTAMP),
(5,'Cash Withdrawal','Withdraw',2,1,CURRENT_TIMESTAMP),
(6,'International Transfer','Cross-border',3.5,1,CURRENT_TIMESTAMP),
(7,'Salary Payment','Salary',0.75,1,CURRENT_TIMESTAMP);

INSERT INTO Transactions VALUES
(1,1,2,6000,90,5910,43910,'2026-03-03',1,'TX1234567890','Success',NULL),
(2,2,3,15000,225,14775,14775,'2026-03-04',1,'TX1234567891','Success',NULL),
(3,3,1,25000,375,24625,49625,'2026-03-04',1,'TX1234567892','Success',NULL),
(4,4,5,8000,120,7880,33880,'2026-03-05',4,'TX1234567893','Success',NULL),
(5,5,6,12000,180,11820,55820,'2026-03-05',1,'TX1234567894','Success',NULL),
(6,1,NULL,5000,100,4900,38810,'2026-03-06',5,'TX1234567895','Success',NULL),
(7,6,4,3000,45,2955,21955,'2026-03-06',2,'TX1234567896','Success',NULL),
(8,3,2,20000,300,19700,29325,'2026-03-07',1,'TX1234567897','Failed','Insufficient balance'),
(9,7,1,10000,150,9850,79850,'2026-03-07',1,'TX1234567898','Success',NULL);

INSERT INTO System_Logs VALUES
(1,'Transaction_Initiated','User 1 sent money',1,1,'192.168.1.100','Info',CURRENT_TIMESTAMP),
(2,'Transaction_Completed','Success',1,1,'192.168.1.100','Info',CURRENT_TIMESTAMP),
(3,'Login_Success','Login',2,NULL,'192.168.1.105','Info',CURRENT_TIMESTAMP),
(4,'Transaction_Failed','Failed',3,8,'192.168.1.120','Warning',CURRENT_TIMESTAMP),
(5,'Account_Suspended','Suspicious',7,NULL,'10.0.0.50','Critical',CURRENT_TIMESTAMP);

INSERT INTO Transaction_Category_Mapping VALUES
(1,1,1,CURRENT_TIMESTAMP),
(2,2,1,CURRENT_TIMESTAMP),
(3,3,1,CURRENT_TIMESTAMP),
(4,4,4,CURRENT_TIMESTAMP),
(5,5,1,CURRENT_TIMESTAMP);

-- ================= QUERIES =================

SELECT * FROM Users WHERE Account_Status='Active';

SELECT * FROM Transactions WHERE Sender_ID=1 OR Receiver_ID=1;

SELECT Transaction_Category_ID, COUNT(*), SUM(Transaction_Amount)
FROM Transactions GROUP BY Transaction_Category_ID;

SELECT Full_Name, Account_Balance
FROM Users WHERE Account_Balance < 30000;
