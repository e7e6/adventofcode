drop table if exists input;
create table input(id integer generated always as identity, line text);

\copy input (line) from 'day16_test.input'
--\copy input (line) from 'day16.input'

with recursive data as (
select id,
       substring(line from 7 for 2) as source_valve,
       regexp_split_to_table(replace(right(line, -position('valve' in line)-5), ' ', ''), ',') as destination_valve,
       (substring(line from '[0-9]+'))::int as flow_rate
from input) ,
search_graph(
  source_valve,
  destination_valve,
  flow_rate,
  minutes,
  path  -- path, stored using an array
) AS (
        SELECT
          source_valve,
          destination_valve,
          flow_rate,
          0 as minutes,
          ARRAY['m' || source_valve] as path  -- idea is to put m in the path meaning 'm'ove or o for 'o'pen
        FROM data
        WHERE source_valve = 'AA'
      UNION ALL
      -- might have to do other UNION: for valve opening and for moving directly to another one
       SELECT
          d.source_valve,
          d.destination_valve,
          --d.flow_rate+(sg.flow_rate) as flow_rate,
          case when 'o'||d.source_valve <> ALL (sg.path) then sg.flow_rate + d.flow_rate * (30 - minutes) else sg.flow_rate end as flow_rate,
          --case when d.source_valve <> ALL (sg.path) and d.flow_rate > 0 then sg.minutes + 2 else sg.minutes + 1 end as minutes,
          case when d.source_valve <> ALL (sg.path) then sg.minutes + 2 else sg.minutes + 1 end as minutes,
          --sg.minutes + 1 as minutes,
        case when d.source_valve <> ALL (sg.path) then path || 'o' || d.source_valve else path || 'm' || d.source_valve as path
          path || d.source_valve as path
        FROM data d, search_graph AS sg
        WHERE
          d.source_valve = sg.destination_valve
          --AND (d.source_valve <> ALL(sg.path))
          AND sg.minutes <= 20
)
SELECT path, flow_rate, minutes
from search_graph
order by flow_rate desc
limit 20;
