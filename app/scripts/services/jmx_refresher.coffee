'use strict'

angular.module('jmxRtMonApp').factory('JmxRefresher', ($timeout, $rootScope, ConfigService) ->
	self = {}

	self.connected = false
	self.url = ->
		return ConfigService.get(ConfigService.URL_KEY)

	self.beans = []
	self.update_interval = ->
		ConfigService.get(ConfigService.REFRESH_PERIOD_KEY)

	self.fetch_data = ->
		jQuery.getJSON("#{self.url()}?callback=?", (result) ->
			return unless result
			self.beans = result['beans']
			$rootScope.$broadcast("JmxRefresher.data_updated", result.beans)
		)

	self.connect = ->
		return if self.connected # We're already connected
		self.connected = true

		# Infinitely poll for new data
		poll = ->
			self.fetch_data()

			$timeout((->
				poll() if self.connected
			), self.update_interval())
		poll()

	self.disconnect = ->
		self.connected = false
		console.log "DC"

	return self
)