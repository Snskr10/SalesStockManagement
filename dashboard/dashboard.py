import streamlit as st
import mysql.connector
import pandas as pd
import os
from datetime import datetime
from reportlab.lib.pagesizes import A4
from reportlab.pdfgen import canvas

# Load environment variables from .env file if it exists
try:
    from dotenv import load_dotenv
    load_dotenv()
except ImportError:
    pass  # python-dotenv not installed, use system environment variables

# ------------------ DATABASE CONNECTION ------------------
def get_connection():
    # Use environment variables if available, otherwise use defaults
    # For GitHub: Set these in your environment or .env file
    # NEVER commit actual passwords to Git!
    
    # Try to load from .env file first (for local development)
    db_password = os.getenv("DB_PASSWORD")
    
    # Fallback to hardcoded password ONLY if no env variable is set
    # This allows the app to work locally, but password won't be in Git
    # In production, always use environment variables!
    if not db_password:
        # Local development fallback - REMOVE THIS BEFORE DEPLOYING TO PRODUCTION
        db_password = "Saag@1001"  # Only used if .env file doesn't exist
    
    return mysql.connector.connect(
        host=os.getenv("DB_HOST", "localhost"),
        user=os.getenv("DB_USER", "root"),
        password=db_password,
        database=os.getenv("DB_NAME", "sales_stock_management")
    )

def get_metrics():
    conn = get_connection()
    cur = conn.cursor()

    cur.execute("SELECT SUM(total_amount) FROM Sales;")
    total_sales = cur.fetchone()[0] or 0   # ✅ safe fallback to 0

    cur.execute("SELECT COUNT(DISTINCT customer_id) FROM Customer;")
    total_customers = cur.fetchone()[0] or 0

    cur.execute("SELECT COUNT(DISTINCT product_id) FROM Product;")
    total_products = cur.fetchone()[0] or 0

    conn.close()
    return total_sales, total_customers, total_products

def generate_invoice_pdf(sale_id: str, pdf_path: str):
    """Generate invoice PDF for a sale"""
    conn = get_connection()
    # Fetch sale header and customer
    header = pd.read_sql(
        "SELECT s.sale_id, s.sale_date, s.total_amount, s.payment_method, c.customer_name, c.address, c.city, c.country "
        "FROM Sales s JOIN Customer c ON s.customer_id=c.customer_id WHERE s.sale_id=%s",
        conn,
        params=[sale_id]
    )
    if header.empty:
        conn.close()
        raise ValueError("Sale not found")
    # Fetch line items
    lines = pd.read_sql(
        "SELECT sd.product_id, p.product_name, sd.quantity, sd.unit_price, sd.total_price "
        "FROM SaleDetails sd JOIN Product p ON sd.product_id=p.product_id WHERE sd.sale_id=%s",
        conn,
        params=[sale_id]
    )
    conn.close()

    c = canvas.Canvas(pdf_path, pagesize=A4)
    width, height = A4
    y = height - 50
    c.setFont("Helvetica-Bold", 16)
    c.drawString(40, y, "Swastik Variety Store - Invoice")
    c.drawString(40, y - 20, "Owner: Bikash Kumar Agrawalla")
    y -= 25
    c.setFont("Helvetica", 10)
    c.drawString(40, y, f"Invoice Date: {datetime.now().strftime('%Y-%m-%d %H:%M')}")
    y -= 15
    row = header.iloc[0]
    c.drawString(40, y, f"Sale ID: {row['sale_id']}  |  Sale Date: {row['sale_date']}  |  Payment: {row['payment_method']}")
    y -= 20
    c.setFont("Helvetica-Bold", 12)
    c.drawString(40, y, "Bill To:")
    y -= 15
    c.setFont("Helvetica", 10)
    c.drawString(40, y, f"{row['customer_name']}")
    y -= 15
    c.drawString(40, y, f"{row['address']}, {row['city']}, {row['country']}")
    y -= 25
    c.setFont("Helvetica-Bold", 11)
    c.drawString(40, y, "Items")
    y -= 15
    c.setFont("Helvetica", 10)
    c.drawString(40, y, "Product")
    c.drawString(250, y, "Qty")
    c.drawString(300, y, "Unit Price")
    c.drawString(400, y, "Line Total")
    y -= 10
    c.line(40, y, 550, y)
    y -= 15
    total = 0.0
    if lines.empty:
        total = float(row['total_amount'] or 0)
        c.drawString(40, y, "(No line items available)")
        y -= 15
    else:
        for _, ln in lines.iterrows():
            if y < 100:
                c.showPage(); y = height - 50
            c.drawString(40, y, f"{ln['product_name']} ({ln['product_id']})")
            c.drawRightString(280, y, str(int(ln['quantity'])))
            c.drawRightString(380, y, f"{ln['unit_price']:.2f}")
            c.drawRightString(520, y, f"{ln['total_price']:.2f}")
            total += float(ln['total_price'] or 0)
            y -= 15
    y -= 10
    c.line(40, y, 550, y)
    y -= 20
    c.setFont("Helvetica-Bold", 12)
    c.drawRightString(520, y, f"Total: ₹ {total:.2f}")
    y -= 30
    c.setFont("Helvetica", 9)
    c.drawString(40, y, "Thank you for your business!")
    c.showPage()
    c.save()

