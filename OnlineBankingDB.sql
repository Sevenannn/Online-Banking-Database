--==================== LIS 543 Project: Database Implementation ====================--
-- Date: 3/5/2023

-- Create Database
CREATE DATABASE OnlineBankingDB_Team6;

USE OnlineBankingDB_Team6;

-- Create Tables
CREATE TABLE Client
	(
	ClientID int IDENTITY(10000000, 1) NOT NULL PRIMARY KEY,
	FirstName varchar(40) NOT NULL,
	MiddleName varchar(40),
	LastName varchar(40) NOT NULL,
	LoginName varchar(40) NOT NULL,
	EncryptedPassword varbinary(250),
	PhoneNumber varchar(20) NOT NULL,
	EmailAddress varchar(100) NOT NULL,
	[Address] varchar(200) NOT NULL,
	City varchar(30) NOT NULL,
	[State] varchar(30) NOT NULL,
	Zipcode varchar(10) NOT NULL,
	SSN varchar(11)
	);

CREATE TABLE Branch
	(
	BranchID int IDENTITY NOT NULL PRIMARY KEY,
	BranchName varchar(100) NOT NULL,
	PhoneNumber varchar(20) NOT NULL,
	EmailAddress varchar(100) NOT NULL,
	[Address] varchar(200) NOT NULL,
	City varchar(30) NOT NULL,
	[State] varchar(30) NOT NULL,
	Zipcode varchar(10) NOT NULL
	);

CREATE TABLE AccountType
	(
	AccountTypeID tinyint NOT NULL PRIMARY KEY,
	AccountTypeDescription varchar(200)
	);

CREATE TABLE Account
	(
	AccountID int IDENTITY(10000000, 1) NOT NULL PRIMARY KEY,
	ClientID int NOT NULL
	REFERENCES Client(ClientID),
	AccountTypeID tinyint NOT NULL
	REFERENCES AccountType(AccountTypeID),
	RoutingNumber varchar(9) NOT NULL,
	AccountBalance money NOT NULL,
	RegistrationBranch int NOT NULL
	REFERENCES Branch(BranchID),
	InterestRate decimal(6, 2) NOT NULL check (InterestRate >= 0),
	OverDraftLimit money NOT NULL check (OverDraftLimit >= 0),
	AccountWarning bit NOT NULL
	);

CREATE TABLE OverDraft
	(
	OverDraftID int IDENTITY NOT NULL PRIMARY KEY,
	ClientAccountID int NOT NULL
	REFERENCES Account(AccountID),
	OverDraftAmount money NOT NULL,
	ExceedOverDraftLimit bit NOT NULL -- 1: exceed; 0: not exceed
	);

CREATE TABLE TransactionType
	(
	TransactionTypeID tinyint NOT NULL PRIMARY KEY,
	TransactionTypeDescription varchar(200) NOT NULL,
	TransactionFee decimal(6,2) NOT NULL check(TransactionFee >= 0)
	);

CREATE TABLE TransactionStatus
	(
	TransactionStatusTypeID tinyint NOT NULL PRIMARY KEY,
	TransactionStatusDescription varchar(200) NOT NULL,
	);

CREATE TABLE [Transaction]
	(
	TransactionID int IDENTITY(1000000000, 1) NOT NULL PRIMARY KEY,
	ClientAccountID int NOT NULL
	REFERENCES Account(AccountID),
	TransactionTypeID tinyint NOT NULL
	REFERENCES TransactionType(TransactionTypeID),
	TransactionAmount money NOT NULL,
	TransactionCurrency varchar(15) NOT NULL,
	TransactionDate date NOT NULL,
	TransactionTime time NOT NULL,
	TransactionStatus tinyint NOT NULL
	REFERENCES TransactionStatus(TransactionStatusTypeID),
	TransactionNotes varchar(200),
	constraint Transaction_AltPK unique(TransactionID, TransactionTypeID)
	);

CREATE TABLE TransferIn
	(
	TransactionID int PRIMARY KEY NOT NULL,
	TransactionTypeID tinyint NOT NULL CHECK (TransactionTypeID = 1), -- TransferIn
	SenderAccountID varchar(20) NOT NULL,
	FOREIGN KEY (TransactionID, TransactionTypeID)
	REFERENCES [Transaction](TransactionID, TransactionTypeID)
	);

CREATE TABLE TransferOut
	(
	TransactionID int PRIMARY KEY NOT NULL,
	TransactionTypeID tinyint NOT NULL CHECK (TransactionTypeID = 2), -- TransferOut
	ReceiverAccountID varchar(20) NOT NULL,
	Overdraft bit NOT NULL, -- 1: true; 0: false
	OverdraftID int
	REFERENCES Overdraft(OverdraftID),
	FOREIGN KEY (TransactionID, TransactionTypeID)
	REFERENCES [Transaction](TransactionID, TransactionTypeID)
	);

CREATE TABLE Withdraw
	(
	TransactionID int PRIMARY KEY NOT NULL,
	TransactionTypeID tinyint NOT NULL CHECK (TransactionTypeID = 3), -- Withdraw
	Overdraft bit NOT NULL,
	OverdraftID int
	REFERENCES Overdraft(OverdraftID),
	FOREIGN KEY (TransactionID, TransactionTypeID)
	REFERENCES [Transaction](TransactionID, TransactionTypeID)
	);

CREATE TABLE Saving
	(
	TransactionID int PRIMARY KEY NOT NULL,
	TransactionTypeID tinyint NOT NULL CHECK (TransactionTypeID = 4), -- Saving
	InterestRate decimal(6, 2) NOT NULL check(InterestRate >= 0),
	FOREIGN KEY (TransactionID, TransactionTypeID)
	REFERENCES [Transaction](TransactionID, TransactionTypeID)
	);

CREATE TABLE Paying
	(
	TransactionID int PRIMARY KEY NOT NULL,
	TransactionTypeID tinyint NOT NULL CHECK (TransactionTypeID = 5), -- Paying
	MerchantAccountID varchar(20) NOT NULL,
	MerchantDescription varchar(200),
	MerchantType varchar(100),
	Overdraft bit NOT NULL,
	OverdraftID int
	REFERENCES Overdraft(OverdraftID),
	FOREIGN KEY (TransactionID, TransactionTypeID)
	REFERENCES [Transaction](TransactionID, TransactionTypeID)
	);

--========== Column Encryption ==========--

-- Create DMK
CREATE MASTER KEY
ENCRYPTION BY PASSWORD = 'Test_P@sswOrd';

-- Create certificate to protect symmetric key
CREATE CERTIFICATE TestCertificate
WITH SUBJECT = 'Team6 Test Certificate',
EXPIRY_DATE = '2026-10-31';

