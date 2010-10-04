#!/bin/sh
#
#  Taginfo Master DB
#
#  update.sh DIR
#

set -e

DIR=$1

if [ "x" = "x$DIR" ]; then
    echo "Usage: update.sh DIR"
    exit 1
fi

echo -n "Start master: "; date

DATABASE=$DIR/taginfo-master.db

rm -f $DATABASE

perl -pe "s|__DIR__|$DIR|" master.sql | sqlite3 $DATABASE
sqlite3 $DATABASE <languages.sql

echo -n "Done master: "; date

