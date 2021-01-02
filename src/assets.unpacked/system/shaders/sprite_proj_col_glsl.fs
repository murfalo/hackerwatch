FSH� �	 color   screenSz   lightInf   s_tex    s_light    s_light2    s_light_overlay    s_shadowInfo    colors   	  varying highp vec2 v_texcoord0;
varying highp vec2 v_texcoord1;
uniform highp vec4 color;
uniform highp vec4 screenSz;
uniform highp vec4 lightInf;
uniform sampler2D s_tex;
uniform sampler2D s_light;
uniform sampler2D s_light2;
uniform sampler2D s_light_overlay;
uniform sampler2D s_shadowInfo;
uniform vec4 colors[3];
void main ()
{
  lowp vec4 l_1;
  lowp vec4 tmpvar_2;
  tmpvar_2 = (texture2D (s_tex, v_texcoord0) * color);
  lowp vec4 tmpvar_3;
  highp vec2 tmpvar_4;
  tmpvar_4 = (gl_FragCoord.xy / screenSz.xy);
  tmpvar_3 = texture2D (s_light_overlay, tmpvar_4);
  lowp vec4 tmpvar_5;
  tmpvar_5 = (texture2D (s_light, tmpvar_4) + tmpvar_3);
  l_1 = tmpvar_5;
  lowp float tmpvar_6;
  tmpvar_6 = clamp ((dot (tmpvar_2.xyz, vec3(0.299, 0.587, 0.114)) * 1.2), 0.0, 1.0);
  lowp vec4 tmpvar_7;
  tmpvar_7 = mix (mix (colors[0], colors[1], clamp (
    (tmpvar_6 * 2.0)
  , 0.0, 1.0)), colors[2], clamp ((
    (tmpvar_6 - 0.5)
   * 2.0), 0.0, 1.0));
  lowp vec3 tmpvar_8;
  tmpvar_8 = mix (tmpvar_2.xyz, tmpvar_7.xyz, tmpvar_7.w);
  lowp vec4 tmpvar_9;
  tmpvar_9.xyz = tmpvar_8;
  tmpvar_9.w = tmpvar_2.w;
  if ((v_texcoord1.x < 32.0)) {
    lowp vec4 ls_10;
    highp vec2 tmpvar_11;
    tmpvar_11.x = gl_FragCoord.x;
    tmpvar_11.y = v_texcoord1.y;
    lowp vec4 tmpvar_12;
    highp vec2 P_13;
    P_13 = (tmpvar_11 / screenSz.xy);
    tmpvar_12 = texture2D (s_shadowInfo, P_13);
    highp float tmpvar_14;
    tmpvar_14 = (1.0 - ((v_texcoord1.x - 10.0) / 22.0));
    if (((v_texcoord1.x < (tmpvar_12.x * 64.0)) || (tmpvar_12.y <= 0.5))) {
      highp vec2 tmpvar_15;
      tmpvar_15.x = gl_FragCoord.x;
      tmpvar_15.y = v_texcoord1.y;
      highp vec2 P_16;
      P_16 = (tmpvar_15 / screenSz.xy);
      ls_10 = texture2D (s_light2, P_16);
    } else {
      highp vec2 tmpvar_17;
      tmpvar_17.x = gl_FragCoord.x;
      tmpvar_17.y = v_texcoord1.y;
      highp vec2 P_18;
      P_18 = (tmpvar_17 / screenSz.xy);
      ls_10 = texture2D (s_light, P_18);
    };
    ls_10 = (ls_10 + tmpvar_3);
    l_1 = mix (tmpvar_5, ls_10, clamp ((tmpvar_14 * 
      (1.0 - ls_10.w)
    ), 0.0, 1.0));
  };
  l_1.xyz = mix (vec3(1.0, 1.0, 1.0), (l_1.xyz * lightInf.w), lightInf.xyz);
  lowp vec4 tmpvar_19;
  tmpvar_19.xyz = ((tmpvar_8 * l_1.xyz) + (l_1.xyz * l_1.w));
  tmpvar_19.w = tmpvar_9.w;
  gl_FragColor = tmpvar_19;
}

 