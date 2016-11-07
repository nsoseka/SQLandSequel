CREATE DATABASE animals;

CREATE TABLE birds (
  id serial PRIMARY KEY,
  name VARCHAR(25)
  age SMALLINT,
  species VARCHAR(15)
);
-- USING SEQUEL

DB = Sequel.connect(adapter: :postgres, database: 'animals')

DB.create_table :birds do
  primary_key :id
  String :name, size: 25
  Integer :age
  String :species, size: 15
end

INSERT INTO birds(name, age, species)
VALUES ('Charlie', 3, 'Finch'),('Allie', 5,'Owl'), ('Jennifer', 3, 'Magpie'),
('Jamie', 4, 'Owl'), ('Roy', 8, 'Crow');
 
 --sequel
DB[:birds].insert(name: 'Charlie', age: 3, species: 'Finch')
DB[:birds].insert(name: 'Allie', age: 5, species: 'Owl')
DB[:birds].insert(name: 'Jennifer', age: 3, species: 'Magpie')
DB[:birds].insert(name: 'Jamie', age: 4, species: 'Owl')
DB[:birds].insert(name: 'Roy', age: 8, species: 'Crow')


SELECT * FROM birds;

--sequel
DB[:birds]

SELECT * FROM birds WHERE age < 5;

--sequel
DB[:birds].where{age < 5}

UPDATE birds
SET species = 'Raven'
WHERE species = 'Crow';

--sequel
DB[:birds].where(species: 'Crow').update(species: "Raven")

UPDATE birds
SET species = 'Hawk'
WHERE name = 'Jamie';

--sequel
DB[:birds].where(name: 'Jamie').update(species: "Hawk")


DELETE FROM birds WHERE species = 'Finch' AND age = 3;

--sequel
DB[:birds].where(species: 'Finch', age: 3).delete 

ALTER TABLE birds ADD CONSTRAINT check_if_age_is_valid CHECK (age >= 0);

--sequel
DB.alter_table :birds do
  add_constraint(:age_check_if_age_is_valid){age >= 0}
end

DROP TABLE birds;

--sequel
DB.drop_table(:birds)

DROP DATABASE animals;

--sequel


DDL

CREATE TYPE spectraltype AS ENUM('O', 'B', 'A', 'F', 'G', 'K', 'M');
CREATE TABLE stars (
  id serial PRIMARY KEY,
  name VARCHAR(25) NOT NULL UNIQUE,
  distance INT NOT NULL CHECK(distance > 0),
  spectral_type spectraltype NOT NULL,
  companions INT NOT NULL CHECK(companions > 0)
);

--sequel
--create the enum first

DB.extension :pg_enum
DB.create_enum(:spectratype, %w'O B  A F G K M')

DB.create_table :stars do
  primary_key :id
  String :name, size: 25
  Integer :distance, null: false
  spectratype :spectral_type
  Integer :companions, null: false
  constraint(:distance_valid_distance){distance > 0}
  constraint(:companions_valid_number_of_companions)(companions > 0)
end


CREATE TABLE planets (
  id serial PRIMARY KEY,
  designation CHAR(1) UNIQUE CHECK(designation ~ '^[A-Za-z]{1}$'),
  Integer :mass, null: false
  mass INT NOT NULL
);

--sequel
DB.extension :pg_enum
alphabetic = %w'a b c d e f g h i j k l m n o p q r s t u v w x y z'
DB.create_enum(:desing, alphabetic)
DB.create_table :planets do
  primary_key :id
  design :designation, unique: true
  Integer :mass, null: false
end

ALTER TABLE planets ADD COLUMN star_id INT NOT NULL REFERENCES stars(id);

--sequel
DB.alter_table :planets do
  add_column :star_id, references: :stars, null: false
end

-- altering the type of a column
ALTER TABLE stars ALTER COLUMN name TYPE VARCHAR(50);

--sequel
DB.alter_table :stars do
  set_column_type :name, String, size: 50
end

ALTER TABLE stars ALTER COLUMN distance TYPE numeric;

--sequel
DB.alter_table :stars do
  set_column_type :distance, BigDecimal
end

-- adding an enum type later on to a table

ALTER TABLE stars 
ALTER COLUMN spectral_type TYPE spectratype
                           USING spectral_type::spectratype;

--sequel
DB.alter_table :stars do
  set_column_type :spectral_type, :spectratype, using: 'spectral_type::spectratype'
end

