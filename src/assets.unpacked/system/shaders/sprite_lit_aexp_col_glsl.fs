FSH��� s_tex    screenSz   s_light    s_light_overlay    lightInf   aexp   colors     varying highp vec4 v_color0;
varying highp vec2 v_texcoord0;
uniform sampler2D s_tex;
uniform highp vec4 screenSz;
uniform sampler2D s_light;
uniform sampler2D s_light_overlay;
uniform highp vec4 lightInf;
uniform highp vec4 aexp;
uniform vec4 colors[3];
void main ()
{
  lowp vec4 l_1;
  lowp vec4 px_2;
  lowp vec4 tmpvar_3;
  tmpvar_3 = texture2D (s_tex, v_texcoord0);
  lowp float tmpvar_4;
  tmpvar_4 = clamp ((dot (tmpvar_3.xyz, vec3(0.299, 0.587, 0.114)) * 1.2), 0.0, 1.0);
  lowp vec4 tmpvar_5;
  tmpvar_5 = mix (mix (colors[0], colors[1], clamp (
    (tmpvar_4 * 2.0)
  , 0.0, 1.0)), colors[2], clamp ((
    (tmpvar_4 - 0.5)
   * 2.0), 0.0, 1.0));
  lowp vec4 tmpvar_6;
  tmpvar_6.xyz = mix (tmpvar_3.xyz, tmpvar_5.xyz, tmpvar_5.w);
  tmpvar_6.w = tmpvar_3.w;
  px_2.xyz = tmpvar_6.xyz;
  if ((tmpvar_3.w <= 0.0)) {
    discard;
  };
  px_2.w = float((tmpvar_3.w >= (1.0 - aexp.x)));
  px_2 = (px_2 * v_color0);
  lowp vec4 tmpvar_7;
  highp vec2 texcoord_8;
  texcoord_8 = (gl_FragCoord.xy / screenSz.xy);
  tmpvar_7 = (texture2D (s_light, texcoord_8) + texture2D (s_light_overlay, texcoord_8));
  l_1.w = tmpvar_7.w;
  l_1.xyz = mix (vec3(1.0, 1.0, 1.0), (tmpvar_7.xyz * lightInf.w), lightInf.xyz);
  px_2.xyz = ((px_2.xyz * l_1.xyz) + (l_1.xyz * tmpvar_7.w));
  gl_FragColor = px_2;
}

 