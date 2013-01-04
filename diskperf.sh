#!/bin/sh

############------DiskPerf-----#################
#
# Author: Kelvin Ng
# Establish Date: 3/1/2013
# Last Update: 4/1/2013
#
################################################

function usage() {
	cat << EOF
-h		Show this message
-s SRC_DIR	Set the source of files for the test
-d DST_DIR	Set the working directory of the test
EOF
}

function getime()
{
	start=$(date +%s)
	`$@`
	end=$(date +%s)
	echo $(($end - $start))
}

function getnum()
{
	echo `ls -A1 $1 | wc -l`
}

function randomfile()
{
	num=$(getnum)
	echo $(($RANDOM % $num + 1))
}

function getfilename()
{
	echo `ls -A1 $1 | sed -n "${2}p"`
}

function delfile()
{
	if [ -d "$1" ] && [ $(getnum "$1") -gt 0 ]; then
		cd "$1"
		delfile $(getfilename . $(randomfile))
		cd ..
	elif [ -f "$1" ]; then
		rm "$1"
		dnum=$(($dnum - 1))
	else
		rm -r "$1"
	fi
}

function randomdelnfile()
{
	for i in $(seq 1 "$1")
	do
		delfile $(getfilename . $(randomfile))
	done
}

while getopts "hs:d:" opt 
do
	case $opt in
	h)
		usage
		exit 1
		;;
	
	s)
		src=$OPTARG
		;;

	d)
		dst=$OPTARG
		;;

	esac
done

if [ "$src" == "" ] || [ "$dst" == "" ]; then
	usage
	exit 1
fi

echo "Start copying the files..."
copy_file_t=$(getime cp -r "$src/*" "$dst")
echo "Time needed: ${copy_file_t}s"

cd $dst

echo "Getting number of files being deleted..."
start=$(date +%s)
dnum=$(($(find . -type f | wc -l) / 10 * 7))
end=$(date +%s)
get_num_del_t=$(($end - $start))
echo "Number of files being deleted: $dnum"
echo "Time needed: $get_num_del_t"

echo "Testing random delete..."
random_del_t=$(getime randomdelnfile "$dnum")
echo "Time needed: ${random_del_t}s"

