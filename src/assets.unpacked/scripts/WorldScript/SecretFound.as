namespace WorldScript
{
	[WorldScript color="255 255 102" icon="system/icons.png;352;32;32;32"]
	class SecretFound
	{
		SValue@ ServerExecute()
		{
			Stats::Add("secrets-found", 1, GetLocalPlayerRecord());

			auto campaign = cast<Campaign>(g_gameMode);
			if (campaign !is null)
			{
				//campaign.FoundSecrets++;
				//campaign.FoundSecretsTotal++;
			}
			return null;
		}

		void ClientExecute(SValue@ val)
		{
			ServerExecute();
		}
	}
}
