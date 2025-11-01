-- ---------------------------------------------------------------------
-- 🏪  SWASTIK VARIETY STORE – SALES & STOCK MANAGEMENT SYSTEM
-- ---------------------------------------------------------------------
-- This script creates the main database with tables, relationships,
-- triggers, views, stored procedures, functions, and normalization demo.
-- ---------------------------------------------------------------------

DROP DATABASE IF EXISTS sales_stock_management;
CREATE DATABASE sales_stock_management;
USE sales_stock_management;

-- ---------------------------------------------------------------------
-- 1️⃣ TABLE CREATION
-- ---------------------------------------------------------------------

-- Supplier master
CREATE TABLE Supplier(
 supplier_id VARCHAR(10) PRIMARY KEY,
 supplier_name VARCHAR(100) NOT NULL,
 contact_name VARCHAR(100),
 phone VARCHAR(20),
 email VARCHAR(100) UNIQUE,
 address VARCHAR(200),
 city VARCHAR(100),
 country VARCHAR(100)
);

-- Customer master
CREATE TABLE Customer(
 customer_id VARCHAR(10) PRIMARY KEY,
 customer_name VARCHAR(100) NOT NULL,
 email VARCHAR(100) UNIQUE,
 phone VARCHAR(20),
 address VARCHAR(200),
 city VARCHAR(100),
 country VARCHAR(100)
);

-- Product catalog
CREATE TABLE Product(
 product_id VARCHAR(10) PRIMARY KEY,
 product_name VARCHAR(100) NOT NULL,
 category VARCHAR(50),
 unit_price DECIMAL(10,2) NOT NULL,
 stock_quantity INT NOT NULL,
 reorder_level INT,
 created_at DATE,
 updated_at DATE,
 supplier_id VARCHAR(10),
 FOREIGN KEY(supplier_id) REFERENCES Supplier(supplier_id)
);

-- Discount master
CREATE TABLE Discounts(
 discount_id VARCHAR(10) PRIMARY KEY,
 discount_name VARCHAR(100) NOT NULL,
 discount_type VARCHAR(50),
 discount_value DECIMAL(10,2),
 start_date DATE,
 end_date DATE,
 active BOOLEAN
);

-- Sales header table
CREATE TABLE Sales(
 sale_id VARCHAR(10) PRIMARY KEY,
 sale_date DATE NOT NULL,
 total_amount DECIMAL(12,2) NOT NULL,
 payment_method VARCHAR(50),
 customer_id VARCHAR(10),
 FOREIGN KEY(customer_id) REFERENCES Customer(customer_id)
);

-- Sale details (line items)
CREATE TABLE SaleDetails(
 sale_detail_id VARCHAR(10) PRIMARY KEY,
 sale_id VARCHAR(10),
 product_id VARCHAR(10),
 discount_id VARCHAR(10),
 quantity INT NOT NULL,
 unit_price DECIMAL(10,2) NOT NULL,
 discount_applied DECIMAL(10,2),
 total_price DECIMAL(12,2),
 FOREIGN KEY(sale_id) REFERENCES Sales(sale_id),
 FOREIGN KEY(product_id) REFERENCES Product(product_id),
 FOREIGN KEY(discount_id) REFERENCES Discounts(discount_id)
);

-- Invoice record
CREATE TABLE Invoices(
 invoice_id VARCHAR(10) PRIMARY KEY,
 invoice_date DATE NOT NULL,
 total_amount DECIMAL(12,2) NOT NULL,
 pdf_path VARCHAR(200),
 qr_code VARCHAR(200),
 sale_id VARCHAR(10),
 FOREIGN KEY(sale_id) REFERENCES Sales(sale_id)
);

USE sales_stock_management;
ALTER TABLE Invoices MODIFY COLUMN invoice_id VARCHAR(20) NOT NULL;

-- Users (Admin / Manager)
CREATE TABLE Users(
 user_id VARCHAR(10) PRIMARY KEY,
 username VARCHAR(50) UNIQUE NOT NULL,
 password_hash VARCHAR(255) NOT NULL,
 role VARCHAR(50),
 email VARCHAR(100),
 phone VARCHAR(20)
);

-- Activity log (trigger output)
CREATE TABLE ActivityLog(
 log_id VARCHAR(40) PRIMARY KEY,
 action VARCHAR(100) NOT NULL,
 entity VARCHAR(50),
 record_id VARCHAR(10),
 timestamp DATETIME NOT NULL,
 user_id VARCHAR(10),
 FOREIGN KEY(user_id) REFERENCES Users(user_id)
);

-- Stock update log (trigger output)
CREATE TABLE StockLogs(
 log_id VARCHAR(40) PRIMARY KEY,
 stock_quantity INT NOT NULL,
 log_date DATE NOT NULL,
 remarks VARCHAR(200),
 product_id VARCHAR(10),
 FOREIGN KEY(product_id) REFERENCES Product(product_id)
);

-- ---------------------------------------------------------------------
-- 2️⃣ INSERT SAMPLE DATA
-- ---------------------------------------------------------------------

INSERT INTO Supplier VALUES
('SUP1','Swastik Variety Store','Rajesh Sharma','+91-9876543210','swastikvariety@gmail.com','Main Bazaar Road','Angul','India'),
('SUP2','Agro Wholesale','Meena Iyer','+91-9988776655','agro.wholesale@gmail.com','Industrial Area','Angul','India'),
('SUP3','Healthy Harvest','Suresh Patel','+91-9123456780','healthyharvest@gmail.com','College Square','Angul','India');

INSERT INTO Customer VALUES
('CUST1','Amit Kumar','amit.kumar@example.com','+91-9011111111','Bus Stand Road','Angul','India'),
('CUST2','Priya Singh','priya.singh@example.com','+91-9022222222','Nalco Nagar','Angul','India'),
('CUST3','Ravi Verma','ravi.verma@example.com','+91-9033333333','Kishore Nagar','Angul','India'),
('CUST4','Neha Gupta','neha.gupta@example.com','+91-9044444444','Similipada','Angul','India'),
('CUST5','Arjun Yadav','arjun.yadav@example.com','+91-9055555555','Handidhua','Angul','India');

INSERT INTO Users VALUES
('U1','Sanskar','hash_sanskar123','Admin','sanskar@gmail.com','+91-9202020202'),
('U2','Aayush','hash_aayush123','Manager','aayush@gmail.com','+91-9303030303');

INSERT INTO Product VALUES
('P1','Basmati Rice 25kg','Grains',1800.00,100,20,'2024-01-01','2024-08-01','SUP1'),
('P2','Wheat Flour 10kg','Grains',450.00,120,30,'2024-01-05','2024-08-01','SUP2'),
('P3','Sugar 5kg','Essentials',250.00,200,50,'2024-01-10','2024-08-01','SUP1'),
('P4','Toor Dal 5kg','Pulses',600.00,80,20,'2024-01-12','2024-08-01','SUP2'),
('P5','Moong Dal 5kg','Pulses',550.00,70,15,'2024-01-15','2024-08-01','SUP3');

