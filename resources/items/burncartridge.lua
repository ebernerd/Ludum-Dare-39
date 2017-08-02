local base = love.filesystem.load("resources/items/item.lua")()

return base:extend {
	drawable = Texture("items/cartridge_burn"),
	inInventory = false,
	tooltip = "Burn Cartridge",
	description = "When equipped, you gain the move \"Burn\"!",
	value = 100,
	type = "Attack",
	attackName = "Burn",
	tpd = 10,

	update = function( self )
		self:basicUpdate()
		self.display = "TDP: " ..self.tpd .. "W"
	end
}