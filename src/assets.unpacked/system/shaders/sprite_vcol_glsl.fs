FSH��� s_tex    �   varying highp vec4 v_color0;
varying highp vec2 v_texcoord0;
uniform sampler2D s_tex;
void main ()
{
  lowp vec4 px_1;
  px_1 = (texture2D (s_tex, v_texcoord0) * v_color0);
  gl_FragColor = px_1;
}

 