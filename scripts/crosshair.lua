local size = 0.01

local color = { 1,1,1,1 }

local crosshair_vertices = {
    {-size, 0, color},
    {size, 0, color},
    { 0, size, color},
    { 0, -size, color}
}

Crosshair.set_crosshair(crosshair_vertices)