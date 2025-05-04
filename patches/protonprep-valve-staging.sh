#!/bin/bash

### (1) PREP SECTION ###

    pushd dxvk
    git reset --hard HEAD
    git clean -xdf
    popd

    pushd vkd3d-proton
    git reset --hard HEAD
    git clean -xdf

    popd

    pushd dxvk-nvapi
    git reset --hard HEAD
    git clean -xdf
    popd

    pushd gstreamer
    git reset --hard HEAD
    git clean -xdf
    echo "GSTREAMER: fix for unclosable invisible wayland opengl windows in taskbar"
    patch -Np1 < ../patches/gstreamer/5509.patch
    patch -Np1 < ../patches/gstreamer/5511.patch
    popd

    pushd protonfixes
    git reset --hard HEAD
    git clean -xdf
    pushd subprojects
    pushd x11-xserver-utils
    git reset --hard HEAD
    git clean -xdf
    popd
    pushd xutils-dev
    git reset --hard HEAD
    git clean -xdf
    popd
    popd
    popd

### END PREP SECTION ###

### (2) WINE PATCHING ###

    pushd wine
    git reset --hard HEAD
    git clean -xdf

### (2-1) PROBLEMATIC COMMIT REVERT SECTION ###

# Bring back configure files. Staging uses them to regenerate fresh ones
# https://github.com/ValveSoftware/wine/commit/e813ca5771658b00875924ab88d525322e50d39f

    git revert --no-commit e813ca5771658b00875924ab88d525322e50d39f

# This doesn't correctly resolve the issue. We have patches that handle this for gstreamer
# Need to revert this so our patches work.

    git revert --no-commit 37818f7a547f7090ef684f8202438374fc31a165

### END PROBLEMATIC COMMIT REVERT SECTION ###

### (2-2) WINE STAGING APPLY SECTION ###

    echo "WINE: -STAGING- applying staging patches"

    ../wine-staging/staging/patchinstall.py DESTDIR="." -a -r \

    -W winex11-_NET_ACTIVE_WINDOW \
    -W winex11-WM_WINDOWPOSCHANGING \
    -W user32-alttab-focus \
    -W winex11-MWM_Decorations \
    -W server-Signal_Thread \
    -W ntdll-Junction_Points \
    -W server-Stored_ACLs \
    -W kernel32-CopyFileEx \
    -W shell32-Progress_Dialog \
    -W shell32-ACE_Viewer \
    -W dbghelp-Debug_Symbols \

    -W ntdll-Syscall_Emulation \
    -W eventfd_synchronization \
    -W server-PeekMessage \
    -W server-Realtime_Priority \
    -W msxml3-FreeThreadedXMLHTTP60 \
    -W ntdll-ForceBottomUpAlloc \
    -W ntdll-NtDevicePath \
    -W ntdll_reg_flush \
    -W user32-rawinput-mouse \
    -W user32-recursive-activation \
    -W d3dx11_43-D3DX11CreateTextureFromMemory \
    -W d3dx9_36-D3DXStubs \
    -W wined3d-zero-inf-shaders \

    -W cryptext-CryptExtOpenCER \
    -W wineboot-ProxySettings

    # NOTE: Some patches are applied manually because they -do- apply, just not cleanly, ie with patch fuzz.
    # A detailed list of why the above patches are disabled is listed below:

    # ** loader-KeyboardLayouts - note -- always use and/or rebase this --  needed to prevent Overwatch huge FPS drop

    # winex11-_NET_ACTIVE_WINDOW - Causes origin to freeze
    # winex11-WM_WINDOWPOSCHANGING - Causes origin to freeze
    # user32-alttab-focus - relies on winex11-_NET_ACTIVE_WINDOW -- may be able to be added now that EA Desktop has replaced origin?
    # winex11-MWM_Decorations - not compatible with fullscreen hack
    # server-Signal_Thread - breaks steamclient for some games -- notably DBFZ
    # ntdll-Junction_Points - breaks CEG drm
    # server-Stored_ACLs - requires ntdll-Junction_Points
    # kernel32-CopyFileEx - breaks various installers
    # shell32-Progress_Dialog - relies on kernel32-CopyFileEx
    # shell32-ACE_Viewer - adds a UI tab, not needed, relies on kernel32-CopyFileEx
    # dbghelp-Debug_Symbols - Ubisoft Connect games (3/3 I had installed and could test) will crash inside pe_load_debug_info function with this enabled

    # ntdll-Syscall_Emulation - already applied
    # eventfd_synchronization - already applied
    # server-PeekMessage - already applied
    # server-Realtime_Priority - already applied
    # msxml3-FreeThreadedXMLHTTP60 - already applied
    # ntdll-ForceBottomUpAlloc - already applied
    # ntdll-NtDevicePath - already applied
    # ntdll_reg_flush - already applied
    # user32-rawinput-mouse - already applied
    # user32-recursive-activation - already applied
    # d3dx11_43-D3DX11CreateTextureFromMemory - already applied
    # d3dx9_36-D3DXStubs - already applied
    # wined3d-zero-inf-shaders - already applied

    # rebased and applied manually:
    # cryptext-CryptExtOpenCER
    # wineboot-ProxySettings

    # dinput-joy-mappings - disabled in favor of proton's gamepad patches -- currently also disabled in upstream staging
    # mfplat-streaming-support -- interferes with proton's mfplat -- currently also disabled in upstream staging
    # wined3d-SWVP-shaders -- interferes with proton's wined3d -- currently also disabled in upstream staging
    # wined3d-Indexed_Vertex_Blending -- interferes with proton's wined3d -- currently also disabled in upstream staging

    echo "WINE: -STAGING- cryptext-CryptExtOpenCER manually applied"
    patch -Np1 < ../patches/wine-hotfixes/staging/cryptext-CryptExtOpenCER/0001.patch

    echo "WINE: -STAGING- wineboot-ProxySettings manually applied"
    patch -Np1 < ../patches/wine-hotfixes/staging/wineboot-ProxySettings/0001.patch

