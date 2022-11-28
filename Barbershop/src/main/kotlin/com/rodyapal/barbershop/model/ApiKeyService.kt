package com.rodyapal.barbershop.model

import com.rodyapal.barbershop.model.entity.ApiKey
import com.rodyapal.barbershop.model.table.ApiKeys
import org.ktorm.database.Database
import org.ktorm.dsl.eq
import org.ktorm.entity.add
import org.ktorm.entity.any
import org.ktorm.entity.sequenceOf
import org.springframework.stereotype.Service

@Service
class ApiKeyService(
	private val database: Database
) {
	private val Database.apiKeys get() = this.sequenceOf(ApiKeys)

	fun saveKey(newKey: String) {
		database.apiKeys.add(
			ApiKey {
				key = newKey
			}
		)
	}

	fun keyExists(keyToCheck: String): Boolean = database.apiKeys.any { keyToCheck eq ApiKeys.key }
}