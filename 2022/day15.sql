drop table if exists input;
create table input(id integer generated always as identity, line text);

--\copy input (line) from 'day15_test.input'
\copy input (line) from 'day15.input'

-------------------------------------------------------
-- FIRST PART... 
-- Incorrect, but I so far fail to understand why
-------------------------------------------------------
--4408541 to low

with dataprep as
(
        select id,
               (regexp_replace(line, 'Sensor at x=(-?[0-9]+), y=(-?[0-9]+): closest beacon is at x=(-?[0-9]+), y=(-?[0-9]+)', '\1'))::int as x_sensor,
               (regexp_replace(line, 'Sensor at x=(-?[0-9]+), y=(-?[0-9]+): closest beacon is at x=(-?[0-9]+), y=(-?[0-9]+)', '\2'))::int as y_sensor,
               (regexp_replace(line, 'Sensor at x=(-?[0-9]+), y=(-?[0-9]+): closest beacon is at x=(-?[0-9]+), y=(-?[0-9]+)', '\3'))::int as x_beacon,
               (regexp_replace(line, 'Sensor at x=(-?[0-9]+), y=(-?[0-9]+): closest beacon is at x=(-?[0-9]+), y=(-?[0-9]+)', '\4'))::int as y_beacon
        from input
) ,
range as
(
        select least(MIN(x_sensor), MIN(x_beacon)) as minx,
               greatest(MAX(x_sensor), MAX(x_beacon)) as maxx
        from dataprep
)
,
check_exists as
(
        select i,
               bool_or(abs(i - x_sensor) + abs(2000000 - y_sensor) <= abs(x_beacon - x_sensor) + abs(y_beacon - y_sensor)
                       and not exists (select 1 from dataprep where x_beacon=i and y_beacon=2000000)) as presence
        from generate_series((select minx from range),(select maxx from range)) i
        cross join dataprep
        group by i
)
select count(*)
from check_exists
where presence;
