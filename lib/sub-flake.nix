{ lib
}:

{
  # location of subflake default.nix
  directory
, # attrset of dependencies attrsets, keyed by package name
  pnames
, # location of file where function is called as paths are a pain
  caller ? ../.
, # name of flake
  name ? lib.pipe directory [
    (lib.path.removePrefix caller)
    (lib.removePrefix "./")
  ]
}:

{
  overlays.${name} = final: prev:
    lib.flip lib.mapAttrs pnames (pname: extras:
      prev.callPackage (directory + "/${pname}.nix") (
        extras.depends or { }
        // (extras.prev or (_: { })) prev
        // (extras.final or (_: { })) final
      )
    );
}
