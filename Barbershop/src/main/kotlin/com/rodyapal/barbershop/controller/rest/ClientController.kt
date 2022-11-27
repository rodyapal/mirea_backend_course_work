package com.rodyapal.barbershop.controller.rest

import com.rodyapal.barbershop.model.dao.ClientDao
import com.rodyapal.barbershop.model.entity.Client
import org.ktorm.dsl.eq
import org.springframework.http.HttpStatus
import org.springframework.web.bind.annotation.*
import org.springframework.web.server.ResponseStatusException

@RestController("/api/v1")
class ClientController(
	private val clientDao: ClientDao
) {
	@GetMapping("/client")
	@ResponseBody
	fun getClient(
		@RequestParam(required = false) id: Int?,
		@RequestParam(required = false) name: String?,
		@RequestParam(required = false) email: String?,
		@RequestParam(required = false) phone: String?,
	): List<Client> = when {
		id != null -> clientDao.findOne { id eq it.id }?.let { listOf(it) } ?: emptyList()
		name != null -> clientDao.findOne { name eq it.name }?.let { listOf(it) } ?: emptyList()
		phone != null -> clientDao.findOne { phone eq it.phoneNumber }?.let { listOf(it) } ?: emptyList()
		email != null -> clientDao.findOne { email eq it.email}?.let { listOf(it) } ?: emptyList()
		else -> clientDao.findAll()
	}

	@PostMapping("/client")
	@ResponseBody
	fun newClient(
		@RequestParam(name = "name") newName: String,
		@RequestParam(name = "email") newEmail: String,
		@RequestParam(name = "phone") newPhone: String,
		@RequestParam(name = "password") newPassword: String,
	): Client {
		val client = Client {
			name = newName
			email = newEmail
			phoneNumber = newPhone
			password = newPassword
		}
		clientDao.add(client)
		return client
	}

	@PatchMapping("/client")
	@ResponseBody
	fun updateClient(
		@RequestParam clientId: Int,
		@RequestParam(required = false) newName: String?,
		@RequestParam(required = false) newEmail: String?,
		@RequestParam(required = false) newPhone: String?,
		@RequestParam(required = false) newPassword: String?,
	): Client = try {
		val client = clientDao.findOne { it.id eq clientId }!!
		if (newName != null) client.name = newName
		if (newEmail != null) client.email = newEmail
		if (newPhone != null) client.phoneNumber = newPhone
		if (newPassword != null) client.password = newPassword
		client.flushChanges()
		client
	} catch (exp: Exception) {
		throw ResponseStatusException(
			HttpStatus.BAD_REQUEST,
			"Invalid client id",
			exp
		)
	}

	@DeleteMapping("/client")
	fun deleteClient(
		@RequestParam clientId: Int
	) {
		clientDao.deleteIf { clientId eq it.id }
	}
}