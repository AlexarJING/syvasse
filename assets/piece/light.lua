local light=Class("light",Base)

function light:initialize(board,x,y,side)
	-- 王，1，民，2，矛，3，弩，4，轻，5，重，6，投石车，7.大象 8. 龙 9 王
	self.board=board
	self.type=4*side
	self.posX=x
	self.posY=y
	self.name="light horse"
	self.range=5
	self.tier=2
	self.sizeX=self.board.size/80
	self.sizeY=self.board.size/80
	self.sizeR=self.board.size/1.5
	self.img = love.graphics.newImage("img/light_horse.png")
	self.board.grid[self.posX][self.posY].piece=self

end
return light