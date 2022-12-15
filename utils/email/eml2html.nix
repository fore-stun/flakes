{ lib
, buildGoModule
, fetchFromGitHub
}:

let
  pname = "eml2html";
  version = "1.0.4";
  src = fetchFromGitHub {
    name = "${pname}-${version}-src";
    owner = "korylprince";
    repo = pname;
    rev = "c9258997dd52127ee54841453cea49bcb0f7d723";
    hash = "sha256-8ezZWfrwMPDWBA4pKG8uYcmM4JvWOm/Y0KvXLwMvM60=";
  };
in
buildGoModule {
  inherit pname version src;

  vendorHash = "sha256-KKfHX7PG72YmARt2LdHm2sYJDp5L/QyoNC5OEEiPBtE=";

  meta = {
    description = "Go library and command line tool to convert eml files to html";
    license = lib.licenses.mit;
  };
}
