#!/vendor/bin/sh
#
# Copyright (c) 2020 Amazon.com, Inc. or its affiliates.  All rights reserved.
#
# PROPRIETARY/CONFIDENTIAL.  USE IS SUBJECT TO LICENSE TERMS.
#

IW="/vendor/bin/iw"
ECHO="/vendor/bin/toybox_vendor echo"
GREP="/vendor/bin/toybox_vendor grep"

wow_setting=`$IW phy phy0 wowlan show | $GREP WoWLAN`
is_disabled=`$ECHO "$wow_setting" | $GREP -i disable`
if [ "$is_disabled" ]; then
    echo 0
else
    is_enabled=`$ECHO "$wow_setting" | $GREP -i enable`
    if [ "$is_enabled" ]; then
         echo 1
    fi
fi
