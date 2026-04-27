-- Находит кафе и аптеки, которые расположены не дальше 300 м от школ.
-- Каждому объекту сопоставляется ближайшая школа в этом радиусе.

CREATE SCHEMA IF NOT EXISTS coursework;

DROP TABLE IF EXISTS coursework.cafes_and_pharmacies_near_schools;

CREATE TABLE coursework.cafes_and_pharmacies_near_schools AS
WITH services AS (
    SELECT
        osm_id,
        COALESCE(name, 'Unnamed object') AS object_name,
        amenity,
        way::geometry(Point, 3857) AS geom_point
    FROM coursework.rostov_point
    WHERE amenity IN ('cafe', 'pharmacy')
    UNION ALL
    SELECT
        osm_id,
        COALESCE(name, 'Unnamed object') AS object_name,
        amenity,
        ST_PointOnSurface(way)::geometry(Point, 3857) AS geom_point
    FROM coursework.rostov_polygon
    WHERE amenity IN ('cafe', 'pharmacy')
),
matches AS (
    SELECT
        sv.osm_id AS service_osm_id,
        sv.object_name,
        sv.amenity AS service_type,
        s.osm_id AS school_osm_id,
        s.school_name,
        ROUND(
            ST_Distance(
                ST_Transform(sv.geom_point, 4326)::geography,
                ST_Transform(s.geom, 4326)::geography
            )::numeric
        )::integer AS distance_to_school_m,
        sv.geom_point AS geom
    FROM services AS sv
    JOIN coursework.schools AS s
        ON ST_DWithin(
            ST_Transform(sv.geom_point, 4326)::geography,
            ST_Transform(s.geom, 4326)::geography,
            300
        )
),
nearest_match AS (
    SELECT DISTINCT ON (service_osm_id)
        service_osm_id,
        object_name,
        service_type,
        school_osm_id,
        school_name,
        distance_to_school_m,
        geom
    FROM matches
    ORDER BY service_osm_id, distance_to_school_m, school_osm_id
)
SELECT
    ROW_NUMBER() OVER (ORDER BY service_type, distance_to_school_m, service_osm_id)::integer AS gid,
    service_osm_id,
    object_name,
    service_type,
    school_osm_id,
    school_name,
    distance_to_school_m,
    geom::geometry(Point, 3857) AS geom
FROM nearest_match;

CREATE UNIQUE INDEX cafes_and_pharmacies_near_schools_gid_idx
    ON coursework.cafes_and_pharmacies_near_schools (gid);

CREATE INDEX cafes_and_pharmacies_near_schools_geom_idx
    ON coursework.cafes_and_pharmacies_near_schools
    USING GIST (geom);

ANALYZE coursework.cafes_and_pharmacies_near_schools;
