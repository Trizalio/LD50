shader_type canvas_item;
uniform sampler2D noise;

uniform vec4 main_color: hint_color = vec4(1., 0., 0., 1.);
uniform vec4 second_color: hint_color = vec4(1., 0., 0., 1.);
uniform vec4 polar_ice_color: hint_color = vec4(vec3(0.8), 1.);
uniform vec4 atmosphere_color: hint_color = vec4(0., 0., .9, .3);
uniform vec4 selection_color: hint_color = vec4(0.5, 0.5, .0, .6);
uniform float selection_width = 0.08;
uniform float selection_gap = 0.0;
uniform float selection_speed = 0.4;
//uniform float selection_power = 1.0;
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
	
	float phase = TIME * selection_speed;
	float elipsic_base = pow(
		pow(y + sin(phase) * selection_to * 2., 2.) + 
		pow(x, 2.) * 0.1, 0.5
	) * (2.1 - abs(cos(phase)) * .9);
	
	float value = (texture(noise, UV + TIME * 0.1).r) * 0.006;
	base += value;
	COLOR.rgba = vec4(.0);
	vec4 atmosphere = atmosphere_color;
	if (base > outer_radius ){
		atmosphere.a -= clamp(pow(base - outer_radius, 3.) * 50000., 0., 1.) ;
		COLOR = atmosphere;
			
//		if (elipsic_base > selection_from && elipsic_base < selection_to){
//			float selection_power = 1.;
//			COLOR = mix(COLOR, selection_color, selection_power);
////			COLOR.rgba = selection_color;
//		}

		if (base > selection_from && base < selection_to){
			float selection_power = pow(min(base-selection_from, selection_to-base) / selection_width, 2.) * 4.;
			COLOR = mix(COLOR, selection_color, selection_power);
		}
	}
	else {
//		COLOR.rgba = main_color.rgba;
		float noise_x = ax + TIME * rotation_speed;
		float noise_y = striping * (ay - cos(x / size) * size);
//		float noise_y = ay * striping - cos(x / size) * striping * 0.5;
		vec2 noise_uv = vec2(noise_x, noise_y) * .3;
		noise_uv += seed;
		float power = texture(noise, noise_uv).r;
		float npower0 = power - main_and_second_colors_distribution;
		if (npower0 > 0.){
			npower0 = npower0 / (1. - main_and_second_colors_distribution);
		}else{
			npower0 = npower0 / (main_and_second_colors_distribution);
		}
		npower0 = sign(npower0) * pow(abs(npower0), main_and_second_colors_mixing);
//		float npower = (power - 0.5) * 2.;
//		float npower2 = sign(npower) * pow(abs(npower), main_and_second_colors_mixing);
//		power = npower2 / 2. + 0.5;
		if (npower0 > 0.){
			power = npower0 * (1. - main_and_second_colors_distribution);
		}else{
			power = npower0 * main_and_second_colors_distribution;
		}
		power += main_and_second_colors_distribution;
		
		COLOR = mix(main_color, second_color, power);
		
		float range_from_pole = pow(pow(abs(y + 0.3), 2.) + pow(abs(x), 2.) * .1, 0.5) * (0.2 + power * 0.8);
		if (range_from_pole < ice_amount * .10 ){
//		if (base * y < -0.01 ){
			COLOR.r = 1.;
			COLOR = polar_ice_color;
		}
		
		float darken_power = pow((1. - (outer_radius - base) / outer_radius), 1.5);
		COLOR = darken(COLOR, darken_power * .6);
//		COLOR = lighten(COLOR, texture(noise, vec2(ax + TIME * 0.1, ay * 5. - cos(x) * 10.) * .3).r * .7);
		float inner_radius = radius * inner_part;
//		COLOR = lighten(COLOR, (inner_radius - base) * 1.)
//		if (base < inner_radius ){
//			COLOR = lighten(COLOR, 0.5)
////			COLOR.a *= 0.8;
//		}else{
//		}
		
	}
	COLOR.rgb = mix(COLOR.rgb, atmosphere.rgb, atmosphere.a);
////
//	if (base > selection_from && base < selection_to){
////		COLOR.rgb = mix(COLOR.rgb, second_color.rgb, second_color.a);
////		COLOR.rgb = vec3(1.);
//		COLOR = mix(COLOR, selection_color, selection_power);
////		COLOR.rgba = selection_color * selection_power;
//	}
////	float elipsic_base = pow(pow(abs(y), 2.) + pow(abs(x), 2.) * .116, 0.5) * 2.;
//	float y_power = .0001;
//	float x_power = 1.;
//	float scale = 1. / pow((x_power + y_power) / 2., 0.5);
//	float elipsic_base2 = pow(pow(y, 2.) * y_power + pow(x, 2.) * x_power, 0.5) * scale / 3. * scale ;
////	float elipsic_base2 = pow(pow(y + phase * selection_to * 2.5, 2.) + pow(x, 2.) * 0.1, 0.5) * (4.1 - abs(cos(TIME)) * 3.0);
//
//	if (elipsic_base2 > selection_from && elipsic_base2 < selection_to){
//		COLOR.rgba = selection_color;
//	}
//	if (y + sin(phase) * selection_to * 2. > 0.){
//	float selection_power = 1.;
//	if (y + sin(phase) * selection_to * 2. > 0. && elipsic_base > selection_from && elipsic_base < selection_to){
//		COLOR = mix(COLOR, selection_color, selection_power);
////		COLOR.rgba = selection_color * selection_power;
//	}
//
	COLOR = clamp(COLOR, vec4(0.), vec4(1.));
}