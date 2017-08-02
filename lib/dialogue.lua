_dialogues = {}

Dialogue = class {
	dialogues = {
		"This is a dialogue! There can be a lot of text! I wanna see how far I can take this and if the line will actually wrap",
		"You can print out text here!",
		"You can also have options:",
		{
			["Option1"] = {},
			["Option2"] = {}
		}
	},
	letterTimer = Timer(0.03),
	letterSounds = {
		love.audio.newSource("resources/sounds/text1.mp3"),
		love.audio.newSource("resources/sounds/text2.mp3"),
		love.audio.newSource("resources/sounds/text3.mp3"),
	},
	lastSound = 1,

	font = love.graphics.newFont( "resources/fonts/Kubasta.ttf", 35 ),

	active = false,
	doneWithCurrentLine = false,
	pos = 1,


	init = function ( self, dialogues )
		self.dialogues = dialogues or self.dialogues
		self.currentLine = 1
		self.currentContainer = self.dialogues

		self.text = self.currentContainer[self.currentLine]

		table.insert( _dialogues, self )
	end,
	start = function( self )
		self.active = true
		doneWithCurrentLine = false
	end,
	update = function( self, dt )
		if self.letterTimer:update( dt ) then
			if self.pos + 1 < #self.currentLine then
				self.pos = self.pos + 1
				if self.currentLine:sub(self.pos, self.pos) ~= " " then
					--self.letterSounds[self.lastSound]:stop()
					--self.lastSound = love.math.random(1,3)
					--self.letterSounds[self.lastSound]:play()
				end
			else
				self.doneWithCurrentLine = true
			end
		end
		if love.keyboard.isDown(" ") and self.doneWithCurrentLine then
			self.currentLine = self.currentLine + 1
			if type(self.currentLine) == "table" then
				self.options = self.currentLine
			else
				self.options = ""
			end
		end
	end,
	draw = function( self )
		if self.active then
			love.graphics.setColor( 25, 25, 25 )
			love.graphics.rectangle("fill", 0, love.graphics.getHeight()*.75, love.graphics.getWidth(), love.graphics.getHeight()/4)
			love.graphics.setColor( 255, 255, 255 )
		end
		if #self.options > 0 then

		else
			love.graphics.setFont( self.font )
			love.graphics.printf(self.currentContainer[self.currentLine]:sub(1, self.pos+1), 10, love.graphics.getHeight()*.75 + 10, love.graphics.getWidth()-20, "left")
		end
	end
}