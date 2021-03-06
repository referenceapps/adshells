#!/bin/bash
#cf push "${CF_APP}"
export count=`cat ./cnt.txt`
#count=12
echo ----$count-------
#./bin/cf add-plugin-repo bluemix http://plugins.ng.bluemix.net/
#./bin/cf install-plugin active-deploy -r bluemix 
#./test.sh

echo "*******************************"
echo "***  Upgrade CF CLI         ***"
echo "*******************************"

mkdir /tmp/newcf
wget -O /tmp/cf$$.tgz 'https://cli.run.pivotal.io/stable?release=linux64-binary&version=6.13.0&source=github-rel'
tar -C /tmp/newcf -xzf /tmp/cf$$.tgz
#export PATH=/tmp/newcf:$PATH

echo "************************************"
echo "*** Install Active Deploy Plugin ***"
echo "************************************"

/tmp/newcf/cf add-plugin-repo bluemix http://plugins.ng.bluemix.net/
/tmp/newcf/cf install-plugin active-deploy -r bluemix -f

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


export new=${CF_APP}${count}
export old=`cf apps | grep ${CF_APP}|awk '{print $1}'`
echo "new --> $new"
echo "old --> $old"
if [ $old == "" ] ; then
echo "old not exist"
cf push ${CF_APP}${count} -m 256MB -n ${CF_APP}
else
if [ ${new} != ${old} ] ; then 
echo "*****************************************"
echo "**   ENTERING ACTIVE DEPLOY            **"
echo "*****************************************"
routeflag=" --no-route"
cf push ${CF_APP}${count}${routeflag} -m 256MB
/tmp/newcf/cf active-deploy-create $old $new --rampup 1m --test 1m --rampdown 1m -l ${CF_APP}_deploy
sleep 240
# show the status of completed deployment
/tmp/newcf/cf active-deploy-show ${CF_APP}_deploy
cf apps

# delete apps
cf delete -f $old

# delete deployment
/tmp/newcf/cf active-deploy-delete ${CF_APP}_deploy
else
echo "$new is same as $old: NNOTHING TO DO"
fi
fi