--making the mass table required
ALTER TABLE planets
ALTER COLUMN mass SET NOT NULL,
ALTER COLUMN mass TYPE numeric,
ADD CHECK (mass > 0.0),
ALTER COLUMN designation SET NOT NULL;

--sequel
-- make sure every other change comes before the constraints.
DB.alter_table :planets do
  set_column_not_null :mass
  set_column_type :mass, BigDecimal
  set_column_not_null :designation
  add_constraint(:mass_valid_value_for_mass){mass > 0.0} 
end

--adding a semi major axis column

ALTER TABLE planets
ADD COLUMN semi_major_axis numeric NOT NULL;

DB.alter_table :planets do
  add_column :semi_major_axis, BigDecimal, null: false
end

--adding a moons column
CREATE TABLE moons (
  id serial PRIMARY KEY,
  designation INT NOT NULL CHECK(designation > 0),
  semi_major_axis INT CHECK(semi_major_axis > 0),
  mass numeric CHECK(mass > 0),
  planet_id INT NOT NULL REFERENCES planets(id)
);

--sequel
DB.create_table :moons do
  primary_key :id
  Integer :designation, null: false, unique: true
  Integer :semi_major_axis
  BigDecimal :mass
  foreign_key :planet_id, :planets, null: false
  constraint(:designation_desigantion_value_check){designation > 0}
  constraint(:semi_major_axis_axis_value_check){semi_major_axis > 0}
  constraint(:mass_valid_mass){mass > 0}
end

DML

One table should be called devices. This table should have columns that meet the following specifications:

    Includes a primary key called id that is auto-incrementing.
    A column called name, that can contain a String. It cannot be NULL.
    A column called created_at that lists the date this device was created. It should be of type timestamp and it should also have a default value related to when a device is created.


CREATE TABLE devices (
  id serial PRIMARY KEY,
  name text NOT NULL,
  created_at timestamp NOT NULL DEFAULT NOW()
);


--Sequel
DB.create_table? :devices do
  primary_key :id
  String :name, null: false
  DateTime :created_at, null: false, default: Sequel::SQL::Function.new(:now)
end

CREATE TABLE parts (
  id serial PRIMARY KEY,
  part_number INT NOT NULL UNIQUE,
  device_id INT REFERENCES devices(id)
);

--sequel
DB.create_table :parts do
  primary_key :id
  Integer :part_number, null: false, unique: true
  foreign_key :device_id, :devices
end

--adding data

 "Accelerometer" "Gyroscope"
  3                5
-- 3 to no one

INSERT INTO devices(name)
VALUES ('Accelerometer'), ('Gyroscope');

INSERT INTO parts(part_number, device_id)
VALUES (1, 1), (2, 1), (3, 1), (4, 2), (5, 2), (6, 2), (7, 2), (8, 2),
(9, null), (10, null), (11, null);

--sequel
DB[:devices].insert(name: 'Accelerometer')
DB[:devices].insert(name: 'Gyroscope')
DB[:parts].insert(part_number: 1, device_id: 1)
DB[:parts].insert(part_number: 2, device_id: 1)
DB[:parts].insert(part_number: 3, device_id: 1)
DB[:parts].insert(part_number: 4, device_id: 2)
DB[:parts].insert(part_number: 5, device_id: 2)
DB[:parts].insert(part_number: 6, device_id: 2)
DB[:parts].insert(part_number: 7, device_id: 2)
DB[:parts].insert(part_number: 8, device_id: 2)
DB[:parts].insert(part_number: 9)
DB[:parts].insert(part_number: 10)
DB[:parts].insert(part_number: 11)

--query data
SELECT name, part_number FROM devices
INNER JOIN parts ON devices.id = device_id;

--sequel
DB[:devices].join(:parts, device_id: :id).select(:name, :part_number)

--part numbers starting with 3

SELECT * FROM parts
WHERE part_number::text LIKE '3%';

--sequel
DB[:parts].where(Sequel.like(Sequel[:part_number].cast(:text), '3%'))

--device and parts

SELECT name, COUNT(devices.id)
FROM devices
INNER JOIN parts ON device_id = devices.id
GROUP BY devices.name;

--sequel
DB[:devices].join(:parts, device_id: :id).
group(:devices__name).select{[:name, count(:devices__id)]}

--order query above
SELECT name, COUNT(devices.id)
FROM devices
INNER JOIN parts ON device_id = devices.id
GROUP BY devices.name
ORDER BY devices.name;

--sequel
DB[:devices].join(:parts, device_id: :id).
group(:devices__name).select{[:name, count(:devices__id)]}.order(:devices__name)

