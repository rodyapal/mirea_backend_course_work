package com.rodyapal.barbershop.model.entity

import org.ktorm.entity.Entity

interface BarberServiceConnection : Entity<BarberServiceConnection> {
	companion object : Entity.Factory<BarberServiceConnection>()
	var barber: Barber
	var service: Service
}