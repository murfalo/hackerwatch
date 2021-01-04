namespace WorldScript
{
	[WorldScript color="238 232 170" icon="system/icons.png;0;96;32;32"]
	class SoundEnvironmentArea
	{
		[Editable]
		array<CollisionArea@>@ Areas;
	
		[Editable default=1.5 min=0.1 max=20]
		float ReverbTime;

		
		void Initialize()
		{
			for (uint i = 0; i < Areas.length(); i++)
			{
				Areas[i].AddOnEnter(this, "OnEnter");
				Areas[i].AddOnExit(this, "OnExit");
			}
		}
		
		void OnEnter(UnitPtr unit, vec2 pos, vec2 normal)
		{
			auto plr = GetLocalPlayer();
			if (plr !is null && plr.m_unit == unit)
				EnvironmentSoundSystem::SetEnvironment(ReverbTime);
		}
		
		void OnExit(UnitPtr unit)
		{
			auto plr = GetLocalPlayer();
			if (plr !is null && plr.m_unit == unit)
				EnvironmentSoundSystem::ClearEnvironment();
		}
	}
}