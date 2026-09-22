{ lib
, fd
, sqlite
, writers
}:
let
  pname = "cf-kv-local";
  version = "0.1.0";

  script = writers.writeZshBin "${pname}" ''
    zparseopts -D -E -F -- \
      c=OPT_commit -commit=OPT_commit \
      m=OPT_metadata -include-metadata=OPT_metadata \
      v=OPT_verbose -verbose=OPT_verbose

    # 1. Automating DO and INSTANCE identification
    WORKDIR="''${WORKDIR:-.}"
    BASE_DIR="$WORKDIR/.wrangler/state/v3/do"

    KEY="''${CF_KEY:-__sql_migrations_lastID}"
    VALUE="''${1:-}"

    END_TRANSACTION="rollback";
    if (( #OPT_commit )); then
      END_TRANSACTION="commit";
    fi

    if [ ! -d "$BASE_DIR" ]; then
        print -- "❌ Error: Wrangler state directory not found at: $BASE_DIR" >&2
        exit 1
    fi

    # Find available Durable Objects namespaces
    local -a do_classes=($(${lib.getExe fd} --max-depth 1 --type directory . "$BASE_DIR" --exec basename {}))

    if ! (( $#do_classes )); then
        print -- "❌ No Durable Object storage directories found."
        exit 1
    fi

    # Select DO Class
    if [[ ''${#do_classes} -eq 1 ]]; then
        SELECTED_DO="''${do_classes[1]}"
    else
        print -- "💡 Multiple Durable Object classes found. Select one:"
        select opt in "''${(@)do_classes}"; do
            if [ -n "$opt" ]; then
                SELECTED_DO="$opt"
                break
            fi
        done
    fi

    # Find available SQLite instances for the chosen class
    INSTANCE_DIR="$BASE_DIR/$SELECTED_DO"
    local -a instances=($(${lib.getExe fd} --max-depth 1 --extension sqlite . "$INSTANCE_DIR" --exec basename {} .sqlite))

    # Exclude 'metadata' instance unless explicitly requested
    if ! (( $#OPT_metadata )); then
        instances=(''${instances:#metadata})
    fi

    if ! (( $#instances )); then
        print -- "❌ No active SQLite instances found for $SELECTED_DO."
        exit 1
    fi

    # Select SQLite Instance
    if [[ ''${#instances} -eq 1 ]]; then
        SELECTED_INSTANCE="''${instances[1]}"
    elif [[ ''${#instances} -gt 1 ]]; then
        print -- "💡 Multiple instances found for $SELECTED_DO. Select one:"
        select opt in "''${(@)instances}"; do
            if [[ -n "$opt" ]]; then
                SELECTED_INSTANCE="$opt"
                break
            fi
        done
    fi

    DB_PATH="$INSTANCE_DIR/$SELECTED_INSTANCE.sqlite"

    if ! (( $#VALUE )); then
      # 2 & 3. Modular SQLite query handling multiple data types safely
      # Cloudflare prefixes values with internal metadata headers.
      # Integers are extracted via bitshifting character arrays. 
      # Strings or JSON types slice past their metadata headers safely using SUBSTR().
      if (( $#OPT_verbose )); then
        print -- "🔍 Querying DB: $DB_PATH" >&2
      fi
      ${lib.getExe sqlite} --box "$DB_PATH" <<-SQL
    select key
         , case 
            -- Natively stored plaintext or clean text fallback
            when typeof(value) = 'text' then value

            -- If it is a blob, inspect the V8 type serialization tags
            when typeof(value) = 'blob' then
                case 
                    -- If it starts with V8 Magic Header (FF 0F) and has the Int tag (49)
                    when hex(substr(value, 1, 2)) = 'FF0F' and hex(substr(value, 3, 1)) = '49' then
                        cast(unicode(substr(value, 4, 1)) >> 1 as integer)

                    -- If it's a regular string/JSON block, slice off the 3-byte V8 header
                    else
                        substr(value, 4)
                end

            else '[Unknown Type]'
        end as decoded
    from _cf_kv;
    SQL
    else
      if (( $#OPT_verbose )); then
        print -- "🔍 Writing to DB: $DB_PATH (''${END_TRANSACTION} transaction)" >&2
      fi
      # 4. Write (integer) value to store
      ${lib.getExe sqlite} --box "$DB_PATH" <<-SQL
    .parameter init
    .parameter set :key "''${(qq)KEY?}"
    .parameter set :value "''${(qq)VALUE?}"

    begin;

    select :value as value;

    update _cf_kv
       set value = cast(unhex('FF0F49') || char(cast(:value as blob) << 1) as blob)
     where key = :key
    ;

    SELECT key, hex(value) as hex, cast(unicode(substr(value,4,1)) >> 1 as integer) as value from _cf_kv;

    ''${(q)END_TRANSACTION?};
    SQL
    fi
  '';
in
lib.standalone { inherit version script; }
