{ name
, url
, hash
, stripRoot # move contents of tree up one level
, fetchurl
, p7zip
}:
fetchurl {
  inherit name url hash;
  nativeBuildInputs = [ p7zip ];
  downloadToTemp = true;
  recursiveHash = true;
  postFetch = ''
    ls -lta $downloadedFile
    tmpdir=$(mktemp -d)
    7z x $downloadedFile -o"$tmpdir"
    mkdir -p $out
  ''
  + (if stripRoot then
    ''
      nested_dir=$(cd $tmpdir && ls -A)
      mv $tmpdir/$nested_dir/* $out/
    '' else
    ''
      mv $tmpdir/* $out/
    '');
}