INSERT INTO Discounts VALUES
('D1','Festival Offer','Percentage',10.00,'2024-08-01','2024-08-31',TRUE),
('D2','Bulk Purchase','Fixed',200.00,'2024-01-01','2024-12-31',TRUE);

INSERT INTO Sales VALUES
('S1','2024-08-05',2500.00,'Cash','CUST1'),
('S2','2024-08-06',5000.00,'UPI','CUST2');

INSERT INTO SaleDetails VALUES
('SD1','S1','P1','D1',1,1800.00,180.00,1620.00),
('SD2','S1','P3',NULL,2,250.00,0.00,500.00),
('SD3','S2','P4','D2',2,600.00,200.00,1000.00),
('SD4','S2','P5',NULL,3,550.00,0.00,1650.00);

INSERT INTO Invoices VALUES
('INV1','2024-08-05',2120.00,'/invoices/inv1.pdf','QR001','S1'),
('INV2','2024-08-06',4600.00,'/invoices/inv2.pdf','QR002','S2');

-- Seed data: 2025 sales (10 per month Jan–Oct) and matching SaleDetails
USE sales_stock_management;

-- Helper note: sale_id fits VARCHAR(10). Pattern: S25MMNN (MM=month, NN=sequence)

-- ======================== JANUARY 2025 ========================
INSERT INTO Sales VALUES
('S250101','2025-01-02',1800.00,'Cash','CUST1'),
('S250102','2025-01-05',900.00,'UPI','CUST2'),
('S250103','2025-01-08',500.00,'Card','CUST3'),
('S250104','2025-01-11',1200.00,'Cash','CUST4'),
('S250105','2025-01-14',1650.00,'UPI','CUST5'),
('S250106','2025-01-17',1800.00,'Card','CUST1'),
('S250107','2025-01-20',900.00,'Cash','CUST2'),
('S250108','2025-01-23',500.00,'UPI','CUST3'),
('S250109','2025-01-26',1200.00,'Card','CUST4'),
('S250110','2025-01-28',1650.00,'Cash','CUST5');

INSERT INTO SaleDetails VALUES
('SD250101','S250101','P1',NULL,1,1800.00,0.00,1800.00),
('SD250102','S250102','P2',NULL,2,450.00,0.00,900.00),
('SD250103','S250103','P3',NULL,2,250.00,0.00,500.00),
('SD250104','S250104','P4',NULL,2,600.00,0.00,1200.00),
('SD250105','S250105','P5',NULL,3,550.00,0.00,1650.00),
('SD250106','S250106','P1',NULL,1,1800.00,0.00,1800.00),
('SD250107','S250107','P2',NULL,2,450.00,0.00,900.00),
('SD250108','S250108','P3',NULL,2,250.00,0.00,500.00),
('SD250109','S250109','P4',NULL,2,600.00,0.00,1200.00),
('SD250110','S250110','P5',NULL,3,550.00,0.00,1650.00);

-- ======================== FEBRUARY 2025 ========================
INSERT INTO Sales VALUES
('S250201','2025-02-02',1800.00,'Cash','CUST2'),
('S250202','2025-02-05',900.00,'UPI','CUST3'),
('S250203','2025-02-08',500.00,'Card','CUST4'),
('S250204','2025-02-11',1200.00,'Cash','CUST5'),
('S250205','2025-02-14',1650.00,'UPI','CUST1'),
('S250206','2025-02-17',1800.00,'Card','CUST2'),
('S250207','2025-02-20',900.00,'Cash','CUST3'),
('S250208','2025-02-23',500.00,'UPI','CUST4'),
('S250209','2025-02-25',1200.00,'Card','CUST5'),
('S250210','2025-02-27',1650.00,'Cash','CUST1');

INSERT INTO SaleDetails VALUES
('SD250201','S250201','P1',NULL,1,1800.00,0.00,1800.00),
('SD250202','S250202','P2',NULL,2,450.00,0.00,900.00),
('SD250203','S250203','P3',NULL,2,250.00,0.00,500.00),
('SD250204','S250204','P4',NULL,2,600.00,0.00,1200.00),
('SD250205','S250205','P5',NULL,3,550.00,0.00,1650.00),
('SD250206','S250206','P1',NULL,1,1800.00,0.00,1800.00),
('SD250207','S250207','P2',NULL,2,450.00,0.00,900.00),
('SD250208','S250208','P3',NULL,2,250.00,0.00,500.00),
('SD250209','S250209','P4',NULL,2,600.00,0.00,1200.00),
('SD250210','S250210','P5',NULL,3,550.00,0.00,1650.00);

-- ======================== MARCH 2025 ========================
INSERT INTO Sales VALUES
('S250301','2025-03-02',1800.00,'Cash','CUST3'),
('S250302','2025-03-05',900.00,'UPI','CUST4'),
('S250303','2025-03-08',500.00,'Card','CUST5'),
('S250304','2025-03-11',1200.00,'Cash','CUST1'),
('S250305','2025-03-14',1650.00,'UPI','CUST2'),
('S250306','2025-03-17',1800.00,'Card','CUST3'),
('S250307','2025-03-20',900.00,'Cash','CUST4'),
('S250308','2025-03-23',500.00,'UPI','CUST5'),
('S250309','2025-03-26',1200.00,'Card','CUST1'),
('S250310','2025-03-28',1650.00,'Cash','CUST2');

INSERT INTO SaleDetails VALUES
('SD250301','S250301','P1',NULL,1,1800.00,0.00,1800.00),
('SD250302','S250302','P2',NULL,2,450.00,0.00,900.00),
('SD250303','S250303','P3',NULL,2,250.00,0.00,500.00),
('SD250304','S250304','P4',NULL,2,600.00,0.00,1200.00),
('SD250305','S250305','P5',NULL,3,550.00,0.00,1650.00),
('SD250306','S250306','P1',NULL,1,1800.00,0.00,1800.00),
('SD250307','S250307','P2',NULL,2,450.00,0.00,900.00),
('SD250308','S250308','P3',NULL,2,250.00,0.00,500.00),
('SD250309','S250309','P4',NULL,2,600.00,0.00,1200.00),
('SD250310','S250310','P5',NULL,3,550.00,0.00,1650.00);

-- ======================== APRIL 2025 ========================
INSERT INTO Sales VALUES
('S250401','2025-04-02',1800.00,'Cash','CUST4'),
('S250402','2025-04-05',900.00,'UPI','CUST5'),
('S250403','2025-04-08',500.00,'Card','CUST1'),
('S250404','2025-04-11',1200.00,'Cash','CUST2'),
('S250405','2025-04-14',1650.00,'UPI','CUST3'),
('S250406','2025-04-17',1800.00,'Card','CUST4'),
('S250407','2025-04-20',900.00,'Cash','CUST5'),
('S250408','2025-04-23',500.00,'UPI','CUST1'),
('S250409','2025-04-26',1200.00,'Card','CUST2'),
('S250410','2025-04-28',1650.00,'Cash','CUST3');

