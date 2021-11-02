
if [ $# -eq 1 ];
then
   export NO_OF_ENTRIES="$1"
else
   export NO_OF_ENTRIES=10
fi
export FILE_NAME="/shared/inputdata"
rm -rf $FILE_NAME
touch $FILE_NAME
for i in `seq $NO_OF_ENTRIES` ; do echo "$i, $RANDOM" ; done >> $FILE_NAME