-- Create symmetric key to encrypt data
CREATE SYMMETRIC KEY TestSymmetricKey
WITH ALGORITHM = AES_128
ENCRYPTION BY CERTIFICATE TestCertificate;

-- Open symmetric key
OPEN SYMMETRIC KEY TestSymmetricKey
DECRYPTION BY CERTIFICATE TestCertificate;

--========== Insert Data ==========--

INSERT Client
	VALUES
	('Emily', 'G', 'Taylor', 'etaylor21', EncryptByKey(Key_GUID(N'TestSymmetricKey'), convert(varbinary, 'taylor21!E')), '555-123-4567', 'emilytaylor21@example.com', '123 Main St.', 'Los Angeles', 'CA', '90001', '123-45-6789'),
	('Oliver', 'A', 'Wilson', 'oliverwilson', EncryptByKey(Key_GUID(N'TestSymmetricKey'), convert(varbinary, 'Hd67#k')), '123-456-7890', 'oliver.wilson@example.com', '321 Main St', 'Los Angeles', 'CA', '90001', '321-45-6789'),
	('Emily', 'B', 'Smith', 'emilysmith', EncryptByKey(Key_GUID(N'TestSymmetricKey'), convert(varbinary, 'KtR23^g')), '234-567-8901', 'emily.smith@example.com', '456 Oak Ave', 'New York', 'NY', '10001', '234-56-7890'),
	('John', 'M', 'Davis', 'jdavis34', EncryptByKey(Key_GUID(N'TestSymmetricKey'), convert(varbinary, 'davis34@J')), '555-987-6543', 'johndavis34@example.com', '456 Elm St.', 'New York', 'NY', '10001', '987-65-4321'),
	('Sophia', 'D', 'Johnson', 'sophiajohnson', EncryptByKey(Key_GUID(N'TestSymmetricKey'), convert(varbinary, 'Uy23$%')), '456-789-0123', 'sophia.johnson@example.com', '321 Pine St', 'Houston', 'TX', '77001', '456-78-9012'),
	('Sarah', 'E', 'Lee', 'slee99', EncryptByKey(Key_GUID(N'TestSymmetricKey'), convert(varbinary, 'lee99#S')), '456-555-1212', 'sarahlee99@example.com', '789 Oak St.', 'Houston', 'TX', '77001', '555-99-1212'),
	('Aiden', 'E', 'Martinez', 'aidenmartinez', EncryptByKey(Key_GUID(N'TestSymmetricKey'), convert(varbinary, 'HyT45@')), '567-890-1234', 'aiden.martinez@example.com', '654 Elm St', 'Phoenix', 'AZ', '85001', '567-89-0123'),
	('Michael', 'C', 'Johnson', 'mjohnson28', EncryptByKey(Key_GUID(N'TestSymmetricKey'), convert(varbinary, 'johnson28$M')), '567-555-5555', 'michaeljohnson28@example.com', '101 Maple Ave.', 'Phoenix', 'AZ', '85001', '555-28-1010'),
	('Laura', 'M', 'Garcia', 'lgarcia42', EncryptByKey(Key_GUID(N'TestSymmetricKey'), convert(varbinary, 'garcia42*L')), '555-674-4567', 'lauragarcia42@example.com', '543 Elm St.', 'Philadelphia', 'PA', '19101', '123-42-5678'),
	('Isabella', 'F', 'Brown', 'isabellabrown', EncryptByKey(Key_GUID(N'TestSymmetricKey'), convert(varbinary, 'GhT67*')), '678-901-2345', 'isabella.brown@example.com', '987 Cedar St', 'Philadelphia', 'PA', '19101', '678-90-1234')

INSERT Branch
	VALUES ('CA_Los_Angeles_Branch1', '111-234-567', 'CA_Los_Angeles_Branch1@bank.com', '123 Main St.', 'Los Angeles', 'CA', '90001'),
	('NY_New_York_Branch1', '222-234-567', 'NY_New_York_Branch1@bank.com', '456 Elm St.', 'New York', 'NY', '10001'),
	('TX_Houston_Branch1', '333-234-567', 'TX_Houston_Branch1@bank.com', '789 Oak St.', 'Houston', 'TX', '77001'),
	('AZ_Phoenix_Branch1', '444-234-567', 'AZ_Phoenix_Branch1@bank.com', '101 Maple Ave.', 'Phoenix', 'AZ', '85001'),
	('PA_Philadelphia_Branch1', '555-234-567', 'PA_Philadelphia_Branch1@bank.com', '543 Elm St.', 'Philadelphia', 'PA', '19101')

INSERT AccountType
	VALUES (1, 'Saving'), (2, 'Checking')

INSERT Account
	VALUES
	(10000000, 1, '021000021', 50000.00, 1, 0.00, 100, 0),
	(10000000, 2, '021000021', 100000.00, 1, 0.00, 100, 0),
	(10000001, 1, '021000021', 2500.75, 1, 0.00, 100, 0),
	(10000001, 2, '021000021', 10000.50, 1, 0.00, 100, 0),
	(10000002, 1, '021000021', 10000.00, 2, 0.00, 100, 0),
	(10000002, 2, '021000021', 20000.00, 2, 0.00, 100, 0),
	(10000003, 1, '021000021', 4000.00, 2, 0.00, 100, 0),
	(10000003, 2, '021000021', 45000.00, 2, 0.00, 100, 0),
	(10000004, 1, '021000021', 5000.00, 3, 0.00, 100, 0),
	(10000004, 2, '021000021', 3000.00, 3, 0.00, 100, 0),
	(10000005, 1, '021000021', 1750.25, 3, 0.00, 100, 0),
	(10000005, 2, '021000021', 3500.50, 3, 0.00, 100, 0),
	(10000006, 1, '021000021', 8000.00, 4, 0.00, 100, 0),
	(10000006, 2, '021000021', 16000.00, 4, 0.00, 100, 0),
	(10000007, 1, '021000021', 320.00, 4, 0.00, 100, 0),
	(10000007, 2, '021000021', 640.00, 4, 0.00, 100, 0),
	(10000008, 1, '021000021', 7500.00, 5, 0.00, 100, 0),
	(10000008, 2, '021000021', 15000.00, 5, 0.00, 100, 0),
	(10000009, 1, '021000021', 600.50, 5, 0.00, 100, 0),
	(10000009, 2, '021000021', 1200.25, 5, 0.00, 100, 0)

/*
 * TransactionStatus: 
 * 1. completed
 * 2. failed
 * 
 * TransactionType:
 * 1. transferin
 * 2. transferout
 * 3. withdraw
 * 4. saving
 * 5. paying
 */
	
