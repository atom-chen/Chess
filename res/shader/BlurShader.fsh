#ifdef GL_ES
precision mediump float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;

uniform vec2 resolution;
uniform float blurRadius;
uniform float sampleNum;


void main(void)
{
    //vec4 col = blur(v_texCoord); //* v_fragmentColor.rgb;
    //gl_FragColor = vec4(col) * v_fragmentColor;

    //this will be our RGBA sum
    vec4 sum = vec4(0.0);

    //our original texcoord for this fragment
    vec2 tc = v_texCoord;

    //the amount to _blur, i.e. how far off center to sample from 
    //1.0 -> _blur by one pixel
    //2.0 -> _blur by two pixels, etc.
    float _blur = 3.0;//blurRadius/resolution; 

    //the direction of our _blur
    //(1.0, 0.0) -> x-axis _blur
    //(0.0, 1.0) -> y-axis _blur
    float hstep = 1.0;//dir.x;
    float vstep = 1.0;//dir.y;

    //apply blurring, using a 9-tap filter with predefined gaussian weights

    sum += texture2D(CC_Texture0, vec2(tc.x - 4.0*_blur*hstep, tc.y - 4.0*_blur*vstep)) * 0.0162162162;
    sum += texture2D(CC_Texture0, vec2(tc.x - 3.0*_blur*hstep, tc.y - 3.0*_blur*vstep)) * 0.0540540541;
    sum += texture2D(CC_Texture0, vec2(tc.x - 2.0*_blur*hstep, tc.y - 2.0*_blur*vstep)) * 0.1216216216;
    sum += texture2D(CC_Texture0, vec2(tc.x - 1.0*_blur*hstep, tc.y - 1.0*_blur*vstep)) * 0.1945945946;

    sum += texture2D(CC_Texture0, vec2(tc.x, tc.y)) * 0.2270270270;

    sum += texture2D(CC_Texture0, vec2(tc.x + 1.0*_blur*hstep, tc.y + 1.0*_blur*vstep)) * 0.1945945946;
    sum += texture2D(CC_Texture0, vec2(tc.x + 2.0*_blur*hstep, tc.y + 2.0*_blur*vstep)) * 0.1216216216;
    sum += texture2D(CC_Texture0, vec2(tc.x + 3.0*_blur*hstep, tc.y + 3.0*_blur*vstep)) * 0.0540540541;
    sum += texture2D(CC_Texture0, vec2(tc.x + 4.0*_blur*hstep, tc.y + 4.0*_blur*vstep)) * 0.0162162162;

    //discard alpha for our simple demo, multiply by vertex color and return
    gl_FragColor = v_fragmentColor * vec4(sum.rgb, 1.0);
}

