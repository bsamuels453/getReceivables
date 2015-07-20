#!/bin/bash

USAGE="$0 <output directory>"
outputDirectory="$1"

if [ -z "$outputDirectory" ]
then
    echo "$USAGE" 2>&1
    exit 1
fi

outputFile="$outputDirectory/receivables.csv"

username="enterusername"
password="enterpasswd"

tmpDir="/tmp/receivables"

if [ -d "$tmpDir" ]; then
	rm -rf $tmpDir
fi

mkdir $tmpDir
cookiejar="$tmpDir/cookie.jar"

errors=0

curl  -b -s -o /dev/null -w "%{http_code}"  $cookiejar -c $cookiejar \
    -d "UserName=$username&Password=$password" \
    "https://my.omegafi.com/apps/myomegafi/login/login_post.php" | tail -n 1 > $tmpDir/httpcode1 
let "errors += $?"

curl -s -o /dev/null -w "%{http_code}" -L -b $cookiejar -c $cookiejar \
    "https://my.omegafi.com/apps/myomegafi/login/sso_launcher.php?app=Vault" | tail -n 1 > $tmpDir/httpcode2
let "errors += $?"

curl -s -b $cookiejar --data "CustomMemberReportID=8052" \
 "https://vault.omegafi.com/vault/ajax/services/billingandcollections/custom_member_report_results_get.php" > $tmpDir/output
let "errors += $?"

httpcode1=$(cat $tmpDir/httpcode1)
httpcode2=$(cat $tmpDir/httpcode2)

if [ "$httpcode1" == "000302" ] && [ "$httpcode2" == "200" ] && [ "$errors" == "0" ]; then
	sed 's/<TR CLASS="/\'$'\n</g' < $tmpDir/output > $tmpDir/output2
	tail -n+2 $tmpDir/output2 > $tmpDir/output3
	head -n-1 $tmpDir/output3 > $tmpDir/output4
	sed -e 's/,//g' $tmpDir/output4 > $tmpDir/commaless
	sed -e 's/<[^(>)]*>/,/g' < $tmpDir/commaless > $tmpDir/output5
	sed -e 's/,,/,/g' < $tmpDir/output5 > $tmpDir/output6
	sed -e 's/,//' < $tmpDir/output6 > $tmpDir/output7
	cut -d , -f 1,2,4,6,7 $tmpDir/output7 > $tmpDir/output8
	tac $tmpDir/output8 > $tmpDir/output9

	chown nginx-usr $tmpDir/output9
	mv $tmpDir/output9 $outputFile
	echo "$(date)" > $tmpDir/lastUpdated.csv
	chown nginx-usr $tmpDir/lastUpdated.csv
	mv $tmpDir/lastUpdated.csv $outputDirectory/lastUpdated.csv
else
	echo "failed"
	echo "Subject:Receivables spreadsheet update failed\n" > $tmpDir/emailhead
	ssmtp bsamuels453@gmail.com < $tmpDir/email
fi

rm -rf $tmpDir
