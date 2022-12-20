# one-click-android-gateway
https://www.youtube.com/embed/ES3ScIiueS8

```
wget https://raw.githubusercontent.com/kontorol/one-click-android-gateway/main/proxy.sh && chmod +x ./proxy.sh
```

## Android shell
## The computer uses ADB
 Download address:

- Windows version: https://dl.google.com/android/repository/platform-tools-latest-windows.zip
- Mac version: https://dl.google.com/android/repository/platform-tools-latest-darwin.zip
- Linux version: https://dl.google.com/android/repository/platform-tools-latest-linux.zip

## How to use:

- To turn on "Android Debugging", in "Settings" - "Developer Options" - "Android Debugging", if you cannot find "Developer Options", you need to click "Version Number" 7 times in a row in "Settings" - "About Phone"

### View devices:
```
adb devices
```

### Wireless connection:
```
adb connect 192.168.0.111
```
- For wireless connection, you need to enable network ADB debugging

### Enter the shell:
```
adb shell
```

### Upload files to your phone:
```
adb push 电脑路径 手机路径
```

### Download the file to your computer:
```
adb pull 手机路径 电脑路径
```

### Install the APK:
```
adb install APK路径
```

## Mobile phones use Termux

### Download address:
- https://github.com/termux/termux-app/releases

### How to use:
- (omitted)

### Configure a bypass gateway
- It is recommended to set the mobile phone as a fixed IP first, there are many ways please Google by yourself

### One-click scripting
```
#!/system/bin/sh

tun='tun0' #虚拟接口名称
dev='wlan0' #物理接口名称，eth0、wlan0
interval=3 #检测网络状态间隔(秒)
pref=18000 #路由策略优先级

# 开启IP转发功能
sysctl -w net.ipv4.ip_forward=1

# 清除filter表转发链规则
iptables -F FORWARD

# 添加NAT转换，部分第三方VPN需要此设置否则无法上网，若要关闭请注释掉
iptables -t nat -A POSTROUTING -o $tun -j MASQUERADE

# 添加路由策略
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
```

### Grant executable permissions:
```
chmod +x proxy.sh
```
### Execute:
```
nohup ./proxy.sh &
```

### Change the gateway
- Global Device Change: Modify the DHCP settings of the primary route
- Single device change: Change the gateway for the device

## Troubleshooting
- Every time the Android system switches network settings, some settings will be reset, and some "permanent" configuration methods will also be reset after the phone restarts

### Check whether IP forwarding is enabled:
```
cat /proc/sys/net/ipv4/ip_forward
```

### Check if iptables allow packets through:
```
iptables -nvL -t (filter|nat|mangle)
```

### Check the routing policy:
```
ip rule
```

### Check the NIC interface:
```
ip a
```
