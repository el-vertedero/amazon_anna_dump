#!/vendor/bin/sh
c=$(cat /proc/cmdline)
c="${c##*bootvideo.enable=}"
c="${c%% *}"

if [ $c == 1 ]; then
    echo "Run bootvideo!"
    /vendor/bin/demo_bootvideo /vendor/stream/video.ts
else
    touch /data/vendor/tmp/chk_bootvideo_done
fi
