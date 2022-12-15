drop table if exists input;
drop table if exists a;
create table input(id integer generated always as identity, line text);

\copy input (line) from 'aoc/day12.input'

-- test data
--\copy input (line) from 'day12_test.input'
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
-- origin destination height poi
-- (1,1) (1,2) a S
-- (1,1) (2,1) a S
-- (1,2) (2,2) b 
-- ..

-- aoc=# select ascii('S'), ascii('a'),ascii('z'), ascii('E');
--  ascii | ascii | ascii | ascii
-- -------+-------+-------+-------
--     83 |    97 |   122 |    69

create table a(c1 text,c2 text,height text, poi char, primary key (c1,c2));


insert into a
(
with recursive aa(c1,c2,height, poi) as 
(

select a.x || ',' || a.y as origin,
       b.x || ',' || b.y as destination,
       a.height        as height,
       a.poi           as poi
from (
	select id as x, p.y as y, 
	       case when p.height='S' or p.height='E' then p.height end as POI,
	       case when p.height='S' then 'a' when p.height='E' then 'z' else p.height end as height
        from input
        cross join lateral string_to_table(line, NULL) with ordinality  p(height, y)
) as a
cross join
(
        select id as x, p.y as y, 
	       case when p.height='S' or p.height='E' then p.height end as POI,
	       case when p.height='S' then 'a' when p.height='E' then 'z' else p.height end as height
        from input
        cross join lateral string_to_table(line, NULL) with ordinality p(height, y)
) as b
where (a.x     = b.x and a.y + 1 = b.y and ascii(a.height) + 1 >= ascii(b.height))
   or (a.x     = b.x and a.y - 1 = b.y and ascii(a.height) + 1 >= ascii(b.height))
   or (a.x + 1 = b.x and a.y     = b.y and ascii(a.height) + 1 >= ascii(b.height))
   or (a.x - 1 = b.x and a.y     = b.y and ascii(a.height) + 1 >= ascii(b.height))
)

select * from aa
);

analyze a;

select count(*) from a;

-- taken from https://www.alibabacloud.com/blog/postgresql-graph-search-practices---10-billion-scale-graph-with-millisecond-response_595039
-- but does not seem to work for big graphs

with recursive
search_graph(      
  c1,   -- point 1      
  c2,   -- point 2      
  height, -- edge property      
  poi,
  depth, -- depth, starting from 1      
  path  -- path, stored using an array      
) AS (      
        SELECT    -- ROOT node query      
          g.c1,   -- point 1      
          g.c2,   -- point 2      
          g.height as height,   -- edge property      
	  g.poi as poi,
          1 as depth,        -- initial depth =1      
          ARRAY[g.c1] as path  -- initial path         
        FROM a AS g       
        WHERE       
          c1 = '21,1' and poi = 'S'         -- ROOT node =?      
      UNION ALL      
       SELECT     -- recursive clause      
          g.c1,    -- point 1      
          g.c2,    -- point 2      
          g.height as height,          -- edge property      
	  g.poi as poi,
          sg.depth + 1 as depth,    -- depth + 1      
          path || g.c1 as path   -- add a new point to the path      
        FROM a AS g, search_graph AS sg   -- circular INNER JOIN      
        WHERE       
          g.c1 = sg.c2         -- recursive JOIN condition      
          AND (g.c1 <> ALL(sg.path))        -- prevent from cycling      
          AND sg.depth <= 30    -- search depth =? It can also be retained to prevent the search from being too deep and thus affecting the performance. For example, the search will not return after a depth of 10        
)      
SELECT * --depth - 1 
from search_graph      
where poi = 'E'   -- end of the shortest path      
limit 1;       -- query a recursive table. You can add LIMIT output or use a cursor     
