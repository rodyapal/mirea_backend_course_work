package com.rodyapal.barbershop.model

import com.rodyapal.barbershop.model.table.*
import org.ktorm.database.Database
import org.ktorm.entity.sequenceOf

val Database.barbers get() = sequenceOf(Barbers)
val Database.services get() = sequenceOf(Services)
val Database.BSConnections get() = sequenceOf(BarberServiceConnections)
val Database.loyaltyCards get() = sequenceOf(LoyaltyCards)
val Database.reviews get() = sequenceOf(Reviews)
val Database.clients get() = sequenceOf(Clients)
val Database.events get() = sequenceOf(Events)
val Database.eventLogs get() = sequenceOf(EventLogs)