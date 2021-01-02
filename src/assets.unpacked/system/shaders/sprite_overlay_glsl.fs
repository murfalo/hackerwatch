FSH��� s_tex    s_light    screenSz     varying highp vec4 v_color0;
varying highp vec2 v_texcoord0;
uniform sampler2D s_tex;
uniform sampler2D s_light;
uniform highp vec4 screenSz;
void main ()
{
  lowp vec4 tmpvar_1;
  highp vec2 P_2;
  P_2 = (gl_FragCoord.xy / screenSz.xy);
  tmpvar_1 = texture2D (s_light, P_2);
  lowp vec4 tmpvar_3;
  tmpvar_3.xyz = (((v_color0.xyz + 
    (v_color0.xyz * tmpvar_1.xyz)
  ) + (tmpvar_1.xyz * tmpvar_1.w)) / 2.0);
  tmpvar_3.w = clamp ((texture2D (s_tex, v_texcoord0).w * v_color0.w), 0.0, 1.0);
  gl_FragColor = tmpvar_3;
}

 