{ writers
, python3Packages
}:

writers.writePythonBin "pysplit"
{
  libraries = builtins.attrValues
    {
      inherit (python3Packages) pysbd;
    };
} ''
  import pysbd
  import sys


  def main():
      text = sys.stdin.read()
      seg = pysbd.Segmenter(language="en", clean=False)
      for t in seg.segment(text):
          print(t.rstrip())


  if __name__ == "__main__":
      main()
''
