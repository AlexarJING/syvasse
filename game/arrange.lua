local scene = Gamestate.new()
local isUpper=false
local s="terrain"
--local s="piece"
local textTerrain=[[
hold 1 and left click to set a wood tile
hold 2 and left click to set a mountain tile
hold 3 and left click to set a water tile
right click to set a grass tile
press enter to submit
]]
local textPiece=[[
hold 1 to set a rabble
hold 2 to set a king
hold 3 to set a bowman
hold 4 to set a spearman
hold 5 to set a lightHorse
hold 6 to set a heavyHorse
hold 7 to set a trebuchet
hold 8 to set a elephant
hold 9 to set a dragon
press enter to submit or random set
]]
local terrainLimit={
	wood=0,
	mountain=0,
	water=0
}
local pieceLimit={
	rabble=6,
	king=1,
	bowman=2,
	spearman=2,
	lightHorse=2,
	heavyHorse=2,
	trebuchet=2,
	elephant=2,
	dragon=1
}
local side=1
--side==1 for up
function scene:init()

end 

function scene:enter()
	self.board=Board:new()
	self:generateRandom(-1)
end


function scene:draw()
	self.board:draw()
	love.graphics.setColor(255,0,0,150)
	if side==1 then
		for x=1,11 do
			for y=6,11 do
				self.board:drawCell(x,y,"fill")
			end
		end
	else
		for x=1,11 do
			for y=1,6 do
				self.board:drawCell(x,y,"fill")
			end
		end
	end
	love.graphics.setColor(255,255,255)
	if s=="terrain" then
		love.graphics.print(textTerrain,520,100)
		local t=""
		for k,v in pairs(terrainLimit) do
			t=t..k .. "  :" .. v.."\n"
		end
		love.graphics.print(t,520,300)
	else
		love.graphics.print(textPiece,520,100)
		local t=""
		for k,v in pairs(pieceLimit) do
			t=t..k .. "  :" .. v.."\n"
		end
		love.graphics.print(t,520,300)
	end
end


function scene:update(dt)
	self.board:update()
end 

function scene:leave()


end


function scene:keypressed(key)
	if key=="return" then
		if s=="terrain" then 
			for k,v in pairs(terrainLimit) do
				if v~=0 then
					print("not finished yet")
					return
				end
			end
			s="piece"
			return 
		elseif s=="piece" then
			for k,v in pairs(pieceLimit) do
				if v~=0 then
					self:generateRandom(1)
					Gamestate.switch(state.battle,self.board)
					return
				end
			end
			Gamestate.switch(state.battle,self.board)
			--generate random map
			--pass the grid to the game
		end
	end
end


function scene:addTerrain(key)
	--0 草 1 林 2 山 3 水 4 堡
	-- 1，民，2，矛，3，弩，4，轻，5，重，6，投石车，7.大象 8. 龙 9.王
	if key=="r" then
		local t=self.board.grid[self.board.sx][self.board.sy].terrain
		if t==1 then
			terrainLimit.wood=terrainLimit.wood+1
		elseif t==2 then
			terrainLimit.mountain=terrainLimit.mountain+1
		elseif t==3 then
			terrainLimit.water=terrainLimit.water+1
		end
		self.board.grid[self.board.sx][self.board.sy].terrain=0
		return
	end
	local p=self.board.grid[self.board.sx][self.board.sy]
	if p.terrain~=0 then return end
	if love.keyboard.isDown("1") and terrainLimit.wood>0 then
		p.terrain=1
		terrainLimit.wood=terrainLimit.wood-1
	elseif love.keyboard.isDown("2") and terrainLimit.mountain>0 then
		p.terrain=2
		terrainLimit.mountain=terrainLimit.mountain-1
	elseif love.keyboard.isDown("3") and terrainLimit.water>0 then
		p.terrain=3
		terrainLimit.water=terrainLimit.water-1
	end

end


