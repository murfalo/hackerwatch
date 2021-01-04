enum FloatCompareFunc
{
	Greater = 1,
	Less,
	GreaterOrEqual,
	LessOrEqual
}

namespace WorldScript
{
	[WorldScript color="#BA8F8F" icon="system/icons.png;454;34;32;32"]
	class CheckActorHealth
	{
		[Editable type=enum default=1]
		FloatCompareFunc Function;

		[Editable]
		float Value;

		[Editable max=1 validation=IsActor]
		UnitFeed Actors;

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
			UnitPtr unit = Actors.FetchFirst();
			if (!unit.IsValid())
				return null;

			Actor@ actor = cast<Actor>(unit.GetScriptBehavior());
			if (actor is null)
				return null;

			float hp = actor.GetHealth();
			bool result = false;
			switch (Function)
			{
				case FloatCompareFunc::Greater: result = hp > Value; break;
				case FloatCompareFunc::Less: result = hp < Value; break;
				case FloatCompareFunc::GreaterOrEqual: result = hp >= Value; break;
				case FloatCompareFunc::LessOrEqual: result = hp <= Value; break;
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
