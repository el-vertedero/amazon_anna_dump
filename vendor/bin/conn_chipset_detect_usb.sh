#!/vendor/bin/sh

IS_MT7668_CONNECTED=0
IS_MT7663_CONNECTED=0
CHIP=mt7668
MIN_USB_DETECTION_ATTEMPTS=10
MAX_USB_DETECTION_ATTEMPTS=600

function check_connectivity_chipset
{
    IS_MT7668_CONNECTED=`lsusb | grep 0e8d:7668 | wc -l`
    IS_MT7663_CONNECTED=`lsusb | grep 0e8d:7663 | wc -l`
}

count=0
while true
#while [ $count -lt $MAX_USB_DETECTION_ATTEMPTS ]
do
    check_connectivity_chipset
    if [ $IS_MT7668_CONNECTED != 0 ]; then
        setprop vendor.conn.chip mt7668
        CHIP=mt7668
        echo "Connectivity: Module MT7668 connected" > /dev/kmsg
        break
    elif [ $IS_MT7663_CONNECTED != 0 ]; then
        setprop vendor.conn.chip mt7663
        CHIP=mt7663
        echo "Connectivity: Module MT7663 connected" > /dev/kmsg
        break
    else
        let count++
        echo "Connectivity: No module detected:$count" > /dev/kmsg
        if [ $count -lt $MIN_USB_DETECTION_ATTEMPTS ]; then
            sleep 0.5
        elif [ $count -eq $MIN_USB_DETECTION_ATTEMPTS ]; then
            CHIP=`getprop persist.vendor.conn.chip`
            if [ -n "$CHIP" ]; then
                setprop vendor.conn.chip $CHIP
                echo "Connectivity: Try module $CHIP" > /dev/kmsg
                break
            fi
            sleep 1
        elif [ $count -gt $MAX_USB_DETECTION_ATTEMPTS ]; then
            echo "Connectivity: Notify user!!!" > /dev/kmsg
            sleep 1
        else
            sleep 1
        fi
    fi
done

setprop vendor.sys.conn.action attach

READY=
while true
do
    READY=`getprop ro.persistent_properties.ready`
    if [ "$READY" == "true" ]; then
        setprop persist.vendor.conn.chip $CHIP
        echo "Connectivity: Write persist.vendor.conn.chip" > /dev/kmsg
        break
    fi
    sleep 1
done

result=0
#if [ $count -eq $MAX_USB_DETECTION_ATTEMPTS ]; then
#    result=1
#fi
exit $result
