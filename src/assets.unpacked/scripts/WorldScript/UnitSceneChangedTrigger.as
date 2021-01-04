enum TextFilterType
{
	StartsWith		= 0,
	EndsWith		= 1,
	Contains		= 2,
	DoesntContain	= 3,
	Is				= 4,
	IsNot			= 5,
}

namespace WorldScript
{
	[WorldScript color="210 105 30" icon="system/icons.png;384;32;32;32"]
	class UnitSceneChangedTrigger
	{
		bool Enabled;
	
		[Editable validation=IsValid changed=OnChanged]
		UnitFeed Units;

		[Editable type=enum default=2]
		TextFilterType TextFilterType;
		
		[Editable]
		string TextFilter;
		
		UnitSource Instigator;
		
		UnitCallbackList m_callbacks;
		
		
		bool IsValid(UnitPtr unit)
		{
			return WorldScript::GetWorldScript(unit) is null;
		}
		
		void OnChanged(array<UnitPtr>@ added, array<UnitPtr>@ removed)
		{
			if (!Network::IsServer())
				return;
		
			if (added !is null)
				for (uint i = 0; i < added.length(); i++)
					m_callbacks.RegisterEventCallback(added[i], UnitEventType::SceneChanged, this, "UnitSceneChanged");
				
			if (removed !is null)
				for (uint i = 0; i < removed.length(); i++)
					m_callbacks.UnregisterEventCallback(removed[i]);
		}
		
		void Cleanup()
		{
			m_callbacks.Cleanup();
		}
		
		void UnitSceneChanged(UnitPtr unit, SValue& arg)
		{
			if (!Enabled)
				return;
		
			string sceneName = "";
			UnitScene@ scene = unit.GetCurrentUnitScene();
			if (scene !is null)
				sceneName = scene.GetName();
		
			int idx;
			switch (TextFilterType)
			{
			case TextFilterType::StartsWith:
				if (sceneName.findFirst(TextFilter) != 0)
					return;
				break;
				
			case TextFilterType::EndsWith:
				if (sceneName.findLast(TextFilter) != int(sceneName.length()) - TextFilter.length())
					return;
				break;
				
			case TextFilterType::Contains:
				if (TextFilter == "")
					break;
			
				if (sceneName.findFirst(TextFilter) == -1)
					return;
				break;
				
			case TextFilterType::DoesntContain:
				if (sceneName.findFirst(TextFilter) != -1)
					return;
				break;
				
			case TextFilterType::Is:
				if (sceneName != TextFilter)
					return;
				break;
				
			case TextFilterType::IsNot:
				if (sceneName == TextFilter)
					return;
				break;
			}
		
			Instigator.Replace(unit);
			WorldScript::GetWorldScript(g_scene, this).Execute();
		}
		
		SValue@ ServerExecute()
		{
			return null;
		}
	}
}