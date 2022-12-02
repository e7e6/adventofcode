create table rps(opponent char, you char);
\copy rps (opponent, you) from 'day2_input' with delimiter ' ';

----------------------------------------------------------------------------
-- part one
-- we do this the dirty way and specify (almost) every combination

select sum(case when you='X' then 1 when you='Y' then 2 when you = 'Z' then 3 end + case concat(opponent, you) when 'AX' then 3 when 'BY' then 3 when 'CZ' then 3 when 'AY' then 6 when  'BZ' then 6 when 'CX' then 6 else 0 end) from rps;

----------------------------------------------------------------------------
-- part two

-- we have
--     ascii(A) - 65 = 0
--     ascii(B) - 65 = 1
--     ascii(C) - 65 = 2
--     ascii(X) - 88 = 0
--     ascii(Y) - 88 = 1
--     ascii(Z) - 88 = 2
-- therefore the score for the game result is easy: ascii(n) * 3

-- for choosing the proper element, we would have the following table:

-- |-------|-----------------|------------|----------------|-------------|
-- | input | ascii(opponent) | ascii(you) | expected score | a(y) - a(o) |
-- |-------|-----------------|------------|----------------|-------------|
-- |    AX |              0  |          0 |              1 |         0   |
-- |    AY |              0  |          1 |              2 |         1   |
-- |    AZ |              0  |          2 |              0 |         2   |
-- |    BX |              1  |          0 |              0 |        -1   |
-- |    BY |              1  |          1 |              1 |         0   |
-- |    BZ |              1  |          2 |              2 |         1   |
-- |    CX |              2  |          0 |              2 |        -2   |
-- |    CY |              2  |          1 |              0 |        -1   |
-- |    CZ |              2  |          2 |              1 |         0   |
-- |-------|-----------------|------------|----------------|-------------|

-- i thought the expected score looked like f(a(y) - a(o)) with some modulus in play
-- and found the following formula that seemed to work well

select sum((ascii(you) -88) * 3 + ((ascii(opponent) -65 + ascii(you) -88) + 2) % 3 +1) from rps;
