-- Быстрый просмотр примеров строк из локальных таблиц Ростова-на-Дону.

SELECT
    'rostov_point' AS source_table,
    osm_id,
    name,
    amenity,
    highway,
    railway
FROM coursework.rostov_point
LIMIT 10;

SELECT
    'rostov_line' AS source_table,
    osm_id,
    name,
    highway,
    railway,
    waterway
FROM coursework.rostov_line
LIMIT 10;

SELECT
    'rostov_polygon' AS source_table,
    osm_id,
    name,
    building,
    landuse,
    leisure,
    amenity
FROM coursework.rostov_polygon
LIMIT 10;

SELECT
    'rostov_roads' AS source_table,
    osm_id,
    name,
    highway,
    railway
FROM coursework.rostov_roads
LIMIT 10;
