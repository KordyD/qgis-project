-- Показывает, какие таблицы и геометрические колонки после osm2pgsql
-- доступны в схеме public

SELECT
    t.table_schema,
    t.table_name,
    c.column_name AS geometry_column,
    gc.type AS geometry_type,
    gc.srid,
    COALESCE(s.n_live_tup, 0) AS estimated_rows
FROM information_schema.tables AS t
LEFT JOIN public.geometry_columns AS gc
    ON gc.f_table_schema = t.table_schema
   AND gc.f_table_name = t.table_name
LEFT JOIN information_schema.columns AS c
    ON c.table_schema = t.table_schema
   AND c.table_name = t.table_name
   AND c.column_name = gc.f_geometry_column
LEFT JOIN pg_stat_user_tables AS s
    ON s.schemaname = t.table_schema
   AND s.relname = t.table_name
WHERE t.table_schema = 'public'
  AND t.table_type = 'BASE TABLE'
ORDER BY t.table_name, c.column_name;

-- Быстрый просмотр состава стандартных osm2pgsql-таблиц.
SELECT
    t.table_name,
    COALESCE(s.n_live_tup, 0) AS estimated_rows
FROM (
    VALUES
        ('planet_osm_point'),
        ('planet_osm_line'),
        ('planet_osm_polygon'),
        ('planet_osm_roads')
) AS t(table_name)
LEFT JOIN pg_stat_user_tables AS s
    ON s.schemaname = 'public'
   AND s.relname = t.table_name
ORDER BY t.table_name;