### END WINE STAGING APPLY SECTION ###

### (2-3) GAME PATCH SECTION ###

    echo "WINE: -GAME FIXES- assetto corsa hud fix"
    patch -Np1 < ../patches/game-patches/assettocorsa-hud.patch

    echo "WINE: -GAME FIXES- add file search workaround hack for Phantasy Star Online 2 (WINE_NO_OPEN_FILE_SEARCH)"
    patch -Np1 < ../patches/game-patches/pso2_hack.patch

    echo "WINE: -GAME FIXES- add xinput support to Dragon Age Inquisition"
    patch -Np1 < ../patches/game-patches/dai_xinput.patch

    echo "WINE: -GAME FIXES- add set current directory workaround for Vanguard Saga of Heroes"
    patch -Np1 < ../patches/game-patches/vgsoh.patch

    echo "WINE: -GAME FIXES- add __TRY/__EXCEPT_PAGE_FAULT wnsprintfA xDefiant patch because of a bad arg passed by the game that would exit to desktop"
    patch -Np1 < ../patches/game-patches/xdefiant.patch

### END GAME PATCH SECTION ###

### (2-4) WINE HOTFIX/BACKPORT SECTION ###

### END WINE HOTFIX/BACKPORT SECTION ###

### (2-5) WINE PENDING UPSTREAM SECTION ###

    # https://github.com/Frogging-Family/wine-tkg-git/commit/ca0daac62037be72ae5dd7bf87c705c989eba2cb
    echo "WINE: -PENDING- unity crash hotfix"
    patch -Np1 < ../patches/wine-hotfixes/pending/unity_crash_hotfix.patch

    # https://github.com/ValveSoftware/wine/pull/205
    # https://github.com/ValveSoftware/Proton/issues/4625
    echo "WINE: -PENDING- Add WINE_DISABLE_SFN option. (Yakuza 5 cutscenes fix)"
    patch -Np1 < ../patches/wine-hotfixes/pending/ntdll_add_wine_disable_sfn.patch

    echo "WINE: -PENDING- ncrypt: NCryptDecrypt implementation (PSN Login for Ghost of Tsushima)"
    patch -Np1 < ../patches/wine-hotfixes/pending/NCryptDecrypt_implementation.patch

    # https://gitlab.winehq.org/wine/wine/-/merge_requests/7032
    # https://bugs.winehq.org/show_bug.cgi?id=56259
    # https://forum.winehq.org/viewtopic.php?t=38443
    echo "WINE: -GAME FIXES- add webview2 patches for GIRLS' FRONTLINE 2: EXILIUM and Vermintide 2"
    patch -Np1 < ../patches/wine-hotfixes/pending/webview2.patch
    patch -Np1 < ../patches/wine-hotfixes/pending/webview2-install-fix.patch

    # https://github.com/ValveSoftware/Proton/issues/7878
    # https://gitlab.winehq.org/wine/wine/-/merge_requests/5153.patch
    # https://gitlab.winehq.org/wine/wine/-/merge_requests/5143.patch
    # https://gitlab.winehq.org/wine/wine/-/merge_requests/5142.patch
    # https://gitlab.winehq.org/wine/wine/-/merge_requests/5175.patch
    # https://gitlab.winehq.org/wine/wine/-/merge_requests/5103.patch
    echo "WINE: -PENDING- taskschd (NCSoft Purple Client)"
    patch -Np1 < ../patches/wine-hotfixes/pending/0001-taskschd-ncsoft-purple-5153.patch
    patch -Np1 < ../patches/wine-hotfixes/pending/0002-taskschd-ncsoft-purple-5143.patch
    patch -Np1 < ../patches/wine-hotfixes/pending/0003-taskschd-ncsoft-purple-5142.patch
    patch -Np1 < ../patches/wine-hotfixes/pending/0004-taskschd-ncsoft-purple-5175.patch
    patch -Np1 < ../patches/wine-hotfixes/pending/0005-taskschd-ncsoft-purple-5103.patch