INSERT INTO SaleDetails VALUES
('SD250401','S250401','P1',NULL,1,1800.00,0.00,1800.00),
('SD250402','S250402','P2',NULL,2,450.00,0.00,900.00),
('SD250403','S250403','P3',NULL,2,250.00,0.00,500.00),
('SD250404','S250404','P4',NULL,2,600.00,0.00,1200.00),
('SD250405','S250405','P5',NULL,3,550.00,0.00,1650.00),
('SD250406','S250406','P1',NULL,1,1800.00,0.00,1800.00),
('SD250407','S250407','P2',NULL,2,450.00,0.00,900.00),
('SD250408','S250408','P3',NULL,2,250.00,0.00,500.00),
('SD250409','S250409','P4',NULL,2,600.00,0.00,1200.00),
('SD250410','S250410','P5',NULL,3,550.00,0.00,1650.00);

-- ======================== MAY 2025 ========================
INSERT INTO Sales VALUES
('S250501','2025-05-02',1800.00,'Cash','CUST5'),
('S250502','2025-05-05',900.00,'UPI','CUST1'),
('S250503','2025-05-08',500.00,'Card','CUST2'),
('S250504','2025-05-11',1200.00,'Cash','CUST3'),
('S250505','2025-05-14',1650.00,'UPI','CUST4'),
('S250506','2025-05-17',1800.00,'Card','CUST5'),
('S250507','2025-05-20',900.00,'Cash','CUST1'),
('S250508','2025-05-23',500.00,'UPI','CUST2'),
('S250509','2025-05-26',1200.00,'Card','CUST3'),
('S250510','2025-05-28',1650.00,'Cash','CUST4');

INSERT INTO SaleDetails VALUES
('SD250501','S250501','P1',NULL,1,1800.00,0.00,1800.00),
('SD250502','S250502','P2',NULL,2,450.00,0.00,900.00),
('SD250503','S250503','P3',NULL,2,250.00,0.00,500.00),
('SD250504','S250504','P4',NULL,2,600.00,0.00,1200.00),
('SD250505','S250505','P5',NULL,3,550.00,0.00,1650.00),
('SD250506','S250506','P1',NULL,1,1800.00,0.00,1800.00),
('SD250507','S250507','P2',NULL,2,450.00,0.00,900.00),
('SD250508','S250508','P3',NULL,2,250.00,0.00,500.00),
('SD250509','S250509','P4',NULL,2,600.00,0.00,1200.00),
('SD250510','S250510','P5',NULL,3,550.00,0.00,1650.00);

-- ======================== JUNE 2025 ========================
INSERT INTO Sales VALUES
('S250601','2025-06-02',1800.00,'Cash','CUST1'),
('S250602','2025-06-05',900.00,'UPI','CUST2'),
('S250603','2025-06-08',500.00,'Card','CUST3'),
('S250604','2025-06-11',1200.00,'Cash','CUST4'),
('S250605','2025-06-14',1650.00,'UPI','CUST5'),
('S250606','2025-06-17',1800.00,'Card','CUST1'),
('S250607','2025-06-20',900.00,'Cash','CUST2'),
('S250608','2025-06-23',500.00,'UPI','CUST3'),
('S250609','2025-06-26',1200.00,'Card','CUST4'),
('S250610','2025-06-28',1650.00,'Cash','CUST5');

INSERT INTO SaleDetails VALUES
('SD250601','S250601','P1',NULL,1,1800.00,0.00,1800.00),
('SD250602','S250602','P2',NULL,2,450.00,0.00,900.00),
('SD250603','S250603','P3',NULL,2,250.00,0.00,500.00),
('SD250604','S250604','P4',NULL,2,600.00,0.00,1200.00),
('SD250605','S250605','P5',NULL,3,550.00,0.00,1650.00),
('SD250606','S250606','P1',NULL,1,1800.00,0.00,1800.00),
('SD250607','S250607','P2',NULL,2,450.00,0.00,900.00),
('SD250608','S250608','P3',NULL,2,250.00,0.00,500.00),
('SD250609','S250609','P4',NULL,2,600.00,0.00,1200.00),
('SD250610','S250610','P5',NULL,3,550.00,0.00,1650.00);

-- ======================== JULY 2025 ========================
INSERT INTO Sales VALUES
('S250701','2025-07-02',1800.00,'Cash','CUST2'),
('S250702','2025-07-05',900.00,'UPI','CUST3'),
('S250703','2025-07-08',500.00,'Card','CUST4'),
('S250704','2025-07-11',1200.00,'Cash','CUST5'),
('S250705','2025-07-14',1650.00,'UPI','CUST1'),
('S250706','2025-07-17',1800.00,'Card','CUST2'),
('S250707','2025-07-20',900.00,'Cash','CUST3'),
('S250708','2025-07-23',500.00,'UPI','CUST4'),
('S250709','2025-07-26',1200.00,'Card','CUST5'),
('S250710','2025-07-28',1650.00,'Cash','CUST1');

INSERT INTO SaleDetails VALUES
('SD250701','S250701','P1',NULL,1,1800.00,0.00,1800.00),
('SD250702','S250702','P2',NULL,2,450.00,0.00,900.00),
('SD250703','S250703','P3',NULL,2,250.00,0.00,500.00),
('SD250704','S250704','P4',NULL,2,600.00,0.00,1200.00),
('SD250705','S250705','P5',NULL,3,550.00,0.00,1650.00),
('SD250706','S250706','P1',NULL,1,1800.00,0.00,1800.00),
('SD250707','S250707','P2',NULL,2,450.00,0.00,900.00),
('SD250708','S250708','P3',NULL,2,250.00,0.00,500.00),
('SD250709','S250709','P4',NULL,2,600.00,0.00,1200.00),
('SD250710','S250710','P5',NULL,3,550.00,0.00,1650.00);

-- ======================== AUGUST 2025 ========================
INSERT INTO Sales VALUES
('S250801','2025-08-02',1800.00,'Cash','CUST3'),
('S250802','2025-08-05',900.00,'UPI','CUST4'),
('S250803','2025-08-08',500.00,'Card','CUST5'),
('S250804','2025-08-11',1200.00,'Cash','CUST1'),
('S250805','2025-08-14',1650.00,'UPI','CUST2'),
('S250806','2025-08-17',1800.00,'Card','CUST3'),
('S250807','2025-08-20',900.00,'Cash','CUST4'),
('S250808','2025-08-23',500.00,'UPI','CUST5'),
('S250809','2025-08-26',1200.00,'Card','CUST1'),
('S250810','2025-08-28',1650.00,'Cash','CUST2');

