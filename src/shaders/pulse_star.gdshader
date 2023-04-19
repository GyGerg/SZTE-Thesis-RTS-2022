shader_type spatial;
render_mode blend_add,unshaded;

uniform bool use_custom_albedo = false;
varying vec4 custom_albedo;
uniform vec4 albedo : source_color = vec4(1.0,1.0,1.0,1.0);
uniform sampler2D albedo_texture;
uniform float Saturation : hint_range(0.5, 1.0) = 1.0;
uniform float PulseRate = 5.0;
uniform float PulseIntensity = 0.1;
uniform float Opacity : hint_range(0,1) = 1.0;

void vertex() {
	
	float pulse_freq = TIME*PulseRate*TAU;
	float pulse_val = 0.5*(sin(pulse_freq)+1.0);
	pulse_val = pow(pulse_val,4);
	custom_albedo = INSTANCE_CUSTOM;
	
//	MODELVIEW_MATRIX = (
//		INV_VIEW_MATRIX 
//		* mat4(VIEW_MATRIX[0],VIEW_MATRIX[1],VIEW_MATRIX[2],VIEW_MATRIX[3])
//	);
	VERTEX += NORMAL * (pulse_val*PulseIntensity);
}

void fragment() {
	vec4 albedo_to_use = albedo;
	if (use_custom_albedo) {
		albedo_to_use = custom_albedo;
	}
		
	vec4 albedo_tex = texture(albedo_texture,UV);
	ALBEDO = albedo_to_use.rgb*albedo_tex.rgb;
	
	float normal_dot = dot(NORMAL, vec3(0,0,1));
	
	normal_dot = max(normal_dot, 0.0);
	// pi/4 approx hardcoded
	float arc = asin(normal_dot*Saturation)/(PI/4.0);
	
	arc = pow(arc,10);
	
	float alpha_value = arc*albedo_to_use.a*Opacity;
	alpha_value = min(Opacity,alpha_value);
	
	ALPHA = (alpha_value);
	// Place fragment code here.
}

