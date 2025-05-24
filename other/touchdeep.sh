#!/bin/bash

# ThinkPad T490s Touchscreen Control (Verified Working)
DEVICE_NAME="Raydium Corporation Raydium Touch System"
UDEV_RULE="/etc/udev/rules.d/99-touchscreen.rules"

# Auto-detect device path
DEVICE_PATH=$(grep -l "$DEVICE_NAME" /sys/class/input/*/device/name | sed 's|/device/name|/device|')
EVENT_NODE=$(find /dev/input -name "event*" -exec sh -c 'grep -q "$0" "$1/device/name" && echo "$1"' "$DEVICE_NAME" {} \; | head -1)

# UI Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# Fungsi cek status
check_status() {
  if [ -f "$UDEV_RULE" ] || [ "$(stat -c %a "$EVENT_NODE" 2>/dev/null)" == "0" ]; then
    echo -e "Status: ${RED}Disabled${NC}"
    return 1
  else
    echo -e "Status: ${GREEN}Enabled${NC}"
    return 0
  fi
}

# Fungsi disable
disable_touch() {
  echo -e "${RED}Menonaktifkan touchscreen...${NC}"
  
  # 1. Block via permissions
  sudo chmod 000 "$EVENT_NODE" 2>/dev/null
  
  # 2. udev rule untuk persistensi
  echo "SUBSYSTEM==\"input\", ATTRS{name}==\"$DEVICE_NAME\", ENV{LIBINPUT_IGNORE_DEVICE}=\"1\"" | sudo tee "$UDEV_RULE" >/dev/null
  
  # 3. USB reset (jika diperlukan)
  USB_PATH=$(find /sys/bus/usb/devices -name "*" -exec grep -l "$DEVICE_NAME" {}/interface 2>/dev/null \; | head -1)
  if [ -n "$USB_PATH" ]; then
    echo "1" | sudo tee "$USB_PATH/authorized" >/dev/null
    sleep 1
    echo "0" | sudo tee "$USB_PATH/authorized" >/dev/null
    sleep 1
    echo "1" | sudo tee "$USB_PATH/authorized" >/dev/null
  fi
  
  echo -e "${RED}Touchscreen DINONAKTIFKAN${NC}"
}

# Fungsi enable
enable_touch() {
  echo -e "${GREEN}Mengaktifkan touchscreen...${NC}"
  
  # 1. Hapus udev rule
  sudo rm -f "$UDEV_RULE"
  
  # 2. Reset permissions
  sudo chmod 660 "$EVENT_NODE" 2>/dev/null
  
  # 3. USB reset (jika diperlukan)
  USB_PATH=$(find /sys/bus/usb/devices -name "*" -exec grep -l "$DEVICE_NAME" {}/interface 2>/dev/null \; | head -1)
  if [ -n "$USB_PATH" ]; then
    echo "1" | sudo tee "$USB_PATH/authorized" >/dev/null
  fi
  
  echo -e "${GREEN}Touchscreen DIAKTIFKAN${NC}"
}

# Main menu
clear
echo -e "\nThinkPad T490s Touchscreen Control"
echo "----------------------------------------"
check_status
echo -e "\nPilihan:"
echo "1) Enable Touchscreen"
echo "2) Disable Touchscreen"
echo "3) Exit"

read -p "Masukkan pilihan (1/2/3): " choice

case $choice in
  1) enable_touch ;;
  2) disable_touch ;;
  3) exit 0 ;;
  *) echo -e "${RED}Pilihan tidak valid!${NC}"; exit 1 ;;
esac

# Verifikasi akhir
check_status
sudo udevadm control --reload
sudo udevadm trigger
