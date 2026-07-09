#!/system/bin/sh

dtid=`/system/bin/cat /proc/idme/device_type_id`
echo "The DTID of this device is : $dtid" >dev/kmsg
cheyne="A2AFH666ZTTTE8"
if [[ $dtid == $cheyne ]]
then
    echo "The is Cheyne device" > dev/kmsg
    system/bin/cmd overlay enable com.amazon.tv.quicksettings.overlay.cheyne.kt
else
    echo "This is not Cheyne" > dev/kmsg
    system/bin/cmd overlay enable com.amazon.tv.quicksettings.overlay.kt
fi