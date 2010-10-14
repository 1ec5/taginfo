--
--  Taginfo source: Wiki
--
--  pre.sql
--

.bail ON

DROP TABLE IF EXISTS meta;

CREATE TABLE meta (
    source_id    TEXT,
    source_name  TEXT,
    update_start TEXT,
    update_end   TEXT,
    data_until   TEXT
);

INSERT INTO meta (source_id, source_name, update_start, data_until) SELECT 'wiki', 'Wiki', datetime('now'), datetime('now');

DROP TABLE IF EXISTS stats;

CREATE TABLE stats (
    key   TEXT,
    value INT64
);

DROP TABLE IF EXISTS wikipages;

CREATE TABLE wikipages (
    lang             TEXT,
    tag              TEXT,
    key              TEXT,
    value            TEXT,
    title            TEXT,
    body             TEXT,
    tgroup           TEXT,
    type             TEXT,
    has_templ        INTEGER,
    parsed           INTEGER,
    description      TEXT,
    image            TEXT,
    on_node          INTEGER,
    on_way           INTEGER,
    on_area          INTEGER,
    on_relation      INTEGER,
    tags_implies     TEXT,
    tags_combination TEXT,
    tags_linked      TEXT,
    status           TEXT
);

DROP TABLE IF EXISTS wikipages_keys;

CREATE TABLE wikipages_keys (
    key   TEXT,
    langs TEXT
);

DROP TABLE IF EXISTS wikipages_tags;

CREATE TABLE wikipages_tags (
    key   TEXT,
    value TEXT,
    langs TEXT
);

DROP TABLE IF EXISTS wiki_languages;

CREATE TABLE wiki_languages (
    language    TEXT,
    count_pages INTEGER
);

DROP TABLE IF EXISTS stats;

CREATE TABLE stats (
    key   TEXT,
    value INT64
);

