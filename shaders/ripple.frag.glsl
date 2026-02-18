#version 330 core
in vec2 fragTexCoord;
in vec4 fragColor;
in vec3 vertexPosition;
uniform float time;
uniform float frequency;
uniform float speed;
uniform float aspect;
out vec4 finalColor;
void main() {
    vec2 uv = vec2(vertexPosition.x * aspect, vertexPosition.y);
    float dist = length(uv);
    float wave = sin(dist * frequency - time * speed);
    float t = wave * 0.5 + 0.5;
    vec3 col = mix(vec3(0.1, 0.2, 0.4), vec3(0.3, 0.6, 1.0), t);
    finalColor = vec4(col, 1.0);
}
