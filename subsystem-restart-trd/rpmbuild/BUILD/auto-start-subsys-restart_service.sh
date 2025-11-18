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

#*******************************************************************************
#
# Subsystem Restart Application Auto-Start Script
#
# This script creates a background service for the Subsystem Restart application
# on boot after initial rpm Package installation
#
#*******************************************************************************

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
PURPLE='\033[0;95m'
RESET='\033[0m'

VERSION="2025.2"
TRD_SERVICE="subsystem-restart"

echo -e "${CYAN}Creating auto-start service for ${TRD_SERVICE}...${RESET}"

# Verify that subsys-restart-app is installed (should be done via RPM)
if [ ! -d "/opt/subsys-restart-app" ] || [ ! -f "/opt/subsys-restart-app/subsys-restart-app.py" ]; then
    echo -e "${RED}Error: Subsystem Restart Application not found! Please install subsys-restart-app RPM package first.${RESET}"
    echo -e "${YELLOW}Expected location: /opt/subsys-restart-app/subsys-restart-app.py${RESET}"
    exit 1
fi

echo -e "${GREEN}Subsystem Restart Application found at /opt/subsys-restart-app/${RESET}"

# if 'sc_app' is present then skip everything and exit as success
if [ -x "$(which sc_app)" ]; then
    echo -e "${YELLOW}Package installation on System Controller${RESET}"
    echo -e "${CYAN}Nothing further needed, please also install the .rpm package on Versal2${RESET}"
    echo -e "${CYAN}💡 Hint: Run 'python3 /opt/subsys-restart-app/subsys-restart-cmd.py' to use the command-line version of the app${RESET}"
    exit 0
else
    echo -e "${YELLOW}Package installation on Versal2${RESET}"
fi

# Step 2: Create systemd service
cat > /etc/systemd/system/$TRD_SERVICE.service << EOF
[Unit]
Description=Subsystem Restart Application Service
After=basic.target
Wants=basic.target

[Service]
Type=simple
ExecStart=/usr/bin/python3 -u /opt/subsys-restart-app/subsys-restart-app.py
Restart=always
RestartSec=10s
StandardOutput=journal+console
StandardError=journal+console
User=root
WorkingDirectory=/opt/subsys-restart-app
Environment=PYTHONUNBUFFERED=1

[Install]
WantedBy=multi-user.target
EOF

# Step 3: Enable and start the service
systemctl daemon-reload
systemctl enable $TRD_SERVICE.service
systemctl start $TRD_SERVICE.service

# Step 4: Show status and usage hint
echo ""
echo -e "${GREEN}Subsystem Restart Service created and started successfully!${RESET}"
echo -e "${CYAN}Checking service status...${RESET}"
sleep 2
systemctl status $TRD_SERVICE.service --no-pager

echo ""
echo -e "${PURPLE}=== Subsystem Restart Application Usage ===${RESET}"
echo -e "${YELLOW}Main service (running):     /opt/subsys-restart-app/subsys-restart-app.py${RESET}"
echo -e "${YELLOW}Command-line interface:     /opt/subsys-restart-app/subsys-restart-cmd.py${RESET}"
echo ""
echo -e "${CYAN}💡 Hint: Run 'python3 /opt/subsys-restart-app/subsys-restart-cmd.py' to use the command-line version of the app${RESET}"
