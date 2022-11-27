package com.rodyapal.barbershop.controller.rest

import com.rodyapal.barbershop.model.dao.BarberDao
import com.rodyapal.barbershop.model.dao.ClientDao
import com.rodyapal.barbershop.model.dao.EventDao
import com.rodyapal.barbershop.model.dao.ServiceDao
import com.rodyapal.barbershop.model.entity.Event
import org.ktorm.dsl.eq
import org.springframework.http.HttpStatus
import org.springframework.web.bind.annotation.*
import org.springframework.web.server.ResponseStatusException
import java.sql.Timestamp

@RestController("api/v1")
class EventController(
	private val eventDao: EventDao,
	private val clientDao: ClientDao,
	private val barberDao: BarberDao,
	private val serviceDao: ServiceDao
) {
	@GetMapping("/event")
	fun getEvent(
		@RequestParam(required = false) id: Int?,
		@RequestParam(required = false) barberId: Int?,
		@RequestParam(required = false) clientId: Int?,
		@RequestParam(required = false) serviceId: Int?,
	): List<Event> = when {
		id != null -> eventDao.findOne { id eq it.idEvent }?.let { listOf(it) } ?: emptyList()
		barberId != null -> eventDao.findList { barberId eq it.idBarber }
		clientId != null -> eventDao.findList { clientId eq it.idClient }
		serviceId != null -> eventDao.findList { serviceId eq it.idService }
		else -> eventDao.findAll()
	}

	@PostMapping("/event")
	fun newEvent(
		@RequestParam(name = "barberId") newBarberId: Int,
		@RequestParam(name = "clientId") newClientId: Int,
		@RequestParam(name = "serviceId") newServiceId: Int,
		@RequestParam(name = "visitDateTime") visitDateTimeMillis: Long,
	): Event {
		try {
			val event = Event {
				barber = barberDao.findOne { newBarberId eq it.id }!!
				client = clientDao.findOne { newClientId eq it.id }!!
				service = serviceDao.findOne { newServiceId eq it.id }!!
				visitDateTime = Timestamp(visitDateTimeMillis)
			}
			eventDao.add(event)
			return event
		} catch (exp: Exception) {
			throw ResponseStatusException(
				HttpStatus.BAD_REQUEST,
				"Invalid id params",
				exp
			)
		}
	}

	@PatchMapping("/event")
	@ResponseBody
	fun updateEvent(
		@RequestParam eventId: Int,
		@RequestParam(required = false) newBarberId: Int?,
		@RequestParam(required = false) newClientId: Int?,
		@RequestParam(required = false) newServiceId: Int?,
		@RequestParam(required = false) newVisitDateTime: Long?,
	): Event = try {
		val event = eventDao.findOne { eventId eq it.idEvent }!!
		if (newBarberId != null) event.barber = barberDao.findOne { newBarberId eq it.id }!!
		if (newClientId != null) event.client = clientDao.findOne { newClientId eq it.id }!!
		if (newServiceId != null) event.service = serviceDao.findOne { newServiceId eq it.id }!!
		if (newVisitDateTime != null) event.visitDateTime = Timestamp(newVisitDateTime)
		event.flushChanges()
		event
	} catch (exp: java.lang.Exception) {
		throw ResponseStatusException(
			HttpStatus.BAD_REQUEST,
			"Invalid id params",
			exp
		)
	}

	@DeleteMapping("/event")
	fun deleteEvent(
		@RequestParam eventId: Int
	) {
		eventDao.deleteIf { eventId eq it.idEvent }
	}
}