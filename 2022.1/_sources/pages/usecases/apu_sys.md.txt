## APU - System Restart

This function demonstrates the APU subsystem performing a full system restart.

To perform system restart from Linux, write `system` to shutdown_scope sysfs file (This is default). A `reboot` command anytime after this, will perform the full system restart.

```
echo system > /sys/devices/platform/firmware:versal-firmware/shutdown_scope
```

Other possible value for the shutdown_scope is subsystem, which will do self restart on next reboot.

The scope can be read back by cat command. The selected scope is indicated by square brackets [  ]. e.g. `subsystem ps_only [system]`

#### Behind the scene
PLM restarts the full system by re-running all the boot CDOs. The nodes are released before doing the restart.

PLM itself is reloaded from the boot media.

In case of Linux, the scope for the restart is recorded and remembered by ATF through sysfs entry update. During the Linux reboot call, the ATF issues `PmSystemShutdown` call to PLM with `system` as an argument for restart type.

#### Python Module & Jupyter wrapper.
This operation can be performed from the python module vssr_trd, which is used by this notebook.

Click __Perform Action__ to execute python call sequence similar to:

```
import vssr_trd as trd
trd.init()
trd.SetControl(0,1)
```

#### Observation
Observe Linux restart in the APU terminal and RPU application dead in it's terminal; then both APU and RPU terminals are getting reloaded with the respective subsystems.

> Note: As APU is hosting this notebook, the notebook becomes inactive and disconnects during the reboot. After reboot one must reconnect the notebook in the browser. In most cases, after waiting for about 120-150 seconds, just a browser refresh is enough to reconnect the notebook after reboot.
