package com.rodyapal.barbershop.model.dao

import com.rodyapal.barbershop.model.entity.*
import com.rodyapal.barbershop.model.table.*
import org.ktorm.database.Database
import org.springframework.stereotype.Component

@Component
class BarberDao(database: Database) : AppDao<Barber, Barbers>(Barbers, database)

@Component
class ServiceDao(database: Database) : AppDao<Service, Services>(Services, database)

@Component
class BSConnectionDao(database: Database) : AppDao<BarberServiceConnection, BarberServiceConnections>(BarberServiceConnections, database)

@Component
class EventDao(database: Database) : AppDao<Event, Events>(Events, database)

@Component
class EventLogDao(database: Database) : AppDao<Event, EventLogs>(EventLogs, database)

@Component
class ClientDao(database: Database) : AppDao<Client, Clients>(Clients, database)

@Component
class ReviewDao(database: Database) : AppDao<Review, Reviews>(Reviews, database)

@Component
class LoyaltyCardDao(database: Database) : AppDao<LoyaltyCard, LoyaltyCards>(LoyaltyCards, database)