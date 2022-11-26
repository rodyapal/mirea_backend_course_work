package com.rodyapal.barbershop.confid

import org.ktorm.database.Database
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import javax.sql.DataSource

@Configuration
class AppConfig {

	@Bean
	@Autowired
	fun database(dataSource: DataSource): Database = Database.connectWithSpringSupport(dataSource)
}