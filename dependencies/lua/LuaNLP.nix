{ lib
, fetchFromGitHub
, lua
}:
let

  pname = "LuaNLP";
  version = "unstable-2022-09-08";
  name = "${pname}-${version}";

  owner = "pncnmnp";
  repo = pname;

  src = fetchFromGitHub {
    name = "${name}-src";
    inherit owner repo;
    rev = "2f8dc3a178f66a0ef6925a47fa0a99bcf30e2dd9";
    hash = "sha256-km6KQZS9KDSzuQQtuEA9CB0DU70k8A3w/9VNnY6bS1Q=";
  };

in
lua.pkgs.buildLuaPackage {
  inherit pname version src;

  propagatedBuildInputs = builtins.attrValues {
    inherit (lua.pkgs)
      lrexlib-pcre
      ;
  };

  dontBuild = true;

  # LUA_LIBDIR = "$out/lib/lua/${lua.luaversion}";
  # LUA_SHAREDIR = "$out/share/lua/${lua.luaversion}";

  installPhase = ''
    runHook preInstall

    LUA_SHAREDIR="$out/share/lua/${lua.luaversion}";
    mkdir -p "''${LUA_SHAREDIR?}"

    find . -type d -exec install -vdm755 "{}" "''${LUA_SHAREDIR?}/{}" \;

    find . -type f -name '*.lua' -exec install -vm755 "{}" "''${LUA_SHAREDIR?}/{}" \;
    find lemmatizer/wordnet/ -type f -name '*.*' -exec install -vm644 "{}" "''${LUA_SHAREDIR?}/{}" \;
    find sent/vader_lexicons/ -type f ! -name 'README*' -exec install -vm644 "{}" "''${LUA_SHAREDIR?}/{}" \;
    find stopword/stoplists/ -type f ! -name 'README*' -exec install -vm644 "{}" "''${LUA_SHAREDIR?}/{}" \;
    find tokenizer -type f -name treebank.json -exec install -vm644 "{}" "''${LUA_SHAREDIR?}/{}" \;

    mkdir -p "$out/share/doc"

    find . -type d -exec install -vdm755 "{}" "$out/share/doc/{}" \;

    find . -type f -name README.md -exec install -vm644 "{}" "$out/share/doc/{}" \;
    find . -type f -name README -exec install -vm644 "{}" "$out/share/doc/{}" \;
    find . -type f -name 'HOWTO*' -exec install -vm644 "{}" "$out/share/doc/{}" \;

    runHook postInstall
  '';

  meta = {
    description = "Natural Language Processing Library for Lua";
    license = lib.licenses.mit;
    homepage = "https://github.com/${owner}/${repo}";
  };
}
