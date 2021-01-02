FSHo>< s_tex    s_xray    vignetteColor   texSz   offset      varying highp vec2 v_texcoord0;
uniform sampler2D s_tex;
uniform sampler2D s_xray;
uniform highp vec4 vignetteColor;
uniform highp vec4 texSz;
uniform highp vec4 offset;
void main ()
{
  lowp vec3 px_1;
  highp vec2 tmpvar_2;
  tmpvar_2 = clamp ((v_texcoord0 + offset.xy), 0.0, 1.0);
  lowp vec4 tmpvar_3;
  tmpvar_3 = texture2D (s_xray, tmpvar_2);
  px_1 = ((texture2D (s_tex, tmpvar_2).xyz * (1.0 - tmpvar_3.w)) + (tmpvar_3.xyz * tmpvar_3.w));
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