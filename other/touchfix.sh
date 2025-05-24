#!/bin/bash

# ThinkPad T490s Touchscreen Toggle (Fix Instant Effect)
TOUCH_DEVICE="Raydium Corporation Raydium Touch System"
UDEV_RULE="/etc/udev/rules.d/99-touchscreen.rules"
DEVICE_NODE="/dev/input/$(grep -l "$TOUCH_DEVICE" /sys/class/input/*/device/name | grep -o 'event[0-9]*')"

# Fungsi untuk disable langsung
disable_touch() {
    # 1. Nonaktifkan via udev (permanen)
    echo "ACTION==\"add|change\", ATTRS{name}==\"$TOUCH_DEVICE\", ATTR{enabled}=\"0\"" | sudo tee "$UDEV_RULE"
    
    # 2. Force disable sekarang juga
    sudo evtest --grab "$DEVICE_NODE" >/dev/null 2>&1 &
    sleep 0.5
    sudo pkill -f "evtest.*$DEVICE_NODE"
    
    # 3. Block input secara langsung
    sudo chmod 000 "$DEVICE_NODE"
    
    echo -e "\e[31mTouchscreen DISABLED (instan)\e[0m"
}

# Fungsi untuk enable
enable_touch() {
    # 1. Hapus rule disable
    sudo rm -f "$UDEV_RULE"
    
    # 2. Kembalikan permission device
    sudo chmod 666 "$DEVICE_NODE"
    
    # 3. Reload driver
    echo "$TOUCH_DEVICE" | sudo tee /sys/bus/usb/drivers/usbhid/unbind >/dev/null 2>&1
    echo "$TOUCH_DEVICE" | sudo tee /sys/bus/usb/drivers/usbhid/bind >/dev/null 2>&1
    
    echo -e "\e[32mTouchscreen ENABLED (instan)\e[0m"
}

# Menu utama
echo -e "\nThinkPad T490s Touchscreen Control"
echo "----------------------------------------"

if lsmod | grep -q "usbhid"; then
    echo -e "Status: \e[32mEnabled\e[0m"
    echo "1. Disable Touchscreen (Instan)"
else
    echo -e "Status: \e[31mDisabled\e[0m"
    echo "1. Enable Touchscreen (Instan)"
fi
echo "2. Exit"

read -p "Pilihan: " choice

case $choice in
    1)  if lsmod | grep -q "usbhid"; then
            disable_touch
        else
            enable_touch
        fi
        ;;
    *)  exit 0 ;;
esac

sudo udevadm control --reload
sudo udevadm trigger
