#!/vendor/bin/sh

AUDIO_CONFIG_ROOT="odm vendor system"
AUDIO_CONFIG_CHILD_PATH="etc"

AUDIO_CONFIG_FEATURE_FILES="audio_effects.xml"

AUDIO_EFFECT_XML_PROPERTY="ro.audio.xml_effect.path"

board_id=
if [ -f /proc/idme/board_id ]; then
    board_id=`/vendor/bin/cat /proc/idme/board_id`
    board_id=${board_id:0:4}
else
    return
fi

for root in $AUDIO_CONFIG_ROOT; do
    AUDIO_EFFECT_XML_PATH=${root}/etc/${AUDIO_CONFIG_FEATURE_FILES}_${board_id}
    if [ -f $AUDIO_EFFECT_XML_PATH ]; then
        setprop $AUDIO_EFFECT_XML_PROPERTY $AUDIO_EFFECT_XML_PATH
        break
    fi
done;
