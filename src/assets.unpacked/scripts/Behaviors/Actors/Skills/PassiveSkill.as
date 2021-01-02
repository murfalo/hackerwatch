namespace Skills
{
	class PassiveSkill : Skill
	{
		array<Modifiers::Modifier@> m_modifiers;

		SValue@ m_params;
	
		PassiveSkill(UnitPtr unit, SValue& params)
		{
			super(unit);

			@m_params = params;
		}

		void Initialize(Actor@ owner, ScriptSprite@ icon, uint id) override
		{
			if (m_params !is null)
			{
				m_modifiers = Modifiers::LoadModifiers(m_owner.m_unit, m_params, "", Modifiers::SyncVerb::Passive, id);
				@m_params = null;
			}

			Skill::Initialize(owner, icon, id);
		}

		array<Modifiers::Modifier@>@ GetModifiers() override
		{
			return m_modifiers;
		}
	}
}