INSERT INTO SaleDetails VALUES
('SD250801','S250801','P1',NULL,1,1800.00,0.00,1800.00),
('SD250802','S250802','P2',NULL,2,450.00,0.00,900.00),
('SD250803','S250803','P3',NULL,2,250.00,0.00,500.00),
('SD250804','S250804','P4',NULL,2,600.00,0.00,1200.00),
('SD250805','S250805','P5',NULL,3,550.00,0.00,1650.00),
('SD250806','S250806','P1',NULL,1,1800.00,0.00,1800.00),
('SD250807','S250807','P2',NULL,2,450.00,0.00,900.00),
('SD250808','S250808','P3',NULL,2,250.00,0.00,500.00),
('SD250809','S250809','P4',NULL,2,600.00,0.00,1200.00),
('SD250810','S250810','P5',NULL,3,550.00,0.00,1650.00);

-- ======================== SEPTEMBER 2025 ========================
INSERT INTO Sales VALUES
('S250901','2025-09-02',1800.00,'Cash','CUST4'),
('S250902','2025-09-05',900.00,'UPI','CUST5'),
('S250903','2025-09-08',500.00,'Card','CUST1'),
('S250904','2025-09-11',1200.00,'Cash','CUST2'),
('S250905','2025-09-14',1650.00,'UPI','CUST3'),
('S250906','2025-09-17',1800.00,'Card','CUST4'),
('S250907','2025-09-20',900.00,'Cash','CUST5'),
('S250908','2025-09-23',500.00,'UPI','CUST1'),
('S250909','2025-09-26',1200.00,'Card','CUST2'),
('S250910','2025-09-28',1650.00,'Cash','CUST3');

INSERT INTO SaleDetails VALUES
('SD250901','S250901','P1',NULL,1,1800.00,0.00,1800.00),
('SD250902','S250902','P2',NULL,2,450.00,0.00,900.00),
('SD250903','S250903','P3',NULL,2,250.00,0.00,500.00),
('SD250904','S250904','P4',NULL,2,600.00,0.00,1200.00),
('SD250905','S250905','P5',NULL,3,550.00,0.00,1650.00),
('SD250906','S250906','P1',NULL,1,1800.00,0.00,1800.00),
('SD250907','S250907','P2',NULL,2,450.00,0.00,900.00),
('SD250908','S250908','P3',NULL,2,250.00,0.00,500.00),
('SD250909','S250909','P4',NULL,2,600.00,0.00,1200.00),
('SD250910','S250910','P5',NULL,3,550.00,0.00,1650.00);

-- ======================== OCTOBER 2025 ========================
INSERT INTO Sales VALUES
('S251001','2025-10-02',1800.00,'Cash','CUST5'),
('S251002','2025-10-05',900.00,'UPI','CUST1'),
('S251003','2025-10-08',500.00,'Card','CUST2'),
('S251004','2025-10-11',1200.00,'Cash','CUST3'),
('S251005','2025-10-14',1650.00,'UPI','CUST4'),
('S251006','2025-10-17',1800.00,'Card','CUST5'),
('S251007','2025-10-20',900.00,'Cash','CUST1'),
('S251008','2025-10-23',500.00,'UPI','CUST2'),
('S251009','2025-10-26',1200.00,'Card','CUST3'),
('S251010','2025-10-28',1650.00,'Cash','CUST4');

INSERT INTO SaleDetails VALUES
('SD251001','S251001','P1',NULL,1,1800.00,0.00,1800.00),
('SD251002','S251002','P2',NULL,2,450.00,0.00,900.00),
('SD251003','S251003','P3',NULL,2,250.00,0.00,500.00),
('SD251004','S251004','P4',NULL,2,600.00,0.00,1200.00),
('SD251005','S251005','P5',NULL,3,550.00,0.00,1650.00),
('SD251006','S251006','P1',NULL,1,1800.00,0.00,1800.00),
('SD251007','S251007','P2',NULL,2,450.00,0.00,900.00),
('SD251008','S251008','P3',NULL,2,250.00,0.00,500.00),
('SD251009','S251009','P4',NULL,2,600.00,0.00,1200.00),
('SD251010','S251010','P5',NULL,3,550.00,0.00,1650.00);

USE sales_stock_management;

INSERT INTO Customer (customer_id, customer_name, email, phone, address, city, country) VALUES
('CUST6','Rohit Sharma','rohit.sharma@example.com','+91-9100000006','Station Road','Angul','India'),
('CUST7','Sunita Rao','sunita.rao@example.com','+91-9100000007','Market Street','Angul','India'),
('CUST8','Deepak Nair','deepak.nair@example.com','+91-9100000008','Temple Lane','Angul','India'),
('CUST9','Kiran Mehta','kiran.mehta@example.com','+91-9100000009','Lake View','Angul','India'),
('CUST10','Vikas Jain','vikas.jain@example.com','+91-9100000010','Hill Road','Angul','India'),
('CUST11','Sneha Kapoor','sneha.kapoor@example.com','+91-9100000011','Green Park','Angul','India'),
('CUST12','Harish Iyer','harish.iyer@example.com','+91-9100000012','River Bank','Angul','India'),
('CUST13','Megha Reddy','megha.reddy@example.com','+91-9100000013','College Road','Angul','India'),
('CUST14','Pooja Bansal','pooja.bansal@example.com','+91-9100000014','Bus Depot','Angul','India'),
('CUST15','Ankit Gupta','ankit.gupta@example.com','+91-9100000015','Old Town','Angul','India'),
('CUST16','Divya Singh','divya.singh@example.com','+91-9100000016','New Colony','Angul','India'),
('CUST17','Rahul Verma','rahul.verma@example.com','+91-9100000017','MG Road','Angul','India'),
('CUST18','Ananya Das','ananya.das@example.com','+91-9100000018','Airport Road','Angul','India'),
('CUST19','Sahil Khan','sahil.khan@example.com','+91-9100000019','Industrial Area','Angul','India'),
('CUST20','Ishita Patel','ishita.patel@example.com','+91-9100000020','High Street','Angul','India'),
('CUST21','Aman Tiwari','aman.tiwari@example.com','+91-9100000021','Garden View','Angul','India'),
('CUST22','Bhavna Jain','bhavna.jain@example.com','+91-9100000022','Sunrise Nagar','Angul','India'),
('CUST23','Karthik R','karthik.r@example.com','+91-9100000023','Central Avenue','Angul','India'),
('CUST24','Nisha Kumar','nisha.kumar@example.com','+91-9100000024','West End','Angul','India'),
('CUST25','Gaurav Sinha','gaurav.sinha@example.com','+91-9100000025','East Market','Angul','India'),
('CUST26','Payal Shah','payal.shah@example.com','+91-9100000026','City Center','Angul','India'),
('CUST27','Tarun Arora','tarun.arora@example.com','+91-9100000027','Ring Road','Angul','India'),
('CUST28','Kirti Joshi','kirti.joshi@example.com','+91-9100000028','Silver Oaks','Angul','India'),
('CUST29','Neeraj Malhotra','neeraj.malhotra@example.com','+91-9100000029','Sunset Blvd','Angul','India'),
('CUST30','Ritika Ghosh','ritika.ghosh@example.com','+91-9100000030','Harbour Road','Angul','India');
USE sales_stock_management;

