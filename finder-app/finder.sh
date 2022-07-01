#!/bin/bash

if (( $# < 2 ))
then
	echo Synopsis: ./writer.sh \<filePath\> \<text_to_write\>
	exit 1
fi

if [ ! -d $1 ]
then
	echo Directory $1 do not exist
	exit 1
fi
cd $1
X=$( find -L | wc -l )
X=$(( $X - 1 ))

Y=$( grep -r $2 * | wc -l )

echo The number of files are $X and the number of matching lines are $Y
