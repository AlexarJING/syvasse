game={}
game.piece={}
game.board=Board:new()
game.selectedPiece=nil
game.goRange=nil
game.turn=true --lower's turn
table.insert(game.piece,Bow:new(1,1,1))
table.insert(game.piece,Dragon:new(1,2,-1))
table.insert(game.piece,Elephant:new(1,3,1))
table.insert(game.piece,Heavy:new(1,4,-1))
table.insert(game.piece,King:new(1,5,1))
table.insert(game.piece,Light:new(1,6,-1))
table.insert(game.piece,Rabble:new(1,7,1))
table.insert(game.piece,Spear:new(1,8,-1))
table.insert(game.piece,Trebuchet:new(1,9,1))
function game:update()
	self.board:update()
	for i,v in ipairs(self.piece) do
		v:update()
	end
end


function game:draw()
	self.board:draw()
	for i,v in ipairs(self.piece) do
		v:draw()
	end
	if self.selectedPiece then
		self:drawRange()
		if  love.mouse.isDown("r") then
			if game.board.sx and game.board.grid[game.board.sx][game.board.sy].piece and game.board.sx~=game.selectedPiece.posX then
				self:drawRange(game.board.grid[game.board.sx][game.board.sy].piece)
			end
		end
	end
end

function game:drawRange(piece)

	local attRange
	local moveRange
	if piece then
		attRange=self.board:getRange(piece,true)
		moveRange=self.board:getRange(piece)
	else
		attRange=self.eatRange
		moveRange=self.goRange
	end
	
	for i,v in pairs(attRange) do
		for j,v in pairs(v) do
			if piece then
				if moveRange[i] and moveRange[i][j] then
					love.graphics.setColor(255,0,255, 100)	
				else
					love.graphics.setColor(255,255,0, 100)
				end
			else
				if moveRange[i] and moveRange[i][j] then
					love.graphics.setColor(0,0,255, 100)	
					
				else
					love.graphics.setColor(255,0,0, 100)
				end
			end
			self.board:drawCell(i,j,"fill")
		end
	end
end


function game:calcValue(p1,p2) --p1为攻，p2为守 协防与夹击
	local defence={}
	local attack={}
	local defence_value=0
	local attack_value=0
	if game.board.grid[p2.posX][p2.posY].terrain==4 then
		defence_value=100
		return false,attack_value,defence_value
	end
	for i=1,6 do
		local x,y=game.board:nextStep(p2.posX,p2.posY,i)
		if x then
			local p=game.board.grid[x][y].piece
			if p and p.type*p1.type>0 and p.tier==p1.tier and p~=p1 then --同盟
				table.insert(attack,p)
			elseif p and p.type*p2.type>0 and p.tier==p2.tier and p~=p2 then
				table.insert(defence,p)
			end
		end
	end

	local count=0
	local count_o=0
	for i=1,5 do
		count=math.floor(count_o/2)
		for _,v in ipairs(attack) do
			if v.tier==i then
				count=count+1
			end
		end
		if i==p1.tier then --选取点
			count=count+1
		end
		if (count==0 or count==math.floor(count_o/2)) and i>=p1.tier then
			attack_value = count==0 and (i-1)*count_o or i*count
			break
		end
		if i==5 then
			attack_value = 4
		end
		count_o=count
	end

	local count=0
	local count_o=0
	for i=1,5 do
		count=math.floor(count_o/2)
		for _,v in ipairs(defence) do
			if v.tier==i then
				count=count+1
			end
		end
		if i==p2.tier then --
			count=count+1
		end
		if (count==0 or count==math.floor(count_o/2)) and i>=p2.tier then
			defence_value = count==0 and (i-1)*count_o or i*count
			break
		end
		count_o=count
		if i==5 then
			defence_value = 4
		end
	end
	return attack_value,defence_value
end

function game:move()
	if self.goRange[self.board.sx] and self.goRange[self.board.sx][self.board.sy] and 
		not game.board.grid[self.board.sx][self.board.sy].piece then --走空地
			game.board.grid[self.selectedPiece.posX][self.selectedPiece.posY].piece=nil
		self.selectedPiece.posX=self.board.sx
		self.selectedPiece.posY=self.board.sy
		game.board.grid[self.selectedPiece.posX][self.selectedPiece.posY].piece=self.selectedPiece
		if self.selectedPiece then self.selectedPiece.selected=false end
		self.selectedPiece=nil
		return true
	end
end

function game:eat()
	if self.eatRange[self.board.sx] and self.eatRange[self.board.sx][self.board.sy] then  --吃子
		for i,v in ipairs(game.piece) do
			if v.posX==self.board.sx and v.posY==self.board.sy and v.type*self.selectedPiece.type<0 then
				local attack,defence=game:calcValue(self.selectedPiece,v)
				if attack>defence then
					if 	self.selectedPiece.attackRange then --远程攻击
						game.board.grid[self.board.sx][self.board.sy].piece=nil --直接吃掉不移动
					else
						game.board.grid[self.selectedPiece.posX][self.selectedPiece.posY].piece=nil
						self.selectedPiece.posX=self.board.sx
						self.selectedPiece.posY=self.board.sy
						game.board.grid[self.selectedPiece.posX][self.selectedPiece.posY].piece=self.selectedPiece
					end
					table.remove(game.piece,i)
				elseif attack==defence then --攻击防御相等则对掉，远程不受影响
					if 	self.selectedPiece.attackRange then --远程攻击
						game.board.grid[self.board.sx][self.board.sy].piece=nil --直接吃掉不移动
						table.remove(game.piece,i)
					else
						game.board.grid[self.selectedPiece.posX][self.selectedPiece.posY].piece=nil
						self.selectedPiece.posX=self.board.sx
						self.selectedPiece.posY=self.board.sy
						game.board.grid[self.selectedPiece.posX][self.selectedPiece.posY].piece=nil
						table.remove(game.piece,i)
						table.remove(game.piece,table.getIndex(game.piece,self.selectedPiece))
						self.selectedPiece=nil
					end
					
				end						
			end
		end
		if self.selectedPiece then self.selectedPiece.selected=false end
		self.selectedPiece=nil
		return true
	end
end


function game:select()
	for i,v in ipairs(self.piece) do --选择棋子
		if v.posX==self.board.sx and v.posY== self.board.sy then
			self.selectedPiece=v
			self.goRange=self.board:getRange(self.selectedPiece)
			self.eatRange=self.board:getRange(self.selectedPiece,true)
			v.selected=true
			return true
		end
	end
end


function game:mousepressed(key)
	if not self.board.sx then return end --如果不在棋盘则跳转
	if key=="l" then	
		if self.selectedPiece then
			if self:move() then return end --走子
			if self:eat() then return end --吃子
		end
		if self:select() then return end		
	end
	if self.selectedPiece  then self.selectedPiece.selected=false end --点击空白则取消选择
	self.selectedPiece=nil
end

return game