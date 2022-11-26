package com.rodyapal.barbershop.model.table

import com.rodyapal.barbershop.model.entity.LoyaltyCard
import org.ktorm.schema.Table
import org.ktorm.schema.int

object LoyaltyCards : Table<LoyaltyCard>("loyalty_cards") {
	val id = int("id_card").primaryKey().bindTo { it.id }
	val discountPercent = int("discount_percent").bindTo { it.discountPercent }
}