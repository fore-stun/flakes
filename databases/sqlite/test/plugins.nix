{ lib
, runCommandLocal
, sqlite-extended
, sqlitePlugins
, writers
}:

let
  sqliteScript = writers.writeText "sqlite-plugin-test-script.sql" ''
    .load define
    .load stats
    .load ipaddr
    .load math
    .load text
    .load unicode
    .load vsv
    .load pivot_vtab

    select(eval('select 1;'));

    -- sum x = 1 + 2 + 3 + 4 + 5
    --       = 1 + 1 + 1 + 1 + 1
    --       +     1 + 2 + 3 + 4
    --       = 1 + 1 + 1 + 1 + 1
    --       +     1 + 1 + 1 + 1
    --       +         1 + 1 + 1
    --       +             1 + 1
    --       +                 1
    --       = 0 + 1 + 1 + 1 + 1 + 1
    --       + 0 + 0 + 1 + 1 + 1 + 1
    --       + 0 + 0 + 0 + 1 + 1 + 1
    --       + 0 + 0 + 0 + 0 + 1 + 1
    --       + 0 + 0 + 0 + 0 + 0 + 1
    -- 
    --  x
    --  ∑ r = ½ x (x + 1)
    -- r=1

    -- 1  1  2 1×2
    -- 2  3  6 2×3
    -- 3  6 12 3×4
    -- 4 10 20 4×5
    -- 5 15 30 5×6
    -- 6 21 42 6×7
    -- 7 28 56 7×8
    select define('sumn', ':x * (:x + 1) / 2');

    -- sum x² = 1 + 4 + 9 + 16 + 25
    --        = 1 + 3 + 5 +  7 +  9
    --        +     1 + 4 +  9 + 16
    --        = 1 + 3 + 5 +  7 +  9
    --        +     1 + 3 +  5 +  7
    --        +         1 +  3 +  5
    --        +              1 +  3
    --        +                   1
    --        = 5×1 + 4×3 + 3×5 + 2×7 + 1×9
    --
    --  x       x
    --  ∑ r² =  ∑ (x - r + 1) (2r - 1)
    -- r=1     r=1
    --
    --  x+1    x+1
    --  ∑ r² =  ∑ (x - r + 1) (2r - 1)
    -- r=1     r=1
    --
    --                   x
    --       =  (x+1)² + ∑ r²
    --                  r=1
    --
    --                        x
    --       =  x² + 2x + 1 + ∑ (x - r + 1) (2r - 1)
    --                       r=1
    --
    --  x           x
    --  ∑ (r+1)² =  ∑ (x - r) (2r + 1)
    -- r=0         r=0
    --
    --                       x        x       x
    --           =  (2x - 1) ∑ r +  x ∑ 1 - 2 ∑ r²
    --                      r=0      r=0     r=0
    --
    --                       x       x+1      x
    --           =  (2x - 1) ∑ r +  x ∑ 1 - 2 ∑ r²
    --                      r=1      r=1     r=1
    --
    --           =  (2x - 1) · ½ x (x + 1)
    --           +  x (x + 1)
    --           - 2 ∑ r²
    --

    --  x       x
    --  ∑ r² =  ∑ (x - r + 1) (2r - 1)
    -- r=1     r=1
    --
    --          x
    --       =  ∑ 2xr - x - 2r² + r + 2r - 1
    --         r=1
    --
    --            x               x      x
    --       = -2 ∑ r² + (2x + 3) ∑ r -  ∑ (x + 1)
    --           r=1             r=1    r=1
    --
    --                                              x
    --       = ½ x (x + 1) (2x + 3) - x (x + 1) - 2 ∑ r²
    --                                             r=1
    --
    --   x
    -- 3 ∑ r² = ½ x (x + 1) (2x + 3) - x (x + 1)
    --  r=1
    --
    --        = x (x + 1) · (½ (2x + 3) - 1)
    --        = ½ x (x + 1) · (2x + 3 - 2)
    --        = ½ x (x + 1) · (2x + 1)

    -- 1   1   1         6   6×1   3×2×1 3×2
    -- 2   4   5  5× 1  30  15×2   5×3×2 5×3×2
    -- 3   9  14  7× 2  84  28×3   7×4×3 7×3×2×2
    -- 4  16  30 10× 3 180  45×4   9×5×4 5×3×3×2×2
    -- 5  25  55 11× 5 330  66×5  11×6×5 11×5×3×2
    -- 6  36  91 13× 7 546  91×6  13×7×6 13×7×3×2
    -- 7  49 140 14×10 840 120×7  15×8×7 7×5×3×2×2×2

    --  x
    --  ∑ r² = x (x + 1) (2x + 1) / 6
    -- r=1
    select define('sumn2', ':x * (:x + 1) * (2 * :x + 1) / 6');

    select sumn(7);

    select sumn2(7);

    select median(value), variance(value) from generate_series(1,99);

    create table tailnet (ip text not null primary key, host text not null unique);

    insert into tailnet
      values ('100.124.159.170', 'wide-eyed-chair-7519' )
           , ('100.98.151.24'  , 'profuse-calendar-8079')
           , ('100.114.141.166', 'flashy-key-7272'      )
           , ('100.86.185.34'  , 'tight-bit-6576'       )
           , ('100.73.129.102' , 'snotty-bikes-2817'    )
           , ('100.122.81.249' , 'smooth-believe-3045'  )
           , ('100.115.254.74' , 'shiny-smile-8847'     )
           , ('100.114.219.120', 'scared-grip-5574'     )
           , ('100.74.34.193'  , 'eminent-copy-2277'    )
           , ('100.114.211.15' , 'fragile-tray-6166'    )
           , ('100.65.40.80'   , 'efficient-profit-1157')
    ;

    create virtual table tailsubnet using pivot_vtab(
      (select host from tailnet),
      (select value, value from generate_series(8,16)),
      (select ipnetwork(ip || '/' || value)
         from tailnet
            , generate_series(8,16)
        where host = ?1
          and value = ?2
      )
    );

    select * from tailsubnet;

    select degrees(pi());

    select text_join(' ', 'This', 'is', 'ok'), upper('This is ok');

    create virtual table people using vsv(
        data='11,Diane,London
        22,Grace,Berlin
        33,Alice,Paris',
        schema="create table people(id integer, name text, city text)",
        columns=3,
        affinity=integer
    );

    select * from people;
  '';

in

runCommandLocal "sqlite-plugin-tests" { } ''
  ${lib.getExe sqlite-extended} --box ':memory:' '.read ${sqliteScript}' >&2
  if ! [[ ${sqlitePlugins.rot13.version} = ${sqlite-extended.version} ]]; then
    echo "Sqlite amalgam (plugins) doesn't match executable version" >&2
    exit 4
  fi
  touch "$out"
''
