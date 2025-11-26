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

Name:           subsys-restart-app
Version:        2025.2
Release:        1%{?dist}
Summary:        APU app for Subsystem Restart TRD

License:        Proprietary
Source0:        %{name}-%{version}.tar.gz

BuildArch:      noarch
Requires:       /usr/bin/python3

%description
Subsystem Restart Application containing Python scripts for versal restart functionality on the APU side.
This package installs subsys-restart-app.py, subsys-restart-cmd.py, subsys-restart-funcs.py, and utility.py.

%prep
%setup -q

%build
# Nothing to build for Python scripts
# configure subsys-restart-funcs.py as per build board

# No build-time modifications needed for Python scripts


%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/opt/subsys-restart-app

# Install Python scripts
install -m 755 subsys-restart-app.py $RPM_BUILD_ROOT/opt/subsys-restart-app/
install -m 755 subsys-restart-cmd.py $RPM_BUILD_ROOT/opt/subsys-restart-app/
install -m 755 subsys-restart-funcs.py $RPM_BUILD_ROOT/opt/subsys-restart-app/
install -m 755 utility.py $RPM_BUILD_ROOT/opt/subsys-restart-app/

# Extract configuration from config.json and update DEV_CONF in the installed subsys-restart-funcs.py
CONFIG_CONTENT=$(sed -n '/^{/,/^}/p' ../../../../%{platform}/%{board}/config.json | sed '1d;$d')
if [ -n "$CONFIG_CONTENT" ]; then
    sed -i "/^DEV_CONF = {}/c\\
DEV_CONF = {\\
$CONFIG_CONTENT\\
}" $RPM_BUILD_ROOT/opt/subsys-restart-app/subsys-restart-funcs.py
    echo "Updated DEV_CONF in installed file with configuration from ../../../../%{platform}/%{board}/config.json"
else
    echo "Warning: No configuration found in ../../../../%{platform}/%{board}/config.json"
fi

# Install service setup scripts
mkdir -p $RPM_BUILD_ROOT/opt/subsys-restart-app/scripts
install -m 755 auto-login_service.sh $RPM_BUILD_ROOT/opt/subsys-restart-app/scripts/
install -m 755 auto-start-subsys-restart_service.sh $RPM_BUILD_ROOT/opt/subsys-restart-app/scripts/
install -m 755 package-install-verify.sh $RPM_BUILD_ROOT/opt/subsys-restart-app/scripts/

%files
%dir /opt/subsys-restart-app
%dir /opt/subsys-restart-app/scripts
/opt/subsys-restart-app/subsys-restart-app.py
/opt/subsys-restart-app/subsys-restart-cmd.py
/opt/subsys-restart-app/subsys-restart-funcs.py
/opt/subsys-restart-app/utility.py
/opt/subsys-restart-app/scripts/auto-login_service.sh
/opt/subsys-restart-app/scripts/auto-start-subsys-restart_service.sh
/opt/subsys-restart-app/scripts/package-install-verify.sh

%post
echo "Subsystem Restart Application installed successfully in /opt/subsys-restart-app/"
echo "APU back-end script: /opt/subsys-restart-app/subsys-restart-app.py"
echo "APU command-line script: /opt/subsys-restart-app/subsys-restart-cmd.py"
echo ""

# Step 1: Set up the auto-start service FIRST (before auto-login)
echo "Setting up auto-start service..."
if [ -f "/opt/subsys-restart-app/scripts/auto-start-subsys-restart_service.sh" ]; then
    /opt/subsys-restart-app/scripts/auto-start-subsys-restart_service.sh
    echo "✓ Auto-start service configured successfully"
else
    echo "Warning: auto-start service script not found!"
fi

echo ""

# Step 2: Configure auto-login for root user LAST
echo "Setting up auto-login to root..."
if [ -f "/opt/subsys-restart-app/scripts/auto-login_service.sh" ]; then
    /opt/subsys-restart-app/scripts/auto-login_service.sh
    echo "✓ Auto-login configured successfully"
    echo "Note: You may be automatically logged in after this installation"
else
    echo "Warning: auto-login service script not found!"
fi


echo ""
echo "📋 Installation Complete!"
echo ""
echo "💡 To verify installation, run:"
echo "   /opt/subsys-restart-app/scripts/package-install-verify.sh"
echo ""
echo "💡 Usage:"
echo "   • Service runs automatically: systemctl status subsystem-restart"
echo "   • Command-line: python3 /opt/subsys-restart-app/subsys-restart-cmd.py"
echo "   • View logs: journalctl -u subsystem-restart -f"

%preun
# Stop and disable services before removal (only on complete removal, not upgrade)
if [ $1 -eq 0 ]; then
    echo "Preparing to remove Subsystem Restart Application services..."

    # Remove subsystem-restart service safely
    systemctl stop subsystem-restart.service 2>/dev/null || true
    systemctl disable subsystem-restart.service 2>/dev/null || true
    rm -f /etc/systemd/system/subsystem-restart.service
    
    # Remove auto-login configuration files (DON'T stop active services)
    # This will take effect on next reboot, avoiding session termination
    rm -rf /etc/systemd/system/serial-getty@ttyAMA1.service.d/ 2>/dev/null || true
    rm -rf /etc/systemd/system/serial-getty@ttyPS0.service.d/ 2>/dev/null || true

    # Reload systemd configuration
    systemctl daemon-reload 2>/dev/null || true

    echo "Subsystem Restart Application services removed. Auto-login will be disabled after next reboot."
    echo "Current session will remain active."
fi

%postun
if [ $1 -eq 0 ]; then
    echo "Subsystem Restart Application, services, and auto-login configuration have been completely removed"
    echo "System will return to default login behavior after reboot"
fi
