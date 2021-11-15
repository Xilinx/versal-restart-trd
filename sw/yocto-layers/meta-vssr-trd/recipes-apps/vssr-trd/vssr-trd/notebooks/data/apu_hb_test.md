## APU - Healthy Boot Test

This function demonstrates the system recovery through APU subsystem healthy boot feature.

If the APU subsystem fails to boot fully within __120 seconds__, the PLM will mark this event as unhealthy boot and it will trigger a system restart to recover. PLM considers a subsystem to be healthy, if the subsystem issues XPm_InitFinalize.

#### How to Test

The __Perform Action__ button will just trigger the subsystem restart. To test Healthy Boot feature, one has to interrupt the u-boot during this subsystem restart.

Stop at u-boot during the Linux boot by pressing any key. Wait for 120 seconds, and system wide reset should appear.


#### Behind the scene
During the subsystem definition following line are added in the cdo for the APU subsystem:

```
# Healthy Boot configuration for APU subsystem
#Add HB_MON_0 to APU subsystem. Timeout(last argument) = 120000ms (0x1D4C0)
pm_add_requirement 0x1c000003 0x18250000 0x46 0xFFFFF 0x1 0x1D4C0
#Set the error action (SRST) for HB_MON_0 in case of subsystem not healthy
#Second Argument = error action; POR=0x1; SRST=0x2; ERR_OUT=0x4;
em_set_action 0x28110000 0x2 0x1
```

This configures the healthy boot monitoring for APU subsystem by PLM. The minimum timeout value for which PLM will wait to allow subsystem mark itself healthy is configured for 120 seconds in this case. If the subsystem fails to mark itself healthy with in 120 seconds, PLM assumes that the subsystem failed to boot properly and triggers SRST (system wide reset)

The subsystem marks itself healthy by issuing `XPm_InitFinalize` . The Linux system, when complete all the boot activities, calls XPm_InitFinalize to finalize its PM requirements. When Linux fails (or is not allowed) to boot, this never called and hence PLM will trigger the recovery.

#### Python Module & Jupyter wrapper.
This operation requires manual intervention at u-boot. The __Perform Action__ button just performs APU subsystem restart.

Click __Perform Action__ to execute python call sequence similar to:

```
import vssr_trd as trd
trd.init()
trd.SetControl(0,0)
```

#### Observation
Observe RPU application still running normally in terminal during this restart. After stopping at u-boot for 120 seconds, observe the system recovery. U-boot killed in the APU terminal and RPU application dead in it's terminal; then both APU and RPU terminals are getting reloaded with the respective subsystems.

> Note: As APU is hosting this notebook, the notebook becomes inactive and disconnects during the reboot. After reboot one must reconnect the notebook in the browser. In most cases just a browser refresh is enough to reconnect the notebook after reboot.
