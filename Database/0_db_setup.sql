GRANT ALL ON appDb TO appUser WITH GRANT OPTION;
FLUSH PRIVILEGES;
SET GLOBAL log_bin_trust_function_creators=1;

CREATE TABLE services (
	id_service 	INT NOT NULL AUTO_INCREMENT,
	`name` 		VARCHAR(128) NOT NULL check ( length(name) > 0 ),
	`description` TEXT NOT NULL check ( length(description) > 0 ),
	duration 	INT NOT NULL check ( duration > 0 ),
	price 		INT NOT NULL check ( price > 0 ),
	PRIMARY KEY (id_service)
);

CREATE TABLE barbers (
	id_barber 	INT NOT NULL AUTO_INCREMENT,
	`name` 		VARCHAR(128) NOT NULL check ( length(name) > 0 ),
	rating 		FLOAT check ( rating > 0 ),
	PRIMARY KEY (id_barber)
);

CREATE TABLE barber_service (
	id_barber  INT NOT NULL,
	id_service INT NOT NULL,
	FOREIGN KEY (id_barber)  REFERENCES barbers(id_barber) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (id_service) REFERENCES services(id_service) ON DELETE CASCADE ON UPDATE CASCADE,
	PRIMARY KEY (id_barber, id_service)
);

CREATE TABLE loyalty_cards (
	id_card 			INT NOT NULL,
	discount_percent  	INT NOT NULL check ( discount_percent < 80 and discount_percent > 0 ),
	PRIMARY KEY (id_card)
);

CREATE TABLE clients (
	id_client 		INT NOT NULL AUTO_INCREMENT,
	`name` 			VARCHAR(128) NOT NULL check ( length(name) > 0 ),
	email 			VARCHAR(128) NOT NULL,
	`password` 		VARCHAR(128) NOT NULL check ( length(password) > 7 ),
	phone_number  	VARCHAR(128) NOT NULL,
	id_card			INT,
	FOREIGN KEY (id_card) REFERENCES loyalty_cards(id_card) ON DELETE CASCADE ON UPDATE CASCADE,
	PRIMARY KEY (id_client)
);

CREATE TABLE events (
	id_event 		INT NOT NULL AUTO_INCREMENT,
	id_service  	INT NOT NULL,
	id_barber 		INT NOT NULL,
	id_client 		INT NOT NULL,
	visit_date_time	TIMESTAMP NOT NULL,
	FOREIGN KEY (id_barber) 	REFERENCES barbers(id_barber) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (id_service) 	REFERENCES services(id_service) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (id_client) 	REFERENCES clients(id_client) ON DELETE CASCADE ON UPDATE CASCADE,
	PRIMARY KEY (id_event, id_service, id_barber, id_client)
);

CREATE TABLE reviews (
	id_review 		INT NOT NULL AUTO_INCREMENT,
	id_client  		INT NOT NULL,
	content 		TEXT NOT NULL check ( length(content) > 0 ),
	creation_time	TIMESTAMP NOT NULL,
	FOREIGN KEY (id_client) REFERENCES clients(id_client) ON DELETE CASCADE ON UPDATE CASCADE,
	PRIMARY KEY (id_review, id_client)
);

CREATE TABLE log_events (
	id_event_log 		INT NOT NULL AUTO_INCREMENT,
	id_service_log  	INT NOT NULL,
	id_barber_log 		INT NOT NULL,
	id_client_log 		INT NOT NULL,
	visit_date_time_log	TIMESTAMP NOT NULL,
	FOREIGN KEY (id_barber_log) 	REFERENCES barbers(id_barber) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (id_service_log) 	REFERENCES services(id_service) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (id_client_log) 	REFERENCES clients(id_client) ON DELETE CASCADE ON UPDATE CASCADE,
	PRIMARY KEY (id_event_log, id_service_log, id_barber_log, id_client_log)
);