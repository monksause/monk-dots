#version 300 es
precision mediump float;

in vec2 v_texcoord;
uniform sampler2D tex;
out vec4 fragColor;

void main() {
    vec4 c = texture(tex, v_texcoord);

    // Color correction — toned down, not stripped out
    c.r *= 0.98;
    c.g *= 0.95;
    c.b *= 0.90;

    // Brightness — barely touching it
    c.rgb *= 0.94;

    // S-curve contrast — much gentler, won't crush blacks
    // mix() blends between original and full curve so darks are preserved
    vec3 scurve = c.rgb * c.rgb * (3.0 - 2.0 * c.rgb);
    c.rgb = mix(c.rgb, scurve, 0.32);

    fragColor = vec4(c.rgb, c.a);
}
