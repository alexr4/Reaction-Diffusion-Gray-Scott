//Simple diffuse shader
#version 130
#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif
const float zero_float = 0.0;
const float one_float = 1.0;
const float gamma = 2.2f;
const vec2 size = vec2(0.25,0.0);
const ivec3 off = ivec3(-1,0,1);

uniform int lightCount;
uniform vec3 lightNormal[8];
uniform vec4 lightPosition[8];
uniform vec3 lightDiffuse[8]; // diffuse is the color element of the light  
uniform vec3 lightFalloff[8];

uniform sampler2D displacementMap;

in vec4 vertColor;
in vec4 vertTexCoord;
in vec3 ecNormal; //eyeCoordinates normalized
in vec3 ecVertex;//eyeCoordinates
in vec3 lightDir[8];
in float isDirectionnal[8];

//material
uniform vec3 kd;//Diffuse reflectivity
uniform vec3 ka;//Ambient reflectivity
uniform vec3 ks;//Specular reflectivity
uniform vec3 emissive; //emissive color
uniform float shininess;//shine factor
uniform float minNormalEmissive = 0.75;

out vec4 fragColor;

vec3 toLinear(vec3 v) {
  return pow(v, vec3(gamma));
}

vec4 toLinear(vec4 v) {
  return vec4(toLinear(v.rgb), v.a);
}

vec3 toGamma(vec3 v) {
  return pow(v, vec3(1.0 / gamma));
}

vec4 toGamma(vec4 v) {
  return vec4(toGamma(v.rgb), v.a);
}

vec3 ads(vec3 dir, vec3 color)
{
	vec3 n = normalize(ecNormal);
	vec3 s = normalize(dir);
	vec3 v = normalize(-ecVertex.xyz);
	vec3 r = reflect(-s, n);
	vec3 h = normalize(v + s);
	float intensity = max(0.0, dot(s, n));

	/*if(gl_FrontFacing)
	{		
	 n = normalize(-ecNormal);
	 s = normalize(dir);
	 v = normalize(ecVertex.xyz);
	 r = reflect(s, n);
	 h = normalize(v + s);
	 intensity = max(0.0, dot(n, s));
	}*/
//
	//return color * intensity * (ka + kd * max(dot(s, n), 0.0) + ks * pow(max(dot(r, v), 0.0), shininess));
	return color * intensity * (ka + kd * max(dot(s, n), 0.0) + ks * pow(max(dot(h, n), 0.0), shininess));
}

float falloffFactor(vec3 lightPos, vec3 vertPos, vec3 coeff) {
  vec3 lpv = lightPos - vertPos;
  vec3 dist = vec3(one_float);
  dist.z = dot(lpv, lpv);
  dist.y = sqrt(dist.z);
  return one_float / dot(dist, coeff);
}

void main()
{
	//textures
	vec2 texdiffuse = texture2D(displacementMap, vertTexCoord.st).xy;
	float gray = texdiffuse.x - texdiffuse.y;

	float s01 = textureOffset(displacementMap, vertTexCoord.xy, off.xy).r - textureOffset(displacementMap, vertTexCoord.xy, off.xy).g;
    float s21 = textureOffset(displacementMap, vertTexCoord.xy, off.zy).r - textureOffset(displacementMap, vertTexCoord.xy, off.zy).g;
    float s10 = textureOffset(displacementMap, vertTexCoord.xy, off.yx).r - textureOffset(displacementMap, vertTexCoord.xy, off.yx).g;
    float s12 = textureOffset(displacementMap, vertTexCoord.xy, off.yz).r - textureOffset(displacementMap, vertTexCoord.xy, off.yz).g;
	
    vec3 va = normalize(vec3(size.xy,s21-s01));
    vec3 vb = normalize(vec3(size.yx,s12-s10));
    vec3 bump = vec3(cross(va,vb)) * 2.0 - 1.0;
	bump.g = 1.0 - bump.g; //invert y axis
   

    
	float intensityNormalMap = 0.0;

	vec3 normal = vec3(1.0, 1.0, 1.0);
	normal.x = dFdx(gray);
	normal.y = dFdy(gray);
	normal.z = sqrt(1 - normal.x*normal.x - normal.y * normal.y); // Reconstruct z component to get a unit normal.
 	vec3 norm = normalize(bump);

	//lights
	vec4 lightColor = vec4(0.0, 0.0, 0.0, 1.0);
	for(int i = 0 ; i <lightCount ; i++) 
	{
	  vec3 direction = normalize(lightDir[i]);
	  float falloff = 0.0;
	  if(isDirectionnal[i] == 1.0)
	  {
	  	falloff = one_float;
	  }else{
	  	falloff = falloffFactor(lightPosition[i].xyz, ecVertex, lightFalloff[i]);
	  }
	  
	  lightColor += vec4(ads(direction, lightDiffuse[i].xyz), 1.0) * falloff;
	  intensityNormalMap += max(dot(norm, lightDir[i]), minNormalEmissive);
	}
	vec4 final_lightColor =  (vec4(emissive, 1.0)  +  (lightColor * vertColor)) * intensityNormalMap;

	float inc = 0.25;
	vec4 Albedo =  toGamma(final_lightColor);

	fragColor = gl_FrontFacing ? Albedo : Albedo;
}