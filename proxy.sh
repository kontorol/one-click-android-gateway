#!/system/bin/sh

tun='tun0' #virtual interface name
dev='wlan0' #physical interface name，eth0、wlan0
interval=3 #Check network status interval (seconds)
pref=18000 #Routing Policy Priority

# Enable IP forwarding function
sysctl -w net.ipv4.ip_forward=1

# Clear filter table forwarding chain rules
iptables -F FORWARD

# Add NAT conversion, some third-party VPNs need this setting, otherwise they will not be able to access the Internet, if you want to close it, please comment it out
iptables -t nat -A POSTROUTING -o $tun -j MASQUERADE

# Add routing policy
ip rule add from all table main pref $pref
ip rule add from all iif $dev table $tun pref $(expr $pref - 1)

contain="from all iif $dev lookup $tun"

while true ;do
    if [[ $(ip rule) != *$contain* ]]; then
            if [[ $(ip ad|grep 'state UP') != *$dev* ]]; then
                echo -e "[$(date "+%H:%M:%S")]dev has been lost."
            else
                ip rule add from all iif $dev table $tun pref $(expr $pref - 1)
                echo -e "[$(date "+%H:%M:%S")]network changed, reset the routing policy."
            fi
    fi
    sleep $interval
done