INSERT INTO Customer (customer_id, customer_name, email, phone, address, city, country) VALUES
('CUST31','Yash Agarwal','yash.agarwal@example.com','+91-9100000031','Civic Center','Angul','India'),
('CUST32','Lavanya Menon','lavanya.menon@example.com','+91-9100000032','Lotus Park','Angul','India'),
('CUST33','Vivek Kulkarni','vivek.kulkarni@example.com','+91-9100000033','Elm Street','Angul','India'),
('CUST34','Jasmin Kaur','jasmin.kaur@example.com','+91-9100000034','Pearl Avenue','Angul','India'),
('CUST35','Rohan Nanda','rohan.nanda@example.com','+91-9100000035','Skyline Road','Angul','India'),
('CUST36','Priyanka Paul','priyanka.paul@example.com','+91-9100000036','Lake Gardens','Angul','India'),
('CUST37','Suresh Rathi','suresh.rathi@example.com','+91-9100000037','Grand Trunk Rd','Angul','India'),
('CUST38','Bharti Soni','bharti.soni@example.com','+91-9100000038','Vasant Vihar','Angul','India'),
('CUST39','Ashok Chauhan','ashok.chauhan@example.com','+91-9100000039','Shastri Nagar','Angul','India'),
('CUST40','Ritu Jain','ritu.jain@example.com','+91-9100000040','Laxmi Road','Angul','India'),
('CUST41','Harpreet Singh','harpreet.singh@example.com','+91-9100000041','Baker Street','Angul','India'),
('CUST42','Nandini Rao','nandini.rao@example.com','+91-9100000042','Sapphire Lane','Angul','India'),
('CUST43','Manish Desai','manish.desai@example.com','+91-9100000043','Park Avenue','Angul','India'),
('CUST44','Shruti Mishra','shruti.mishra@example.com','+91-9100000044','Rose Garden','Angul','India'),
('CUST45','Arvind Joshi','arvind.joshi@example.com','+91-9100000045','Airport Link Rd','Angul','India'),
('CUST46','Mansi Batra','mansi.batra@example.com','+91-9100000046','Canal Street','Angul','India'),
('CUST47','Farhan Ali','farhan.ali@example.com','+91-9100000047','Heritage Circle','Angul','India'),
('CUST48','Zara Sheikh','zara.sheikh@example.com','+91-9100000048','Sunrise Point','Angul','India'),
('CUST49','Naveen Kumar','naveen.kumar@example.com','+91-9100000049','Pine View','Angul','India'),
('CUST50','Mahima Kapoor','mahima.kapoor@example.com','+91-9100000050','Orchid Heights','Angul','India');


USE sales_stock_management;

-- Seed 300 products: IDs P6..P305
-- Categories rotate across Grains, Pulses, Essentials, Beverages, Snacks
-- Suppliers rotate across SUP1, SUP2, SUP3

INSERT INTO Product (product_id, product_name, category, unit_price, stock_quantity, reorder_level, created_at, updated_at, supplier_id) VALUES
-- P6..P55
('P6','Item 6','Grains',110.00,200,40,'2025-01-01','2025-10-01','SUP1'),
('P7','Item 7','Pulses',120.00,180,36,'2025-01-01','2025-10-01','SUP2'),
('P8','Item 8','Essentials',130.00,160,32,'2025-01-01','2025-10-01','SUP3'),
('P9','Item 9','Beverages',140.00,140,28,'2025-01-01','2025-10-01','SUP1'),
('P10','Item 10','Snacks',150.00,120,24,'2025-01-01','2025-10-01','SUP2'),
('P11','Item 11','Grains',160.00,200,40,'2025-01-01','2025-10-01','SUP3'),
('P12','Item 12','Pulses',170.00,180,36,'2025-01-01','2025-10-01','SUP1'),
('P13','Item 13','Essentials',180.00,160,32,'2025-01-01','2025-10-01','SUP2'),
('P14','Item 14','Beverages',190.00,140,28,'2025-01-01','2025-10-01','SUP3'),
('P15','Item 15','Snacks',200.00,120,24,'2025-01-01','2025-10-01','SUP1'),
('P16','Item 16','Grains',210.00,200,40,'2025-01-01','2025-10-01','SUP2'),
('P17','Item 17','Pulses',220.00,180,36,'2025-01-01','2025-10-01','SUP3'),
('P18','Item 18','Essentials',230.00,160,32,'2025-01-01','2025-10-01','SUP1'),
('P19','Item 19','Beverages',240.00,140,28,'2025-01-01','2025-10-01','SUP2'),
('P20','Item 20','Snacks',250.00,120,24,'2025-01-01','2025-10-01','SUP3'),
('P21','Item 21','Grains',260.00,200,40,'2025-01-01','2025-10-01','SUP1'),
('P22','Item 22','Pulses',270.00,180,36,'2025-01-01','2025-10-01','SUP2'),
('P23','Item 23','Essentials',280.00,160,32,'2025-01-01','2025-10-01','SUP3'),
('P24','Item 24','Beverages',290.00,140,28,'2025-01-01','2025-10-01','SUP1'),
('P25','Item 25','Snacks',300.00,120,24,'2025-01-01','2025-10-01','SUP2'),
('P26','Item 26','Grains',310.00,200,40,'2025-01-01','2025-10-01','SUP3'),
('P27','Item 27','Pulses',320.00,180,36,'2025-01-01','2025-10-01','SUP1'),
('P28','Item 28','Essentials',330.00,160,32,'2025-01-01','2025-10-01','SUP2'),
('P29','Item 29','Beverages',340.00,140,28,'2025-01-01','2025-10-01','SUP3'),
('P30','Item 30','Snacks',350.00,120,24,'2025-01-01','2025-10-01','SUP1'),
('P31','Item 31','Grains',360.00,200,40,'2025-01-01','2025-10-01','SUP2'),
('P32','Item 32','Pulses',370.00,180,36,'2025-01-01','2025-10-01','SUP3'),
('P33','Item 33','Essentials',380.00,160,32,'2025-01-01','2025-10-01','SUP1'),
('P34','Item 34','Beverages',390.00,140,28,'2025-01-01','2025-10-01','SUP2'),
('P35','Item 35','Snacks',400.00,120,24,'2025-01-01','2025-10-01','SUP3'),
('P36','Item 36','Grains',410.00,200,40,'2025-01-01','2025-10-01','SUP1'),
('P37','Item 37','Pulses',420.00,180,36,'2025-01-01','2025-10-01','SUP2'),
('P38','Item 38','Essentials',430.00,160,32,'2025-01-01','2025-10-01','SUP3'),
('P39','Item 39','Beverages',440.00,140,28,'2025-01-01','2025-10-01','SUP1'),
('P40','Item 40','Snacks',450.00,120,24,'2025-01-01','2025-10-01','SUP2'),
('P41','Item 41','Grains',460.00,200,40,'2025-01-01','2025-10-01','SUP3'),
('P42','Item 42','Pulses',470.00,180,36,'2025-01-01','2025-10-01','SUP1'),
('P43','Item 43','Essentials',480.00,160,32,'2025-01-01','2025-10-01','SUP2'),
('P44','Item 44','Beverages',490.00,140,28,'2025-01-01','2025-10-01','SUP3'),
('P45','Item 45','Snacks',500.00,120,24,'2025-01-01','2025-10-01','SUP1'),
('P46','Item 46','Grains',510.00,200,40,'2025-01-01','2025-10-01','SUP2'),
('P47','Item 47','Pulses',520.00,180,36,'2025-01-01','2025-10-01','SUP3'),
('P48','Item 48','Essentials',530.00,160,32,'2025-01-01','2025-10-01','SUP1'),
('P49','Item 49','Beverages',540.00,140,28,'2025-01-01','2025-10-01','SUP2'),
('P50','Item 50','Snacks',550.00,120,24,'2025-01-01','2025-10-01','SUP3')
;

