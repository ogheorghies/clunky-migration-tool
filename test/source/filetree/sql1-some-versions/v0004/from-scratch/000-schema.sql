CREATE TABLE item (
    id varchar PRIMARY KEY,
    len integer,
    len2 integer,
    ts timestamp default (now())
);

CREATE TABLE item2 (
    id varchar PRIMARY KEY,
    len integer
);
