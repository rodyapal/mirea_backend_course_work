package com.rodyapal.barbershop.controller.rest

import com.rodyapal.barbershop.model.dao.ClientDao
import com.rodyapal.barbershop.model.dao.ReviewDao
import com.rodyapal.barbershop.model.entity.Review
import org.ktorm.dsl.eq
import org.springframework.http.HttpStatus
import org.springframework.web.bind.annotation.*
import org.springframework.web.server.ResponseStatusException
import java.sql.Timestamp
import java.time.Instant

@RestController("api/v1")
class ReviewController(
	private val reviewDao: ReviewDao,
	private val clientDao: ClientDao
) {
	@GetMapping("/review")
	@ResponseBody
	fun getReview(
		@RequestParam(required = false) id: Int?,
		@RequestParam(required = false) authorId: Int?,
	): List<Review> = when {
		id != null -> reviewDao.findOne { id eq it.id }?.let { listOf(it) } ?: emptyList()
		authorId != null -> reviewDao.findOne { authorId eq it.idClient }?.let { listOf(it) } ?: emptyList()
		else -> reviewDao.findAll()
	}

	@PostMapping("/review")
	@ResponseBody
	fun newReview(
		@RequestParam(name = "authorId") authorId: Int,
		@RequestParam(name = "content") reviewContent: String,
	): Review {
		try {
			val review = Review {
				author = clientDao.findOne { authorId eq it.id }!!
				content = reviewContent
				creationTime = Timestamp.from(Instant.now())
			}
			reviewDao.add(review)
			return review
		} catch (exp: Exception) {
			throw ResponseStatusException(
				HttpStatus.BAD_REQUEST,
				"Invalid id params",
				exp
			)
		}
	}

	@PatchMapping("/review")
	@ResponseBody
	fun updateReview(
		@RequestParam reviewId: Int,
		@RequestParam newContent: String,
	): Review = try {
		val review = reviewDao.findOne { reviewId eq it.id }!!
		review.content = newContent
		review.flushChanges()
		review
	} catch (exp: Exception) {
		throw ResponseStatusException(
			HttpStatus.BAD_REQUEST,
			"Invalid review id",
			exp
		)
	}

	@DeleteMapping("/review")
	fun deleteReview(
		@RequestParam reviewId: Int
	) {
		reviewDao.deleteIf { reviewId eq it.id }
	}
}