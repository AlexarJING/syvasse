local bow=Class("bow",Base)

function bow:initialize(board,x,y,side)
	self.board=board
	self.type=3*side
	self.posX=x
	self.posY=y
	self.name="crossbows"
	self.range=1
	self.attackRange=2
	self.tier=2
	self.sizeX=self.board.size/80
	self.sizeY=self.board.size/80
	self.img = love.graphics.newImage("img/crossbows.png")
	self.sizeR=self.board.size/1.5
	self.board.grid[self.posX][self.posY].piece=self
end

return bow