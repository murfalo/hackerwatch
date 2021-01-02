class ClassFaceInfo
{
	string m_file;
	Texture2D@ m_texture;

	int m_y;
	int m_count;

	ClassFaceInfo(string charClass)
	{
		SValue@ svalClass = Resources::GetSValue("players/" + charClass + "/char.sval");
		if (svalClass is null)
		{
			PrintError("Couldn't get SValue file for class \"" + charClass + "\"");
			return;
		}

		m_file = GetParamString(UnitPtr(), svalClass, "face-file", false, "gui/icons_faces.tif");
		@m_texture = Resources::GetTexture2D(m_file);

		m_y = GetParamInt(UnitPtr(), svalClass, "face-y");
		m_count = GetParamInt(UnitPtr(), svalClass, "face-count");
	}

	ScriptSprite@ GetSprite(int face)
	{
		return ScriptSprite(m_texture, vec4(face * 24, m_y, 24, 24));
	}
}

ScriptSprite@ GetFaceSprite(const string &in charClass, int face)
{
	PrintError("Deprecated function called: Use ClassFaceInfo class instead!");

	auto faceInfo = ClassFaceInfo(charClass);
	return faceInfo.GetSprite(face);
}
