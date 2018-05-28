#ifdef GL_ES
precision mediump float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;

void main()
{
	//http://www.360doc.com/content/14/0808/13/636843_400316996.shtml
	vec4 color1 = texture2D(CC_Texture0, v_texCoord) * v_fragmentColor;
	gl_FragColor = color1 / (vec4(1,1,1,1)-color1);
    if(gl_FragColor.a > 0.0) {
        gl_FragColor.rgb *= 1.2;
    }
}
