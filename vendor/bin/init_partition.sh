#!/vendor/bin/sh

FACTORY_RESET_FLAG=/data/vendor/tv_database_inited.ini
RW_PARTS="cha chb eeprom_a dvbsdb_a basic_a schedpvr"

function reset_part()
{
    echo "Factory reset $1." > /dev/kmsg
    dd if=/dev/zero of=/dev/block/platform/mstar_mci.0/by-name/$1 bs=1m count=1
}

function set_reset_flag()
{
    touch $FACTORY_RESET_FLAG
    chmod -R 660 $FACTORY_RESET_FLAG
    chown -R 1000:1000 $FACTORY_RESET_FLAG
}

if [[ -f $FACTORY_RESET_FLAG ]]; then
    echo "Don't need to factory reset R/W partitions." > /dev/kmsg
    exit 0
fi

# factory reset detected! re-initialize upgrade.
for part in $RW_PARTS; do
    reset_part $part
done

set_reset_flag

exit 0
