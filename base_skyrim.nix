# This nix derivation creates an unmodded skyrim with a unique hash.
{ skyrim_version ? "1.6.1170.0"
, requireFile
}:
let
  version-info = {
    # from steam. 
    "1.6.1170.0" = {
      hash = "0wyh25a8pq2izsskzfwa6wzmc1rpa8gn0sisyrg59jq0fngyvis6";
    };
  };
  inherit (version-info.${skyrim_version}) hash;
in
requireFile {
  name = "skyrim-${skyrim_version}.tar.gz";
  sha256 = "${hash}";
  message = ''
    To use this, download Skyrim, run
    tar -czvf "skyrim-${skyrim_version}.tar.gz" <install_dir>
    (install_dir should have SkyrimSE.exe, and should be fresh.)

    Then run: nix-prefetch-url file://<path-to-targz>
    You probably want to read the README.
  '';
}
