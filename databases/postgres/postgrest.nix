{ lib
, postgrest
, system
}:

let
  p = import postgrest.outPath { inherit system; };

in
p.postgrestStatic
