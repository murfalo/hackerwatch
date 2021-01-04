namespace WorldScript
{
	[WorldScript color="238 232 170" icon="system/icons.png;352;32;32;32"]
	class SpawnEffectParam
	{
		vec3 Position;

		[Editable]
		UnitScene@ Effect;

		[Editable]
		string ParamName;

		[Editable]
		float ParamValue;

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
			UnitPtr effectUnit = PlayEffect(Effect, xy(Position), {
				{ ParamName, ParamValue }
			});
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
