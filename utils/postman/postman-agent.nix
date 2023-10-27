{ lib
, fetchzip
, patchelf
, stdenvNoCC
}:

let
  pname = "postman-agent";
  version = "0.4.16";


  src = fetchzip {
    url = "https://dl-agent.pstmn.io/download/latest/linux";
    hash = "sha256:05gm1lz7q6vqnzfgjljsbvgm4h08xmrqyjw504d003r7k5v7kfhh";
    name = "${pname}-${version}-linux-x64.tar.gz";
  };

in
stdenvNoCC.mkDerivation {
  inherit pname version src;
  installPhase = ''
    mkdir -p "$out/bin"
    mkdir -p "$out/lib"
    mv "$src/app" "$out/lib"
    mv "$src/Postman Agent" "$out/bin"
  '';
  preFixup = ''
    patchelf "$out/app/Postman Agent"
  '';
}
