class GiveKey : IEffect
{
	int m_lock;
	int m_amount;

	GiveKey(UnitPtr unit, SValue& params)
	{
		m_lock = GetParamInt(unit, params, "lock", false);
		m_amount = GetParamInt(unit, params, "amount", false, 1);
	}

	int GetLock()
	{
		return m_lock;
	}

	void SetWeaponInformation(uint weapon) {}

	bool Apply(Actor@ owner, UnitPtr target, vec2 pos, vec2 dir, float intensity, bool husk)
	{
		if (!CanApply(owner, target, pos, dir, intensity))
			return false;

		auto player = cast<Player>(target.GetScriptBehavior());
		if (player !is null)
		{
			int amount = int(m_amount * player.m_record.GetModifiers().KeyGainScale(player));

			int lock = GetLock();

			NetGiveKeyImpl(lock, amount, player);

			string strKeyValue = "";
			if (amount == 1)
				strKeyValue = Resources::GetString(".item.key");
			else
			{
				dictionary params = { { "num", amount } };
				strKeyValue = Resources::GetString(".item.key.plural", params);
			}
			AddFloatingText(FloatingTextType::Pickup, strKeyValue, player.m_unit.GetPosition());

			(Network::Message("PlayerGiveKey") << lock << amount).SendToAll();
		}

		return true;
	}

	bool CanApply(Actor@ owner, UnitPtr target, vec2 pos, vec2 dir, float intensity) override
	{
		return true;
	}
}

void NetGiveKeyImpl(int lock, int amount, PlayerBase@ player)
{
	player.m_record.keys[lock] += amount;
	Stats::Add("key-found-" + lock, amount, player.m_record);
}
