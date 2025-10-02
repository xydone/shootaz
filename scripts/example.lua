MAX_RUNTIME = 5

Player.set_weapon(3, 3, FIRING_MODE_SEMI, 0.1)

local MAX_SPHERES = 3

local RADIUS = 0.5

local SPAWN_AREA = {
    x_min = -5, x_max = 5,
    y_min = 0,  y_max = 10,
    z_min = -50, z_max = -50,
}


local function random_range(min, max)
    return math.random() * (max - min) + min
end

local function spawn_sphere()
    local x = random_range(SPAWN_AREA.x_min, SPAWN_AREA.x_max)
    local y = random_range(SPAWN_AREA.y_min, SPAWN_AREA.y_max)
    local z = random_range(SPAWN_AREA.z_min, SPAWN_AREA.z_max)
    
    Object.create_sphere(x, y, z, RADIUS)
end

function update()
    local current_spheres = Object.get_spheres()  
    local count = #current_spheres
    
    while count < MAX_SPHERES do
        spawn_sphere()
        count = count + 1
    end
end

function onTimerEnd()
    -- TODO: destroy existing spheres
    print("Timer ended!")
end