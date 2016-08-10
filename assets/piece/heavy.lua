local heavy=Class("heavy",Base)

function heavy:initialize(board,x,y,side)
	-- 王，1，民，2，矛，3，弩，4，轻，5，重，6，投石车，7.大象 8. 龙 9 王
	self.board=board
	self.type=5*side
	self.posX=x
	self.posY=y
	self.name="heavy horse"
	self.range=3
	self.tier=3
	self.sizeX=self.board.size/80
	self.sizeY=self.board.size/80
	self.sizeR=self.board.size/1.5
	self.img = love.graphics.newImage("img/heavy_horse.png")
	self.board.grid[self.posX][self.posY].piece=self
end

return heavy