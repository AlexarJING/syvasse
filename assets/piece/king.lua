local king=Class("king",Base)

function king:initialize(board,x,y,side)
	-- 王，1，民，2，矛，3，弩，4，轻，5，重，6，投石车，7.大象 8. 龙 9 王
	self.board=board
	self.type=9*side
	self.posX=x
	self.posY=y
	self.name="king"
	self.range=1
	self.tier=1
	self.sizeX=self.board.size/80
	self.sizeY=self.board.size/80
	self.sizeR=self.board.size/1.5
	self.img = love.graphics.newImage("img/king.png")
	self.board.grid[self.posX][self.posY].piece=self
end

return king