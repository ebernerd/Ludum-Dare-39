local base = love.filesystem.load("resources/items/item.lua")()

return base:extend {
	drawable = Texture("items/cartridge_shock"),
	inInventory = false,
	tooltip = "Shock Cartridge",
	description = "When equipped, you gain the move \"Shock\"!",
	value = 100,
	type = "Attack",
	attackName = "Shock",
	tpd = 20,

	update = function( self )
		self:basicUpdate()
		self.display = "TDP: " ..self.tpd .. "W"
	end
}