#!/vendor/bin/sh

source /vendor/etc/boot.conf

while [ ! -f /mnt/vendor/tmp/mtk_rm_end ] ;
do
      /vendor/bin/sleep 0.1
done

/vendor/bin/touch /mnt/vendor/tmp/basic_mounted

#date 2014.10.01-00:00

# for cts -- start
/vendor/bin/chmod 771 /mnt/vendor/tmp
/vendor/bin/chown 0:1000 /mnt/vendor/tmp
# 0:1000 -> root.system
# for cts -- end

# default umask in Linux world
umask 000

#wait /dev/fusion0 create for fix linux world access fail.
while [ ! -c /dev/fusion0 ] ;
do
      /vendor/bin/sleep 0.1
done

# Launch TV F/W
/vendor/bin/echo "--- Launch TV F/W --- "
/vendor/bin/sh /vendor/etc/rc.local

while true
do
if [ -f /mnt/vendor/tmp/dtv_svc_is_ready ];then
    break
fi
/vendor/bin/sleep 0.1
done

/vendor/bin/echo "==> dtv_svc end" > /proc/boottime

# Factory mode via ttyMT3
stty -F /dev/ttyS0 115200

# for CTS user build debug, in uboot: addboot logcat_print=1
grep logcat_print=1 /proc/cmdline > /dev/null

if [ $? == 0 ]; then
    /vendor/bin/sleep 20
    logcat -v time &
fi
