#!/system/bin/sh

TOOLBOX=/vendor/bin/toybox_vendor
TAG="iperftun"
TMP=""
IPT_PID=0
IPS_PID=0
PORT=5001
IPTABLES=/system/bin/iptables
IP=/system/bin/ip
IPERFTUN=/vendor/bin/iperftun
LOG=/system/bin/log

function IPT_LOG {
    $LOG -t $TAG "$@"
}

function start_setup_iperf() {
    echo "Args : $@"
    if [[ $1 == "0" ]]; then
	$IPERFTUN -0 &
	IPT_PID=$!
    elif [[ $1 == "1" || $1 == "2" || $1 == "3" || $1 == "4" ]]; then
	M=$1
	IPT_LOG "Using port : ${PORT}"
	TMP=`cat /proc/sys/net/ipv4/ping_group_range`
	echo "0 2147483647" > /proc/sys/net/ipv4/ping_group_range

	TUN="/dev/tun"
	# Destination IP address
	DEST_IP=$2
	if [[ $DEST_IP == 'gw' ]]; then
	    # Find the defualt GW
	    S=`$IP route get 8.8.8.8 | grep dev`
	    if [ $? -ne 0 ]; then
		IPT_LOG "Unable to find GW's IP address"
		exit 1
	    fi
	    ARR=($S)
	    DEST_IP=${ARR[2]}
	    IPT_LOG "Using the default gw IP - $DEST_IP"
	fi

	# Destination MAC address
	S=`cat /proc/net/arp | grep "$DEST_IP "`
	ARR=($S)
	DEST_MAC=${ARR[3]}
	IPT_LOG "Destination MAC addr. - $DEST_MAC"

	# The interface to use for egress
	S=`$IP route get $DEST_IP | grep dev`
	ARR=($S)
	case $S in
	    # FOS6,7 - 192.168.0.1 dev wlan0 table wlan0 src 192.168.0.192
	    *" table "*)
		OFACE=${ARR[2]}
		LOCAL_IP=${ARR[6]}
		;;
	    # FOS5 - 192.168.0.1 dev wlan0  src 192.168.0.243  uid 0
	    *" src "*)
		OFACE=${ARR[2]}
		LOCAL_IP=${ARR[4]}
		;;
	    *)
		IPT_LOG "Unable to retrive local IP"
		exit 1
		;;
	esac

	$IPERFTUN -$1 -D $TUN -i tun_icmp -o $OFACE -s $DEST_IP -l $LOCAL_IP -m $DEST_MAC -p ${PORT} &
	IPT_PID=$!
    fi
}

function stop_setup_iperf {
    PSWR=`ps -A | grep iperftun`
    IFS=' '; read U WPID OT <<< $PSWR
    kill $WPID
}

function start {
    # Start in daemon mode
    if [[ $# == 0 ]]; then
	start_setup_iperf "0"
	exit 0
    fi

    if [[ $1 == "-h" ]]; then
	echo "Usage: iperftun.sh [method] [dest_ip|gw]"
	exit 0
    fi

    # Batch mode
    if [[ $1 == "all" ]]; then
	shift
	start_setup_iperf "1" $@
	exit 0
    fi

    start_setup_iperf $@
}

function stop {
    IPT_LOG "Enter STOP"
    stop_setup_iperf $@
}

start $@

exit 0
