package com.rodyapal.barbershop.model.entity

import org.ktorm.entity.Entity

interface LoyaltyCard : Entity<LoyaltyCard> {
	companion object : Entity.Factory<LoyaltyCard>()
	val id: Int
	var discountPercent: Int
}