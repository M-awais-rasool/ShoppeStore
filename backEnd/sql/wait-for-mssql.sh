#!/bin/bash
# Wait for SQL Server to be ready
echo "Waiting for SQL Server to be available..."
until /opt/mssql-tools/bin/sqlcmd -S mssql -U SA -P Strong@Password123 -Q "SELECT 1" &>/dev/null
do
  sleep 2
done

# Run the initialization script
echo "Running init.sql..."
/opt/mssql-tools/bin/sqlcmd -S mssql -U SA -P Strong@Password123 -i /sql/init.sql
