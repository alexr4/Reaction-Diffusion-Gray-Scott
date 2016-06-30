//Simple diffuse shader 
uniform mat4 transform;
uniform mat3 normalMatrix;
uniform mat4 texMatrix;
uniform mat4 modelview;

const float zero_float = 0.0;
const float one_float = 1.0;
const vec2 size = vec2(0.25,0.0);
const ivec3 off = ivec3(-1,0,1);

//lights attribute
uniform int lightCount;
uniform vec4 lightPosition[8];
uniform vec3 lightNormal[8];

in vec4 vertex;
in vec3 normal;
in vec4 color;
in vec2 texCoord;
in vec4 tangent;

out vec4 vertColor;
out vec4 vertTexCoord;
out vec3 ecNormal; //eyeCoordinates normalized
out vec3 ecVertex;//eyeCoordinates
out vec3 lightDir[8];
out float isDirectionnal[8];

uniform sampler2D displacementMap;
uniform float displaceStrength;


void main()
{
	vertColor = color;
	vertTexCoord =  texMatrix * vec4(texCoord, 1.0, 1.0);

	float s01 = textureOffset(displacementMap, vertTexCoord.xy, off.xy).r - textureOffset(displacementMap, vertTexCoord.xy, off.xy).g;
    float s21 = textureOffset(displacementMap, vertTexCoord.xy, off.zy).r - textureOffset(displacementMap, vertTexCoord.xy, off.zy).g;
    float s10 = textureOffset(displacementMap, vertTexCoord.xy, off.yx).r - textureOffset(displacementMap, vertTexCoord.xy, off.yx).g;
    float s12 = textureOffset(displacementMap, vertTexCoord.xy, off.yz).r - textureOffset(displacementMap, vertTexCoord.xy, off.yz).g;
	
    vec3 va = normalize(vec3(size.xy,s21-s01));
    vec3 vb = normalize(vec3(size.yx,s12-s10));
    vec3 bump = vec3(cross(va,vb));

	vec4 displacedVertex;
	vec4 dv;
	float df;
	vec2 uv = texture2D(displacementMap, vertTexCoord.xy).xy;
	float offset = 1.0 - (uv.x - uv.y);
	dv = vec4(offset, offset, offset, 1.0);	
	df = 0.30*dv.x + 0.59*dv.y + 0.11*dv.z;
	displacedVertex = vec4(normal * df * displaceStrength, 0.0) + vertex;

	vertColor = color;

	//Define lights
	ecVertex = vec3(modelview * displacedVertex);
	ecNormal = normalize(normalMatrix * normal);

	//

	for(int i=0; i<lightCount; i++)
	{
		bool isDir = lightPosition[i].w < one_float;

		if (isDir) {
			isDirectionnal[i] = 1.0;
			lightDir[i] = -one_float * lightNormal[i];
		} else { 
			isDirectionnal[i] = 0.0;
			lightDir[i] = normalize(lightPosition[i].xyz - ecVertex);
		}
	}

	gl_Position = transform * displacedVertex;
}