-- Строит буферные зоны 500 м вокруг школ.

CREATE SCHEMA IF NOT EXISTS coursework;

DROP TABLE IF EXISTS coursework.school_buffers;

CREATE TABLE coursework.school_buffers AS
SELECT
    ROW_NUMBER() OVER (ORDER BY s.school_name, s.osm_id)::integer AS gid,
    s.osm_id AS school_osm_id,
    s.school_name,
    s.amenity,
    500::integer AS buffer_m,
    ST_Transform(
        ST_Buffer(ST_Transform(s.geom, 4326)::geography, 500)::geometry,
        3857
    )::geometry(Polygon, 3857) AS geom
FROM coursework.schools AS s;

CREATE UNIQUE INDEX school_buffers_gid_idx
    ON coursework.school_buffers (gid);

CREATE INDEX school_buffers_geom_idx
    ON coursework.school_buffers
    USING GIST (geom);

ANALYZE coursework.school_buffers;
