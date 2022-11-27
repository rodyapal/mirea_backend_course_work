package com.rodyapal.barbershop.model.entity

import com.rodyapal.barbershop.model.BSConnections
import com.rodyapal.barbershop.model.dao.BSConnectionDao
import com.rodyapal.barbershop.model.services
import org.ktorm.database.Database
import org.ktorm.dsl.eq
import org.ktorm.dsl.inList
import org.ktorm.entity.Entity
import org.ktorm.entity.filter
import org.ktorm.entity.toList

interface Barber : Entity<Barber> {
	companion object : Entity.Factory<Barber>()
	val id: Int
	var name: String
	var rating: Float

	fun getServiceIds(dao: BSConnectionDao) = dao.findList { id eq it.idBarber }
}