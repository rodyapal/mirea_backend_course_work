package com.rodyapal.barbershop.model.entity

import com.rodyapal.barbershop.model.AppDatabase
import org.ktorm.dsl.eq
import org.ktorm.entity.Entity
import org.ktorm.entity.filter
import org.ktorm.entity.toList

interface Barber : Entity<Barber> {
	companion object : Entity.Factory<Barber>()
	val id: Int
	var name: String
	var rating: Float

	val service: List<Service> get() = AppDatabase.BSConnections
		.filter { it.idBarber eq id }.toList()
		.map { it.service.id }
		.let {
			AppDatabase.services.toList().filter { service ->
				service.id in it
			}
		}
}