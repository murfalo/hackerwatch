class ShootRandomProjectile : IAction
{
	array<SpawnUnitEntry@> m_projectile;
	int m_projectiles;

	float m_spread;
	float m_spreadMin;
	float m_spreadMax;
	int m_spreadTime;
	int m_spreadTimeC;
	int m_spreadCooldown;
	int m_shootDist;
	vec2 m_offset;
	bool m_rotateOffset;

	uint m_weaponInfo;


	ShootRandomProjectile(UnitPtr unit, SValue& params)
	{
		SValue@ svProjectile = params.GetDictionaryEntry("projectile");
		if (svProjectile.GetType() == SValueType::String)
		{
			auto entry = SpawnUnitEntry();
			entry.m_chance = 1000;
			@entry.m_prod = Resources::GetUnitProducer(svProjectile.GetString());
			m_projectile.insertLast(entry);
		}
		else if (svProjectile.GetType() == SValueType::Array)
		{
			auto arr = svProjectile.GetArray();
			for (uint i = 0; i < arr.length(); i += 2)
			{
				auto entry = SpawnUnitEntry();
				entry.m_chance = arr[i + 0].GetInteger();
				@entry.m_prod = Resources::GetUnitProducer(arr[i + 1].GetString());
				m_projectile.insertLast(entry);
			}
		}

		m_projectiles = GetParamInt(unit, params, "projectiles", false, 1);
		m_shootDist = GetParamInt(unit, params, "dist", false, 0);

		m_offset = GetParamVec2(unit, params, "offset", false);
		if (m_offset.x != 0 || m_offset.y != 0)
			m_rotateOffset = GetParamBool(unit, params, "rotate-offset", false);

		SValue@ spread = GetParamDictionary(unit, params, "spread", false);
		if (spread !is null)
		{
			m_spreadMin = GetParamInt(unit, spread, "min") * PI / 180.0;
			m_spreadMax = GetParamInt(unit, spread, "max") * PI / 180.0;
			m_spreadTime = GetParamInt(unit, spread, "time");
			m_spreadCooldown = GetParamInt(unit, params, "cooldown", false, 100);
		}
		else
		{
			m_spreadMin = GetParamInt(unit, params, "spread-min", false) * PI / 180.0;
			m_spread = GetParamInt(unit, params, "spread", false) * PI / 180.0;
		}
	}

	void SetWeaponInformation(uint weapon)
	{
		m_weaponInfo = weapon;
	}

	bool NeedNetParams() { return true; }

	vec2 GetShootDir(vec2 dir, int i, bool allowRandom)
	{
		if (allowRandom && (m_spread > 0 || m_spreadMin > 0))
		{
			float rnd = (randf() - 0.5) * (m_spread - m_spreadMin);
			if (m_spreadMin > 0)
				rnd += (randi(2) == 0 ? m_spreadMin : -m_spreadMin);

			float ang = atan(dir.y, dir.x) + rnd;
			return vec2(cos(ang), sin(ang));
		}

		return dir;
	}

	int GetProjectileType()
	{
		int n = randi(1000);
		for (uint i = 0; i < m_projectile.length(); i++)
		{
			n -= m_projectile[i].m_chance;
			if (n < 0)
				return i;
		}
		return -1;
	}

	UnitPtr ProduceProjectile(int type, vec2 shootPos, int id = 0)
	{
		return m_projectile[type].m_prod.Produce(g_scene, xyz(shootPos), id);
	}

	bool DoAction(SValueBuilder@ builder, Actor@ owner, Actor@ target, vec2 pos, vec2 dir, float intensity)
	{
		if (m_rotateOffset)
			pos += addrot(m_offset, atan(dir.y, dir.x)) * length(m_offset);
		else
			pos += m_offset;

		if (m_spreadTime > 0)
		{
			m_spread = lerp(m_spreadMin, m_spreadMax, min(1.0, m_spreadTimeC / float(m_spreadTime)));
			m_spreadTimeC = min(m_spreadTime, m_spreadTimeC + m_spreadCooldown);
		}

		dir = normalize(dir);

		bool shot = false;

		builder.PushArray();
		builder.PushVector2(pos);
		builder.PushFloat(intensity);
		if (target is null)
			builder.PushInteger(0);
		else
			builder.PushInteger(target.m_unit.GetId());

		for (int i = 0; i < m_projectiles; i++)
		{
			int type = GetProjectileType();
			if (type == -1)
				continue;

			vec2 shootDir = GetShootDir(dir, i, true);

			vec2 shootPos = pos + shootDir * m_shootDist;
			if (m_shootDist > 0)
			{
				auto results = g_scene.RaycastClosest(xy(owner.m_unit.GetPosition()), shootPos, ~0, RaycastType::Shot);
				if (results.FetchUnit(g_scene).IsValid())
					shootPos = results.point;
			}

			auto proj = ProduceProjectile(type, shootPos);
			if (!proj.IsValid())
				continue;

			IProjectile@ p = cast<IProjectile>(proj.GetScriptBehavior());
			if (p is null)
				continue;

			builder.PushInteger(type);
			builder.PushInteger(proj.GetId());
			builder.PushVector2(shootDir);

			p.Initialize(owner, shootDir, intensity, false, target, m_weaponInfo);
			shot = true;
		}

		builder.PopArray();


		return shot;
	}

	bool NetDoAction(SValue@ param, Actor@ owner, vec2 pos, vec2 dir)
	{
		array<SValue@>@ pm = param.GetArray();
		pos = pm[0].GetVector2();
		float intensity = pm[1].GetFloat();

		int targetId = pm[2].GetInteger();
		Actor@ target;
		if (targetId != 0)
		{
			UnitPtr targetUnit = g_scene.GetUnit(targetId);
			if (targetUnit.IsValid())
				@target = cast<Actor>(targetUnit.GetScriptBehavior());
		}

		for (uint i = 3; i < pm.length(); i += 3)
		{
			int type = pm[i + 0].GetInteger();
			int id = pm[i + 1].GetInteger();
			vec2 shootDir = pm[i + 2].GetVector2();

			vec2 shootPos = pos + shootDir * m_shootDist;
			if (m_shootDist > 0)
			{
				auto results = g_scene.RaycastClosest(xy(owner.m_unit.GetPosition()), shootPos, ~0, RaycastType::Shot);
				if (results.FetchUnit(g_scene).IsValid())
					shootPos = results.point;
			}

			auto proj = ProduceProjectile(type, shootPos, id);
			if (!proj.IsValid())
				continue;

			IProjectile@ p = cast<IProjectile>(proj.GetScriptBehavior());
			if (p is null)
				continue;

			p.Initialize(owner, shootDir, intensity, true, target, m_weaponInfo);
		}

		return true;
	}

	void Update(int dt, int cooldown)
	{
		if (cooldown <= 0)
			m_spreadTimeC = 0;
	}
}
