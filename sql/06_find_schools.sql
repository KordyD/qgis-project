-- Находит все школы по OSM-тегам в пределах Ростова-на-Дону.

CREATE SCHEMA IF NOT EXISTS coursework;

DROP TABLE IF EXISTS coursework.schools;

CREATE TABLE coursework.schools AS
WITH point_schools AS (
    SELECT
        osm_id,
        COALESCE(name, 'Unnamed school') AS school_name,
        amenity,
        'point'::text AS source_type,
        way::geometry(Point, 3857) AS geom
    FROM coursework.rostov_point
    WHERE amenity IN ('school', 'college', 'university')
),
polygon_schools AS (
    SELECT
        osm_id,
        COALESCE(name, 'Unnamed school') AS school_name,
        amenity,
        'polygon'::text AS source_type,
        ST_PointOnSurface(way)::geometry(Point, 3857) AS geom
    FROM coursework.rostov_polygon
    WHERE amenity IN ('school', 'college', 'university')
),
all_schools AS (
    SELECT * FROM point_schools
    UNION ALL
    SELECT * FROM polygon_schools
)
SELECT
    ROW_NUMBER() OVER (ORDER BY school_name, osm_id)::integer AS gid,
    osm_id,
    school_name,
    amenity,
    source_type,
    geom
FROM all_schools;

CREATE UNIQUE INDEX schools_gid_idx
    ON coursework.schools (gid);

CREATE INDEX schools_geom_idx
    ON coursework.schools
    USING GIST (geom);

ANALYZE coursework.schools;
