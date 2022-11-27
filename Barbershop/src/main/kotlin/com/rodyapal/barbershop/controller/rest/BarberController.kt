package com.rodyapal.barbershop.controller.rest

import com.rodyapal.barbershop.model.dao.BSConnectionDao
import com.rodyapal.barbershop.model.dao.BarberDao
import com.rodyapal.barbershop.model.dao.ServiceDao
import com.rodyapal.barbershop.model.entity.Barber
import com.rodyapal.barbershop.model.entity.BarberServiceConnection
import org.ktorm.dsl.eq
import org.springframework.http.HttpStatus
import org.springframework.web.bind.annotation.*
import org.springframework.web.server.ResponseStatusException

@RestController
class BarberController(
	private val barberDao: BarberDao,
	private val bsConnectionDao: BSConnectionDao,
	private val serviceDao: ServiceDao
) {
	@GetMapping("/api/v1/barber")
	@ResponseBody
	fun getBarber(
		@RequestParam(required = false) id: Int?,
		@RequestParam(required = false) name: String?,
	): List<Barber> = when {
		id != null -> barberDao.findOne { id eq it.id }?.let { listOf(it) } ?: emptyList()
		name != null -> barberDao.findOne { name eq it.name }?.let { listOf(it) } ?: emptyList()
		else -> barberDao.findAll()
	}

	@PostMapping("/api/v1/barber")
	@ResponseBody
	fun newBarber(
		@RequestParam(name = "name") newName: String,
		@RequestParam(name = "rating") newRating: Float,
		@RequestParam(required = false) serviceIds: List<Int>?
	): Barber {
		val barber = Barber {
			name = newName
			rating = newRating
		}
		barberDao.add(barber)
		serviceIds?.forEach { serviceId ->
			val connection = BarberServiceConnection {
				this.barber = barber
				this.service = serviceDao.findOne { serviceId eq it.id }!!
			}
			bsConnectionDao.add(connection)
		}
		return barber
	}

	@PatchMapping("/api/v1/barber")
	@ResponseBody
	fun updateBarber(
		@RequestParam barberId: Int,
		@RequestParam(required = false) newName: String?,
		@RequestParam(required = false) newRating: Float?
	): Barber = try {
		val barber = barberDao.findOne { it.id eq barberId }!!
		if (newName != null) barber.name = newName
		if (newRating != null) barber.rating = newRating
		barber.flushChanges()
		barber
	} catch (exp: Exception) {
		throw ResponseStatusException(
			HttpStatus.BAD_REQUEST,
			"Invalid barber id",
			exp
		)
	}

	@DeleteMapping("/api/v1/barber")
	fun deleteBarber(
		@RequestParam barberId: Int
	) {
		barberDao.deleteIf { barberId eq it.id }
	}
}