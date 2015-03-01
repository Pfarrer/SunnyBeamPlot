#!/bin/bash

# Config Variables
DIR="/opt/SunnyBeamPlot/"
SOURCE_DIR="/media/sunnybeam/SBEAM"
TARGET_DIR="/var/www"

# Runtime helper variables
m_csvs=$(find $SOURCE_DIR -regextype posix-extended -regex ".*/[0-9]{4}-.*\.CSV")
d_csvs=$(find $SOURCE_DIR -regextype posix-extended -regex ".*/[0-9]{2}-.*\.CSV")

# Create dirs
m_target_dir=$TARGET_DIR
d_target_dir=$TARGET_DIR/days
backup_target_dir=$TARGET_DIR/backup
mkdir -p $m_target_dir
mkdir -p $d_target_dir
mkdir -p $backup_target_dir

cd $DIR

function get_day_total {
	local subtotal=$(tail -2 $1 | head -1 | tr ';' '\n' | tail -n +2)
	local sum="$(echo -e $subtotal | tr ' ' '\n' | tr ',' '.' | awk '{ sum+=$1 } END { print sum }' | tr '.' ',')"
	echo "$sum"
}

for csv in $d_csvs
do
	day_name="$(basename ${csv%.*})"
	target_file="$d_target_dir/$day_name.png"

	# Only run for newer CSV file than PNG file
	if [ "$csv" -nt "$target_file" ]; then
		echo "Generating $csv -> $target_file ..."

		total=$(get_day_total $csv)
		title=$(echo $day_name | sed "s|^\./||")
		title="Werte vom $title, Tagessumme: $total kWh"
		
		tmp_file=$(mktemp)
		cat $csv | tr "," "." > $tmp_file
		gnuplot -e "input_name='$tmp_file';output_name='$target_file';title='$title'" day.gnuplot
		rm $tmp_file

		# Copy backup$
		cp $csv "$backup_target_dir/$day_name.CSV"
	fi
done
