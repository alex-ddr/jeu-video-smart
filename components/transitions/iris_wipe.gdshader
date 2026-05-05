shader_type canvas_item;

// Taille du cercle (1.05 = écran totalement visible, 0.0 = écran tout noir)
uniform float circle_size : hint_range(0.0, 1.05) = 1.05;
// Pour que le cercle reste rond même si l'écran est rectangulaire
uniform float screen_ratio = 1.777; 
// Position du centre du cercle (0.5, 0.5 = milieu de l'écran)
uniform vec2 center = vec2(0.5, 0.5);
// La couleur de la transition
uniform vec4 color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

void fragment() {
	vec2 uv = UV;
	// On corrige le ratio pour éviter que le cercle soit un ovale
	uv.x = (uv.x - center.x) * screen_ratio + center.x;
	
	// On calcule la distance entre le pixel actuel et le centre
	float d = distance(uv, center);
	
	// Si on est en dehors du cercle, on affiche la couleur (noir), sinon c'est transparent
	COLOR.a = step(circle_size, d);
	COLOR.rgb = color.rgb;
}