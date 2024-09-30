import os
from faker import Faker
import pandas as pd
import random
import numpy as np
from datetime import timedelta
import geopy.distance

# Initialize the Faker object with Australian locale
fake = Faker('en_AU')

# Set the seed for reproducibility
Faker.seed(42)
random.seed(42)
np.random.seed(42)

# Define Australian states and their approximate geographic coordinates (latitude, longitude)
australian_states = {
    "New South Wales": {"latitude": -33.8688, "longitude": 151.2093},
    "Victoria": {"latitude": -37.8136, "longitude": 144.9631},
    "Queensland": {"latitude": -27.4698, "longitude": 153.0251},
    "Western Australia": {"latitude": -31.9505, "longitude": 115.8605},
    "South Australia": {"latitude": -34.9285, "longitude": 138.6007},
    "Tasmania": {"latitude": -42.8821, "longitude": 147.3272},
    "Australian Capital Territory": {"latitude": -35.2809, "longitude": 149.1300},
    "Northern Territory": {"latitude": -12.4634, "longitude": 130.8456}
}

# Define Shipping Companies
shipping_companies = ["Australia Post", "FedEx", "DHL", "Toll", "Sendle"]

# Define Product Categories
product_categories = ["Electronics", "Apparel", "Furniture", "Food", "Toys", "Books", "Beauty", "Sports"]

# Define Payment Methods
payment_methods = ["Credit Card", "PayPal", "Bank Transfer", "Afterpay"]

# Define Order Statuses
order_statuses = ["Shipped", "Processing", "Cancelled", "Returned"]

# Define Return Status
return_statuses = ["Returned", "Not Returned"]

# Define Loyalty Tiers
loyalty_tiers = ["Bronze", "Silver", "Gold", "Platinum"]

# Define Employee Departments
employee_departments = ["Sales", "Logistics", "Customer Support", "IT", "HR"]

# Define Order Priorities
order_priorities = ["High", "Medium", "Low"]

# Define Modes of Transportation
modes_of_transportation = ["Air", "Sea", "Road", "Rail"]

# Generate Customers Table
def generate_customers(num_customers=1000):
    customers = []
    for _ in range(num_customers):
        state = random.choice(list(australian_states.keys()))
        customer = {
            "CustomerID": fake.unique.random_number(digits=5),
            "CustomerName": fake.name(),
            "CustomerEmail": fake.email(),
            "CustomerPhoneNumber": fake.phone_number(),
            "Address": fake.street_address(),
            "City": fake.city(),
            "State": state,
            "PostalCode": fake.postcode(),
            "Latitude": australian_states[state]["latitude"] + random.uniform(-0.1, 0.1),
            "Longitude": australian_states[state]["longitude"] + random.uniform(-0.1, 0.1),
            "CustomerLoyaltyTier": random.choice(loyalty_tiers)
        }
        customers.append(customer)
    df_customers = pd.DataFrame(customers)
    
    return df_customers

# Generate Products Table
def generate_products(num_products=500):
    products = []
    for _ in range(num_products):
        product = {
            "ProductID": fake.unique.random_number(digits=7),
            "ProductName": fake.word().capitalize(),
            "ProductCategory": random.choice(product_categories),
            "UnitPrice": round(random.uniform(5, 500), 2),
            "OrderWeight": round(random.uniform(0.1, 20.0), 2)  # in kg
        }
        products.append(product)
    df_products = pd.DataFrame(products)
    
    return df_products

# Generate Employees Table
def generate_employees(num_employees=100):
    employees = []
    for _ in range(num_employees):
        department = random.choice(employee_departments)
        employee = {
            "EmployeeID": fake.unique.random_number(digits=4),
            "EmployeeName": fake.name(),
            "EmployeeEmail": fake.email(),
            "EmployeeDepartment": department
        }
        employees.append(employee)
    df_employees = pd.DataFrame(employees)
    
    return df_employees

# Generate Warehouses Table
def generate_warehouses(num_warehouses=10):
    warehouses = []
    for _ in range(num_warehouses):
        state = random.choice(list(australian_states.keys()))
        warehouse = {
            "WarehouseID": fake.unique.random_number(digits=4),
            "WarehouseName": fake.company(),
            "State": state,
            "City": fake.city(),
            "PostalCode": fake.postcode(),
            "Latitude": australian_states[state]["latitude"] + random.uniform(-0.2, 0.2),
            "Longitude": australian_states[state]["longitude"] + random.uniform(-0.2, 0.2)
        }
        warehouses.append(warehouse)
    df_warehouses = pd.DataFrame(warehouses)
    
    return df_warehouses

# Generate Shipping Companies Table
def generate_shipping_companies():
    shipping = []
    for idx, company in enumerate(shipping_companies, start=1):
        shipping_company = {
            "ShippingCompanyID": idx,
            "ShippingCompanyName": company,
            "CarrierPerformance": round(random.uniform(0.5, 5.0), 2)
        }
        shipping.append(shipping_company)
    df_shipping = pd.DataFrame(shipping)
    
    return df_shipping

# Function to calculate fluctuating fuel charge
def calculate_fuel_charge(distance, mode_of_transportation):
    base_charge = random.uniform(1, 3)  # Base fuel charge rate per kilometer
    if mode_of_transportation == "Air":
        return round(base_charge * distance * random.uniform(1.2, 1.5), 2)
    elif mode_of_transportation == "Sea":
        return round(base_charge * distance * random.uniform(0.8, 1.0), 2)
    elif mode_of_transportation == "Road":
        return round(base_charge * distance * random.uniform(1.0, 1.2), 2)
    elif mode_of_transportation == "Rail":
        return round(base_charge * distance * random.uniform(0.9, 1.1), 2)

