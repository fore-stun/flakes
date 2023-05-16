{ lib
, buildGoModule
, fetchFromGitHub
}:

let
  pname = "aztfexport";
  version = "0.11.0";

  src = fetchFromGitHub {
    name = "${pname}-${version}-src";
    owner = "Azure";
    repo = pname;
    rev = "a70eab527442ed3866285fc0337c59eb20ccca70";
    hash = "sha256-mdQyJcBft6R2rQ7Xhx71og1hxbAxejmfd/W4XnNGl6w=";
  };
in
buildGoModule {
  inherit pname version src;

  vendorHash = "sha256-9YjyDUVwloMl0kN+kylGe1INjc10FdgoqmmAnF4c16Y=";

  meta = {
    description = "A tool to bring existing Azure resources under Terraform's management";
    license = lib.licenses.mpl20;
  };
}
