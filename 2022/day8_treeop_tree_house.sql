DROP TABLE IF EXISTS grid;

CREATE TABLE grid (
    id integer GENERATED ALWAYS AS IDENTITY,
    g text
);

\copy grid (g) from 'day8.input' 

-- test data
-- \copy grid (g) from 'day8_test.input'
-- looks like this:
-- 3 0 3 7 3
-- 2 5 5 1 2
-- 6 5 3 3 2
-- 3 3 5 4 9
-- 3 5 3 9 0

-------------------------------------------------------
-- FIRST PART
-------------------------------------------------------
-- lots of calculation, this is correct but slow

WITH c AS (
    SELECT
        id,
        string_to_table (g, NULL) AS height
    FROM grid
),
myg AS (
    SELECT
        row_number() OVER (PARTITION BY id) AS col,
        id AS row,
        height
    FROM c
),
visible_trees AS (
    SELECT
        col,
        ROW,
        height,
        -- visible from north
        (height > ( SELECT max(gr.height) FROM myg gr WHERE gr.col = gri.col AND gr.row < gri.row)
                OR gri.row = 1)
        OR
        -- visible from west
        (height > ( SELECT max(gr.height) FROM myg gr WHERE gr.row = gri.row AND gr.col < gri.col)
                OR gri.col = 1)
        OR
        -- visible from south
        (height > ( SELECT max(gr.height) FROM myg gr WHERE gr.col = gri.col AND gr.row > gri.row)
                OR gri.row = 99)
       OR
       -- visible from east
       (height > ( SELECT max(gr.height) FROM myg gr WHERE gr.row = gri.row AND gr.col > gri.col)
               OR gri.col = 99) AS visible
    FROM
        myg gri
    ORDER BY col, ROW, height
)
SELECT count(*)
FROM visible_trees
WHERE visible;

-------------------------------------------------------
-- SECOND PART
-------------------------------------------------------
-- lots of calculation, this is correct but slow

WITH c AS (
    SELECT id, string_to_table (g, NULL) AS height
    FROM grid
),
myg AS (
    SELECT row_number() OVER (PARTITION BY id) AS col, id AS row, height
    FROM c
),
distances AS (
    SELECT
        col,
        ROW,
        height,
        -- distance to a higher tree north
        (
            SELECT least (MIN(gri.row - gr.row), gri.row - 1)
            FROM myg gr
            WHERE gr.col = gri.col AND gr.row < gri.row AND gr.height >= gri.height) AS dist_north,
       -- distance to a higher tree west
       (
           SELECT least (MIN(gri.col - gr.col), gri.col - 1)
           FROM myg gr
           WHERE gr.row = gri.row AND gr.col < gri.col AND gr.height >= gri.height) AS dist_west,
       -- distance to a higher tree south
       (
           SELECT least (MIN(gr.row - gri.row), 99 - gri.row)
           FROM myg gr
           WHERE gr.col = gri.col AND gr.row > gri.row AND gr.height >= gri.height) AS dist_south,
       -- distance to a higher tree west
       (
           SELECT least (MIN(gr.col - gri.col), 99 - gri.col)
           FROM myg gr
           WHERE gr.row = gri.row AND gr.col > gri.col AND gr.height >= gri.height) AS dist_east
    FROM myg gri
    WHERE col > 1 AND col < 99 AND ROW > 1 AND ROW < 99
    ORDER BY col, ROW
)
SELECT max(dist_north * dist_west * dist_south * dist_east)
FROM distances;