--list first parts belonging to a device and secondly those that do not

SELECT part_number, device_id
FROM parts
WHERE device_id IS NOT NULL;

--sequel
DB[:parts].select(:part_number, :device_id).exclude(device_id: nil)

SELECT part_number, device_id
FROM parts
WHERE device_id IS NULL;

--sequel
DB[:parts].select(:part_number, :device_id).where(device_id: nil)


--return oldest device

SELECT name AS oldest_device FROM devices ORDER BY created_at ASC LIMIT 1;

--sequel, aliased as oldest_device
DB[:devices].select(:name___oldest_device).order(:created_at).limit(1).as(:oldest_device)

--updating data
UPDATE parts
SET device_id = 1
WHERE part_number = 7 AND part_number = 8;

--sequel
DB[:parts].where(part_number: 8).update(device_id: 1)
DB[:parts].where(part_number: 7).update(device_id: 1)

--delte accelerometer

DELETE FROM parts WHERE device_id = 1;
DELETE FROM devices WHERE name = 'Accelerometer';

--sequel
DB[:parts].where(device_id: 1).delete
DB[:devices].where(name: 'Accelerometer').delete

M : M

CREATE TABLE customers (
  id serial PRIMARY KEY,
  name text NOT NULL,
  payment_token text UNIQUE CHECK (payment_token SIMILAR TO ('[A-Z]{8}'))
);

--sequel
DB.create_table :customers do
  primary_key :id
  String :name, text: true, null: false
  String :payment_token, text: true, unique: true
  constraint(:payment_token_token_validity){Sequel.like(:payment_token, /[A-Z]{8}/)}
end

CREATE TABLE services (
  id serial PRIMARY KEY,
  description text NOT NULL,
  price numeric(10, 2) NOT NULL CHECK( price > 0.00)
);


--sequel
DB.create_table :services do
  primary_key :id
  String :description, text: true, null: false
  BigDecimal :price, size: [10, 2], null: false
  constraint(:price_valid_price){ price > 0.00 }
end


INSERT INTO customers(name, payment_token)
VALUES ('Pat Johnson', 'XHGOAHEQ'), ('Nancy Monreal', 'JKWQPJKL'),
('Lynn Blake', 'KLZXWEEE'), ('Chen Ke-Hua', 'KWETYCVX'),
('Scott Lakso', 'UUEAPQPS'), ('Jim Pornot', 'XKJEYAZA');

--sequel
DB[:customers].insert(name: 'Pat Johnson', payment_token: 'XHGOAHEQ')
DB[:customers].insert(name: 'Nancy Monreal', payment_token: 'JKWQPJKL')
DB[:customers].insert(name: 'Lynn Blake', payment_token: 'KLZXWEEE')
DB[:customers].insert(name: 'Chen Ke-Hua', payment_token: 'KWETYCVX')
DB[:customers].insert(name: 'Scott Lakso', payment_token: 'UUEAPQPS')
DB[:customers].insert(name: 'Jim Pornot', payment_token: 'XKJEYAZA')


INSERT INTO services(description, price)
VALUES ('Unix Hosting', 5.95), ('DNS', 4.95), ('Whois Registration', 1.95),
('High Bandwidth', 15.00), ('Business Support', 250.00), ('Dedicated Hosting', 50.00),
('Bulk Email', 250.00), ('One-to-one Training', 999.00);

--sequel
DB[:services].insert(description: 'Unix Hosting', price: 5.95)
DB[:services].insert(description: 'DNS', price: 4.95)
DB[:services].insert(description: 'Whois Registration', price: 1.95)
DB[:services].insert(description: 'High Bandwidth', price: 15.00)
DB[:services].insert(description: 'Business Support', price: 250.00)
DB[:services].insert(description: 'Dedicated Hosting', price: 50.00)
DB[:services].insert(description: 'Bulk Email', price: 250.00)
DB[:services].insert(description: 'One-to-one Training', price: 999.00)


CREATE TABLE customers_services (
  id serial PRIMARY KEY,
  customer_id INT REFERENCES customers (id) ON DELETE CASCADE,
  service_id INT REFERENCES services (id)
);
create_join_table(:artist_id=>:artists, :album_id=>:albums)

--sequel
DB.create_table :customers_services do
  primary_key :id
  foreign_key :customer_id, :customers, null: false, on_delete: :cascade
  foreign_key :service_id, :services, null: false 
end

