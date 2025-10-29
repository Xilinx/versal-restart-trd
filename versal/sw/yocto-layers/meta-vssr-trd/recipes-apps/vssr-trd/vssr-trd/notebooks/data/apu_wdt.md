## APU - WDT Recovery

This function demonstrates the system recovery through FPD Watchdog.

The Linux, running on APU subsystem, launches the TRD application `watchdog-daemon` as daemon using the init script `watchdog-daemon-init`. This application is responsible for configuring and kicking the FPD Watchdog in the system for infinite time.

The watchdog is configured with the timeout value of __20 seconds__ and is kicked every __5 seconds__.

To test the recovery, in Linux start the watchdog-daemon (automatically done at boot) and simulate a hang by killing the watchdog-daemon application.

```
# Start the Watchdog
sudo systemctl start watchdog-daemon-init.service

# Do normal operations

#Kill the watchdog
sudo systemctl stop watchdog-daemon-init.service
```

#### Behind the scene
During the BOOT image creation, `config_fpd_wdt.cdo` added in boot.bif will configure the expiry action of the FPD WDT to *Subsystem Restart*. PLM configures this action in the error management module. Whenever FPD WDT expires, the PLM gets the notification to perform the configured action.

In Linux system, the watchdog driver is enabled by default. The Linux device tree has the FPD WDT node enabled. So the FPD watchdog is populated as hardware watchdog device. The `watchdog-daemon` opens this device and configure it for 20 seconds. Then this application is running an infinite loop to kick the watchdog every 5 seconds.

When this application is killed or hanged, the watchdog stops receiving the kick (heartbeats), resulting in watchdog expiry. And hence PLM will perform *Subsystem Restart*.

#### Python Module & Jupyter wrapper.
This operation can be performed from the python module vssr_trd, which is used by this notebook.

Click __Perform Action__ to execute python call sequence similar to:

```
import vssr_trd as trd
trd.init()
trd.SetControl(0,4)
```

#### Observation
Observe the system recovering after a countdown of about 15 to 20 seconds. Linux killed in the APU terminal and RPU application still running in it's terminal; Linux subsystem is reloaded thereafter.

> Note: As APU is hosting this notebook, the notebook becomes inactive and disconnects during the reboot. After reboot one must reconnect the notebook in the browser. In most cases, after waiting for about 120-150 seconds, just a browser refresh is enough to reconnect the notebook after reboot.
