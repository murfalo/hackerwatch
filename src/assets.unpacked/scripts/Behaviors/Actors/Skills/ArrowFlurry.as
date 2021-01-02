namespace Skills
{
	class ArrowFlurry : Whirlnova
	{
		ArrowFlurry(UnitPtr unit, SValue& params)
		{
			super(unit, params);

			string strProjectile = GetParamString(unit, params, "projectile", false);
			if (strProjectile != "")
				@m_projProd = Resources::GetUnitProducer(strProjectile);
			else
			{
				auto player = cast<PlayerBase>(m_owner);
				if (player !is null)
				{
					auto primarySkill = cast<Skills::ShootProjectile>(player.m_skills[0]);
					if (primarySkill !is null)
						@m_projProd = primarySkill.m_projectile;
				}
			}

			if (m_projProd is null)
				PrintError("Projectile could not be set!");
		}
	}
}