# Generate Orders and OrderDetails Tables
def generate_orders(num_orders=1000000, df_customers=None, df_products=None, df_warehouses=None, df_shipping=None, df_employees=None, batch_size=100000):
    """Generate orders and order details for a given number of orders in batches."""
    orders = []
    order_details = []
    
    # Process in batches if necessary
    for batch in range(num_orders // batch_size):
        print(f"Generating batch {batch + 1} of orders...")
        for _ in range(batch_size):
            customer = df_customers.sample(1).iloc[0]
            product = df_products.sample(1).iloc[0]
            warehouse = df_warehouses.sample(1).iloc[0]
            shipping_company = df_shipping.sample(1).iloc[0]
            employee = df_employees.sample(1).iloc[0]
            
            order_date = fake.date_between(start_date='-4y', end_date='today')
            shipped_date = order_date + timedelta(days=random.randint(0, 5)) if random.random() > 0.1 else None  # 10% not shipped
            delivery_date = shipped_date + timedelta(days=random.randint(1, 10)) if shipped_date else None
            if delivery_date and delivery_date < shipped_date:
                delivery_date = shipped_date + timedelta(days=random.randint(-2, 10))
            
            distance = geopy.distance.distance(
                (warehouse["Latitude"], warehouse["Longitude"]),
                (customer["Latitude"], customer["Longitude"])
            ).km
            
            mode_of_transport = random.choice(modes_of_transportation)
            fuel_charge = calculate_fuel_charge(distance, mode_of_transport)
            
            order = {
                "OrderID": fake.unique.random_number(digits=8),
                "CustomerID": customer["CustomerID"],
                "EmployeeID": employee["EmployeeID"],
                "WarehouseID": warehouse["WarehouseID"],
                "ShippingCompanyID": shipping_company["ShippingCompanyID"],
                "ModeOfTransportation": mode_of_transport,
                "FuelCharge": fuel_charge,
                "OrderDate": order_date,
                "ShippedDate": shipped_date,
                "DeliveryDate": delivery_date,
                "OrderPriority": random.choice(order_priorities),
                "PaymentMethod": random.choice(payment_methods),
                "OrderStatus": random.choice(order_statuses),
                "ReturnStatus": random.choice(return_statuses),
                "FeedbackScore": random.randint(1, 5),
                "FraudulentTransaction": random.choice([True, False])
            }
            orders.append(order)
            
            num_products = random.randint(1, 3)
            for _ in range(num_products):
                quantity = random.randint(1, 5)
                unit_price = product["UnitPrice"] if random.random() > 0.01 else product["UnitPrice"] * 10
                order_detail = {
                    "OrderDetailID": fake.unique.random_number(digits=9),
                    "OrderID": order["OrderID"],
                    "ProductID": product["ProductID"],
                    "Quantity": quantity if random.random() > 0.02 else -quantity,
                    "UnitPrice": unit_price,
                    "Discount": round(random.uniform(0, 0.3), 2) if random.random() > 0.7 else None
                }
                order_details.append(order_detail)
    
    df_orders = pd.DataFrame(orders)
    df_order_details = pd.DataFrame(order_details)
    
    # Convert OrderDate, ShippedDate, and DeliveryDate to datetime format
    df_orders['OrderDate'] = pd.to_datetime(df_orders['OrderDate'])
    df_orders['ShippedDate'] = pd.to_datetime(df_orders['ShippedDate'])
    df_orders['DeliveryDate'] = pd.to_datetime(df_orders['DeliveryDate'])
    
    # Calculate DeliveryTime and Delay in Orders
    df_orders["DeliveryTime_Days"] = (df_orders["DeliveryDate"] - df_orders["OrderDate"]).dt.days
    df_orders["Delay_Days"] = (df_orders["ShippedDate"] - df_orders["OrderDate"]).dt.days
    
    return df_orders, df_order_details

# Folder for saving files
save_folder = 'output_data_large'  # Specify your folder here

# Create folder if it doesn't exist
if not os.path.exists(save_folder):
    os.makedirs(save_folder)

# Generate all tables
print("Generating Customers...")
df_customers = generate_customers(num_customers=1000)

print("Generating Products...")
df_products = generate_products(num_products=500)

print("Generating Employees...")
df_employees = generate_employees(num_employees=100)

print("Generating Warehouses...")
df_warehouses = generate_warehouses(num_warehouses=10)

print("Generating Shipping Companies...")
df_shipping = generate_shipping_companies()

print("Generating Orders and Order Details...")
df_orders, df_order_details = generate_orders(num_orders=1000000, df_customers=df_customers, df_products=df_products, df_warehouses=df_warehouses, df_shipping=df_shipping, df_employees=df_employees)

# Calculate TotalPrice in OrderDetails
df_order_details["TotalPrice"] = df_order_details["Quantity"] * df_order_details["UnitPrice"]

# Save to CSV files in the folder
print(f"Saving to CSV files in {save_folder}...")
df_customers.to_csv(f'{save_folder}/customers.csv', index=False)
df_products.to_csv(f'{save_folder}/products.csv', index=False)
df_employees.to_csv(f'{save_folder}/employees.csv', index=False)
df_warehouses.to_csv(f'{save_folder}/warehouses.csv', index=False)
df_shipping.to_csv(f'{save_folder}/shipping_companies.csv', index=False)
df_orders.to_csv(f'{save_folder}/orders.csv', index=False)
df_order_details.to_csv(f'{save_folder}/order_details.csv', index=False)

print("Data generation complete! Files saved as CSVs.")
