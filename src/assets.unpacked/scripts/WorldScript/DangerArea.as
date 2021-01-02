enum DamageFilter
{
	NeutralActor 		= 1,
	PlayerActor 		= 2,
	EnemyActor 			= 4,
	PlayerTeam			= 128,
	Other 				= 64
}


namespace WorldScript
{
	bool ApplyDamageFilter(UnitPtr unit, DamageFilter filter)
	{
		if (!unit.IsValid())
			return false;
			
		ref@ behavior = unit.GetScriptBehavior();
		
		if (behavior is null)
			return false;
	
		if (cast<IDamageTaker>(behavior) is null)
			return false;
	
		AreaFilter type = AreaFilter::Other;
	
		Actor@ actor = cast<Actor>(behavior);
		if (actor !is null)
		{
			if (actor.Team == g_team_none)
				type = AreaFilter::NeutralActor;
			else if (cast<PlayerBase>(actor) !is null)
				type = AreaFilter::PlayerActor;
			else if (actor.Team == g_team_player)
				type = AreaFilter::PlayerTeam;
			else
				type = AreaFilter::EnemyActor;
		}
	
		return type & filter != 0;
	}


	[WorldScript color="255 0 0" icon="system/icons.png;0;96;32;32"]
	class DangerArea
	{
		bool Enabled;
	
		[Editable type=flags default=71]
		DamageFilter Filter;
		
		[Editable]
		array<CollisionArea@>@ Areas;
	
		[Editable default=500 min=-1 max=1000000]
		int Frequency;
		
		[Editable default=1000 min=0 max=1000000]
		int Damage;
		[Editable default=0 min=0 max=1000000]
		int MagicalDamage;
		
		%//[Editable type=flags default=1]
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
		
		
		int m_time;
		array<UnitPtr> m_units;
		DamageInfo m_dmg;
		ActorBuffDef@ m_buff;
		
		
		void Initialize()
		{
			m_time = Frequency;
			
			for (uint i = 0; i < Areas.length(); i++)
			{
				Areas[i].AddOnEnter(this, "OnEnter");
				Areas[i].AddOnExit(this, "OnExit");
			}

			m_dmg.Damage = Damage + MagicalDamage;
			m_dmg.PhysicalDamage = Damage;
			m_dmg.MagicalDamage = MagicalDamage;
			m_dmg.DamageType = uint8(DamageType::TRAP); // uint8(DamageType);
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
		
			if (m_dmg.Damage > 0)
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
		
		void TickDamage()
		{
			for (uint i = 0; i < m_units.length(); i++)
				ApplyDamage(m_units[i], xy(m_units[i].GetPosition()));
		}
		
		void OnEnabledChanged(bool enabled)
		{
			if (enabled)
				TickDamage();
		}
		
		void Update(int dt)
		{
			if (!Enabled)
				return;
		
			if (Frequency > 0)
			{
				m_time -= dt;
				while (m_time < 0)
				{
					m_time += Frequency;
					TickDamage();
				}
			}
		}
		
		void OnEnter(UnitPtr unit, vec2 pos, vec2 normal)
		{
			if (!ApplyDamageFilter(unit, Filter))
				return;

			if (!Enabled || !ApplyDamage(unit, pos))
				m_units.insertLast(unit);
		}
		
		void OnExit(UnitPtr unit)
		{
			if (!ApplyDamageFilter(unit, Filter))
				return;
			
			for (uint i = 0; i < m_units.length();)
			{
				if (m_units[i] == unit)
				{
					m_units.removeAt(i);
					return;
				}
				else
					i++;
			}
		}
	}
}