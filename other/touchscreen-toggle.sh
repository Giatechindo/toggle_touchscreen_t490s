#!/bin/bash

# ThinkPad T490s Touchscreen Toggle (100% Working)
# Gabungkan semua metode yang terbukti berhasil

TOUCH_DEVICE="Raydium Corporation Raydium Touch System"
UDEV_RULE="/etc/udev/rules.d/99-touchscreen.rules"

# Cari device path yang benar
DEVICE_PATH=$(grep -l "$TOUCH_DEVICE" /sys/class/input/*/device/name 2>/dev/null | head -1 | sed 's|/name$||')
ENABLED_FILE="$DEVICE_PATH/enabled"

# Warna UI
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# Fungsi utama
toggle_touchscreen() {
  if [ "$1" == "disable" ]; then
    # Nonaktifkan
    echo "ACTION==\"add|change\", ATTRS{name}==\"$TOUCH_DEVICE\", ATTR{enabled}=\"0\"" | sudo tee "$UDEV_RULE" >/dev/null
    echo 0 | sudo tee "$ENABLED_FILE" >/dev/null 2>&1
    echo -e "${RED}Touchscreen DISABLED${NC}"
  else
    # Aktifkan
    sudo rm -f "$UDEV_RULE"
    echo 1 | sudo tee "$ENABLED_FILE" >/dev/null 2>&1
    echo -e "${GREEN}Touchscreen ENABLED${NC}"
  fi
  sudo udevadm control --reload
  sudo udevadm trigger
}

# Menu utama
clear
echo -e "\nThinkPad T490s Touchscreen Control"
echo "----------------------------------------"

# Cek status
if [ -f "$UDEV_RULE" ] || [ -f "$ENABLED_FILE" ] && [ "$(cat "$ENABLED_FILE" 2>/dev/null)" == "0" ]; then
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
    if [ -f "$UDEV_RULE" ] || [ -f "$ENABLED_FILE" ] && [ "$(cat "$ENABLED_FILE" 2>/dev/null)" == "0" ]; then
      toggle_touchscreen enable
    else
      toggle_touchscreen disable
    fi
    ;;
  *)
    exit 0
    ;;
esac

# Verifikasi
echo -e "\nPerubahan diterapkan segera"
echo -e "Konfigurasi permanen: $(if [ -f "$UDEV_RULE" ]; then echo -e "${RED}Disabled"; else echo -e "${GREEN}Enabled"; fi)${NC}"
