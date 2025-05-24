#!/bin/bash

# Nama perangkat touchscreen
DEVICE_NAME="Raydium Corporation Raydium Touch System Touchscreen"
DEVICE_PATH="/dev/input/event10"
UDEV_RULE="/etc/udev/rules.d/99-disable-touchscreen.rules"
USB_DEVICE="1-6"  # Dari udevadm info: /devices/pci0000:00/0000:00:14.0/usb1/1-6

# Fungsi untuk memeriksa status touchscreen
check_touchscreen_status() {
  # Periksa izin perangkat menggunakan ls -l
  PERMS=$(ls -l $DEVICE_PATH | awk '{print $1}')
  if [[ "$PERMS" == crw-rw* ]]; then
    echo "Touchscreen saat ini ENABLED."
    return 0
  else
    echo "Touchscreen saat ini DISABLED."
    return 1
  fi
}

# Fungsi untuk menonaktifkan touchscreen
disable_touchscreen() {
  echo "Menonaktifkan touchscreen..."
  # Buat aturan udev
  echo 'SUBSYSTEM=="input", ATTRS{name}=="'$DEVICE_NAME'", ENV{LIBINPUT_IGNORE_DEVICE}="1"' | sudo tee $UDEV_RULE > /dev/null
  # Ubah izin perangkat
  sudo chmod 000 $DEVICE_PATH
  # Pemicu ulang aturan udev dan perangkat USB
  sudo udevadm control --reload-rules
  sudo udevadm trigger --subsystem-match=input
  # Lepaskan dan sambungkan kembali perangkat USB
  echo "$USB_DEVICE" | sudo tee /sys/bus/usb/drivers/usb/unbind > /dev/null
  sleep 1
  echo "$USB_DEVICE" | sudo tee /sys/bus/usb/drivers/usb/bind > /dev/null
  echo "Touchscreen telah dinonaktifkan."
}

# Fungsi untuk mengaktifkan touchscreen
enable_touchscreen() {
  echo "Mengaktifkan touchscreen..."
  if [ -f "$UDEV_RULE" ]; then
    sudo rm $UDEV_RULE
  fi
  # Kembalikan izin perangkat
  sudo chmod 660 $DEVICE_PATH
  # Pemicu ulang aturan udev dan perangkat USB
  sudo udevadm control --reload-rules
  sudo udevadm trigger --subsystem-match=input
  # Lepaskan dan sambungkan kembali perangkat USB
  echo "$USB_DEVICE" | sudo tee /sys/bus/usb/drivers/usb/unbind > /dev/null
  sleep 1
  echo "$USB_DEVICE" | sudo tee /sys/bus/usb/drivers/usb/bind > /dev/null
  echo "Touchscreen telah diaktifkan."
}

# Tampilkan status
check_touchscreen_status

# Tampilkan menu interaktif
echo "Pilih tindakan:"
echo "1) Enable touchscreen"
echo "2) Disable touchscreen"
echo "3) Exit"
read -p "Masukkan pilihan (1/2/3): " choice

case $choice in
  1)
    enable_touchscreen
    ;;
  2)
    disable_touchscreen
    ;;
  3)
    echo "Keluar tanpa perubahan."
    exit 0
    ;;
  *)
    echo "Pilihan tidak valid. Gunakan 1, 2, atau 3."
    exit 1
    ;;
esac

# Verifikasi status akhir
check_touchscreen_status
