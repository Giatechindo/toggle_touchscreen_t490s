#!/bin/bash

echo "🔍 Mencari perangkat touchscreen..."
TOUCH_ID=$(xinput list | grep -i touchscreen | grep -o 'id=[0-9]\+' | cut -d= -f2)

if [ -z "$TOUCH_ID" ]; then
    echo "❌ Touchscreen tidak ditemukan."
    exit 1
fi

echo "✋ Menonaktifkan touchscreen dengan ID: $TOUCH_ID..."
xinput disable "$TOUCH_ID"

echo "✅ Touchscreen dimatikan sementara. Akan aktif lagi setelah reboot atau logout."
