#!/bin/bash
make
cd ../bin

rm -f rapport.txt

for dir in $(ls .)
	do
		echo -e "\tDossier : $dir"
		for file in $(ls ./$dir)
			do
				echo "$file :"
				echo "$file :" >>"./rapport.txt"
				../src/as < "./$dir/$file" 2>>"./rapport.txt"
				let "res = $?"
				echo "return" $res >> "./rapport.txt"
				if [ $res = 0 ]
				then
					echo "No problem

					" >> "./rapport.txt"
				else
					if [ $res = 1 ]
					then
						echo "Syntax Error
						" >> "./rapport.txt"
					else
						echo "Semantic Error
						" >> "./rapport.txt"
					fi
				fi
			done
	done
