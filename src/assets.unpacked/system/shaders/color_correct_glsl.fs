FSHo>< s_tex    colorCorrect   	  varying highp vec2 v_texcoord0;
uniform sampler2D s_tex;
uniform highp vec4 colorCorrect;
void main ()
{
  lowp vec3 px_1;
  highp vec2 tmpvar_2;
  tmpvar_2 = (v_texcoord0 - 0.5);
  highp float tmpvar_3;
  tmpvar_3 = dot (tmpvar_2, tmpvar_2);
  highp vec2 tmpvar_4;
  tmpvar_4 = (v_texcoord0 + ((tmpvar_2 * 
    (tmpvar_3 + ((colorCorrect.w * tmpvar_3) * tmpvar_3))
  ) * colorCorrect.w));
  if ((((
    (tmpvar_4.x > 0.0)
   && 
    (tmpvar_4.y > 0.0)
  ) && (tmpvar_4.x < 1.0)) && (tmpvar_4.y < 1.0))) {
    px_1 = texture2D (s_tex, tmpvar_4).xyz;
  };
  px_1 = (((
    (pow (px_1, (1.0/(colorCorrect.xxx))) - 0.5)
   * colorCorrect.z) + 0.5) + colorCorrect.y);
  lowp vec4 tmpvar_5;
  tmpvar_5.w = 1.0;
  tmpvar_5.xyz = clamp (px_1, 0.0, 1.0);
  gl_FragColor = tmpvar_5;
}

 