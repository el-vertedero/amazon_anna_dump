#!/vendor/bin/sh

prop_ip='persist.adbnet.ip'
idmeippath='/proc/idme/eth_ip_addr'
ipaddr='192.168.1.101'

if [ -f $idmeippath ] ; then
   idmeip=`/vendor/bin/cat $idmeippath`
   if [ "$idmeip" != "" ] && [ "$idmeip" != "0" ] ; then
      ipaddr="$idmeip"
   fi
fi
/vendor/bin/setprop $prop_ip "$ipaddr/24"
