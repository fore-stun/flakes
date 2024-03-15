{ ... }:

{
  an = {
    final = pkgs: {
      inherit (pkgs) hunspellDicts;
    };
  };
  names = null;
}
