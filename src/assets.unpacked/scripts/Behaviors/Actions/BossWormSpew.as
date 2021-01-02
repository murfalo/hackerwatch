class BossWormClump
{
	int chance;
	UnitProducer@ unit;
	array<IEffect@>@ effects;

	BossWormClump(int chance, UnitProducer@ unit, array<IEffect@>@ effects)
	{
		this.chance = chance;
		@(this.unit) = unit;
		@(this.effects) = effects;
	}

	int opCmp(const BossWormClump &in clump) const
	{
		if(chance < clump.chance)
			return -1;
		else if(chance > clump.chance)
			return 1;
		return 0;
	}
}

class QueuedClump
{
	int delay;
	uint clumpId;

	Actor@ owner;
	Actor@ target;
	vec2 dir;
	float intensity;
	vec2 spread;

	QueuedClump(int delay, uint id, Actor@ owner, Actor@ target, vec2 dir, float intensity, vec2 spread)
	{
		this.delay = delay;
		clumpId = id;

		@(this.owner) = owner;
		@(this.target) = target;
		this.dir = dir;
		this.intensity = intensity;
		this.spread = spread;
	}
}

class BossWormSpew : IAction
{
	array<BossWormClump@> m_clumps;
	array<QueuedClump@> m_queuedClumps;

	int m_totClumpChance;
	int m_airTime;

	int m_spread;

	BossWormSpew(UnitPtr unit, SValue& params)
	{
		m_totClumpChance = 0;

		m_airTime = GetParamInt(unit, params, "air-time", false, 1000);

		m_spread = GetParamInt(unit, params, "spread", false, 0);

		auto clumpsData = GetParamArray(unit, params, "clumps");
		if (clumpsData !is null)
		{
			for (uint i = 0; i < clumpsData.length(); i++)
			{
				auto chance = GetParamInt(unit, clumpsData[i], "chance", true, 1);
				auto up = Resources::GetUnitProducer(GetParamString(unit, clumpsData[i], "clump", true));
				auto effects = LoadEffects(unit, clumpsData[i]);

				m_clumps.insertLast(BossWormClump(chance, up, effects));

				m_totClumpChance += chance;
			}
		}

		m_clumps.sortDesc();
	}

	void SetWeaponInformation(uint weapon)
	{
		// TODO: Propagate to clump effects? eh..
	}

	bool NeedNetParams() { return true; }


	int RandClump()
	{
		int n = randi(m_totClumpChance);
		for (uint i = 0; i < m_clumps.length(); i++)
		{
			n -= m_clumps[i].chance;
			if (n < 0)
				return i;
		}

		return -1;
	}

	vec2 GetRandomSpread()
	{
		return vec2(
			randi(m_spread) - m_spread / 2,
			randi(m_spread) - m_spread / 2
		);
	}

	bool DoAction(SValueBuilder@ builder, Actor@ owner, Actor@ target, vec2 pos, vec2 dir, float intensity)
	{
		int id = RandClump();
		if (id >= 0)
		{
			vec2 spread = GetRandomSpread();
			m_queuedClumps.insertLast(QueuedClump(m_airTime, id, owner, target, dir, intensity, spread));

			builder.PushArray();
			builder.PushInteger(id);
			if (target is null)
				builder.PushInteger(0);
			else
				builder.PushInteger(target.m_unit.GetId());
			builder.PushVector2(spread);
			builder.PopArray();

			return true;
		}

		return false;
	}

	bool NetDoAction(SValue@ param, Actor@ owner, vec2 pos, vec2 dir)
	{
		array<SValue@>@ pm = param.GetArray();

		int id = pm[0].GetInteger();
		int targetId = pm[1].GetInteger();
		vec2 spread = pm[2].GetVector2();

		Actor@ target = null;
		if (targetId != 0)
		{
			UnitPtr targetUnit = g_scene.GetUnit(targetId);
			if (targetUnit.IsValid())
				@target = cast<Actor>(targetUnit.GetScriptBehavior());
		}

		m_queuedClumps.insertLast(QueuedClump(m_airTime, id, owner, target, dir, 1.0, spread));
		return true;
	}

	void Update(int dt, int cooldown)
	{
		for (uint i = 0; i < m_queuedClumps.length();)
		{
			m_queuedClumps[i].delay -= dt;
			if (m_queuedClumps[i].delay <= 0)
			{
				auto queued = m_queuedClumps[i];
				if (queued.target !is null)
				{
					auto pos = queued.target.m_unit.GetPosition();
					pos.z = 0;

					pos.x += queued.spread.x;
					pos.y += queued.spread.y;

					auto u = m_clumps[queued.clumpId].unit.Produce(g_scene, pos);
					auto chnk = cast<BossWormSpewChunk>(u.GetScriptBehavior());
					if (chnk !is null)
						chnk.Initialize(queued.owner, m_clumps[queued.clumpId].effects);
				}

				m_queuedClumps.removeAt(i);
				//i++;
			}
			else
				i++;
		}
	}
}
