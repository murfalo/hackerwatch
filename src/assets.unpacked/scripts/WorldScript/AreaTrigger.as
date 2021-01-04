enum AreaFilter
{
	NeutralActor 		= 1,
	PlayerActor 		= 2,
	EnemyActor 			= 4,
	PlayerTeam			= 128,
	PlayerProjectile 	= 8,
	EnemyProjectile 	= 16,
	TrapProjectile 		= 32,
	Other 				= 64
}

enum AreaEvent
{
	OnEnter = 1,
	OnExit
}

namespace WorldScript
{
	bool ApplyAreaFilter(UnitPtr unit, AreaFilter filter)
	{
		if (!unit.IsValid())
			return false;
			
		ref@ behavior = unit.GetScriptBehavior();
		
		if (behavior is null)
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
		else
		{
			IProjectile@ proj = cast<IProjectile>(behavior);
			if (proj !is null)
			{
				if (proj.Team == g_team_none)
					type = AreaFilter::TrapProjectile;
				else if (proj.Team == g_team_player)
					type = AreaFilter::PlayerProjectile;
				else
					type = AreaFilter::EnemyProjectile;
			}
		}
	
		return type & filter != 0;
	}


	[WorldScript color="210 105 30" icon="system/icons.png;384;128;32;32"]
	class AreaTrigger
	{
		[Editable type=enum default=1]
		AreaEvent Event;
		
		[Editable]
		array<CollisionArea@>@ Areas;
		
		[Editable type=flags default=2]
		AreaFilter Filter;
		
		UnitSource AllInside;
		UnitSource LastEntered;
		UnitSource LastExited;
		
		
		void Initialize()
		{
			if (Network::IsServer())
			{
				for (uint i = 0; i < Areas.length(); i++)
				{
					Areas[i].AddOnEnter(this, "OnEnter");
					Areas[i].AddOnExit(this, "OnExit");
				}
			}
		}

		void Cleanup()
		{
			if (Areas !is null)
			{
				for (uint i = 0; i < Areas.length(); i++)
					Areas[i].ClearFuncs(this);
			}
		}
		
		void OnEnabledChanged(bool enabled)
		{
			auto script = WorldScript::GetWorldScript(g_scene, this);
			if (enabled)
			{
				UnitPtr unit;
				for (uint i = 0; i < Areas.length(); i++)
				{
					auto units = Areas[i].FetchAllInside(g_scene);
					for (uint j = 0; j < units.length(); j++)
					{
						if (!ApplyAreaFilter(units[j], Filter))
							continue;
					
						unit = units[j];
						AllInside.Add(units[j]);
						if (Event == AreaEvent::OnEnter)
						{
							LastEntered.Replace(unit);
							script.Execute();
						}
					}
				}
				
				if (unit.IsValid() && Event != AreaEvent::OnEnter)
					LastEntered.Replace(unit);
			}
			else
			{
				AllInside.Clear();
			
				if (Event == AreaEvent::OnExit)
				{
					for (uint i = 0; i < Areas.length(); i++)
					{
						auto units = Areas[i].FetchAllInside(g_scene);
						for (uint j = 0; j < units.length(); j++)
						{
							if (!ApplyAreaFilter(units[j], Filter))
								continue;
						
							LastExited.Replace(units[j]);
							script.Execute();
						}
					}
				}
				else
				{
					for (uint i = 0; i < Areas.length(); i++)
					{
						auto units = Areas[i].FetchAllInside(g_scene);
						for (uint j = 0; j < units.length(); j++)
						{
							if (!ApplyAreaFilter(units[j], Filter))
								continue;
						
							LastExited.Replace(units[j]);
							return;
						}
					}
				}
			}
		}
		
		void OnEnter(UnitPtr unit, vec2 pos, vec2 normal)
		{
			if (ApplyAreaFilter(unit, Filter))
			{
				LastEntered.Replace(unit);
				AllInside.Add(unit);
				
				if (Event == AreaEvent::OnEnter)
					WorldScript::GetWorldScript(g_scene, this).Execute();
			}
		}
		
		void OnExit(UnitPtr unit)
		{
			if (ApplyAreaFilter(unit, Filter))
			{
				LastExited.Replace(unit);
				AllInside.Remove(unit);
				
				if (Event == AreaEvent::OnExit)
					WorldScript::GetWorldScript(g_scene, this).Execute();
			}
		}
		
		SValue@ ServerExecute()
		{
			return null;
		}
	}
}