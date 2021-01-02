class AnnounceParams
{
	string m_text = "";
	string m_font = "gui/fonts/arial11.fnt";
	vec2 m_anchor = vec2(0.5, 0.7);
	int m_time = 1000;
	int m_fadeTime = 250;
	vec4 m_color = vec4(1, 1, 1, 1);
	bool m_override = false;
	int m_align = 0;
}
