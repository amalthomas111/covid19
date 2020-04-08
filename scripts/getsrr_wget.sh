#!/bin/bash
# Author: A.T
if [ "$#" -ne 1 ]; then
echo "bash script.sh srrlistfile"
exit
fi

# check for input files
if [ ! -f $1 ];then
        echo "Inputfile:${1} not found! Exiting"
        exit
fi

list=$1
cat $1|while read i;do srapath $i ;done > url.txt
total=$(wc -l url.txt|cut -d' ' -f1)
echo "Total # of SRRs from srapath to download=${total}"
echo "========================================="
echo ""
cat url.txt|while read i;do
        srr=$(basename $i)
        name=$(echo $srr|cut -d'.' -f1)
        echo "wget -O ${name}.sra $i"
        wget -O ${name}.sra $i
done
echo ""
total=$(ls -1 *.sra|sed 's/.sra//g'|wc -l)
echo "-----------------------------------------"
echo "Total files downloaded=${total}"
echo "Files downloaded at:"$PWD
