#!/vendor/bin/sh

fos_flags_path='/proc/idme/fos_flags'
dev_flags_path='/proc/idme/dev_flags'
FOS_DEV_FLAGS_NO_STR=256
FOS_DEV_FLAGS_USB_MODE_PHERIPHERAL=0x1
FOS_FLAGS_ADB_ROOT=2
FOS_DEV_FLAGS_STR_LESS_DELAY=0x8

# set ir protocol
/vendor/bin/setprop ro.odm.ir.protocol rc-5

# set ro.product.region based on idme region
idme_region=`/vendor/bin/cat /proc/idme/region`
/vendor/bin/setprop ro.product.region "$idme_region"

# keep perf governor
/vendor/bin/setprop vendor.mtk.use.perf.gov true

# set product model
idme_prod_model=`/vendor/bin/cat /proc/idme/product_model`
/vendor/bin/setprop ro.product.model_trigger "$idme_prod_model"
/vendor/bin/setprop ro.product.model.ready yes

#set ro.poweron.src and sys.poweron.src based on wakeup reason
power_on_reason=`/vendor/bin/cat /proc/Mstar-poweron-reason`
/vendor/bin/setprop ro.poweron.src "$power_on_reason"
/vendor/bin/setprop sys.poweron.src "$power_on_reason"

# populate ro.nrdp.oemmodel
idme_mfr_name=`/vendor/bin/cat /proc/idme/mfr_name`
idme_mfr_model=`/vendor/bin/cat /proc/idme/mfr_model`
prop_oem_model=$idme_mfr_name"_"$idme_mfr_model
# for settings use
/vendor/bin/setprop ro.product.oemmodel "$prop_oem_model"
/vendor/bin/setprop ro.nrdp.oemmodel "$prop_oem_model"
# for netflix use
/vendor/bin/setprop ro.vendor.nrdp.oemmodel "$prop_oem_model"

# set suspend blocker per FOS_DEV_FLAGS_NO_STR
dev_flags=`/vendor/bin/cat $dev_flags_path`
dev_flags=0x$dev_flags
if [ $(($dev_flags & $FOS_DEV_FLAGS_NO_STR)) != "0" ] ; then
    /vendor/bin/setprop odm.hold.wakelock.idme y
fi

if [ $(($dev_flags & $FOS_DEV_FLAGS_STR_LESS_DELAY)) != "0" ] ; then
    /vendor/bin/setprop sys.str.delay_before_str 10000
fi

# enable USB device mode if ADB is enabled
if [ $(($dev_flags & $FOS_DEV_FLAGS_USB_MODE_PHERIPHERAL)) != "0" ] ; then
    /vendor/bin/setprop vendor.usb.debugging.init y
else
    /vendor/bin/setprop vendor.usb.debugging.init n
fi

# set dvbs property
product_name=`/vendor/bin/cat /proc/idme/product_name`
oem_data=`/vendor/bin/cat /proc/idme/oem_data`
if [[ $oem_data == *"dvbs=1"* ]]; then
   /vendor/bin/setprop ro.vendor.mtk.system.dvbs.existed 1
   /vendor/bin/setprop ro.vendor.mtk.system.ci.existed 1
   /vendor/bin/setprop ro.vendor.fos.dvbs.existed 1
   /vendor/bin/setprop ro.vendor.fos.ci.existed 1
else
   /vendor/bin/setprop ro.vendor.mtk.system.dvbs.existed 0
   /vendor/bin/setprop ro.vendor.mtk.system.ci.existed 0
   /vendor/bin/setprop ro.vendor.fos.dvbs.existed 0
   /vendor/bin/setprop ro.vendor.fos.ci.existed 0
fi

# set model_name and memc property
idme_model_name=`/vendor/bin/cat /proc/idme/model_name`
idme_memc=`/vendor/bin/cat /proc/idme/memc`
/vendor/bin/setprop ro.vendor.mstar.idme.model_name "$idme_model_name"
/vendor/bin/setprop ro.vendor.mstar.idme.memc "$idme_memc"

# Anna HW has only one LNB value, which is different than other projects
# Use a property to indicate this
/vendor/bin/setprop ro.vendor.fos.lnb.fixed 1

# farfield support
cmdline=`/vendor/bin/cat /proc/cmdline`
if [[ $cmdline == *"farfield.dsp.name=mt8570"* ]]; then
    /vendor/bin/setprop ro.vendor.dsp.name mt8570
fi

# disable loading DBC ko for models with LDM feature. DBC is exclusive with LDM.
DISPLAY_LDM_MASK=0x1
ldm_type=`/vendor/bin/getprop ro.boot.support_ldm`
echo "devcfg: ldm_type: $ldm_type" > /dev/kmsg
# make sure boolean value
if [ $(($ldm_type & $DISPLAY_LDM_MASK)) != "1" ] ; then
        /vendor/bin/setprop ro.vendor.mstar.dbc_name dynamic_backlight_T
fi
