#!/bin/bash
#------------------------------------------------------------------------------
#
#  Taginfo
#
#  update_all.sh DATADIR
#
#  Call this to update your Taginfo databases. All data will be store in the
#  directory DATADIR. Create an empty directory before starting for the first time!
#
#  In this directory you will find:
#  log      - directory with log files from running the update script
#  download - directory with bzipped databases for download
#  ...      - a directory for each source with database and possible some
#             temporary files
#
#------------------------------------------------------------------------------

# These sources will be downloaded from http://taginfo.openstreetmap.org/download/
# Note that this will NOT work for the "db" source! Well, you can download it,
# but it will fail later, because the database is changed by the master.sql
# scripts.
readonly SOURCES_DOWNLOAD=$(../bin/taginfo-config.rb sources.download)

# These sources will be created from the actual sources
readonly SOURCES_CREATE=$(../bin/taginfo-config.rb sources.create)

#------------------------------------------------------------------------------

set -e
set -u

readonly SRCDIR=$(dirname $(readlink -f "$0"))
readonly DATADIR=$1

if [ -z $DATADIR ]; then
    echo "Usage: update_all.sh DATADIR"
    exit 1
fi

source ./util.sh all

readonly LOGFILE=$(date +%Y%m%dT%H%M)
mkdir -p $DATADIR/log
exec >$DATADIR/log/$LOGFILE.log 2>&1


download_source() {
    local source="$1"

    print_message "Downloading $source..."

    mkdir -p $DATADIR/$source
    run_exe curl --silent --fail --output $DATADIR/download/taginfo-$source.db.bz2 --time-cond $DATADIR/download/taginfo-$source.db.bz2 http://taginfo.openstreetmap.org/download/taginfo-$source.db.bz2
    run_exe -l$DATADIR/$source/taginfo-$source.db bzcat $DATADIR/download/taginfo-$source.db.bz2

    print_message "Done."
}

download_sources() {
    local sources="$*"

    mkdir -p $DATADIR/download

    local source
    for source in $sources; do
        download_source $source
    done
}

update_source() {
    local source="$1"

    print_message "Running $source/update.sh..."

    mkdir -p $DATADIR/$source
    $SRCDIR/$source/update.sh $DATADIR/$source

    print_message "Done."
}

update_sources() {
    local sources="$*"

    local source
    for source in $sources; do
        update_source $source
    done
}

update_master() {
    print_message "Running master/update.sh..."

    $SRCDIR/master/update.sh $DATADIR

    print_message "Done."
}

compress_file() {
    local filename="$1"
    local compressed="$2"

    print_message "Compressing '$filename' to '$compressed'"
    bzip2 -9 -c $DATADIR/$filename.db >$DATADIR/download/taginfo-$compressed.db.bz2 &
}

compress_databases() {
    local sources="$*"

    print_message "Running bzip2 on all databases..."

    local source
    for source in $sources; do
        compress_file $source/taginfo-$source $source
#        bzip2 -9 -c $DATADIR/$source/taginfo-$source.db >$DATADIR/download/taginfo-$source.db.bz2 &
    done
    sleep 5 # wait for bzip2 on the smaller dbs to finish

    local db
    for db in master history search; do
        compress_file taginfo-$db $db
#        bzip2 -9 -c $DATADIR/taginfo-$db.db >$DATADIR/download/taginfo-$db.db.bz2 &
    done

    wait

    print_message "Done."
}

create_extra_indexes() {
    print_message "Creating extra indexes..."

    run_sql $DATADIR/db/taginfo-db.db $SRCDIR/db/add_extra_indexes.sql

    print_message "Done."
}

main() {
    print_message "Start update_all..."

    download_sources $SOURCES_DOWNLOAD
    update_sources $SOURCES_CREATE
    update_master
    compress_databases $SOURCES_CREATE
    create_extra_indexes

    print_message "Done update_all."
}

main


#-- THE END -------------------------------------------------------------------
