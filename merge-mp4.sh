#!/bin/bash

## Script to merge all mp4 videos in current directory (recursively 2 levels)
## And update chapter marks to retain the folder/filename

## Script for merging videos


filename=`basename pwd`
current=`pwd`
bname=`basename "$current"`
find . -maxdepth 1 -iname '*.mp4' | xargs -L 1 echo | awk '{printf "file \x27%s\x27\n", $0}' >> list.txt
find . -maxdepth 1 -iname '*.mp4' | xargs -L 1 echo | awk '{print $0}' >> files.txt
echo -n "Merging the files"
ffmpeg -f concat -safe 0 -i list.txt -c copy "$bname.mp4" -v quiet
echo "..........[ DONE ]"

## extract meta
# ffmpeg -i all.mp4 -f ffmetadata metafile
metafile="metadata.txt"
echo -n "Extracting meta data"
ffmpeg -i "$bname.mp4" -f ffmetadata $metafile -v quiet
echo "..........[ DONE ]"

## chapter marks
#TODO: (‘=’, ‘;’, ‘#’, ‘\’) to be escaped
ts=0
echo -n "Identifying chapters"
cat files.txt | while read file
do
    ds=`ffprobe -v quiet -of csv=p=0 -show_entries format=duration "$file"`
    # echo "$ds"
    echo "[CHAPTER]" >> $metafile
    echo "TIMEBASE=1/1" >> $metafile
    echo "START=$ts" >> $metafile
    ts=`echo $ts + $ds | bc`
    echo "END=$ts" >> $metafile
    echo "TITLE=$file" >> $metafile
    
done
echo "..........[ DONE ]"
## update meta with chaptermarks

echo -n "Adding chapter meta "

ffmpeg -i "$bname.mp4" -i $metafile -map_metadata 1 -codec copy "$bname-meta.mp4" -v quiet
echo "..........[ DONE ]"

## cleanup
echo -n "Cleaning up"

rm files.txt list.txt $metafile

echo "..........[ DONE ]"

echo "Job Completed."
