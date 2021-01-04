namespace Modifiers
{
	class WarlockCleaverModifier : Modifier
	{
		ActorBuffDef@ m_buff;

		WarlockCleaverModifier(UnitPtr unit, SValue& params)
		{
			@m_buff = LoadActorBuff(GetParamString(unit, params, "buff"));
		}

		bool HasTriggerEffects() override { return true; }
		void TriggerEffects(PlayerBase@ player, Actor@ enemy, EffectTrigger trigger) override
		{
			if (trigger != EffectTrigger::Hit)
				return;

			auto skill = cast<Skills::MeleeSwing>(player.m_skills[0]);
			if (skill is null)
				return;

			ActorBuffDef@ buffDef = null;
			for (uint i = 0; i < skill.m_effects.length(); i++)
			{
				auto buffEffect = cast<ApplyBuff>(skill.m_effects[i]);
				if (buffEffect !is null)
				{
					@buffDef = buffEffect.m_buff;
					break;
				}
			}

			if (buffDef is null)
				return;

			auto newBuff = ActorBuff(player, m_buff, 1.0f, !player.m_record.local);
			newBuff.m_duration = buffDef.m_duration;
			enemy.ApplyBuff(newBuff);
		}
	}
}
