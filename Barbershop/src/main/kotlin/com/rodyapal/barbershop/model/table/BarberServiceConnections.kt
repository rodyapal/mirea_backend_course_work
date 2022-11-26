package com.rodyapal.barbershop.model.table

import com.rodyapal.barbershop.model.entity.BarberServiceConnection
import org.ktorm.schema.Table
import org.ktorm.schema.int

object BarberServiceConnections : Table<BarberServiceConnection>(
	"barber_service"
) {
	val idBarber = int("id_barber").primaryKey().references(Barbers) { it.barber }
	val idService = int("id_service").primaryKey().references(Services) { it.service }
}