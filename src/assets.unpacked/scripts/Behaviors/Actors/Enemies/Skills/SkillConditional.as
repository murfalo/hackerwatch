interface ISkillConditional
{
	bool IsAllowed(CompositeActorBehavior@ owner);
}

abstract class SkillConditionalHealth : ISkillConditional
{
	float m_limit;
	SkillConditionalHealth(float limit) { m_limit = limit; }
	bool IsAllowed(CompositeActorBehavior@ owner) { return false; }
}

class CondHealthGreater : SkillConditionalHealth
{
	CondHealthGreater(float limit) { super(limit); }
	bool IsAllowed(CompositeActorBehavior@ owner) override { return owner.m_hp > m_limit; }
}

class CondHealthLess : SkillConditionalHealth
{
	CondHealthLess(float limit) { super(limit); }
	bool IsAllowed(CompositeActorBehavior@ owner) override { return owner.m_hp < m_limit; }
}

class CondHealthGreaterEqual : SkillConditionalHealth
{
	CondHealthGreaterEqual(float limit) { super(limit); }
	bool IsAllowed(CompositeActorBehavior@ owner) override { return owner.m_hp >= m_limit; }
}

class CondHealthLessEqual : SkillConditionalHealth
{
	CondHealthLessEqual(float limit) { super(limit); }
	bool IsAllowed(CompositeActorBehavior@ owner) override { return owner.m_hp <= m_limit; }
}

abstract class SkillConditionalPlayers : ISkillConditional
{
	int m_limit;
	bool m_includeDead;
	
	SkillConditionalPlayers(int limit, bool includeDead) { m_limit = limit; m_includeDead = includeDead; }
	bool IsAllowed(CompositeActorBehavior@ owner) { return false; }
	
	int GetCount()
	{
		int num = 0;
		for (uint i = 0; i < g_players.length(); i++)
		{
			if (g_players[i].peer == 255)
				continue;
			
			if (!m_includeDead && g_players[i].IsDead())
				continue;
			
			num++;
		}
		
		if (m_includeDead)
			num += max(0, GetVarInt("g_extra_players"));
		
		return num;
	}
}

class CondPlayersGreater : SkillConditionalPlayers
{
	CondPlayersGreater(int limit, bool includeDead) { super(limit, includeDead); }
	bool IsAllowed(CompositeActorBehavior@ owner) override { return GetCount() > m_limit; }
}

class CondPlayersLess : SkillConditionalPlayers
{
	CondPlayersLess(int limit, bool includeDead) { super(limit, includeDead); }
	bool IsAllowed(CompositeActorBehavior@ owner) override { return GetCount() < m_limit; }
}

class CondPlayersGreaterEqual : SkillConditionalPlayers
{
	CondPlayersGreaterEqual(int limit, bool includeDead) { super(limit, includeDead); }
	bool IsAllowed(CompositeActorBehavior@ owner) override { return GetCount() >= m_limit; }
}

class CondPlayersLessEqual : SkillConditionalPlayers
{
	CondPlayersLessEqual(int limit, bool includeDead) { super(limit, includeDead); }
	bool IsAllowed(CompositeActorBehavior@ owner) override { return GetCount() <= m_limit; }
}

class CondPlayersEqual : SkillConditionalPlayers
{
	CondPlayersEqual(int limit, bool includeDead) { super(limit, includeDead); }
	bool IsAllowed(CompositeActorBehavior@ owner) override { return GetCount() == m_limit; }
}

class CondPlayersNotEqual : SkillConditionalPlayers
{
	CondPlayersNotEqual(int limit, bool includeDead) { super(limit, includeDead); }
	bool IsAllowed(CompositeActorBehavior@ owner) override { return GetCount() != m_limit; }
}


abstract class SkillConditionalNGP : ISkillConditional
{
	int m_limit;
	
	SkillConditionalNGP(int limit) { m_limit = limit; }
	bool IsAllowed(CompositeActorBehavior@ owner) { return false; }
}

