drop table if exists signal;
create table signal(id integer generated always as identity, x_register text);

\copy signal (x_register) from 'day10.input'

-- test data
--\copy signal (x_register) from 'day10_test.input'

-------------------------------------------------------
-- FIRST PART
-------------------------------------------------------

with si as (
        -- we will get all cycle increments
        select --id --, x_register,
       (select sum(case when x_register like 'noop' then 1 else 2 end)
        from signal s
        where s.id <= sig.id)+1 as cycle,
       (select sum(case when x_register like 'addx%' then (substring (x_register from 6))::int end) + 1
        from signal s
        where s.id <=sig.id) as x_running_count
        from signal sig

        UNION
        -- we add this to fill the gaps where we don't have the cycle
        -- but we don't have the running count, therefore will use some ugly max below
        select i,NULL
        from generate_series(1, (select max(id) from signal)) i
),
ssi as (
        select cycle * (select max(ss.x_running_count) from si ss where ss.cycle = si.cycle or ss.cycle = si.cycle - 1)
        as strength
        from si
        where si.cycle in (20, 60, 100, 140, 180, 220)
        group by cycle
        order by cycle
)
select sum(strength)
from ssi;

-------------------------------------------------------
-- SECOND PART
-------------------------------------------------------

