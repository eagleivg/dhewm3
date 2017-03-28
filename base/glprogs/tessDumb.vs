#version 410 core

// mesh data
layout (location = 0) in vec3 position;
layout (location = 1) in vec2 texcoord;
layout (location = 2) in vec3 normal;

// to control shader
out VertexCS
{
        vec3 position;
        vec2 texcoord;
        vec3 normal;
} vertcs;

void main(void)
{
        vertcs.position = position;
        vertcs.texcoord = texcoord;
        vertcs.normal = normal;

        gl_Position = vec4(position, 1.0);
}

