#!/vendor/bin/sh

# place logics depending on file system mounted in this file.

# set ro.odm.version.number
tvconfig_ota_version=`/vendor/bin/cat /vendor/tvconfig/config/tvconfig_ota_version.ini`
/vendor/bin/setprop ro.odm.version.number "$tvconfig_ota_version"

i="0"
# check if exists and timeout till 2s
while [ $i -lt 200 ] ;
do
    if [[ -f /sys/kernel/debug/is_support_av1ex ]] ; then
         echo "is_support_av1ex are ready in devcfg" > /dev/kmsg
         break
    fi
    /vendor/bin/sleep 0.01
    i=$(($i+1))
done

# Check the SOC capability
is_support_dolby_vision=`/vendor/bin/cat /sys/kernel/debug/is_support_dolby_vision`
if [ -z "$is_support_dolby_vision" ]; then
    # if can not find 'DOVI' info.
    is_support_dolby_vision="1"
fi
is_support_av1ex=`/vendor/bin/cat /sys/kernel/debug/is_support_av1ex`
if [ -z "$is_support_av1ex" ]; then
    # if can not find 'AV1EX' info.
    is_support_av1ex="0"
fi

# set media codecs extension
codecPopValue=0
if [ $is_support_dolby_vision == "1" ] ; then
    codecPopValue=$(($codecPopValue+1))
    if [ $is_support_av1ex == "1" ]; then
        codecPopValue=$(($codecPopValue+2))
    fi
fi

# set ro.amazon.sys.fbs-size for HD/FHD panel
# the resolution is read from tvconfig partition, thus do it in post-fs stage
idme_device_type_id=`/vendor/bin/cat /proc/idme/device_type_id`

case "$idme_device_type_id" in
    "AHCEDGRIFN5RP")
        # Anna, 4K
        # Display and framebuffer size
        /vendor/bin/setprop vendor.display-size "3840x2160"
        /vendor/bin/setprop ro.amazon.sys.fbs-size "1920x1080"
        # set modelgroup for netflix testing
        if [ $is_support_dolby_vision == "1" ] ; then
            echo "Set modelgroup for dovi model" > /dev/kmsg
            if [ $is_support_av1ex == "0" ]; then
                /vendor/bin/setprop ro.vendor.nrdp.modelgroup FTVET31DOVI2020
            else
                /vendor/bin/setprop ro.vendor.nrdp.modelgroup FTVET31DOVIAV12020
            fi
        else
            echo "Set modelgroup for non-dovi model" > /dev/kmsg
            if [ $is_support_av1ex == "0" ]; then
                /vendor/bin/setprop ro.vendor.nrdp.modelgroup FTVET31HDR2020
            else
                /vendor/bin/setprop ro.vendor.nrdp.modelgroup FTVET31HDRAV12020
            fi
        fi
        ;;
    "ADOUDFQX2QVX0" | "A3D5JL73E6MKZ1")
        # Kayla 4K models
        # Display and framebuffer size
        /vendor/bin/setprop vendor.display-size "3840x2160"
        /vendor/bin/setprop ro.amazon.sys.fbs-size "1920x1080"
        codecPopValue=$(($codecPopValue+4))
        # set modelgroup for netflix testing
        if [ $is_support_dolby_vision == "1" ] ; then
            echo "Set modelgroup for dovi model" > /dev/kmsg
            /vendor/bin/setprop ro.vendor.nrdp.modelgroup FTVET31DOVIAV12020
        else
            echo "Set modelgroup for non-dovi model" > /dev/kmsg
            /vendor/bin/setprop ro.vendor.nrdp.modelgroup FTVET31HDRAV12020
        fi
        ;;
    "A2AFH666ZTTTE8")
        # Kayla 2K model
        # Display size
        /vendor/bin/setprop vendor.display-size "1920x1080"
        # Kayla-EU 2K force disable DV
        codecPopValue=8
        # We read the specific idme model ini file to get the appropriate panel.ini file.
        # We then read the panel.ini file to get the panel width/height and set
        # the framebuffer size based on it.
        idme_model_name=`/vendor/bin/cat /proc/idme/model_name`
        panel_ini_file=`/vendor/bin/sed -rn 's/m_pPanelName[^=]*=[^=]*"(.+)".*/\1/p' "$idme_model_name"`
        panel_width=`/vendor/bin/sed -rn 's/m_wPanelWidth[^=]*=[^0-9]*([0-9]+).*/\1/p' "$panel_ini_file"`
        panel_height=`/vendor/bin/sed -rn 's/m_wPanelHeight[^=]*=[^0-9]*([0-9]+).*/\1/p' "$panel_ini_file"`
        if (( $panel_width >= 1280 )) && (( $panel_width <= 1366 )) && \
           (( $panel_height >= 720 )) && (( $panel_height <= 768 )); then
            /vendor/bin/setprop ro.amazon.sys.fbs-size "1360x768"
            /vendor/bin/setprop ro.vendor.nrdp.modelgroup FTVET31HDHDR2022
        else
            /vendor/bin/setprop ro.amazon.sys.fbs-size "1920x1080"
            /vendor/bin/setprop ro.vendor.nrdp.modelgroup FTVET31FHDHDR2022
        fi
        ;;
    *)
        echo "devcfg-post-fs: unknown device_type_id - $idme_device_type_id" > /dev/kmsg
        ;;
esac

## codecPopValue
# 0x  0         0         0     0
#     |         |         |     |
#  Kayla-2K  Kayla-4K   AV1ex   DV
# 0x0100 kayla-4K Non-AV1ex Non-DV
# 0x0101 Kayla-4K Non-AV1ex DV
# 0x0111 Kayla-4K AV1ex DV
# 0x1000 Kayla-2K Non-AV1ex Non-DV

if [ $codecPopValue != "0" ] ; then
    codecPopValueHex=`printf "%x" $codecPopValue`
    /vendor/bin/setprop ro.vendor.media.codecs.fosext "$codecPopValueHex"
fi
echo "devcfg: ro.vendor.media.codecs.fosext $codecPopValue" > /dev/kmsg

/vendor/bin/setprop ro.vendor.media.codecs.fosext.ready true

config_name=`/vendor/bin/cat /proc/idme/config_name`
config_name_trimmed=${config_name%_*}
if [[ $config_name_trimmed == "kaylaeu" ]]; then
    echo "set product name kyleu for $config_name" > /dev/kmsg
    /vendor/bin/setprop ro.vendor.amz.product.name "kyleu"
else
    if [ $config_name_trimmed == "capri_mx800" ]; then
        echo "set product name ctmx800 for $config_name" > /dev/kmsg
        /vendor/bin/setprop ro.vendor.amz.product.name "ctmx800"
    else
        if [ $config_name_trimmed == "capri_mx700" ]; then
            echo "set product name ctmx700 for $config_name" > /dev/kmsg
            /vendor/bin/setprop ro.vendor.amz.product.name "ctmx700"
        fi
    fi
fi

if [[ $config_name_trimmed == capri* ]]; then
    /vendor/bin/setprop persist.bluetooth.avrcpversion "avrcp15"
fi
