#!/bin/bash
#echo "$#"
if [ "$#" -lt 1 ]; then
    echo "sh script.sh <SRP014854/PRJNA257197> <path(optional)>"
    exit
fi
if [ "$#" -eq 1 ]; then
    path=$PWD
elif [ $2 == "." ]; then
    path=$PWD
else
    path=$2
fi
echo "path:$path"
#esearch -db sra -query ${1}|esummary | xtract  -pattern DocumentSummary -element Run@acc Title LIBRARY_SELECTION  LIBRARY_LAYOUT
esearch -db sra -query ${1} | efetch -format runinfo > ${1}.runinfo.csv
cut -d"," -f1 ${1}.runinfo.csv |sed '/^$/d'|grep -v Run >> srrlist.txt.temp
cat srrlist.txt.temp|sort -u > srrlist.txt
rm srrlist.txt.temp
echo "srrlist.txt created"
awk -F "," -v c1=Run -v  c2=LibraryLayout -v c3=ScientificName -v \
        c4=LibraryStrategy -v c5=LibrarySelection -v c6=SampleName \
        '{if(NR==1){for(i=1;i<=NF;i++){ix[$i]=i}}else{print $ix[c1]"\t"$ix[c2]"\t"$ix[c3]"\t"$ix[c4]"\t"$ix[c5]"\t"$ix[c6]}}'\
        ${1}.runinfo.csv >> $path/list.txt.temp
cat $path/list.txt.temp|grep -v Run|sort -u|sed 's/ /_/g'|sed '/^[[:space:]]*$/d' > $path/list.txt
rm $path/list.txt.temp
echo "list.txt created"
