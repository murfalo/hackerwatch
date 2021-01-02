FSHo>< s_tex    
s_displace    s_glow    vignetteColor   texSz   offset   9  varying highp vec2 v_texcoord0;
uniform sampler2D s_tex;
uniform sampler2D s_displace;
uniform sampler2D s_glow;
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
  px_1 = (texture2D (s_tex, tmpvar_3).xyz + texture2D (s_glow, tmpvar_3).xyz);
  highp vec2 tmpvar_4;
  tmpvar_4.x = v_texcoord0.x;
  tmpvar_4.y = (-(texSz.w) + (v_texcoord0.y * texSz.y));
  lowp vec3 tmpvar_5;
  tmpvar_5 = mix (px_1, ((vignetteColor.xyz * 
    dot (px_1, vignetteColor.xyz)
  ) + vignetteColor.xyz), (clamp (
    pow (((1.0 - clamp (
      pow ((15.0 * ((
        (v_texcoord0.x * (1.0 - v_texcoord0.x))
       * tmpvar_4.y) * (1.0 - tmpvar_4.y))), 0.575)
    , 0.0, 1.0)) + 0.1), 4.0)
  , 0.0, 1.0) * vignetteColor.w));
  px_1 = tmpvar_5;
  lowp vec4 tmpvar_6;
  tmpvar_6.w = 1.0;
  tmpvar_6.xyz = tmpvar_5;
  gl_FragColor = tmpvar_6;
}

 