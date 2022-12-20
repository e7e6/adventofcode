-- WORK IN PROGRESS

-- test data
\copy input (line) from 'day15_test.input'

-- Sensor at x=2, y=18: closest beacon is at x=-2, y=15   
-- Sensor at x=9, y=16: closest beacon is at x=10, y=16   
-- Sensor at x=13, y=2: closest beacon is at x=15, y=3    
-- Sensor at x=12, y=14: closest beacon is at x=10, y=16  
-- Sensor at x=10, y=20: closest beacon is at x=10, y=16  
-- Sensor at x=14, y=17: closest beacon is at x=10, y=16  
-- Sensor at x=8, y=7: closest beacon is at x=2, y=10
-- Sensor at x=2, y=0: closest beacon is at x=2, y=10
-- Sensor at x=0, y=11: closest beacon is at x=2, y=10    
-- Sensor at x=20, y=14: closest beacon is at x=25, y=17  
-- Sensor at x=17, y=20: closest beacon is at x=21, y=22  
-- Sensor at x=16, y=7: closest beacon is at x=15, y=3    
-- Sensor at x=14, y=3: closest beacon is at x=15, y=3    
-- Sensor at x=20, y=1: closest beacon is at x=15, y=3    

-------------------------------------------------------   
-- FIRST PART
-------------------------------------------------------   


with dataprep as (
select id,
       (regexp_replace(line, 'Sensor at x=(-?[0-9]+), y=(-?[0-9]+): closest beacon is at x=(-?[0-9]+), y=(-?[0-9]+)', '\1'))::int as x_sensor,
       (regexp_replace(line, 'Sensor at x=(-?[0-9]+), y=(-?[0-9]+): closest beacon is at x=(-?[0-9]+), y=(-?[0-9]+)', '\2'))::int as y_sensor,
       (regexp_replace(line, 'Sensor at x=(-?[0-9]+), y=(-?[0-9]+): closest beacon is at x=(-?[0-9]+), y=(-?[0-9]+)', '\3'))::int as x_beacon,
       (regexp_replace(line, 'Sensor at x=(-?[0-9]+), y=(-?[0-9]+): closest beacon is at x=(-?[0-9]+), y=(-?[0-9]+)', '\4'))::int as y_beacon
from input) ,
geo as (
select (x_sensor || ',' || y_sensor)::point as sensor,
       (x_beacon || ',' || y_beacon)::point as beacon,
       circle((x_sensor || ',' || y_sensor)::point, abs(x_beacon - x_sensor) + abs(y_beacon - y_sensor)) as circle
from dataprep),
range as (
select least(MIN(x_sensor), MIN(x_beacon)) as minx,
       greatest(MAX(x_sensor), MAX(x_beacon)) as maxx
from dataprep)
select i, 
       bool_or(circle @> point(i,20)) 
from generate_series((select minx from range),(select maxx from range)) i 
cross join geo 
where point(i,20) not in (select beacon from geo) -- not the proper operator
group by i order by i;
