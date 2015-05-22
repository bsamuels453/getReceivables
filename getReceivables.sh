#!/bin/bash
# getReceivables.sh
# By Joseph LeGarreta
# Updated 5/22/15

# If $TMPDIR does not exist, set it to $HOME/tmp and create directory if necessary
if [ -z "$TMPDIR" ]
then
	TMPDIR="$HOME/tmp"
	# Create tmp in home directory if one does not exist
	if [ ! -e "$HOME/tmp" ]
	then
		mkdir "$HOME/tmp"
	fi
fi

# Create a temp dir
scriptTmpDir=$(mktemp -d -t GetReceivables.XXX)

trap "rm -rf $scriptTmpDir" EXIT HUP INT QUIT PIPE TERM

USAGE="$0 <output directory>"

while getopts "h" opt
do
	case $opt in
		h)
			echo "$USAGE" 2>&1
			exit 1
		;;
		*)
			echo "$USAGE" 2>&1
			exit 1
		;;
	esac
done

outputDirectory="$1"

if [ -z "$outputDirectory" ]
then
	echo "$USAGE" 2>&1
	exit 1
fi

if [ ! -e "$outputDirectory" ]
then
	echo "$0: $outputDirectory: No such file or directory" 1>&2
	exit 1
fi

# Set reverse command based on operating system
if uname | grep -i -q -e "Darwin"
then
	reverse='tail -r'
else
	reverse='tac'
fi

# For autonomous authentication, uncomment and enter your username/password here, or export the username and password environment variables
# username=foo
# password=bar

# If no username/password set, prompt user
if [ -z $username ]
then
	read -p "username: " username
elif [ -z $password ]
then
	read -s -p "password: " password
fi

if [ -z $username ] || [ -z $password ]
then
	echo "$0: Please set username and password environment variables" 1>&2
fi

cookieJar="$scriptTmpDir/cookie.jar"
outputFile="$outputDirectory/receivables.csv"

# Log in
curl -s -k -b $cookieJar -c $cookieJar -d "UserName=$username&Password=$password" "https://www.omegafi.com/apps/chapterdesktop/templates/login_post.php" 1>/dev/null

# Get report
curl -s -k -b $cookieJar -c $cookieJar -d "DisplayFields[0]=CurrentBalance\
&DisplayFields[1]=CellPhone\
&MemberTypes[0]=Active\
&MemberTypes[1]=Active Alumni\
&MemberTypes[2]=Delta Omicron 12 mon\
&MemberTypes[3]=Fall 2013 New Member\
&MemberTypes[4]=Live In A\
&MemberTypes[5]=Live In B\
&MemberTypes[6]=Past Debtor\
&MemberTypes[7]=President\
&InActive=0\
&SortOrder1=CurrentBalance" "https://www.omegafi.com/apps/chapterdesktop/templates/report_customreportview_csv.php" | sed 's/","/	/g;s/[",]//g;s/	/,/g' | cut -d , -f 1,2,5 | tail -n+2 | $reverse > "$outputFile"