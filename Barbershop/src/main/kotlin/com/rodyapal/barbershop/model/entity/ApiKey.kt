package com.rodyapal.barbershop.model.entity

import org.ktorm.entity.Entity

interface ApiKey : Entity<ApiKey> {
	companion object : Entity.Factory<ApiKey>()
	var key: String
}