st.set_page_config(
    page_title="Swastik Variety Store", 
    layout="wide",
    page_icon="🏪",
    initial_sidebar_state="expanded"
)

# Custom CSS for better UI
st.markdown("""
<style>
    /* Main styling */
    .main {
        padding: 2rem 1rem;
    }
    
    /* Header styling */
    .shop-header {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        padding: 2rem;
        border-radius: 15px;
        color: white;
        margin-bottom: 2rem;
        box-shadow: 0 4px 6px rgba(0,0,0,0.1);
    }
    
    .shop-title {
        font-size: 2.5rem;
        font-weight: bold;
        margin-bottom: 0.5rem;
    }
    
    .shop-subtitle {
        font-size: 1.1rem;
        opacity: 0.95;
    }
    
    /* Metric cards */
    .metric-card {
        background: white;
        padding: 1.5rem;
        border-radius: 12px;
        box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        border-left: 4px solid #667eea;
        margin-bottom: 1rem;
    }
    
    /* Buttons */
    .stButton > button {
        border-radius: 8px;
        font-weight: 600;
        transition: all 0.3s;
    }
    
    .stButton > button:hover {
        transform: translateY(-2px);
        box-shadow: 0 4px 8px rgba(0,0,0,0.2);
    }
    
    /* Sidebar */
    .css-1d391kg {
        padding-top: 3rem;
    }
    
    /* Cards */
    [data-testid="stMetricValue"] {
        font-size: 2rem;
    }
    
    /* Divider */
    hr {
        margin: 2rem 0;
    }
    
    /* Form styling */
    .stForm {
        border: 2px solid #e0e0e0;
        border-radius: 10px;
        padding: 1.5rem;
        background: #f9f9f9;
    }
    
    /* Success messages */
    .stSuccess {
        border-radius: 8px;
    }
</style>
""", unsafe_allow_html=True)

# ------------------ SIDEBAR ------------------
with st.sidebar:
    st.markdown("""
    <div style='text-align: center; padding: 1rem 0;'>
        <h1 style='color: #667eea; margin-bottom: 0.5rem;'>🏪 Swastik Variety Store</h1>
        <p style='color: #888; font-size: 0.85rem;'>Owner: Bikash Kumar Agrawalla</p>
        <p style='color: #888; font-size: 0.8rem;'>📍 Angul, Odisha</p>
    </div>
    """, unsafe_allow_html=True)
    
    st.divider()
    
    page = st.radio(
        "Navigate to",
        ["Dashboard", "Billing", "Insights", "Invoices", "Analytics", "Import"],
        label_visibility="collapsed"
    ) 

# ------------------ DASHBOARD ------------------
if page == "Dashboard":
    # Header
    st.markdown("""
    <div class="shop-header">
        <div class="shop-title">🏪 Swastik Variety Store</div>
        <div class="shop-subtitle">Owner: Bikash Kumar Agrawalla | 📍 Angul, Odisha | 📅 {}</div>
    </div>
    """.format(datetime.now().strftime("%B %d, %Y - %I:%M %p")), unsafe_allow_html=True)
    
    st.markdown("### 📊 Business Overview")

    conn = get_connection()
    total_customers = pd.read_sql("SELECT COUNT(*) FROM Customer", conn).iloc[0,0]
    total_products = pd.read_sql("SELECT COUNT(*) FROM Product", conn).iloc[0,0]
    total_sales = pd.read_sql("SELECT SUM(total_amount) FROM Sales", conn).iloc[0,0]

    # Metrics in styled cards
    c1, c2, c3 = st.columns(3)
    total_sales, total_customers, total_products = get_metrics()
    
    with c1:
        st.markdown("""
        <div style='background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 1.5rem; border-radius: 12px; color: white; text-align: center;'>
            <h3 style='margin: 0; font-size: 0.9rem; opacity: 0.9;'>💰 Total Revenue</h3>
            <h2 style='margin: 0.5rem 0 0 0; font-size: 2rem;'>₹ {}</h2>
        </div>
        """.format(f"{total_sales:,.2f}"), unsafe_allow_html=True)
    
    with c2:
        st.markdown("""
        <div style='background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%); padding: 1.5rem; border-radius: 12px; color: white; text-align: center;'>
            <h3 style='margin: 0; font-size: 0.9rem; opacity: 0.9;'>👥 Total Customers</h3>
            <h2 style='margin: 0.5rem 0 0 0; font-size: 2rem;'>{}</h2>
        </div>
        """.format(total_customers), unsafe_allow_html=True)
    
    with c3:
        st.markdown("""
        <div style='background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%); padding: 1.5rem; border-radius: 12px; color: white; text-align: center;'>
            <h3 style='margin: 0; font-size: 0.9rem; opacity: 0.9;'>📦 Total Products</h3>
            <h2 style='margin: 0.5rem 0 0 0; font-size: 2rem;'>{}</h2>
        </div>
        """.format(total_products), unsafe_allow_html=True)

    st.divider()
    st.markdown("### 📈 Recent Sales Activity")
    conn.close()

