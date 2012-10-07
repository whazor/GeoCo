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
	point GEOMETRY(Point,4326),
	nearest_way_id BIGINT
);

CREATE TABLE hints (
	publiced_at TIMESTAMP
) INHERITS (coordinates);

CREATE TABLE hunts (
	found_at TIMESTAMP
) INHERITS (coordinates);

# --- !Downs
DROP TABLE users;
DROP TABLE hints;
DROP TABLE hunts;
DROP TABLE coordinates;