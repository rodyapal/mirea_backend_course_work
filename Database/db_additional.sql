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

    select duration into replace_service_duration from services
        inner join events e on services.id_service = e.id_service
        inner join barbers b on e.id_barber = b.id_barber
        where b.id_barber = old.id_barber;

    select visit_date_time into event_duration from `events` where events.id_barber = old.id_barber;

    select id_barber into replace_barber_id from `events`
        inner join services s on events.id_service = s.id_service
        where (DATE(visit_date_time) + interval s.duration minute < DATE(visit_date_time)
        or DATE(visit_date_time) > DATE(visit_date_time) + interval duration minute)
        and id_barber != old.id_barber
        group by id_barber order by count(id_barber)
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