class CondNGPGreater : SkillConditionalNGP
{
	CondNGPGreater(int limit) { super(limit); }
	bool IsAllowed(CompositeActorBehavior@ owner) override { return g_ngp > m_limit; }
}

class CondNGPLess : SkillConditionalNGP
{
	CondNGPLess(int limit) { super(limit); }
	bool IsAllowed(CompositeActorBehavior@ owner) override { return g_ngp < m_limit; }
}

class CondNGPGreaterEqual : SkillConditionalNGP
{
	CondNGPGreaterEqual(int limit) { super(limit); }
	bool IsAllowed(CompositeActorBehavior@ owner) override { return g_ngp >= m_limit; }
}

class CondNGPLessEqual : SkillConditionalNGP
{
	CondNGPLessEqual(int limit) { super(limit); }
	bool IsAllowed(CompositeActorBehavior@ owner) override { return g_ngp <= m_limit; }
}

class CondNGPEqual : SkillConditionalNGP
{
	CondNGPEqual(int limit) { super(limit); }
	bool IsAllowed(CompositeActorBehavior@ owner) override { return g_ngp == m_limit; }
}

class CondNGPNotEqual : SkillConditionalNGP
{
	CondNGPNotEqual(int limit) { super(limit); }
	bool IsAllowed(CompositeActorBehavior@ owner) override { return g_ngp != m_limit; }
}


class CondFlag : ISkillConditional
{
	string m_flag;
	bool m_exists;

	CondFlag(string flag, bool exists)
	{
		m_flag = flag;
		m_exists = exists;
	}

	bool IsAllowed(CompositeActorBehavior@ owner) override 
	{ 
		return g_flags.IsSet(m_flag) == m_exists;
	}
}

class CondCharge : ISkillConditional
{
	bool m_charging;

	CondCharge(bool charging)
	{
		m_charging = charging;
	}

	bool IsAllowed(CompositeActorBehavior@ owner) override 
	{ 
		bool charging = false;
		
		auto movement = cast<ChargeMovement>(owner.m_movement);
		if (movement !is null)
			charging = movement.IsCharging();
	
		return charging == m_charging;
	}
}

class CondCheckBuff : ISkillConditional
{
	uint m_buffHash;
	bool m_value;

	CondCheckBuff(string buff, bool value)
	{
		m_buffHash = HashString(buff);
		m_value = value;
	}

	bool IsAllowed(CompositeActorBehavior@ owner) override 
	{ 
		bool hasBuff = owner.m_buffs.HasBuff(m_buffHash);
		return hasBuff == m_value;
	}
}

class CondCheckBuffTag : CondCheckBuff
{
	uint64 m_tag;

	CondCheckBuffTag(string buff, bool value) 
	{ 
		super("", value); 
		m_tag = ApplyActorBuffTag(0, buff);
	}
	
	bool IsAllowed(CompositeActorBehavior@ owner) override 
	{ 
		bool hasBuffTag = owner.m_buffs.HasTags(m_tag);
		return hasBuffTag == m_value;
	}
}



