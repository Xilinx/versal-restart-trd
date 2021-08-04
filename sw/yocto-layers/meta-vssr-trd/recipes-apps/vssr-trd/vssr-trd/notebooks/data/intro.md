## VSSR TRD Notebook

### This notebook demonstrates the functions of the Versal Subsystem Restart TRD

#### In this Notebook, the widgets are layed out in a dashboard with the following selections:
- Target Selection - Select the processor that will be performing the specified action
- Action Selection - Select what action will be performed
- Perform Action - Button to perform above selected action

To perform various tasks, the notebook uses a python module `vssr_trd`. This module provides a wrapper API `SetControl(target,action)`, where target can be *APU(0)* or *RPU(1)*, and action can be *SubsystemRestart(0), SystemRestart(1), TestHealthyBoot(2), KillWdt(4)*.

#### The following status updates are displayed in real-time:
- Design - Design variant being used (base/bzip2)
- APU Status - Current status of APU subsystem (Alive / Dead)
- RPU Status - Current status of RPU subsystem (Alive / Dead)

APU and RPU applications of the trd, communicates with each other over the LibMetal shared memory interface. Through this interface the APU sends various action request to RPU and RPU sends its alive status to APU. 

#### The details of currently selected Target and Action are provided in the below section. *(Updated dynamically)*