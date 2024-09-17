import os

# Customer list: "name","phone number"
customers = [
    ("amnuay", "0955499819"),
    ("gorapin", "0955462893"),
    ("natnaree", "0955455848")
]

# Directory where Asterisk looks for call files
callfile_dir = "/var/spool/asterisk/outgoing/"

# Create call files for each customer
for customer in customers:
    name, phone = customer

    # Call file content
    callfile_content = f"""Channel: PJSIP/201/{phone}
CallerID: "{name}" <{phone}>
MaxRetries: 2
RetryTime: 1800  ; 1800 seconds = 30 minutes
WaitTime: 30     ; 30 seconds to wait for answer
Context: autodial
Extension: s
Priority: 1
"""

    # Call file path
    callfile_path = os.path.join(callfile_dir, f"{name}.call")

    # Write the call file
    with open(callfile_path, "w") as callfile:
        callfile.write(callfile_content)

    # Set permissions so Asterisk can access the call file
    os.chmod(callfile_path, 0o777)

print("Call files created successfully.")