INSERT INTO TransactionType (TransactionTypeID, TransactionTypeDescription, TransactionFee)
	VALUES
	(1, 'Transfer In', 0),
	(2, 'Transfer Out', 0),
	(3, 'Withdraw', 0),
	(4, 'Saving', 0),
	(5, 'Paying', 0)
	
INSERT INTO TransactionStatus (TransactionStatusTypeID, TransactionStatusDescription)
	VALUES
	(1, 'Completed'),
	(2, 'Failed')

-- Insert Transaction Data
INSERT INTO [Transaction] (ClientAccountID, TransactionTypeID, TransactionAmount, TransactionCurrency, TransactionDate, TransactionTime, TransactionStatus, TransactionNotes)
VALUES
	(10000000, 2, 1933.01, 'USD', '2022-01-01', '19:23:29', 1, 'Rent'),
	(10000002, 5, 13402.33, 'USD', '2022-01-05', '19:33:15', 2, 'Flight tickets'),
	(10000000, 5, 50, 'USD', '2022-01-05', '20:24:19', 1, 'Starbucks'),
	(10000004, 5, 10800.05, 'USD', '2022-01-10', '20:30:04', 2, 'Flight tickets'),
	(10000014, 5, 156.84, 'USD', '2022-01-11', '01:27:31', 1, 'QFC'),
	(10000012, 5, 27.91, 'USD', '2022-01-13', '19:43:34', 1, 'DingTaiFeng'),
	(10000010, 1, 182.82, 'USD', '2022-01-16', '03:50:41', 1, 'Zelle'),
	(10000017, 5, 9598.52, 'USD', '2022-01-16', '20:53:14', 1, 'Flight tickets'),
	(10000016, 1, 101.53, 'USD', '2022-01-18', '10:35:19', 1, 'Zelle'),
	(10000007, 4, 19.85, 'USD', '2022-01-19', '21:16:51', 1, 'Deposit'),
	(10000000, 5, 10321.24, 'USD', '2022-01-24', '10:39:47', 1, 'UW tuition'),
	(10000003, 3, 7389.79, 'USD', '2022-01-27', '13:44:22', 1, 'Withdraw'),
	(10000000, 5, 25, 'USD', '2022-01-27', '16:29:18', 1, 'Starbucks'),
	(10000000, 2, 1927.38, 'USD', '2022-02-01', '12:31:20', 1, 'Rent'),
	(10000000, 5, 195.31, 'USD', '2022-02-02', '13:41:14', 1, 'Shopping'),
	(10000000, 5, 188.41, 'USD', '2022-02-03', '21:32:21', 1, 'Flight Tickets'),
	(10000004, 2, 101.49, 'USD', '2022-02-06', '02:38:35', 1, 'Zelle'),
	(10000000, 5, 50, 'USD', '2022-02-11', '14:30:27', 1, 'Starbucks'),
	(10000009, 5, 172.42, 'USD', '2022-02-21', '23:32:34', 1, 'Bar'),
	(10000016, 5, 1106.11, 'USD', '2022-02-22', '22:54:31', 1, 'AirBnB'),
	(10000018, 1, 186.61, 'USD', '2022-02-23', '08:17:56', 1, 'Zelle'),
	(10000000, 5, 25, 'USD', '2022-03-01', '09:33:08', 1, 'Starbucks'),
	(10000000, 2, 1913.12, 'USD', '2022-03-02', '03:01:02', 1, 'Rent'),
	(10000005, 4, 182.77, 'USD', '2022-03-06', '12:40:14', 1, 'Deposit'),
	(10000018, 5, 53.80, 'USD', '2022-03-07', '08:03:22', 1, 'QFC'),
	(10000009, 4, 154.86, 'USD', '2022-03-11', '16:20:36', 1, 'Deposit'),
	(10000000, 5, 50, 'USD', '2022-03-15', '15:00:30', 1, 'Starbucks'),
	(10000014, 5, 28.64, 'USD', '2022-03-16', '17:05:13', 1, 'Jellycat'),
	(10000004, 1, 167.30, 'USD', '2022-03-24', '21:28:27', 1, 'Zelle'),
	(10000005, 2, 2141.30, 'USD', '2022-03-29', '08:21:35', 1, 'March rent'),
	(10000009, 2, 1106.80, 'USD', '2022-03-29', '13:15:20', 1, 'Exchange'),
	(10000009, 5, 16.91, 'USD', '2022-03-31', '13:12:19', 1, 'Trader Joes'),
	(10000000, 2, 1849.23, 'USD', '2022-04-03', '19:21:33', 1, 'Rent'),
	(10000004, 5, 125.06, 'USD', '2022-04-09', '04:03:37', 1, 'ChengDuMemeory'),
	(10000016, 5, 8798.09, 'USD', '2022-04-11', '16:22:58', 2, 'Vacation Package'),
	(10000012, 1, 1396.59, 'USD', '2022-04-16', '00:44:16', 1, 'Salary'),
	(10000005, 3, 55.35, 'USD', '2022-04-17', '04:12:33', 1, 'Withdraw'),
	(10000000, 2, 113.32, 'USD', '2022-04-17', '18:15:51', 1, 'Zelle'),
	(10000012, 5, 109.43, 'USD', '2022-04-18', '05:38:34', 1, 'CheeseCakeFactory'),
	(10000000, 5, 95.26, 'USD', '2022-04-19', '12:58:21', 1, 'Shopping'),
	(10000008, 5, 6031.57, 'USD', '2022-04-24', '16:45:10', 2, 'Shopping'),
	(10000010, 2, 160.37, 'USD', '2022-04-25', '15:56:28', 1, 'Zelle'),
	(10000000, 2, 1839.29, 'USD', '2022-05-01', '08:01:03', 1, 'Rent'),
	(10000000, 5, 50.00, 'USD', '2022-05-01', '14:00:00', 1, 'Starbucks'),
	(10000018, 1, 100.61, 'USD', '2022-05-08', '05:07:47', 1, 'Zelle'),
	(10000007, 3, 1843.08, 'USD', '2022-05-09', '07:03:56', 1, 'Withdraw'),
	(10000006, 1, 59.70, 'USD', '2022-05-11', '02:52:11', 1, 'Zelle'),
	(10000014, 5, 57.74, 'USD', '2022-05-19', '23:21:22', 1, 'Starbucks'),
	(10000018, 2, 22.95, 'USD', '2022-05-24', '00:01:33', 1, 'Zelle'),
	(10000009, 2, 187.44, 'USD', '2022-05-25', '03:43:46', 1, 'Zelle'),
	(10000005, 4, 98.41, 'USD', '2022-05-31', '16:43:21', 1, 'Deposit'),
	(10000000, 2, 1802.64, 'USD', '2022-06-03', '09:19:09', 1, 'Rent'),
	(10000006, 5, 186.99, 'USD', '2022-06-13', '22:12:11', 1, 'Sephora'),
	(10000000, 2, 118.48, 'USD', '2022-06-13', '23:35:41', 1, 'Zelle'),
	(10000012, 5, 184.49, 'USD', '2022-06-14', '14:02:18', 1, 'Trader Joes'),
	(10000018, 3, 188.71, 'USD', '2022-06-17', '05:58:10', 1, 'Withdraw'),
	(10000018, 1, 111.41, 'USD', '2022-06-24', '20:46:32', 1, 'Zelle'),
	(10000001, 3, 75.56, 'USD', '2022-06-28', '19:14:45', 1, 'Withdraw'),
	(10000001, 3, 1967.85, 'USD', '2022-06-29', '01:39:37', 1, 'Withdraw'),
	(10000002, 5, 26.24, 'USD', '2022-06-29', '11:29:40', 1, 'Grocery'),
	(10000000, 2, 1897.02, 'USD', '2022-07-01', '13:42:03', 1, 'Rent'),
	(10000000, 5, 335.87, 'USD', '2022-07-01', '23:47:29', 1, 'Flight tickets'),
	(10000000, 5, 1028.67, 'USD', '2022-07-01', '23:58:22', 1, 'Disney'),
	(10000006, 5, 96.73, 'USD', '2022-07-05', '16:51:42', 1, 'Jellycat'),
	(10000000, 5, 100, 'USD', '2022-07-06', '15:21:48', 1, 'Starbucks'),
	(10000005, 4, 179.95, 'USD', '2022-07-13', '14:47:31', 1, 'Deposit'),
	(10000006, 5, 55.38, 'USD', '2022-07-13', '17:13:35', 1, 'Hong Kong Bristo'),
	(10000006, 4, 39.21, 'USD', '2022-07-17', '15:57:17', 1, 'Deposit'),
	(10000006, 2, 94.49, 'USD', '2022-07-19', '09:32:27', 1, 'Zelle'),
	(10000009, 2, 151.01, 'USD', '2022-07-22', '16:16:51', 1, 'Zelle'),
	(10000006, 4, 62.34, 'USD', '2022-07-22', '17:40:57', 1, 'Deposit'),
	(10000006, 2, 163.23, 'USD', '2022-07-29', '21:58:54', 1, 'Zelle'),
	(10000000, 2, 1901.22, 'USD', '2022-08-01', '12:37:38', 1, 'Rent'),
	(10000001, 3, 189.78, 'USD', '2022-08-01', '13:40:18', 1, 'Withdraw'),
	(10000006, 2, 718.72, 'USD', '2022-08-03', '16:21:16', 1, 'Zelle'),
	(10000006, 4, 1638.86, 'USD', '2022-08-05', '02:57:43', 1, 'Deposit'),
	(10000019, 5, 1354.44, 'USD', '2022-08-07', '14:53:34', 2, 'Hotel Booking'),
	(10000011, 3, 184.62, 'USD', '2022-08-09', '02:33:40', 1, 'Withdraw'),
	(10000006, 1, 143.63, 'USD', '2022-08-10', '05:32:21', 1, 'Zelle'),
	(10000000, 5, 50, 'USD', '2022-08-11', '15:25:33', 1, 'Starbucks'),
	(10000014, 2, 12.31, 'USD', '2022-08-16', '21:44:44', 1, 'Zelle'),
	(10000006, 5, 125.29, 'USD', '2022-08-17', '08:08:46', 1, 'Lunch'),
	(10000003, 4, 47.38, 'USD', '2022-08-25', '00:35:55', 1, 'Deposit'),
	(10000000, 5, 4488.52, 'USD', '2022-08-27', '13:49:02', 1, 'Flight tickets'),
	(10000010, 5, 14533.38, 'USD', '2022-08-29', '23:11:34', 2, 'UW tuition'),
	(10000006, 1, 99.34, 'USD', '2022-09-02', '05:32:36', 1, 'Zelle'),
	(10000003, 4, 28.12, 'USD', '2022-09-02', '07:45:20', 1, 'Deposit'),
	(10000000, 2, 1882.24, 'USD', '2022-09-04', '02:14:22', 1, 'Rent'),
	(10000000, 1, 161.70, 'USD', '2022-09-16', '07:02:11', 1, 'Zelle'),
	(10000002, 5, 29.83, 'USD', '2022-09-17', '07:54:44', 1, 'Book'),
	(10000008, 2, 157.48, 'USD', '2022-09-22', '19:27:04', 1, 'Zelle'),
	(10000006, 2, 1125.66, 'USD', '2022-09-25', '21:52:15', 1, 'Exchange'),
	(10000000, 5, 50, 'USD', '2022-09-29', '17:19:08', 1, 'Starbucks'),
	(10000000, 2, 1872.38, 'USD', '2022-10-02', '02:22:22', 1, 'Rent'),
	(10000003, 4, 32.87, 'USD', '2022-10-05', '23:38:49', 1, 'Deposit'),
	(10000006, 5, 196.09, 'USD', '2022-10-05', '18:30:45', 1, 'Utility Fee'),
	(10000010, 1, 378.14, 'USD', '2022-10-07', '17:00:30', 1, 'Salary'),
	(10000016, 2, 135.60, 'USD', '2022-10-10', '17:12:18', 1, 'Zelle'),
	(10000000, 5, 174.10, 'USD', '2022-10-11', '20:48:18', 1, 'Sneakers'),
	(10000005, 4, 24.45, 'USD', '2022-10-12', '20:42:31', 1, 'Deposit'),
	(10000006, 1, 180.16, 'USD', '2022-10-16', '08:00:41', 1, 'Zelle'),
	(10000010, 5, 124.39, 'USD', '2022-10-22', '16:19:57', 1, 'Tickets'),
	(10000000, 2, 1880.36, 'USD', '2022-11-01', '16:20:39', 1, 'Rent'),
	(10000000, 1, 10000, 'USD', '2022-11-01', '19:00:39', 1, 'Zelle'),
	(10000000, 5, 80.27, 'USD', '2022-11-01', '20:20:19', 1, 'Grocery'),
	(10000000, 5, 15, 'USD', '2022-11-03', '19:21:47', 1, 'Zelle'),
	(10000000, 2, 20, 'USD', '2022-11-05', '20:01:58', 1, 'Zelle'),
	(10000000, 5, 80.45, 'USD', '2022-11-06', '13:20:01', 1, 'Gas'),
	(10000000, 5, 10.38, 'USD', '2022-11-06', '17:43:01', 1, 'Chipotle'),
	(10000000, 5, 58.01, 'USD', '2022-11-06', '19:33:58', 1, 'Target'),
	(10000006, 5, 62.81, 'USD', '2022-11-08', '06:09:37', 1, 'Grocery'),
	(10000006, 3, 63.46, 'USD', '2022-11-09', '14:49:20', 1, 'Withdraw'),
	(10000018, 1, 73.78, 'USD', '2022-11-10', '10:03:46', 1, 'Zelle'),
	(10000000, 5, 15, 'USD', '2022-11-10', '20:02:07', 1, 'Snowy Village'),
	(10000000, 1, 30.58, 'USD', '2022-11-11', '12:46:27', 1, 'Zelle'),
	(10000014, 1, 14273.96, 'USD', '2022-11-12', '10:38:11', 1, 'Lottery'),
	(10000000, 5, 100, 'USD', '2022-11-13', '18:22:09', 1, 'Starbucks'),
	(10000000, 5, 21, 'USD', '2022-11-14', '09:33:01', 1, 'Ba Bar'),
	(10000000, 5, 30, 'USD', '2022-11-14', '10:20:30', 1, 'GoodtoGo'),
	(10000000, 5, 12.33, 'USD', '2022-11-14', '18:42:01', 1, 'Chipotle'),
	(10000000, 5, 18, 'USD', '2022-11-15', '10:22:01', 1, 'Parking'),
	(10000000, 5, 97.42, 'USD', '2022-11-16', '09:49:01', 1, 'Grocery'),
	(10000000, 5, 48.99, 'USD', '2022-11-16', '15:39:10', 1, 'UBookstore'),
	(10000006, 5, 62.99, 'USD', '2022-11-17', '23:21:38', 1, 'Trader Joes'),
	(10000000, 5, 22.49, 'USD', '2022-11-18', '18:38:20', 1, 'Ba Bar'),
	(10000005, 2, 42.14, 'USD', '2022-11-21', '23:53:14', 1, 'Zelle'),
	(10000000, 5, 268.98, 'USD', '2022-11-23', '16:28:41', 1, 'Aritzia'),
	(10000000, 5, 89.99, 'USD', '2022-11-25', '11:48:36', 1, 'Madewell'),
	(10000000, 5, 150.67, 'USD', '2022-11-25', '12:20:53', 1, 'Sephora'),
	(10000000, 5, 999.99, 'USD', '2022-11-25', '12:36:09', 1, 'Bestbuy'),
	(10000000, 5, 68.28, 'USD', '2022-11-25', '13:29:34', 1, 'Restaurant'),
	(10000000, 5, 17.49, 'USD', '2022-11-25', '16:49:27', 1, 'Donuts'),
	(10000000, 5, 65.89, 'USD', '2022-11-25', '17:57:20', 1, 'Barnes and Nobles'),
	(10000000, 5, 180.99, 'USD', '2022-11-28', '15:28:02', 1, 'Banana Republic'),
	(10000000, 5, 37.99, 'USD', '2022-11-28', '16:41:20', 1, 'Sephora'),
	(10000000, 4, 990.2, 'USD', '2022-11-30', '12:36:16', 1, 'Salary'),
	(10000000, 2, 1830.27, 'USD', '2022-12-02', '19:36:36', 1, 'Rent'),
	(10000012, 5, 183.98, 'USD', '2022-12-02', '20:41:54', 1, 'BBQ'),
	(10000006, 5, 5233.33, 'USD', '2022-12-03', '08:25:42', 2, 'Hotel booking'),
	(10000006, 5, 196.95, 'USD', '2022-12-04', '01:01:54', 1, 'Sneakers'),
	(10000016, 1, 150.15, 'USD', '2022-12-14', '17:42:03', 1, 'Zelle'),
	(10000006, 5, 165.61, 'USD', '2022-12-14', '18:03:52', 1, 'Christams Shopping'),
	(10000002, 5, 182.29, 'USD', '2022-12-17', '10:59:35', 1, 'Christams Shopping'),
	(10000018, 1, 166.05, 'USD', '2022-12-17', '12:52:50', 1, 'Zelle'),
	(10000005, 4, 89.57, 'USD', '2022-12-17', '21:09:48', 1, 'Deposit'),
	(10000000, 5, 100, 'USD', '2022-12-21', '11:22:33', 1, 'Starbucks'),
	(10000014, 5, 64.39, 'USD', '2022-12-22', '15:25:09', 1, 'Space Needle Tickets'),
	(10000005, 4, 56.47, 'USD', '2022-12-24', '04:34:43', 1, 'Deposit'),
	(10000008, 5, 169.86, 'USD', '2022-12-25', '18:29:40', 1, 'Christmas Dinner'),
	(10000016, 5, 165.33, 'USD', '2022-12-30', '02:56:25', 1, 'XiAnTastes')

