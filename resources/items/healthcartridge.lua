local base = love.filesystem.load("resources/items/item.lua")()

return base:extend {
	drawable = Texture("items/cartridge_health"),
	inInventory = false,
	tooltip = "Health Cartridge",
	description = "When equipped, you gain the move \"Revive!\"",
	value = 100,
	type = "Attack",
	tpd = 25,
	update = function( self )
		self:basicUpdate()
		self.display = "TDP: " ..self.tpd .. "W"
	end,
	attackName = "Health"
}