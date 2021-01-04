namespace Materials
{
	interface IDyeState
	{
		void Update(int dt);
		array<vec4> GetShades(int idt);
	}

	array<IDyeState@> MakeDyeStates(const array<Dye@> &in dyes, PlayerRecord@ record = null)
	{
		array<IDyeState@> ret;
		ret.resize(dyes.length());
		for (uint i = 0; i < dyes.length(); i++)
			@ret[i] = dyes[i].MakeDyeState(record);
		return ret;
	}

	array<IDyeState@> MakeDyeStates(PlayerRecord@ record)
	{
		return MakeDyeStates(record.colors, record);
	}
}
