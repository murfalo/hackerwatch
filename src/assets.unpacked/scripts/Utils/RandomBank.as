enum RandomContext
{
	CardGame0,
	CardGame1,
	CardGame2,
	CardGame3,
	CardGame4,
	CardGame5,
	CardGame6,
	CardGame7,
	CardGame8,
	CardGame9,

	NumContexts,
}

namespace RandomBank
{
	array<RandomSequence> g_randomSequences(int(RandomContext::NumContexts));

	int Int(RandomContext ctx, int max) { return g_randomSequences[int(ctx)].GetInt(max); }
	float Float(RandomContext ctx) { return g_randomSequences[int(ctx)].GetFloat(); }
	uint GetSeed(RandomContext ctx) { return g_randomSequences[int(ctx)].GetSeed(); }
	void SetSeed(RandomContext ctx, uint seed) { g_randomSequences[int(ctx)].SetSeed(seed); }
}
