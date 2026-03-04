// shader for MeshInstance3D - mesh plane

shader_type spatial;

// base colour
group_uniforms colour;
uniform vec4 base : source_color = vec4(1.0f);

// noise layers properties:
// noise type - value cubic or perlin
// generate mipmaps - off
// seamless - on
// in 3d space - on 

// mid grass layer colour
group_uniforms colour.mid;
uniform vec4 mid : source_color = vec4(1.0f);
uniform sampler2D mid_noise;
uniform float mid_scale : hint_range(0.0, 1.0, 0.001) = 0.005;
uniform float mid_threshold : hint_range(0.0, 1.0, 0.001) = 0.4;

// top grass layer colour
group_uniforms colour.top;
uniform vec4 top : source_color = vec4(1.0f);
uniform sampler2D top_noise;
uniform float top_scale : hint_range(0.0, 0.1, 0.001) = 0.005;
uniform float top_threshold : hint_range(0.0, 1.0, 0.001) = 0.5;

varying vec3 world;

// pixel size
uniform float pixelation: hint_range(0.0,1.0,0.001)=0.1;

void vertex() {
	world = (MODEL_MATRIX* vec4(VERTEX,1.0)).xyz;
}

void fragment() {
	vec2 cell = floor(world.xz/pixelation);

	float mid_noise_texture = texture(mid_noise, cell * mid_scale).r;
	float top_noise_texture = texture(top_noise, cell * top_scale).r;
	
	ALBEDO = base.rgb;
	if (mid_noise_texture > mid_threshold) {
		ALBEDO = mid.rgb;
	} if (top_noise_texture > top_threshold) {
		ALBEDO = top.rgb;
	}
	ALPHA = 1.0;
}