### END WINE PENDING UPSTREAM SECTION ###


### (2-6) PROTON-GE ADDITIONAL CUSTOM PATCHES ###

#    echo "WINE: -FSR- fullscreen hack fsr patch"
#    patch -Np1 < ../patches/proton/47-proton-fshack-AMD-FSR-complete.patch

    echo "WINE: -Nvidia Reflex- Support VK_NV_low_latency2"
    patch -Np1 < ../patches/proton/83-nv_low_latency_wine.patch

    echo "WINE: CUSTOM Add options to disable proton media converter."
    patch -Np1 < ../patches/proton/add-envvar-to-gate-media-converter.patch

    echo "WINE: -CUSTOM- Downgrade MESSAGE to TRACE to remove write_watches spam"
    patch -Np1 < ../patches/proton/0001-ntdll-Downgrade-using-kernel-write-watches-from-MESS.patch

    echo "WINE: -CUSTOM- Fix wine bug #56653 - GetLogicalProcessorInformation can be missing Cache information"
    patch -Np1 < ../patches/wine-hotfixes/pending/wine-bug-56653.patch

    echo "WINE: -CUSTOM- Add WINE_NO_WM_DECORATION option to disable window decorations so that borders behave properly"
    patch -Np1 < ../patches/proton/WINE_NO_WM_DECORATION.patch

    echo "WINE: -CUSTOM- Add PROTON_PREFER_SDL option to make it not prefer hidraw and instead expose both sdl and hidraw"
#    patch -Np1 < ../patches/proton/PREFER_SDL.patch

    # https://github.com/ValveSoftware/wine/pull/269
    echo "WINE: -PENDING- Hid multi TLC and Fanatec wheel-bases hidraw white-list"
#    patch -Np1 < ../patches/wine-hotfixes/pending/hid-multi-tlc-and-ftec-hidraw-269.patch

    popd

### END PROTON-GE ADDITIONAL CUSTOM PATCHES ###
### END WINE PATCHING ###
