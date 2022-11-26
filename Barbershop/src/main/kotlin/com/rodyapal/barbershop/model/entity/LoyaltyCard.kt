package com.rodyapal.barbershop.model.entity

import org.ktorm.entity.Entity

interface LoyaltyCard : Entity<LoyaltyCard> {
	companion object : Entity.Factory<Service>()
	val id: Int
	val discountPercent: Int
}