-- Auto-generate remainder pattern P51..P305
-- For brevity we use multiple INSERT batches to reach 300 rows

INSERT INTO Product (product_id, product_name, category, unit_price, stock_quantity, reorder_level, created_at, updated_at, supplier_id)
SELECT 
  CONCAT('P', n) AS product_id,
  CONCAT('Item ', n) AS product_name,
  CASE (n % 5)
    WHEN 1 THEN 'Grains'
    WHEN 2 THEN 'Pulses'
    WHEN 3 THEN 'Essentials'
    WHEN 4 THEN 'Beverages'
    ELSE 'Snacks'
  END AS category,
  50 + (n * 5) AS unit_price,
  100 + ((n % 5) * 20) AS stock_quantity,
  20 + ((n % 5) * 4) AS reorder_level,
  '2025-01-01' AS created_at,
  '2025-10-01' AS updated_at,
  CASE (n % 3)
    WHEN 1 THEN 'SUP1'
    WHEN 2 THEN 'SUP2'
    ELSE 'SUP3'
  END AS supplier_id
FROM (
  SELECT 51 AS n UNION ALL SELECT 52 UNION ALL SELECT 53 UNION ALL SELECT 54 UNION ALL SELECT 55
  UNION ALL SELECT 56 UNION ALL SELECT 57 UNION ALL SELECT 58 UNION ALL SELECT 59 UNION ALL SELECT 60
  UNION ALL SELECT 61 UNION ALL SELECT 62 UNION ALL SELECT 63 UNION ALL SELECT 64 UNION ALL SELECT 65
  UNION ALL SELECT 66 UNION ALL SELECT 67 UNION ALL SELECT 68 UNION ALL SELECT 69 UNION ALL SELECT 70
  UNION ALL SELECT 71 UNION ALL SELECT 72 UNION ALL SELECT 73 UNION ALL SELECT 74 UNION ALL SELECT 75
  UNION ALL SELECT 76 UNION ALL SELECT 77 UNION ALL SELECT 78 UNION ALL SELECT 79 UNION ALL SELECT 80
  UNION ALL SELECT 81 UNION ALL SELECT 82 UNION ALL SELECT 83 UNION ALL SELECT 84 UNION ALL SELECT 85
  UNION ALL SELECT 86 UNION ALL SELECT 87 UNION ALL SELECT 88 UNION ALL SELECT 89 UNION ALL SELECT 90
  UNION ALL SELECT 91 UNION ALL SELECT 92 UNION ALL SELECT 93 UNION ALL SELECT 94 UNION ALL SELECT 95
  UNION ALL SELECT 96 UNION ALL SELECT 97 UNION ALL SELECT 98 UNION ALL SELECT 99 UNION ALL SELECT 100
  UNION ALL SELECT 101 UNION ALL SELECT 102 UNION ALL SELECT 103 UNION ALL SELECT 104 UNION ALL SELECT 105
  UNION ALL SELECT 106 UNION ALL SELECT 107 UNION ALL SELECT 108 UNION ALL SELECT 109 UNION ALL SELECT 110
  UNION ALL SELECT 111 UNION ALL SELECT 112 UNION ALL SELECT 113 UNION ALL SELECT 114 UNION ALL SELECT 115
  UNION ALL SELECT 116 UNION ALL SELECT 117 UNION ALL SELECT 118 UNION ALL SELECT 119 UNION ALL SELECT 120
  UNION ALL SELECT 121 UNION ALL SELECT 122 UNION ALL SELECT 123 UNION ALL SELECT 124 UNION ALL SELECT 125
  UNION ALL SELECT 126 UNION ALL SELECT 127 UNION ALL SELECT 128 UNION ALL SELECT 129 UNION ALL SELECT 130
  UNION ALL SELECT 131 UNION ALL SELECT 132 UNION ALL SELECT 133 UNION ALL SELECT 134 UNION ALL SELECT 135
  UNION ALL SELECT 136 UNION ALL SELECT 137 UNION ALL SELECT 138 UNION ALL SELECT 139 UNION ALL SELECT 140
  UNION ALL SELECT 141 UNION ALL SELECT 142 UNION ALL SELECT 143 UNION ALL SELECT 144 UNION ALL SELECT 145
  UNION ALL SELECT 146 UNION ALL SELECT 147 UNION ALL SELECT 148 UNION ALL SELECT 149 UNION ALL SELECT 150
  UNION ALL SELECT 151 UNION ALL SELECT 152 UNION ALL SELECT 153 UNION ALL SELECT 154 UNION ALL SELECT 155
  UNION ALL SELECT 156 UNION ALL SELECT 157 UNION ALL SELECT 158 UNION ALL SELECT 159 UNION ALL SELECT 160
  UNION ALL SELECT 161 UNION ALL SELECT 162 UNION ALL SELECT 163 UNION ALL SELECT 164 UNION ALL SELECT 165
  UNION ALL SELECT 166 UNION ALL SELECT 167 UNION ALL SELECT 168 UNION ALL SELECT 169 UNION ALL SELECT 170
  UNION ALL SELECT 171 UNION ALL SELECT 172 UNION ALL SELECT 173 UNION ALL SELECT 174 UNION ALL SELECT 175
  UNION ALL SELECT 176 UNION ALL SELECT 177 UNION ALL SELECT 178 UNION ALL SELECT 179 UNION ALL SELECT 180
  UNION ALL SELECT 181 UNION ALL SELECT 182 UNION ALL SELECT 183 UNION ALL SELECT 184 UNION ALL SELECT 185
  UNION ALL SELECT 186 UNION ALL SELECT 187 UNION ALL SELECT 188 UNION ALL SELECT 189 UNION ALL SELECT 190
  UNION ALL SELECT 191 UNION ALL SELECT 192 UNION ALL SELECT 193 UNION ALL SELECT 194 UNION ALL SELECT 195
  UNION ALL SELECT 196 UNION ALL SELECT 197 UNION ALL SELECT 198 UNION ALL SELECT 199 UNION ALL SELECT 200
  UNION ALL SELECT 201 UNION ALL SELECT 202 UNION ALL SELECT 203 UNION ALL SELECT 204 UNION ALL SELECT 205
  UNION ALL SELECT 206 UNION ALL SELECT 207 UNION ALL SELECT 208 UNION ALL SELECT 209 UNION ALL SELECT 210
  UNION ALL SELECT 211 UNION ALL SELECT 212 UNION ALL SELECT 213 UNION ALL SELECT 214 UNION ALL SELECT 215
  UNION ALL SELECT 216 UNION ALL SELECT 217 UNION ALL SELECT 218 UNION ALL SELECT 219 UNION ALL SELECT 220
  UNION ALL SELECT 221 UNION ALL SELECT 222 UNION ALL SELECT 223 UNION ALL SELECT 224 UNION ALL SELECT 225
  UNION ALL SELECT 226 UNION ALL SELECT 227 UNION ALL SELECT 228 UNION ALL SELECT 229 UNION ALL SELECT 230
  UNION ALL SELECT 231 UNION ALL SELECT 232 UNION ALL SELECT 233 UNION ALL SELECT 234 UNION ALL SELECT 235
  UNION ALL SELECT 236 UNION ALL SELECT 237 UNION ALL SELECT 238 UNION ALL SELECT 239 UNION ALL SELECT 240
  UNION ALL SELECT 241 UNION ALL SELECT 242 UNION ALL SELECT 243 UNION ALL SELECT 244 UNION ALL SELECT 245
  UNION ALL SELECT 246 UNION ALL SELECT 247 UNION ALL SELECT 248 UNION ALL SELECT 249 UNION ALL SELECT 250
  UNION ALL SELECT 251 UNION ALL SELECT 252 UNION ALL SELECT 253 UNION ALL SELECT 254 UNION ALL SELECT 255
  UNION ALL SELECT 256 UNION ALL SELECT 257 UNION ALL SELECT 258 UNION ALL SELECT 259 UNION ALL SELECT 260
  UNION ALL SELECT 261 UNION ALL SELECT 262 UNION ALL SELECT 263 UNION ALL SELECT 264 UNION ALL SELECT 265
  UNION ALL SELECT 266 UNION ALL SELECT 267 UNION ALL SELECT 268 UNION ALL SELECT 269 UNION ALL SELECT 270
  UNION ALL SELECT 271 UNION ALL SELECT 272 UNION ALL SELECT 273 UNION ALL SELECT 274 UNION ALL SELECT 275
  UNION ALL SELECT 276 UNION ALL SELECT 277 UNION ALL SELECT 278 UNION ALL SELECT 279 UNION ALL SELECT 280
  UNION ALL SELECT 281 UNION ALL SELECT 282 UNION ALL SELECT 283 UNION ALL SELECT 284 UNION ALL SELECT 285
  UNION ALL SELECT 286 UNION ALL SELECT 287 UNION ALL SELECT 288 UNION ALL SELECT 289 UNION ALL SELECT 290
  UNION ALL SELECT 291 UNION ALL SELECT 292 UNION ALL SELECT 293 UNION ALL SELECT 294 UNION ALL SELECT 295
  UNION ALL SELECT 296 UNION ALL SELECT 297 UNION ALL SELECT 298 UNION ALL SELECT 299 UNION ALL SELECT 300
  UNION ALL SELECT 301 UNION ALL SELECT 302 UNION ALL SELECT 303 UNION ALL SELECT 304 UNION ALL SELECT 305
) AS t;




