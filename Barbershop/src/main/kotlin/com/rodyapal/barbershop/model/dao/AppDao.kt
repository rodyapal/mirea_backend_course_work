package com.rodyapal.barbershop.model.dao

import org.ktorm.database.Database
import org.ktorm.entity.*
import org.ktorm.schema.ColumnDeclaring
import org.ktorm.schema.Table
import org.springframework.beans.factory.annotation.Autowired

abstract class AppDao<E: Entity<E>, T : Table<E>>(
	private val table: T,
	@Autowired private val database: Database
) {
	open fun add(entity: E): Int = database.sequenceOf(table).add(entity)

	open fun update(entity: E): Int = database.sequenceOf(table).update(entity)

	open fun deleteIf(predicate: (T) -> ColumnDeclaring<Boolean>): Int = database.sequenceOf(table).removeIf(predicate)

	open fun allMatched(predicate: (T) -> ColumnDeclaring<Boolean>): Boolean = database.sequenceOf(table).all(predicate)

	open fun anyMatch(predicate: (T) -> ColumnDeclaring<Boolean>): Boolean = database.sequenceOf(table).any(predicate)

	open fun noneMatched(predicate: (T) -> ColumnDeclaring<Boolean>): Boolean = database.sequenceOf(table).none(predicate)

	open fun count(): Int = database.sequenceOf(table).count()

	open fun count(predicate: (T) -> ColumnDeclaring<Boolean>): Int = database.sequenceOf(table).count(predicate)

	open fun findOne(predicate: (T) -> ColumnDeclaring<Boolean>): E? = database.sequenceOf(table).find(predicate)

	open fun findList(predicate: (T) -> ColumnDeclaring<Boolean>): List<E> =
		database.sequenceOf(table).filter(predicate).toList()

	open fun findAll(): List<E> = database.sequenceOf(table).toList()
}