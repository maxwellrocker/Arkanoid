local BAR_WIDTH = 80
local BAR_HEIGHT= 20

local BALL_RADIUS = 10
local BALL_SPEED  = 5

local SCREEN_TOP    = display.screenOriginY
local SCREEN_BOTTOM = display.viewableContentHeight + display.screenOriginY
local SCREEN_LEFT   = display.screenOriginX
local SCREEN_RIGHT  = display.viewableContentWidth + display.screenOriginX

local BRICK_WIDTH  = 40
local BRICK_HEIGHT = 20
local LINE_X = 6
local LINE_Y = 4
local brick = {}


--Brick
for i=1, LINE_X*LINE_Y do
	local xpos = math.mod( (i-1), LINE_X )
	local ypos = math.floor( (i-1)/LINE_X )
	brick[i] = display.newRect(SCREEN_LEFT+xpos*BRICK_WIDTH+(xpos+1)*4,
	                           SCREEN_TOP+ypos*BRICK_HEIGHT+(ypos+1)*5,
							   BRICK_WIDTH,
							   BRICK_HEIGHT)
	brick[i].isbreak = false
end


--Control Bar
local bar = display.newRect(display.contentWidth*0.5 - BAR_WIDTH*0.5,
                            display.contentHeight-100,
							BAR_WIDTH,
							BAR_HEIGHT)


--The Ball
local ball = display.newCircle(bar.x, bar.y-BAR_HEIGHT*0.5-BALL_RADIUS, BALL_RADIUS)
ball:setFillColor( 0, 255, 0, 255 );
ball.dirx = 0
ball.diry = 0
ball.fired = false


--Fire Button
local button = display.newImage("button.png")
button.x = display.contentWidth*0.5
button.y = SCREEN_BOTTOM - 25


--Control Bar TouchEvent
function bar:touch(event)
	local phase = event.phase
	if phase == "began" then
		bar.x0 = event.x - bar.x
		
	elseif phase == "moved" then
		--control bar pos
		if (event.x-bar.x0) < (SCREEN_LEFT+BAR_WIDTH*0.5) then
			bar.x = SCREEN_LEFT+BAR_WIDTH*0.5
		elseif (event.x-bar.x0) > (SCREEN_RIGHT-BAR_WIDTH*0.5) then
			bar.x = SCREEN_RIGHT-BAR_WIDTH*0.5
		else
			bar.x = event.x - bar.x0
		end
		
		--ball pos
		if ball.fired==false then
			ball.x = bar.x
			ball.y = bar.y-BAR_HEIGHT*0.5-BALL_RADIUS
		end
		
	elseif phase == "ended" then
	elseif phase == "cancelled" then
	end
	print( "event(" .. event.phase .. ") ("..event.x..","..event.y..")" )
end
bar:addEventListener("touch", bar)


--Fire Ball
function button:tap(event)
	ball.dirx = BALL_SPEED
	ball.diry = BALL_SPEED*-1
	ball.fired = true
	print("fire")
end
button:addEventListener("tap", button)


--Update
local function update(event)
	if ball.fired then
	
		--screen
		if ball.x+ball.dirx < SCREEN_LEFT+BALL_RADIUS or ball.x+ball.dirx > SCREEN_RIGHT-BALL_RADIUS then
			ball.dirx = ball.dirx*-1
		end
		if ball.y+ball.diry < SCREEN_TOP+BALL_RADIUS or ball.y+ball.diry > SCREEN_BOTTOM-BALL_RADIUS then
			ball.diry = ball.diry*-1
		end
		
		--bar
		if ball.y+ball.diry > bar.y-BAR_HEIGHT*0.5-BALL_RADIUS and
		   ball.x+ball.dirx > bar.x-BAR_WIDTH*0.5 and
		   ball.x+ball.dirx < bar.x+BAR_WIDTH*0.5 then
			ball.diry = ball.diry*-1
		end
		
		--brick
		for i,v in pairs(brick) do
			if v and v.isbreak == false then
				local posx = ball.x+ball.dirx
				local posy = ball.y+ball.diry
				if posy+BALL_RADIUS > v.y-BRICK_HEIGHT*0.5 and
				   ball.y < v.y-BRICK_HEIGHT*0.5 and
				   posx > v.x-BRICK_WIDTH*0.5 and
				   posx < v.x+BRICK_WIDTH*0.5 then
					ball.diry = ball.diry*-1
					v:removeSelf()
					v.isbreak = true
					break
				end
				if posy-BALL_RADIUS < v.y+BRICK_HEIGHT*0.5 and
				   ball.y > v.y+BRICK_HEIGHT*0.5 and
				   posx > v.x-BRICK_WIDTH*0.5 and
				   posx < v.x+BRICK_WIDTH*0.5 then
					ball.diry = ball.diry*-1
					v:removeSelf()
					v.isbreak = true
					break
				end
				if posx+BALL_RADIUS > v.x-BRICK_WIDTH*0.5 and
				   ball.x < v.x-BRICK_WIDTH*0.5 and
				   posy > v.y-BRICK_HEIGHT*0.5 and
				   posy < v.y+BRICK_HEIGHT*0.5 then
					ball.dirx = ball.dirx*-1
					v:removeSelf()
					v.isbreak = true
					break
				end
				if posx-BALL_RADIUS < v.x+BRICK_WIDTH*0.5 and
				   ball.x > v.x+BRICK_WIDTH*0.5 and
				   posy > v.y-BRICK_HEIGHT*0.5 and
				   posy < v.y+BRICK_HEIGHT*0.5 then
					ball.dirx = ball.dirx*-1
					v:removeSelf()
					v.isbreak = true
					break
				end
			end
		end
		
		--death
		if ball.y > bar.y then
			ball.x = bar.x
			ball.y = bar.y-BAR_HEIGHT*0.5-BALL_RADIUS
			ball.fired = false
			return
		end
		
		ball.x = ball.x + ball.dirx
		ball.y = ball.y + ball.diry
	end
end
Runtime:addEventListener( "enterFrame", update );