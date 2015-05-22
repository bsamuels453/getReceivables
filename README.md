# getReceivables
Shell script for use with OmegaFi and Google Sheets. Creates a spreadsheet with balances of all members.

This script creates a CSV file called receivables.csv in a user-specified directory, sorted by balance in descending order. In Google Sheets, one can insert the following into a cell, and the contents of the CSV file will be read into the spreadsheet:

=IMPORTDATA("http://www.yourwebsite.com/path/to/receivables.csv")

This script is designed to work on Mac OS X, Linux, Unix, and most any *nix operating system.

USAGE:
getReceivables.sh \<output directory\>

For autonomous script execution, don't forget to either insert your OmegaFi username and password in the appropriate section of the script, or export the environment variables "username" and "password" before running.
