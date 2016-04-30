CREATE TABLE item (
    id varchar PRIMARY KEY,
    len integer,
    len2 integer,
    ts timestamp default (now())
);