INSERT INTO customers_services(customer_id, service_id)
VALUES (1, 1), (1, 2), (1, 3), (3, 1), (3, 2), (3, 3), (3, 4), (3, 5),
(4, 1), (4, 4), (5, 1), (5, 2), (5, 6), (6, 1), (6, 6), (6, 7);

--sequel
DB[:customers_services].insert(customer_id: 1, service_id: 1)
DB[:customers_services].insert(customer_id: 1, service_id: 2)
DB[:customers_services].insert(customer_id: 1, service_id: 3)
DB[:customers_services].insert(customer_id: 3, service_id: 1)
DB[:customers_services].insert(customer_id: 3, service_id: 2)
DB[:customers_services].insert(customer_id: 3, service_id: 3)
DB[:customers_services].insert(customer_id: 3, service_id: 4)
DB[:customers_services].insert(customer_id: 3, service_id: 5)
DB[:customers_services].insert(customer_id: 4, service_id: 1)
DB[:customers_services].insert(customer_id: 4, service_id: 4)
DB[:customers_services].insert(customer_id: 5, service_id: 1)
DB[:customers_services].insert(customer_id: 5, service_id: 2)
DB[:customers_services].insert(customer_id: 5, service_id: 6)
DB[:customers_services].insert(customer_id: 6, service_id: 1)
DB[:customers_services].insert(customer_id: 6, service_id: 6)
DB[:customers_services].insert(customer_id: 6, service_id: 7)


--get customers subscribed to atleast one service

SELECT DISTINCT customers.* 
FROM customers
     INNER JOIN customers_services ON customers.id = customer_id;

--sequel
DB[:customers].join(:customers_services, customer_id: :id).
distinct(:customers__name).
select{[:customers__id, :customers__name, :customers__payment_token]}

--customers not subscribed to any service

SELECT DISTINCT customers.* 
FROM customers
      LEFT JOIN customers_services ON customer_id = customers.id
WHERE service_id IS NULL;

--sequel
DB[:customers].left_outer_join(:customers_services, customer_id: :id).
where(service_id: nil).
select{[:customers__id, :customers__name, :customers__payment_token]}

--customers with no services and services with no customers
-- use the full join to return all the columsn of a table
SELECT customers.*, services.*
FROM customers_services
      FULL JOIN customers ON customers.id = customer_id
      FULL JOIN services ON services.id = service_id
WHERE service_id IS NULL OR customer_id IS NULL;

--sequel
DB[:customers].full_join(:customers_services, customer_id: :id).
full_join(:services, id: :service_id).
where(service_id: nil, customer_id: nil)

--services with no customers

SELECT DISTINCT services.* 
FROM services
      LEFT JOIN customers_services ON service_id = services.id
WHERE customer_id IS NULL;

--sequel
DB[:services].left_join(:customers_services, service_id: :id).
where(customer_id: nil).
select{[:services__id, :services__description, :services__price]}

SELECT name, string_agg(services.description, ', ')
FROM customers
     LEFT JOIN customers_services ON customer_id = customers.id
     LEFT JOIN services ON service_id = services.id
GROUP BY customers.name
ORDER BY name;

--sequel
DB.extension :string_agg
DB[:customers].left_join(:customers_services, customer_id: :id).
left_join(:services, id: :service_id).
group(:customers__name).
select(:name, Sequel.string_agg(:services__description, ', '))

-- work in progress

SELECT description, count(services.description)
FROM services
     INNER JOIN customers_services ON service_id = services.id
GROUP BY description
HAVING (count(services.description) >= 3);

--sequel
DB[:services].select{[:services__description, count(:services__description)]}.
join(:customers_services, service_id: :id).
group(:services__description).
having{count(:services__description) >= 3}

--income(gross)

SELECT sum(price) AS gross
FROM services
  INNER JOIN customers_services ON service_id = services.id
  INNER JOIN customers ON customer_id = customers.id;

--sequel
DB[:services].join(:customers_services, service_id: :id).
join(:customers, id: :customer_id).
select{ Sequel[sum(:services__price)].cast(:Float).as(:gross) }

--new customer
INSERT INTO customers (name, payment_token)
VALUES ('John Doe', 'EYODHLCN');

INSERT INTO customers_services(customer_id, service_id)
VALUES (7, 1), (7, 2), (7, 3)

--sequel
DB[:customers].insert(name: 'John Doe', payment_token: 'EYODHLCN')
DB[:customers_services].insert(customer_id: 7, service_id: 1)
DB[:customers_services].insert(customer_id: 7, service_id: 2)
DB[:customers_services].insert(customer_id: 7, service_id: 3)

