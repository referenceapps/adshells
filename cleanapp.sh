#!/bin/bash
set -x 
appcnt=`cf apps|grep ${CF_APP}| wc -l`
if [ $appcnt -gt 1 ]; then
echo "***********************************"
echo "*** cleaning old or stopped app ***"
echo "***********************************"
 
cf apps | grep ${CF_APP} |awk -v cfapp=${CF_APP} '
BEGIN{lv=-1; lapp=length(cfapp); lapp++}
{
	print $0
#print $1 "  " $2; print NF
	if (($2 == "stopped")||(NF < 6)) {
		echoapp = "echo cf delete -f " $1
		system(echoapp)
		delapp = "cf delete -f " $1
		system(delapp)	
	}else{
		if ($1 == cfapp){
			print "old"
			num=0
			if(lv == -1) {
				lv=0;
				print "change lv to 0"
			} else if (lv >0) {
				echoapp = "echo cf delete -f " cfapp "*******"	
				system(echoapp);
				delapp = "cf delete -f " cfapp	
				system(delapp);
			}else{
				print "***********ERRROR LEVEL= NUMERO*********"
			}
		}else {
			num=substr($1,lapp);
			if (num~/^[0-9]*$/){
				print num;
				if (num > lv) {
					if (lv==0){
						echoapp = "echo cf delete -f " cfapp  "*******"	
						system (echoapp);
						delapp = "cf delete -f " cfapp	
						system (delapp);
					}else{
						echoapp = "echo cf delete -f " cfapp lv "*******"	
						system (echoapp); 
						delapp = "cf delete -f " cfapp	lv
						system (delapp)
					}
					lv=num;
					stampa="change lv to " num; print stampa 
				}
				else if (num < lv){
					echoapp = "echo cf delete -f " cfapp  num "*******"	
					system (echoapp);
					delapp = "cf delete -f " cfapp	num
					#system (delapp);
				}else{
					print "***********ERRROR LEVEL= NUMERO*********"
				}
			}
			else{
				print "no good"	
			}
		}
	}
}'

fi
