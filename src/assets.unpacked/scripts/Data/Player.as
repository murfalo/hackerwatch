namespace Tweak
{
	const int SpawnInvulnTime = 3000;

	const int HealAddPerLevel = 100000;
	const int BaseArmor = 50;

	const float PlayerSpeed = 2.4f;
	const float PlayerSpeedMax = 5.0f;
	const int DashChargeTime = 1500;
	const int MaxDashes = 8;
	const int DashSpeed = 12;
	const int DashDuration = 120;

	const float HealScalePerLevel = 1.0f;

	const int ExtraLives = 0;
	const int BaseHealth = 100;

	const int PlayerCameraHeight = 0;

	const int SkillPointsPerLevelBase = 3;
	const int SkillPointsPerLevelMod = 5;
	const int SkillPointsPerLevelCap = 10;

	const int ExperiencePerLevel = 750;
	const float ExperienceExponent = 2.25f;
	
	const float DeathExperienceLoss = 0.0f;

	const int ExperienceShareRange = 500;
	const int HalfExperienceShareRange = 1200;
	float ExperienceScale = 1.0f;

	const int DesertNewGamePlusStars = 10;
	const int MoonNewGamePlusStars = 10;

	const int MtBlocksCooldown = 2000;
	
	
	vec2 NewGamePlusNegArmor(float ngp)
	{
//%if HARDCORE
		// return vec2(90.0f, 75.0f) * pow(ngp, 0.85f);
		// return vec2(75.0f, 62.0f) * pow(ngp, 0.9f);
//%else
		return vec2(60.0f, 50.0f) * pow(ngp, 0.77f);
//%endif
	}
	

	/*
	array<array<vec4>> SkinColors = {
		MakePlayerColor(102,17,47,  207,90,85,  255,203,157)
	};
	
	array<array<vec4>> ClothesColors = {
		MakePlayerColor(18,40,59,  29,71,109,  49,125,195),
		MakePlayerColor(112,88,29,  235,172,21,  255,230,59),
		MakePlayerColor(255,166,59,  255,166,59,  255,230,59),

		MakePlayerColor(41,26,18,  102,68,46,  142,100,69),
		MakePlayerColor(1,22,30,  11,56,75,  49,125,195),
		MakePlayerColor(162,60,32,  215,99,40,  215,123,40),

		MakePlayerColor(41,26,18,  102,68,46,  142,100,69),
		MakePlayerColor(1,22,30,  11,56,75,  49,125,195),
		MakePlayerColor(162,60,32,  215,99,40,  215,123,40),

		MakePlayerColor(57,72,34,  134,189,56,  180,234,96),
		MakePlayerColor(30,58,78,  53,103,139,  93,151,193),
		MakePlayerColor(92,0,0,  166,0,0,  202,0,0),

		MakePlayerColor(51,37,0,  161,99,0,  230,167,24),
		MakePlayerColor(92,0,0,  166,0,0,  212,0,0),
		MakePlayerColor(22,22,26,  46,47,51,  65,67,72),

		MakePlayerColor(43,48,58,  117,117,135,  255,255,255),
		MakePlayerColor(10,0,47,  103,0,118,  147,0,118),
		MakePlayerColor(92,52,20,  137,85,45,  255,169,102),

		MakePlayerColor(102,17,47,  160,18,52,  243,83,59),
		MakePlayerColor(209,114,0,  255,166,59,  255,230,59),
		MakePlayerColor(151,88,69,  238,136,100,  209,194,176),
		
		MakePlayerColor(17,43,102,  18,92,244,  59,137,243),
		MakePlayerColor(104,104,104,  157,157,157,  196,196,196),
		MakePlayerColor(111,105,114,  171,161,177,  194,190,194),
		
		MakePlayerColor(44,51,22,  103,161,53,  136,191,111),
		MakePlayerColor(209,33,0,  255,90,59,  255,154,59),
		MakePlayerColor(111,105,114,  171,161,177,  194,190,194),
		
		MakePlayerColor(92,27,23,  219,153,23,  221,203,55),
		MakePlayerColor(28,88,122,  61,93,156,  61,124,156),
		MakePlayerColor(60,65,67,  92,101,104,  110,111,113)
	};

	array<vec4> MakePlayerColor(int r1, int g1, int b1,  int r2, int g2, int b2,  int r3, int g3, int b3)
	{
		array<vec4> colors = {
			tocolor(vec4(r1 / 255.0f, g1 / 255.0f, b1 / 255.0f, 1.0f)),
			tocolor(vec4(r2 / 255.0f, g2 / 255.0f, b2 / 255.0f, 1.0f)),
			tocolor(vec4(r3 / 255.0f, g3 / 255.0f, b3 / 255.0f, 1.0f))
		};
		
		return colors;
	}
	*/
}



