# Table of Contents:
[![Developer's Guide](https://img.shields.io/badge/-1._Developer's_Guide-white)](#developers-guide)<br>

# Developer's Guide
### TRD Software Overview
* Both APU (linux) and RPU (Baremetal) talk to PLM to perform various TRD tasks.
* There is no direct communication between APU and RPU (as of 2025.2 release).
* APU, RPU and System Controller communicate via DDR Memory ( which is accessible to all ).
  * APU uses `devmem2` utility tool to read/write to DDR Memory.
  * RPU uses xilpm-ng `Xil_In32()` and `Xil_Out32()` to read/write to DDR Memory.
  * System Controller uses `XSDB` to perform read/write operations on DDR Memory.
* With the help of `DRMsg Protocol`, a custom message sharing over DDR Memory, TRD can perform several tasks!
  * A slave (eg: APU) polls it's specific region in DDR space, waiting to perform necessary action. The application `*-app.py` contents this algorithm.
  * The master, which could either be a PS block or System Controller, provide a command-line interface to the user, which orders slave to execute necessary TRD task.
* Note: 2025.2 releases only APU application!
```
         ╔═════════════════════════════════════╗
         ║                 PLM                 ║
         ╚══╦═══════════════════════════════╦══╝
            ▲                               ▲
            │                               │
            │                               │
            ▼                               ▼
╔═════════════════╗                    ╔═════════════════╗
║                 ║                    ║                 ║
║       APU       ║                    ║       RPU       ║
║                 ║                    ║                 ║
╚═════════════════╝                    ╚═════════════════╝
         ▲                                      ▲
         │                                      │
         └────────┐                    ┌────────┘
                  │                    │
                  ▼                    ▼
         ╔══════════════════════════════════════╗
         ║                                      ║
         ║              DDR Memory              ║
         ║                                      ║
         ╚══════════════════════════════════════╝
                             ▲
                             │
                             │
                             ▼
             ╔═══════════════════════════════╗
             ║                               ║
             ║       System Controller       ║
             ║                               ║
             ╚═══════════════════════════════╝
```

### EDF Yocto Overview
* Customers directly use SDTGEN published here: https://edf.amd.com/sswreleases/rel-v2025.2/sdt/2025.2/2025.2_1111_1_11112340/external/versal-2ve-2vm-vek385-revb-sdt-seg/ (but, tool supports usage of .XSA to generate SDTGEN if needed).
* Overlay CDO will contain all the subsystem customizations and confirations.
* In EDF Yocto Setup, we create our custom meta layer for TRD(s).
* With `gen-machine-conf`, we generate our custom machine by inheriting the default `versal-2ve-2vm-vek385-sdt-seg` machine provided by EDF.
* Following bitbake command over-writes xilinx-bootbin recipe to build necessary artifacts: `MACHINE=<custom-machine-name> bitbake xilinx-bootbin`
```
╔════════════════╗          ╔════════════════╗          ╔════════════════╗          ╔════════════════╗          ╔════════════════╗          ╔════════════════╗
║                ║          ║                ║          ║                ║          ║     TRD        ║          ║      GEN       ║          ║                ║
║      .XSA      ║  ─────►  ║   SDTGEN DIR   ║  ─────►  ║  OVERLAY CDO   ║  ─────►  ║   EDF YOCTO    ║  ─────►  ║     MACHINE    ║  ─────►  ║    BITBAKE     ║
║                ║          ║                ║          ║                ║          ║     SETUP      ║          ║      CONF      ║          ║                ║
╚════════════════╝          ╚════════════════╝          ╚════════════════╝          ╚════════════════╝          ╚════════════════╝          ╚════════════════╝
```

### RPM Package Overview
* `build-package.sh` takes care of building *.rpm package for TRD(s).
* `rpmbuild/BUILD/` directory has all the necessary linux configuration scripts and source files are copied from `../apu_app/` for TRD.
* The generated .rpm package should be available at `rpmbuild/RPMS/` directory.
* The generated .rpm package can be installed on both APU as well as System Controller.
  * The package looks for `sc_app` as an identifier to determine whether the host is Versal2 device or System Controller.
  * With this intelligence, the package configures and installs the necessary components accordingly.
* The `/opt/<>/*-cmd.py` script can run on either System Controller or Versal2 (running on System Controller is good, as it gives complete visual of what's happening)
* To properly uninstall the .rpm package: `rpm -e <package-name>`
