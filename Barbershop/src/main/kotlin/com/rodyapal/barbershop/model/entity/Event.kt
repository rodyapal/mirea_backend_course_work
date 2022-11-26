package com.rodyapal.barbershop.model.entity

import org.ktorm.entity.Entity
import java.sql.Timestamp

interface Event : Entity<Event> {
	companion object : Entity.Factory<Barber>()
	val id: Int
	var service: Service
	var barber: Barber
	val client: Client
	var visitDateTime: Timestamp
}