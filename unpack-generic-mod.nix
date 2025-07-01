{ filename
, mod_version
, sha256
, requires
, outputs ? [ "out" ]
, extraInputs ? [ ]
, installPhase ? null
, stripRoot ? false
, pkgs ? (import <nixpkgs> { })
}:
let
  inherit (pkgs) lib;
in
pkgs.stdenvNoCC.mkDerivation {
  # names are like, blah-version.zip. so we get just the blah-version.
  name = builtins.elemAt (builtins.match "^(.*)\\.[^.]+" filename) 0;

  inherit outputs;

  src = pkgs.requireFile {
    name = filename;
    inherit sha256;
    message = "please upload ${filename} to the nix store.";
  };

  dontFixup = true;
  nativeBuildInputs = [ pkgs.p7zip ] ++ extraInputs;

  inherit filename mod_version sha256 requires;

  unpackPhase = ''
    runHook preUnpack

    echo "src is $src"

    7z x "$src" -aoa -o./source/
    cd ./source
    ${lib.optionalString stripRoot ''cd "$(ls -A)"''}
   
    src=$PWD
    runHook postUnpack
  '';

  installPhase = (if installPhase != null then installPhase else ''
    runHook preInstall
    mkdir -p $out
    pwd ls -lta .
    mv ./* $out/
    runHook postInstall
    '');
}
