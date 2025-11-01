# 🚀 Setup Instructions

## Quick Setup Guide

### 1. Database Setup

1. **Create MySQL Database**
   ```sql
   CREATE DATABASE sales_stock_management;
   ```

2. **Run Schema Script**
   ```bash
   mysql -u root -p sales_stock_management < dashboard/schema.sql
   ```

3. **(Optional) Load Sample Data**
   ```bash
   mysql -u root -p sales_stock_management < dashboard/seed_products.sql
   mysql -u root -p sales_stock_management < dashboard/seed_customers_more.sql
   mysql -u root -p sales_stock_management < dashboard/seed_2025_sales.sql
   ```

### 2. Environment Configuration

**Option A: Using .env file (Recommended)**

1. Copy the example file:
   ```bash
   cd dashboard
   cp env.example .env
   ```

2. Edit `.env` with your database credentials:
   ```env
   DB_HOST=localhost
   DB_USER=root
   DB_PASSWORD=your_actual_password
   DB_NAME=sales_stock_management
   ```

**Option B: Using System Environment Variables**

Set these in your system:
- `DB_HOST`
- `DB_USER`
- `DB_PASSWORD`
- `DB_NAME`

**Option C: Manual Configuration**

Edit `dashboard.py` and update the `get_connection()` function directly (not recommended for production).

### 3. Install Dependencies

```bash
cd dashboard
pip install -r requirements.txt
```

### 4. Run the Application

```bash
cd dashboard
streamlit run dashboard.py
```

The application will open at `http://localhost:8501`

## 🔒 Security Best Practices

1. **Never commit `.env` files to Git**
   - The `.gitignore` file already excludes `.env`
   - Always use `env.example` as a template

2. **Use Strong Database Passwords**
   - Don't use default MySQL root password
   - Use a dedicated database user with limited privileges

3. **Restrict Database Access**
   - Only allow localhost connections in production
   - Use MySQL user permissions to limit access

## 🐛 Troubleshooting

### Database Connection Errors

- Verify MySQL is running: `mysql -u root -p`
- Check database exists: `SHOW DATABLES;`
- Verify credentials in `.env` or environment variables
- Check firewall settings if using remote database

### Import Errors

- Ensure all dependencies are installed: `pip install -r requirements.txt`
- Check Python version: `python --version` (needs 3.8+)
- Verify MySQL connector is working: `python -c "import mysql.connector"`

### Streamlit Issues

- Clear cache: `streamlit cache clear`
- Check port availability: Change port with `streamlit run dashboard.py --server.port 8502`
- Update Streamlit: `pip install --upgrade streamlit`

## 📝 Database User Setup (Optional - More Secure)

Instead of using root, create a dedicated database user:

```sql
CREATE USER 'store_app'@'localhost' IDENTIFIED BY 'strong_password_here';
GRANT ALL PRIVILEGES ON sales_stock_management.* TO 'store_app'@'localhost';
FLUSH PRIVILEGES;
```

Then use these credentials in your `.env` file.

## ✅ Verification

After setup, verify everything works:

1. Database connection: Application should load without errors
2. Dashboard metrics: Should show data if sample data was loaded
3. Billing page: Should be able to select products
4. Import page: Should show CSV upload interface

If all checks pass, you're ready to use the application! 🎉

