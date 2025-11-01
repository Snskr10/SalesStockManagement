# 📄 SQL Files Guide

## ✅ SQL Files That Should Be Included in GitHub

Your project **MUST** include SQL files so others can set up the database. Here's what you need:

### Required Files:

1. **`dashboard/schema.sql`** - **ESSENTIAL**
   - Contains all `CREATE TABLE` statements
   - Defines database structure
   - Creates all tables (Customer, Product, Sales, SaleDetails, Supplier, Invoices, etc.)
   - **This file is CRITICAL - without it, the app won't work!**

2. **Optional Seed Data Files:**
   - `dashboard/seed_products.sql` - Sample product data
   - `dashboard/seed_customers_more.sql` - Sample customer data
   - `dashboard/seed_2025_sales.sql` - Sample sales transactions

## 🔍 How to Find Your SQL Files

### If you have them in MySQL Workbench:
1. Open MySQL Workbench
2. File → Export → Export Structure and Data
3. Save as `schema.sql` in `dashboard/` folder

### If you created them manually:
Check these locations:
- MySQL Workbench saved scripts folder
- Your project folder (might be in a `sql/` subdirectory)
- Documents folder where you saved SQL scripts

### Creating schema.sql from your existing database:

**Option 1: Using MySQL Workbench**
```sql
-- In MySQL Workbench, go to Server → Data Export
-- Select database: sales_stock_management
-- Export to Dump Project Folder
-- Choose "Export to Dump Project Folder"
-- Save in: dashboard/schema.sql
```

**Option 2: Using Command Line (mysqldump)**
```bash
# Export structure only (recommended)
mysqldump -u root -p --no-data sales_stock_management > dashboard/schema.sql

# Or export structure + data (if you want sample data)
mysqldump -u root -p sales_stock_management > dashboard/schema.sql
```

**Option 3: Extract from your existing schema.sql**
If you have a `schema.sql` file from your initial setup, it should already be ready!

## ✅ Verification

Before committing to GitHub, verify:

1. **Check files exist:**
   ```bash
   cd dashboard
   dir *.sql    # Windows
   ls *.sql     # Linux/Mac
   ```

2. **Verify .gitignore doesn't exclude them:**
   - Open `.gitignore`
   - Make sure there's NO line like `*.sql` or `**/*.sql`
   - SQL files should NOT be ignored

3. **Check git status:**
   ```bash
   git status
   # Should show *.sql files as ready to commit
   ```

## 📝 What SQL Files Should Contain

### `schema.sql` should include:
- `CREATE DATABASE` statement (optional)
- All `CREATE TABLE` statements
- `CREATE VIEW` statements (if any)
- `CREATE TRIGGER` statements (if any)
- Foreign key constraints
- Indexes

### Example structure:
```sql
-- Schema for Sales Stock Management System
DROP DATABASE IF EXISTS sales_stock_management;
CREATE DATABASE sales_stock_management;
USE sales_stock_management;

CREATE TABLE Customer(
  customer_id VARCHAR(10) PRIMARY KEY,
  customer_name VARCHAR(100) NOT NULL,
  ...
);

CREATE TABLE Product(
  product_id VARCHAR(10) PRIMARY KEY,
  ...
);

-- ... more tables
```

## 🚨 Important Security Notes

✅ **SAFE to include:**
- Table structures (CREATE TABLE)
- Indexes and constraints
- Views and stored procedures
- Sample/dummy data

❌ **DO NOT include:**
- Real customer data with sensitive info
- Actual passwords or API keys
- Production data exports
- User account details

## 📦 Adding SQL Files to Git

Once you have your SQL files in `dashboard/`:

```bash
# Add SQL files
git add dashboard/*.sql

# Verify what will be committed
git status

# Commit
git commit -m "Add database schema and seed data SQL files"

# Push
git push
```

## 🎯 Quick Checklist

Before uploading to GitHub:
- [ ] `schema.sql` exists in `dashboard/` folder
- [ ] SQL files are NOT in `.gitignore`
- [ ] `git status` shows SQL files ready to commit
- [ ] Schema file contains all necessary tables
- [ ] Test that schema works: `mysql -u root -p < dashboard/schema.sql`

---

**Note**: Without `schema.sql`, other developers cannot set up the database, and your project won't be complete on GitHub! Make sure this file is included. 📄✅

