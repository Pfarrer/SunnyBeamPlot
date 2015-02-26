#!/bin/bash

# Config Variables
TARGET_DIR="generated"

# Runtime helper variables
m_csvs=$(find . -regextype posix-extended -regex "\./[0-9]{4}-.*\.CSV")
d_csvs=$(find . -regextype posix-extended -regex "\./[0-9]{2}-.*\.CSV")

# Create dirs
m_target_dir=$TARGET_DIR
d_target_dir=$TARGET_DIR/days
mkdir -p $m_target_dir
mkdir -p $d_target_dir

function get_day_total {
	local subtotal=$(tail -2 $1 | head -1 | tr ';' '\n' | tail -n +2)
	local sum="$(echo -e $subtotal | tr ' ' '\n' | tr ',' '.' | awk '{ sum+=$1 } END { print sum }' | tr '.' ',')"
	echo "$sum"
}

for csv in $d_csvs
do
	target_file="$d_target_dir/${csv%.*}.png"

	# DEBUG
	touch $csv

	# Only run for newer CSV file than PNG file
	if [ "$csv" -nt "$target_file" ]; then
		echo "Generating ${csv%.*} ..."

		total=$(get_day_total $csv)
		title=$(echo ${csv%.*} | sed "s|^\./||")
		title="Werte vom $title, Tagessumme: $total kWh"
		gnuplot -e "output_name='$target_file';title='$title'" day.gnuplot < $csv
	fi
done
