#!/vendor/bin/sh

usrflags=`cat /proc/idme//usr_flags`
len=$((${#usrflags}-1))
lastdigit=${usrflags:$len:1}
lastdigit=0x$lastdigit

function set_idme_usr_flags
{
   if [ $lastdigit -eq 10 ]; then lastdigit=a; fi
   if [ $lastdigit -eq 11 ]; then lastdigit=b; fi
   if [ $lastdigit -eq 12 ]; then lastdigit=c; fi
   if [ $lastdigit -eq 13 ]; then lastdigit=d; fi
   if [ $lastdigit -eq 14 ]; then lastdigit=e; fi
   if [ $lastdigit -eq 15 ]; then lastdigit=f; fi

   newusrflags=${usrflags:0:$len}$lastdigit
   echo "usr_flags:" $newusrflags > /dev/kmsg
   /vendor/bin/setprop vendor.sys.storemode.usrflags $newusrflags
}

echo "set storemode $1" > /dev/kmsg
if [ $1 -eq 1 ]; then
   lastdigit=$((lastdigit|0x4))
   set_idme_usr_flags
elif [ $1 -eq 0 ]; then
   lastdigit=$((lastdigit&(lastdigit^0x4)))
   set_idme_usr_flags
else
   if [[ -f /data/vendor/storemode_flag ]]; then
      echo "no need to clear" > /dev/kmsg
   else
      touch /data/vendor/storemode_flag
      /vendor/bin/setprop vendor.sys.storemode.clear 1
   fi
fi
