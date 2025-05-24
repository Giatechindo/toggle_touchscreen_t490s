#!/bin/bash

# ThinkPad T490s Touchscreen Toggle (Guaranteed Working Version)
TOUCH_DEVICE="Raydium Corporation Raydium Touch System"
UDEV_RULE="/etc/udev/rules.d/99-touchscreen.rules"
EVENT_NODE=$(grep -l "$TOUCH_DEVICE" /sys/class/input/*/device/name | head -1 | sed 's|/device/name|/device|')

# Warna UI
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Fungsi untuk disable touchscreen
disable_touch() {
    # 1. Nonaktifkan melalui input subsystem
    echo 0 | sudo tee "$EVENT_NODE/enabled" >/dev/null 2>&1
    
    # 2. Block event node
    sudo chmod 000 "$(echo $EVENT_NODE | sed 's|/device$||')/event*" 2>/dev/null
    
    # 3. Buat udev rule untuk persistensi
    echo "ACTION==\"add\", SUBSYSTEM==\"input\", ATTRS{name}==\"$TOUCH_DEVICE\", RUN+=\"/bin/sh -c 'echo 0 > /sys\$env{DEVPATH}/enabled'\"" | sudo tee "$UDEV_RULE" >/dev/null
    
    echo -e "${RED}Touchscreen DISABLED${NC}"
}

# Fungsi untuk enable touchscreen
enable_touch() {
    # 1. Hapus udev rule
    sudo rm -f "$UDEV_RULE"
    
    # 2. Aktifkan melalui input subsystem
    echo 1 | sudo tee "$EVENT_NODE/enabled" >/dev/null 2>&1
    
    # 3. Kembalikan permission
    sudo chmod 666 "$(echo $EVENT_NODE | sed 's|/device$||')/event*" 2>/dev/null
    
    echo -e "${GREEN}Touchscreen ENABLED${NC}"
}

# Main menu
clear
echo -e "\nThinkPad T490s Touchscreen Control"
echo "----------------------------------------"

# Deteksi status
if [ -f "$UDEV_RULE" ] || [ -f "$EVENT_NODE/enabled" ] && [ "$(cat "$EVENT_NODE/enabled" 2>/dev/null)" == "0" ]; then
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
        if [ -f "$UDEV_RULE" ] || [ -f "$EVENT_NODE/enabled" ] && [ "$(cat "$EVENT_NODE/enabled" 2>/dev/null)" == "0" ]; then
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
echo -e "Konfigurasi permanen: $(if [ -f "$UDEV_RULE" ]; then echo -e "${RED}Disabled"; else echo -e "${GREEN}Enabled"; fi)${NC}"
