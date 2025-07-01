# SkyrimModder
This is developmental. Use at your own risk. Please back up your files before continuing.

The goal is a reproducible Skyrim installation, and Nix is the bestest thing for reproducibility, so here we are.
However, there are two things that are not reproducible:
- the config files living in steamapps config folder like Plugins.txt (amendable)
- the Steam Proton environment (other people have come before me and failed, so let's just pray with this one)

BIG WARNING: adding mods is kinda PITA.
See the ad-hoc stuff in skyrim_mods.nix -- many packages require custom steps, though these are typically documented
in some fomod xml file that you can then translate into those steps you see.
I verified it works with the few mods that I have enabled here. You probably don't want to try unless you're already familiar with Nix.

However, I think we could actually have very nice reproducibility, with minimal manual stuff to do for the user, following this idea; it's just
we'd have to have a source of mods that is NOT nexus, that allows fetching the mods programmatically, along with a "nixpkgs"-like thing that
describes the packages, and takes whichever configurations.

I'm using:
- Steam Proton Experimental
- Skyrim v1.6.1170.0

## Usage Instructions
### 1. Obtain the Skyrim source
Download a fresh Skyrim.
The Skyrim install directory should look like:
```
❯ ls -1 
 bink2w64.dll
 Data
 High.ini
 installscript.vdf
 Low.ini
 Medium.ini
 Skyrim
 Skyrim.ccc
 Skyrim_Default.ini
 SkyrimSE.exe
```

for me, on steam, this is 
`install_dir=~/.local/share/Steam/steamapps/common/Skyrim\ Special\ Edition`
### 2. Get the Version String
`ver=$(strings "${install_dir}/SkyrimSE.exe" | rg -A 1 "Release Final" | rg "\d+\.\d+\.\d+")`

### 3. Upload Skyrim to the nix store
`tar -czvf "skyrim-${ver}.tar.gz" ./Skyrim\ Special\ Edition/`
`nix-prefetch-url file://skyrim-${ver}.tar.gz`
It will print something like:
```
❯ nix-prefetch-url file://$PWD/skyrim-1.6.1170.0.tar.gz 
path is '/nix/store/12dj2dp7j0nx972ahp8j9r27vza96p29-skyrim-1.6.1170.0.tar.gz'
0wyh25a8pq2izsskzfwa6wzmc1rpa8gn0sisyrg59jq0fngyvis6
```
The second line is the hash. This has to go into wherever the corresponding requireFile is.

To avoid it getting garbage collected (so that you can later reuse it, ie when you want to rebuild with new mods)
I would recommend ie:
`nix-store -r /nix/store/12dj2dp7j0nx972ahp8j9r27vza96p29-skyrim-1.6.1170.0.tar.gz --add-root ./base-skyrim-archive`

### 4. Upload Mods into the Nix Store

#### Upload Mods
I may have named things a bit weirdly, but anyways, I basically followed steps above, made an entry in the mods list
ie:
```nix
Address_Library_for_SKSE_Plugins = (unpack-generic-mod rec {
  filename = "Address_Library_for_SKSE_Plugins-${mod_version}.zip";
  mod_version = "11.0.0.0";
  sha256 = "00hs4f9v8ybkyp2bvf4djj8wii6v69a2h89slr7965nsraqrl077";
  requires = [ ]; # none
});
```
The filename there should match the name of the file you upload into the nix store.
Download the zip file from Nexus, save it as that filename, and then run nix-prefetch-url on it.
The mod should have the standard format. It should use paths with Capitalization.
Its contents will go into the Data directory of the install folder.

To avoid nix garbage collection, just to be safe, 
`nix-build ./build_srcs.nix -o all-srcs-root`
and do not touch.
This is also useful for examining that the individual mods are packaged in the standardized way.

Note that you will likely have to "massage" the outputs. See skyrim_mods.nix for examples.

#### Why not automated downloads?
Unfortunately, their download API is paid user only, and I really don't believe that
any package manager (this isn't one, but still) thing should force you to have a subscription.

Note that this:
https://github.com/Rucadi/NixSkyrimAE/blob/master/mods/nixutils/downloaders/nexusmods/downloadFromNexus.sh
does not work anymore. I assume they updated stuff on their side to avoid it.

### 5. Build
`nix-build -A skyrim`

Check inside that directory for the conflicted_files.txt
It has `<filename> <originalMod> <overwritingMod>` -- basically, overwritingMod is clobbering the file with filename that was from originalMod.

### 6. Install
Symlink it to the place where the Skyrim directory is supposed to be.
For stuff like display configuration, note that's found in the steam compatdata/
It does NOT use the ini files inside the installation.

## Troubleshooting
check skse is enabled. in Skyrim game console:
`getskseversion`

next, check mods actually were detected.
- first, launch Skyrim via SKSELoader to detect mods. (it should populate the Plugins.txt automatically)
- then open up Plugins.txt
  (Online stuff speaks about an in-game mod menu. I don't see it.
   Enable the mods you want.)
- enabled mods should start with a '*'
example of mine, all enabled:
```
# This file is used by Skyrim to keep track of your downloaded content.
# Please do not modify this file.
*unofficial skyrim special edition patch.esp
*SkyUI_SE.esp
*UIExtensions.esp
*alternate start - live another life.esp
*RealNamesExtended.esp
*nwsFollowerFramework.esp
```
