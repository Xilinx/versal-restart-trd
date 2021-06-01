## APU - Subsystem Restart

This function demonstrates the APU subsystem performing a self restart.

The APU subsystem in this design includes the PS peripherals needed to run Linux and either a simple PL design in the Baseline hardware design, or a PL accelerator used for accelerating bzip2 engine in the BZip hardware design.

To perform subsystem restart from Linux, write `subsystem` to shutdown_scope sysfs file. A `reboot` command anytime after this, will perform the subsystem restart.

```
echo subsystem > /sys/devices/platform/firmware:versal-firmware/shutdown_scope
```

Other possible value for the shutdown_scope is system(default), which will do full system restart on next reboot.

The scope can be read back by cat command. The selected scope is indicated by square brackets [  ]. e.g. `[subsystem] ps_only system`

#### Behind the scene
PLM remembers the subsystem through the cdo commands during the system boot. When it receives the request for SystemShutdown with subsystem as argument, it releases all the peripheral nodes requested / allocated to the subsystem. If the nodes are not used by any other subsystem, then those nodes are idled and reset as well. PLM reloads the subsystem after pre-allocting (automatic node request) of necessary nodes for the subsystem to start or init. The subsystem itself will request the rest of the nodes when needed.

In case of Linux, the scope for the restart is recorded and remembered by ATF through sysfs entry update. During the Linux reboot call, the ATF issues `PmSystemShutdown` call to PLM with `subsystem` as an argument for restart type.

> Note: Currently Idling/Reset of the PL peripherals is not supported by PLM. This demo relies on Linux drivers and application to idle the ongoing traffic from PL periperhals.

#### Python Module & Jupyter wrapper.
This operation can be performed from the python module vssr_trd, which is used by this notebook.

Click __Perform Action__ to execute python call sequence similar to:

```
import vssr_trd as trd
trd.init()
trd.SetControl(0,0)
```

#### Observation
Observe RPU application still running normally in terminal during this restart.

> Note: As APU is hosting this notebook, the notebook becomes inactive and disconnects during the reboot. After reboot one must reconnect the notebook in the browser. In most cases just a browser refresh is enough to reconnect the notebook after reboot.
