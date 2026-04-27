-- Находит жилые дома, попадающие в радиус 500 м от школ.
-- Каждому дому сопоставляется ближайшая школа в пределах этого радиуса.

CREATE SCHEMA IF NOT EXISTS coursework;

DROP TABLE IF EXISTS coursework.buildings_within_school_buffers;

CREATE TABLE coursework.buildings_within_school_buffers AS
WITH buildings AS (
    SELECT
        osm_id,
        COALESCE(name, 'Unnamed residential building') AS building_name,
        building AS building_type,
        way
    FROM coursework.rostov_polygon
    WHERE building IN (
        'apartments',
        'detached',
        'dormitory',
        'house',
        'residential',
        'semidetached_house',
        'terrace'
    )
),
matches AS (
    SELECT
        b.osm_id AS building_osm_id,
        b.building_name,
        b.building_type,
        s.school_osm_id,
        s.school_name,
        ROUND(
            ST_Distance(
                ST_Transform(ST_PointOnSurface(b.way), 4326)::geography,
                ST_Transform(sc.geom, 4326)::geography
            )::numeric
        )::integer AS distance_to_school_m,
        b.way AS geom
    FROM buildings AS b
    JOIN coursework.school_buffers AS s
        ON ST_Intersects(b.way, s.geom)
    JOIN coursework.schools AS sc
        ON sc.osm_id = s.school_osm_id
),
nearest_match AS (
    SELECT DISTINCT ON (building_osm_id)
        building_osm_id,
        building_name,
        building_type,
        school_osm_id,
        school_name,
        distance_to_school_m,
        geom
    FROM matches
    ORDER BY building_osm_id, distance_to_school_m, school_osm_id
)
SELECT
    ROW_NUMBER() OVER (ORDER BY distance_to_school_m, building_osm_id)::integer AS gid,
    building_osm_id,
    building_name,
    building_type,
    school_osm_id,
    school_name,
    distance_to_school_m,
    geom::geometry(Geometry, 3857) AS geom
FROM nearest_match;

CREATE UNIQUE INDEX buildings_within_school_buffers_gid_idx
    ON coursework.buildings_within_school_buffers (gid);

CREATE INDEX buildings_within_school_buffers_geom_idx
    ON coursework.buildings_within_school_buffers
    USING GIST (geom);

ANALYZE coursework.buildings_within_school_buffers;
