# First database

# --- !Ups
CREATE TABLE users
(
	user_id SERIAL PRIMARY KEY,
	name TEXT NOT NULL
);

CREATE TABLE coordinates
(
	coordinate_id SERIAL NOT NULL PRIMARY KEY,
	fox_group TEXT NOT NULL,   
	created_at TIMESTAMP NOT NULL,
	user_id INTEGER REFERENCES users ON DELETE SET NULL,
	raw TEXT NOT NULL,
	point GEOMETRY(Point,4326)
);

CREATE TABLE hints (
	hint_hour INT NOT NULL
) INHERITS (coordinates);

CREATE TABLE hunts (
	found_at TIMESTAMP
) INHERITS (coordinates);

# --- !Downs
DROP TABLE hints CASCADE;
DROP TABLE hunts CASCADE;
DROP TABLE coordinates CASCADE;
DROP TABLE users CASCADE;