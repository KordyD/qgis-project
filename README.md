# QGIS School Accessibility Project

Проект по пространственному анализу в `PostGIS + QGIS` на данных
`OpenStreetMap`, ограниченных Ростовом-на-Дону.

В проекте:
- SQL-скрипты для подготовки данных после `osm2pgsql`
- вырезка города в локальные таблицы `coursework.rostov_*`
- набор аналитических таблиц по школам
- готовый QGIS-проект `schools_project.qgz`

## Демо

![Demo map](images/demo.png)

На демо показаны школьные буферы, жилые дома в зоне доступности, ближайшие
остановки, а также объекты сервиса рядом со школами.

## Стэк

- `PostgreSQL`
- `PostGIS`
- `osm2pgsql`
- `QGIS`
- данные `OSM / Geofabrik`

## Структура

- [sql](sql) — все SQL-скрипты
- [images](images) — демонстрационные скриншоты
- [report](report) — отчет по проекту
- [schools_project.qgz](schools_project.qgz) — QGIS-проект
- [docker-compose.yaml](docker-compose.yaml) — локальный compose для окружения

## SQL пайплайн

Порядок запуска скриптов:

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

## Что делают скрипты

- `00` — создает схему `coursework`
- `01` — проверяет, что `osm2pgsql` загрузил таблицы в `public`
- `02` — ищет кандидатов на границу Ростова-на-Дону
- `03` — создает таблицу `coursework.rostov_boundary`
- `04` — вырезает город в локальные таблицы `coursework.rostov_*`
- `05` — показывает примеры строк из локальных таблиц
- `06` — собирает все школы в таблицу `coursework.schools`
- `07` — строит буферы 500 м вокруг школ
- `08` — находит жилые дома в радиусе 500 м от школ
- `09` — строит линии от школы до ближайшей остановки
- `10` — считает топ-10 школьных территорий по площади
- `11` — ищет кафе и аптеки в радиусе 300 м от школ

## Результаты

- `coursework.schools`
- `coursework.school_buffers`
- `coursework.buildings_within_school_buffers`
- `coursework.nearest_stop_to_schools`
- `coursework.top_school_areas`
- `coursework.cafes_and_pharmacies_near_schools`