INSERT INTO OverDraft -- (OverDraftID, ClientAccountID, OverdraftAmount, ExceedOverdraftLimit)
	VALUES
	(10000000, 1046.90, 1),
	(10000001, 82.11, 0)

INSERT INTO TransferIn -- (TransactionID, TransactionTypeID, SenderAccountID)
	VALUES
(1000000006, 1, '34589217'),
(1000000008, 1, '78952103'),
(1000000020, 1, '62198547'),
(1000000028, 1, '30897452'),
(1000000035, 1, '40512389'),
(1000000044, 1, '82746315'),
(1000000046, 1, '93650218'),
(1000000056, 1, '21783094'),
(1000000078, 1, '50328947'),
(1000000085, 1, '19260835'),
(1000000088, 1, '82746315'),
(1000000096, 1, '21783094'),
(1000000100, 1, '40512389'),
(1000000103, 1, '40512389'),
(1000000112, 1, '82746315'),
(1000000114, 1, '12049229'),
(1000000115, 1, '82746315'),
(1000000140, 1, '40512389'),
(1000000143, 1, '27840288')

INSERT INTO TransferOut -- (TransactionID, TransactionTypeID, ReceiverAccountID, Overdraft, OverdraftID)
	VALUES
    (1000000000, 2, '21888888', 0, null),
    (1000000013, 2, '68732471', 0, null),
    (1000000016, 2, '91975856', 0, null),
    (1000000022, 2, '72567354', 0, null),
    (1000000029, 2, '44219299', 0, null),
    (1000000030, 2, '93298270', 0, null),
    (1000000032, 2, '21884768', 0, null),
    (1000000037, 2, '50094649', 0, null),
    (1000000041, 2, '72994712', 0, null),
    (1000000042, 2, '17639452', 0, null),
    (1000000048, 2, '30883944', 0, null),
    (1000000049, 2, '98886510', 0, null),
    (1000000051, 2, '56654223', 0, null),
    (1000000053, 2, '10938155', 0, null),
    (1000000060, 2, '49187137', 0, null),
    (1000000068, 2, '86475472', 0, null),
    (1000000069, 2, '55154538', 0, null),
    (1000000071, 2, '14344971', 0, null),
    (1000000072, 2, '63285185', 0, null),
    (1000000074, 2, '22875301', 0, null),
    (1000000080, 2, '23749756', 0, null),
    (1000000087, 2, '93761842', 0, null),
    (1000000090, 2, '52819473', 0, null),
    (1000000091, 2, '84934873', 0, null),
    (1000000093, 2, '35722270', 0, null),
    (1000000097, 2, '74089045', 0, null),
    (1000000102, 2, '22689185', 0, null),
    (1000000106, 2, '89446471', 0, null),
    (1000000125, 2, '71572814', 0, null),
    (1000000136, 2, '71576666', 0, null)

