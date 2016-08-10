local dragon=Class("dragon",Base)

function dragon:initialize(board,x,y,side)
	-- 王，1，民，2，矛，3，弩，4，轻，5，重，6，投石车，7.大象 8. 龙 9 王
	self.board=board
	self.type=8*side
	self.posX=x
	self.posY=y
	self.name="dragon"
	self.range=7
	self.tier=4
	self.sizeX=self.board.size/80
	self.sizeY=self.board.size/80
	self.sizeR=self.board.size/1.5
	self.img = love.graphics.newImage("img/dragon.png")
	self.board.grid[self.posX][self.posY].piece=self
end

return dragon