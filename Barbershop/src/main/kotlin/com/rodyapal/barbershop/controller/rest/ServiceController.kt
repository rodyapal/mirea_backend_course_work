package com.rodyapal.barbershop.controller.rest

import com.rodyapal.barbershop.model.dao.BSConnectionDao
import com.rodyapal.barbershop.model.dao.BarberDao
import com.rodyapal.barbershop.model.dao.ServiceDao
import com.rodyapal.barbershop.model.entity.BarberServiceConnection
import com.rodyapal.barbershop.model.entity.Service
import org.ktorm.dsl.and
import org.ktorm.dsl.eq
import org.ktorm.dsl.greater
import org.ktorm.dsl.less
import org.springframework.http.HttpStatus
import org.springframework.web.bind.annotation.*
import org.springframework.web.server.ResponseStatusException

@RestController("/api/v1")
class ServiceController(
	private val serviceDao: ServiceDao,
	private val barberDao: BarberDao,
	private val bsConnectionDao: BSConnectionDao,
) {
	@GetMapping("/service")
	@ResponseBody
	fun getService(
		@RequestParam(required = false) id: Int?,
		@RequestParam(required = false) name: String?,
		@RequestParam(required = false) maxPrice: Int?,
		@RequestParam(required = false) minPrice: Int?,
	): List<Service> = when {
		id != null -> serviceDao.findOne { id eq it.id }?.let { listOf(it) } ?: emptyList()
		name != null -> serviceDao.findOne { name eq it.name }?.let { listOf(it) } ?: emptyList()
		maxPrice != null && minPrice != null -> serviceDao.findList { (minPrice less it.price) and (maxPrice greater it.price )}
		maxPrice != null -> serviceDao.findList { maxPrice greater it.price }
		minPrice != null -> serviceDao.findList { minPrice less it.price }
		else -> serviceDao.findAll()
	}

	@PostMapping("/service")
	@ResponseBody
	fun newService(
		@RequestParam(name = "name") newName: String,
		@RequestParam(name = "description") newDescription: String,
		@RequestParam(name = "duration") newDuration: Int,
		@RequestParam(name = "price") newPrice: Int,
		@RequestParam(required = false) barberIds: List<Int>?
	): Service {
		val service = Service {
			name = newName
			description = newDescription
			duration = newDuration
			price = newPrice
		}
		serviceDao.add(service)
		barberIds?.forEach { barberId ->
			val connection = BarberServiceConnection {
				this.service = service
				this.barber = barberDao.findOne { barberId eq it.id }!!
			}
			bsConnectionDao.add(connection)
		}
		return service
	}

	@PatchMapping("/service")
	@ResponseBody
	fun updateService(
		@RequestParam serviceId: Int,
		@RequestParam(required = false) newName: String?,
		@RequestParam(required = false) newDuration: Int?,
		@RequestParam(required = false) newPrice: Int?,
	): Service = try {
		val service = serviceDao.findOne { serviceId eq it.id }!!
		if (newName != null) service.name = newName
		if (newDuration != null) service.duration = newDuration
		if (newPrice != null) service.price = newPrice
		service.flushChanges()
		service
	} catch (exp: Exception) {
		throw ResponseStatusException(
			HttpStatus.BAD_REQUEST,
			"Invalid service id",
			exp
		)
	}

	@DeleteMapping("/service")
	fun deleteService(
		@RequestParam serviceId: Int,
	) {
		serviceDao.deleteIf { serviceId eq it.id }
	}
}