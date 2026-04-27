-- Ищет кандидатов на административную границу Ростова-на-Дону
-- в исходных таблицах osm2pgsql.

SELECT
    osm_id,
    name,
    boundary,
    admin_level,
    ST_GeometryType(way) AS geom_type,
    ROUND(ST_Area(ST_Transform(way, 4326)::geography)::numeric / 1000000, 2) AS area_km2
FROM public.planet_osm_polygon
WHERE boundary = 'administrative'
  AND (
      name ILIKE '%Ростов%'
      OR name ILIKE '%Rostov%'
      OR name ILIKE '%Дону%'
      OR name ILIKE '%Don%'
  )
ORDER BY
    CASE
        WHEN name = 'Ростов-на-Дону' THEN 0
        WHEN name = 'Rostov-on-Don' THEN 1
        ELSE 2
    END,
    admin_level,
    area_km2 DESC;
