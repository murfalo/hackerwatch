FSH��� s_tex    �   varying highp vec4 v_color0;
varying highp vec2 v_texcoord0;
uniform sampler2D s_tex;
void main ()
{
  lowp vec4 tmpvar_1;
  tmpvar_1.xyz = v_color0.xyz;
  tmpvar_1.w = texture2D (s_tex, v_texcoord0).w;
  gl_FragColor = tmpvar_1;
}

 