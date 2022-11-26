package com.rodyapal.barbershop.model

import com.rodyapal.barbershop.model.table.*
import org.ktorm.database.Database
import org.ktorm.entity.sequenceOf

const val DB_URL = "jdbc:mysql://localhost:3306/appDb"
const val DB_USER = "appUser"
const val DB_PASS = "password"

object AppDatabase {
	private val self = Database.connect(
		DB_URL,
		user = DB_USER,
		password = DB_PASS
	)

	val barbers get() = self.sequenceOf(Barbers)
	val services get() = self.sequenceOf(Services)
	val BSConnections get() = self.sequenceOf(BarberServiceConnections)
	val loyaltyCards get() = self.sequenceOf(LoyaltyCards)
	val reviews get() = self.sequenceOf(Reviews)
	val clients get() = self.sequenceOf(Clients)
	val events get() = self.sequenceOf(Events)
	val eventLogs get() = self.sequenceOf(EventLogs)
}