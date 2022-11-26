CREATE TABLE services
(
    id_service    INT          NOT NULL AUTO_INCREMENT,
    `name`        VARCHAR(128) NOT NULL check ( length(name) > 0 ),
    `description` TEXT         NOT NULL check ( length(description) > 0 ),
    duration      INT NOT NULL check ( duration > 0 ),
    price         INT NOT NULL check ( price > 0 ),
    PRIMARY KEY (id_service)
);

CREATE TABLE barbers
(
    id_barber INT          NOT NULL AUTO_INCREMENT,
    `name`    VARCHAR(128) NOT NULL check ( length(name) > 0 ),
    rating    FLOAT check ( rating > 0 ),
    PRIMARY KEY (id_barber)
);

CREATE TABLE barber_service
(
    id_barber  INT NOT NULL,
    id_service INT NOT NULL,
    FOREIGN KEY (id_barber) REFERENCES barbers (id_barber) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_service) REFERENCES services (id_service) ON DELETE CASCADE ON UPDATE CASCADE,
    PRIMARY KEY (id_barber, id_service)
);

CREATE TABLE loyalty_cards
(
    id_card          INT NOT NULL,
    discount_percent INT NOT NULL check ( discount_percent < 80 and discount_percent > 0 ),
    PRIMARY KEY (id_card)
);

CREATE TABLE clients
(
    id_client    INT          NOT NULL AUTO_INCREMENT,
    `name`       VARCHAR(128) NOT NULL check ( length(name) > 0 ),
    email        VARCHAR(128) NOT NULL,
    `password`   VARCHAR(128) NOT NULL check ( length(password) > 7 ),
    phone_number VARCHAR(128) NOT NULL,
    id_card      INT,
    FOREIGN KEY (id_card) REFERENCES loyalty_cards (id_card) ON DELETE CASCADE ON UPDATE CASCADE,
    PRIMARY KEY (id_client)
);

CREATE TABLE events
(
    id_event        INT       NOT NULL AUTO_INCREMENT,
    id_service      INT       NOT NULL,
    id_barber       INT       NOT NULL,
    id_client       INT       NOT NULL,
    visit_date_time TIMESTAMP NOT NULL,
    FOREIGN KEY (id_barber) REFERENCES barbers (id_barber) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_service) REFERENCES services (id_service) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_client) REFERENCES clients (id_client) ON DELETE CASCADE ON UPDATE CASCADE,
    PRIMARY KEY (id_event, id_service, id_barber, id_client)
);

CREATE TABLE reviews
(
    id_review     INT       NOT NULL AUTO_INCREMENT,
    id_client     INT       NOT NULL,
    content       TEXT      NOT NULL check ( length(content) > 0 ),
    creation_time TIMESTAMP NOT NULL,
    FOREIGN KEY (id_client) REFERENCES clients (id_client) ON DELETE CASCADE ON UPDATE CASCADE,
    PRIMARY KEY (id_review, id_client)
);

CREATE TABLE log_events
(
    id_event_log        INT       NOT NULL AUTO_INCREMENT,
    id_service_log      INT       NOT NULL,
    id_barber_log       INT       NOT NULL,
    id_client_log       INT       NOT NULL,
    visit_date_time_log TIMESTAMP NOT NULL,
    FOREIGN KEY (id_barber_log) REFERENCES barbers (id_barber) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_service_log) REFERENCES services (id_service) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_client_log) REFERENCES clients (id_client) ON DELETE CASCADE ON UPDATE CASCADE,
    PRIMARY KEY (id_event_log, id_service_log, id_barber_log, id_client_log)
);

create function is_barber_service_connected(barber_id int, service_id int) returns boolean
    not deterministic
begin
    return exists(SELECT *
                  from barber_service
                  where barber_service.id_barber = barber_id
                    AND barber_service.id_service = service_id);
end;

create function is_email_valid(email_to_check varchar(128)) returns boolean
    deterministic
