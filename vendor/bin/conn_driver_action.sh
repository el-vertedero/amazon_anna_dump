#!/vendor/bin/sh

BUS=usb
if [ "$BUS" != "usb" ]; then
    echo "Connectivity: Not support bus:$BUS" > /dev/kmsg
    exit 1
fi

CHIP=`getprop vendor.conn.chip`
if [ "$CHIP" != "mt7668" ] && [ "$CHIP" != "mt7663" ]; then
    echo "Connectivity: Not support chip:$CHIP" > /dev/kmsg
    exit 2
fi

ACTION=`getprop vendor.sys.conn.action`
if [ "$ACTION" != "attach" ] && [ "$ACTION" != "detach" ] && [ "$ACTION" != "reload" ]; then
    echo "Connectivity: Not support action:$ACTION" > /dev/kmsg
    exit 3
fi

function driver_attach
{
    if [ "$CHIP" == "mt7668" ]; then
        insmod /vendor/lib/modules/btmtk_usb.ko
        if [ $? != 0 ]; then
            echo "Connectivity: insmod btmtk_usb.ko failed" > /dev/kmsg
        fi
        insmod /vendor/lib/modules/wlan_mt76x8_usb_prealloc.ko
        if [ $? != 0 ]; then
            echo "Connectivity: insmod wlan_mt76x8_usb_prealloc.ko failed" > /dev/kmsg
        fi
        insmod /vendor/lib/modules/wlan_mt76x8_usb.ko
        if [ $? != 0 ]; then
            echo "Connectivity: insmod wlan_mt76x8_usb.ko failed" > /dev/kmsg
        fi
    else
        insmod /vendor/lib/modules/btmtk_usb_mt76x3.ko
        if [ $? != 0 ]; then
            echo "Connectivity: insmod btmtk_usb_mt76x3.ko failed" > /dev/kmsg
        fi
        insmod /vendor/lib/modules/wlan_mt76x3_usb_prealloc.ko
        if [ $? != 0 ]; then
            echo "Connectivity: insmod wlan_mt76x3_usb_prealloc.ko failed" > /dev/kmsg
        fi
        insmod /vendor/lib/modules/wlan_mt76x3_usb.ko
        if [ $? != 0 ]; then
            echo "Connectivity: insmod wlan_mt76x3_usb.ko failed" > /dev/kmsg
        fi
    fi
}

function driver_detach
{
    if [ "$CHIP" == "mt7668" ]; then
        rmmod /vendor/lib/modules/btmtk_usb.ko
        if [ $? != 0 ]; then
            echo "Connectivity: rmmod btmtk_usb.ko failed" > /dev/kmsg
        fi
        rmmod /vendor/lib/modules/wlan_mt76x8_usb.ko
        if [ $? != 0 ]; then
            echo "Connectivity: rmmod wlan_mt76x8_usb.ko failed" > /dev/kmsg
        fi
        rmmod /vendor/lib/modules/wlan_mt76x8_usb_prealloc.ko
        if [ $? != 0 ]; then
            echo "Connectivity: rmmod wlan_mt76x8_usb_prealloc.ko failed" > /dev/kmsg
        fi
    else
        rmmod /vendor/lib/modules/btmtk_usb_mt76x3.ko
        if [ $? != 0 ]; then
            echo "Connectivity: rmmod btmtk_usb_mt76x3.ko failed" > /dev/kmsg
        fi
        rmmod /vendor/lib/modules/wlan_mt76x3_usb.ko
        if [ $? != 0 ]; then
            echo "Connectivity: rmmod wlan_mt76x3_usb.ko failed" > /dev/kmsg
        fi
        rmmod /vendor/lib/modules/wlan_mt76x3_usb_prealloc.ko
        if [ $? != 0 ]; then
            echo "Connectivity: rmmod wlan_mt76x3_usb_prealloc.ko failed" > /dev/kmsg
        fi
    fi
}

if [ "$ACTION" == "attach" ]; then
    driver_attach
elif [ "$ACTION" == "detach" ]; then
    driver_detach
elif [ "$ACTION" == "reload" ]; then
    driver_detach
    driver_attach
fi

echo "Connectivity: Drivers $ACTION done" > /dev/kmsg

exit 0
