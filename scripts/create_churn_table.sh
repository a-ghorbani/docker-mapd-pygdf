set -e
# Create table
cat ~/scripts/create_table_churn.sql | ~/mapd/bin/mapdql -p HyperInteractive
# Import CSV
echo "COPY churn_telco_table FROM '~/scripts/churn.txt';" | ~/mapd/bin/mapdql -p HyperInteractive
