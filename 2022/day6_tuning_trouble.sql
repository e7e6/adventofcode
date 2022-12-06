DROP TABLE IF EXISTS signal;

CREATE TABLE signal ( s text);

\copy signal from 'day6.input'
-- test data
-- insert into signal values ('bvwbjplbgvbhsrlpgdmjqwftvncz'); -- expect 5
-- insert into signal values ('nppdvjthqldpwncqszvftbrmjlhg'); -- expect 6
-- insert into signal values ('nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg'); -- expect 10
-- insert into signal values ('zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw'); -- expect 11

-------------------------------------------------------
-- FIRST PART
-------------------------------------------------------

SELECT i - 1
FROM
    generate_series(5, ( SELECT length(s) FROM signal)) i
    JOIN string_to_table (( SELECT s FROM signal), NULL)
    WITH ORDINALITY t(v, o) ON o < i
        AND o >= i - 4
GROUP BY i
HAVING count(DISTINCT v) = 4
ORDER BY i
LIMIT 1;

-------------------------------------------------------
-- SECOND PART
-------------------------------------------------------

SELECT i - 1
FROM
    generate_series(15, ( SELECT length(s) FROM signal)) i
    JOIN string_to_table (( SELECT s FROM signal), NULL)
    WITH ORDINALITY t(v, o) ON o < i
        AND o >= i - 14
GROUP BY i
HAVING count(DISTINCT v) = 14
ORDER BY i
LIMIT 1;

