package com.rodyapal.barbershop.model.table

import com.rodyapal.barbershop.model.entity.Client
import org.ktorm.schema.Table
import org.ktorm.schema.int
import org.ktorm.schema.varchar

object Clients : Table<Client>("clients") {
	val id = int("id_client").primaryKey().bindTo { it.id }
	val name = varchar("name").bindTo { it.name }
	val email = varchar("email").bindTo { it.email }
	val password = varchar("password").bindTo { it.password }
	val phoneNumber = varchar("phone_number").bindTo { it.phoneNumber }
	val idCard = int("id_card").references(LoyaltyCards) { it.card }
}