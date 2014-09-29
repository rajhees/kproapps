#!/bin/bash

for f in `ls`
do
		if [[ "$f" == *-* ]]
		then
			rm $f
		fi	
done