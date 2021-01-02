FSH��� s_tex    texSz   texBnds   time   H  varying highp vec4 v_color0;
varying highp vec2 v_texcoord0;
uniform sampler2D s_tex;
uniform highp vec4 texSz;
uniform highp vec4 texBnds;
uniform highp vec4 time;
void main ()
{
  highp float tmpvar_1;
  tmpvar_1 = ((sin(
    ((time.x * 6.2832) / 4000.0)
  ) * 2.0) - 1.0);
  if ((tmpvar_1 < 0.0)) {
    discard;
  };
  highp vec2 tmpvar_2;
  tmpvar_2.x = float((v_texcoord0.x >= texBnds.z));
  tmpvar_2.y = float((v_texcoord0.y >= texBnds.w));
  highp vec2 tmpvar_3;
  tmpvar_3 = (vec2(greaterThanEqual (v_texcoord0, texBnds.xy)) - tmpvar_2);
  bool tmpvar_4;
  if (((tmpvar_3.x * tmpvar_3.y) < 1.0)) {
    tmpvar_4 = bool(1);
  } else {
    tmpvar_4 = (texture2D (s_tex, v_texcoord0).w <= 0.5);
  };
  if (!(tmpvar_4)) {
    discard;
  };
  mediump vec4 tmpvar_5;
  tmpvar_5 = (v_color0 * pow (clamp (tmpvar_1, 0.0, 1.0), 20.0));
  highp vec2 tmpvar_6;
  tmpvar_6.y = 0.0;
  tmpvar_6.x = texSz.x;
  highp vec2 pos_7;
  pos_7 = (v_texcoord0 + tmpvar_6);
  highp vec2 tmpvar_8;
  tmpvar_8.x = float((pos_7.x >= texBnds.z));
  tmpvar_8.y = float((pos_7.y >= texBnds.w));
  highp vec2 tmpvar_9;
  tmpvar_9 = (vec2(greaterThanEqual (pos_7, texBnds.xy)) - tmpvar_8);
  bool tmpvar_10;
  if (((tmpvar_9.x * tmpvar_9.y) < 1.0)) {
    tmpvar_10 = bool(1);
  } else {
    tmpvar_10 = (texture2D (s_tex, pos_7).w <= 0.5);
  };
  if (!(tmpvar_10)) {
    gl_FragColor = tmpvar_5;
  } else {
    highp vec2 tmpvar_11;
    tmpvar_11.y = 0.0;
    tmpvar_11.x = -(texSz.x);
    highp vec2 pos_12;
    pos_12 = (v_texcoord0 + tmpvar_11);
    highp vec2 tmpvar_13;
    tmpvar_13.x = float((pos_12.x >= texBnds.z));
    tmpvar_13.y = float((pos_12.y >= texBnds.w));
    highp vec2 tmpvar_14;
    tmpvar_14 = (vec2(greaterThanEqual (pos_12, texBnds.xy)) - tmpvar_13);
    bool tmpvar_15;
    if (((tmpvar_14.x * tmpvar_14.y) < 1.0)) {
      tmpvar_15 = bool(1);
    } else {
      tmpvar_15 = (texture2D (s_tex, pos_12).w <= 0.5);
    };
    if (!(tmpvar_15)) {
      gl_FragColor = tmpvar_5;
    } else {
      highp vec2 tmpvar_16;
      tmpvar_16.x = 0.0;
      tmpvar_16.y = texSz.y;
      highp vec2 pos_17;
      pos_17 = (v_texcoord0 + tmpvar_16);
      highp vec2 tmpvar_18;
      tmpvar_18.x = float((pos_17.x >= texBnds.z));
      tmpvar_18.y = float((pos_17.y >= texBnds.w));
      highp vec2 tmpvar_19;
      tmpvar_19 = (vec2(greaterThanEqual (pos_17, texBnds.xy)) - tmpvar_18);
      bool tmpvar_20;
      if (((tmpvar_19.x * tmpvar_19.y) < 1.0)) {
        tmpvar_20 = bool(1);
      } else {
        tmpvar_20 = (texture2D (s_tex, pos_17).w <= 0.5);
      };
      if (!(tmpvar_20)) {
        gl_FragColor = tmpvar_5;
      } else {
        highp vec2 tmpvar_21;
        tmpvar_21.x = 0.0;
        tmpvar_21.y = -(texSz.y);
        highp vec2 pos_22;
        pos_22 = (v_texcoord0 + tmpvar_21);
        highp vec2 tmpvar_23;
        tmpvar_23.x = float((pos_22.x >= texBnds.z));
        tmpvar_23.y = float((pos_22.y >= texBnds.w));
        highp vec2 tmpvar_24;
        tmpvar_24 = (vec2(greaterThanEqual (pos_22, texBnds.xy)) - tmpvar_23);
        bool tmpvar_25;
        if (((tmpvar_24.x * tmpvar_24.y) < 1.0)) {
          tmpvar_25 = bool(1);
        } else {
          tmpvar_25 = (texture2D (s_tex, pos_22).w <= 0.5);
        };
        if (!(tmpvar_25)) {
          gl_FragColor = tmpvar_5;
        } else {
          gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
        };
      };
    };
  };
}

 