enum BuffCheckMode
{
	BuffName,
	BuffTag
}

namespace WorldScript
{
	[WorldScript color="#BA8F8F" icon="system/icons.png;454;34;32;32"]
	class CheckActorBuff
	{
		[Editable type=enum]
		BuffCheckMode Mode;

		[Editable]
		string Buff;

		[Editable max=1 validation=IsActor]
		UnitFeed Actor;

		[Editable validation=IsExecutable]
		UnitFeed OnTrue;

		[Editable validation=IsExecutable]
		UnitFeed OnFalse;

		bool IsActor(UnitPtr unit)
		{
			return cast<Actor>(unit.GetScriptBehavior()) !is null;
		}

		bool IsExecutable(UnitPtr unit)
		{
			WorldScript@ script = WorldScript::GetWorldScript(unit);
			if (script is null)
				return false;
		
			return script.IsExecutable();
		}

		SValue@ ServerExecute()
		{
			UnitPtr unit = Actor.FetchFirst();
			if (!unit.IsValid())
				return null;

			auto actor = cast<CompositeActorBehavior>(unit.GetScriptBehavior());
			if (actor is null)
				return null;

			bool result = false;
			switch (Mode)
			{
				case BuffCheckMode::BuffName: result = actor.m_buffs.HasBuff(HashString(Buff)); break;
				case BuffCheckMode::BuffTag: result = actor.m_buffs.HasTags(ApplyActorBuffTag(0, Buff)); break;
			}

			array<UnitPtr>@ toExec;
			if (result)
				@toExec = OnTrue.FetchAll();
			else
				@toExec = OnFalse.FetchAll();

			for (uint i = 0; i < toExec.length(); i++)
				WorldScript::GetWorldScript(g_scene, toExec[i].GetScriptBehavior()).Execute();

			return null;
		}
	}
}
