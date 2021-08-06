## RPU - Subsystem Restart

This function demonstrates the RPU subsystem performing a self restart.

The RPU subsystem in this design includes the PS peripherals needed to run an R5 standalone application in lock-step mode.

The application triggers subsystem restart by calling XilPm client API `XPm_SystemShutdown`, with subsystem as argument for restart type.

#### Behind the scene
PLM remembers the subsystem through the CDO commands during the system boot. When it receives the request for SystemShutdown with subsystem as argument, it releases all the peripheral nodes requested / allocated to the subsystem. If the nodes are not used by any other subsystem, then those nodes are idled and reset as well. PLM reloads the subsystem after pre-allocting (automatic node request) of necessary nodes for the subsystem to start or init. The subsystem itself will request the rest of the nodes when needed.

RPU application of the TRD waits for the command from APU over libmetal. When it receives subsystem restart request it will call XilPm API `XPm_SystemShutdown` with `subsystem` as argument to perform self restart.

Note: There is deliberate 3 second delay in the start of R5 application for the demo purpose. While the R5 is down, the alive status of the R5 is changed to off.

There is no PL peripheral for RPU subsystem, hence nothing extra needs to be done for idling/resetting the PL peripherals.

#### Python Module & Jupyter wrapper.
This operation can be performed from the python module vssr_trd, which is used by this notebook.

Click __Perform Action__ to execute python call sequence similar to:

```
import vssr_trd as trd
trd.init()
trd.SetControl(1,0)
```

#### Observation
Observe RPU subsystem dead for 3 seconds and getting restarted, above the control panel on rigth side. Also observe the RPU application restarting the counter in the serial terminal.
