-- Создает таблицу с административной границей Ростова-на-Дону.

CREATE SCHEMA IF NOT EXISTS coursework;

DROP TABLE IF EXISTS coursework.rostov_boundary;

CREATE TABLE coursework.rostov_boundary AS
WITH candidates AS (
    SELECT
        osm_id,
        name,
        boundary,
        admin_level,
        ST_Multi(ST_CollectionExtract(way, 3))::geometry(MultiPolygon, 3857) AS geom
    FROM public.planet_osm_polygon
    WHERE boundary = 'administrative'
      AND admin_level IN ('6', '7', '8', '9')
      AND name IN ('городской округ Ростов-на-Дону', 'Rostov-on-Don')
),
selected AS (
    SELECT
        osm_id,
        name,
        boundary,
        admin_level,
        geom
    FROM candidates
    ORDER BY
        CASE
            WHEN name = 'городской округ Ростов-на-Дону' AND admin_level = '8' THEN 0
            WHEN name = 'Rostov-on-Don' AND admin_level = '8' THEN 1
            WHEN name = 'городской округ Ростов-на-Дону' THEN 2
            WHEN name = 'Rostov-on-Don' THEN 3
            ELSE 4
        END,
        ST_Area(ST_Transform(geom, 4326)::geography) DESC
    LIMIT 1
)
SELECT
    osm_id,
    name,
    boundary,
    admin_level,
    geom
FROM selected;

CREATE INDEX IF NOT EXISTS rostov_boundary_geom_idx
    ON coursework.rostov_boundary
    USING GIST (geom);

SELECT COUNT(*) AS boundary_rows
FROM coursework.rostov_boundary;
