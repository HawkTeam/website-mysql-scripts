#!/bin/bash
# HackingTeam
# CarrotPlant LLC
# 2011
# Backup each mysql databases into a different file, rather than one big file
# Optionally files can be gzipped (dbname.gz)
#
# Usage: dump_all_databases [ -u username -o output_dir -z ]
#		 
#	-u username to connect mysql server
#	-o [output_dir] optional the output directory where to put the files
#	-z gzip enabled
#
# Note: The script will prompt for a password, you cannot specify it as command line argument for security reasons

PROG_NAME=$(basename $0)
USER="yourusername"
PASSWORD="yourpassword"
OUTPUTDIR="/data/backup/databases/"
GZIP_ENABLED=0
GZIP=""

MYSQLDUMP="/usr/bin/mysqldump"
MYSQL="/usr/bin/mysql"

while getopts u:o:z OPTION
do
    case ${OPTION} in
        u) USER=${OPTARG};;
        o) OUTPUTDIR=${OPTARG};;
        z) GZIP_ENABLED=1;;
        ?) echo "Usage: ${PROG_NAME} [ -u username -o output_dir -z ]"
           exit 2;;
    esac
done


# get a list of databases
databases=`$MYSQL --user=$USER --password=$PASSWORD -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema)"`

# dump each database in turn
for db in $databases; do
    echo $db
	if [ $GZIP_ENABLED == 1 ]; then
		$MYSQLDUMP --single-transaction --force --opt --user=$USER --password=$PASSWORD --databases $db | gzip > "$OUTPUTDIR/$db.gz"
	else
	    $MYSQLDUMP --force --opt --user=$USER --single-transaction --password=$PASSWORD --databases $db > "$OUTPUTDIR/$db.sql"
   	fi    
done

