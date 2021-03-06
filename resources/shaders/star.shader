shader_type canvas_item;
uniform sampler2D noise;

uniform vec4 main_color: hint_color = vec4(1., 1., 1., 1.);
uniform vec4 selection_color: hint_color = vec4(0.5, 0.5, .0, .6);
uniform float size = 0.4;
uniform float glow_power = .06;
uniform float selection_width = 0.08;
uniform float selection_gap = 0.0;
uniform vec2 seed = vec2(0.);
const float inner_part = 0.9;
const float inner_alpha = 0.9;

vec4 lighten(vec4 color, float power){
	vec4 missing_color = vec4(1.) - color;
	vec4 result = color + missing_color * power;
	return result;
}


void fragment(){
	float ax = UV.x;
	float ay = UV.y;
	float x = ax - 0.5;
	float y = ay - 0.5;
	COLOR.rgb = vec3(0);
	float radius = size / 4.;
	float outer_radius = radius;
	float selection_from = (outer_radius + selection_gap - selection_width / 2.);
	float selection_to = (outer_radius + selection_gap + selection_width / 2.);
	float norm_x = clamp(x / size, -1, 1);
	float height = cos(asin(norm_x));
	float fy = y;
	float fx = x;
	float height2 = cos(abs(fx * 3.14));
	float base = sqrt(fx*fx + fy*fy) / 3.;
	
	float value = (texture(noise, UV + TIME * 0.1).r) * 0.01;
	base += value;
	COLOR.rgba = vec4(.0);
	if (base > outer_radius ){
		COLOR.rgba = main_color.rgba;
		COLOR.a -= clamp(pow(base - outer_radius, 1.) / glow_power, 0., 1.) ;
		
		if (base > selection_from && base < selection_to){
			float selection_power = pow(min(base-selection_from, selection_to-base) / selection_width, 2.) * 4.;
			COLOR = mix(COLOR, selection_color, selection_power);
		}
	}
	else {
		COLOR.rgba = main_color.rgba;
		float inner_radius = radius * inner_part;
		COLOR = lighten(COLOR, (inner_radius - base) * 10.)
//		if (base < inner_radius ){
//			COLOR = lighten(COLOR, 0.5)
////			COLOR.a *= 0.8;
//		}else{
//		}
		
	}
	COLOR = clamp(COLOR, vec4(0.), vec4(1.));
}