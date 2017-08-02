local base = love.filesystem.load("resources/items/item.lua")()

return base:extend {
	drawable = Texture("items/cartridge_strength"),
	inInventory = false,
	tooltip = "Strength Cartridge",
	description = "When equipped, you gain the move \"Strength\"!",
	value = 100,
	type = "Attack",
	attackName = "Strength",
	tpd = 5,
	rarity = 0,
	update = function( self )
		self:basicUpdate()
		self.display = "TDP: " ..self.tpd .. "W"
	end
}