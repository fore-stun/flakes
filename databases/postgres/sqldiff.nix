{ lib
, python3Packages
, writers
}:

let
  pname = "sqldiff";
  version = "0.1.0";

  script = writers.writePythonBin pname
    {
      libraries = builtins.attrValues
        {
          inherit (python3Packages) sqlglot;
        };
    } ''
    import argparse
    from sqlglot import diff, parse_one
    from sqlglot.expressions import Expression


    def parse_file(file_path: str) -> Expression:
        with open(file_path, 'r') as file:
            sql_content = file.read()
        return parse_one(sql_content)


    def main():
        parser = argparse.ArgumentParser(
            description='Parse SQL queries from files and compare them.'
        )
        parser.add_argument('file1', type=str, help='Path to the first SQL file')
        parser.add_argument('file2', type=str, help='Path to the second SQL file')

        args = parser.parse_args()
        print(diff(parse_file(args.file1), parse_file(args.file2)))


    if __name__ == "__main__":
        main()
  '';

in

lib.standalone { inherit version script; }