-- ---------------------------------------------------------------------
-- VIEWS (Reusable reports)
-- ---------------------------------------------------------------------
-- View 1: Total spent by each customer
CREATE OR REPLACE VIEW v_customer_total AS
SELECT c.customer_id, c.customer_name, SUM(s.total_amount) AS total_spent
FROM Sales s JOIN Customer c ON s.customer_id=c.customer_id
GROUP BY c.customer_id, c.customer_name;

-- View 2: Total sales and quantity by product
CREATE OR REPLACE VIEW v_product_sales AS
SELECT p.product_id, p.product_name, SUM(sd.quantity) AS total_units_sold, SUM(sd.total_price) AS total_sales
FROM SaleDetails sd JOIN Product p ON sd.product_id=p.product_id
GROUP BY p.product_id, p.product_name;

-- ---------------------------------------------------------------------
-- 4️⃣ TRIGGERS (Automatic actions)
-- ---------------------------------------------------------------------
DELIMITER //
-- Trigger 1: After product stock update → logs to StockLogs
CREATE TRIGGER trg_after_stock_update
AFTER UPDATE ON Product
FOR EACH ROW
BEGIN
 IF NEW.stock_quantity <> OLD.stock_quantity THEN
  INSERT INTO StockLogs(log_id, stock_quantity, log_date, remarks, product_id)
  VALUES(CONCAT('SL',UUID()), NEW.stock_quantity, NOW(), 'Stock updated by trigger', NEW.product_id);
 END IF;
END //
DELIMITER ;

DELIMITER //
-- Trigger 2: After new sale insert → logs activity to ActivityLog
CREATE TRIGGER trg_after_sale_insert
AFTER INSERT ON Sales
FOR EACH ROW
BEGIN
 INSERT INTO ActivityLog(log_id, action, entity, record_id, timestamp, user_id)
 VALUES(CONCAT('AL',UUID()), 'NEW_SALE', 'Sales', NEW.sale_id, NOW(), 'U1');
END //
DELIMITER ;

-- ---------------------------------------------------------------------
-- 5️⃣ STORED PROCEDURE (Cursor example)
-- ---------------------------------------------------------------------
DELIMITER //
-- Procedure: ListLowStockProducts
-- Purpose: Scans products and lists those below reorder level
CREATE PROCEDURE ListLowStockProducts()
BEGIN
 DECLARE done INT DEFAULT 0;
 DECLARE p_id VARCHAR(10);
 DECLARE p_name VARCHAR(100);
 DECLARE cur CURSOR FOR 
     SELECT product_id, product_name FROM Product WHERE stock_quantity <= reorder_level;
 DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

 OPEN cur;
 read_loop: LOOP
  FETCH cur INTO p_id, p_name;
  IF done THEN LEAVE read_loop; END IF;
  SELECT CONCAT('Low Stock: ', p_id, ' - ', p_name) AS Alert;
 END LOOP;
 CLOSE cur;
END //
DELIMITER ;

