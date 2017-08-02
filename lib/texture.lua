Texture = class {
	image = "",
	filter = "nearest",
	type = "Texture",
	sx = 1,
	sy = 1,
	init = function( self, path )
		local path = "resources/images/" .. (path or "noTexture") .. ".png"
		if not love.filesystem.isFile( path ) then
			path = "resources/images/noTexture.png"
		end
		self.image = love.graphics.newImage( path )
		self.image:setFilter( self.filter, self.filter )
	end,
	getSize = function( self )
		return self.image:getWidth()*self.sx, self.image:getHeight()*self.sy
	end,
	scale = function( self, sx, sy )
		if not sx and not sy then
			return self.sx, self.sy
		else
			self.sx = sx or self.sx
			self.sy = sy or self.sy
		end
		return self
	end,
	draw = function( self, x, y )
		love.graphics.draw( self.image, x, y, 0, self.sx, self.sy )
	end
}