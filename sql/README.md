# SQL scripts for PostGIS

Набор рассчитан на работу только по Ростову-на-Дону после загрузки
`osm2pgsql` в `public` с таблицами `planet_osm_point`, `planet_osm_line`,
`planet_osm_polygon`, `planet_osm_roads`.

Порядок запуска:

1. `00_create_coursework_schema.sql`
2. `01_check_public_osm_tables.sql`
3. `02_find_rostov_boundary_candidates.sql`
4. `03_create_rostov_boundary.sql`
5. `04_create_rostov_osm_subsets.sql`
6. `05_preview_rostov_osm_rows.sql`
7. `06_find_schools.sql`
8. `07_school_buffers.sql`
9. `08_buildings_within_school_buffers.sql`
10. `09_nearest_stop_to_schools.sql`
11. `10_top_school_areas.sql`
12. `11_cafes_and_pharmacies_near_schools.sql`

Что делает каждый файл:

- `00_create_coursework_schema.sql`  
  Создает схему `coursework`.

- `01_check_public_osm_tables.sql`  
  Проверяет, что таблицы `osm2pgsql` реально загружены в `public`.

- `02_find_rostov_boundary_candidates.sql`  
  Показывает кандидатов на административную границу Ростова-на-Дону.

- `03_create_rostov_boundary.sql`  
  Создает таблицу `coursework.rostov_boundary`.

- `04_create_rostov_osm_subsets.sql`  
  Вырезает из `public` только объекты Ростова в таблицы `coursework.rostov_*`.

- `05_preview_rostov_osm_rows.sql`  
  Показывает примеры строк из локальных таблиц Ростова.

- `06_find_schools.sql`  
  Ищет все школы по OSM-тегам и сохраняет их в таблицу `coursework.schools`.

- `07_school_buffers.sql`  
  Строит буферы 500 м вокруг школ.

- `08_buildings_within_school_buffers.sql`  
  Находит здания, попадающие в радиус 500 м от школ.

- `09_nearest_stop_to_schools.sql`  
  Для каждой школы находит ближайшую остановку и строит линию до нее.

- `10_top_school_areas.sql`  
  Считает площадь школьных территорий и возвращает 10 крупнейших объектов.

- `11_cafes_and_pharmacies_near_schools.sql`  
  Находит кафе и аптеки, расположенные в пределах 300 м от школ.
