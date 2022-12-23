drop table if exists input;
create table input(id integer generated always as identity, line text);

\copy input (line) from 'day16_test.input'

-- test data
--\copy input (line) from 'day12_test.input'
-- Valve AA has flow rate=0; tunnels lead to valves DD, II, BB
-- Valve BB has flow rate=13; tunnels lead to valves CC, AA
-- Valve CC has flow rate=2; tunnels lead to valves DD, BB
-- Valve DD has flow rate=20; tunnels lead to valves CC, AA, EE
-- Valve EE has flow rate=3; tunnels lead to valves FF, DD
-- Valve FF has flow rate=0; tunnels lead to valves EE, GG
-- Valve GG has flow rate=0; tunnels lead to valves FF, HH
-- Valve HH has flow rate=22; tunnel leads to valve GG
-- Valve II has flow rate=0; tunnels lead to valves AA, JJ
-- Valve JJ has flow rate=21; tunnel leads to valve II

with dataprep as (
select id,
       substring(line from 7 for 2) as source_valve,
       substring(line from '[0-9]+') as flow_rate,
       regexp_split_to_table(replace(right(line, -position('valve' in line)-5), ' ', ''), ',') as destination_valve,
from input)
select * from dataprep;
