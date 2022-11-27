package com.rodyapal.barbershop.model.entity

import org.ktorm.dsl.eq
import org.ktorm.entity.Entity
import org.ktorm.entity.filter
import org.ktorm.entity.toList

interface Barber : Entity<Barber> {
	companion object : Entity.Factory<Barber>()
	val id: Int
	var name: String
	var rating: Float
}