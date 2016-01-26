export count=`git log origin/master --oneline| wc -l`
echo ----$count-------
echo $count > ./cnt.txt
cat ./cnt.txt
