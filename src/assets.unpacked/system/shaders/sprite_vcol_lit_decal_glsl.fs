FSH��� s_tex    screenSz   s_light    s_light_overlay    s_decal    lightInf   �  varying highp vec4 v_color0;
varying highp vec2 v_texcoord0;
uniform sampler2D s_tex;
uniform highp vec4 screenSz;
uniform sampler2D s_light;
uniform sampler2D s_light_overlay;
uniform sampler2D s_decal;
uniform highp vec4 lightInf;
void main ()
{
  lowp vec4 l_1;
  lowp vec4 px_2;
  px_2 = (texture2D (s_tex, v_texcoord0) * v_color0);
  lowp vec4 tmpvar_3;
  highp vec2 P_4;
  P_4 = (gl_FragCoord.xy / screenSz.xy);
  tmpvar_3 = texture2D (s_decal, P_4);
  if ((tmpvar_3.w > 0.0)) {
    px_2.xyz = (((
      (4.0 * px_2.xyz)
     * 
      (tmpvar_3.xyz * tmpvar_3.xyz)
    ) + pow (px_2.xyz, vec3(5.0, 5.0, 5.0))) + (0.3 * tmpvar_3.xyz));
  };
  lowp vec4 tmpvar_5;
  highp vec2 texcoord_6;
  texcoord_6 = (gl_FragCoord.xy / screenSz.xy);
  tmpvar_5 = (texture2D (s_light, texcoord_6) + texture2D (s_light_overlay, texcoord_6));
  l_1.w = tmpvar_5.w;
  l_1.xyz = mix (vec3(1.0, 1.0, 1.0), (tmpvar_5.xyz * lightInf.w), lightInf.xyz);
  px_2.xyz = ((px_2.xyz * l_1.xyz) + (l_1.xyz * tmpvar_5.w));
  gl_FragColor = px_2;
}

 