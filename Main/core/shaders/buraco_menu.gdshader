shader_type canvas_item;

uniform sampler2D texture_a;  
uniform sampler2D texture_b;   

uniform vec2 hole_center = vec2(0.5, 0.5);
uniform float hole_width = 0.08;    
uniform float hole_height = 0.04;   
uniform float border_thickness = 0.003; 

void fragment() {
    vec2 uv = UV;
    float half_w = hole_width / 2.0;
    float half_h = hole_height / 2.0;
    
    // Verifica se o pixel TA dentro do retângulo
    bool inside = (uv.x >= hole_center.x - half_w && uv.x <= hole_center.x + half_w &&
                   uv.y >= hole_center.y - half_h && uv.y <= hole_center.y + half_h);
    
    vec4 color;
    if (inside)
        color = texture(texture_a, uv);
    else
        color = texture(texture_b, uv);
    
    // Borda branca quase imperceptível
    float dx = abs(uv.x - hole_center.x);
    float dy = abs(uv.y - hole_center.y);
    float border_w = half_w + border_thickness;
    float border_h = half_h + border_thickness;
    bool on_border = (dx >= half_w && dx <= border_w && dy <= border_h) ||
                     (dy >= half_h && dy <= border_h && dx <= border_w);
    
    if (on_border)
        color = vec4(1.0, 1.0, 1.0, 1.0);  // borda branca peak
    
    COLOR = color;
}