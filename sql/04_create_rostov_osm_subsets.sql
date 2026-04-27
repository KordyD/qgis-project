-- Вырезает объекты Ростова-на-Дону из стандартных таблиц osm2pgsql
-- в локальные таблицы coursework.rostov_*.

CREATE SCHEMA IF NOT EXISTS coursework;

DROP TABLE IF EXISTS coursework.rostov_point;
CREATE TABLE coursework.rostov_point AS
SELECT p.*
FROM public.planet_osm_point AS p
JOIN coursework.rostov_boundary AS b
    ON ST_Intersects(p.way, b.geom);

DROP TABLE IF EXISTS coursework.rostov_line;
CREATE TABLE coursework.rostov_line AS
SELECT l.*
FROM public.planet_osm_line AS l
JOIN coursework.rostov_boundary AS b
    ON ST_Intersects(l.way, b.geom);

DROP TABLE IF EXISTS coursework.rostov_polygon;
CREATE TABLE coursework.rostov_polygon AS
SELECT p.*
FROM public.planet_osm_polygon AS p
JOIN coursework.rostov_boundary AS b
    ON ST_Intersects(p.way, b.geom);

DROP TABLE IF EXISTS coursework.rostov_roads;
CREATE TABLE coursework.rostov_roads AS
SELECT r.*
FROM public.planet_osm_roads AS r
JOIN coursework.rostov_boundary AS b
    ON ST_Intersects(r.way, b.geom);

CREATE INDEX IF NOT EXISTS rostov_point_way_idx
    ON coursework.rostov_point
    USING GIST (way);

CREATE INDEX IF NOT EXISTS rostov_line_way_idx
    ON coursework.rostov_line
    USING GIST (way);

CREATE INDEX IF NOT EXISTS rostov_polygon_way_idx
    ON coursework.rostov_polygon
    USING GIST (way);

CREATE INDEX IF NOT EXISTS rostov_roads_way_idx
    ON coursework.rostov_roads
    USING GIST (way);

ANALYZE coursework.rostov_point;
ANALYZE coursework.rostov_line;
ANALYZE coursework.rostov_polygon;
ANALYZE coursework.rostov_roads;

SELECT 'rostov_point' AS table_name, COUNT(*) AS rows_count
FROM coursework.rostov_point
UNION ALL
SELECT 'rostov_line' AS table_name, COUNT(*) AS rows_count
FROM coursework.rostov_line
UNION ALL
SELECT 'rostov_polygon' AS table_name, COUNT(*) AS rows_count
FROM coursework.rostov_polygon
UNION ALL
SELECT 'rostov_roads' AS table_name, COUNT(*) AS rows_count
FROM coursework.rostov_roads
ORDER BY table_name;
