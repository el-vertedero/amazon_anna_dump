#!/vendor/bin/sh
while true
do
    BOOTANIM_EXIT=`/vendor/bin/getprop service.bootanim.exit`
    if [ "${BOOTANIM_EXIT}" = "1" ]; then
        log -t "bootanim_exit_check" "service.bootanim.exit=1, create file /data/vendor/tmp/bootanim_completed"
        date -u > /data/vendor/tmp/bootanim_completed
        break
    fi
    sleep 0.1
done

