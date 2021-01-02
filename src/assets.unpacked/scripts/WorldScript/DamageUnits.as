namespace WorldScript
{
	[WorldScript color="255 0 0" icon="system/icons.png;0;96;32;32"]
	class DamageUnits
	{
		[Editable validation=IsValid]
		UnitFeed Units;
		
		[Editable default=1000 min=0 max=1000000]
		int Physical;

		[Editable default=0 min=0 max=1000000]
		int Magical;
		
		[Editable type=flags default=1]
		DamageType DamageType;
		
		[Editable default=""]
		string Buff;

		[Editable default=true]
		bool CanKill;

		[Editable default=false]
		bool TrueStrike;

		[Editable default=1]
		float ArmorMul;
		[Editable default=1]
		float ResistanceMul;

		DamageInfo m_dmg;
		ActorBuffDef@ m_buff;

		bool IsValid(UnitPtr unit)
		{
			return cast<IDamageTaker>(unit.GetScriptBehavior()) !is null;
		}
		
		void Initialize()
		{
			m_dmg.PhysicalDamage = Physical;
			m_dmg.MagicalDamage = Magical;
			m_dmg.DamageType = uint8(DamageType);
			m_dmg.CanKill = CanKill;
			m_dmg.TrueStrike = TrueStrike;
			m_dmg.ArmorMul = vec2(ArmorMul, ResistanceMul);
			@m_buff = LoadActorBuff(Buff);
		}
		
		bool ApplyDamage(UnitPtr unit, vec2 pos)
		{
			if (!FilterHuskDamage(null, unit, !Network::IsServer()))
				return false;
		
			auto behavior = unit.GetScriptBehavior();

			if (m_buff !is null)
			{
				Actor@ actor = cast<Actor>(behavior);
				if (actor !is null)
					actor.ApplyBuff(ActorBuff(null, m_buff, 1.0, false));
			}
		
			if (m_dmg.PhysicalDamage > 0 || m_dmg.MagicalDamage > 0)
			{
				unit.TriggerCallbacks(UnitEventType::Damaged);
				
				IDamageTaker@ dt = cast<IDamageTaker>(behavior);
				if (dt is null)
					return true;
				
				dt.Damage(m_dmg, pos, vec2(0, 0));
				return dt.IsDead();
			}
			
			return false;
		}
		
		SValue@ ServerExecute()
		{
			array<UnitPtr>@ units = Units.FetchAll();
			for (uint i = 0; i < units.length(); i++)
				ApplyDamage(units[i], xy(units[i].GetPosition()));
				
			return null;
		}

		void ClientExecute(SValue@ sval)
		{
			array<UnitPtr>@ units = Units.FetchAll();
			for (uint i = 0; i < units.length(); i++)
			{
				// Check if the unit is a local player (workaround for clients not working with DamageUnits, don't want to mess up other cases where this will be called)
				auto player = cast<Player>(units[i].GetScriptBehavior());
				if (player !is null)
					ApplyDamage(units[i], xy(units[i].GetPosition()));
			}
		}
	}
}