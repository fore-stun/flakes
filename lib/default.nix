{ lib, ... }:

let
  lang = l: x: x;

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

  pythonScopeWith = prev: pythonVariant: overlays:
    let
      python3 = prev."python${pythonVariant}";
      pkgs = python3.pkgs.overrideScope (lib.composeManyExtensions overlays);
    in
    {
      "python${pythonVariant}" = python3 // {
        inherit pkgs;
        withPackages = f: python3.buildEnv.override { extraLibs = f pkgs; };

        packageOverrides = lib.warn ''
          `python3.packageOverrides` does not compose;
          instead, manually replace the `pkgs` attr of `python3` with `python3.pkgs.overrideScope` applied to the overrides.
        ''
          prev.python3.packageOverrides;
      };
      "python${pythonVariant}Packages" = pkgs;
    };


  allFlakeSources =
    let
      f = r: x: lib.pipe x [ builtins.attrValues (builtins.concatMap r) ];
      collectFlakeInputs = input: [ input ] ++ f collectFlakeInputs (input.inputs or { });
    in
    f collectFlakeInputs;

  prefixStringLines = prefix: str:
    lib.concatMapStringsSep "\n" (line: prefix + line) (lib.splitString "\n" str);

  indent = prefixStringLines "  ";

  shellHook = args: ''
    interactive_shellhook() {
      ${indent args.interactive or "return 0"}
    }

    non_interactive_shellhook() {
      ${indent args.nonInteractive or "return 0"}
    }

    case "$-" in
      *i*)
        interactive_shellhook
        ;;
      *)
        non_interactive_shellhook
        ;;
    esac
  '';

in
lib.recursiveUpdate lib {
  platforms = { inherit anyNix; };
  licenses = { inherit dual; };
  inherit
    allFlakeSources
    indent
    lang
    shellHook
    standalone
    prefixStringLines
    pythonScopeWith
    ;
}
