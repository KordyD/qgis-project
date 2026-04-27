-- Считает площадь территорий школ, представленных полигонами.
-- Возвращает 10 крупнейших школьных территорий.

CREATE SCHEMA IF NOT EXISTS coursework;

DROP TABLE IF EXISTS coursework.top_school_areas;

CREATE TABLE coursework.top_school_areas AS
WITH school_polygons AS (
    SELECT
        osm_id,
        COALESCE(name, 'Unnamed school') AS school_name,
        amenity,
        ROUND(ST_Area(ST_Transform(way, 4326)::geography)::numeric)::bigint AS area_m2,
        way
    FROM coursework.rostov_polygon
    WHERE amenity IN ('school', 'college', 'university')
),
ranked AS (
    SELECT
        osm_id,
        school_name,
        amenity,
        area_m2,
        way,
        ROW_NUMBER() OVER (ORDER BY area_m2 DESC, osm_id) AS area_rank
    FROM school_polygons
)
SELECT
    ROW_NUMBER() OVER (ORDER BY area_rank, osm_id)::integer AS gid,
    osm_id,
    school_name,
    amenity,
    area_m2,
    area_rank,
    way::geometry(Geometry, 3857) AS geom
FROM ranked
WHERE area_rank <= 10;

CREATE UNIQUE INDEX top_school_areas_gid_idx
    ON coursework.top_school_areas (gid);

CREATE INDEX top_school_areas_geom_idx
    ON coursework.top_school_areas
    USING GIST (geom);

ANALYZE coursework.top_school_areas;
