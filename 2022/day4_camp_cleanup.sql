-- https://adventofcode.com/2022/day/

DROP TABLE IF EXISTS assignments;

-- I wanted to have the ranges use GENERATED ALWAYS AS
-- but the funnction used below would not be IMMUTABLE
-- || instead of concat would be fine, but I did not
-- find a replacement... for replace().  

CREATE TABLE assignments (
    firstelf text,
    secondelf text,
    firstelf_section int4range,
    secondelf_section int4range
);

\copy assignments(firstelf, secondelf) from 'day4.input' delimiter ',';

-------------------------------------------------------
-- FIRST PART
-------------------------------------------------------

UPDATE
    assignments
SET
    firstelf_section = concat('[', replace(firstelf, '-', ','), ']')::int4range,
    secondelf_section = concat('[', replace(secondelf, '-', ','), ']')::int4range;

SELECT
    count(*)
FROM
    assignments
WHERE
    firstelf_section @> secondelf_section
    OR secondelf_section @> firstelf_section;

-------------------------------------------------------
-- SECOND PART
-------------------------------------------------------
SELECT
    count(*)
FROM
    assignments
WHERE
    firstelf_section && secondelf_section
    OR secondelf_section && firstelf_section;
