FSH��� s_tex    screenSz   s_light    s_light_overlay    s_decal    lightInf   aexp   �  varying highp vec4 v_color0;
varying highp vec2 v_texcoord0;
uniform sampler2D s_tex;
uniform highp vec4 screenSz;
uniform sampler2D s_light;
uniform sampler2D s_light_overlay;
uniform sampler2D s_decal;
uniform highp vec4 lightInf;
uniform highp vec4 aexp;
void main ()
{
  lowp vec4 l_1;
  lowp vec4 px_2;
  lowp vec4 tmpvar_3;
  tmpvar_3 = texture2D (s_tex, v_texcoord0);
  px_2.xyz = tmpvar_3.xyz;
  if ((tmpvar_3.w <= 0.0)) {
    discard;
  };
  px_2.w = float((tmpvar_3.w >= (1.0 - aexp.x)));
  px_2 = (px_2 * v_color0);
  lowp vec4 tmpvar_4;
  highp vec2 P_5;
  P_5 = (gl_FragCoord.xy / screenSz.xy);
  tmpvar_4 = texture2D (s_decal, P_5);
  if ((tmpvar_4.w > 0.0)) {
    px_2.xyz = (((
      (4.0 * px_2.xyz)
     * 
      (tmpvar_4.xyz * tmpvar_4.xyz)
    ) + pow (px_2.xyz, vec3(5.0, 5.0, 5.0))) + (0.3 * tmpvar_4.xyz));
  };
  lowp vec4 tmpvar_6;
  highp vec2 texcoord_7;
  texcoord_7 = (gl_FragCoord.xy / screenSz.xy);
  tmpvar_6 = (texture2D (s_light, texcoord_7) + texture2D (s_light_overlay, texcoord_7));
  l_1.w = tmpvar_6.w;
  l_1.xyz = mix (vec3(1.0, 1.0, 1.0), (tmpvar_6.xyz * lightInf.w), lightInf.xyz);
  px_2.xyz = ((px_2.xyz * l_1.xyz) + (l_1.xyz * tmpvar_6.w));
  gl_FragColor = px_2;
}

 