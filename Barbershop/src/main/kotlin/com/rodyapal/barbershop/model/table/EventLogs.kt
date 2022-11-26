package com.rodyapal.barbershop.model.table

import com.rodyapal.barbershop.model.entity.Event
import org.ktorm.schema.Table
import org.ktorm.schema.int
import org.ktorm.schema.jdbcTimestamp

object EventLogs : Table<Event>("log_events") {
	val idEvent = int("id_event_log").primaryKey().bindTo { it.id }
	val idService = int("id_service_log").primaryKey().references(Services) { it.service }
	val idBarber = int("id_barber_log").primaryKey().references(Barbers) { it.barber }
	val idClient = int("id_client_log").primaryKey().references(Clients) { it.client }
	val visitDateTime = jdbcTimestamp("visit_date_time_log").bindTo { it.visitDateTime }
}