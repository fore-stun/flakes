{ ... }@inputs:

let
  lib = inputs.lib.recursiveUpdate inputs.lib {
    platforms = { inherit anyNix; };
    licenses = { inherit dual; };
    inherit
      standalone
      ;
  };

  anyNix = lib.platforms.darwin ++ lib.platforms.linux;

  dual = builtins.attrValues
    { inherit (lib.licenses) bsd3 asl20; };

  standalone =
    { version
    , script
    , meta ? { }
    , passthru ? { }
    }:

    script.overrideAttrs (old: {
      inherit version;
      meta = old.meta or { } // {
        inherit version;
        license = dual;
        platforms = anyNix;
      } // meta;
      passthru = old.passthru or { } // passthru;
    });

in
lib
