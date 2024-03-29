FSH��� s_tex    screenSz   s_light    s_light_overlay    lightInf   aexp   multiColors     varying highp vec4 v_color0;
varying highp vec2 v_texcoord0;
uniform sampler2D s_tex;
uniform highp vec4 screenSz;
uniform sampler2D s_light;
uniform sampler2D s_light_overlay;
uniform highp vec4 lightInf;
uniform highp vec4 aexp;
uniform vec4 multiColors[24];
void main ()
{
  lowp vec4 l_1;
  lowp vec4 px_2;
  lowp vec4 tmpvar_3;
  tmpvar_3 = texture2D (s_tex, v_texcoord0);
  px_2 = tmpvar_3;
  bool tmpvar_4;
  tmpvar_4 = bool(1);
  lowp vec4 tmpvar_5;
  lowp float tmpvar_6;
  tmpvar_6 = clamp ((tmpvar_3.w * 1000.0), 0.0, 1.0);
  if ((tmpvar_3.w > 0.8888)) {
    lowp float tmpvar_7;
    tmpvar_7 = clamp ((dot (tmpvar_3.xyz, vec3(0.299, 0.587, 0.114)) * 1.2), 0.0, 1.0);
    lowp vec4 tmpvar_8;
    tmpvar_8.xyz = mix (mix (multiColors[21], multiColors[22], clamp (
      (tmpvar_7 * 2.0)
    , 0.0, 1.0)), multiColors[23], clamp ((
      (tmpvar_7 - 0.5)
     * 2.0), 0.0, 1.0)).xyz;
    tmpvar_8.w = tmpvar_6;
    tmpvar_5 = tmpvar_8;
    tmpvar_4 = bool(0);
  } else {
    if ((tmpvar_3.w > 0.7777)) {
      lowp float tmpvar_9;
      tmpvar_9 = clamp ((dot (tmpvar_3.xyz, vec3(0.299, 0.587, 0.114)) * 1.2), 0.0, 1.0);
      lowp vec4 tmpvar_10;
      tmpvar_10.xyz = mix (mix (multiColors[18], multiColors[19], clamp (
        (tmpvar_9 * 2.0)
      , 0.0, 1.0)), multiColors[20], clamp ((
        (tmpvar_9 - 0.5)
       * 2.0), 0.0, 1.0)).xyz;
      tmpvar_10.w = tmpvar_6;
      tmpvar_5 = tmpvar_10;
      tmpvar_4 = bool(0);
    } else {
      if ((tmpvar_3.w > 0.6666)) {
        lowp float tmpvar_11;
        tmpvar_11 = clamp ((dot (tmpvar_3.xyz, vec3(0.299, 0.587, 0.114)) * 1.2), 0.0, 1.0);
        lowp vec4 tmpvar_12;
        tmpvar_12.xyz = mix (mix (multiColors[15], multiColors[16], clamp (
          (tmpvar_11 * 2.0)
        , 0.0, 1.0)), multiColors[17], clamp ((
          (tmpvar_11 - 0.5)
         * 2.0), 0.0, 1.0)).xyz;
        tmpvar_12.w = tmpvar_6;
        tmpvar_5 = tmpvar_12;
        tmpvar_4 = bool(0);
      } else {
        if ((tmpvar_3.w > 0.5555)) {
          lowp float tmpvar_13;
          tmpvar_13 = clamp ((dot (tmpvar_3.xyz, vec3(0.299, 0.587, 0.114)) * 1.2), 0.0, 1.0);
          lowp vec4 tmpvar_14;
          tmpvar_14.xyz = mix (mix (multiColors[12], multiColors[13], clamp (
            (tmpvar_13 * 2.0)
          , 0.0, 1.0)), multiColors[14], clamp ((
            (tmpvar_13 - 0.5)
           * 2.0), 0.0, 1.0)).xyz;
          tmpvar_14.w = tmpvar_6;
          tmpvar_5 = tmpvar_14;
          tmpvar_4 = bool(0);
        } else {
          if ((tmpvar_3.w > 0.4444)) {
            lowp float tmpvar_15;
            tmpvar_15 = clamp ((dot (tmpvar_3.xyz, vec3(0.299, 0.587, 0.114)) * 1.2), 0.0, 1.0);
            lowp vec4 tmpvar_16;
            tmpvar_16.xyz = mix (mix (multiColors[9], multiColors[10], clamp (
              (tmpvar_15 * 2.0)
            , 0.0, 1.0)), multiColors[11], clamp ((
              (tmpvar_15 - 0.5)
             * 2.0), 0.0, 1.0)).xyz;
            tmpvar_16.w = tmpvar_6;
            tmpvar_5 = tmpvar_16;
            tmpvar_4 = bool(0);
          } else {
            if ((tmpvar_3.w > 0.3333)) {
              lowp float tmpvar_17;
              tmpvar_17 = clamp ((dot (tmpvar_3.xyz, vec3(0.299, 0.587, 0.114)) * 1.2), 0.0, 1.0);
              lowp vec4 tmpvar_18;
              tmpvar_18.xyz = mix (mix (multiColors[6], multiColors[7], clamp (
                (tmpvar_17 * 2.0)
              , 0.0, 1.0)), multiColors[8], clamp ((
                (tmpvar_17 - 0.5)
               * 2.0), 0.0, 1.0)).xyz;
              tmpvar_18.w = tmpvar_6;
              tmpvar_5 = tmpvar_18;
              tmpvar_4 = bool(0);
            } else {
              if ((tmpvar_3.w > 0.2222)) {
                lowp float tmpvar_19;
                tmpvar_19 = clamp ((dot (tmpvar_3.xyz, vec3(0.299, 0.587, 0.114)) * 1.2), 0.0, 1.0);
                lowp vec4 tmpvar_20;
                tmpvar_20.xyz = mix (mix (multiColors[3], multiColors[4], clamp (
                  (tmpvar_19 * 2.0)
                , 0.0, 1.0)), multiColors[5], clamp ((
                  (tmpvar_19 - 0.5)
                 * 2.0), 0.0, 1.0)).xyz;
                tmpvar_20.w = tmpvar_6;
                tmpvar_5 = tmpvar_20;
                tmpvar_4 = bool(0);
              } else {
                if ((tmpvar_3.w > 0.1111)) {
                  lowp float tmpvar_21;
                  tmpvar_21 = clamp ((dot (tmpvar_3.xyz, vec3(0.299, 0.587, 0.114)) * 1.2), 0.0, 1.0);
                  lowp vec4 tmpvar_22;
                  tmpvar_22.xyz = mix (mix (multiColors[0], multiColors[1], clamp (
                    (tmpvar_21 * 2.0)
                  , 0.0, 1.0)), multiColors[2], clamp ((
                    (tmpvar_21 - 0.5)
                   * 2.0), 0.0, 1.0)).xyz;
                  tmpvar_22.w = tmpvar_6;
                  tmpvar_5 = tmpvar_22;
                  tmpvar_4 = bool(0);
                };
              };
            };
          };
        };
      };
    };
  };
  if (tmpvar_4) {
    lowp vec4 tmpvar_23;
    tmpvar_23.xyz = tmpvar_3.xyz;
    tmpvar_23.w = tmpvar_6;
    tmpvar_5 = tmpvar_23;
    tmpvar_4 = bool(0);
  };
  px_2.xyz = tmpvar_5.xyz;
  if ((tmpvar_5.w <= 0.0)) {
    discard;
  };
  px_2.w = float((tmpvar_5.w >= (1.0 - aexp.x)));
  px_2 = (px_2 * v_color0);
  lowp vec4 tmpvar_24;
  highp vec2 texcoord_25;
  texcoord_25 = (gl_FragCoord.xy / screenSz.xy);
  tmpvar_24 = (texture2D (s_light, texcoord_25) + texture2D (s_light_overlay, texcoord_25));
  l_1.w = tmpvar_24.w;
  l_1.xyz = mix (vec3(1.0, 1.0, 1.0), (tmpvar_24.xyz * lightInf.w), lightInf.xyz);
  px_2.xyz = ((px_2.xyz * l_1.xyz) + (l_1.xyz * tmpvar_24.w));
  gl_FragColor = px_2;
}

 