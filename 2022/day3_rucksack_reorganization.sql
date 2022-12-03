-- https://adventofcode.com/2022/day/3

create table rucksack(
        id integer not null generated always as identity
        items text);

\copy rucksack from 'day3_input'

----------------------------------------------------------------------------
-- part one

with rucksack_left as
(
        select id, string_to_table(left(items, length(items) / 2), NULL) as item
        from rucksack
),
rucksack_right as
(
        select id, string_to_table(right(items, length(items) / 2), NULL) as item
        from rucksack
),
common_items as
(
        select distinct l.id, l.item, case when ascii(l.item) >= 97 then ascii(l.item) - 96 else ascii(l.item) - 38  end as priority
        from rucksack_left l
        inner join rucksack_right r on
                l.id = r.id AND l.item = r.item
)
select sum(common_items.priority)
from common_items;

----------------------------------------------------------------------------
-- part two
-- This is dirty but i'm too lazy now to improve it today

with c as (
        select  id, items, row_number() over (partition by (id+2)/3) as rn
        from rucksack
) ,
c2 as (
        select (id+2)/3 as g,rn, string_to_table(items, NULL) as item
        from c
        group by g, item,rn
),
c3 as (
        select case when ascii(item) >= 97 then ascii(item) - 96 else ascii(item) - 38  end as priority
        from c2
        group by g,item
        having count(*) = 3
)
select sum(priority)
from c3;
