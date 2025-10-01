@header const m = @import("../math.zig")
@ctype mat4 m.Mat4

@vs vs
layout(binding = 0) uniform vs_params {
    mat4 mvp;
};

in vec4 position;
in vec3 instance_offset;
in vec4 instance_color;
in float instance_radius;

out vec4 color;

void main() {
    gl_Position = mvp * (vec4(position.xyz * instance_radius, 1.0) + vec4(instance_offset, 0.0));
    color = instance_color;
}
@end

@fs fs
in vec4 color;
out vec4 frag_color;

void main() {
    frag_color = color;
}
@end

@program sphere vs fs