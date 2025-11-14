#!/bin/bash

###############################################################################
#
# Copyright (C) 2025 Advanced Micro Devices, Inc. All Rights Reserved.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
###############################################################################

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