array<ISkillConditional@>@ LoadSkillConditionals(UnitPtr owner, SValue& params)
{
	auto condArr = GetParamArray(owner, params, "conditional", false);
	if (condArr is null)
		return null;

	array<ISkillConditional@> conditionals;
	for (uint i = 0; i < condArr.length(); i++)
	{
		auto start = condArr[i].GetString();
		if (start == "hp")
		{
			string cond = condArr[++i].GetString();
			float limit = condArr[++i].GetFloat();
			
			if (cond == "gt" || cond == ">")
				conditionals.insertLast(CondHealthGreater(limit));
			else if (cond == "lt" || cond == "<")
				conditionals.insertLast(CondHealthLess(limit));
			else if (cond == "ge" || cond == ">=")
				conditionals.insertLast(CondHealthGreaterEqual(limit));
			else if (cond == "le" || cond == "<=")
				conditionals.insertLast(CondHealthLessEqual(limit));
		}
		else if (start == "players")
		{
			string cond = condArr[++i].GetString();
			int limit = condArr[++i].GetInteger();
			
			if (cond == "gt" || cond == ">")
				conditionals.insertLast(CondPlayersGreater(limit, true));
			else if (cond == "lt" || cond == "<")
				conditionals.insertLast(CondPlayersLess(limit, true));
			else if (cond == "ge" || cond == ">=")
				conditionals.insertLast(CondPlayersGreaterEqual(limit, true));
			else if (cond == "le" || cond == "<=")
				conditionals.insertLast(CondPlayersLessEqual(limit, true));
			else if (cond == "eq" || cond == "==")
				conditionals.insertLast(CondPlayersEqual(limit, true));
			else if (cond == "ne" || cond == "!=")
				conditionals.insertLast(CondPlayersNotEqual(limit, true));
		}
		else if (start == "alive players")
		{
			string cond = condArr[++i].GetString();
			int limit = condArr[++i].GetInteger();
			
			if (cond == "gt" || cond == ">")
				conditionals.insertLast(CondPlayersGreater(limit, false));
			else if (cond == "lt" || cond == "<")
				conditionals.insertLast(CondPlayersLess(limit, false));
			else if (cond == "ge" || cond == ">=")
				conditionals.insertLast(CondPlayersGreaterEqual(limit, false));
			else if (cond == "le" || cond == "<=")
				conditionals.insertLast(CondPlayersLessEqual(limit, false));
			else if (cond == "eq" || cond == "==")
				conditionals.insertLast(CondPlayersEqual(limit, false));
			else if (cond == "ne" || cond == "!=")
				conditionals.insertLast(CondPlayersNotEqual(limit, false));
		}
		else if (start == "ngp")
		{
			string cond = condArr[++i].GetString();
			int limit = condArr[++i].GetInteger();
			
			if (cond == "gt" || cond == ">")
				conditionals.insertLast(CondNGPGreater(limit));
			else if (cond == "lt" || cond == "<")
				conditionals.insertLast(CondNGPLess(limit));
			else if (cond == "ge" || cond == ">=")
				conditionals.insertLast(CondNGPGreaterEqual(limit));
			else if (cond == "le" || cond == "<=")
				conditionals.insertLast(CondNGPLessEqual(limit));
			else if (cond == "eq" || cond == "==")
				conditionals.insertLast(CondNGPEqual(limit));
			else if (cond == "ne" || cond == "!=")
				conditionals.insertLast(CondNGPNotEqual(limit));
		}
		else if (start == "flag")
		{
			string cond = condArr[++i].GetString();
			string flag = condArr[++i].GetString();
		
			if (cond == "is")
				conditionals.insertLast(CondFlag(flag, true));
			else if (cond == "isnt")
				conditionals.insertLast(CondFlag(flag, false));
		}
		else if (start == "charging")
		{
			bool charge = condArr[++i].GetBoolean();
			conditionals.insertLast(CondCharge(charge));
		}
		else if (start == "buff")
		{
			string cond = condArr[++i].GetString();
			string buff = condArr[++i].GetString();
			
			if (cond == "has")
				conditionals.insertLast(CondCheckBuff(buff, true));
			else if (cond == "hasnt")
				conditionals.insertLast(CondCheckBuff(buff, false));
			else if (cond == "has tag")
				conditionals.insertLast(CondCheckBuffTag(buff, true));
			else if (cond == "hasnt tag")
				conditionals.insertLast(CondCheckBuffTag(buff, false));
		}
	}
	
	return conditionals;
}

bool CheckConditionals(array<ISkillConditional@>@ conditionals, CompositeActorBehavior@ behavior)
{
	if (conditionals !is null)
	{
		for (uint i = 0; i < conditionals.length(); i++)
			if (!conditionals[i].IsAllowed(behavior))
				return false;
	}
	
	return true;
}