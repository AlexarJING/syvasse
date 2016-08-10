local board=Class("board")
local board_width=11
local board_height=11	
local size=30
local board_x=30
local board_y=28
local sqr3=3^0.5
local debug=false
function board:initialize(grid)
	self.size=size
	if grid then
		self.grid=grid
	else
		self.grid={}
		for i=1,board_width do
			self.grid[i]={}
			for j=1,board_height do
				self.grid[i][j]={
					piece=nil,
					terrain = 0
				}
			end
		end
	end
	path=self:findPath(1,1,10,10)
end

function board:select()
	local x,y=love.mouse.getPosition()
	x=x-board_x+size
	local px=math.ceil(x/size/1.5)
	y=px%2~=0 and y-board_y+sqr3/2*size or y-board_y
	local py=math.ceil(y/size/sqr3)

	if px<1 or py<1 or px>board_width or py>board_height then self.sx=nil
	else self.sx=px;self.sy=py;return px,py end
end


function board:update()
	self:select()
end



--t= 1 2 3 4 5 6 从左上转圈数
function board:nextStep(x,y,t) -- x,y grid位置，t
	local rx,ry
	if x%2==0 then
		if t==1 then
			rx=x-1
			ry=y
		elseif t==2 then
			rx=x
			ry=y-1
		elseif t==3 then
			rx=x+1
			ry=y
		elseif t==4 then
			rx=x+1
			ry=y+1
		elseif t==5 then
			rx=x
			ry=y+1
		else
			rx=x-1
			ry=y+1
		end
	else

		if t==1 then
			rx=x-1
			ry=y-1
		elseif t==2 then
			rx=x
			ry=y-1
		elseif t==3 then
			rx=x+1
			ry=y-1
		elseif t==4 then
			rx=x+1
			ry=y
		elseif t==5 then
			rx=x
			ry=y+1
		else
			rx=x-1
			ry=y
		end
	end
	if rx<1 or ry<1 or rx>board_width or ry>board_height then return 
	else return rx,ry end
end
-- type 
-- 0,王，1，民，2，矛，3，弩，4，轻，5，重，6，投石车，7.大象 8. 龙


function board:getGridPos(i,j)
	if not i then return end
	if i<1 or j<1 or i>board_width or j>board_height then return end
	if i%2==0 then
		return (i-1)*size*1.5+board_x,(j-1)*size*sqr3+size/2*sqr3+board_y 
	else
		return (i-1)*size*1.5+board_x,(j-1)*size*sqr3+board_y
	end
end

local function setColor(self,i,j)
	local t=self.grid[i][j].terrain
	if t==1 then --wood
		love.graphics.setColor(50, 100, 50)
	elseif t==2 then --mountain
		love.graphics.setColor(150, 150, 150)
	elseif t==3 then --water
		love.graphics.setColor(50, 50, 250)
	elseif t==4 then --castle
		love.graphics.setColor(250, 250, 50)
	else
		love.graphics.setColor(50, 200, 50)
	end
end

function board:drawCell(i,j,type)
	type=type or "fill"
	if i%2==0 then 
        love.graphics.hexagon(type, (i-1)*size*1.5+board_x,(j-1)*size*sqr3+size/2*sqr3+board_y,size)
    else 
        love.graphics.hexagon(type, (i-1)*size*1.5+board_x,(j-1)*size*sqr3+board_y,size)
    end
end


function board:draw()

	for i=1,board_width do
		for j=1,board_height do
			setColor(self,i,j)
			self:drawCell(i,j,"fill")
            love.graphics.setColor(0,0,0)
            self:drawCell(i,j,"line")
            if self.grid[i][j].piece then
            	self.grid[i][j].piece:draw()
            end
		end
	end
	if debug then
		love.graphics.setColor(255, 0,0)
		if self.sx then
			for i,v in pairs(self.grid) do
				for j,v in pairs(v) do
					local x,y=self:getGridPos(i,j)
					if x then love.graphics.print(v.piece, x, y) end
				end
			end
		end
	end
	if path then

		for i,v in ipairs(path) do
			love.graphics.setColor(255,0,0,200)
			self:drawCell(v[1],v[2],"fill")
			love.graphics.setColor(255,255,255)
			love.graphics.print(v[3], self:getGridPos(v[1],v[2]))
		end
	end
end

