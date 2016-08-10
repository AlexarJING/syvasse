local piece=Class("piece")

function piece:initialize()


end


function piece:update()
	
end

function piece:draw()
	local x,y=self.board:getGridPos(self.posX,self.posY)
	local alpha
	if self.selected then
		alpha=255
	else
		alpha=200
	end
	if self.type>0 then
		love.graphics.setColor(255, 255, 255,alpha)
		love.graphics.circle("fill", x, y, self.sizeR)
		love.graphics.setColor(0,0,0, alpha)
		--love.graphics.printf(self.name, x-5, y-5)
		love.graphics.draw(self.img, x, y, 0, self.sizeX, self.sizeY, 60, 45)
		love.graphics.circle("line", x, y, self.sizeR)
		love.graphics.setColor(255, 0,0)
		love.graphics.print(self.board:calcDefence(self), x+5, y+5)
	else
		love.graphics.setColor(0,0,0,alpha)
		love.graphics.circle("fill", x, y, self.sizeR)
		love.graphics.setColor(255,255,255, alpha)
		--love.graphics.print(self.name, x-5, y-5 )
		love.graphics.draw(self.img, x, y, 0, self.sizeX, self.sizeY, 60, 45)
		love.graphics.circle("line", x, y, self.sizeR) 
		love.graphics.setColor(255, 0,0)
		love.graphics.print(self.board:calcDefence(self), x+10, y+5) 
	end
	love.graphics.setColor(255, 255, 255,255)
end


return piece