# ------------------ BILLING ------------------
elif page == "Billing":
    st.markdown("""
    <div class="shop-header">
        <div class="shop-title">💰 Point of Sale (POS)</div>
        <div class="shop-subtitle">Quick Billing System - Swastik Variety Store</div>
    </div>
    """, unsafe_allow_html=True)
    conn = get_connection()
    cursor = conn.cursor()

    # Initialize session state for cart
    if 'cart' not in st.session_state:
        st.session_state.cart = []
    if 'current_customer' not in st.session_state:
        st.session_state.current_customer = None
    
    # Billing interface with better layout
    col1, col2 = st.columns([1.2, 1])
    
    with col1:
        st.markdown("### 👤 Customer Details")
        st.markdown("---")
        
        # Show currently selected customer
        if st.session_state.current_customer:
            st.success(f"✅ **Current Customer:** {st.session_state.current_customer['customer_name']} ({st.session_state.current_customer['customer_id']})")
            if st.button("🔄 Change Customer"):
                st.session_state.current_customer = None
                st.rerun()
        
        # Search or create customer
        customer_search = st.text_input("🔍 Search Customer (Name or Phone)", key="cust_search", disabled=bool(st.session_state.current_customer))
        
        if customer_search and not st.session_state.current_customer:
            # Search existing customers
            customers_df = pd.read_sql(
                "SELECT customer_id, customer_name, phone, email, address FROM Customer WHERE customer_name LIKE %s OR phone LIKE %s LIMIT 10",
                conn,
                params=[f"%{customer_search}%", f"%{customer_search}%"]
            )
            if not customers_df.empty:
                customer_options = [f"{row['customer_name']} - {row['phone']} ({row['customer_id']})" for _, row in customers_df.iterrows()]
                selected_idx = st.selectbox("Select Customer", range(len(customer_options)), format_func=lambda x: customer_options[x])
                if st.button("✅ Select This Customer"):
                    selected_row = customers_df.iloc[selected_idx]
                    st.session_state.current_customer = selected_row.to_dict()
                    st.success(f"✅ Customer Selected: {st.session_state.current_customer['customer_name']}")
                    st.rerun()
            else:
                st.info("No customer found. Create new customer below.")
        
        # Create new customer
        with st.expander("➕ Add New Customer"):
            with st.form("new_customer_form"):
                new_cust_name = st.text_input("Customer Name *")
                new_cust_phone = st.text_input("Phone *")
                new_cust_email = st.text_input("Email")
                new_cust_address = st.text_input("Address", "Angul")
                new_cust_type = st.selectbox("Customer Type", ["Regular", "VIP", "Wholesale", "Retail"], index=0)
                new_cust_submit = st.form_submit_button("Add Customer")
                
                if new_cust_submit and new_cust_name and new_cust_phone:
                    # Generate customer ID
                    cursor.execute("SELECT MAX(CAST(SUBSTRING(customer_id, 5) AS UNSIGNED)) FROM Customer WHERE customer_id LIKE 'CUST%'")
                    result = cursor.fetchone()
                    next_num = (result[0] or 0) + 1
                    new_cust_id = f"CUST{next_num:04d}"
                    
                    try:
                        # Check if customer_type column exists in the table
                        cursor.execute("SHOW COLUMNS FROM Customer LIKE 'customer_type'")
                        has_customer_type = cursor.fetchone() is not None
                        
                        if has_customer_type:
                            cursor.execute(
                                "INSERT INTO Customer (customer_id, customer_name, email, phone, address, city, country, customer_type) VALUES (%s,%s,%s,%s,%s,%s,%s,%s)",
                                (new_cust_id, new_cust_name, new_cust_email or None, new_cust_phone, new_cust_address, "Angul", "India", new_cust_type)
                            )
                        else:
                            cursor.execute(
                                "INSERT INTO Customer (customer_id, customer_name, email, phone, address, city, country) VALUES (%s,%s,%s,%s,%s,%s,%s)",
                                (new_cust_id, new_cust_name, new_cust_email or None, new_cust_phone, new_cust_address, "Angul", "India")
                            )
                        conn.commit()
                        st.session_state.current_customer = {
                            'customer_id': new_cust_id,
                            'customer_name': new_cust_name,
                            'phone': new_cust_phone,
                            'email': new_cust_email,
                            'address': new_cust_address
                        }
                        st.success(f"✅ Customer {new_cust_name} added successfully!")
                        st.rerun()
                    except mysql.connector.Error as e:
                        st.error(f"Error: {e.msg}")
    
    with col2:
        st.markdown("### 📦 Products & Cart")
        st.markdown("---")
        
        # Get all products
        products_df = pd.read_sql(
            "SELECT product_id, product_name, unit_price, stock_quantity FROM Product WHERE stock_quantity > 0 ORDER BY product_name",
            conn
        )
        
        if not products_df.empty:
            product_options = {f"{row['product_name']} (₹{row['unit_price']:.2f})": row['product_id'] 
                             for _, row in products_df.iterrows()}
            selected_product_display = st.selectbox("Select Product", options=list(product_options.keys()))
            selected_product_id = product_options[selected_product_display]
            
            # Get product details
            product_row = products_df[products_df['product_id'] == selected_product_id].iloc[0]
            stock_qty = int(product_row.get('stock_quantity', 0))
            product_name = str(product_row.get('product_name', 'Unknown'))
            quantity = st.number_input("Quantity", min_value=1, max_value=stock_qty, value=1)
            
            if st.button("➕ Add to Cart"):
                unit_price = float(product_row.get('unit_price', 0))
                total_price = unit_price * quantity
                
                # Check if product already in cart
                existing_idx = next((i for i, item in enumerate(st.session_state.cart) if item['product_id'] == selected_product_id), None)
                if existing_idx is not None:
                    st.session_state.cart[existing_idx]['quantity'] += quantity
                    st.session_state.cart[existing_idx]['total_price'] = st.session_state.cart[existing_idx]['quantity'] * unit_price
                else:
                    st.session_state.cart.append({
                        'product_id': selected_product_id,
                        'product_name': product_name,
                        'quantity': quantity,
                        'unit_price': unit_price,
                        'total_price': total_price
                    })
                st.success(f"✅ Added {quantity} x {product_name}")
                st.rerun()
        else:
            st.warning("No products available in stock.")
    
    # Display Cart and Total
    st.divider()
    st.markdown("### 🛒 Current Order Summary")
    
    if st.session_state.current_customer:
        st.info(f"**Customer:** {st.session_state.current_customer['customer_name']} ({st.session_state.current_customer['customer_id']})")
    else:
        st.warning("⚠️ Please select or create a customer first!")
    
    if st.session_state.cart:
        cart_df = pd.DataFrame(st.session_state.cart)
        st.dataframe(cart_df[['product_name', 'quantity', 'unit_price', 'total_price']], use_container_width=True)
        
        grand_total = sum(item['total_price'] for item in st.session_state.cart)
        st.metric("💰 Total Amount", f"₹ {grand_total:,.2f}")
        
        # Payment method and finalize
        col3, col4 = st.columns(2)
        with col3:
            payment_method = st.selectbox("Payment Method", ["Cash", "UPI", "Card"])
        
        with col4:
            sale_date = st.date_input("Sale Date", value=datetime.now().date())
        
        if st.button("💳 Generate Bill & Invoice", type="primary", disabled=not st.session_state.current_customer):
            try:
                # Generate Sale ID
                cursor.execute("SELECT MAX(CAST(SUBSTRING(sale_id, 2) AS UNSIGNED)) FROM Sales WHERE sale_id LIKE 'S%'")
                result = cursor.fetchone()
                next_num = (result[0] or 0) + 1
                new_sale_id = f"S{next_num:03d}"
                
                # Insert Sale
                cursor.execute(
                    "INSERT INTO Sales (sale_id, sale_date, total_amount, payment_method, customer_id) VALUES (%s,%s,%s,%s,%s)",
                    (new_sale_id, sale_date, grand_total, payment_method, st.session_state.current_customer['customer_id'])
                )
                
                # Insert SaleDetails and update stock
                cursor.execute("SELECT MAX(CAST(SUBSTRING(sale_detail_id, 3) AS UNSIGNED)) FROM SaleDetails WHERE sale_detail_id LIKE 'SD%'")
                result = cursor.fetchone()
                next_sd_num = (result[0] or 0) + 1
                
                for item in st.session_state.cart:
                    sale_detail_id = f"SD{next_sd_num:04d}"
                    next_sd_num += 1
                    cursor.execute(
                        "INSERT INTO SaleDetails (sale_detail_id, sale_id, product_id, discount_id, quantity, unit_price, discount_applied, total_price) VALUES (%s,%s,%s,%s,%s,%s,%s,%s)",
                        (sale_detail_id, new_sale_id, item['product_id'], None, item['quantity'], item['unit_price'], 0, item['total_price'])
                    )
                    # Update stock
                    cursor.execute(
                        "UPDATE Product SET stock_quantity = stock_quantity - %s WHERE product_id = %s",
                        (item['quantity'], item['product_id'])
                    )
                
                conn.commit()
                
                # Generate Invoice
                invoices_dir = os.path.join(os.path.dirname(__file__), "invoices")
                os.makedirs(invoices_dir, exist_ok=True)
                invoice_id = f"INV_{new_sale_id}"
                pdf_path = os.path.join(invoices_dir, f"{invoice_id}.pdf")
                
                generate_invoice_pdf(new_sale_id, pdf_path)
                
                # Insert Invoice record
                cursor.execute(
                    "REPLACE INTO Invoices (invoice_id, invoice_date, total_amount, pdf_path, qr_code, sale_id) VALUES (%s, CURDATE(), %s, %s, %s, %s)",
                    (invoice_id, grand_total, pdf_path, invoice_id, new_sale_id)
                )
                conn.commit()
                
                st.success(f"✅ Bill Generated Successfully! Sale ID: {new_sale_id}")
                st.info(f"📄 Invoice Generated: {invoice_id}")
                
                # Show invoice download
                try:
                    with open(pdf_path, 'rb') as f:
                        st.download_button(
                            label="📥 Download Invoice PDF",
                            data=f.read(),
                            file_name=f"{invoice_id}.pdf",
                            mime="application/pdf"
                        )
                except Exception as e:
                    st.warning(f"Could not load PDF: {e}")
                
                # Clear cart and customer
                st.session_state.cart = []
                st.session_state.current_customer = None
                st.rerun()
                
            except mysql.connector.Error as e:
                st.error(f"Database error: {e.msg}")
                conn.rollback()
            except Exception as e:
                st.error(f"Error: {e}")
                conn.rollback()
        
        # Clear cart button
        if st.button("🗑️ Clear Cart"):
            st.session_state.cart = []
            st.rerun()
    else:
        st.info("🛒 Cart is empty. Add products to start billing.")
    
    conn.close()

