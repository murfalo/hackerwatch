namespace WorldScript
{
	[WorldScript color="255 255 0" icon="system/icons.png;0;96;32;32"]
	class RemoveBuff
	{
		[Editable validation=IsValid]
		UnitFeed Units;

		[Editable]
		string BuffPath;

		bool IsValid(UnitPtr unit)
		{
			return cast<CompositeActorBehavior>(unit.GetScriptBehavior()) !is null;
		}

		SValue@ ServerExecute()
		{
			ClientExecute(null);
			return null;
		}

		void ClientExecute(SValue@ val)
		{
			uint buffPathHash = HashString(BuffPath);

			auto arr = Units.FetchAll();
			for (uint i = 0; i < arr.length(); i++)
			{
				auto actor = cast<CompositeActorBehavior>(arr[i].GetScriptBehavior());
				if (actor is null)
					continue;

				actor.m_buffs.Remove(buffPathHash);
			}
		}
	}
}
