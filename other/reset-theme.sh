#!/bin/bash

# Direktori backup
BACKUP_DIR="$HOME/.themes-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Backup tema dari ~/.themes
if [ -d "$HOME/.themes" ]; then
    echo "📦 Membackup ~/.themes ke $BACKUP_DIR"
    cp -r "$HOME/.themes"/* "$BACKUP_DIR/"
else
    echo "⚠️ Direktori ~/.themes tidak ditemukan"
fi

# Reset GTK, Shell, dan Window Manager theme ke Adwaita
echo "🧼 Mereset tema ke Adwaita..."
gsettings set org.gnome.desktop.interface gtk-theme "Adwaita"
gsettings set org.gnome.desktop.wm.preferences theme "Adwaita"
gsettings set org.gnome.shell.extensions.user-theme name "Adwaita"

# Deteksi sesi Wayland atau X11
SESSION_TYPE=$(echo $XDG_SESSION_TYPE)
if [[ "$SESSION_TYPE" == "x11" ]]; then
    echo "🔄 Restart GNOME Shell (X11) via Alt+F2 > r"
    echo "Silakan tekan Alt + F2, ketik: r, lalu Enter"
else
    echo "🔁 Kamu menggunakan Wayland. Silakan reboot manual agar semua efek tema hilang sepenuhnya."
fi

echo "✅ Selesai. Semua tema dikembalikan ke default."