INSERT INTO Withdraw -- (TransactionID, TransactionTypeID, Overdraft, OverdraftID)
	VALUES
	(1000000011, 3, 0, null),
	(1000000036, 3, 0, null),
	(1000000045, 3, 0, null),
	(1000000055, 3, 0, null),
	(1000000057, 3, 0, null),
	(1000000058, 3, 0, null),
	(1000000073, 3, 0, null),
	(1000000077, 3, 0, null),
	(1000000111, 3, 0, null)
	
INSERT INTO Saving -- (TransactionID, TransactionTypeID, InterestRateValue)
	VALUES
	(1000000009, 4, 1.5),
	(1000000023, 4, 1.5),
	(1000000025, 4, 1.05),
	(1000000050, 4, 2.25),
	(1000000065, 4, 2.25),
	(1000000067, 4, 2.75),
	(1000000070, 4, 2.75),
	(1000000075, 4, 1.05),
	(1000000082, 4, 2.2),
	(1000000086, 4, 3.5),
	(1000000094, 4, 3.5),
	(1000000099, 4, 2.2),
	(1000000135, 4, 1.05),
	(1000000144, 4, 2.25),
	(1000000147, 4, 0.95)

INSERT INTO Paying -- (TransactionID, TransactionTypeID, MerchantAccountID, MerchantDescription, MerchantType, Overdraft, OverdraftID)
	VALUES
