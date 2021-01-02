FSHo>< s_tex    
s_displace    vignetteColor   texSz   offset   �  varying highp vec2 v_texcoord0;
uniform sampler2D s_tex;
uniform sampler2D s_displace;
uniform highp vec4 vignetteColor;
uniform highp vec4 texSz;
uniform highp vec4 offset;
void main ()
{
  lowp vec2 tc_1;
  tc_1 = (v_texcoord0 + ((texture2D (s_displace, v_texcoord0).xy - 0.5) * 0.1));
  lowp vec2 tmpvar_2;
  tmpvar_2 = clamp ((tc_1 + offset.xy), 0.0, 1.0);
  tc_1 = tmpvar_2;
  lowp vec4 tmpvar_3;
  tmpvar_3 = texture2D (s_tex, tmpvar_2);
  highp vec2 tmpvar_4;
  tmpvar_4.x = v_texcoord0.x;
  tmpvar_4.y = (-(texSz.w) + (v_texcoord0.y * texSz.y));
  lowp vec4 tmpvar_5;
  tmpvar_5.w = 1.0;
  tmpvar_5.xyz = mix (tmpvar_3.xyz, ((vignetteColor.xyz * 
    dot (tmpvar_3.xyz, vignetteColor.xyz)
  ) + vignetteColor.xyz), (clamp (
    pow (((1.0 - clamp (
      pow ((15.0 * ((
        (v_texcoord0.x * (1.0 - v_texcoord0.x))
       * tmpvar_4.y) * (1.0 - tmpvar_4.y))), 0.575)
    , 0.0, 1.0)) + 0.1), 4.0)
  , 0.0, 1.0) * vignetteColor.w));
  gl_FragColor = tmpvar_5;
}

 