--0 草 1 林 2 山 3 水 4 堡
-- 1，民，2，矛，3，弩，4，轻，5，重，6，投石车，7.大象 8. 龙 9.王
function board:getTerrainStep(x,y,step,type,direct)
	if step<=0 then return 0 end
	local t=math.abs(self.grid[x][y].terrain)
	local p=self.grid[x][y].piece and self.grid[x][y].piece.type or 0
	if type==8 then return step end
	if t==1 then
		if type==6 or type==7 then 
			step=0
		else
			step= math.floor(step/2)==0 and 1 or math.floor(step/2)
		end
	elseif t==2 then
		if type~=8 then
			step=0
		end
	elseif t==3 then
		if type==6 then
			step=0
		else
			step=1
		end
	elseif type==4 then
		--无人堡直接穿过
	else
		step=step
	end
	if type*p>=0 or direct then return step
	
	else return 0 end
end

function board:getRange(piece,direct)
	local x=piece.posX
	local y=piece.posY
	local step=piece.range
	if direct then step=piece.attackRange or piece.range end
	local type=piece.type
	step=step+1
	local tab={}
	local toTest={{x,y,step}}
	local loop=0
	tab[x]={}
	tab[x][y]=0
	if self:getTerrainStep(x,y,step,type)==0 then
		return tab
	end

	while #toTest~=0 and loop<step do
		local toSave={}
		loop=loop + 1
		for _,p in ipairs(toTest) do
			for i=1,6 do
				local nx,ny =self:nextStep(p[1],p[2],i)
				local pStep=p[3]
				if nx then 
					if not tab[nx] then tab[nx]={} end
					if not tab[nx][ny] then 	
						local s=self:getTerrainStep(nx,ny,pStep-1,type,direct)
						if s>0 then
							tab[nx][ny]=loop 
							table.insert(toSave, {nx,ny,s})
						end
					end
				end
			end	
		end
		toTest=toSave
	end
	tab[x][y]=nil
	return tab
end


function board:calcDefence(p2)
	local defence={}
	local defence_value=0
	if self.grid[p2.posX][p2.posY].terrain==4 then
		defence_value=100
		return defence_value
	end
	for i=1,6 do
		local x,y=self:nextStep(p2.posX,p2.posY,i)
		if x then
			local p=self.grid[x][y].piece
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

function board:findPath(ox,oy,tx,ty)
	local toFind={}
	local toSave={}
	local result={}
	local grid=table.copy(self.grid)
	--草地代价为0,林代价为1，水代价为2

	local function getValue(x1,y1,x2,y2) --x1,y1从那开始探测，x2,y2被探测的点
		if grid[x2][y2].value then return end --已经被探测的则不再探测
		local value=grid[x1][y1].value
		local t=grid[x2][y2].terrain
		local p=grid[x2][y2].piece
		--if p then print("blocked");return end
		if t==1 then
			value=value+1
		elseif t==2 then
			--return 
		elseif t==3 then
			value=value+2
		end

		local vx=(x2-x1)*(tx-x2)
		if vx>0 then
			value=value-1
		elseif vx==0 then
			value=value+0
		else 
			value=value+1 
		end
		local yy1,yy2,yy3
		if x1%2==0 then yy1=y1+0.5 else yy1=y1 end
		if x2%2==0 then yy2=y2+0.5 else yy2=y2 end
		if ty%2==0 then yy3=ty+0.5 else yy3=ty end
		local vy=(yy2-yy1)*(yy3-yy2)
		if vy>0 then
			value=value-1
		elseif vy==0 then
			value=value+0
		else 
			value=value+1 
		end
		grid[x2][y2].value=value
		return value
		--grid[x][y].value=
	end

	table.insert(toFind,{ox,oy,0})
	grid[ox][oy].value=0
	repeat
		table.sort( toFind, function(a,b) return a[3]<b[3] end ) --按分数排序
		
		local p=toFind[1]
		if p[1]==tx and p[2]==ty then break end
		for i=1,6 do
			local nx,ny=self:nextStep(p[1],p[2],i) --找周围的
			if nx then
				local value=getValue(p[1],p[2],nx,ny)
				if value then
					grid[nx][ny].from={p[1],p[2]}
					table.insert(toFind, {nx,ny,value})
				end
			end
		end
		table.remove(toFind, 1)
	until #toFind==0
	if not grid[tx][ty].from then 
		return 
	end
	local x,y=tx,ty
	while true do
		if grid[x][y].from then
			x,y=unpack(grid[x][y].from)
		else
			break
		end
		if (not x) or (not y) then break end
		table.insert(result, 1, {x,y,grid[x][y].value})
	end
	return result
end


return board