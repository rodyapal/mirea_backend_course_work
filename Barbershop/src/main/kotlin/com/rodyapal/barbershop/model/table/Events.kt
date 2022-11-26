package com.rodyapal.barbershop.model.table

import com.rodyapal.barbershop.model.entity.Event
import org.ktorm.schema.Table
import org.ktorm.schema.int
import org.ktorm.schema.jdbcTimestamp

object Events : Table<Event>("events") {
	val idEvent = int("id_event").primaryKey().bindTo { it.id }
	val idService = int("id_service").primaryKey().references(Services) { it.service }
	val idBarber = int("id_barber").primaryKey().references(Barbers) { it.barber }
	val idClient = int("id_client").primaryKey().references(Clients) { it.client }
	val visitDateTime = jdbcTimestamp("visit_date_time").bindTo { it.visitDateTime }
}