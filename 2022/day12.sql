drop table if exists input;
create table input(id integer generated always as identity, line text);

--\copy input (line) from 'day12.input'

-- test data
\copy input (line) from 'day12_test.input'
-- Sabqponm
-- abcryxxl
-- accszExk
-- acctuvwj
-- abdefghi

-------------------------------------------------------
-- FIRST PART
-------------------------------------------------------

-- our goal is to have a table that will look like the following
-- for every point, give all possible reachable points
-- start end   start_or_end
-- (1,1) (1,2) true
-- (1,1) (2,1) true
-- (1,2) (2,2) false
-- ..

-- aoc=# select ascii('S'), ascii('a'),ascii('z'), ascii('E');
--  ascii | ascii | ascii | ascii
-- -------+-------+-------+-------
--     83 |    97 |   122 |    69

select point(a.x, a.y) as origin,
       point(b.x, b.y) as destination,
       a.height        as height
from (
        select id as x, p.y as y, p.height as height
        from input
        cross join lateral string_to_table(line, NULL) with ordinality  p(height, y)
) as a
cross join
(
        select id as x, p.y as y, p.height as height
        from input
        cross join lateral string_to_table(line, NULL) with ordinality p(height, y)
) as b
-- missing start and end point
where (a.x     = b.x and a.y + 1 = b.y and ((ascii(a.height) + 1 <= ascii(b.height)) or (a.height='S' and ascii(a.height) + 14 + 1 <= ascii (b.height))))
   or (a.x     = b.x and a.y - 1 = b.y and ((ascii(a.height) + 1 <= ascii(b.height)) or (a.height='S' and ascii(a.height) + 14 + 1 <= ascii (b.height))))
   or (a.x + 1 = b.x and a.y     = b.y and ((ascii(a.height) + 1 <= ascii(b.height)) or (a.height='S' and ascii(a.height) + 14 + 1 <= ascii (b.height))))
   or (a.x - 1 = b.x and a.y     = b.y and ((ascii(a.height) + 1 <= ascii(b.height)) or (a.height='S' and ascii(a.height) + 14 + 1 <= ascii (b.height))))

;
