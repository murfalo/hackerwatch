namespace WorldScript
{
	[WorldScript color="238 232 170" icon="system/icons.png;352;32;32;32"]
	class SpawnEffect
	{
		vec3 Position;

		[Editable]
		UnitScene@ Effect;

		[Editable validation=IsExecutable]
		UnitFeed FinishTrigger;

		[Editable]
		int Layer;

		bool IsExecutable(UnitPtr unit)
		{
			WorldScript@ script = WorldScript::GetWorldScript(unit);
			if (script is null)
				return false;

			return script.IsExecutable();
		}

		SValue@ ServerExecute()
		{
			UnitPtr effectUnit = PlayEffect(Effect, xy(Position));
			if (!effectUnit.IsValid())
				return null;

			if (Layer != 0)
				effectUnit.SetLayer(Layer);

			if (Network::IsServer())
			{
				auto fx = cast<EffectBehavior>(effectUnit.GetScriptBehavior());
				auto triggerArr = FinishTrigger.FetchAll();
				for (uint i = 0; i < triggerArr.length(); i++)
				{
					auto callbackScript = WorldScript::GetWorldScript(g_scene, triggerArr[i].GetScriptBehavior());
					fx.m_finishTriggers.insertLast(callbackScript);
				}
			}
			return null;
		}

		void ClientExecute(SValue@ val)
		{
			ServerExecute();
		}
	}
}