begin
    return email_to_check like '%_@__%.__%';
end;

create function is_phone_number_valid(phone_number varchar(128)) returns boolean
    deterministic
begin
    return phone_number like '+7(___)___-__-__';
end;

create trigger barber_service_connection_check
    before insert
    on `events`
    for each row
begin
    DECLARE msg VARCHAR(255);
    if (not is_barber_service_connected(NEW.`id_barber`, NEW.`id_service`)) then
        set msg = 'Barber and service are not connected';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = msg;
    end if;
end;

create trigger change_barbers_on_delete_trigger
    before delete
    on barbers
    for each row
begin
    declare replace_service_duration int;
    declare replace_barber_id int;
    declare event_duration timestamp;

    select duration
    into replace_service_duration
    from services
             inner join events e on services.id_service = e.id_service
             inner join barbers b on e.id_barber = b.id_barber
    where b.id_barber = old.id_barber;

    select visit_date_time into event_duration from `events` where events.id_barber = old.id_barber;

    select id_barber
    into replace_barber_id
    from `events`
             inner join services s on events.id_service = s.id_service
    where (DATE(visit_date_time) + interval s.duration minute < DATE(visit_date_time)
        or DATE(visit_date_time) > DATE(visit_date_time) + interval duration minute)
      and id_barber != old.id_barber
    group by id_barber
    order by count(id_barber)
    limit 1;

    update events set id_barber = replace_barber_id where id_barber = old.id_barber;
end;

create trigger log_passed_event
    after delete
    on `events`
    for each row
begin
    insert into log_events (id_service_log, id_barber_log, id_client_log, visit_date_time_log)
    values (old.id_service, old.id_barber, old.id_client, old.visit_date_time);
end;

create event clear_old_events
    on schedule
        every 1 day
    do
    begin
        delete from events where DATE(visit_date_time) < CURRENT_DATE;
    end;

create event clear_logs
    on schedule
        every 30 day
    do
    begin
        delete from log_events where DATE(visit_date_time_log) + interval 20 day < CURRENT_DATE;
    end;

ALTER TABLE clients
    ADD CONSTRAINT email_check CHECK ( clients.email like '%_@__%.__%' );
ALTER TABLE clients
    ADD CONSTRAINT phone_number_check CHECK ( clients.phone_number like '+7(___)___-__-__' );
# '+(_)|(__)(___)___-__-__'

CREATE INDEX idx_client_name on clients (`name`);
CREATE INDEX idx_client_email on clients (email);
CREATE INDEX idx_client_phone on clients (phone_number);

CREATE INDEX idx_barber_name on barbers (`name`);
CREATE INDEX idx_service_name on services (`name`);

insert into services (name, description, duration, price) values ('Trippledex', 'Future-proofed logistical open architecture', '48', '007');
insert into services (name, description, duration, price) values ('Latlux', 'Open-source solution-oriented support', '7854', '5446');
insert into services (name, description, duration, price) values ('Flexidy', 'Cloned composite standardization', '69', '941');
insert into services (name, description, duration, price) values ('Stringtough', 'Re-engineered analyzing approach', '20', '22333');
insert into services (name, description, duration, price) values ('Bytecard', 'Inverse secondary info-mediaries', '6789', '49549');
insert into services (name, description, duration, price) values ('Voyatouch', 'Networked scalable open system', '9646', '300');
insert into services (name, description, duration, price) values ('Lotlux', 'De-engineered eco-centric circuit', '2', '5');
insert into services (name, description, duration, price) values ('Prodder', 'Customizable national implementation', '74', '792');
insert into services (name, description, duration, price) values ('Y-find', 'Advanced modular firmware', '9', '64110');
insert into services (name, description, duration, price) values ('Quo Lux', 'Realigned human-resource database', '9', '947');
insert into services (name, description, duration, price) values ('Daltfresh', 'Optimized neutral emulation', '5', '064');
insert into services (name, description, duration, price) values ('Toughjoyfax', 'Upgradable local structure', '73019', '240');
insert into services (name, description, duration, price) values ('Y-find', 'Fundamental didactic budgetary management', '26', '952');
insert into services (name, description, duration, price) values ('Latlux', 'Implemented systemic installation', '70', '31733');
insert into services (name, description, duration, price) values ('Stringtough', 'Automated tertiary adapter', '55965', '5');
insert into services (name, description, duration, price) values ('Pannier', 'User-centric optimal standardization', '9', '54');
insert into services (name, description, duration, price) values ('Latlux', 'Diverse real-time extranet', '93', '55834');
insert into services (name, description, duration, price) values ('Greenlam', 'Vision-oriented bandwidth-monitored matrix', '830', '886');
insert into services (name, description, duration, price) values ('Y-find', 'Total value-added focus group', '66', '01615');
insert into services (name, description, duration, price) values ('Stringtough', 'Automated dynamic standardization', '7', '3640');

