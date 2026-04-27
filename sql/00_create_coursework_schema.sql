-- Создает рабочую схему для аналитических представлений

CREATE EXTENSION IF NOT EXISTS postgis;

CREATE SCHEMA IF NOT EXISTS coursework;

COMMENT ON SCHEMA coursework IS
'Схема с пространственными представлениями и аналитическими запросами для курсовой.';
