-- 1. Create Database
CREATE DATABASE GadaElectronics;
GO

USE GadaElectronics;
GO

-- 2. Drop Existing Tables If They Exist
IF OBJECT_ID('Orders') IS NOT NULL DROP TABLE Orders;
IF OBJECT_ID('Products') IS NOT NULL DROP TABLE Products;
IF OBJECT_ID('Customers') IS NOT NULL DROP TABLE Customers;

-- 3. Create Tables
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100),
    Email NVARCHAR(100),
    City NVARCHAR(50)
);

CREATE TABLE Products (
    ProductID INT PRIMARY KEY IDENTITY(1,1),
    ProductName NVARCHAR(100),
    Price DECIMAL(10,2)
);

CREATE TABLE Orders (
    OrderID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT,
    ProductID INT,
    Quantity INT,
    OrderDate DATE,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

-- 4. Insert 100 Realistic Indian-Style Customers
DECLARE @i INT = 1;

DECLARE @firstNames NVARCHAR(MAX) = 'Raj,Priya,Amit,Neha,Ravi,Suman,Vijay,Anjali,Manish,Pooja,Ankit,Divya,Aditya,Preeti,Arjun,Simran,Kunal,Swati,Nikhil,Sneha,Deepak,Isha,Sachin,Megha,Nitin,Reena,Saurabh,Kiran,Harshita,Aayush,Tanya';
DECLARE @lastNames NVARCHAR(MAX) = 'Verma,Sharma,Patel,Mehta,Rao,Kumar,Gupta,Reddy,Yadav,Joshi,Desai,Chopra,Malhotra,Nair,Kapoor,Bhatt,Trivedi,Saxena,Kaul,Das';

DECLARE @firstNameList TABLE (Name NVARCHAR(50));
DECLARE @lastNameList TABLE (Name NVARCHAR(50));

INSERT INTO @firstNameList SELECT value FROM STRING_SPLIT(@firstNames, ',');
INSERT INTO @lastNameList SELECT value FROM STRING_SPLIT(@lastNames, ',');

WHILE @i <= 100
BEGIN
    DECLARE @firstName NVARCHAR(50) = (SELECT TOP 1 Name FROM @firstNameList ORDER BY NEWID());
    DECLARE @lastName NVARCHAR(50) = (SELECT TOP 1 Name FROM @lastNameList ORDER BY NEWID());
    DECLARE @fullName NVARCHAR(100) = CONCAT(@firstName, ' ', @lastName);
    DECLARE @email NVARCHAR(100) = LOWER(CONCAT(@firstName, '.', @lastName, @i, '@gadaelectronics.in'));
    DECLARE @city NVARCHAR(50) = CHOOSE((@i % 6) + 1, 'Mumbai', 'Delhi', 'Ahmedabad', 'Kolkata', 'Bangalore', 'Chennai');

    INSERT INTO Customers (Name, Email, City)
    VALUES (@fullName, @email, @city);

    SET @i += 1;
END

-- 5. Insert 20 Realistic Products
INSERT INTO Products (ProductName, Price)
VALUES
('Samsung LED TV 32"', 17999),
('LG Refrigerator 260L', 22999),
('Sony Home Theater 5.1', 14999),
('Philips Mixer Grinder', 3499),
('HP Inkjet Printer', 5999),
('Voltas Split AC 1.5T', 31999),
('Dell Inspiron Laptop', 49999),
('Mi Smart Band 7', 3999),
('Realme Bluetooth Speaker', 1999),
('Panasonic Washing Machine', 18999),
('Syska Smart Bulb', 799),
('Bajaj Electric Kettle', 1199),
('Havells Ceiling Fan', 2499),
('boAt Rockerz Headphones', 1499),
('LG Microwave Oven', 8499),
('OnePlus Nord Smartphone', 27999),
('Canon DSLR Camera', 38999),
('Samsung SSD 1TB', 7999),
('Lenovo Tablet M10', 14999),
('TP-Link WiFi Router', 2499);

-- 6. Generate Realistic Orders

-- Clear Orders
DELETE FROM Orders;

-- Customers 1–10: Frequent Buyers (30–50 orders)
SET @i = 1;
WHILE @i <= 10
BEGIN
    DECLARE @j INT = 1;
    WHILE @j <= (30 + FLOOR(RAND() * 21))
    BEGIN
        INSERT INTO Orders (CustomerID, ProductID, Quantity, OrderDate)
        VALUES (
            @i,
            FLOOR(RAND() * 20) + 1,
            FLOOR(RAND() * 3) + 1,
            DATEADD(DAY, -FLOOR(RAND() * 365), GETDATE())
        );
        SET @j += 1;
    END
    SET @i += 1;
END

-- Customers 11–30: Moderate Buyers (10–20 orders)
SET @i = 11;
WHILE @i <= 30
BEGIN
    SET @j = 1;
    WHILE @j <= (10 + FLOOR(RAND() * 11))
    BEGIN
        INSERT INTO Orders (CustomerID, ProductID, Quantity, OrderDate)
        VALUES (
            @i,
            FLOOR(RAND() * 20) + 1,
            FLOOR(RAND() * 3) + 1,
            DATEADD(DAY, -FLOOR(RAND() * 365), GETDATE())
        );
        SET @j += 1;
    END
    SET @i += 1;
END

-- Customers 31–100: Occasional Buyers (1–5 orders)
SET @i = 31;
WHILE @i <= 100
BEGIN
    SET @j = 1;
    WHILE @j <= (1 + FLOOR(RAND() * 5))
    BEGIN
        INSERT INTO Orders (CustomerID, ProductID, Quantity, OrderDate)
        VALUES (
            @i,
            FLOOR(RAND() * 20) + 1,
            FLOOR(RAND() * 3) + 1,
            DATEADD(DAY, -FLOOR(RAND() * 365), GETDATE())
        );
        SET @j += 1;
    END
    SET @i += 1;
END
