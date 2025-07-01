let
  pkgs = import <nixpkgs> { };
  def = (import ./default.nix { });
  save = def.all_mods // { inherit (def) base_skyrim_src_unpacked; };
  inherit (pkgs) lib;
in
# I highly recommend making a nix-root with this,
# so as not to lose the sources during experimentation.
pkgs.runCommand "keep-sources" { } ''
  mkdir -p $out/srcs $out/unpacked

  # Reference sources here so they become dependencies
  cd $out/srcs
  ${
    builtins.concatStringsSep "\n" (
      lib.mapAttrsToList (name: value:
         lib.optionalString (value ? src) "ln -s ${value.src} ${name}-src"
        )
        save
    )
  }

  cd $out/unpacked
  ${
    builtins.concatStringsSep "\n" (
      lib.mapAttrsToList (name: value:
         "ln -s ${value} ${name}"
        )
        save
    )
  }
''
