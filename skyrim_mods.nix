{ skyrim_version ? "1.6.1170.0"# to assert versions
, pkgs ? (import <nixpkgs> { })
}:
let
  inherit (pkgs) lib;
  # dummy placeholders just for documentation.
  # usually mods don't specify versions; pray that it just werks regardless.
  fetch_7z = (pkgs.callPackage ./fetch_7z.nix);
  some_microsoft_visual_cpp_redistributable = "ignore";
  unpack-generic-mod = args: import ./unpack-generic-mod.nix (args // { inherit pkgs; });
in
  # this simply defines the mods.
  # Please use Capitalization for filepaths -- Windows filepaths are not case sensitive...?
  #
  # each mod will be a unique nix store output.
  # they only get mixed together in default.nix
  # 
  # mod versions below may look a bit weird because I initially got them by exporting a csv from ModOrganizer.
  # 
  # Each attribute in the below set should be a valid mod. The mod should be unpacked from its archive (zip,7z)
  # and, it should be ready to just be copied on top of the skyrim installation
  #
  # 
  # 
  #
  # Optionally dev outputs with sources... idk, try to keep it consistent... we may merge them all together like the mods
  # at some point.
  #
  # TODO: Requirements use like SKYUI. but maybe you have SKYUI_RU...?
  # 
assert (lib.versionAtLeast (lib.versions.majorMinor skyrim_version) "1.6"); # 
rec {
  SKSE = pkgs.stdenvNoCC.mkDerivation {
    name = "SKSE v2.2.6";
    requires = [];
    src = fetch_7z {
      name = "SKSE v2.2.6 - src";
      url = "https://skse.silverlock.org/beta/skse64_2_02_06.7z";
      hash = "sha256-SKQNkjx0rMhU1ORnX3AtvVP2rOt78nRf34AhQEETeEY=";
      stripRoot = true;
    };

    outputs = [ "out" "dev" ];
    installPhase = ''
      mkdir -p $dev/Scripts/
      mv -t $dev ./src/*
      rmdir src
      mv -t $dev/Scripts/ ./Data/Scripts/Source/*
      rmdir ./Data/Scripts/Source

      mkdir -p $out/
      mv -t $out ./*
    '';
  };
  Alternate_Start = (unpack-generic-mod rec {
    filename = "Alternate_Start-${mod_version}.7z";
    mod_version = "4.2.5";
    sha256 = "0qd3rwpxcxns7z244q0lf909vmq12nxf2zzg592mhxg3zki6453y";
    requires = [ ]; # none
    # mod_id = 272;
    # file_id = 642220;
  });
  Address_Library_for_SKSE_Plugins = (unpack-generic-mod rec {
    filename = "Address_Library_for_SKSE_Plugins-${mod_version}.zip";
    mod_version = "11";
    sha256 = "00hs4f9v8ybkyp2bvf4djj8wii6v69a2h89slr7965nsraqrl077";
    requires = [ ]; # none
    # mod_id = 32444;
    # file_id = 470707;
  });
  ConsoleUtilSSE = (unpack-generic-mod rec {
    filename = "ConsoleUtilSSE-${mod_version}.7z";
    mod_version = "1.5.1";
    sha256 = "1cq6444cmv70ccwfn3gd2r2s17908wdsq2hgli9hmr7i284mrbhp";
    requires = [
      Address_Library_for_SKSE_Plugins
    ];

    # mod_id= 76649;
    # file_id = 456904;
    outputs = [ "out" "dev" ];
    installPhase = ''
      mkdir -p $out $dev/Scripts/
      mv -t $dev/Scripts ./Scripts/Source/*
      rmdir ./Scripts/Source
      mv -t $out ./*
    '';
  });
  PapyrusUtil_SE_Modders_Scripting_Utility_Functions = (unpack-generic-mod rec {
    mod_version = "4.6";
    filename = "PapyrusUtil_SE_Modders_Scripting_Utility_Functions-${mod_version}.zip";
    sha256 = "0g8yxya882c1kyilmfj0mdz5j89y5jnsk4m2axmcfni1z3d3n6s4";

    requires = [
      SKSE
      Address_Library_for_SKSE_Plugins
    ];

    outputs = [ "out" "dev" ];
    installPhase = ''
      # this redundantly has two copies of the same source files.
      rm -r ./Scripts/Source/
       
      mkdir -p $dev/Scripts/
      mv -t $dev/Scripts/ Source/Scripts/*

      rm -r Source/
      rm Readme*

      mkdir -p $out
      ls -la
      mv -t $out ./*
    '';
    # mod_id= 13048;
    # file_id = 462773;
  });
  powerofthrees_Tweaks = (unpack-generic-mod rec {
    mod_version = "1.13";
    filename = "powerofthrees_Tweaks-${mod_version}.7z";
    sha256 = "1l8y3s7zn03v5i463gbhb6arhmys1jwgmzyjq5v5v0j73ixscy8a";
    requires = [
      Address_Library_for_SKSE_Plugins
    ];
    # mod_id= 51073;
    # file_id = 573995;
    outputs = [ "out" "dev" ];
    stripRoot = true;
    installPhase = ''
      mkdir -p $out/Scripts $dev/Scripts/
      mv -t $dev/Scripts ./Required/source/scripts/*

      mv ./Required/scripts $out/Scripts
      mv ./SE/SKSE $out/SKSE 
    '';
  });
  powerofthrees_Papyrus_Extender = (unpack-generic-mod rec {
    mod_version = "6.0.2";
    filename = "powerofthrees_Papyrus_Extender-${mod_version}.7z";
    sha256 = "0b7zh1536lbs86qj7h5nvz5c167aki08y4frdx3k3ddn9f6spx27";
    requires = [
      Address_Library_for_SKSE_Plugins
      powerofthrees_Tweaks
    ];
    # mod_id= 22854;
    # file_id = 636552;
    outputs = [ "out" "dev" ];
    stripRoot = true;
    installPhase = ''
      mkdir -p $out/ $dev/Scripts/
      mv -t $dev/Scripts/ ./Required/Source/scripts/*
      rm -r ./Required/Source
      mv -t $out ./Required/* 
      mv -t $out ./SE/* 
    '';
  });
  Unofficial_Skyrim_Special_Edition_Patch = (unpack-generic-mod rec {
    mod_version = "4.3.4a";
    filename = "Unofficial_Skyrim_Special_Edition_Patch-${mod_version}.7z";
    requires = [
      SKSE
      some_microsoft_visual_cpp_redistributable
    ];
    # mod_id = 266;
    # file_id = 598358;
    sha256 = "05jxmlwbcs04zcxm7rcvwp9bjmb7i6x3jngknq7fpfj0yl3yngfz";
    installPhase = ''
      mkdir -p $out/Data
      mv -t $out ./Docs
      mv -t $out ./BashTags
      mv -t $out ./* 
    '';
  });
  RUS_Unofficial_Skyrim_Special_Edition_Patch = (unpack-generic-mod rec {
    mod_version = "4.3.4";
    sha256 = "0jsz4qz8qdmigww2s4s12ww13xx2fjc9k4rpd268422h2iisjyb1";
    filename = "RUS_Unofficial_Skyrim_Special_Edition_Patch-${mod_version}.zip";
    requires = [
      Unofficial_Skyrim_Special_Edition_Patch
    ];
    # mod_id = 142395;
    # file_id = 597044;
  });
  Fuz_Ro_Doh = (unpack-generic-mod rec {
    mod_version = "2.5";
    sha256 = "0hghbh1aw8vs9mjhc0p7kqhxhsnzbvhpdvqwgjcji74b2rrn11gr";
    filename = "Fuz_Ro_Doh-${mod_version}.7z";
    requires = [ ];
    # mod_id = 15109;
    # file_id = 464222;
  });
  SSE_Display_Tweaks = (unpack-generic-mod rec {
    mod_version = "0.5.16";
    filename = "SSE_Display_Tweaks-${mod_version}.zip";
    sha256 = "1q3l65mlwx8nwzr968yhjjwvyl88w7pnch935al2mwccaipvrf08";
    requires = [
      SKSE
      Unofficial_Skyrim_Special_Edition_Patch
    ];
    # mod_id = 34705;
    # file_id = 454679;
  });
  Russian_Textures_and_Console_Font_Fix = (unpack-generic-mod rec {
    mod_version = "1.4";
    filename = "Russian_Textures_and_Console_Font_Fix-${mod_version}.zip";
    sha256 = "0yr6rd4hsb62zalkmjphyc2wb74ldd1ip868l1lag0cyss137ijq";
    requires = [ ];
    # mod_id= 887;
    # file_id = 590010;
  });
  Pelinal_RU_Font_replacer = (unpack-generic-mod rec {
    mod_version = "1.4.3.0";
    filename = "Pelinal_RU_Font_replacer-${mod_version}.7z";
    sha256 = "1hpzfqbdwz28s18fcxqfw49m1z555azrmqb39rirn2ncyl8fzgqk";
    requires = [
      Unofficial_Skyrim_Special_Edition_Patch
    ];
    # mod_id = 61264;
    # file_id = 254077;
    installPhase = ''
      mkdir -p $out/Interface
      mv -t $out/Interface ./Pelinal/interface/*
    '';
  });
  SkyUI =let
    ru = (unpack-generic-mod rec {
      #  Russian translation)
      mod_version = "5.2";
      filename = "SkyUI_RU-${mod_version}.7z";
      sha256 = "0qhn8clx7rflv66rd6j7z1svkasqp8ml3qyzcga7mxai23ly0xak";
      requires = [ ];
      # mod_id = 21088;
      # file_id = 71683;
      installPhase = ''
        mkdir -p $out
        rm -rf ./fomod
        mv -t $out/ ./*
      '';
    });
    en = (unpack-generic-mod rec {
      mod_version = "5.2";
      filename = "SkyUI_EN-${mod_version}.7z";
      sha256 = "0qhn8clx7rflv66rd6j7z1svkasqp8ml3qyzcga7mxai23ly0xak";
      requires = [ ];
      # mod_id = 12604;
      # file_id=35407
    });
  in
    ru;
  UIExtensions = (unpack-generic-mod rec {
    mod_version = "1.2";
    filename = "UIExtensions-${mod_version}.7z";
    sha256 = "19ip2ss00zarmyzaxppih5fwy1xaiw9i69zxs8x09bdylpix4p1x";
    requires = [ ];
    # mod_id= 17561;
    # file_id = 55628;
  });
  UIExtensions_RU = (unpack-generic-mod rec {
    mod_version = "1.2";
    filename = "UIExtensions_RU-${mod_version}.zip";
    sha256 = "0q36b9hy61pii1zfnpnw3ci5ivlk4xnc93f12hr29djfgp177k55";
    requires = [ UIExtensions ];
    # mod_id= 49301;
    # file_id = 201053;
    installPhase = ''
      mkdir -p $out/Interface/Translations/
      mv -t $out/Interface/Translations/ ./data/interface/translations/*
    '';
  });
  Spell_Perk_Item_Distributor = (unpack-generic-mod rec {
    mod_version = "7.1.3.0";
    filename = "Spell_Perk_Item_Distributor-${mod_version}.7z";
    sha256 = "140smcfskdgvp2yabcdci4b0cdi94lyi24vxffrjzjkb15zpl167";
    requires = [
      Address_Library_for_SKSE_Plugins
      powerofthrees_Tweaks
    ];
    # mod_id= 36869;
    # file_id = 491985;
    installPhase = ''
      mkdir -p $out
      mv ./SE/SKSE $out/SKSE/
    '';
    stripRoot=true;
  });
  Merge_Mapper = (unpack-generic-mod rec {
    mod_version = "1.5";
    filename = "Merge_Mapper-${mod_version}.7z";
    sha256 = "1vcljj3hvr5qzk4l5ym65y7946flxz03yyayq0ha96wr61gwshap";
    requires = [
      Address_Library_for_SKSE_Plugins
    ];
    # mod_id= 74689;
    # file_id = 8725;
  });
  Form_List_Manipulator = (unpack-generic-mod rec {
    mod_version = "1.8.1";
    filename = "Form_List_Manipulator-${mod_version}.zip";
    sha256 = "0qaxv4n1mnwr697pzxp04yi8adhylxikcslg99s8ar9m404axxxk";
    requires = [
      Address_Library_for_SKSE_Plugins
      Merge_Mapper
      powerofthrees_Tweaks
    ];
    # mod_id= 74037;
    # file_id = 546948;
  });
  Real_Names_Extended = (unpack-generic-mod rec {
    mod_version = "1.6";
    filename = "Real_Names_Extended-${mod_version}.7z";
    sha256 = "0f7l6a62dl3a47dh2bzpiglpk5kq7yzb463s7xcpn4hxwm5lci5q";
    requires = [
      Form_List_Manipulator
      PapyrusUtil_SE_Modders_Scripting_Utility_Functions
      SKSE
      SkyUI
      Spell_Perk_Item_Distributor
      UIExtensions
    ];
    # mod_id= 77038;
    # file_id = 326199;
    outputs = [ "out" "dev" ];
    installPhase = ''
      mkdir -p $out $dev/Scripts
      mv ./source/scripts/* $dev/Scripts
      rm -rf ./source

      mv ./skse/plugins ./skse/Plugins

      mv skse      $out/SKSE
      mv Interface/translations Interface/Translations
      mv Interface $out/Interface 
      mv scripts   $out/Scripts
      mv -t $out ./*
    '';

  });
  Subtitles = (unpack-generic-mod rec {
    mod_version = "0.6.2";
    filename = "Subtitles-${mod_version}.7z";
    sha256 = "0x4rkzwj3b2m0hv56x98zj2h4y8gp9cylrkhm9406ycs4kih03xn";
    requires = [
      Address_Library_for_SKSE_Plugins
      SKSE
    ];
    # mod_id= 113214;
    # file_id = 585712;
  });
  To_Your_Face = (unpack-generic-mod rec {
    mod_version = "1u";
    filename = "To_Your_Face-${mod_version}.zip";
    sha256 = "147phv25l08xdm620qvjd6p1jyzs78259riaqy46fw6r4mrfbwkd";
    requires = [
      SKSE
    ];
    # mod_id= 24720;
    # file_id = 464059;
  });
  Nethers_Follower_Framework = (unpack-generic-mod rec {
    mod_version = "2.8.6b";
    filename = "Nethers_Follower_Framework-${mod_version}.zip";
    sha256 = "01k0wcs383v4vrzll909gz8y54mhiqkclag5h0fs759sjl42p1lj";
    requires = [
      ConsoleUtilSSE
      Fuz_Ro_Doh
      PapyrusUtil_SE_Modders_Scripting_Utility_Functions
      SkyUI
      Spell_Perk_Item_Distributor
      Unofficial_Skyrim_Special_Edition_Patch
      SKSE
    ];
    # mod_id= 55653;
    # file_id = 489439;

    outputs = [ "out" "dev" ];
    # explicitly do *something* with each of the directories.
    # use cp to merge folders. mv doesn't
    installPhase =
      ''
        mkdir -p $out/Scripts $out/Sound $dev/Scripts

        rm -rf               00\ Main\ LE/
        cp -r -t $out/          00\ Main\ SSE/*
         
        mv 01\ Required/sound 01\ Required/Sound
        cp -r -t $out/          01\ Required/*
        
        cp -r -t $dev/Scripts/  02\ Scripts\ Source/* 
        rm -rf                  03\ Dummy\ Scripts/
        cp -r -t $out/          04\ SkyUILib/* 
        cp -r -t $out/          05\ Perk\ Distributor/* 
        cp -r -t $out/Scripts/  10\ Traps/Scripts/* 
        rm -r                   20\ Base\ Scripts/Scripts/ 
        rm -r                   22\ BAT\ Leveling/ 
        cp -r -t $out/          23\ BAT\ Classes/*

        # Interesting NPCs support
        rm -rf               30\ iNPC/

        # Relationship Overhaul, only use if buggy stuff interacting with followers
        rm -rf               35\ RDO\ Main/
        rm -rf               36\ RDO\ Comments/

        # NTMD for no team magic damage, says not really needed
        rm -rf               40\ NTMD Main LE
        rm -rf               40\ NTMD Main SSE
        rm -rf               41\ NTMD Scripts
        rm -rf               45\ NTMD Apocalypse LE
        rm -rf               45\ NTMD Apocalypse SSE
        rm -rf               46\ NTMD Elemental Destruction LE
        rm -rf               46\ NTMD Elemental Destruction SSE

        mv $out/meshes $out/Meshes
      '';
  });
  Nethers_Follower_Framework_RU = (unpack-generic-mod rec {
    mod_version = "2.8.6b";
    filename = "Nethers_Follower_Framework_RU-${mod_version}.7z";
    sha256 = "03g6hwk2wcy8n2ipm726jg9z8xc6qgi33ncrzx9j6yklbzxqkkfb";
    requires = [
      Nethers_Follower_Framework
    ];

    extraInputs = [ pkgs.fd ];
    outputs = [ "out" "dev" ];
    installPhase = ''
      mkdir -p $out/Scripts $out/Interface $out/Sound $dev/Scripts
      cd 00\ Data/

      # not using LE
      rm -rf *_LE*

      mv -t $out/           01_SE/* 
      mv -t $out/           02_SE_NoTeamMagicDamage/*
      mv -t $out/Scripts/   03_Scripts_SE/Scripts/* 
      mv -t $dev/Scripts/   03_Scripts_Source/* 
      mv -t $out/Interface/ 04_Interface/Interface/* 
      mv -t $out/Sound      05_Sound/Sound/*
    '';
    # file_id = 626654;
    # mod_id = 28089;
  });

  # It's nice this is on github. This makes life easier. It has binaries included.
  CHIM_AIAgent = pkgs.stdenvNoCC.mkDerivation {
    src = pkgs.fetchFromGitHub {
      owner = "abeiro";
      repo = "aiagent-aiff";
      rev = "7d4b90238c9e23da9fa2c59cedd400442c5e896a";
      hash = "";
    };

    dontFixup=true;
    installPhase = ''
      mkdir -p $out
      cp -t $
      cp ./* $out
    '';
  };


  (unpack-generic-mod rec {
    mod_version = "1.3.3b";
    filename = "CHIM_AIAgent-${mod_version}.zip";
    sha256 = "0bia591810l8bvk9sld6baygn5rmnijbkbp7a90dfmx7wc9dmn9h";
    requires = [
      Address_Library_for_SKSE_Plugins
      ConsoleUtilSSE
      PapyrusUtil_SE_Modders_Scripting_Utility_Functions
      powerofthrees_Papyrus_Extender
      Real_Names_Extended
      SkyUI
      SSE_Display_Tweaks
      UIExtensions
      some_microsoft_visual_cpp_redistributable
    ];
    # mod_id= 126330;
    # file_id = 635638;
    stripRoot = true;
    outputs = [ "out" "dev" ];
    installPhase = ''
      mkdir -p $out $dev/Scripts
      rm ./CHIM.exe
      mv -t $dev/Scripts ./Source/Scripts/*
      rm -r ./Source
      mv -t $out ./*
    '';
  });
}
