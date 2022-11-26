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