enum UsableIcon
{
	None,
	Generic,
	Cross,
	Key,
	Shop,
	Speech,
	Exit,
	Question,
	Revive
}

interface IUsable
{
	UnitPtr GetUseUnit();
	bool CanUse(PlayerBase@ player);
	void Use(PlayerBase@ player);
	void NetUse(PlayerHusk@ player);
	UsableIcon GetIcon(Player@ player);
	int UsePriority(IUsable@ other);
}

class PlayerUsable
{
	IUsable@ m_usable;
	int m_refCount;

	PlayerUsable(IUsable@ usable)
	{
		@m_usable = usable;
		m_refCount = 1;
	}

	int opCmp(const PlayerUsable &in usable)
	{
		return m_usable.UsePriority(usable.m_usable);
	}
}
