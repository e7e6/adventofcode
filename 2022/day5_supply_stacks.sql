-- https://adventofcode.com/2022/day/5
DROP TABLE IF EXISTS mouvements;
DROP TABLE IF EXISTS crates_staging;
DROP TABLE IF EXISTS crates;
DROP FUNCTION IF EXISTS operate (integer, integer, integer);

CREATE TABLE mouvements (
    id int GENERATED ALWAYS AS IDENTITY,
    n int,
    source int,
    destination int
);

CREATE TABLE crates_staging (
    id int GENERATED ALWAYS AS IDENTITY,
    stack text
);

-- This will not win me any beauty price
-- But it's short and easy
\copy mouvements(n, source, destination) from program 'sed -n "/move/p" day5.input | sed "s/move //g;s/from //g ; s/to //g"' with delimiter ' '
\copy crates_staging(stack) from program 'sed -n "/\[/p" day5.input | cut -c 2,6,10,14,18,22,26,30,34,38'

-- rotate the data for easier manipulation...incorrectly  (should be corrected later)
-- we reverse the stack so the bottom is on the left
CREATE TABLE crates AS
SELECT
    c.id,
    reverse(ltrim(rotated, ' ')) AS stack
FROM
    crates_staging c,
    LATERAL (
        SELECT string_agg(substr(d.stack, c.id, 1), '') AS rotated
        FROM crates_staging d) e
ORDER BY id;

-- very cheapo correction
INSERT INTO crates (id, stack) VALUES (9, 'LSG');

-- we define a little function that will move the crates
-- from stack to stack
CREATE OR REPLACE FUNCTION public.operate (n_crates integer, source integer, destination integer)
    RETURNS void
    LANGUAGE plpgsql
    AS $function$
DECLARE
    crates_to_move text;
BEGIN
    SELECT RIGHT (stack, n_crates) INTO crates_to_move
    FROM crates
    WHERE id = source;

    UPDATE crates
    SET stack = LEFT (stack, length(stack) - n_crates)
    WHERE id = source;

    UPDATE crates
    SET stack = stack || reverse(crates_to_move)
        -- set stack = stack || crates_to_move

    WHERE id = destination;
    RAISE NOTICE 'Moving % from % to %.', crates_to_move, source, destination;
END;
$function$;

DO $$
    << myblock >>
DECLARE
    current_op integer := 1;
    rec record;
    curs CURSOR FOR
        SELECT
            n,
            source,
            destination
        FROM
            mouvements
        ORDER BY
            id;
BEGIN
    OPEN curs;
    LOOP
        FETCH curs INTO rec;
        exit
        WHEN NOT found;
        PERFORM
            operate (rec.n, rec.source, rec.destination);
        --select id, stack from crates order by id;
    END LOOP;
    CLOSE curs;
END myblock
$$;

-------------------------------------------------------
-- FIRST PART
-------------------------------------------------------
SELECT
    string_agg(
    RIGHT (stack, 1), '')
FROM (
    SELECT *
    FROM crates
    ORDER BY id) c;

-------------------------------------------------------
-- SECOND PART
-------------------------------------------------------
-- same stuff with the function change
-- set stack = stack || crates_to_move
