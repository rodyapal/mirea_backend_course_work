package com.rodyapal.barbershop.model.entity

import com.rodyapal.barbershop.model.AppDatabase
import org.ktorm.dsl.eq
import org.ktorm.entity.Entity
import org.ktorm.entity.filter
import org.ktorm.entity.toList

interface Service : Entity<Service> {
	companion object : Entity.Factory<Service>()
	val id: Int
	var name: String
	var description: String
	var duration: Int
	var price: Int

	val providers: List<Barber> get() = AppDatabase.BSConnections
		.filter { it.idService eq id }.toList()
		.map { it.barber.id }
		.let {
			AppDatabase.barbers.toList().filter { barber ->
				barber.id in it
			}
		}
}