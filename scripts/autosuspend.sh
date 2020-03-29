#!/bin/sh
acpi -b | awk -F'[,:%]' '{print $2, $3}' | {
    read -r status capacity
    if [ "$status" = Discharging -a "$capacity" -lt 6 ]; then
        logger "Battery critical state of charge, suspending..."
        su -l -s /bin/sh io -c 'export DISPLAY=:0; slock' &
        pm-suspend
    fi
}
