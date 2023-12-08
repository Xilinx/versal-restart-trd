# APU - Image store Test

This function demonstrates the Image store feature

The APU subsystem in this design includes the PS peripherals needed to run Linux and a simple PL design in the Baseline hardware design.

This will perform APU subsystem restart from RPU subsystem by following below steps:
	- RPU application triggers apu power down by calling XilPm client API `XPm_ForcePowerDown`, with APU subsystem id as arugment.
	- After that we try to wakeup APU subsystem by loading partial PDI through an IPI command from Image store
#### Limitation
To run this test case again, please restart the RPU subsystem.

#### Behind the scene
While generating the pdi we need to give range and size of the Image store using cdo commands.

Image store CDO :
```
marker 0x64 "PMC_FW_CONFIG"
# Image Store Location: 64-bit address
# Higher 32-bit Address
write 0xF2014288 0x0
# Lower 32-bit Address
write 0xf201428C 0x3e000000
# Size
write 0xf2014290 0x00400000
marker 0x65 "PMC_FW_CONFIG"
```
We need to add cdo command for this under "PMC_FW_CONFIG" marker in overlay CDO. Apart from this, we need to add RPU and APU subsystems block in BIF file using imagestore attribute(DDR Memory)

RPU application powers down the APU subsystem using API `XPm_ForcePowerDown`.
PLM remembers the subsystem through the cdo commands during the system boot. When it receives the request for `XPm_ForcePowerDown` with subsystem as argument, it releases all the peripheral nodes requested / allocated to the subsystem. If the nodes are not used by any other subsystem, then those nodes are idled and reset as well.

Now, RPU applicaton writes Payload in the buffer using API `XIpiPsu_WriteMessage`, As a Payload argument DDR low and high address.
After that the API `XIpiPsu_TriggerIpi` triggers subsystems loading from the DDR address. PLM recives ipi call, reloads the subsystem from the DDR address and the subsystem requests necessary nodes.

#### Python Module & Jupyter wrapper.
This operation can be performed from the python module vssr_trd, which is used by this notebook.

Click __Perform Action__ to execute python call sequence similar to:

```
import vssr_trd as trd
trd.init()
trd.SetControl(1,5)
```

#### Observation
Observe RPU application still running normally in terminal during this APU subsystem restart and See APU subsystem restart from DDR memory addresses using kernel log.

> Note: As APU is hosting this notebook, the notebook becomes inactive and disconnects during the reboot. After reboot one must reconnect the notebook in the browser. In most cases, after waiting for about 120-150 seconds, just a browser refresh is enough to reconnect the notebook after reboot.
