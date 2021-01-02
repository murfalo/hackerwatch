FSHo>< s_tex    
s_displace    s_xray    vignetteColor   texSz   offset   �  varying highp vec2 v_texcoord0;
uniform sampler2D s_tex;
uniform sampler2D s_displace;
uniform sampler2D s_xray;
uniform highp vec4 vignetteColor;
uniform highp vec4 texSz;
uniform highp vec4 offset;
void main ()
{
  lowp vec3 px_1;
  lowp vec2 tc_2;
  tc_2 = (v_texcoord0 + ((texture2D (s_displace, v_texcoord0).xy - 0.5) * 0.1));
  lowp vec2 tmpvar_3;
  tmpvar_3 = clamp ((tc_2 + offset.xy), 0.0, 1.0);
  tc_2 = tmpvar_3;
  lowp vec4 tmpvar_4;
  tmpvar_4 = texture2D (s_xray, tmpvar_3);
  px_1 = ((texture2D (s_tex, tmpvar_3).xyz * (1.0 - tmpvar_4.w)) + (tmpvar_4.xyz * tmpvar_4.w));
  highp vec2 tmpvar_5;
  tmpvar_5.x = v_texcoord0.x;
  tmpvar_5.y = (-(texSz.w) + (v_texcoord0.y * texSz.y));
  lowp vec3 tmpvar_6;
  tmpvar_6 = mix (px_1, ((vignetteColor.xyz * 
    dot (px_1, vignetteColor.xyz)
  ) + vignetteColor.xyz), (clamp (
    pow (((1.0 - clamp (
      pow ((15.0 * ((
        (v_texcoord0.x * (1.0 - v_texcoord0.x))
       * tmpvar_5.y) * (1.0 - tmpvar_5.y))), 0.575)
    , 0.0, 1.0)) + 0.1), 4.0)
  , 0.0, 1.0) * vignetteColor.w));
  px_1 = tmpvar_6;
  lowp vec4 tmpvar_7;
  tmpvar_7.w = 1.0;
  tmpvar_7.xyz = tmpvar_6;
  gl_FragColor = tmpvar_7;
}

 