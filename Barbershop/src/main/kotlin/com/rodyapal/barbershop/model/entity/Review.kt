package com.rodyapal.barbershop.model.entity

import org.ktorm.entity.Entity
import java.sql.Timestamp

interface Review : Entity<Review> {
	companion object : Entity.Factory<Review>()
	val id: Int
	var content: String
	val creationTime: Timestamp
	val author: Client
}