-- ---------------------------------------------------------------------
-- 6️⃣ FUNCTION (Reusable logic)
-- ---------------------------------------------------------------------
DELIMITER //
-- Function: GetTotalBySaleID
-- Purpose: Returns total of all items for a given Sale ID
CREATE FUNCTION GetTotalBySaleID(sid VARCHAR(10))
RETURNS DECIMAL(12,2)
DETERMINISTIC
BEGIN
 DECLARE total DECIMAL(12,2);
 SELECT SUM(total_price) INTO total FROM SaleDetails WHERE sale_id = sid;
 RETURN total;
END //
DELIMITER ;

-- ---------------------------------------------------------------------
-- 7️⃣ COMPLEX QUERIES (used in Analytics tab)
-- ---------------------------------------------------------------------

-- (1) Customers whose total spend > average sale amount
SELECT c.customer_name, SUM(s.total_amount) AS total_spent
FROM Sales s JOIN Customer c ON s.customer_id=c.customer_id
GROUP BY c.customer_name
HAVING SUM(s.total_amount) > (SELECT AVG(total_amount) FROM Sales);

-- (2) Top 5 products by revenue
SELECT p.product_name, SUM(sd.total_price) AS total_revenue
FROM SaleDetails sd JOIN Product p ON sd.product_id=p.product_id
GROUP BY p.product_name ORDER BY total_revenue DESC LIMIT 5;

-- (3) Monthly sales totals (trend analysis)
SELECT DATE_FORMAT(s.sale_date,'%Y-%m') AS Month, SUM(s.total_amount) AS Monthly_Sales
FROM Sales s GROUP BY Month ORDER BY Month;

-- (4) Customer order count and spending summary
SELECT c.customer_name, COUNT(s.sale_id) AS total_orders, SUM(s.total_amount) AS total_spent
FROM Sales s JOIN Customer c ON s.customer_id=c.customer_id
GROUP BY c.customer_name ORDER BY total_orders DESC;

-- (5) Products never sold
SELECT product_id, product_name FROM Product
WHERE product_id NOT IN (SELECT DISTINCT product_id FROM SaleDetails);

-- (6) Sales joined with customer names
SELECT s.sale_id, s.sale_date, c.customer_name, s.total_amount
FROM Sales s INNER JOIN Customer c ON s.customer_id=c.customer_id;

-- (7) Same-category product pairs
SELECT a.product_name AS Product_A, b.product_name AS Product_B, a.category
FROM Product a JOIN Product b ON a.category=b.category AND a.product_id <> b.product_id;

-- ---------------------------------------------------------------------
-- 8️⃣ NORMALIZATION DEMO (UNF → 1NF → 2NF → 3NF)
-- ---------------------------------------------------------------------
DROP DATABASE IF EXISTS normalization_demo;
CREATE DATABASE normalization_demo;
USE normalization_demo;

-- 🔸 UNF: All products stored in one field
CREATE TABLE Sales_UNF(
 SaleID VARCHAR(10),
 CustomerName VARCHAR(100),
 CustomerCity VARCHAR(100),
 ProductList VARCHAR(255),
 TotalAmount DECIMAL(10,2)
);
INSERT INTO Sales_UNF VALUES
('S1','Amit Kumar','Angul','Rice-2-900, Sugar-1-250',2050),
('S2','Priya Singh','Angul','Oil-1-2300, Salt-5-20',2400);

-- 🔸 1NF: Repeating groups split into rows
CREATE TABLE Sales_1NF(
 SaleID VARCHAR(10),
 CustomerName VARCHAR(100),
 CustomerCity VARCHAR(100),
 ProductName VARCHAR(100),
 Quantity INT,
 UnitPrice DECIMAL(10,2),
 LineTotal DECIMAL(10,2)
);
INSERT INTO Sales_1NF VALUES
('S1','Amit Kumar','Angul','Rice',2,900,1800),
('S1','Amit Kumar','Angul','Sugar',1,250,250),
('S2','Priya Singh','Angul','Oil',1,2300,2300),
('S2','Priya Singh','Angul','Salt',5,20,100);

-- 🔸 2NF: Remove partial dependency (split details)
CREATE TABLE Sales_2NF(
 SaleID VARCHAR(10) PRIMARY KEY,
 CustomerName VARCHAR(100),
 CustomerCity VARCHAR(100),
 TotalAmount DECIMAL(10,2)
);
CREATE TABLE SaleDetails_2NF(
 SaleDetailID VARCHAR(10) PRIMARY KEY,
 SaleID VARCHAR(10),
 ProductName VARCHAR(100),
 Quantity INT,
 UnitPrice DECIMAL(10,2),
 LineTotal DECIMAL(10,2),
 FOREIGN KEY(SaleID) REFERENCES Sales_2NF(SaleID)
);
INSERT INTO Sales_2NF VALUES
('S1','Amit Kumar','Angul',2050),
('S2','Priya Singh','Angul',2400);
INSERT INTO SaleDetails_2NF VALUES
('SD1','S1','Rice',2,900,1800),
('SD2','S1','Sugar',1,250,250),
('SD3','S2','Oil',1,2300,2300),
('SD4','S2','Salt',5,20,100);

-- 🔸 3NF: Remove transitive dependency (separate Customer table)
CREATE TABLE Customer_3NF(
 CustomerID VARCHAR(10) PRIMARY KEY,
 CustomerName VARCHAR(100),
 CustomerCity VARCHAR(100)
);
CREATE TABLE Sales_3NF(
 SaleID VARCHAR(10) PRIMARY KEY,
 CustomerID VARCHAR(10),
 TotalAmount DECIMAL(10,2),
 FOREIGN KEY(CustomerID) REFERENCES Customer_3NF(CustomerID)
);
CREATE TABLE SaleDetails_3NF(
 SaleDetailID VARCHAR(10) PRIMARY KEY,
 SaleID VARCHAR(10),
 ProductName VARCHAR(100),
 Quantity INT,
 UnitPrice DECIMAL(10,2),
 LineTotal DECIMAL(10,2),
 FOREIGN KEY(SaleID) REFERENCES Sales_3NF(SaleID)
);

INSERT INTO Customer_3NF VALUES
('CUST1','Amit Kumar','Angul'),
('CUST2','Priya Singh','Angul');
INSERT INTO Sales_3NF VALUES
('S1','CUST1',2050),
('S2','CUST2',2400);
INSERT INTO SaleDetails_3NF VALUES
('SD1','S1','Rice',2,900,1800),
('SD2','S1','Sugar',1,250,250),
('SD3','S2','Oil',1,2300,2300),
('SD4','S2','Salt',5,20,100);

SELECT * FROM Customer_3NF;
SELECT * FROM Sales_3NF;
SELECT * FROM SaleDetails_3NF;
USE sales_stock_management;
SHOW TABLES;

ALTER TABLE Customer ADD COLUMN customer_type VARCHAR(20);

