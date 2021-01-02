VSH��� u_modelViewProj   color   w  attribute highp vec3 a_position;
attribute highp vec2 a_texcoord0;
varying highp vec4 v_color0;
varying highp vec2 v_texcoord0;
uniform highp mat4 u_modelViewProj;
uniform highp vec4 color;
void main ()
{
  highp vec4 tmpvar_1;
  tmpvar_1.w = 1.0;
  tmpvar_1.xyz = a_position;
  gl_Position = (u_modelViewProj * tmpvar_1);
  v_texcoord0 = a_texcoord0;
  v_color0 = color;
}

 