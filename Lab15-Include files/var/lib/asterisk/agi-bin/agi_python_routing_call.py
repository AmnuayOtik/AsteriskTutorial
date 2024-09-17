#!/home/pyproject/venv/bin/python

import mysql.connector
import sys
from asterisk.agi import AGI

# Initialize AGI
agi = AGI()

# Get the customer_phone argument from the dialplan
customer_phone = sys.argv[1] if len(sys.argv) > 1 else None

# Database connection details
db_config = {
    'host': 'localhost',
    'user': 'root',
    'password': '1Qazxsw2!!',
    'database': 'call_routing'
}
# Function to send AGI command to Asterisk
def agi_command(command):
    sys.stdout.write(command + '\n')
    sys.stdout.flush()

def get_routing(customer_phone):
    try:
        # Connect to the database
        connection = mysql.connector.connect(**db_config)
        cursor = connection.cursor(dictionary=True)
        
        # Query to select customer phone and route_to_internal_ext
        query = "SELECT customer_phone, route_to_internal_ext FROM call_routing WHERE customer_phone = %s AND rec_status = '1'"
        cursor.execute(query, (customer_phone,))
        
        # Fetch the result
        result = cursor.fetchone()
        
        if result:
            customer_phone = result['customer_phone']
            route_to_internal_ext = result['route_to_internal_ext']
            return customer_phone, route_to_internal_ext
        else:
            return None, None

    except mysql.connector.Error as err:
        agi.verbose(f"Error: {err}")
        return None, None

    finally:
        if connection.is_connected():
            cursor.close()
            connection.close()

if customer_phone:
    # Get customer phone and route
    customer_phone, route_to_internal_ext = get_routing(customer_phone)

    if customer_phone and route_to_internal_ext:
        agi_command(f'SET VARIABLE agi_customer_phone_number "{customer_phone}"')
        agi_command(f'SET VARIABLE agi_route_to_internal_ext "{route_to_internal_ext}"')
        agi.verbose(f"Customer Phone: {customer_phone}, Route to Extension: {route_to_internal_ext}")
    else:
        agi.verbose("No routing found for this phone number.")
else:
    agi.verbose("No customer phone argument received.")
