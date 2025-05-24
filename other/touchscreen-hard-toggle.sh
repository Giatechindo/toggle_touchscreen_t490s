#!/bin/bash

# ThinkPad T490s Touchscreen Hard Disable/Enable
TOUCH_DEVICE="Raydium Corporation Raydium Touch System"
UDEV_RULE="/etc/udev/rules.d/99-touchscreen.rules"
EVENT_DEVICE=$(grep -l "$TOUCH_DEVICE" /sys/class/input/*/device/name | head -1 | sed 's|/device/name||')

# Warna UI
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Fungsi untuk disable
disable_touch() {
    # 1. Block device node secara permanen
    echo "SUBSYSTEM==\"input\", KERNEL==\"event*\", ATTRS{name}==\"$TOUCH_DEVICE\", RUN+=\"/bin/sh -c 'chmod 000 /dev/input/%k'\"" | sudo tee "$UDEV_RULE" >/dev/null
    
    # 2. Terapkan segera
    sudo chmod 000 "$EVENT_DEVICE/event"*
    
    # 3. Force release device
    sudo fuser -k "$EVENT_DEVICE/event"* >/dev/null 2>&1
    
    echo -e "${RED}Touchscreen DISABLED (Permanen)${NC}"
}

# Fungsi untuk enable
enable_touch() {
    # 1. Hapus block
    sudo rm -f "$UDEV_RULE"
    
    # 2. Kembalikan permission
    sudo chmod 666 "$EVENT_DEVICE/event"*
    
    echo -e "${GREEN}Touchscreen ENABLED${NC}"
}

# Main menu
clear
echo -e "\nThinkPad T490s Touchscreen Control"
echo "----------------------------------------"

# Deteksi status
if [ -f "$UDEV_RULE" ] || [ $(stat -c %a "$EVENT_DEVICE/event"* 2>/dev/null | head -1) == "0" ]; then
    echo -e "Status: ${RED}Disabled${NC}"
    echo -e "\n1. Enable Touchscreen"
else
    echo -e "Status: ${GREEN}Enabled${NC}"
    echo -e "\n1. Disable Touchscreen"
fi
echo "2. Exit"

read -p "Pilihan: " choice

case $choice in
    1)
        if [ -f "$UDEV_RULE" ] || [ $(stat -c %a "$EVENT_DEVICE/event"* 2>/dev/null | head -1) == "0" ]; then
            enable_touch
        else
            disable_touch
        fi
        ;;
    *)
        exit 0
        ;;
esac

# Verifikasi
echo -e "\nPerubahan diterapkan segera"
sudo udevadm control --reload
sudo udevadm trigger
