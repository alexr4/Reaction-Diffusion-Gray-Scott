#version 430
#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

const vec2 size = vec2(0.25,0.0);
const ivec3 off = ivec3(-1,0,1);

uniform sampler2D texture;
in vec4 vertTexCoord;

out vec4 fragColor;



void main(void) {
	vec4 uv = texture2D(texture, vertTexCoord.st);
 	float s01 = textureOffset(texture, vertTexCoord.xy, off.xy).r - textureOffset(texture, vertTexCoord.xy, off.xy).g;
    float s21 = textureOffset(texture, vertTexCoord.xy, off.zy).r - textureOffset(texture, vertTexCoord.xy, off.zy).g;
    float s10 = textureOffset(texture, vertTexCoord.xy, off.yx).r - textureOffset(texture, vertTexCoord.xy, off.yx).g;
    float s12 = textureOffset(texture, vertTexCoord.xy, off.yz).r - textureOffset(texture, vertTexCoord.xy, off.yz).g;
    float gray = uv.r - uv.g;
	
    vec3 va = normalize(vec3(size.xy,s21-s01));
    vec3 vb = normalize(vec3(size.yx,s12-s10));
    vec4 bump = vec4( cross(va,vb), 1.0);

    vec4 Albedo = vec4(bump.x, bump.y, uv.r, uv.g);

	fragColor = Albedo;
}