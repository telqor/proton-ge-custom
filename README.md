This is my personal fork of [GloriousEggroll's GE-Proton](https://github.com/GloriousEggroll/proton-ge-custom), enabling following changes:

- NTSync support
- Preliminary Edge WebView2 installer via Winetricks (for APB Reloaded OTW/Beta's new WebView launcher)

*About NTSync:*

The required NTSync patches have been obtained from the proton-cachyos project, specifically [its Wine repository](https://github.com/CachyOS/wine-cachyos).

You can verify that you are running NTSync by checking for the string "using fast synchronization" in your Wine/Proton logs, or by using Mangohud's WSYNC indicator.

A supported kernel is needed, which can be either a 6.14+ kernel or a previous one that has been specially patched to use NTSync. You can verify the presence of the NTSync module by running `modinfo ntsync`. 
The module may or may not be loaded by default, if `modinfo ntsync` returns valid module information but `/dev/ntsync` does not exist, you can load the module manually such as with `sudo modprobe ntsync`
You can check your distribution's documentation for a more permanent way to load the module on boot.

Several cutting edge distributions such as CachyOS already ship compatible kernels by default.

Use the environment variable `PROTON_NO_NTSYNC=1` to manually disable NTSync, such as to find any regression introduced by merely applying the patches (without even using NTSync itself). 

Thanks to Elizabeth Figura for developing the NTSync patchset, and to whrvt and loathingKernel for rebasing the patches to work on a Proton 10 base.

*About WebView2:*

The built in Winetricks now contains the webview2 verb, you can install it easily with umu for a given game ID:

`GAMEID=YOUR_GAME_ID PROTONPATH=PATH_TO_THIS_PROTON umu-run winetricks webview2`

Since the installer is slow and convoluted (requires a specially patched Mono specifically for APB OTW), I have not set it to automatically run with APB for now. Obviously, this will change if the WebView launcher is used in the regular Steam version. 

No other WebView2 related workarounds have been added, such as DLL overrides or compatibility mode settings. Other WebView2 games besides APB OTW may or may not work when using this verb.

