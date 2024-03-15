{ writers
, python3Packages
}:

let
  pname = "pysplit";

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
script
