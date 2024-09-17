#!/usr/bin/env python3
import sys
from asterisk.agi import AGI

def main():
    agi = AGI()

    # Log that the script started
    agi.verbose("AGI script started", 1)

    try:
        # Answer the call
        agi.answer()
        agi.verbose("Answered the call", 1)

        # Play a known sound file
        result = agi.stream_file('tt-monkeys')
        agi.verbose(f"Stream file result: {result}", 1)

        if result != 0:
            agi.verbose("Failed to play sound file", 1)
        else:
            agi.verbose("Successfully played sound file", 1)

    except Exception as e:
        # Catch any exceptions and log them
        agi.verbose(f"Error occurred: {str(e)}", 1)
    finally:
        # Ensure the call is hung up
        agi.hangup()
        agi.verbose("Hung up the call", 1)

if __name__ == '__main__':
    main()
