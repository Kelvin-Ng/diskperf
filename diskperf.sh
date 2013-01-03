#!/bin/sh

############------DiskPerf-----#################
#
# Author: Kelvin Ng
# Establish Date: 3/1/2013
# Last Update: 3/1/2013
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
	echo `/usr/bin/time -p $@ 2>&1 > /dev/null | grep 'real' | cut -d ' ' -f 2`
}

function getnum()
{
	echo `ls -A1 $1 | wc -l`
}

function randomfile()
{
	num=$(getnum)
	echo $(($(od -An -N2 -i /dev/random) % $num + 1))
}

function getfilename()
{
	echo `ls -A1 $1 | sed -n "${2}p"`
}

function delfile()
{
	if [ -d "$1" ]; then
		cd $1
		delfile $(getfilename . $(randomfile))
		cd ..
	elif [ -f "$1" ]; then
		rm $1
	fi
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

echo Start copying the files...
xt=$(getime cp -r "$src/*" "$dst")
echo "Time needed: $xt"

cd $dst

delfile $(getfilename . $(randomfile))

