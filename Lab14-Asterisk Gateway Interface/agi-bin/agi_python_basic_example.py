#!/usr/bin/env python3

import sys
import datetime

# Function to send AGI command to Asterisk
def agi_command(command):
    sys.stdout.write(command + '\n')
    sys.stdout.flush()

# Get the current date and time
now = datetime.datetime.now()
current_date = now.strftime("%Y-%m-%d")
current_time = now.strftime("%H:%M:%S")

# Send AGI command to set the date and time as Asterisk variables
agi_command(f'SET VARIABLE agi_date "{current_date}"')
agi_command(f'SET VARIABLE agi_time "{current_time}"')

# Send a VERBOSE message for debugging
agi_command(f'VERBOSE "Date: {current_date}, Time: {current_time}" 1')

# End the AGI script
#agi_command('HANGUP')
