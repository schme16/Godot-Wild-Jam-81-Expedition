shader_type canvas_item;

uniform vec4 colour : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float fade : hint_range(0.0, 1.0) = 1.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 main_texture = texture(TEXTURE, UV);
	
	main_texture.rgb = mix(main_texture.rgb, colour.rgb, fade);
	
	COLOR = main_texture;
}
