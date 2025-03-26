## RPU - WDT Recovery

This function demonstrates the system recovery through LPD Watchdog.

The RPU application configures and starts the LPD watchdog during the init sequence.

The watchdog is configured with the timeout value of __10 seconds__ and is kicked approximately every __50 miliseconds__.

To test the recovery, when the rpu application receives the request, it stops kicking the watchdog, and allow it to expire after 10 seconds.

#### Behind the scene
During the BOOT image creation, `config_lpd_wdt.cdo` added in boot.bif will configure the expiry action of the LPD WDT to *Subsystem Restart*. PLM configures this action in the error management module. Whenever LPD WDT expires, the PLM gets the notification to perform the configured action.

RPU application of the TRD waits for the command from APU over libmetal. When it receives 'Kill Watchdog' request it will set a flag to stop the watchdog kicks. This will result in the watchdog expiry after the configured time. And hence PLM will perform __Subsystem Restart__.

#### Python Module & Jupyter wrapper.
This operation can be performed from the python module vssr_trd, which is used by this notebook.

Click __Perform Action__ to execute python call sequence similar to:

```
import vssr_trd as trd
trd.init()
trd.SetControl(1,4)
```

#### Observation
Observe the system recovering after a countdown of about 10 seconds. RPU is reloaded after 10 seconds while Linux keeps running normally.

