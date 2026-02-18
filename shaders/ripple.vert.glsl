#version 330 core
out vec2 fragTexCoord;
out vec4 fragColor;
out vec3 vertexPosition;
void main() {
    vec2 positions[3] = vec2[](vec2(-1,-1), vec2(3,-1), vec2(-1,3));
    vec2 uvs[3] = vec2[](vec2(0,0), vec2(1,0), vec2(0,1));
    gl_Position = vec4(positions[gl_VertexID], 0.0, 1.0);
    fragTexCoord = uvs[gl_VertexID];
    fragColor = vec4(1.0);
    vertexPosition = vec3(positions[gl_VertexID], 0.0);
}
