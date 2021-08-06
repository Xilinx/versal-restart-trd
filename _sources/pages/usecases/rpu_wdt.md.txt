## RPU - WDT Recovery

This function demonstrates the system recovery through LPD Watchdog.

The RPU application configures and start the LPD watchdog during the init sequence.

The watchdog is configured with the timeout value of __10 seconds__ and is kicked approximately every __500 miliseconds__.

To test the recovery, when the rpu application receives the request, it stops kicking the watchdog, and allow it to expire after 10 seconds.

#### Behind the scene
During the BOOT image creation, `config_lpd_wdt_por.cdo` added in boot.bif will configure the expiry action of the LPD WDT to *Power-On-Reset (POR) restart*. PLM configures this action in the error management module. Whenever LPD WDT expires, the PLM gets the notification to perform the configured action.

RPU application of the TRD waits for the command from APU over libmetal. When it receives 'Kill Watchdog' request it will set a flag to stop the watchdog kicks. This will result in the watchdog expiry after the configured time. And hence PLM will perform __Power-On-Reset__.

#### Python Module & Jupyter wrapper.
This operation can be performed from the python module vssr_trd, which is used by this notebook.

Click __Perform Action__ to execute python call sequence similar to:

```
import vssr_trd as trd
trd.init()
trd.SetControl(1,4)
```

#### Observation
Observe the system recovering after a countdown of about 10 seconds. Linux killed in the APU terminal and RPU application dead in it's terminal; then both APU and RPU terminals are getting reloaded with the respective subsystems.

> Note: As APU is hosting this notebook, the notebook becomes inactive and disconnects during the reboot. After reboot one must reconnect the notebook in the browser. In most cases just a browser refresh is enough to reconnect the notebook after reboot.
