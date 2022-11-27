package com.rodyapal.barbershop.model.entity

import org.ktorm.entity.Entity

interface Client : Entity<Client> {
	companion object : Entity.Factory<Client>()
	val id: Int
	var name: String
	var email: String
	var password: String
	var phoneNumber: String
	val card: LoyaltyCard
}