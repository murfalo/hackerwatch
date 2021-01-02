FSH��� s_tex    s_mask    screenSz   /  varying highp vec4 v_color0;
varying highp vec2 v_texcoord0;
uniform sampler2D s_tex;
uniform sampler2D s_mask;
uniform highp vec4 screenSz;
void main ()
{
  highp vec2 tmpvar_1;
  tmpvar_1 = (gl_FragCoord.xy / screenSz.xy);
  lowp vec4 tmpvar_2;
  tmpvar_2 = texture2D (s_mask, tmpvar_1);
  if ((tmpvar_2.x < 0.5)) {
    discard;
  };
  lowp vec4 tmpvar_3;
  tmpvar_3 = texture2D (s_tex, v_texcoord0);
  if ((tmpvar_3.w < 0.5)) {
    discard;
  };
  lowp vec4 tmpvar_4;
  tmpvar_4.xyz = v_color0.xyz;
  tmpvar_4.w = tmpvar_3.w;
  gl_FragColor = tmpvar_4;
}

 