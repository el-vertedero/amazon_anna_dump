VENDOR_TMP=/tmp

mkdir -p $VENDOR_TMP/dev

# make device nodes
mknod $VENDOR_TMP/dev/eeprom_0 c 228 0 2>/dev/null
mknod $VENDOR_TMP/dev/eeprom_3 c 227 0 2>/dev/null
mknod $VENDOR_TMP/dev/eeprom_4 c 230 0 2>/dev/null

mknod $VENDOR_TMP/dev/localdimming c 186 0 2>/dev/null
mknod $VENDOR_TMP/dev/mtal c 241 0 2>/dev/null
mknod $VENDOR_TMP/dev/mtal_media c 241 0 2>/dev/null
mknod $VENDOR_TMP/dev/mtal_system c 241 0 2>/dev/null
mknod $VENDOR_TMP/dev/cb c 241 8 2>/dev/null
mknod $VENDOR_TMP/dev/cb2 c 241 16 2>/dev/null
mknod $VENDOR_TMP/dev/cli c 241 4 2>/dev/null
mknod $VENDOR_TMP/dev/feeder c 247 0 2>/dev/null
mknod $VENDOR_TMP/dev/fbm_mpeg c 252 69 2>/dev/null
mknod $VENDOR_TMP/dev/fbm_feeder c 252 78 2>/dev/null
mknod $VENDOR_TMP/dev/fbm_feeder_mmp c 252 79 2>/dev/null
mknod $VENDOR_TMP/dev/fbm_venc c 252 101 2>/dev/null
mknod $VENDOR_TMP/dev/fbm_feeder2 c 252 106 2>/dev/null
mknod $VENDOR_TMP/dev/fbm_mpeg2 c 252 108 2>/dev/null
mknod $VENDOR_TMP/dev/fbm_pvr c 252 109 2>/dev/null
mknod $VENDOR_TMP/dev/fbm_shm_vbif c 252 181 2>/dev/null
mknod $VENDOR_TMP/dev/fbm_shm_thumbnail c 252 184 2>/dev/null
mknod $VENDOR_TMP/dev/fbm_shm_ssma c 251 180 2>/dev/null
mknod $VENDOR_TMP/dev/ttyMT3 c 204 19 2>/dev/null

chown system $VENDOR_TMP/dev/mtal_system
chgrp system $VENDOR_TMP/dev/mtal_system
chown media $VENDOR_TMP/dev/mtal_media
chgrp drmrpc $VENDOR_TMP/dev/mtal_media

# symlink device nodes
ln -s $VENDOR_TMP/dev/eeprom_0 /dev/eeprom_0
ln -s $VENDOR_TMP/dev/eeprom_3 /dev/eeprom_3
ln -s $VENDOR_TMP/dev/eeprom_4 /dev/eeprom_4

ln -s $VENDOR_TMP/dev/localdimming /dev/localdimming
ln -s $VENDOR_TMP/dev/mtal /dev/mtal
ln -s $VENDOR_TMP/dev/mtal_media /dev/mtal_media
ln -s $VENDOR_TMP/dev/mtal_system /dev/mtal_system
ln -s $VENDOR_TMP/dev/cb /dev/cb
ln -s $VENDOR_TMP/dev/cb2 /dev/cb2
ln -s $VENDOR_TMP/dev/cli /dev/cli
ln -s $VENDOR_TMP/dev/feeder /dev/feeder
ln -s $VENDOR_TMP/dev/fbm_mpeg /dev/fbm_mpeg
ln -s $VENDOR_TMP/dev/fbm_feeder /dev/fbm_feeder
ln -s $VENDOR_TMP/dev/fbm_feeder_mmp /dev/fbm_feeder_mmp
ln -s $VENDOR_TMP/dev/fbm_venc /dev/fbm_venc
ln -s $VENDOR_TMP/dev/fbm_feeder2 /dev/fbm_feeder2
ln -s $VENDOR_TMP/dev/fbm_mpeg2 /dev/fbm_mpeg2
ln -s $VENDOR_TMP/dev/fbm_pvr /dev/fbm_pvr
ln -s $VENDOR_TMP/dev/fbm_shm_vbif /dev/fbm_shm_vbif
ln -s $VENDOR_TMP/dev/fbm_shm_thumbnail /dev/fbm_shm_thumbnail
ln -s $VENDOR_TMP/dev/fbm_shm_ssma /dev/fbm_shm_ssma
ln -s $VENDOR_TMP/dev/ttyMT3 /dev/ttyMT3

# touch flag for MtkRm
touch /mnt/vendor/tmp/mknod_util_end
