package com.rodyapal.barbershop.model.table

import com.rodyapal.barbershop.model.entity.ApiKey
import org.ktorm.schema.Table
import org.ktorm.schema.varchar

object ApiKeys : Table<ApiKey>("api_keys") {
	val key = varchar("key").primaryKey().bindTo { it.key }
}