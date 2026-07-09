#!/vendor/bin/sh
## Copyright (c) 2021 Amazon.com, Inc. or its affiliates.  All rights reserved.
##
## PROPRIETARY/CONFIDENTIAL.  USE IS SUBJECT TO LICENSE TERMS.

GETPROP="/vendor/bin/getprop"
IPTABLES="/system/bin/iptables"

CERTIFICATION_FLAG=`$GETPROP persist.disable.dns.8888`

if [ "$CERTIFICATION_FLAG" == "on" ]; then
    $IPTABLES -I OUTPUT -d 8.8.8.8 -j REJECT
    exit
fi

