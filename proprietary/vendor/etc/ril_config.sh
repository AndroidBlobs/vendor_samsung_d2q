#!/vendor/bin/sh

hw_type=`getprop ro.vendor.sim.onebinary`
sim_count=`getprop ro.vendor.sim.count`
is_dsda=`getprop ro.vendor.sim.config`

if [ "$hw_type" = "true" ]; then
    sim_count="2"
    if [ -f /mnt/vendor/efs/factory.prop ]; then
        fac_count=`cat /mnt/vendor/efs/factory.prop |
            sed -n 's/^ro.multisim.simslotcount=//p'`
    elif [ -f /efs/factory.prop ]; then
        fac_count=`cat /efs/factory.prop |
            sed -n 's/^ro.multisim.simslotcount=//p'`
    fi
    if [ "$fac_count" == "1" ] || [ "$fac_count" == "2" ]; then
        sim_count=$fac_count
    fi
fi

case "$sim_count" in
    "1")
        setprop ro.vendor.radio.simslotcount 1
        setprop ro.vendor.radio.multisim.config ss
        ;;
    "2")
        setprop ro.vendor.radio.simslotcount 2

        if [ "$is_dsda" = "dsda" ]; then
            setprop ro.vendor.radio.multisim.config dsda
        else 
            setprop ro.vendor.radio.multisim.config dsds
        fi
        ;;
    *)
        setprop ro.vendor.radio.simslotcount 1
        setprop ro.vendor.radio.multisim.config ss
        ;;
esac

#ro.telephony.default_network
if [ -f /mnt/vendor/efs/telephony.prop ]; then
    net_mode=`cat /mnt/vendor/efs/telephony.prop |
        sed -n 's/^ro.multisim.default_network=//p'`

    #null check
    if [ x$net_mode == x ]; then
        `setprop ro.multisim.telephony.prop_has_wrong_value true`
    else
        `setprop ro.multisim.default_network $net_mode`
    fi
elif [ -f /efs/telephony.prop ]; then
    net_mode=`cat /efs/telephony.prop |
        sed -n 's/^ro.multisim.default_network=//p'`

    #null check
    if [ x$net_mode == x ]; then
        `setprop ro.multisim.telephony.prop_has_wrong_value true`
    else
        `setprop ro.multisim.default_network $net_mode`
    fi
fi
