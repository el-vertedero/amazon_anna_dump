#!/vendor/bin/sh

# place logics depending on file system mounted in this file.

# check if ALS sensor is connected
# to access this file
# als_device_file=/sys/bus/i2c/devices/2-0039/als_lux
# if [ -e "$als_device_file" ] ; then
#     echo "devcfg: als sensor detected." > /dev/kmsg
# else
#     echo "devcfg: als sensor is not connected!" > /dev/kmsg
# fi

idme_device_config_name=`/vendor/bin/cat /proc/idme/config_name`
config_name=$(echo "$idme_device_config_name" | tr '[:upper:]' '[:lower:]')
config_name_trimmed=${config_name%_*}
if [ $config_name_trimmed == "kayla" ]; then
    /vendor/bin/setprop ro.vendor.mstar.als_name "als_service_na"
    RETVAL=0
    /vendor/bin/insmod /vendor/lib/modules/als_service.ko || RETVAL=1
    if [ ${RETVAL} -eq 1  ]; then
        echo "insert als_service kernel module for NA model failed!" > /dev/kmsg
        exit
    fi
    echo "als_service.ko is loaded for NA model" > /dev/kmsg
    /vendor/bin/insmod /vendor/lib/modules/als_aab.ko || RETVAL=1
    if [ ${RETVAL} -eq 1  ]; then
        echo "insert als_aab kernel module for NA model failed!" > /dev/kmsg
        exit
    fi
    echo "als_aab.ko is loaded for NA model" > /dev/kmsg
elif [[ $config_name == "kaylaeu_ff"* ]]; then
    /vendor/bin/setprop ro.vendor.mstar.als_name "als_service_eu"
    RETVAL=0
    /vendor/bin/insmod /product/lib/modules/als_service.ko || RETVAL=1
    if [ ${RETVAL} -eq 1  ]; then
        echo "insert als_service kernel module for EU model failed!" > /dev/kmsg
        exit
    fi
    echo "als_service.ko is loaded for NA model" > /dev/kmsg
    /vendor/bin/insmod /product/lib/modules/als_aab.ko || RETVAL=1
    if [ ${RETVAL} -eq 1  ]; then
        echo "insert als_aab kernel module for EU model failed!" > /dev/kmsg
        exit
    fi
    echo "als_aab.ko is loaded for NA model" > /dev/kmsg
else
     echo "devcfg-check-als: unknown device_config_name - $idme_device_config_name" > /dev/kmsg
fi

