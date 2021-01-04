namespace WorldScript
{
	[WorldScript color="186 85 164" icon="system/icons.png;352;96;32;32"]
	class MusicArea
	{
		[Editable]
		SoundEvent@ Music;
	
		[Editable]
		int Channel;
		
		[Editable]
		array<CollisionArea@>@ Areas;
	
	
		void Initialize()
		{
			for (uint i = 0; i < Areas.length(); i++)
				Areas[i].AddOnEnter(this, "OnEnter");
		}
	
		void OnEnter(UnitPtr unit, vec2 pos, vec2 normal)
		{
			if (!unit.IsValid())
				return;

			ref@ behavior = unit.GetScriptBehavior();
			if (behavior is null)
				return;

			auto plr = cast<Player>(behavior);
			if (plr is null)
				return;
			
			PlayAsMusic(Channel, Music);
		}
	}
}