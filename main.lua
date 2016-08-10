require "init"
function love.load(arg) 
	--love.graphics.setBackgroundColor(10,10,50)
	state={}
	state.start=require("game/start")
	state.arrange=require("game/arrange")
	state.battle=require("game/battle")
	Gamestate.registerEvents()
	Gamestate.switch(state.arrange)
end

function love.update(dt) 
    loveframes.update(dt)
end

function love.draw()
end

function love.mousepressed(x, y, button) 
    loveframes.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
    loveframes.mousereleased(x, y, button)
end

function love.keypressed(key, isrepeat) 
    loveframes.keypressed(key, isrepeat)
end

function love.keyreleased(key)
    loveframes.keyreleased(key) 
end

function love.textinput(text)
    loveframes.textinput(text)
end


