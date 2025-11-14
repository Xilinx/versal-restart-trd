## RPU - System Restart

This function demonstrates the RPU subsystem performing a full system restart.

The application triggers subsystem restart by calling XilPm client API `XPm_SystemShutdown`, with system as argument for restart type.

#### Behind the scene
PLM restarts the full system by re-running all the boot CDOs. The nodes are released before doing the restart.

PLM itself is reloaded from the boot media.

RPU application of the TRD waits for the command from APU over libmetal. When it receives system restart request it will call XilPm API `XPm_SystemShutdown` with `system` as argument to perform full system restart.

#### Python Module & Jupyter wrapper.
This operation can be performed from the python module vssr_trd, which is used by this notebook.

Click __Perform Action__ to execute python call sequence similar to:

```
import vssr_trd as trd
trd.init()
trd.SetControl(1,1)
```

#### Observation
Observe Linux killed in the APU terminal and RPU application dead in it's terminal; then both APU and RPU terminals are getting reloaded with the respective subsystems.

> Note: As APU is hosting this notebook, the notebook becomes inactive and disconnects during the reboot. After reboot one must reconnect the notebook in the browser. In most cases, after waiting for about 120-15- seconds, just a browser refresh is enough to reconnect the notebook after reboot.
