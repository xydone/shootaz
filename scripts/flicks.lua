MAX_RUNTIME = 30

X = {min = -5, max = 5}
Y = {min = 0, max = 10}
Z = -50
RADIUS = 0.5

Player.set_weapon(3, 3, FIRING_MODE_semi, 0.1)

local MAX_SPHERES = 3

Object.random_init()

function update()
    local current_spheres = Object.get_spheres()  
    local count = #current_spheres
    
    while count < MAX_SPHERES do
        Object.generate_random_sphere()
        count = count + 1
    end
end

function onTimerEnd()
    Object.clear_spheres()
end