function scene:addPiece(key)
	--0 草 1 林 2 山 3 水 4 堡
	-- 1，民，2，矛，3，弩，4，轻，5，重，6，投石车，7.大象 8. 龙 9.王
	if key=="r" then
		if not self.board.grid[self.board.sx][self.board.sy].piece then return end
		local piece=math.abs(self.board.grid[self.board.sx][self.board.sy].piece.type)
		if piece==1 then
			pieceLimit.rabble=pieceLimit.rabble+1
		elseif piece==2 then
			pieceLimit.spearman=pieceLimit.spearman+1
		elseif piece==3 then
			pieceLimit.bowman=pieceLimit.bowman+1
		elseif piece==4 then
			pieceLimit.lightHorse=pieceLimit.lightHorse+1
		elseif piece==5 then
			pieceLimit.heavyHorse=pieceLimit.heavyHorse+1
		elseif piece==6 then
			pieceLimit.trebuchet=pieceLimit.trebuchet+1
		elseif piece==7 then
			pieceLimit.elephant=pieceLimit.elephant+1
		elseif piece==8 then
			pieceLimit.dragon=pieceLimit.dragon+1
		elseif piece==9 then
			pieceLimit.king=pieceLimit.king+1
		end
		self.board.grid[self.board.sx][self.board.sy].piece=nil
		return
	end
	local p=self.board.grid[self.board.sx][self.board.sy]
	local x=self.board.sx
	local y=self.board.sy
	if p.piece~=nil then return end
	if love.keyboard.isDown("1") and pieceLimit.rabble>0 then
		if p.terrain==2 then return end
		p.piece=Rabble:new(self.board,x,y,side)
		pieceLimit.rabble=pieceLimit.rabble-1
	elseif love.keyboard.isDown("2") and pieceLimit.spearman>0 then
		if p.terrain==2 then return end
		p.piece=Spear:new(self.board,x,y,side)
		pieceLimit.spearman=pieceLimit.spearman-1
	elseif love.keyboard.isDown("3") and pieceLimit.bowman>0 then
		if p.terrain==2 then return end
		p.piece=Bow:new(self.board,x,y,side)
		pieceLimit.bowman=pieceLimit.bowman-1
	elseif love.keyboard.isDown("4") and pieceLimit.lightHorse>0 then
		if p.terrain==2 then return end
		p.piece=Light:new(self.board,x,y,side)
		pieceLimit.lightHorse=pieceLimit.lightHorse-1			
	elseif love.keyboard.isDown("5") and pieceLimit.heavyHorse>0 then
		if p.terrain==2 then return end
		p.piece=Heavy:new(self.board,x,y,side)
		pieceLimit.heavyHorse=pieceLimit.heavyHorse-1		
	elseif love.keyboard.isDown("6") and pieceLimit.trebuchet>0 then
		if p.terrain~=0 then return end
		p.piece=Trebuchet:new(self.board,x,y,side)
		pieceLimit.trebuchet=pieceLimit.trebuchet-1	
	elseif love.keyboard.isDown("7") and pieceLimit.elephant>0 then
		if p.terrain==2 then return end
		p.piece=Elephant:new(self.board,x,y,side)
		pieceLimit.elephant=pieceLimit.elephant-1	
	elseif love.keyboard.isDown("8") and pieceLimit.dragon>0 then
		p.piece=Dragon:new(self.board,x,y,side)
		pieceLimit.dragon=pieceLimit.dragon-1
	elseif love.keyboard.isDown("9") and pieceLimit.king>0 then
		if p.terrain==2 then return end
		p.piece=King:new(self.board,x,y,side)
		pieceLimit.king=pieceLimit.king-1	
	end

end

function scene:mousepressed(x,y,key)
	if not self.board.sx then return end 
	if side==1 then
		if self.board.sy>5 then return end
	else
		if self.board.sy<7 then return end
	end

	if s=="terrain" then
		self:addTerrain(key)
	else
		self:addPiece(key)
	end	
end

local function name2piece(name)
	if name=="rabble" then return Rabble end
	if name=="bowman" then return Bow end
	if name=="spearman" then return Spear end
	if name=="lightHorse" then return Light end
	if name=="heavyHorse" then return Heavy end
	if name=="king" then return King end
	if name=="trebuchet" then return Trebuchet end
	if name=="elephant" then return Elephant end
	if name=="dragon" then return Dragon end

end

function scene:setInEmpty(name,pside)
	local x,y
	repeat
		if pside==-1 then
			x = love.math.random(1,11)
			y = love.math.random(7,11)
		else
			x = love.math.random(1,11)
			y = love.math.random(1,5)
		end
	until self.board.grid[x][y].piece==nil
	
	local p=name2piece(name)
	self.board.grid[x][y].piece=p(self.board,x,y,pside)
	
end 

function scene:generateRandom(pside)
	for k,v in pairs(pieceLimit) do
		for i=1,v do
			self:setInEmpty(k,pside)
		end
	end

end


return scene