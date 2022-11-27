package com.rodyapal.barbershop.controller.rest

import com.rodyapal.barbershop.model.dao.BSConnectionDao
import com.rodyapal.barbershop.model.dao.BarberDao
import com.rodyapal.barbershop.model.dao.ServiceDao
import com.rodyapal.barbershop.model.entity.BarberServiceConnection
import org.ktorm.dsl.and
import org.ktorm.dsl.eq
import org.springframework.http.HttpStatus
import org.springframework.web.bind.annotation.*
import org.springframework.web.server.ResponseStatusException

@RestController
class BSConnectionController(
	private val bsConnectionDao: BSConnectionDao,
	private val barberDao: BarberDao,
	private val serviceDao: ServiceDao
) {
	@GetMapping("/api/v1/bs")
	@ResponseBody
	fun getConnection(
		@RequestParam(required = false) idBarber: Int?,
		@RequestParam(required = false) idService: Int?,
	): List<BarberServiceConnection> = when {
		idBarber != null && idService != null -> bsConnectionDao.findOne { (idBarber eq it.idBarber) and (idService eq it.idService) }?.let { listOf(it) } ?: emptyList()
		idBarber != null -> bsConnectionDao.findList { idBarber eq it.idBarber }
		idService != null -> bsConnectionDao.findList { idService eq it.idService }
		else -> bsConnectionDao.findAll()
	}

	@PostMapping("/api/v1/bs")
	@ResponseBody
	fun newConnection(
		@RequestParam idBarber: Int,
		@RequestParam idService: Int,
	): BarberServiceConnection = try {
		val connection = BarberServiceConnection {
			barber = barberDao.findOne { idBarber eq it.id }!!
			service = serviceDao.findOne { idService eq it.id }!!
		}
		bsConnectionDao.add(connection)
		connection
	} catch (exp: Exception) {
		throw ResponseStatusException(
			HttpStatus.BAD_REQUEST,
			"Invalid service id",
			exp
		)
	}

	@DeleteMapping("/api/v1/bs")
	@ResponseBody
	fun deleteConnection(
		@RequestParam idBarber: Int,
		@RequestParam idService: Int,
	) {
		bsConnectionDao.deleteIf { (idBarber eq it.idBarber) and (idService eq it.idService) }
	}
}