(1000000001, 5, '27835411', 'Delta', 'Airline', 0, null),
(1000000002, 5, '34656712', 'Starbucks', 'Restaurant', 0, null),
(1000000003, 5, '86333349', 'Delta', 'Airline', 0, null),
(1000000004, 5, '40848245', 'QFC', 'Shopping', 0, null),
(1000000005, 5, '89301080', 'DingTaiFeng', 'Restaurant', 0, null),
(1000000007, 5, '72881348', 'Flight tickets', 'Airline', 0, null),
(1000000010, 5, '67209021', 'UW tuition', 'Education', 0, null),
(1000000012, 5, '64496588', 'Starbucks', 'Restaurant', 0, null),
(1000000014, 5, '25308137', 'Shopping', 'Shopping', 0, null),
(1000000015, 5, '14006424', 'Flight Tickets', 'Airline', 0, null),
(1000000017, 5, '31975163', 'Starbucks', 'Restaurant', 0, null),
(1000000018, 5, '98620490', 'Bar', 'Restaurant', 0, null),
(1000000019, 5, '18832779', 'AirBnB', 'Travel', 0, null),
(1000000021, 5, '73774647', 'Starbucks', 'Restaurant', 0, null),
(1000000024, 5, '89431755', 'QFC', 'Shopping', 0, null),
(1000000026, 5, '46799344', 'Starbucks', 'Restaurant', 0, null),
(1000000027, 5, '80848900', 'Jellycat', 'Shopping', 0, null),
(1000000031, 5, '70410254', 'Trader Joes', 'Shopping', 0, null),
(1000000033, 5, '30527571', 'ChengDuMemeory', 'Restaurant', 0, null),
(1000000034, 5, '73627373', 'Vacation Package', 'Travel', 0, null),
(1000000038, 5, '49142008', 'CheeseCakeFactory', 'Restaurant', 0, null),
(1000000039, 5, '42946991', 'Shopping', 'Shopping', 0, null),
(1000000040, 5, '54128655', 'Shopping', 'Shopping', 0, null),
(1000000043, 5, '50714227', 'Starbucks', 'Restaurant', 0, null),
(1000000047, 5, '79703372', 'Starbucks', 'Restaurant', 0, null),
(1000000052, 5, '41346228', 'Sephora', 'Shopping', 0, null),
(1000000054, 5, '33623768', 'Trader Joes', 'Shopping', 0, null),
(1000000059, 5, '65599862', 'Grocery', 'Shopping', 0, null),
(1000000061, 5, '24626413', 'Flight tickets', 'Airline', 0, null),
(1000000062, 5, '52706809', 'Disney', 'Travel', 0, null),
(1000000063, 5, '64871100', 'Jellycat', 'Shopping', 0, null),
(1000000064, 5, '57255478', 'Starbucks', 'Restaurant', 0, null),
(1000000066, 5, '68418133', 'Hong Kong Bristo', 'Restaurant', 0, null),
(1000000076, 5, '15821410', 'Hotel Booking', 'Travel', 0, null),
(1000000079, 5, '56912467', 'Starbucks', 'Restaurant', 0, null),
(1000000081, 5, '22558016', 'Lunch', 'Restaurant', 0, null),
(1000000083, 5, '78745413', 'Flight tickets', 'Airline', 0, null),
(1000000084, 5, '55128634', 'UW tuition', 'Education', 0, null),
(1000000089, 5, '23625680', 'Book', 'Education', 0, null),
(1000000092, 5, '28815987', 'Starbucks', 'Restaurant', 0, null),
(1000000095, 5, '78595812', 'Utility Fee', 'Travel', 0, null),
(1000000098, 5, '78041320', 'Sneakers', 'Shopping', 0, null),
(1000000101, 5, '99251626', 'Tickets', 'Travel', 0, null),
(1000000104, 5, '66607708', 'Grocery', 'Shopping', 0, null),
(1000000105, 5, '32430891', 'Zelle', 'Restaurant', 0, null),
(1000000107, 5, '92400895', 'Gas', 'Travel', 0, null),
(1000000108, 5, '23867884', 'Chipotle', 'Restaurant', 0, null),
(1000000109, 5, '41055661', 'Target', 'Shopping', 0, null),
(1000000110, 5, '53239449', 'Grocery', 'Shopping', 0, null),
(1000000113, 5, '96264668', 'Snowy Village', 'Restaurant', 0, null),
(1000000116, 5, '13032540', 'Starbucks', 'Restaurant', 0, null),
(1000000117, 5, '11576454', 'Ba Bar', 'Restaurant', 0, null),
(1000000118, 5, '28724471', 'GoodtoGo', 'Travel', 0, null),
(1000000119, 5, '83254816', 'Chipotle', 'Restaurant', 0, null),
(1000000120, 5, '95869792', 'Parking', 'Travel', 0, null),
(1000000121, 5, '25305167', 'Grocery', 'Shopping', 0, null),
(1000000122, 5, '90025747', 'UBookstore', 'Education', 0, null),
(1000000123, 5, '11626105', 'Trader Joes', 'Shopping', 0, null),
(1000000124, 5, '36697391', 'Ba Bar', 'Restaurant', 0, null),
(1000000126, 5, '42440435', 'Aritzia', 'Shopping', 0, null),
(1000000127, 5, '37184029', 'Madewell', 'Shopping', 0, null),
(1000000128, 5, '10017425', 'Sephora', 'Shopping', 0, null),
(1000000129, 5, '92009652', 'Bestbuy', 'Shopping', 0, null),
(1000000130, 5, '19458599', 'Restaurant', 'Restaurant', 0, null),
(1000000131, 5, '27368403', 'Donuts', 'Restaurant', 0, null),
(1000000132, 5, '68580900', 'Book', 'Education', 0, null),
(1000000133, 5, '56742221', 'Banana Republic', 'Shopping', 0, null),
(1000000134, 5, '58069370', 'Sephora', 'Shopping', 0, null),
(1000000137, 5, '59879132', 'BBQ', 'Restaurant', 0, null),
(1000000138, 5, '45742602', 'Housing', 'Travel', 0, null),
(1000000139, 5, '69086033', 'Sneakers', 'Shopping', 0, null),
(1000000141, 5, '45092906', 'Christams Shopping', 'Shopping', 0, null),
(1000000142, 5, '49113429', 'Christams Shopping', 'Shopping', 0, null),
(1000000145, 5, '32861175', 'Starbucks', 'Restaurant', 0, null),
(1000000146, 5, '50623132', 'Space Needle Center', 'Travel', 0, null),
(1000000148, 5, '35472905', 'Christmas Dinner', 'Restaurant', 0, null),
(1000000149, 5, '75722403', 'XiAnTastes', 'Restaurant', 0, null)

