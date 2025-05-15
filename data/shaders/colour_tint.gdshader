shader_type canvas_item;

uniform vec4 colour : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float fade : hint_range(0.0, 1.0) = 1.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 main_texture = texture(TEXTURE, UV);
	
	main_texture.rgb = main_texture.rgb * colour.rgb * fade;
	main_texture.a *= fade;
	
	COLOR = main_texture;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
