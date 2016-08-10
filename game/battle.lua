local scene = Gamestate.new()
scene.selectedPiece=nil
scene.goRange=nil
scene.side=1

function scene:init()
end 

function scene:enter(from,board)
	self.board=board
	self.piece={}
	for x=1,11 do
		for y=1,11 do
			if self.board.grid[x][y].piece then
				table.insert(self.piece, self.board.grid[x][y].piece)
			end
		end
	end
end


function scene:draw()
	self.board:draw()
	for i,v in ipairs(self.piece) do
		v:draw()
	end
	if self.selectedPiece then
		self:drawRange()
		if  love.mouse.isDown("r") then
			if self.board.sx and self.board.grid[self.board.sx][self.board.sy].piece and self.board.sx~=self.selectedPiece.posX then
				self:drawRange(self.board.grid[self.board.sx][self.board.sy].piece)
			end
		end
	end
	love.graphics.setColor(255,255,255)
	if scene.side==1 then
		love.graphics.print("White's turn", 550,100)
	else
		love.graphics.print("Black's turn", 550,100)
	end
end


function scene:update(dt)
	self.board:update()
	for i,v in ipairs(self.piece) do
		v:update()
	end
end 

function scene:leave()

end

function scene:drawRange(piece)

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


function scene:calcDefence(p2)
	local defence={}
	local defence_value=0
	if self.board.grid[p2.posX][p2.posY].terrain==4 then
		defence_value=100
		return defence_value
	end
	for i=1,6 do
		local x,y=self.board:nextStep(p2.posX,p2.posY,i)
		if x then
			local p=self.board.grid[x][y].piece
			if p and p.type*p2.type>0 and p.tier==p2.tier and p~=p2 then
				table.insert(defence,p)
			end
		end
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
	return defence_value

end


function scene:calcValue(p1,p2) --p1为攻，p2为守 协防与夹击
	local defence={}
	local attack={}
	local defence_value=0
	local attack_value=0
	if self.board.grid[p2.posX][p2.posY].terrain==4 then
		defence_value=100
		return false,attack_value,defence_value
	end
	for i=1,6 do
		local x,y=self.board:nextStep(p2.posX,p2.posY,i)
		if x then
			local p=self.board.grid[x][y].piece
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

function scene:move()
	if self.goRange[self.board.sx] and self.goRange[self.board.sx][self.board.sy] and 
	not self.board.grid[self.board.sx][self.board.sy].piece then --走空地
		self.board.grid[self.selectedPiece.posX][self.selectedPiece.posY].piece=nil
		self.selectedPiece.posX=self.board.sx
		self.selectedPiece.posY=self.board.sy
		self.board.grid[self.selectedPiece.posX][self.selectedPiece.posY].piece=self.selectedPiece
		if self.selectedPiece then self.selectedPiece.selected=false end
		self.selectedPiece=nil
		return true
	end
end

function scene:eat()
	if self.eatRange[self.board.sx] and self.eatRange[self.board.sx][self.board.sy] then  --吃子
		for i,v in ipairs(self.piece) do
			if v.posX==self.board.sx and v.posY==self.board.sy and v.type*self.selectedPiece.type<0 then
				local attack,defence=self:calcValue(self.selectedPiece,v)
				if attack>defence then
					if 	self.selectedPiece.attackRange then --远程攻击
						self.board.grid[self.board.sx][self.board.sy].piece=nil --直接吃掉不移动
					else
						self.board.grid[self.selectedPiece.posX][self.selectedPiece.posY].piece=nil
						self.selectedPiece.posX=self.board.sx
						self.selectedPiece.posY=self.board.sy
						self.board.grid[self.selectedPiece.posX][self.selectedPiece.posY].piece=self.selectedPiece
					end
					if math.abs(v.type)==9 then print("game over") end
					table.remove(self.piece,i)
					if self.selectedPiece then self.selectedPiece.selected=false end
					self.selectedPiece=nil
					return true
				elseif attack==defence then --攻击防御相等则对掉，远程不受影响
					if 	self.selectedPiece.attackRange then --远程攻击
						self.board.grid[self.board.sx][self.board.sy].piece=nil --直接吃掉不移动
						table.remove(self.piece,i)
					else
						self.board.grid[self.selectedPiece.posX][self.selectedPiece.posY].piece=nil
						self.selectedPiece.posX=self.board.sx
						self.selectedPiece.posY=self.board.sy
						self.board.grid[self.selectedPiece.posX][self.selectedPiece.posY].piece=nil
						table.remove(self.piece,i)
						table.remove(self.piece,table.getIndex(self.piece,self.selectedPiece))
						if math.abs(self.selectedPiece.type)==9 then print("game over") end 
						self.selectedPiece=nil
					end
					if math.abs(v.type)==9 then print("game over") end

					if self.selectedPiece then self.selectedPiece.selected=false end
					self.selectedPiece=nil
					return true
				else 
					return false	
				end						
			end
		end
		if self.selectedPiece then self.selectedPiece.selected=false end
		self.selectedPiece=nil
	end
end


function scene:select()
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


function scene:mousepressed(x,y,key)
	if not self.board.sx then return end --如果不在棋盘则跳转
	if key=="l" then	
		if self.selectedPiece and self.selectedPiece.type*self.side>0 then --走子
			if self:move() then self.side=self.side*-1 ;return end --走子
			if self:eat() then self.side=self.side*-1 ;return end --吃子
		end
		if self:select() then return end		
	end
	if self.selectedPiece  then self.selectedPiece.selected=false end --点击空白则取消选择
	self.selectedPiece=nil
end
return scene