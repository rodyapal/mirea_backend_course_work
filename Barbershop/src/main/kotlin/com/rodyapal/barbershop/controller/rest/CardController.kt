package com.rodyapal.barbershop.controller.rest

import com.rodyapal.barbershop.model.dao.LoyaltyCardDao
import com.rodyapal.barbershop.model.entity.LoyaltyCard
import org.ktorm.dsl.eq
import org.springframework.http.HttpStatus
import org.springframework.web.bind.annotation.*
import org.springframework.web.server.ResponseStatusException

@RestController("/api/v1")
class CardController(
	private val cardDao: LoyaltyCardDao
) {
	@GetMapping("/card")
	@ResponseBody
	fun getCards(
		@RequestParam(required = false) cardId: Int?
	): List<LoyaltyCard> = if (cardId != null) cardDao.findOne { cardId eq it.id }?.let { listOf(it) }
		?: emptyList() else cardDao.findAll()

	@PostMapping("/card")
	@ResponseBody
	fun newCard(
		@RequestParam discount: Int
	): LoyaltyCard {
		val card = LoyaltyCard {
			discountPercent = discount
		}
		cardDao.add(card)
		return card
	}

	@PatchMapping("/card")
	@ResponseBody
	fun updateCard(
		@RequestParam cardId: Int,
		@RequestParam discount: Int
	): LoyaltyCard = try {
		val card = cardDao.findOne { cardId eq it.id }!!
		card.discountPercent = discount
		card.flushChanges()
		card
	} catch (exp: Exception) {
		throw ResponseStatusException(
			HttpStatus.BAD_REQUEST,
			"Invalid card id",
			exp
		)
	}

	@DeleteMapping("/card")
	fun deleteCard(
		@RequestParam cardId: Int
	) {
		cardDao.deleteIf { cardId eq it.id }
	}
}