# ------------------ INSIGHTS ------------------
elif page == "Insights":
    st.markdown("""
    <div class="shop-header">
        <div class="shop-title">📊 Data Insights & Records</div>
        <div class="shop-subtitle">View all your business data - Customers, Products, Sales</div>
    </div>
    """, unsafe_allow_html=True)
    
    tab1, tab2, tab3, tab4 = st.tabs(["👥 Customers", "📦 Products", "💸 Sales", "📋 Sale Details"])
    
    with tab1:
        st.subheader("Customer Data")
        conn = get_connection()
        df = pd.read_sql("SELECT * FROM Customer ORDER BY customer_name", conn)
        st.dataframe(df, use_container_width=True)
        conn.close()
    
    with tab2:
        st.subheader("Product Data")
        conn = get_connection()
        df = pd.read_sql("SELECT * FROM Product ORDER BY product_name", conn)
        st.dataframe(df, use_container_width=True)

    st.subheader("🔄 Update Product Stock")
    with st.form("update_stock"):
        pid_up = st.text_input("Product ID")
        new_stock = st.number_input("New Stock Quantity", min_value=0)
        if st.form_submit_button("Update Stock"):
            cursor = conn.cursor()
            cursor.execute("UPDATE Product SET stock_quantity=%s, updated_at=CURDATE() WHERE product_id=%s", (new_stock, pid_up))
            conn.commit()
            st.success("Stock updated successfully!")
            st.rerun()
    conn.close()
    
    with tab3:
        st.subheader("Sales Data")
        conn = get_connection()
        df = pd.read_sql(
            "SELECT s.sale_id, s.sale_date, c.customer_name, s.total_amount, s.payment_method FROM Sales s JOIN Customer c ON s.customer_id=c.customer_id ORDER BY s.sale_date DESC",
            conn
        )
        st.dataframe(df, use_container_width=True)
    conn.close()

    with tab4:
        st.subheader("Sale Details")
        conn = get_connection()
        df = pd.read_sql(
            "SELECT sd.*, p.product_name FROM SaleDetails sd JOIN Product p ON sd.product_id=p.product_id ORDER BY sd.sale_id DESC",
            conn
        )
        st.dataframe(df, use_container_width=True)
        conn.close()


