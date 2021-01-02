FSH��� s_tex    multiColors   colors   -  varying highp vec4 v_color0;
varying highp vec2 v_texcoord0;
uniform sampler2D s_tex;
uniform vec4 multiColors[24];
uniform vec4 colors[3];
void main ()
{
  lowp vec4 px_1;
  lowp vec4 tmpvar_2;
  tmpvar_2 = texture2D (s_tex, v_texcoord0);
  px_1 = tmpvar_2;
  bool tmpvar_3;
  tmpvar_3 = bool(1);
  lowp vec4 tmpvar_4;
  lowp float tmpvar_5;
  tmpvar_5 = clamp ((tmpvar_2.w * 1000.0), 0.0, 1.0);
  if ((tmpvar_2.w > 0.8888)) {
    lowp float tmpvar_6;
    tmpvar_6 = clamp ((dot (tmpvar_2.xyz, vec3(0.299, 0.587, 0.114)) * 1.2), 0.0, 1.0);
    lowp vec4 tmpvar_7;
    tmpvar_7.xyz = mix (mix (multiColors[21], multiColors[22], clamp (
      (tmpvar_6 * 2.0)
    , 0.0, 1.0)), multiColors[23], clamp ((
      (tmpvar_6 - 0.5)
     * 2.0), 0.0, 1.0)).xyz;
    tmpvar_7.w = tmpvar_5;
    tmpvar_4 = tmpvar_7;
    tmpvar_3 = bool(0);
  } else {
    if ((tmpvar_2.w > 0.7777)) {
      lowp float tmpvar_8;
      tmpvar_8 = clamp ((dot (tmpvar_2.xyz, vec3(0.299, 0.587, 0.114)) * 1.2), 0.0, 1.0);
      lowp vec4 tmpvar_9;
      tmpvar_9.xyz = mix (mix (multiColors[18], multiColors[19], clamp (
        (tmpvar_8 * 2.0)
      , 0.0, 1.0)), multiColors[20], clamp ((
        (tmpvar_8 - 0.5)
       * 2.0), 0.0, 1.0)).xyz;
      tmpvar_9.w = tmpvar_5;
      tmpvar_4 = tmpvar_9;
      tmpvar_3 = bool(0);
    } else {
      if ((tmpvar_2.w > 0.6666)) {
        lowp float tmpvar_10;
        tmpvar_10 = clamp ((dot (tmpvar_2.xyz, vec3(0.299, 0.587, 0.114)) * 1.2), 0.0, 1.0);
        lowp vec4 tmpvar_11;
        tmpvar_11.xyz = mix (mix (multiColors[15], multiColors[16], clamp (
          (tmpvar_10 * 2.0)
        , 0.0, 1.0)), multiColors[17], clamp ((
          (tmpvar_10 - 0.5)
         * 2.0), 0.0, 1.0)).xyz;
        tmpvar_11.w = tmpvar_5;
        tmpvar_4 = tmpvar_11;
        tmpvar_3 = bool(0);
      } else {
        if ((tmpvar_2.w > 0.5555)) {
          lowp float tmpvar_12;
          tmpvar_12 = clamp ((dot (tmpvar_2.xyz, vec3(0.299, 0.587, 0.114)) * 1.2), 0.0, 1.0);
          lowp vec4 tmpvar_13;
          tmpvar_13.xyz = mix (mix (multiColors[12], multiColors[13], clamp (
            (tmpvar_12 * 2.0)
          , 0.0, 1.0)), multiColors[14], clamp ((
            (tmpvar_12 - 0.5)
           * 2.0), 0.0, 1.0)).xyz;
          tmpvar_13.w = tmpvar_5;
          tmpvar_4 = tmpvar_13;
          tmpvar_3 = bool(0);
        } else {
          if ((tmpvar_2.w > 0.4444)) {
            lowp float tmpvar_14;
            tmpvar_14 = clamp ((dot (tmpvar_2.xyz, vec3(0.299, 0.587, 0.114)) * 1.2), 0.0, 1.0);
            lowp vec4 tmpvar_15;
            tmpvar_15.xyz = mix (mix (multiColors[9], multiColors[10], clamp (
              (tmpvar_14 * 2.0)
            , 0.0, 1.0)), multiColors[11], clamp ((
              (tmpvar_14 - 0.5)
             * 2.0), 0.0, 1.0)).xyz;
            tmpvar_15.w = tmpvar_5;
            tmpvar_4 = tmpvar_15;
            tmpvar_3 = bool(0);
          } else {
            if ((tmpvar_2.w > 0.3333)) {
              lowp float tmpvar_16;
              tmpvar_16 = clamp ((dot (tmpvar_2.xyz, vec3(0.299, 0.587, 0.114)) * 1.2), 0.0, 1.0);
              lowp vec4 tmpvar_17;
              tmpvar_17.xyz = mix (mix (multiColors[6], multiColors[7], clamp (
                (tmpvar_16 * 2.0)
              , 0.0, 1.0)), multiColors[8], clamp ((
                (tmpvar_16 - 0.5)
               * 2.0), 0.0, 1.0)).xyz;
              tmpvar_17.w = tmpvar_5;
              tmpvar_4 = tmpvar_17;
              tmpvar_3 = bool(0);
            } else {
              if ((tmpvar_2.w > 0.2222)) {
                lowp float tmpvar_18;
                tmpvar_18 = clamp ((dot (tmpvar_2.xyz, vec3(0.299, 0.587, 0.114)) * 1.2), 0.0, 1.0);
                lowp vec4 tmpvar_19;
                tmpvar_19.xyz = mix (mix (multiColors[3], multiColors[4], clamp (
                  (tmpvar_18 * 2.0)
                , 0.0, 1.0)), multiColors[5], clamp ((
                  (tmpvar_18 - 0.5)
                 * 2.0), 0.0, 1.0)).xyz;
                tmpvar_19.w = tmpvar_5;
                tmpvar_4 = tmpvar_19;
                tmpvar_3 = bool(0);
              } else {
                if ((tmpvar_2.w > 0.1111)) {
                  lowp float tmpvar_20;
                  tmpvar_20 = clamp ((dot (tmpvar_2.xyz, vec3(0.299, 0.587, 0.114)) * 1.2), 0.0, 1.0);
                  lowp vec4 tmpvar_21;
                  tmpvar_21.xyz = mix (mix (multiColors[0], multiColors[1], clamp (
                    (tmpvar_20 * 2.0)
                  , 0.0, 1.0)), multiColors[2], clamp ((
                    (tmpvar_20 - 0.5)
                   * 2.0), 0.0, 1.0)).xyz;
                  tmpvar_21.w = tmpvar_5;
                  tmpvar_4 = tmpvar_21;
                  tmpvar_3 = bool(0);
                };
              };
            };
          };
        };
      };
    };
  };
  if (tmpvar_3) {
    lowp vec4 tmpvar_22;
    tmpvar_22.xyz = tmpvar_2.xyz;
    tmpvar_22.w = tmpvar_5;
    tmpvar_4 = tmpvar_22;
    tmpvar_3 = bool(0);
  };
  lowp float tmpvar_23;
  tmpvar_23 = clamp ((dot (tmpvar_4.xyz, vec3(0.299, 0.587, 0.114)) * 1.2), 0.0, 1.0);
  lowp vec4 tmpvar_24;
  tmpvar_24 = mix (mix (colors[0], colors[1], clamp (
    (tmpvar_23 * 2.0)
  , 0.0, 1.0)), colors[2], clamp ((
    (tmpvar_23 - 0.5)
   * 2.0), 0.0, 1.0));
  lowp vec4 tmpvar_25;
  tmpvar_25.xyz = mix (tmpvar_4.xyz, tmpvar_24.xyz, tmpvar_24.w);
  tmpvar_25.w = tmpvar_4.w;
  px_1 = (tmpvar_25 * v_color0);
  gl_FragColor = px_1;
}

 