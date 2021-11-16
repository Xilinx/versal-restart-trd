## RPU - Healthy Boot Test

This function demonstrates the system recovery through RPU subsystem healthy boot feature.

If the RPU subsystem fails to boot fully within __20 seconds__, the PLM will mark this event as unhealthy boot and it will trigger a system restart to recover. PLM considers a subsystem to be healthy, if the subsystem issues XPm_InitFinalize.

To test this feature, there is a hook in the rpu application, which will not issue XPm_InitFinalize on next boot. This is achieved by writing a BAD_BOOT_KEY in a specific persistent memory; followed by subsystem restart.

#### Behind the scene
During the subsystem definition following line are added in the cdo for the RPU subsystem:

```
# Healthy Boot configuration for RPU subsystem
#Add HB_MON_1 to RPU_LS subsystem. Timeout(last argument) = 20000ms (0x4E20)
pm_add_requirement 0x1c000004 0x18250001 0x46 0xFFFFF 0x1 0x4E20
#Set the error action (POR) for HB_MON_1 in case of subsystem not healthy
#Second Argument = error action; POR=0x1; SRST=0x2; ERR_OUT=0x4;
em_set_action 0x28110000 0x1 0x2
```

This configures the healthy boot monitoring for RPU subsystem by PLM. The minimum timeout value for which PLM will wait to allow subsystem mark itself healthy is configured for 20 seconds in this case. If the subsystem fails to mark itself healthy with in 20 seconds, PLM assumes that the subsystem failed to boot properly and triggers POR (system wide __Power-On-reset__)

The subsystem marks itself healthy by issuing `XPm_InitFinalize` . The RPU application in the TRD, calls XPm_InitFinalize to finalize its PM requirements after initialization, if BAD BOOT KEY is not marked.

RPU application of the TRD waits for the command from APU over libmetal. When it receives request to test the healthy boot, it will mark BAD BOOT Key and perform subsystem restart by calling XilPm API `XPm_SystemShutdown` with `subsystem` as argument to perform self restart. On next boot, RPU application skips `XPm_InitFinalize`, hence recovery is trigger after 20 seconds.

#### Python Module & Jupyter wrapper.
This operation can be performed from the python module vssr_trd, which is used by this notebook.

Click __Perform Action__ to execute python call sequence similar to:

```
import vssr_trd as trd
trd.init()
trd.SetControl(1,2)
```

#### Observation
Observe RPU subsystem dead for 3 seconds and getting restarted, above the control panel on right side. Also observe the message __BAD BOOT__, during rpu application relaunch. Linux and everything else should be working fine. Wait for 20 seconds, observe the system recovery. Linux dead in the APU terminal and RPU application dead in it's own terminal; then both APU and RPU terminals are getting reloaded with the respective subsystems.

> Note: As APU is hosting this notebook, the notebook becomes inactive and disconnects during the reboot. After reboot one must reconnect the notebook in the browser. In most cases just a browser refresh is enough to reconnect the notebook after reboot.
