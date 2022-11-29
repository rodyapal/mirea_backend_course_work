package com.rodyapal.barbershop.confid

import com.rodyapal.barbershop.model.ApiKeyService
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.security.authorization.AuthorizationDecision
import org.springframework.security.config.annotation.web.builders.HttpSecurity
import org.springframework.security.web.SecurityFilterChain

private const val HEADER_API_KEY = "apiKey"

@Configuration
class SecurityConfig {
	@Autowired
	private lateinit var apiKeyService: ApiKeyService

	@Bean
	fun web(httpSecurity: HttpSecurity): SecurityFilterChain {
		httpSecurity.authorizeHttpRequests {
			it.requestMatchers("/api/**").access { _, context ->
				val apiKey = context.request.getHeader(HEADER_API_KEY) ?: return@access AuthorizationDecision(false)
				AuthorizationDecision(
					apiKeyService.keyExists(apiKey)
				)
			}.anyRequest().permitAll()
		}
		return httpSecurity.build()
	}
}