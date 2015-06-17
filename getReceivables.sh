#!/bin/sh

outputDirectory="$1"
outputFile="$outputDirectory/receivables.csv"

authKey="ENTER YOUR SESSION TOKEN HERE"

curl -s -b FSSESSION_VAULT=$authKey --data "CustomMemberReportID=8052" \
"https://vault.omegafi.com/vault/ajax/services/billingandcollections/custom_member_report_results_get.php" > output

sed 's/<TR CLASS="/\'$'\n</g' < output > output2
tail -n+2 output2 > output3
head -n-2 output3 > output4
sed -e 's/<[^(>)]*>/,/g' < output4 > output5
sed -e 's/,,/,/g' < output5 > output6
sed -e 's/,//' < output6 > output7
cut -d , -f 1,2,4,5,6,7 output7 > output8
tac output8 > output9

chown nginx-usr output9
mv output9 $outputFile
