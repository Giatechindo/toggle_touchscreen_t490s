#!/bin/bash

# ThinkPad T490s Ultimate Touchscreen Control
# Fix untuk kasus dimana metode sebelumnya tidak bekerja

TOUCH_DEVICE="Raydium Corporation Raydium Touch System"
UDEV_RULE="/etc/udev/rules.d/99-touchscreen.rules"
INPUT_DEVICE=$(grep -l "$TOUCH_DEVICE" /sys/class/input/*/device/name | head -1 | sed 's|/device/name||')
DEVICE_ID=$(cat "$INPUT_DEVICE/id/product")

# Warna UI
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Fungsi disable yang benar-benar bekerja
disable_touch() {
    # 1. Nonaktifkan melalui udev (permanen)
    echo "ACTION==\"add|change\", ATTRS{idProduct}==\"$DEVICE_ID\", ATTR{enabled}=\"0\"" | sudo tee "$UDEV_RULE" >/dev/null
    
    # 2. Nonaktifkan secara hardware
    echo 0 | sudo tee "$INPUT_DEVICE/device/enabled" >/dev/null 2>&1
    
    # 3. Block input events
    sudo chmod 000 "$INPUT_DEVICE/event*" 2>/dev/null
    
    # 4. Unbind dari kernel
    echo "$(cat "$INPUT_DEVICE/device/../idVendor"):$(cat "$INPUT_DEVICE/device/../idProduct")" | sudo tee /sys/bus/usb/drivers/usbhid/unbind >/dev/null 2>&1
    
    echo -e "${RED}Touchscreen DISABLED (instan)${NC}"
}

enable_touch() {
    # 1. Hapus konfigurasi disable
    sudo rm -f "$UDEV_RULE"
    
    # 2. Kembalikan permission
    sudo chmod 666 "$INPUT_DEVICE/event*" 2>/dev/null
    
    # 3. Enable hardware
    echo 1 | sudo tee "$INPUT_DEVICE/device/enabled" >/dev/null 2>&1
    
    # 4. Rebind ke kernel
    echo "$(cat "$INPUT_DEVICE/device/../idVendor"):$(cat "$INPUT_DEVICE/device/../idProduct")" | sudo tee /sys/bus/usb/drivers/usbhid/bind >/dev/null 2>&1
    
    echo -e "${GREEN}Touchscreen ENABLED (instan)${NC}"
}

# Main menu
clear
echo -e "\nThinkPad T490s Touchscreen Control"
echo "----------------------------------------"

# Deteksi status
if [ -f "$UDEV_RULE" ] || [ -f "$INPUT_DEVICE/device/enabled" ] && [ "$(cat "$INPUT_DEVICE/device/enabled" 2>/dev/null)" == "0" ]; then
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
        if [ -f "$UDEV_RULE" ] || [ -f "$INPUT_DEVICE/device/enabled" ] && [ "$(cat "$INPUT_DEVICE/device/enabled" 2>/dev/null)" == "0" ]; then
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
