DROP TABLE IF EXISTS
    cattoys,
    cats,
    toys;

CREATE TABLE cats (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    color VARCHAR(255),
    breed VARCHAR(255)
);

CREATE TABLE toys (
    id SERIAL PRIMARY KEY,
    price DECIMAL,
    color VARCHAR(255),
    name VARCHAR(255)
);

CREATE TABLE cattoys (
    id SERIAL PRIMARY KEY,
    cat_id INT REFERENCES cats(id),
    toy_id INT REFERENCES toys(id)
);

INSERT INTO
  cats (name, color, breed)
VALUES
  ('Niles Mowgli Kitty Prancer Schreiber', 'orange', 'Tabby'),
  ('Smokey', 'white', 'Himalayan'),
  ('Athena', 'black', 'Bombay'),
  ('Lola', 'gray', 'Exotic shorthair'),
  ('Ripley', 'whitesmoke', 'Bengal');

INSERT INTO
  toys (price, color, name)
VALUES
  (49.00, 'rainbow', 'spinner'),
  (9.99, 'gray', 'fake mouse'),
  (0.50, 'white', 'paper'),
  (97.00, 'gold', '24 karat mouse'),
  (19.99, 'orange', 'premium string');

INSERT INTO
  cattoys (cat_id, toy_id)
VALUES
  (1, 3),
  (1, 1),
  (3, 2),
  (4, 2),
  (5, 4);