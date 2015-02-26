set terminal png transparent nocrop enhanced size 800,600 font "arial,8" 
set output output_name

set style data lines
set xdata time
set timefmt '%H:%M'
set datafile separator ';'
set decimalsign locale; set decimalsign ","

set xrange ['00:00':'23:50']
set yrange [0:3]
#set xtics 0,1,23

set title title

plot '/dev/stdin' using 1:2 title 'Inv. 1' with lines, \
     '/dev/stdin' using 1:3 title 'Inv. 2' with lines
