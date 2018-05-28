#ifdef GL_ES
precision mediump float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
uniform sampler2D u_texture;

void main()
{
	vec4 normalColor = v_fragmentColor * texture2D(CC_Texture0, v_texCoord);
        normalColor.r = normalColor.r;
        normalColor.g = normalColor.g;
        normalColor.b = normalColor.b;
        gl_FragColor = normalColor;
}

