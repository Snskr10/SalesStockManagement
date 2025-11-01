# 🏪 Swastik Variety Store - Sales & Stock Management System

A comprehensive billing and inventory management system built with Streamlit and MySQL, designed for retail store operations.

## 📋 Features

### 🛒 Billing System
- Real-time billing with automatic invoice generation
- Customer management with auto-creation for new customers
- Shopping cart functionality
- Automatic stock deduction
- PDF invoice generation

### 📊 Insights Dashboard
- Customer data management
- Product inventory tracking
- Sales history and analytics
- Sale details view
- Stock update functionality

### 📄 Invoice Management
- View all generated invoices
- Download invoice PDFs
- Track invoice history

### 📈 Analytics
- Sales analytics and reporting
- Product performance metrics
- Customer insights
- Same-category product pairing

### 📥 Bulk Data Import
- CSV import for Customer, Product, Sales, SaleDetails, and Supplier data
- Automatic data validation and type coercion
- Upsert functionality (insert or update)

## 🚀 Getting Started

### Prerequisites

- Python 3.8 or higher
- MySQL Server 5.7 or higher
- pip (Python package manager)

### Installation

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd "Sales Stock Management"
   ```

2. **Install Python dependencies**
   ```bash
   cd dashboard
   pip install -r requirements.txt
   ```

3. **Set up MySQL Database**

   - Create a MySQL database named `sales_stock_management`
   - Run the SQL schema file to create tables:
     ```bash
     cd dashboard
     mysql -u root -p sales_stock_management < schema.sql
     ```
   - (Optional) Load sample data if available:
     ```bash
     mysql -u root -p sales_stock_management < seed_products.sql
     mysql -u root -p sales_stock_management < seed_customers_more.sql
     mysql -u root -p sales_stock_management < seed_2025_sales.sql
     ```
   
   **Note**: Make sure `schema.sql` file exists in the `dashboard/` folder. This file contains all the database table structures and is required for the application to work.

4. **Configure Database Connection**

   Create a `.env` file in the `dashboard` directory:
   ```env
   DB_HOST=localhost
   DB_USER=root
   DB_PASSWORD=your_password_here
   DB_NAME=sales_stock_management
   ```

   Or modify the `get_connection()` function in `dashboard.py` with your credentials.

5. **Run the Application**
   ```bash
   cd dashboard
   streamlit run dashboard.py
   ```

6. **Access the Application**
   - Open your browser and navigate to `http://localhost:8501`

## 📁 Project Structure

```
Sales Stock Management/
│
├── dashboard/
│   ├── dashboard.py          # Main Streamlit application
│   ├── requirements.txt      # Python dependencies
│   ├── schema.sql            # Database schema
│   ├── seed_*.sql           # Sample data scripts
│   └── invoices/             # Generated PDF invoices
│
├── .gitignore                # Git ignore rules
├── README.md                 # This file
└── .env.example              # Environment variables template
```

## 🗄️ Database Schema

The system uses the following main tables:

- **Customer**: Customer information
- **Product**: Product inventory with stock tracking
- **Sales**: Sales transactions
- **SaleDetails**: Individual line items for each sale
- **Supplier**: Supplier information
- **Invoices**: Generated invoice records
- **Discounts**: Discount management
- **Users**: User accounts
- **ActivityLog**: Activity tracking
- **StockLogs**: Stock movement logs

## 🔧 Configuration

### Database Configuration

Edit the `get_connection()` function in `dashboard.py` or use environment variables:

```python
def get_connection():
    return mysql.connector.connect(
        host=os.getenv("DB_HOST", "localhost"),
        user=os.getenv("DB_USER", "root"),
        password=os.getenv("DB_PASSWORD", ""),
        database=os.getenv("DB_NAME", "sales_stock_management")
    )
```

## 📝 Usage Guide

### Creating a Bill

1. Navigate to **Billing** page
2. Search for an existing customer or add a new one
3. Select products and add quantities
4. Review cart and total
5. Select payment method and generate bill
6. Invoice PDF will be automatically generated

### Importing Data

1. Go to **Import** page
2. Upload CSV file
3. Select target table (Customer, Product, Sales, etc.)
4. Preview data
5. Confirm import

### Viewing Reports

- **Dashboard**: Overview metrics and recent sales
- **Insights**: Detailed views of customers, products, sales
- **Analytics**: Advanced analytics and reports
- **Invoices**: All generated invoices with download option

## 🛠️ Technologies Used

- **Frontend**: Streamlit
- **Backend**: Python
- **Database**: MySQL
- **Data Processing**: Pandas
- **PDF Generation**: ReportLab
- **Visualization**: Plotly

## 📄 License

This project is for educational and business use.

## 👤 Owner

**Bikash Kumar Agrawalla**  
📍 Angul, Odisha, India

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## 📞 Support

For issues or questions, please open an issue in the GitHub repository.

## 🔐 Security Note

- **Never commit `.env` file or database credentials to Git**
- Use environment variables for sensitive information
- Keep your database password secure
- Regularly backup your database

---

**Note**: This application is designed for a single-store operation. For multi-store or enterprise deployments, additional modifications may be required.

