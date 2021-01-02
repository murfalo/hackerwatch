FSHo>< s_tex    blur   �  varying highp vec2 v_texcoord0;
uniform sampler2D s_tex;
uniform highp vec4 blur;
void main ()
{
  lowp vec4 color_1;
  color_1 = ((texture2D (s_tex, v_texcoord0) * 0.333) + (texture2D (s_tex, (v_texcoord0 + blur.xy)) * 0.199));
  color_1 = (color_1 + (texture2D (s_tex, (v_texcoord0 - blur.xy)) * 0.199));
  highp vec2 tmpvar_2;
  tmpvar_2 = (blur.xy * vec2(2.0, 2.0));
  color_1 = (color_1 + (texture2D (s_tex, (v_texcoord0 + tmpvar_2)) * 0.099));
  color_1 = (color_1 + (texture2D (s_tex, (v_texcoord0 - tmpvar_2)) * 0.099));
  highp vec2 tmpvar_3;
  tmpvar_3 = (blur.xy * vec2(3.0, 3.0));
  color_1 = (color_1 + (texture2D (s_tex, (v_texcoord0 + tmpvar_3)) * 0.031));
  color_1 = (color_1 + (texture2D (s_tex, (v_texcoord0 - tmpvar_3)) * 0.031));
  highp vec2 tmpvar_4;
  tmpvar_4 = (blur.xy * vec2(4.0, 4.0));
  color_1 = (color_1 + (texture2D (s_tex, (v_texcoord0 + tmpvar_4)) * 0.004));
  color_1 = (color_1 + (texture2D (s_tex, (v_texcoord0 - tmpvar_4)) * 0.004));
  gl_FragColor = (color_1 * 1.1);
}

 