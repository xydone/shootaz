MAX_RUNTIME = 1

local x = 0
local y = 5
local z = -50
RADIUS = 0.5

Player.set_weapon(3, 3, FIRING_MODE_tracking, 0.1)

Object.random_init()
Object.create_sphere(x,y,z, RADIUS)

local change = -0.1

function update()
    x = x + change
    if x < -10 then
      change = 0.1
    elseif x > 10 then
      change = -0.1
    end
    Object.update_sphere(0,x,y,z,RADIUS)
end

function onTimerEnd()
    Object.clear_spheres()
end