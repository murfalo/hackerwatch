class TowerFlowerSkill : ICompositeActorSkill
{
	string m_spikeUnit;
	int m_radius;

	int m_attackInterval;
	int m_attackIntervalC;
	int m_attackIntervalRandom;

	bool m_casting;
	bool m_casted;
	int m_castpoint;
	int m_castpointC;

	int m_minHardness;
	int m_maxHardness;

	int m_attackingC;

	UnitProducer@ m_spikeProducer;
	UnitScene@ m_spikeEffect;
	AnimString@ m_anim;

	UnitPtr m_unit;
	CompositeActorBehavior@ m_behavior;

	SoundEvent@ m_castSound;
	SoundEvent@ m_failSound;

	array<UnitPtr> m_targetUnits;

	TowerFlowerSkill(UnitPtr unit, SValue& params)
	{
		@m_spikeProducer = Resources::GetUnitProducer(GetParamString(unit, params, "spike"));
		@m_spikeEffect = unit.GetUnitScene(GetParamString(unit, params, "spike-effect", false));
		@m_anim = AnimString(GetParamString(unit, params, "anim", false));

		m_spikeUnit = GetParamString(unit, params, "spike", false);
		m_radius = GetParamInt(unit, params, "radius");

		m_attackInterval = GetParamInt(unit, params, "interval");
		m_attackIntervalRandom = GetParamInt(unit, params, "interval-random");
		m_castpoint = GetParamInt(unit, params, "castpoint");

		m_minHardness = GetParamInt(unit, params, "hardness-min", false, -1);
		m_maxHardness = GetParamInt(unit, params, "hardness-max", false, -1);

		@m_castSound = Resources::GetSoundEvent(GetParamString(unit, params, "cast-snd", false));
		@m_failSound = Resources::GetSoundEvent(GetParamString(unit, params, "fail-snd", false));
	}

	void Initialize(UnitPtr unit, CompositeActorBehavior& behavior, int id)
	{
		m_unit = unit;
		@m_behavior = behavior;
	}

	void Save(SValueBuilder& builder)
	{
	}

	void Load(SValue@ sval)
	{
	}

	void Update(int dt, bool isCasting)
	{
		if (m_casting)
		{
			m_attackingC -= dt;

			m_behavior.SetUnitScene(m_anim.GetSceneName(0), false);
			if (!m_casted)
			{
				m_castpointC += dt;
				if (m_castpointC >= m_castpoint)
				{
					m_casted = true;
					m_castpointC = 0;
					NetUseSkill(1, null);
				}
			}

			if (m_attackingC <= 0)
				m_casting = false;

			return;
		}

		m_attackIntervalC -= dt;
		if (m_attackIntervalC <= 0)
			NetUseSkill(0, null);
	}

	bool IsCasting() { return m_casting; }
	void OnDamaged() {}
	void OnDeath() {}
	void Destroyed() {}
	void OnCollide(UnitPtr unit, vec2 normal) {}
	void CancelSkill() {}

	void NetUseSkill(int stage, SValue@ param)
	{
		if (stage == 0)
		{
			m_attackIntervalC = m_attackInterval + randi(m_attackIntervalRandom);
			vec2 pos = xy(m_unit.GetPosition());
			array<UnitPtr>@ results = g_scene.QueryCircle(pos, m_radius, ~0, RaycastType::Any);
			for (uint i = 0; i < results.length(); i++)
			{
				UnitPtr unit = results[i];
				if (unit == m_unit)
					continue;

				Actor@ a = cast<Actor>(unit.GetScriptBehavior());
				if (a is null or a.Team == m_behavior.Team)
					continue;

				m_casting = true;
				m_casted = false;
				m_targetUnits.insertLast(unit);

				m_attackingC = m_behavior.SetUnitScene(m_anim.GetSceneName(0), true);
			}
		} 
		else if (stage == 1) 
		{
			while (m_targetUnits.length() > 0)
			{
				UnitPtr unit = m_targetUnits[0];

				vec2 unit_pos = xy(unit.GetPosition());

				bool passable = true;
				string hitFx = "";

				if (m_minHardness != -1 || m_maxHardness != -1)
				{
					array<Tileset@>@ tilesets = g_scene.FetchTilesets(unit_pos);
					for (uint i = 0; i < tilesets.length(); i++)
					{
						SValue@ tsd = tilesets[i].GetData();
						if (tsd is null)
							continue;

						SValue@ svHitFx = tsd.GetDictionaryEntry("hit-effect");
						if (svHitFx !is null && svHitFx.GetType() == SValueType::String)
							hitFx = svHitFx.GetString();

						SValue@ svHardness = tsd.GetDictionaryEntry("hardness");
						if (svHardness is null || svHardness.GetType() != SValueType::Integer)
							continue;

						int hardness = svHardness.GetInteger();
						if ((m_minHardness != -1 && hardness < m_minHardness) ||
						    (m_maxHardness != -1 && hardness > m_maxHardness))
						{
							passable = false;
							break;
						}
					}
				}

				if (passable)
				{
					UnitPtr newUnit = m_spikeProducer.Produce(g_scene, xyz(unit_pos));
					TowerFlowerSpike@ spike = cast<TowerFlowerSpike>(newUnit.GetScriptBehavior());

					if (spike !is null)
					{
						if (m_spikeEffect !is null)
						{
							newUnit.SetUnitScene(m_spikeEffect, true);
							newUnit.SetShouldCollide(false);
							spike.m_ttl = m_spikeEffect.Length();
						}

						@spike.m_owner = cast<Actor>(m_unit.GetScriptBehavior());
						spike.m_intensity = m_behavior.m_buffs.DamageMul();
					}

					PlaySound3D(m_castSound, xyz(unit_pos));
					if (hitFx != "")
						PlayEffect(hitFx, newUnit);
				}
				else
					PlaySound3D(m_failSound, xyz(unit_pos));

				m_targetUnits.removeAt(0);
			}
		}
	}
}
