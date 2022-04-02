shader_type canvas_item;
uniform sampler2D noise;

uniform vec4 main_color: hint_color = vec4(1., 0., 0., 1.);
uniform vec4 second_color: hint_color = vec4(1., 0., 0., 1.);
uniform vec4 atmosphere_color: hint_color = vec4(0., 0., .9, .3);
uniform float size = 0.4;
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
	float norm_x = clamp(x / size, -1, 1);
	float height = cos(asin(norm_x));
	float fy = y;
	float fx = x;
	float height2 = cos(abs(fx * 3.14));
	float base = sqrt(fx*fx + fy*fy) / 3.;
	
	float value = (texture(noise, UV + TIME * 0.1).r) * 0.004;
	base += value;
	COLOR.rgba = vec4(.0);
	float outer_radius = radius;
	vec4 atmosphere = atmosphere_color;
	if (base > outer_radius ){
		atmosphere.a -= clamp(pow(base - outer_radius, 3.) * 50000., 0., 1.) ;
		COLOR = atmosphere;
	}
	else {
//		COLOR.rgba = main_color.rgba;
		float power = texture(noise, vec2(ax + TIME * 0.1, ay * 5. - cos(x) * 10.) * .3).r;
		float npower = (power - 0.5) * 2.;
		float npower2 = sign(npower) * pow(abs(npower), 0.4);
		power = npower2 / 2. + 0.5;
		COLOR = mix(main_color, second_color, power);
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
	COLOR = clamp(COLOR, vec4(0.), vec4(1.));
}