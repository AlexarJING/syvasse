local elephant=Class("elephant",Base)

function elephant:initialize(board,x,y,side)
	-- 王，1，民，2，矛，3，弩，4，轻，5，重，6，投石车，7.大象 8. 龙 9 王
	self.board=board
	self.type=7*side
	self.posX=x
	self.posY=y
	self.name="elephant"
	self.range=3
	self.tier=3
	self.sizeX=self.board.size/80
	self.sizeY=self.board.size/80
	self.sizeR=self.board.size/1.5
	self.img = love.graphics.newImage("img/elephant.png")
	self.board.grid[self.posX][self.posY].piece=self
end

return elephant