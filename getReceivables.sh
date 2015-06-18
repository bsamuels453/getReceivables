#!/bin/sh

USAGE="$0 <output directory>"
outputDirectory="$1"

if [ -z "$outputDirectory" ]
then
    echo "$USAGE" 2>&1
    exit 1
fi

outputFile="$outputDirectory/receivables.csv"

username="username"
password="password"

mkdir /tmp/receivables
tmpDir="/tmp/receivables"
cookiejar="$tmpDir/cookie.jar"

curl -s -b $cookiejar -c $cookiejar \
    -d "UserName=$username&Password=$password" \
    "https://my.omegafi.com/apps/myomegafi/login/login_post.php" 1 > /dev/null

curl -L -s -b $cookiejar -c $cookiejar \
    "https://my.omegafi.com/apps/myomegafi/login/sso_launcher.php?app=Vault" 1 > /dev/null

curl -s -b $cookiejar --data "CustomMemberReportID=8052" \
"https://vault.omegafi.com/vault/ajax/services/billingandcollections/custom_member_report_results_get.php" > $tmpDir/output

sed 's/<TR CLASS="/\'$'\n</g' < $tmpDir/output > $tmpDir/output2
tail -n+2 $tmpDir/output2 > $tmpDir/output3
head -n-1 $tmpDir/output3 > $tmpDir/output4
sed -e 's/,//g' $tmpDir/output4 > $tmpDir/commaless
sed -e 's/<[^(>)]*>/,/g' < $tmpDir/commaless > $tmpDir/output5
sed -e 's/,,/,/g' < $tmpDir/output5 > $tmpDir/output6
sed -e 's/,//' < $tmpDir/output6 > $tmpDir/output7
cut -d , -f 1,2,4,5,6,7 $tmpDir/output7 > $tmpDir/output8
tac $tmpDir/output8 > $tmpDir/output9

chown nginx-usr $tmpDir/output9
mv $tmpDir/output9 $outputFile

rm -rf $tmpDir