---========== Create Views ==========--

-- View 1: Registration Branches & Their Performance
CREATE VIEW vwBranchesPerformances
	AS
	SELECT BranchID,
		BranchName,
		[Address] AS BranchAddress,
		City AS BranchCity,
		[State] AS BranchState,
		Zipcode AS BranchZipcode,
		SUM(TotalTransactionAmount) AS TotalTransactionAmount
	FROM Branch b
	INNER JOIN Account a
	on b.BranchID = a.RegistrationBranch
	INNER JOIN
	(SELECT a.AccountID, SUM(t.TransactionAmount) AS TotalTransactionAmount
	FROM Account a
	INNER JOIN [Transaction] t
		on a.AccountID = t.ClientAccountID
	GROUP BY a.AccountID) tta
	on a.AccountID = tta.AccountID
	GROUP BY BranchID, BranchName, [Address], City, [State], Zipcode

SELECT * FROM vwBranchesPerformances

-- View 2: How much each client involve in different transaction activities
CREATE VIEW vwClientActivity
	WITH ENCRYPTION
	AS 
	SELECT c.ClientID,
		c.FirstName,
		c.MiddleName,
		c.LastName,
		ta.TransactionTypeDescription AS TransactionType,
		ta.TransactionAmount
	FROM Client c
	INNER JOIN
	(SELECT ClientID, tt.TransactionTypeDescription, SUM(TransactionAmount) AS TransactionAmount
	FROM Account a
	INNER JOIN [Transaction] t
		on a.AccountID = t.ClientAccountID
	INNER JOIN TransactionType tt
		on t.TransactionTypeID = tt.TransactionTypeID
	GROUP BY ClientID, tt.TransactionTypeDescription) ta on c.ClientID = ta.ClientID

SELECT *
FROM vwClientActivity
ORDER BY ClientID, TransactionType

-- View 3: Overdraft transactions and their corresponding clients & accounts
CREATE VIEW vwAccountOverdraft
	WITH ENCRYPTION
	AS
	SELECT c.ClientID,
		c.FirstName,
		c.MiddleName,
		c.LastName,
		a.AccountID,
		o.OverDraftAmount,
		o.ExceedOverDraftLimit
	FROM Account a
	INNER JOIN OverDraft o
		on a.AccountID = o.ClientAccountID
	INNER JOIN Client c
		on a.ClientID = c.ClientID

SELECT * FROM vwAccountOverdraft

-- View 4: Clients & Their Accounts
CREATE VIEW vwClientAccounts
	WITH ENCRYPTION
	AS 
	SELECT c.ClientID,
		c.FirstName,
		c.MiddleName,
		c.LastName,
		a.AccountID,
		atype.AccountTypeDescription as AccountType,
		a.AccountBalance
	FROM Client c
	INNER JOIN Account a
		on c.ClientID = a.ClientID
	INNER JOIN AccountType atype
		on a.AccountTypeID = atype.AccountTypeID

SELECT * FROM vwClientAccounts

--========== Triggers ==========--

/*
 * Trigger: Update Account, Overdraft With Transaction Insertion
 * Functionality: 
 * 		1. For each transaction, update the account balance.
 * 		2. After each withdraw, paying, and transferOut transaction, if the overdraft 
 * 			balance exceeds account overdraft limit, set the AccountWarning bit on.
 * 		3. If the warning account client pays back overdraft amount (account balance 
 * 			becomes positive), set the AccountWarning bit off.
 * 		4. After each withdraw, paying, and transferOut transaction, if there is an overdraft,
 * 			insert the transaction into the Overdraft table. If the overdraft amount exceed
 * 			overdraft limit, set the ExceedOverDraftLimit bit on upon insertion.
 * Testing: 
 * 		1. Testing AccountBalance accuracy for five main transaction types. 
 * 		2. Testing Overdraft table insertion after overdraft transactions.
 * 		3. Testing AccountWarning bit and ExceedOverDraftLimit bit after overdraft amount 
 * 			exceeds overdraft limit.
 * 		4. Testing AccountWarning bit after account warning clients pay back.
 * 		5. Testing data accuracy with integers and decimals.
 */