# ------------------ ANALYTICS ------------------
elif page == "Analytics":
    st.markdown("""
    <div class="shop-header">
        <div class="shop-title">📈 Business Analytics</div>
        <div class="shop-subtitle">Sales Reports, Customer Insights & Performance Metrics</div>
    </div>
    """, unsafe_allow_html=True)
    conn = get_connection()

    col1, col2 = st.columns(2)

    with col1:
        st.subheader("Customers spending above average sale")
        if st.button("Run – Customer spend > avg"):
            q = (
                "SELECT c.customer_name, SUM(s.total_amount) AS total_spent "
                "FROM Sales s JOIN Customer c ON s.customer_id=c.customer_id "
                "GROUP BY c.customer_name "
                "HAVING SUM(s.total_amount)>(SELECT AVG(total_amount) FROM Sales)"
            )
            df = pd.read_sql(q, conn)
            st.dataframe(df)

        st.subheader("Top 5 products by revenue")
        if st.button("Run – Top products revenue"):
            q = (
                "SELECT p.product_name, SUM(sd.total_price) AS total_revenue "
                "FROM SaleDetails sd JOIN Product p ON sd.product_id=p.product_id "
                "GROUP BY p.product_name ORDER BY total_revenue DESC LIMIT 5"
            )
            df = pd.read_sql(q, conn)
            st.dataframe(df)

        st.subheader("Monthly sales totals")
        if st.button("Run – Monthly sales"):
            q = (
                "SELECT DATE_FORMAT(s.sale_date,'%Y-%m') AS Month, SUM(s.total_amount) AS Monthly_Sales "
                "FROM Sales s GROUP BY Month ORDER BY Month"
            )
            df = pd.read_sql(q, conn)
            st.dataframe(df)

    with col2:
        st.subheader("Customer orders summary")
        if st.button("Run – Orders summary"):
            q = (
                "SELECT c.customer_name, COUNT(s.sale_id) AS total_orders, SUM(s.total_amount) AS total_spent "
                "FROM Sales s JOIN Customer c ON s.customer_id=c.customer_id "
                "GROUP BY c.customer_name ORDER BY total_orders DESC"
            )
            df = pd.read_sql(q, conn)
            st.dataframe(df)

        st.subheader("Products never sold")
        if st.button("Run – Never sold products"):
            q = (
                "SELECT product_id, product_name FROM Product "
                "WHERE product_id NOT IN (SELECT DISTINCT product_id FROM SaleDetails)"
            )
            df = pd.read_sql(q, conn)
            st.dataframe(df)

        st.subheader("Sales with customer details")
        if st.button("Run – Sales join Customer"):
            q = (
                "SELECT s.sale_id, s.sale_date, c.customer_name, s.total_amount "
                "FROM Sales s INNER JOIN Customer c ON s.customer_id=c.customer_id"
            )
            df = pd.read_sql(q, conn)
            st.dataframe(df)

    st.subheader("Same-category product pairs")
    if st.button("Run – Same category pairs"):
        q = (
            "SELECT a.product_name AS Product_A, b.product_name AS Product_B, a.category "
            "FROM Product a JOIN Product b ON a.category=b.category AND a.product_id<>b.product_id"
        )
        df = pd.read_sql(q, conn)
        st.dataframe(df)

    st.subheader("Stored procedure & function")
    c = conn.cursor()
    if st.button("Run Procedure: ListLowStockProducts"):
        try:
            c.callproc('ListLowStockProducts')
            for result in c.stored_results():
                rows = result.fetchall()
                cols = result.column_names
                if rows:
                    st.dataframe(pd.DataFrame(rows, columns=cols))
                else:
                    st.info("No low stock alerts.")
        except mysql.connector.Error as e:
            st.error(f"Procedure error: {e.msg}")

    sale_id_for_fn = st.text_input("Enter Sale ID to compute total via function", key="fn_sale_id")
    if st.button("Run Function: GetTotalBySaleID"):
        try:
            df = pd.read_sql(
                "SELECT GetTotalBySaleID(%s) AS total",
                conn,
                params=[sale_id_for_fn]
            )
            st.write(df)
        except mysql.connector.Error as e:
            st.error(f"Function error: {e.msg}")

    conn.close()

