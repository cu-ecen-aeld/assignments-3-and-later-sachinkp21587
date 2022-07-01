#!/bin/bash

if (( $# < 2 ))
then
	echo Synopsis: ./writer.sh \<filePath\> \<text_to_write\>
	exit 1
fi

directory=$(dirname $1)
echo $directory

filename=$(basename $1)
echo $filename

if [ ! -d $directory ]
then
	mkdir -p $directory
fi
	echo $2 > $1

if [ ! $? -eq 0 ]
then
	echo error
	exit 1
fi