insert into barbers (name, rating) values ('Trudi Solleme', 2.67);
insert into barbers (name, rating) values ('Agathe Little', 3.6);
insert into barbers (name, rating) values ('Em Artingstall', 1.47);
insert into barbers (name, rating) values ('Gillian Freed', 3.38);
insert into barbers (name, rating) values ('Jeana Grunnill', 3.04);
insert into barbers (name, rating) values ('Lona O''Docherty', 2.74);
insert into barbers (name, rating) values ('Kellie Slainey', 3.85);
insert into barbers (name, rating) values ('Latrena Burrass', 3.5);
insert into barbers (name, rating) values ('Arliene Rodenhurst', 2.03);
insert into barbers (name, rating) values ('Cymbre Langer', 1.3);
insert into barbers (name, rating) values ('Sarena Bosward', 3.76);
insert into barbers (name, rating) values ('Wilma Yell', 1.74);
insert into barbers (name, rating) values ('Bruis Espinheira', 3.59);

insert into barber_service (id_barber, id_service) values (1, 1);
insert into barber_service (id_barber, id_service) values (1, 2);
insert into barber_service (id_barber, id_service) values (1, 3);
insert into barber_service (id_barber, id_service) values (1, 4);
insert into barber_service (id_barber, id_service) values (1, 5);
insert into barber_service (id_barber, id_service) values (1, 6);
insert into barber_service (id_barber, id_service) values (1, 7);
insert into barber_service (id_barber, id_service) values (1, 8);
insert into barber_service (id_barber, id_service) values (1, 9);
insert into barber_service (id_barber, id_service) values (1, 10);
insert into barber_service (id_barber, id_service) values (1, 11);
insert into barber_service (id_barber, id_service) values (1, 12);
insert into barber_service (id_barber, id_service) values (1, 13);
insert into barber_service (id_barber, id_service) values (1, 14);
insert into barber_service (id_barber, id_service) values (1, 15);
insert into barber_service (id_barber, id_service) values (1, 16);
insert into barber_service (id_barber, id_service) values (1, 17);
insert into barber_service (id_barber, id_service) values (1, 18);
insert into barber_service (id_barber, id_service) values (1, 19);
insert into barber_service (id_barber, id_service) values (1, 20);
insert into barber_service (id_barber, id_service) values (2, 4);
insert into barber_service (id_barber, id_service) values (2, 16);
insert into barber_service (id_barber, id_service) values (2, 15);
insert into barber_service (id_barber, id_service) values (3, 20);
insert into barber_service (id_barber, id_service) values (3, 9);
insert into barber_service (id_barber, id_service) values (3, 12);
insert into barber_service (id_barber, id_service) values (3, 11);
insert into barber_service (id_barber, id_service) values (3, 4);
insert into barber_service (id_barber, id_service) values (3, 13);
insert into barber_service (id_barber, id_service) values (4, 11);
insert into barber_service (id_barber, id_service) values (4, 5);
insert into barber_service (id_barber, id_service) values (4, 8);
insert into barber_service (id_barber, id_service) values (4, 9);
insert into barber_service (id_barber, id_service) values (4, 13);
insert into barber_service (id_barber, id_service) values (4, 1);
insert into barber_service (id_barber, id_service) values (4, 4);
insert into barber_service (id_barber, id_service) values (4, 17);
insert into barber_service (id_barber, id_service) values (4, 12);
insert into barber_service (id_barber, id_service) values (5, 5);
insert into barber_service (id_barber, id_service) values (6, 19);
insert into barber_service (id_barber, id_service) values (6, 2);
insert into barber_service (id_barber, id_service) values (6, 17);
insert into barber_service (id_barber, id_service) values (6, 4);
insert into barber_service (id_barber, id_service) values (6, 20);
insert into barber_service (id_barber, id_service) values (6, 16);
insert into barber_service (id_barber, id_service) values (6, 15);
insert into barber_service (id_barber, id_service) values (6, 8);
insert into barber_service (id_barber, id_service) values (6, 9);
insert into barber_service (id_barber, id_service) values (7, 5);
insert into barber_service (id_barber, id_service) values (7, 17);
insert into barber_service (id_barber, id_service) values (7, 1);
insert into barber_service (id_barber, id_service) values (7, 13);
insert into barber_service (id_barber, id_service) values (7, 19);
insert into barber_service (id_barber, id_service) values (7, 6);
insert into barber_service (id_barber, id_service) values (7, 15);
insert into barber_service (id_barber, id_service) values (7, 11);
insert into barber_service (id_barber, id_service) values (8, 19);
insert into barber_service (id_barber, id_service) values (8, 17);
insert into barber_service (id_barber, id_service) values (8, 10);
insert into barber_service (id_barber, id_service) values (9, 2);
insert into barber_service (id_barber, id_service) values (10, 1);
insert into barber_service (id_barber, id_service) values (10, 10);
insert into barber_service (id_barber, id_service) values (11, 16);
insert into barber_service (id_barber, id_service) values (11, 19);
insert into barber_service (id_barber, id_service) values (12, 7);
insert into barber_service (id_barber, id_service) values (12, 11);

