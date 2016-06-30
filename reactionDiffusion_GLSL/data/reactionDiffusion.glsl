#version 430
#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

const vec2 size = vec2(0.25,0.0);
const ivec3 off = ivec3(-1,0,1);

uniform sampler2D source;
uniform float time = 1.0;
uniform float dA = 0.2097;
uniform float dB = 0.105;
uniform float feedRate = 0.055;//0.062;
uniform float killRate = 0.062;//0.062;
uniform vec2 screen;
uniform vec2 mouse;
uniform float maxDist = 50.0;

uniform sampler2D texture;
uniform vec2 texOffset;

in vec4 vertColor;
in vec4 vertTexCoord;

out vec4 fragColor;

vec2 laplace()
{
	float center = 1.0;
	float near = 1.0;
	float far = 1.0;
	vec2 uv = texture2D(texture, vertTexCoord.st).rg * center;
    vec2 uv0 = texture2D(texture, vertTexCoord.st + vec2(-texOffset.s, 0.0)).rg * near;
    vec2 uv1 = texture2D(texture, vertTexCoord.st + vec2(+texOffset.s, 0.0)).rg * near;
    vec2 uv2 = texture2D(texture, vertTexCoord.st + vec2(0.0, -texOffset.t)).rg * near;
    vec2 uv3 = texture2D(texture, vertTexCoord.st + vec2(0.0, +texOffset.t)).rg * near;
    vec2 uv4 = texture2D(texture, vertTexCoord.st + vec2(-texOffset.s, -texOffset.t)).rg * near;
    vec2 uv5 = texture2D(texture, vertTexCoord.st + vec2(+texOffset.s, -texOffset.t)).rg * near;
    vec2 uv6 = texture2D(texture, vertTexCoord.st + vec2(-texOffset.s, +texOffset.t)).rg * near;
    vec2 uv7 = texture2D(texture, vertTexCoord.st + vec2(+texOffset.s, +texOffset.t)).rg * near;

	//return uv0 + uv1 + uv2 + uv3 + uv4 + uv5 + uv6 + uv7 - 8.0 * uv;
	return uv0 + uv1 + uv2 + uv3 - 4.0 * uv;
}


void main(void) {
	vec2 grid = texture2D(source, vertTexCoord.st).rg;

	float chemicalA = grid.r;
	float chemicalB = grid.g;

	//compute delta base on http://www.karlsims.com/rd.html
	float A_ = (dA * laplace().r) - (chemicalA * chemicalB * chemicalB) + (feedRate * (1.0 - chemicalA));
	float B_ = (dB * laplace().g) + (chemicalA * chemicalB * chemicalB) - ((killRate + feedRate) * chemicalB);
	float t = clamp(time, 0.0, 1.0);
	vec2 reactiondiffusion = grid + t * vec2(A_, B_); 

	vec2 diff = vertTexCoord.st * screen - mouse;
    float dist = dot(diff, diff);
    if(dist < maxDist) {
        reactiondiffusion.g =0.9;
    }

    //Bump
    float s01 = textureOffset(texture, vertTexCoord.xy, off.xy).g - textureOffset(texture, vertTexCoord.xy, off.xy).g;
    float s21 = textureOffset(texture, vertTexCoord.xy, off.zy).r - textureOffset(texture, vertTexCoord.xy, off.zy).g;
    float s10 = textureOffset(texture, vertTexCoord.xy, off.yx).r - textureOffset(texture, vertTexCoord.xy, off.yx).g;
    float s12 = textureOffset(texture, vertTexCoord.xy, off.yz).r - textureOffset(texture, vertTexCoord.xy, off.yz).g;
  
    vec3 va = normalize(vec3(size.xy,s21-s01));
    vec3 vb = normalize(vec3(size.yx,s12-s10));
    vec4 bump = vec4( cross(va,vb), 1.0);
	

    reactiondiffusion = clamp(reactiondiffusion, vec2(0.0, 0.0), vec2(1.0, 1.0));

	fragColor = vec4(reactiondiffusion, bump.x, bump.y);	
}