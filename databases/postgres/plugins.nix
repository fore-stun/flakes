{ lib
, callPackage
}:

lib.mapAttrs (n: f: callPackage f { }) {
}