insert into loyalty_cards (id_card, discount_percent) values (1, 70);
insert into loyalty_cards (id_card, discount_percent) values (2, 72);
insert into loyalty_cards (id_card, discount_percent) values (3, 65);
insert into loyalty_cards (id_card, discount_percent) values (4, 78);
insert into loyalty_cards (id_card, discount_percent) values (5, 76);
insert into loyalty_cards (id_card, discount_percent) values (6, 15);
insert into loyalty_cards (id_card, discount_percent) values (7, 35);
insert into loyalty_cards (id_card, discount_percent) values (8, 50);
insert into loyalty_cards (id_card, discount_percent) values (9, 5);
insert into loyalty_cards (id_card, discount_percent) values (10, 50);
insert into loyalty_cards (id_card, discount_percent) values (11, 14);
insert into loyalty_cards (id_card, discount_percent) values (12, 52);
insert into loyalty_cards (id_card, discount_percent) values (13, 61);
insert into loyalty_cards (id_card, discount_percent) values (14, 79);
insert into loyalty_cards (id_card, discount_percent) values (15, 24);
insert into loyalty_cards (id_card, discount_percent) values (16, 37);
insert into loyalty_cards (id_card, discount_percent) values (17, 33);
insert into loyalty_cards (id_card, discount_percent) values (18, 32);
insert into loyalty_cards (id_card, discount_percent) values (19, 48);
insert into loyalty_cards (id_card, discount_percent) values (20, 25);
insert into loyalty_cards (id_card, discount_percent) values (21, 1);
insert into loyalty_cards (id_card, discount_percent) values (22, 68);
insert into loyalty_cards (id_card, discount_percent) values (23, 28);
insert into loyalty_cards (id_card, discount_percent) values (24, 14);
insert into loyalty_cards (id_card, discount_percent) values (25, 15);
insert into loyalty_cards (id_card, discount_percent) values (26, 39);
insert into loyalty_cards (id_card, discount_percent) values (27, 10);
insert into loyalty_cards (id_card, discount_percent) values (28, 40);
insert into loyalty_cards (id_card, discount_percent) values (29, 33);
insert into loyalty_cards (id_card, discount_percent) values (30, 36);
insert into loyalty_cards (id_card, discount_percent) values (31, 24);
insert into loyalty_cards (id_card, discount_percent) values (32, 23);
insert into loyalty_cards (id_card, discount_percent) values (33, 75);
insert into loyalty_cards (id_card, discount_percent) values (34, 27);
insert into loyalty_cards (id_card, discount_percent) values (35, 79);
insert into loyalty_cards (id_card, discount_percent) values (36, 74);
insert into loyalty_cards (id_card, discount_percent) values (37, 63);
insert into loyalty_cards (id_card, discount_percent) values (38, 18);
insert into loyalty_cards (id_card, discount_percent) values (39, 2);
insert into loyalty_cards (id_card, discount_percent) values (40, 57);

