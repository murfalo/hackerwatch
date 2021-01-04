namespace WorldScript
{
	[WorldScript color="200 50 200" icon="system/icons.png;384;224;32;32"]
	class PotionRefill
	{
		[Editable]
		UnitFeed Targets;

		[Editable validation=IsExecutable]
		UnitFeed OnRefilled;

		UnitSource RefillTaker;

		bool IsExecutable(UnitPtr unit)
		{
			WorldScript@ script = WorldScript::GetWorldScript(unit);
			if (script is null)
				return false;

			return script.IsExecutable();
		}

		SValue@ ServerExecute()
		{
			ClientExecute(null);
			return null;
		}

		void ClientExecute(SValue@ val)
		{
			bool hasSet = false;

			auto units = Targets.FetchAll();
			for (uint i = 0; i < units.length(); i++)
			{
				auto player = cast<PlayerBase>(units[i].GetScriptBehavior());
				if (player is null)
					continue;

				auto record = player.m_record;

				if (record.potionChargesUsed == 0 && record.hp >= 1.0f && record.mana >= 1.0f)
					continue;

				RefillTaker.Replace(player.m_unit);

				record.RefillPotionCharges();
				record.hp = 1.0f;
				record.mana = 1.0f;

				AddFloatingText(FloatingTextType::Pickup, Resources::GetString(".hud.potionrefill"), player.m_unit.GetPosition());

				hasSet = true;

				Stats::Add("well-used", 1, record);
			}

			if (hasSet && Network::IsServer())
			{
				auto arr = OnRefilled.FetchAll();
				for (uint i = 0; i < arr.length(); i++)
					WorldScript::GetWorldScript(g_scene, arr[i].GetScriptBehavior()).Execute();
			}
		}
	}
}
