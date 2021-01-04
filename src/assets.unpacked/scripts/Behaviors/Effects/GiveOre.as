class GiveOre : IEffect
{
	int m_amount;
	bool m_pickup;

	GiveOre(UnitPtr unit, SValue& params)
	{
		m_amount = GetParamInt(unit, params, "amount");
		m_pickup = GetParamBool(unit, params, "pickup", false, false);
	}
	
	void SetWeaponInformation(uint weapon) {}

	bool Apply(Actor@ owner, UnitPtr target, vec2 pos, vec2 dir, float intensity, bool husk)
	{
		if (!CanApply(owner, target, pos, dir, intensity))
			return false;

		if (m_pickup)
		{
			auto localPlayer = GetLocalPlayer();
			GiveOreImpl(m_amount, localPlayer, localPlayer is cast<Player>(target.GetScriptBehavior()));
		}
		else
			GiveOreImpl(m_amount, cast<Player>(target.GetScriptBehavior()));

		return true;
	}

	bool CanApply(Actor@ owner, UnitPtr target, vec2 pos, vec2 dir, float intensity) override
	{
		return true;
	}
}

void GiveOreImpl(int amount, Player@ player, bool showFloatingText = true)
{
	if (player is null)
		return;

	amount = roll_round(amount * (player.m_record.GetModifiers().OreGainScale(player) + 0.2f * g_ngp));

	NetGiveOreImpl(amount, player);

	string strOreValue = "";
	if (amount == 1)
		strOreValue = Resources::GetString(".item.ore");
	else
	{
		dictionary params = { { "num", amount } };
		strOreValue = Resources::GetString(".item.ore.plural", params);
	}

	if (showFloatingText)
		AddFloatingText(FloatingTextType::Pickup, strOreValue, player.m_unit.GetPosition());
}

void NetGiveOreImpl(int amount, PlayerBase@ player)
{
	Stats::Add("ore-found", amount, player.m_record);
	Stats::Add("avg-ore-found", amount, player.m_record);

	auto gm = cast<Campaign>(g_gameMode);
	if (gm !is null)
	{
		ivec3 level = CalcLevel(gm.m_levelCount);
		Stats::Add("avg-ore-found-act-" + (level.x + 1), amount, player.m_record);
	}

	player.m_record.runOre += amount;
}
