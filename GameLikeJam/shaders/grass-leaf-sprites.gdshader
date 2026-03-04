shader_type spatial;
render_mode depth_prepass_alpha, depth_draw_opaque;

group_uniforms colour;
uniform sampler2D base_texture : source_color, filter_nearest;
uniform vec4 base : source_color = vec4(1.0f);

group_uniforms colour.mid;
uniform vec4 mid : source_color = vec4(1.0f); 
uniform float mid_scale : hint_range(0.0, 1.0, 0.001) = 0.005; 
uniform float mid_threshold : hint_range(0.0, 1.0, 0.001) = 0.3; 
uniform sampler2D mid_noise; 

group_uniforms colour.top;
uniform vec4 top : source_color = vec4(1.0f);
uniform float top_scale : hint_range(0.0, 0.1, 0.001) = 0.005; 
uniform float top_threshold : hint_range(0.0, 1.0, 0.001) = 0.6;
uniform sampler2D top_noise; 

uniform float area = 50.0;

varying float instance_id;
varying float leaf_seed;
varying vec3 model_origin;


float random(float n) {
	return fract(sin(n * 12.9898) * 43758.5453);
}

void vertex() {
	instance_id = float(INSTANCE_ID);
	leaf_seed = random(instance_id);

    vec3 offset = vec3(random(instance_id) * area -area * 0.5, 0.0, random(instance_id + 1.0) * area -area * 0.5);
	
	//billboard
	mat4 modified_model_view = VIEW_MATRIX * mat4(
		vec4(INV_VIEW_MATRIX[0].xyz, 0.0),
		vec4(INV_VIEW_MATRIX[1].xyz, 0.0),
		vec4(INV_VIEW_MATRIX[2].xyz, 0.0),
		vec4(MODEL_MATRIX[3].xyz +offset,1.0)
	);

	model_origin = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	MODELVIEW_MATRIX = modified_model_view;
}

void fragment() {

	vec4 grass_texture = texture(base_texture, UV);

	float mid_noise_texture = texture(mid_noise, vec2(leaf_seed,0.0)).r;
	float top_noise_texture = texture(top_noise, vec2(leaf_seed,1.0)).r;
	
	ALBEDO = base.rgb * grass_texture.rgb;
	if (mid_noise_texture > mid_threshold) {
		ALBEDO = mid.rgb * grass_texture.rgb;
	} if (top_noise_texture > top_threshold) {
		ALBEDO = top.rgb * grass_texture.rgb;
	}

	ALPHA = grass_texture.a;
}