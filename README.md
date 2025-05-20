This is [GloriousEggroll's GE-Proton](https://github.com/GloriousEggroll/proton-ge-custom) with NTSync patches included, no other changes have been made. The required patches have been obtained from the proton-cachyos project, specifically [its Wine repository](https://github.com/CachyOS/wine-cachyos).

You can verify that you are running NTSync by checking for the string "using fast synchronization" in your Wine/Proton logs, or by using Mangohud's WSYNC indicator.

A supported kernel is needed, which can be either a 6.14+ kernel or a previous one that has been specially patched to use NTSync. You can verify the presence of the NTSync module by running `modinfo ntsync`. 
The module may or may not be loaded by default, if `modinfo ntsync` returns valid module information but `/dev/ntsync` does not exist, you can load the module manually such as with `sudo modprobe ntsync`
You can check your distribution's documentation for a more permanent way to load the module on boot.

Several cutting edge distributions such as CachyOS already ship compatible kernels by default.

Use the environment variable `PROTON_NO_NTSYNC=1` to manually disable NTSync, such as to find any regression introduced by merely applying the patches (without even using NTSync itself). 

Thanks to Elizabeth Figura for developing the NTSync patchset, and to whrvt and loathingKernel for rebasing the patches to work on a Proton 10 base.
