#!/bin/bash

# Configure auto-login for ttyAMA0
mkdir -p /etc/systemd/system/serial-getty@ttyAMA1.service.d/
cat > /etc/systemd/system/serial-getty@ttyAMA1.service.d/autologin.conf << 'EOF'
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin root --noclear %I $TERM
EOF

# Configure auto-login for ttyPS0 (backup)
mkdir -p /etc/systemd/system/serial-getty@ttyPS0.service.d/
cat > /etc/systemd/system/serial-getty@ttyPS0.service.d/autologin.conf << 'EOF'
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin root --noclear %I $TERM
EOF

# Reload systemd
systemctl daemon-reload

# Enable and restart services
systemctl enable serial-getty@ttyAMA1.service 2>/dev/null
systemctl restart serial-getty@ttyAMA1.service 2>/dev/null
systemctl enable serial-getty@ttyPS0.service 2>/dev/null
systemctl restart serial-getty@ttyPS0.service 2>/dev/null

echo "Auto-login configured. Check which service is active:"
systemctl status serial-getty@ttyAMA1.service | grep Active
systemctl status serial-getty@ttyPS0.service | grep Active

echo ""
echo "Boot console from kernel cmdline:"
cat /proc/cmdline | grep -o 'console=[^ ]*'
