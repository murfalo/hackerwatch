namespace Skills
{
	class DropUnit : ActiveSkill
	{
		UnitProducer@ m_prod;
		bool m_needNetSync;

		uint m_maxCount;
		bool m_removeOldest;

		float m_distance;

		array<UnitPtr> m_units;

		DropUnit(UnitPtr unit, SValue& params)
		{
			super(unit, params);

			@m_prod = Resources::GetUnitProducer(GetParamString(unit, params, "unit"));
			m_needNetSync = !IsNetsyncedExistance(m_prod.GetNetSyncMode());

			m_maxCount = GetParamInt(unit, params, "max-count");
			m_removeOldest = GetParamBool(unit, params, "remove-oldest", false);

			m_distance = GetParamFloat(unit, params, "offset", false, 0.0f);
		}

		TargetingMode GetTargetingMode(int &out size) override { return TargetingMode::TargetAOE; }

		bool Activate(vec2 target) override
		{
			if (!m_removeOldest && m_units.length() >= m_maxCount)
				return false;

			return ActiveSkill::Activate(target);
		}

		bool NeedNetParams() override { return true; }

		void DoActivate(SValueBuilder@ builder, vec2 target) override
		{
			vec3 unitPos = m_owner.m_unit.GetPosition() + xyz(target * m_distance);
			unitPos.z = 0;
			builder.PushVector3(unitPos);

			if (m_needNetSync || Network::IsServer())
				SpawnUnit(unitPos, target);
		}

		void NetDoActivate(SValue@ param, vec2 target) override
		{
			if (!m_needNetSync && !Network::IsServer())
			{
				PlaySkillEffect(target);
				return;
			}

			vec3 unitPos = param.GetVector3();
			SpawnUnit(unitPos, target);
		}

		void DoUpdate(int dt) override
		{
			for (int i = m_units.length() - 1; i >= 0; i--)
			{
				if (m_units[i].IsDestroyed())
					m_units.removeAt(i);
			}
		}

		UnitPtr SpawnUnit(vec3 pos, vec2 target)
		{
			PlaySkillEffect(target);

			UnitPtr unit = m_prod.Produce(g_scene, pos);

			auto ownedUnit = cast<IOwnedUnit>(unit.GetScriptBehavior());
			if (ownedUnit !is null)
			{
				ownedUnit.Initialize(m_owner, 1.0f, false, m_skillId + 1);

				if (!m_needNetSync && Network::IsServer())
					(Network::Message("SetOwnedUnit") << unit << m_owner.m_unit << 1.0f).SendToAll();
			}

			m_units.insertLast(unit);

			if (m_removeOldest && m_units.length() > m_maxCount)
			{
				UnitPtr unitToRemove = m_units[0];
				m_units.removeAt(0);
				unitToRemove.Destroy();
			}

			return unit;
		}
	}
}
