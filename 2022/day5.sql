

drop table if exists mouvements;
drop table if exists crates_staging;
drop table if exists crates;
drop function if exists operate(integer, integer, integer) ;

create table mouvements(id int generated always as identity, n int, source int, destination int);
create table crates_staging (id int generated always as identity, stack text);

-- This will not win me any beauty price
-- But it's short and easy
\copy mouvements(n, source, destination) from program 'sed -n "/move/p" day5.input | sed "s/move //g;s/from //g ; s/to //g"' with delimiter ' '
\copy crates_staging(stack) from program 'sed -n "/\[/p" day5.input | cut -c 2,6,10,14,18,22,26,30,34,38' 

-- rotate the data for easier manipulation... on the cheap.
-- we reverse the stack so the bottom is on the left
create table crates as select c.id,reverse(ltrim(rotated, ' ')) as stack from crates_staging c, lateral (select string_agg(substr(d.stack,c.id,1),'') as rotated from crates_staging d) e order by id ;


-- we define a little function that will move the crates 
-- from stack to stack
CREATE OR REPLACE FUNCTION public.operate(n_crates integer, source integer, destination integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
        crates_to_move text;
BEGIN
	select right(stack,n_crates)
        into crates_to_move
        from crates
	where id = source;

        update crates 
        set stack = left(stack, length(stack) - n_crates)
        where id = source;

        update crates
        set stack = stack || reverse(crates_to_move)
        where id = destination;

	RAISE NOTICE 'Moving % from % to %.', crates_to_move, source, destination;
	--RETURN 'Moving ' || crates_to_move || ' from ' || source || ' to ' || destination;

END;
$function$
;


-- select operate(1,2,1);
-- select operate(3,1,3);
-- select operate(2,2,1);
-- select operate(1,1,2);

table crates order by id ;
select operate(7,3,9);
table crates order by id ;
select operate(6,2,1);
table crates order by id ;
select operate(2,4,8);
table crates order by id ;
select operate(10,8,4);
table crates order by id ;
select operate(1,2,4);
table crates order by id ;



/*


do $$

<<myblock>>
declare
current_op integer := 1;
rec record;
curs cursor
for select n, source, destination
    from mouvements order by id;
begin
        open curs;
        loop
                fetch curs into rec;
                exit when not found;
                perform operate(rec.n, rec.source, rec.destination);
		--select id, stack from crates order by id;
        end loop;
        close curs;
end myblock $$;
table crates order by id ;
*/



select string_agg(right(stack,1), '') from (select * from crates order by id) c;
