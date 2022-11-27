package com.rodyapal.barbershop.model.entity

import org.ktorm.entity.Entity

interface Service : Entity<Service> {
	companion object : Entity.Factory<Service>()
	val id: Int
	var name: String
	var description: String
	var duration: Int
	var price: Int
}