insert into clients (name, email, password, phone_number, id_card) values ('Audrey Gardiner', 'shuuzmauoa@mail.ru', 'NUJDVLbtGvJDbij', '+7(304)967-86-35', 1);
insert into clients (name, email, password, phone_number, id_card) values ('Janice George', 'bojfzh@mail.ru', 'VjZyuoUKLft', '+7(410)210-29-86', 2);
insert into clients (name, email, password, phone_number, id_card) values ('Dina Greenaway', 'hlrdyqwngf@mail.ru', 'FnRfEgEmufFTZD', '+7(616)523-81-55', 3);
insert into clients (name, email, password, phone_number, id_card) values ('Riaan Wilkes', 'wvptha@yahoo.com', 'wIAwatFpjk', '+7(933)528-21-73', 4);
insert into clients (name, email, password, phone_number, id_card) values ('Fatima Parry', 'owtggkqcqx@ya.ru', 'uWrqHKDqHqDMCA', '+7(835)605-74-74', 5);
insert into clients (name, email, password, phone_number, id_card) values ('Marisa Wills', 'ciomlkfi@yahoo.com', 'WhuwXKtTDCRYSCJ', '+7(409)536-47-41', 6);
insert into clients (name, email, password, phone_number, id_card) values ('Jenny Mcnamara', 'zdeqiqpfgejq@ya.ru', 'NsoJRytPGa', '+7(511)306-48-21', 7);
insert into clients (name, email, password, phone_number, id_card) values ('Lilly-Grace Moran', 'mbxtchgqacqe@bing.com', 'omDwtMJVysp', '+7(223)483-70-22', 8);
insert into clients (name, email, password, phone_number, id_card) values ('Noor Henderson', 'gnqgdxta@ya.ru', 'uwCrmmDKKS', '+7(706)430-14-34', 9);
insert into clients (name, email, password, phone_number, id_card) values ('Glenda Rayner', 'iplisjcqy@yahoo.com', 'CgXCllTHyUILT', '+7(265)878-69-89', 10);
insert into clients (name, email, password, phone_number, id_card) values ('Garfield Mclellan', 'oxtfceyb@bing.com', 'UlMVAsAcP', '+7(241)901-41-70', 11);
insert into clients (name, email, password, phone_number, id_card) values ('Hailie Hodgson', 'fmkmunnd@gmail.com', 'oZaExGoMgBRFNZt', '+7(163)782-88-42', 12);
insert into clients (name, email, password, phone_number, id_card) values ('Jasmine Gardiner', 'cnzphgudt@ya.ru', 'GosNmMfpr', '+7(741)904-19-84', 13);
insert into clients (name, email, password, phone_number, id_card) values ('Cathal Singh', 'bialyt@bing.com', 'KhciAarqAQmo', '+7(824)962-66-62', 14);
insert into clients (name, email, password, phone_number, id_card) values ('Raees Webster', 'kmmbzaj@gmail.com', 'yCFIHIIqJZPx', '+7(314)998-43-48', 15);
insert into clients (name, email, password, phone_number, id_card) values ('Chantel Battle', 'ksifpz@gmail.com', 'VZeYOJaYebSclE', '+7(893)886-33-47', 16);
insert into clients (name, email, password, phone_number, id_card) values ('Manha Gates', 'hfonklmbc@mail.ru', 'IjSEtIqBOyCAUJE', '+7(779)770-76-39', 17);
insert into clients (name, email, password, phone_number, id_card) values ('Phebe Copeland', 'lwdzccej@mail.ru', 'MalveVFfJeAACq', '+7(842)338-66-70', 18);
insert into clients (name, email, password, phone_number, id_card) values ('Salman Yoder', 'czkjhohpvbbs@mail.ru', 'dGsybvuccES', '+7(165)320-74-21', 19);
insert into clients (name, email, password, phone_number, id_card) values ('Rose Patrick', 'ljvppmdovoo@mail.ru', 'XAWfZqCkEbyTMSo', '+7(321)949-74-96', 20);
insert into clients (name, email, password, phone_number, id_card) values ('Shelby Portillo', 'gqnfdlakwhjc@bing.com', 'WpZQbYUujTlBA', '+7(670)790-29-44', 21);
insert into clients (name, email, password, phone_number, id_card) values ('Siya Rivers', 'bgximnq@gmail.com', 'AjgCBNfTM', '+7(208)285-26-78', 22);
insert into clients (name, email, password, phone_number, id_card) values ('Dean Crossley', 'rdraezbrrd@mail.ru', 'cETxZxHSuExFzpS', '+7(654)814-37-76', 23);
insert into clients (name, email, password, phone_number, id_card) values ('Aishah Stark', 'kofthgpq@ya.ru', 'xnSajOkizejZ', '+7(580)143-86-52', 24);
insert into clients (name, email, password, phone_number, id_card) values ('Polly Cooley', 'elempgir@yahoo.com', 'NWLzVvWxKvk', '+7(432)653-53-19', 25);
insert into clients (name, email, password, phone_number, id_card) values ('Melissa Case', 'aackiqvkgwmv@yahoo.com', 'XsKvnFSLZAtNVX', '+7(713)843-33-92', 26);
insert into clients (name, email, password, phone_number, id_card) values ('Omari Redman', 'hszrpdltmg@bing.com', 'EhrrQXyAuYJNSNf', '+7(942)979-19-87', 27);
insert into clients (name, email, password, phone_number, id_card) values ('Sami Davidson', 'pnpqrx@yahoo.com', 'SJxHSbVDNIs', '+7(955)525-32-98', 28);
insert into clients (name, email, password, phone_number, id_card) values ('Charlie Lyon', 'ebrzvvnssyi@mail.ru', 'gbcZRLoZzSnbk', '+7(227)491-10-45', 29);
insert into clients (name, email, password, phone_number, id_card) values ('Jaydn Hollis', 'exqoonrczt@gmail.com', 'CTyjIsKvpburnNT', '+7(427)169-65-22', 30);
insert into clients (name, email, password, phone_number, id_card) values ('Chloe-Ann Portillo', 'tggffvkz@bing.com', 'tuhSSlMPl', '+7(821)481-88-73', 31);
insert into clients (name, email, password, phone_number, id_card) values ('Karol Kane', 'pvmpkwu@bing.com', 'NpqorKeFEtB', '+7(867)781-89-44', 32);
insert into clients (name, email, password, phone_number, id_card) values ('Alaw Harmon', 'uqxtfmhdb@mail.ru', 'wTyamWNoCxj', '+7(998)638-41-41', 33);
insert into clients (name, email, password, phone_number, id_card) values ('Zavier Higgs', 'sblpeuscg@bing.com', 'pRMMQewdi', '+7(757)654-68-31', 34);
insert into clients (name, email, password, phone_number, id_card) values ('Caspar Terrell', 'aeaqwsaof@yahoo.com', 'agHEkKXcCX', '+7(538)483-97-36', 35);
insert into clients (name, email, password, phone_number, id_card) values ('Wayne Robles', 'otgloboon@gmail.com', 'RBzAVIMRzadZGAQ', '+7(578)466-24-72', 36);
insert into clients (name, email, password, phone_number, id_card) values ('Kane Talbot', 'zhnwvpsqxmf@ya.ru', 'NXbyDnlEpwF', '+7(218)237-27-37', 37);
insert into clients (name, email, password, phone_number, id_card) values ('Adam Lara', 'upngmaynpr@gmail.com', 'OQzyUiRLqPU', '+7(630)870-86-48', 38);
insert into clients (name, email, password, phone_number, id_card) values ('Haaris Ferreira', 'gnosqhiub@bing.com', 'ILXqZGQrNuZ', '+7(481)127-76-55', 39);
insert into clients (name, email, password, phone_number, id_card) values ('Jarvis English', 'uhwyaifjs@yahoo.com', 'fyQOFvmedUB', '+7(126)871-83-34', 40);

