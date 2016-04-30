CREATE TABLE item (
    id varchar PRIMARY KEY,
    len integer,
    ts timestamp default (now())
);
