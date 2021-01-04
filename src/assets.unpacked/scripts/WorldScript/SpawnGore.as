namespace WorldScript
{
	[WorldScript color="255 50 50" icon="system/icons.png;64;320;32;32"]
	class SpawnGore
	{
		vec3 Position;

		[Editable]
		string Path;

		[Editable default=true]
		bool Death;

		[Editable default=1.0]
		float Damage;

		[Editable]
		int Angle;

		[Editable default=1.0]
		float ForceXY;
		[Editable default=1.0]
		float ForceZ;

		GoreSpawner@ m_gore;

		SValue@ ServerExecute()
		{
			if (m_gore is null)
				@m_gore = LoadGore(Path);
			if (m_gore is null)
				return null;

			float mulBeforeXY = m_gore.m_forceMulXY;
			float mulBeforeZ = m_gore.m_forceMulZ;
			m_gore.m_forceMulXY = ForceXY;
			m_gore.m_forceMulZ = ForceZ;
			if (Death)
				m_gore.OnDeath(Damage, xy(Position), Angle * PI / 180.0);
			else
				m_gore.OnHit(Damage, xy(Position), Angle * PI / 180.0);
			m_gore.m_forceMulXY = mulBeforeXY;
			m_gore.m_forceMulZ = mulBeforeZ;

			return null;
		}

		void ClientExecute(SValue@ val)
		{
			ServerExecute();
		}
	}
}
