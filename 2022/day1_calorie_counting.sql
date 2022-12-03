-- https://adventofcode.com/2022/day/1

create table elf_calories(elf_id integer, calories integer);
\copy elf_calories (calories) from 'aoc/day1_input' with (NULL '');

do $$
<<myblock>>
        declare
                current_elf_id integer := 1;
                rec record;
                current_elf cursor
                        for select calories
                        from elf_calories;
begin
        open current_elf;
        loop
                fetch current_elf into rec;
                exit when not found;
                update elf_calories set elf_id = current_elf_id WHERE CURRENT OF current_elf;
                if rec.calories is null then
                        current_elf_id := current_elf_id + 1;
                end if;
        end loop;
        close current_elf;
end myblock $$;

-----------------------------------------------------------------
-- FIRST STAR
select elf_id, sum(calories) from elf_calories group by elf_id order by 2 desc;

-----------------------------------------------------------------
-- SECOND STAR
select sum(cal) from (select elf_id, sum(calories) as cal from elf_calories group by elf_id order by 2 desc limit 3);
