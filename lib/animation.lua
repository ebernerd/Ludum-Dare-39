Animation = class {
	images = {},
	imageIndex = 1,
	time = 0.2,
	timer = "",

	active = true,

	init = function( self, time, images )
		self.time = time or self.time
		self.images = images or self.images

		local imgs = {}
		for i, v in pairs( self.images ) do
			if v.type and v.type == "Texture" then
				table.insert(imgs, v)
			else
				table.insert(imgs, Texture(v))
			end
		end
		self.images = imgs

		self.timer = Timer( self.time )
		self.timer.globalUpdate = false
	end,
	scale = function( self )
		return self.images[ self.imageIndex ]:scale()
	end,
	draw = function( self, x, y )
		self.images[self.imageIndex]:draw( x, y )
	end,	
	update = function( self, dt )
		if self.timer:update( dt ) then
			self.imageIndex = self.imageIndex + 1
			if self.imageIndex > #self.images then
				self.imageIndex = 1
			end
		end
	end
}