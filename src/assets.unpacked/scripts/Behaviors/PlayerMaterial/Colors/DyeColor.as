namespace Materials
{
	class DyeColorState : IDyeState
	{
		DyeColor@ m_dye;

		DyeColorState(DyeColor@ dye)
		{
			@m_dye = dye;
		}

		void Update(int dt) {}
		array<vec4> GetShades(int idt) { return m_dye.m_shades; }
	}

	class DyeColor : Dye
	{
		array<vec4> m_shades;

		DyeColor(SValue &sval)
		{
			super(sval);

			auto arrShades = GetParamArray(UnitPtr(), sval, "shades");
			for (uint i = 0; i < arrShades.length(); i++)
			{
				string strColor = arrShades[i].GetString();
				vec4 color = ParseColorRGBA(strColor);
				m_shades.insertLast(color);
			}
		}

		IDyeState@ MakeDyeState(PlayerRecord@ record) override
		{
			return DyeColorState(this);
		}
	}
}
