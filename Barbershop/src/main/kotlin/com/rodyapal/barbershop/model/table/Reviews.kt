package com.rodyapal.barbershop.model.table

import com.rodyapal.barbershop.model.entity.Review
import org.ktorm.schema.Table
import org.ktorm.schema.int
import org.ktorm.schema.jdbcTimestamp
import org.ktorm.schema.text

object Reviews : Table<Review>("reviews") {
	val id = int("id_review").primaryKey().bindTo { it.id }
	val idClient = int("id_client").primaryKey().references(Clients) { it.author }
	val content = text("content").bindTo { it.content }
	val creationTime = jdbcTimestamp("creation_time").bindTo { it.creationTime }
}