FSHo>< s_tex    color   �   varying highp vec2 v_texcoord0;
uniform sampler2D s_tex;
uniform highp vec4 color;
void main ()
{
  lowp vec4 tmpvar_1;
  tmpvar_1 = texture2D (s_tex, v_texcoord0);
  gl_FragData[0] = (tmpvar_1.x * color);
  gl_FragData[1] = (tmpvar_1.x * color);
}

 