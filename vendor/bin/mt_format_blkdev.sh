#!/vendor/bin/sh

make_ext4fs_bin=/system/bin/mkfs.ext4
bin_dir=/vendor/bin/
blkdev_dir=/dev/block/bootdevice/by-name/

format_partitions=`${bin_dir}sed 's/ /\n/g' /proc/cmdline | \
	${bin_dir}sed -n 's/.*format_blkdev=\(.*\)/\1/p' | ${bin_dir}sed 's/,/ /g'`

if [ -z "$format_partitions" ]; then
	${bin_dir}echo "format_partitions is NULL"
	exit 0
fi

${bin_dir}echo "try to format partition '$format_partitions' ..."
for partition in $format_partitions
do
	blkdev="${blkdev_dir}${partition}"

	if [ ! -e "$blkdev" ]; then
		${bin_dir}echo "warn: cannot find $partition by path $blkdev"
		continue
	fi

	$make_ext4fs_bin $blkdev
	${bin_dir}echo "command '$make_ext4fs_bin $blkdev' returned with $?"
done
${bin_dir}sync