# ------------------ INVOICES ------------------
elif page == "Invoices":
    st.markdown("""
    <div class="shop-header">
        <div class="shop-title">🧾 Invoice Management</div>
        <div class="shop-subtitle">Generate, View & Download Invoices</div>
    </div>
    """, unsafe_allow_html=True)
    invoices_dir = os.path.join(os.path.dirname(__file__), "invoices")
    os.makedirs(invoices_dir, exist_ok=True)

    conn = get_connection()
    st.subheader("Generate single invoice")
    sale_id_input = st.text_input("Sale ID", key="inv_sale_id")
    if st.button("Generate Invoice PDF"):
        try:
            invoice_id = f"INV_{sale_id_input}"
            pdf_path = os.path.join(invoices_dir, f"{invoice_id}.pdf")
            generate_invoice_pdf(sale_id_input, pdf_path)
            cursor = conn.cursor()
            cursor.execute(
                "REPLACE INTO Invoices (invoice_id, invoice_date, total_amount, pdf_path, qr_code, sale_id) VALUES (%s, CURDATE(), (SELECT total_amount FROM Sales WHERE sale_id=%s), %s, %s, %s)",
                (invoice_id, sale_id_input, pdf_path, invoice_id, sale_id_input)
            )
            conn.commit()
            st.success(f"Invoice generated: {pdf_path}")
        except Exception as e:
            st.error(f"Invoice generation failed: {e}")

    st.subheader("Generate invoices for all missing sales")
    if st.button("Generate All Missing"):
        try:
            df_missing = pd.read_sql(
                "SELECT s.sale_id FROM Sales s LEFT JOIN Invoices i ON s.sale_id=i.sale_id WHERE i.sale_id IS NULL",
                conn
            )
            count = 0
            for sale_id in df_missing['sale_id'].tolist():
                invoice_id = f"INV_{sale_id}"
                pdf_path = os.path.join(invoices_dir, f"{invoice_id}.pdf")
                generate_invoice_pdf(sale_id, pdf_path)
                cursor = conn.cursor()
                cursor.execute(
                    "REPLACE INTO Invoices (invoice_id, invoice_date, total_amount, pdf_path, qr_code, sale_id) VALUES (%s, CURDATE(), (SELECT total_amount FROM Sales WHERE sale_id=%s), %s, %s, %s)",
                    (invoice_id, sale_id, pdf_path, invoice_id, sale_id)
                )
                conn.commit()
                count += 1
            st.success(f"Generated {count} invoices.")
        except Exception as e:
            st.error(f"Bulk invoice generation failed: {e}")

    st.subheader("All invoices")
    try:
        inv_df = pd.read_sql("SELECT invoice_id, invoice_date, total_amount, pdf_path, sale_id FROM Invoices ORDER BY invoice_date DESC", conn)
        
        if not inv_df.empty:
            # Display table with download buttons integrated
            st.markdown("""
            <style>
            .invoice-table {
                width: 100%;
            }
            </style>
            """, unsafe_allow_html=True)
            
            # Create header
            cols = st.columns([1, 1, 1.5, 2, 1, 1.5])
            with cols[0]:
                st.write("**Invoice ID**")
            with cols[1]:
                st.write("**Invoice Date**")
            with cols[2]:
                st.write("**Total Amount**")
            with cols[3]:
                st.write("**PDF Path**")
            with cols[4]:
                st.write("**Sale ID**")
            with cols[5]:
                st.write("**Download**")
            
            st.divider()
            
            # Display each row with download button
            for idx, r in inv_df.iterrows():
                cols = st.columns([1, 1, 1.5, 2, 1, 1.5])
                with cols[0]:
                    st.write(r['invoice_id'])
                with cols[1]:
                    st.write(str(r['invoice_date']))
                with cols[2]:
                    st.write(f"₹ {float(r['total_amount']):,.2f}")
                with cols[3]:
                    st.write(str(r['pdf_path']))
                with cols[4]:
                    st.write(r['sale_id'])
                with cols[5]:
                    p = r['pdf_path']
                    try:
                        if os.path.exists(p):
                            with open(p, 'rb') as f:
                                st.download_button(
                                    label="📥 Download",
                                    data=f.read(),
                                    file_name=os.path.basename(p),
                                    mime="application/pdf",
                                    key=f"dl_{r['invoice_id']}_{idx}"
                                )
                        else:
                            st.warning("File not found")
                    except Exception as e:
                        st.error(f"Error: {str(e)[:30]}")
        else:
            st.info("No invoices found.")
            
    except mysql.connector.Error as e:
        st.error(f"Load invoices failed: {e.msg}")
    finally:
        conn.close()

