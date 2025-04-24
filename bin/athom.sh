#! /bin/zsh -eu

setopt warn_create_global

PROGRAM=${0:t}

if [[ $# -lt 1 ]]; then
    echo "$PROGRAM: usage"
    echo "$PROGRAM Room Name"
    exit 1
fi

room="${(C)@}" # Upcase the first letter of each word.
friendly_name="$room Presence Sensor"

name=${friendly_name:l} # Lower case the entire string.
name=${name// /-} # Replace spaces with dashes.

source venv-esphome/bin/activate

cp -a athom-configs/athom-presence-sensor.yaml .

perl -pi -e "s/\@\@\@NAME\@\@\@/$name/; s/\@\@\@FRIENDLYNAME\@\@\@/$friendly_name/; s/\@\@\@ROOM\@\@\@/$room/" athom-presence-sensor.yaml

less athom-presence-sensor.yaml

esphome compile athom-presence-sensor.yaml

echo
cp -a .esphome/build/$name/.pioenvs/$name/firmware.bin $name.bin
ls -l $name.bin

device="${name}.iot.mandarb.com"

cat <<EOF
To flash this device, run the following command:
$(host $device)

esphome run --device $device athom-presence-sensor.yaml && rm $name.bin athom-presence-sensor.yaml
EOF
