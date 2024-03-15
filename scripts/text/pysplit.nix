{ lib
, python3Packages
, writers
}:

let
  pname = "pysplit";
  version = "0.0.1";

  script = writers.writePythonBin "${pname}"
    {
      libraries = builtins.attrValues
        {
          inherit (python3Packages) pysbd;
        };
    } ''
    from itertools import groupby
    import sys

    import pysbd


    def main():
        text = sys.stdin.read().splitlines()
        seg = pysbd.Segmenter(language="en", clean=False)
        for chunk in ("\n".join(l) for _, l in groupby(text, lambda x: x != "")):
            if chunk.startswith("#"):
                print(chunk)
                continue
            for t in seg.segment(chunk) or [""]:
                print(t.rstrip())


    if __name__ == "__main__":
        main()
  '';

in
lib.standalone { inherit version script; }
