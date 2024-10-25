-- EXAMPLE 4.2
SELECT count(*) FROM test WHERE almost_unique > 66 AND almost_unique < 10719;
SELECT count(*) FROM test WHERE almost_unique > 10719 AND almost_unique < 21471;
SELECT count(*) FROM test WHERE almost_unique > 21471 AND almost_unique < 31904;
