shader_type canvas_item;
uniform sampler2D noise;

uniform float main_color_reflectivness = 0.8;
uniform float second_color_reflectivness = 0.3;
uniform float ice_color_reflectivness = 0.7;
uniform vec4 main_color: hint_color = vec4(1., 0., 0., 1.);
uniform vec4 second_color: hint_color = vec4(1., 0., 0., 1.);
uniform vec4 polar_ice_color: hint_color = vec4(vec3(0.8), 1.);
uniform vec4 atmosphere_color: hint_color = vec4(0., 0., .9, .3);
uniform vec4 selection_color: hint_color = vec4(0.5, 0.5, .0, .6);
uniform float selection_width = 0.08;
uniform float selection_gap = 0.0;
uniform float rotation_speed = 0.1;
uniform vec2 seed = vec2(0.);
uniform float size = 0.4;
uniform float striping = 5.;
uniform float ice_amount = .2;
uniform float main_and_second_colors_mixing = .3;
uniform float main_and_second_colors_distribution = .5;
//
const float inner_part = 0.9;
const float inner_alpha = 0.9;

vec4 lighten(vec4 color, float power){
	vec4 missing_color = vec4(1.) - color;
	vec4 result = color + missing_color * power;
	return result;
}
vec4 darken(vec4 color, float power){
	vec4 result = color;
	result.rgb *= 1. - power;
	return result;
}

float get_shift(float y, float x){
	float alpha = atan(y * 1., size) * 2.;
	float R = cos(alpha) * size;
	float psi = atan(x, R) * .5;
	float r = cos(psi) * R;
	return -r;
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
//	float height = cos(asin(norm_x));
	float fy = y;
	float fx = x;
//	float height2 = cos(abs(fx * 3.14));
	float base = sqrt(fx*fx + fy*fy) / 3.;
	
	
	float value = (texture(noise, UV + TIME * 0.1).r) * 0.006;
	base += value;
	COLOR.rgba = vec4(.0);
	vec4 atmosphere = atmosphere_color;
	if (base > outer_radius ){
		atmosphere.a -= clamp(pow(base - outer_radius, 3.) * 50000., 0., 1.) ;
		COLOR = atmosphere;
			

		if (base > selection_from && base < selection_to){
			float selection_power = pow(min(base-selection_from, selection_to-base) / selection_width, 2.) * 4.;
			COLOR = mix(COLOR, selection_color, selection_power);
		}
	}
	else {
//		COLOR.rgba = main_color.rgba;
		float noise_x = ax + TIME * rotation_speed * 1.;
		float noise_y = striping * striping * (ay - cos(x / size) * 0.4 * 1.0);
		vec2 noise_uv = vec2(noise_x, noise_y) * .3;
		noise_uv += seed;
		float power_ = texture(noise, noise_uv).r;
		float npower0 = power_ - main_and_second_colors_distribution;
		if (npower0 > 0.){
			npower0 = npower0 / (1. - main_and_second_colors_distribution);
		}else{
			npower0 = npower0 / (main_and_second_colors_distribution);
		}
		npower0 = sign(npower0) * pow(abs(npower0), main_and_second_colors_mixing);
//		float npower = (power - 0.5) * 2.;
//		float npower2 = sign(npower) * pow(abs(npower), main_and_second_colors_mixing);
//		power = npower2 / 2. + 0.5;
		float power = 0.;
		if (npower0 > 0.){
			power = npower0 * (1. - main_and_second_colors_distribution);
		}else{
			power = npower0 * main_and_second_colors_distribution;
		}
		power += main_and_second_colors_distribution;
		
		COLOR = mix(main_color, second_color, power);
		float reflectivness = mix(main_color_reflectivness, second_color_reflectivness, power);
//		float reflectivness = main_color_reflectivness * (1. - power) + second_color_reflectivness * power;
		
		float range_from_north_pole = pow(pow(y + size * 0.72, 2.) * 2.0 + pow(x, 2.), 0.5);
		float range_from_north_pole2 = pow(pow(y, 2.) * .4 + pow(x, 2.), 0.5);
//		range_from_north_pole = 1000.;
		float range_from_south_pole = size * 2. - y * 1.5 - range_from_north_pole2;
		float icing_power = min(range_from_north_pole, range_from_south_pole) + (power - 0.5) * 0.05;
		
		if (icing_power < ice_amount * .25 ){
//		if (base * y < -0.01 ){
			COLOR = polar_ice_color;
			reflectivness = ice_color_reflectivness;
		}
		
		float darken_power = pow((1. - (outer_radius - base) / outer_radius), 1.5);
		COLOR = darken(COLOR, darken_power * .6);
		float lighten_power = (selection_gap * -y * 45. - darken_power * 0.4) * reflectivness;
		lighten_power = clamp(lighten_power, -0.5, 1.);
		COLOR = lighten(COLOR, lighten_power);
		float inner_radius = radius * inner_part;
//		COLOR = lighten(COLOR, (inner_radius - base) * 1.)
//		if (base < inner_radius ){
//			COLOR = lighten(COLOR, 0.5)
////			COLOR.a *= 0.8;
//		}else{
//		}
		
		COLOR = lighten(COLOR, (power_ - 0.5) * 0.5);
		COLOR = darken(COLOR, (0.5 - power_) * 0.5);
	}
	COLOR.rgb = mix(COLOR.rgb, atmosphere.rgb, atmosphere.a);
	COLOR = clamp(COLOR, vec4(0.), vec4(1.));
}