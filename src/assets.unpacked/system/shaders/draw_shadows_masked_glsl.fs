FSH���I s_mask    screenSz   5  varying highp vec4 v_color0;
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
  gl_FragColor = v_color0;
}

 