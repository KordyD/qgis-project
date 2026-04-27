-- Для каждой школы находит ближайшую остановку и строит линию до нее.

CREATE SCHEMA IF NOT EXISTS coursework;

DROP TABLE IF EXISTS coursework.nearest_stop_to_schools;

CREATE TABLE coursework.nearest_stop_to_schools AS
WITH stops AS (
    SELECT
        osm_id,
        COALESCE(name, 'Unnamed stop') AS stop_name,
        COALESCE(highway, public_transport, railway) AS stop_type,
        way::geometry(Point, 3857) AS geom_point
    FROM coursework.rostov_point
    WHERE highway = 'bus_stop'
       OR public_transport IN ('platform', 'stop_position', 'station')
       OR railway IN ('tram_stop', 'station', 'halt')
),
nearest AS (
    SELECT
        s.osm_id AS school_osm_id,
        s.school_name,
        st.osm_id AS stop_osm_id,
        st.stop_name,
        st.stop_type,
        ROUND(
            ST_Distance(
                ST_Transform(s.geom, 4326)::geography,
                ST_Transform(st.geom_point, 4326)::geography
            )::numeric
        )::integer AS distance_m,
        ST_MakeLine(s.geom, st.geom_point) AS geom
    FROM coursework.schools AS s
    LEFT JOIN LATERAL (
        SELECT
            osm_id,
            stop_name,
            stop_type,
            geom_point
        FROM stops
        ORDER BY s.geom <-> geom_point
        LIMIT 1
    ) AS st ON TRUE
)
SELECT
    ROW_NUMBER() OVER (ORDER BY school_name, school_osm_id)::integer AS gid,
    school_osm_id,
    school_name,
    stop_osm_id,
    stop_name,
    stop_type,
    distance_m,
    geom::geometry(LineString, 3857) AS geom
FROM nearest;

CREATE UNIQUE INDEX nearest_stop_to_schools_gid_idx
    ON coursework.nearest_stop_to_schools (gid);

CREATE INDEX nearest_stop_to_schools_geom_idx
    ON coursework.nearest_stop_to_schools
    USING GIST (geom);

ANALYZE coursework.nearest_stop_to_schools;
