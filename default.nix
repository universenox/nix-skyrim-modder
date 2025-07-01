{ pkgs ? (import <nixpkgs> { })
, skyrim_version ? "1.6.1170.0"
}:
rec {
  base_skyrim_src_unpacked = pkgs.stdenvNoCC.mkDerivation {
    name = "skyrim-${skyrim_version}";
    src = (pkgs.callPackage ./base_skyrim.nix { inherit skyrim_version; });
    dontFixup = true;
    installPhase = ''
      cp -r ./ $out/
    '';
  };

  all_mods = (import ./skyrim_mods.nix { inherit skyrim_version pkgs; });

  enabled_mods = [
    # "SKSE" NO -- SKSE treated specially.
    "Address_Library_for_SKSE_Plugins"
    "ConsoleUtilSSE"
    "PapyrusUtil_SE_Modders_Scripting_Utility_Functions"
    "powerofthrees_Tweaks"
    "powerofthrees_Papyrus_Extender"
    "Unofficial_Skyrim_Special_Edition_Patch"
    "RUS_Unofficial_Skyrim_Special_Edition_Patch"
    "Fuz_Ro_Doh"
    "SSE_Display_Tweaks"
    "Russian_Textures_and_Console_Font_Fix"
    "Pelinal_RU_Font_replacer"
    "SkyUI"
    "UIExtensions"
    "UIExtensions_RU"
    "Spell_Perk_Item_Distributor"
    "Merge_Mapper"
    "Form_List_Manipulator"
    "Alternate_Start"
    "Real_Names_Extended"
    "Subtitles"
    "To_Your_Face"
    "Nethers_Follower_Framework"
    # "Nethers_Follower_Framework_RU"
    # "CHIM_AIAgent"
  ];

  skyrim = pkgs.stdenvNoCC.mkDerivation {
    name = "skyrim-with-mods";
    dontFixup = true;
    dontUnpack = true;

    nativeBuildInputs = [ pkgs.rsync pkgs.ripgrep pkgs.fd pkgs.tree pkgs.util-linux pkgs.moreutils ];

    buildInputs = (map (mod-name: all_mods.${mod-name}) enabled_mods);

    # create a tree of symlinks to the base game files and mod files.
    buildPhase = let
      inherit (pkgs) lib;

      check-req = (mod-name: req: ''
        if [[ ${req} != ignore ]]; then
          rg -q "^${req}$" ./installed_mods.txt

          if [[ $? != 0 ]]; then
            echo "missing req ${req} for mod ${mod-name}"
            exit 1
          fi
        fi
      '');

      process-mod = (mod-name:
        let
          mod-drv = all_mods.${mod-name};
          mod-dir = "${mod-drv}";
          debug-print = true;
        in
        lib.optionalString debug-print ''
          echo "Adding mod: ${mod-name} - ${mod-dir}"
          echo "Checking requisites..."
        ''
        + (lib.concatMapStrings (check-req mod-name) mod-drv.requires)
        + lib.optionalString debug-print ''
          echo "Linking tree..."
        '' + ''
          link_tree ${mod-dir}/ ./Data/
          echo "${mod-dir}" >> ./installed_mods.txt
        '');

    in ''
      mkdir build && cd build
      touch ./installed_mods.txt
      touch ./conflicted_files.txt

      # files are symlinks, but not directories
      link_tree () {
        local src_dir="$(realpath $1)"
        local dst_dir="$(realpath $2)"

        # create required directories.
        ( cd "$src_dir" && find -type d -exec mkdir -p "$dst_dir/{}" \; )

        # create symlinks, warn on collision.
        while IFS= read -r -d ''' src_path; do
          rel_path="''${src_path#$src_dir/}"
          dst_path="$dst_dir/$rel_path"

          # warn on collision
          if [[ -e "$dst_path" ]]; then
            original="$(realpath "$dst_dir/$rel_path")"
            overwriting="$(realpath "$src_dir/$rel_path")"

            orig_tmp="''${original#/nix/store/*-}"
            overwrite_tmp="''${overwriting#/nix/store/*-}"
            
            orig_mod="''${orig_tmp%%/*}"
            overwrite_mod="''${overwrite_tmp%%/*}"
            echo "\"$rel_path\",\"$orig_mod\",\"$overwrite_mod\"" >> ./conflicted_files.txt
            rm "$dst_path"
          fi

          # actual symlink creation
          ( cd "$(dirname "$dst_path")" && ln -s "$src_path" )
        done < <(find "$src_dir" -type f -print0)
      }

      link_tree ${base_skyrim_src_unpacked}/ ./

      # prepare base folders for all the mods
      mkdir -p Data/Meshes Data/Textures Data/Scripts Data/Interface Data/Sound Data/Music Data/Strings 

      # link SKSE
      ln -s ${all_mods.SKSE}/*.exe ./
      ln -s ${all_mods.SKSE}/*.dll ./
      ln -s ${all_mods.SKSE}/Data/Scripts/* ./Data/Scripts/
      echo "${all_mods.SKSE}" >> installed_mods.txt
      ''
      + (lib.concatMapStrings process-mod enabled_mods)
      +
      ''
      echo "Finished linking mods."

      # turn ini files into actual files (vs symlinks)
      fd -e ini -t l -x sh -c 'cp --remove-destination "$(readlink "$1")" "$1"' _

      mkdir -p ./Data/SKSE/
      cat ${pkgs.writeText "skse-ini" ''
        [Display]
        iTintTextureResolution=2048

        [General]
        ClearInvalidRegistrations=1
        EnableDiagnostics=1
        [Memory]
        DefaultHeapInitialAllocMB=768
        ScrapHeapSizeMB=256
        [Debug]
        WriteMiniDumps=1
      ''} > ./Data/SKSE/skse.ini

      echo "Please check for conflicts in $out/conflicted_files.txt"
      # format conflicts
      column -t -s ',' ./conflicted_files.txt | sponge ./conflicted_files.txt

      mv ./SkyrimSELauncher.exe ./SkyrimSELauncher.exe.bak

      # I have no audio, otherwise...
      mv ./skse64_loader.exe ./SkyrimSELauncher.exe
    '';

    installPhase = ''
      mkdir -p $out
      cp -r --preserve=links ./* $out
    '';
  };

}
