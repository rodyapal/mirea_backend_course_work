package com.rodyapal.barbershop.model.table

import com.rodyapal.barbershop.model.entity.Barber
import org.ktorm.schema.Table
import org.ktorm.schema.float
import org.ktorm.schema.int
import org.ktorm.schema.varchar

object Barbers : Table<Barber>("barbers") {
	val id = int("id_barber").primaryKey().bindTo { it.id }
	val name = varchar("name").bindTo { it.name }
	val rating = float("rating").bindTo { it.rating }
}