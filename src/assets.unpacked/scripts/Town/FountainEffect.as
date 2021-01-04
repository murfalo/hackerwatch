namespace Fountain
{
	class Effect
	{
		string m_id;
		uint m_idHash;
		int m_level;
		int m_favor;
		string m_flag;
		array<Modifiers::Modifier@> m_modifiers;
	}

	array<uint> CurrentEffects;
	array<Effect@> AvailableEffects;

	Modifiers::ModifierList@ Modifiers;

	void ClearEffects()
	{
		CurrentEffects.removeRange(0, CurrentEffects.length());
	}

	void RefreshModifiers(Modifiers::ModifierList@ list)
	{
		if (Modifiers is null)
			return;

		list.Remove(Modifiers);
		list.Add(Modifiers);

		Modifiers.Clear();

		int favor = 0;
		for (uint i = 0; i < CurrentEffects.length(); i++)
		{
			auto effect = GetEffect(CurrentEffects[i]);
			if (effect is null)
			{
				PrintError("Couldn't find effect with ID " + CurrentEffects[i] + " for modifiers");
				continue;
			}

			favor += effect.m_favor;

			for (uint j = 0; j < effect.m_modifiers.length(); j++)
				Modifiers.Add(effect.m_modifiers[j]);
		}

		if (favor < 0)
		{
			SValueBuilder builderGold;
			builderGold.PushDictionary();
			builderGold.PushFloat("scale", 1.0f + 0.05f * -favor);
			builderGold.PopDictionary();
			Modifiers.Add(Modifiers::GoldGain(UnitPtr(), builderGold.Build()));

			SValueBuilder builderExp;
			builderExp.PushDictionary();
			builderExp.PushFloat("mul", 1.0f + 0.05f * -favor);
			builderExp.PopDictionary();
			Modifiers.Add(Modifiers::Experience(UnitPtr(), builderExp.Build()));
		}
	}

	bool HasEffect(const string &in effect)
	{
		return HasEffect(HashString(effect));
	}

	bool HasEffect(uint effect)
	{
		return CurrentEffects.find(effect) != -1;
	}

	void ApplyEffect(const string &in effect)
	{
		ApplyEffect(HashString(effect));
	}

	void ApplyEffect(uint effect)
	{
		if (!HasEffect(effect))
			CurrentEffects.insertLast(effect);
	}

	Effect@ GetEffect(const string &in effect)
	{
		return GetEffect(HashString(effect));
	}

	Effect@ GetEffect(uint effect)
	{
		for (uint i = 0; i < AvailableEffects.length(); i++)
		{
			if (AvailableEffects[i].m_idHash == effect)
				return AvailableEffects[i];
		}
		return null;
	}

	void Clear()
	{
		AvailableEffects.removeRange(0, AvailableEffects.length());
	}

	void AddWishFile(SValue@ sval)
	{
		auto arr = sval.GetArray();
		for (uint i = 0; i < arr.length(); i++)
		{
			auto svEffect = arr[i];

			Effect@ newEffect = Effect();
			newEffect.m_id = GetParamString(UnitPtr(), svEffect, "id");
			newEffect.m_idHash = HashString(newEffect.m_id);
			newEffect.m_level = GetParamInt(UnitPtr(), svEffect, "level");
			newEffect.m_favor = GetParamInt(UnitPtr(), svEffect, "favor");
			newEffect.m_flag = GetParamString(UnitPtr(), svEffect, "flag", false);
			newEffect.m_modifiers = Modifiers::LoadModifiers(UnitPtr(), svEffect, "", Modifiers::SyncVerb::Wish, newEffect.m_idHash);
			AvailableEffects.insertLast(newEffect);
		}
	}
}