insert into reviews (id_client, content, creation_time) values (1, 'Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus. In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.', TIMESTAMP('2022-08-01 09:02:15'));
insert into reviews (id_client, content, creation_time) values (2, 'Fusce consequat. Nulla nisl. Nunc nisl.Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.', TIMESTAMP('2022-09-16 06:38:24'));
insert into reviews (id_client, content, creation_time) values (3, 'Fusce consequat. Nulla nisl. Nunc nisl.Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. ', TIMESTAMP('2022-09-17 18:38:24'));
insert into reviews (id_client, content, creation_time) values (4, 'Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.', TIMESTAMP('2022-08-04 06:38:24'));
insert into reviews (id_client, content, creation_time) values (10, 'Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.', TIMESTAMP('2022-05-31 15:38:24'));
insert into reviews (id_client, content, creation_time) values (12, 'Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris.', TIMESTAMP('2022-09-15 06:38:24'));
insert into reviews (id_client, content, creation_time) values (15, 'Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.', TIMESTAMP('2022-07-07 06:38:24'));
insert into reviews (id_client, content, creation_time) values (22, 'Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.', TIMESTAMP('2022-08-18 10:38:24'));

insert into events (id_service, id_barber, id_client, visit_date_time) values (5, 4, 13, TIMESTAMP('2022-10-11 01:44:08'));
insert into events (id_service, id_barber, id_client, visit_date_time) values (16, 2, 2, TIMESTAMP('2022-04-01 16:59:42'));
insert into events (id_service, id_barber, id_client, visit_date_time) values (1, 10, 7, TIMESTAMP('2022-04-20 17:04:16'));
insert into events (id_service, id_barber, id_client, visit_date_time) values (16, 6, 2, TIMESTAMP('2022-05-01 13:04:43'));
insert into events (id_service, id_barber, id_client, visit_date_time) values (16, 1, 40, TIMESTAMP('2021-10-19 23:32:47'));
insert into events (id_service, id_barber, id_client, visit_date_time) values (15, 2, 4, TIMESTAMP('2022-05-31 04:55:17'));
insert into events (id_service, id_barber, id_client, visit_date_time) values (11, 12, 39, TIMESTAMP('2022-09-03 19:17:06'));
insert into events (id_service, id_barber, id_client, visit_date_time) values (10, 10, 26, TIMESTAMP('2022-07-15 00:39:01'));
insert into events (id_service, id_barber, id_client, visit_date_time) values (13, 7, 38, TIMESTAMP('2022-03-10 14:39:21'));
insert into events (id_service, id_barber, id_client, visit_date_time) values (2, 9, 14, TIMESTAMP('2022-01-01 19:32:37'));