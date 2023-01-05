{ lib
, stdenvNoCC
, nodejs_latest
, fetchzip
}:

let
  pname = "tailwindcss-language-server";
  version = "0.0.10";
  name = "${pname}-${version}";
  src = fetchzip {
    name = "${name}-src";
    url = "https://registry.npmjs.org/@tailwindcss/language-server/-/language-server-0.0.10.tgz";
    hash = "sha256-j85HiDX2kZwQxJmOv8oXrZ12YGlDdec9HyRMnTSaIKY=";
  };

in
stdenvNoCC.mkDerivation {
  inherit pname version src;

  installPhase = ''
    mkdir -p "$out/bin"
    cp -rv "$src/bin" "$out/"
    chmod +x "$out/bin/${pname}"
  '';

  propagatedBuildInputs = [
    nodejs_latest
  ];

  meta = {
    description = "Language Server Protocol implementation for Tailwind CSS, used by Tailwind CSS IntelliSense for VS Code.";
    homepage = "https://github.com/tailwindlabs/tailwindcss-intellisense/tree/master/packages/tailwindcss-language-server";
    license = lib.licenses.mit;
  };
}

