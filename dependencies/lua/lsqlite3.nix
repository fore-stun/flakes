{ lib
, lua
, fetchurl
, sqlite
, unzip
}:
let

  pname = "lsqlite3";
  version = "0.9.6-1";
  name = "${pname}-${version}";

  src = fetchurl {
    name = "${name}-src";
    url = "https://lua.sqlite.org/home/zip/lsqlite3_v096.zip?uuid=v0.9.6";
    hash = "sha256-Ccgm2oT0cNl7NQqFMI8bb4Ujsl/MyPmBEMC5+8ohGgk=";
  };

in
lua.pkgs.buildLuarocksPackage {
  inherit pname version src;

  nativeBuildInputs = [ unzip ];

  buildInputs = [ sqlite.dev ];

  unpackCmd = "unzip $curSrc";

  meta = {
    description = "A binding for Lua to the SQLite3 database library";
    license = lib.licenses.mit;
    homepage = "http://lua.sqlite.org/";
  };
}