# ------------------ IMPORT ------------------
elif page == "Import":
    st.markdown("""
    <div class="shop-header">
        <div class="shop-title">⬆️ Bulk Data Import</div>
        <div class="shop-subtitle">Upload CSV files to update your store data</div>
    </div>
    """, unsafe_allow_html=True)

    # Supported table metadata
    table_meta = {
        "Customer": {
            "pk": ["customer_id"],
            "columns": [
                "customer_id", "customer_name", "email", "phone", "address", "city", "country", "customer_type"
            ]
        },
        "Product": {
            "pk": ["product_id"],
            "columns": [
                "product_id", "product_name", "category", "unit_price", "stock_quantity",
                "reorder_level", "created_at", "updated_at", "supplier_id"
            ]
        },
        "Sales": {
            "pk": ["sale_id"],
            "columns": [
                "sale_id", "sale_date", "total_amount", "payment_method", "customer_id"
            ]
        },
        "SaleDetails": {
            "pk": ["sale_detail_id"],
            "columns": [
                "sale_detail_id", "sale_id", "product_id", "discount_id", "quantity",
                "unit_price", "discount_applied", "total_price"
            ]
        },
        "Supplier": {
            "pk": ["supplier_id"],
            "columns": [
                "supplier_id", "supplier_name", "contact_name", "phone", "email",
                "address", "city", "country"
            ]
        }
    }

    selected_table = st.selectbox("Target table", list(table_meta.keys()))
    file = st.file_uploader("Choose CSV file", type=["csv"]) 

    if file is not None:
        try:
            # Read CSV, treating empty strings as NaN which we'll convert to None later
            df_raw = pd.read_csv(file, na_values=['', ' ', 'nan', 'NaN', 'NULL', 'null'], keep_default_na=True)
            # Clean column names: strip whitespace and filter out invalid columns
            df_raw.columns = df_raw.columns.str.strip()
            # Convert column names to strings and filter out invalid ones
            cleaned_cols = []
            for col in df_raw.columns:
                col_str = str(col) if col is not None else ''
                # Skip invalid column names
                if (col_str.lower() not in ['nan', 'none', ''] and 
                    not col_str.startswith('Unnamed') and 
                    col_str != '' and 
                    pd.notna(col)):
                    cleaned_cols.append(col_str)
            
            # Keep only valid columns
            df_raw = df_raw[cleaned_cols] if cleaned_cols else pd.DataFrame()
            
            st.subheader("Preview")
            st.dataframe(df_raw.head(50))
            st.caption(f"Rows: {len(df_raw)} | Columns: {list(df_raw.columns)}")
            meta = table_meta[selected_table]
            allowed_cols = meta["columns"]
            pk_cols = meta["pk"]
            # Only include columns that exist in both CSV and allowed columns
            present_cols = [c for c in df_raw.columns if c in allowed_cols and pd.notna(c) and str(c).lower() != 'nan']
            missing_pk = [c for c in pk_cols if c not in present_cols]
            if missing_pk:
                st.error(f"Missing required primary key columns for {selected_table}: {missing_pk}")
            else:
                st.info(f"Detected columns mapped to {selected_table}: {present_cols}")
                if st.button("Upsert into database"):
                    conn = get_connection()
                    cur = conn.cursor()

                    # Type coercion helpers
                    def coerce_types(df: pd.DataFrame, table: str) -> pd.DataFrame:
                        out = df.copy()
                        if table == "Product":
                            for c in ["unit_price"]:
                                if c in out.columns:
                                    out[c] = pd.to_numeric(out[c], errors="coerce")
                            for c in ["stock_quantity", "reorder_level"]:
                                if c in out.columns:
                                    out[c] = pd.to_numeric(out[c], errors="coerce").astype("Int64")
                            for c in ["created_at", "updated_at"]:
                                if c in out.columns:
                                    out[c] = pd.to_datetime(out[c], errors="coerce").dt.date
                        elif table == "Customer":
                            pass
                        elif table == "Sales":
                            if "sale_date" in out.columns:
                                out["sale_date"] = pd.to_datetime(out["sale_date"], errors="coerce").dt.date
                            for c in ["total_amount"]:
                                if c in out.columns:
                                    out[c] = pd.to_numeric(out[c], errors="coerce")
                        elif table == "SaleDetails":
                            for c in ["quantity"]:
                                if c in out.columns:
                                    out[c] = pd.to_numeric(out[c], errors="coerce").astype("Int64")
                            for c in ["unit_price", "discount_applied", "total_price"]:
                                if c in out.columns:
                                    out[c] = pd.to_numeric(out[c], errors="coerce")
                        elif table == "Supplier":
                            # Supplier has no date or numeric columns that need conversion
                            pass
                        return out

                    if not present_cols:
                        st.error("No valid columns found in CSV that match the selected table columns.")
                    else:
                        df = coerce_types(df_raw[present_cols], selected_table)
                        # Replace empty strings with None for optional fields
                        # For SaleDetails, discount_id can be empty
                        if selected_table == "SaleDetails" and "discount_id" in df.columns:
                            df["discount_id"] = df["discount_id"].replace(['', ' ', None], None)
                        # Replace NaN, NaT, and other null values with None for DB
                        df = df.replace({pd.NA: None, pd.NaT: None})
                        df = df.replace('', None)  # Replace empty strings with None
                        df = df.where(pd.notnull(df), None)  # Replace NaN with None for DB
                        
                        # Ensure all column names are strings and valid - filter more aggressively
                        valid_cols = []
                        for c in present_cols:
                            c_str = str(c) if c is not None else ''
                            c_lower = c_str.lower().strip()
                            # Only add if it's a valid column name
                            if (c_lower not in ['nan', 'none', ''] and 
                                not c_lower.startswith('unnamed') and 
                                c_str != '' and 
                                pd.notna(c) and
                                c_str in df.columns):
                                valid_cols.append(c_str)
                        
                        if not valid_cols:
                            st.error("No valid columns found after filtering. Please check your CSV column names.")
                            cur.close()
                            conn.close()
                        else:
                            cols_sql = ", ".join([f"`{c}`" for c in valid_cols])
                            placeholders = ", ".join(["%s"] * len(valid_cols))
                            update_assign = ", ".join([f"`{c}`=VALUES(`{c}`)" for c in valid_cols if c not in pk_cols])
                            insert_sql = f"INSERT INTO {selected_table} ({cols_sql}) VALUES ({placeholders})"
                            if update_assign:
                                insert_sql += f" ON DUPLICATE KEY UPDATE {update_assign}"
                            
                            # Show SQL for debugging (optional - can be removed)
                            st.code(f"SQL: {insert_sql[:200]}...", language="sql")

                            # Create batch, ensuring empty strings become None
                            batch = []
                            for _, row in df.iterrows():
                                batch_row = []
                                for c in valid_cols:
                                    val = row.get(c, None) if c in row else None
                                    # Convert empty strings, NaN, and None to None
                                    if pd.isna(val) or val == '' or (isinstance(val, str) and val.strip() == ''):
                                        val = None
                                    batch_row.append(val)
                                batch.append(tuple(batch_row))
                            try:
                                cur.executemany(insert_sql, batch)
                                conn.commit()
                                st.success(f"Upsert complete ✅ Rows processed: {len(batch)}")
                            except mysql.connector.Error as e:
                                st.error(f"Database error: {e.msg}")
                                st.code(f"SQL: {insert_sql}", language="sql")
                            finally:
                                cur.close()
                                conn.close()
        except Exception as e:
            st.error(f"Failed to read/process CSV: {e}")

