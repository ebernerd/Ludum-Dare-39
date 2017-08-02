_timers = {}

Timer = class {
	timer = 0,
	time = 0.2,
	mode = "loop",
	active = true,

	globalUpdate = false,

	init = function( self, time, onComplete )
		print( time )
		self.time = time or self.time
		self.onComplete = onComplete or function() end

		if self.globalUpdate then
			table.insert( _timers, self )
		end
	end,
	start = function( self )
		self.active = true
		self.timer = 0
	end,
	stop = function( self )
		self.active = false
	end,
	reset = function( self )
		self.timer = 0
	end,
	getTime = function( self )
		return self.timer
	end,	
	update = function( self, dt )
		if self.active then
			self.timer = self.timer + dt
			if self.timer >= self.time then
				if self.mode == "loop" then
					self.timer = 0
				elseif self.mode == "terminate" then
					self.active = false
					self.timer = 0
				end
				if self.onComplete then self:onComplete() end
				return true
			end
		end
		return false
	end
}