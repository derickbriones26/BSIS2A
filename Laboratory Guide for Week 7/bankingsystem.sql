-- ==========================================================
-- IT 105 – Information Management I
-- Week 7 Laboratory: Transactions, Security & Large Datasets
-- ==========================================================

-- Drop the database if it exists (clean start)
DROP DATABASE IF EXISTS BankingSystem;
CREATE DATABASE BankingSystem;
USE BankingSystem;

-- ==========================================================
-- PART 2 – Create Normalized Tables
-- ==========================================================

-- Customers table
CREATE TABLE Customers (
    CustomerID INT AUTO_INCREMENT PRIMARY KEY,
    FullName VARCHAR(100),
    Email VARCHAR(100) UNIQUE,
    PhoneNumber VARCHAR(20),
    Address TEXT
);

-- Accounts table
CREATE TABLE Accounts (
    AccountID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID INT,
    AccountType ENUM('Savings','Checking','Business'),
    Balance DECIMAL(12,2),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
    ON DELETE CASCADE
);

-- Transactions table
CREATE TABLE Transactions (
    TransactionID INT AUTO_INCREMENT PRIMARY KEY,
    AccountID INT,
    TransactionType ENUM('Deposit','Withdrawal','Transfer'),
    Amount DECIMAL(12,2),
    TransactionDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (AccountID) REFERENCES Accounts(AccountID)
);

-- Loans table
CREATE TABLE Loans (
    LoanID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID INT,
    LoanAmount DECIMAL(12,2),
    InterestRate DECIMAL(5,2),
    LoanTerm INT,
    Status ENUM('Active','Paid','Defaulted'),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

-- Payments table
CREATE TABLE Payments (
    PaymentID INT AUTO_INCREMENT PRIMARY KEY,
    LoanID INT,
    AmountPaid DECIMAL(12,2),
    PaymentDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (LoanID) REFERENCES Loans(LoanID)
);

-- ==========================================================
-- PART 3 – Generate 100,000 Records
-- ==========================================================

-- Helper table with numbers 1..100000
CREATE TABLE seq_100k (n INT PRIMARY KEY);

INSERT INTO seq_100k
SELECT a.N + b.N*10 + c.N*100 + d.N*1000 + e.N*10000 + 1
FROM
    (SELECT 0 N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) a,
    (SELECT 0 N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) b,
    (SELECT 0 N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) c,
    (SELECT 0 N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) d,
    (SELECT 0 N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) e
WHERE (a.N + b.N*10 + c.N*100 + d.N*1000 + e.N*10000) < 100000;

-- Insert 100,000 customers
INSERT INTO Customers (FullName, Email, PhoneNumber, Address)
SELECT
    CONCAT('Customer_', n),
    CONCAT('customer', n, '@bank.com'),
    CONCAT('+639', FLOOR(RAND()*1000000000)),
    CONCAT('Street_', FLOOR(RAND()*10000), ', City_', FLOOR(RAND()*100))
FROM seq_100k;

-- Generate accounts (one per customer)
INSERT INTO Accounts (CustomerID, AccountType, Balance)
SELECT
    CustomerID,
    IF(RAND()>0.5, 'Savings', 'Checking'),
    ROUND(RAND()*100000, 2)
FROM Customers;

-- Generate transactions (one per account)
INSERT INTO Transactions (AccountID, TransactionType, Amount)
SELECT
    AccountID,
    IF(RAND()>0.5, 'Deposit', 'Withdrawal'),
    ROUND(RAND()*5000, 2)
FROM Accounts;

-- Generate loans (one per customer)
INSERT INTO Loans (CustomerID, LoanAmount, InterestRate, LoanTerm, Status)
SELECT
    CustomerID,
    ROUND(RAND()*100000, 2),
    ROUND(RAND()*10, 2),
    FLOOR(RAND()*60) + 12,
    IF(RAND()>0.5, 'Active', 'Paid')
FROM Customers;

-- Generate loan payments (one per loan)
INSERT INTO Payments (LoanID, AmountPaid)
SELECT
    LoanID,
    ROUND(RAND()*5000, 2)
FROM Loans;

-- ==========================================================
-- PART 4 – Transaction Example (Bank Transfer)
-- ==========================================================

START TRANSACTION;

UPDATE Accounts SET Balance = Balance - 1000 WHERE AccountID = 1;
UPDATE Accounts SET Balance = Balance + 1000 WHERE AccountID = 2;

INSERT INTO Transactions (AccountID, TransactionType, Amount) VALUES
(1, 'Transfer', 1000),
(2, 'Transfer', 1000);

COMMIT;

-- ==========================================================
-- PART 5 – User Roles and Access Control
-- ==========================================================

-- Create bank clerk user (drop if exists to avoid error)
DROP USER IF EXISTS 'bank_clerk'@'localhost';
CREATE USER 'bank_clerk'@'localhost' IDENTIFIED BY 'securepassword';
GRANT SELECT, UPDATE ON BankingSystem.Accounts TO 'bank_clerk'@'localhost';

-- Create read‑only auditor
DROP USER IF EXISTS 'auditor'@'localhost';
CREATE USER 'auditor'@'localhost' IDENTIFIED BY 'readonlypass';
GRANT SELECT ON BankingSystem.* TO 'auditor'@'localhost';

-- ==========================================================
-- PART 6 – SQL Injection Awareness (demonstration only)
-- ==========================================================

-- Vulnerable query (returns all accounts if user input is "' OR 1=1 -- ")
-- SELECT * FROM Accounts WHERE AccountID = '' OR 1=1;

-- Mitigation using prepared statement
PREPARE stmt FROM 'SELECT * FROM Accounts WHERE AccountID = ?';
SET @id = 5;
EXECUTE stmt USING @id;
DEALLOCATE PREPARE stmt;

-- ==========================================================
-- PART 7 – Bulk Transactions with Savepoint
-- ==========================================================

START TRANSACTION;

UPDATE Accounts SET Balance = Balance - 100 WHERE AccountID BETWEEN 1 AND 2000;
UPDATE Accounts SET Balance = Balance + 100 WHERE AccountID BETWEEN 2001 AND 4000;

SAVEPOINT transfer_batch;

-- Verify a few rows
SELECT * FROM Accounts WHERE AccountID BETWEEN 1 AND 5;

-- Roll back to the savepoint (undoes the second update and any later changes)
ROLLBACK TO SAVEPOINT transfer_batch;

-- Commit the first update (balance -100 for accounts 1..2000)
COMMIT;

-- ==========================================================
-- PART 8 – Transaction Isolation Level
-- ==========================================================

SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE;

START TRANSACTION;

UPDATE Accounts SET Balance = Balance - 500 WHERE AccountID = 3;
UPDATE Accounts SET Balance = Balance + 500 WHERE AccountID = 4;

COMMIT;

-- Check current isolation level (use @@tx_isolation for MariaDB)
SELECT @@tx_isolation AS isolation_level;

-- ==========================================================
-- End of Laboratory Script
-- ==========================================================