--big ticket services money and hypothetical values

SELECT sum(price)
FROM services
     INNER JOIN customers_services ON service_id = services.id
     INNER JOIN customers ON customer_id = customers.id
WHERE services.price > 100;

--all customers taken big ticket services

SELECT sum(price)
FROM services
CROSS JOIN customers
WHERE price > 100 ;

--sequel
DB[:services].join(:customers_services, service_id: :id).
join(:customers, id: :customer_id).
where{:services__price > 100}.
select{Sequel[sum(:services__price)].cast(:Float)}

DB[:services].cross_join(:customers).
where{price > 100}.
select{Sequel[sum(:services__price)].cast(:Float)}


Write the necessary SQL statements to delete the "Bulk Email" service 
and customer "Chen Ke-Hua" from the database.

--deleting bulk email and chen ke-hua
DELETE FROM customers_services
WHERE service_id = 7;

DELETE FROM customers WHERE name = 'Chen Ke-Hua';
DELETE FROM services WHERE description = 'Bulk Email';

--sequel
DB[:customers_services].
where(service_id: 7).delete

DB[:customers].where(name: 'Chen Ke-Hua').delete
DB[:services].where(description: 'Bulk Email').delete


SUB QUERIES

--bidders table, items table, bids table
CREATE TABLE bidders (
  id serial PRIMARY KEY,
  name text NOT NULL
);

DB.create_table? :bidders do
  primary_key :id
  String :name, text: true, null: false
end

CREATE TABLE items (
  id serial PRIMARY KEY,
  name text NOT NULL,
  initial_price numeric(6, 2) NOT NULL,
  sales_price numeric(6, 2)
);

DB.create_table? :items do
  primary_key :id
  String :name, null: false
  BigDecimal :initial_price, size: [6, 2], null: false
  BigDecimal :sales_price, size: [6, 2]
end


CREATE TABLE bids (
  id serial PRIMARY KEY,
  bidder_id INT NOT NULL REFERENCES bidders (id),
  item_id INT NOT NULL REFERENCES items (id),
  amount numeric(6, 2) NOT NULL
);

DB.create_table? :bids do
  primary_key :id
  foreign_key :bidder_id, :bidders, null: false
  foreign_key :item_id, :items, null: false
  BigDecimal :amount, size: [6, 2], null: false
end

-- copying data into the database using the copy meta command

\copy bidders FROM ./bidders.csv WITH HEADER CSV;
\copy items FROM ./items.csv WITH HEADER CSV;
\copy bids(id, bidder_id, item_id, amount) FROM ./bids.csv WITH HEADER CSV;

-- items with bids placed on them
SELECT items.name
FROM items
WHERE items.id IN (SELECT item_id FROM bids );

--sequel
ids = DB[:bids].select(:item_id)
DB[:items].where(id: ids).select(:name)

-- items with no bids on them
SELECT items.name
FROM items
WHERE items.id NOT IN (SELECT item_id FROM bids );

--sequel
ids = DB[:bids].select(:item_id)
DB[:items].exclude(id: ids).select(:name)

--names of bidders who have placed bids
SELECT name
FROM bidders
WHERE EXISTS (SELECT bidder_id FROM bids WHERE bidders.id = bidder_id);

--sequel
ids = DB[:bids].select(:bidder_id)
DB[:bidders].where(id: ids).select(:name)

--or using the exist clause as stipulated
DB[:bidders].select(:name).where(DB[:bids].where(bidders__id: :bidder_id).
select(:bidder_id).exists)

--items sold for less than 100$
SELECT name AS "sold for less than 100 dollars" FROM items 
WHERE  100.00 > ANY (SELECT amount FROM bids WHERE items.id = item_id);

--or using all
SELECT name AS "sold for less than 100 dollars" FROM items 
WHERE  100 > ALL (SELECT amount FROM bids WHERE items.id = item_id);

--highest bids by each individual
SELECT MAX(bid_counts.count) 
FROM (SELECT COUNT(bidder_id) FROM bids GROUP BY bidder_id) AS bid_counts;

--sequel
DB[DB[:bids].group(:bidder_id).
select{count(:bidder_id)}.as(:bid_counts)].
select{max(:bid_counts__count)}

--using a scalar sub query to return number of bids for each item
SELECT name, (SELECT count(item_id) FROM bids WHERE items.id = item_id)
FROM items;

DB[:items].select{[:name, DB[:bids].select{count(item_id)}.
where(items__id: :item_id)]}









