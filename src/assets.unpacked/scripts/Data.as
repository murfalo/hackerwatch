string GetPlayerColor(int peer)
{
	if (peer < 0 || peer >= int(Tweak::PlayerColors.length()))
		return "ffffff";

	return Tweak::PlayerColors[peer];
}

namespace CVars
{
	bool UseTileEffects = true;
}
