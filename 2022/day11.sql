drop table if exists keepaway;
create table keepaway(id integer generated always as identity, data text);

--\copy signal (x_register) from 'day10.input' 

-- test data
\copy keepaway (data) from 'day11_test.input'

-------------------------------------------------------
-- FIRST PART... not done.
-------------------------------------------------------

with rep as (
select id / 7 as monkey,
       case when data like '%Starting items%' then regexp_split_to_array( right(data, length(data) - 18), ', ') end as items,
       case when data like '%Operation%' then right(data, length(data) - 19) end as operation,
       case when data like '%Test%' then substring(data from '[0-9]+') end as divisible_by,
       case when data like '%If true%' then substring(data from '[0-9]+')::int end as if_true,
       case when data like '%If false%' then substring(data from '[0-9]+')::int end as if_false
from keepaway
where data != '' and
      data not like 'Monkey%'
),
representation as (
select monkey,
       max(items) as items,
       max(operation) as operation,
       max(divisible_by) as divisible_by,
       max(if_true) as if_true,
       max(if_false) as if_false
from rep
group by monkey
order by monkey
)
select * 
from representation;

-- monkey |     items     | operation | divisible_by | if_true | if_false
----------+---------------+-----------+--------------+---------+----------
--      0 | {79,98}       | old * 19  | 23           |       2 |        3
--      1 | {54,65,75,74} | old + 6   | 19           |       2 |        0
--      2 | {79,60,97}    | old * old | 13           |       1 |        3
--      3 | {74}          | old + 3   | 17           |       0 |        1

-- there is some interesting stuff below
-- to reformat the data and iterate, but no time to go further

--
--first_two_actions as (
--select ord, monkey, items, operation, divisible_by::integer, if_true, if_false,
--       i.val::integer as current_item,
--       case (regexp_split_to_array(operation, ' '))[2]
--        when '+' then 
--		case 
--                when (regexp_split_to_array(operation, ' '))[3] = 'old' 
--			then (i.val::integer + i.val::integer) / 3
--		else (i.val::integer + (regexp_split_to_array(operation, ' '))[3]::integer) / 3
--                end
--        else 
--		case 
--                when (regexp_split_to_array(operation, ' '))[3] = 'old' 
--			then (i.val::integer * i.val::integer) / 3
--		else (i.val::integer * (regexp_split_to_array(operation, ' '))[3]::integer) / 3
--		end
--        end as new_item
--from representation
--cross join lateral unnest(items) with ordinality as i(val, ord) 
--),
--fa_cleanup as (
--select row_number() over () as rn,
--       ord, monkey, 
--       -- items,
--       items[ord:] as items,
--       current_item, new_item,divisible_by, 
--       case when new_item % divisible_by = 0 
--	then if_true
--	else if_false
--       end as send_to_monkey_n
--from first_two_actions
--)
--select rn,
--	ord, monkey,
--	case when ord = 1 then items || (select array(select fac.new_item::text
--                                  	from fa_cleanup fac
--                                  	where facleanup.send_to_monkey_n = fac.monkey and fac.rn < facleanup.rn))
--		else items end,
--       current_item, new_item,divisible_by, 
--send_to_monkey_n
--
--from fa_cleanup facleanup;