-- DROP TRIGGER TransactionTrigger
CREATE TRIGGER TransactionTrigger ON
[Transaction]
AFTER INSERT
AS BEGIN
	DECLARE @tid int -- TransactionID
	DECLARE @ttype tinyint -- TransactionType
	DECLARE @accountid int -- ClientAccountID 
	DECLARE @tamount money -- TransactionAmount
	DECLARE @originBalance money -- AccountBalance
	DECLARE @overdraftLimit money -- OverdraftLimit
	DECLARE @accountWarning bit -- AccountWarning
	DECLARE @overdraftAmount money -- OverDraftAmount
	SELECT @tid = i.TransactionID FROM inserted i
	SELECT @ttype = i.TransactionTypeID FROM inserted i
	SELECT @accountid = i.ClientAccountID FROM inserted i
	SELECT @tamount = i.TransactionAmount FROM inserted i
	SELECT @originBalance = AccountBalance FROM Account WHERE AccountID = @accountid
	SELECT @overdraftLimit = OverdraftLimit FROM Account WHERE AccountID = @accountid
	SELECT @accountWarning = AccountWarning FROM Account WHERE AccountID = @accountid
	SELECT @overdraftAmount = -1 * (@originBalance - @tamount)
	IF @ttype = 1 or @ttype = 4 -- "1: TransferIn; 4: Saving"
	BEGIN 
		-- Update account balance
		UPDATE Account
		SET Account.AccountBalance = @originBalance + @tamount
		WHERE AccountID = @accountid
		-- If warning account client pays back
		IF @accountWarning = 1 AND @originBalance + @tamount >= 0 
		BEGIN 
			UPDATE Account
			SET Account.AccountWarning = 0
			WHERE AccountID = @accountid
		END
	END
	ELSE  -- "2: TransferOut; 3: Withdraw; 5: Paying“
	BEGIN
		-- Update account balance
		UPDATE Account
		SET Account.AccountBalance = @originBalance - @tamount
		WHERE AccountID = @accountid
		-- If there is overdraft, insert into Overdraft table
		IF @originBalance - @tamount < 0  
		BEGIN
			-- If overdraft amount exceed the overdraft limit, 
			-- set on AccountWarning bit and ExceedOverDraftLimit bit
			IF @overdraftAmount > @overdraftLimit
			BEGIN
				INSERT Overdraft
				VALUES (@accountid, @overdraftAmount, 1)

				UPDATE Account
				SET Account.AccountWarning = 1
				WHERE AccountID = @accountid
			END
			ELSE
			-- If overdraft amount does not exceed the overdraft limit, 
			-- insert into Overdraft table with ExceedOverDraftLimit bit off.
			BEGIN
				INSERT Overdraft
				VALUES (@accountid, @overdraftAmount, 0)
			END		
		END
	END
END

---- Trigger 1 Test ---- 

SELECT * FROM Account a -- AccountID 10000000, Original Balance 50000.0000

-- Test TransferIn
INSERT INTO [Transaction] (ClientAccountID, TransactionTypeID, TransactionAmount, TransactionCurrency, TransactionDate, TransactionTime, TransactionStatus, TransactionNotes)
VALUES (10000000, 1, 1933.01, 'USD', '2022-01-01', '19:23:29', 1, 'Rent')
-- Passed, Account Balance increases to 51933.0000

-- Test TransferOut
INSERT INTO [Transaction] (ClientAccountID, TransactionTypeID, TransactionAmount, TransactionCurrency, TransactionDate, TransactionTime, TransactionStatus, TransactionNotes)
VALUES (10000000, 2, 1933.01, 'USD', '2022-01-01', '19:23:29', 1, 'Rent')
-- Passed, Account Balance decreases to 50000.0000.

-- Test Withdraw
INSERT INTO [Transaction] (ClientAccountID, TransactionTypeID, TransactionAmount, TransactionCurrency, TransactionDate, TransactionTime, TransactionStatus, TransactionNotes)
VALUES (10000000, 3, 1123, 'USD', '2022-01-01', '19:23:29', 1, 'Rent')
-- Passed, Account Balance decreases to 48877.0000.

-- Test Saving
INSERT INTO [Transaction] (ClientAccountID, TransactionTypeID, TransactionAmount, TransactionCurrency, TransactionDate, TransactionTime, TransactionStatus, TransactionNotes)
VALUES (10000000, 4, 1123, 'USD', '2022-01-01', '19:23:29', 1, 'Rent')
-- Passed, Account Balance increases to 50000.0000.

-- Test Paying
INSERT INTO [Transaction] (ClientAccountID, TransactionTypeID, TransactionAmount, TransactionCurrency, TransactionDate, TransactionTime, TransactionStatus, TransactionNotes)
VALUES (10000000, 5, 1123, 'USD', '2022-01-01', '19:23:29', 1, 'Rent')
-- Passed, Account Balance decreases to 48877.0000.

-- Test Overdraft that exceeds overdraft limit
SELECT * FROM Account a -- AccountID: 10000002, AccountBalance: 2501, OverDraftLimit: 100, Warningbit: off

INSERT INTO [Transaction] (ClientAccountID, TransactionTypeID, TransactionAmount, TransactionCurrency, TransactionDate, TransactionTime, TransactionStatus, TransactionNotes)
VALUES (10000002, 2, 11230.7, 'USD', '2022-01-01', '19:23:29', 1, 'Rent')
SELECT * FROM OverDraft 
-- Passed, Account Balance decreases to -8729.7000, AccountWarning bit of Account 10000002 is set on.
-- Transaction inserted into Overdraft table with correct OverdraftAmount (8729.70000), ExceedOverdraftLimit bit is set on.

-- Test Overdraft that does not exceed overdraft limit
SELECT * FROM Account a -- AccountID: 10000015, AccountBalance: 640.0000, OverDraftLimit: 100, Warningbit: off

INSERT INTO [Transaction] (ClientAccountID, TransactionTypeID, TransactionAmount, TransactionCurrency, TransactionDate, TransactionTime, TransactionStatus, TransactionNotes)
VALUES (10000015, 5, 641, 'USD', '2022-01-01', '19:23:29', 1, 'Rent')
SELECT * FROM OverDraft 
-- Passed, Account Balance decreases to -1, AccountWarning bit of Account 10000002 is set off.
-- Transaction inserted into Overdraft table with correct OverdraftAmount (1), ExceedOverdraftLimit bit is set off.

-- Test Account warning client pays back
INSERT INTO [Transaction] (ClientAccountID, TransactionTypeID, TransactionAmount, TransactionCurrency, TransactionDate, TransactionTime, TransactionStatus, TransactionNotes)
VALUES (10000002, 1, 11230.7, 'USD', '2022-01-01', '19:23:29', 1, 'Rent') 
-- Passed, AccountWarning bit of Account 10000002 is set off.


