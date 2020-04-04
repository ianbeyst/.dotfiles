#!/bin/sh
acpi -b | awk -F'[,:%]' '{print $2, $3}' | {
    read -r status capacity

    if [ "$status" = Discharging -a "$capacity" -lt 11 ]; then
        su -l -s /bin/sh io -c 'export DISPLAY=:0; zenity --warning --text="SoC ≤ 0.1" --icon-name=""'
    fi

    if [ "$status" = Discharging -a "$capacity" -lt 6 ]; then
        logger "Battery critical state of charge, suspending..."
        su -l -s /bin/sh io -c 'export DISPLAY=:0; slock' &
        pm-suspend
    fi
}
