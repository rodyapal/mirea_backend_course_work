package com.rodyapal.barbershop.model.entity

import com.rodyapal.barbershop.model.dao.BSConnectionDao
import org.ktorm.dsl.eq
import org.ktorm.entity.Entity

interface Service : Entity<Service> {
	companion object : Entity.Factory<Service>()
	val id: Int
	var name: String
	var description: String
	var duration: Int
	var price: Int

	fun getBarberIds(dao: BSConnectionDao) = dao.findList { id eq it.idService }
}