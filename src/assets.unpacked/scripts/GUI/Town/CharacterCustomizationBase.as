class CharacterCustomizationBase
{
	IWidgetHoster@ m_host;
	GUIDef@ m_def;

	MarkovName@ m_randomNameGen;

	MenuTabSystem@ m_tabSystem;

	Widget@ m_wContainer;

	TextInputWidget@ m_wName;
	PortraitWidget@ m_wPortrait;

	TextWidget@ m_wVoice;

	ScalableSpriteIconButtonWidget@ m_wButtonFinish;

	array<Materials::Dye@> m_dyesOriginal;
	array<Materials::Dye@> m_dyes;

	PlayerTrails::TrailDef@ m_trailOriginal;
	PlayerTrails::TrailDef@ m_trail;

	PlayerFrame@ m_frameOriginal;
	PlayerFrame@ m_frame;

	PlayerComboStyle@ m_comboStyleOriginal;
	PlayerComboStyle@ m_comboStyle;

	PlayerCorpseGravestone@ m_gravestoneOriginal;
	PlayerCorpseGravestone@ m_gravestone;

	bool m_editing = false;
	int m_editCost;

	string m_nameOrignal;
	string m_charClass;
	array<ScriptSprite@> m_faces;
	int m_faceOriginal;
	int m_face;

	int m_voiceOriginal;
	int m_voice;

	CharacterCustomizationBase(string charClass, IWidgetHoster@ host)
	{
		m_charClass = charClass;
		@m_host = host;

		@m_tabSystem = MenuTabSystem(m_host);
		m_tabSystem.AddTab(CustomizationDyesTab(this));
		m_tabSystem.AddTab(CustomizationTrailsTab(this));
		m_tabSystem.AddTab(CustomizationFramesTab(this));
		m_tabSystem.AddTab(CustomizationCombosTab(this));
		m_tabSystem.AddTab(CustomizationGravestonesTab(this));
	}

	TownRecord@ GetTown()
	{
		auto gmMenu = cast<MainMenu>(g_gameMode);
		if (gmMenu !is null)
			return gmMenu.m_town;

		auto gmTown = cast<Campaign>(g_gameMode);
		if (gmTown !is null)
			return gmTown.m_townLocal;

		return null;
	}

	int GetNameChangeCost()
	{
		auto record = GetLocalPlayerRecord();
		if (record is null || !record.freeCustomizationUsed)
			return 0;

		return 10000;
	}

	int GetPortraitChangeCost()
	{
		auto record = GetLocalPlayerRecord();
		if (record is null || !record.freeCustomizationUsed)
			return 0;

		return 5000;
	}

	int GetDyeChangeCost(Materials::Dye@ dye)
	{
		auto record = GetLocalPlayerRecord();
		if (record is null || !record.freeCustomizationUsed)
			return 0;

		switch (dye.m_quality)
		{
			case ActorItemQuality::Common: return 500;
			case ActorItemQuality::Uncommon: return 2500;
			case ActorItemQuality::Rare: return 10000;
		}
		return 10001;
	}

	int GetTrailChangeCost(PlayerTrails::TrailDef@ trail)
	{
		auto record = GetLocalPlayerRecord();
		if (record is null || !record.freeCustomizationUsed)
			return 0;

		return 5000;
	}

	int GetFrameChangeCost(PlayerFrame@ frame)
	{
		auto record = GetLocalPlayerRecord();
		if (record is null || !record.freeCustomizationUsed)
			return 0;

		return 5000;
	}

	int GetComboStyleChangeCost(PlayerComboStyle@ style)
	{
		auto record = GetLocalPlayerRecord();
		if (record is null || !record.freeCustomizationUsed)
			return 0;

		return 5000;
	}

	int GetGravestoneChangeCost(PlayerCorpseGravestone@ gravestone)
	{
		auto record = GetLocalPlayerRecord();
		if (record is null || !record.freeCustomizationUsed)
			return 0;

		return 5000;
	}

	int GetVoiceChangeCost(Voices::VoiceDef@ voice)
	{
		auto record = GetLocalPlayerRecord();
		if (record is null || !record.freeCustomizationUsed)
			return 0;

		return voice.m_changeCost;
	}

	void Close()
	{
		m_tabSystem.Close();
	}

	void DoLayout(bool invalidated)
	{
		if (invalidated)
			m_tabSystem.DoLayout();
	}

	void Update(int dt)
	{
		m_tabSystem.Update(dt);
	}

	void Draw(SpriteBatch& sb, int idt)
	{
		m_tabSystem.Draw(sb, idt);
	}

	void Initialize(GUIDef@ def, PlayerRecord@ record = null)
	{
		@m_def = def;
		m_editing = (record !is null);

		auto faceInfo = ClassFaceInfo(m_charClass);
		for (int i = 0; i < faceInfo.m_count; i++)
			m_faces.insertLast(faceInfo.GetSprite(i));

		array<string> names = {
			"mary", "patricia", "linda", /*"barbara",*/ "elizabeth", "jennifer", "maria", "susan", "margaret", "dorothy", "lisa", "nancy", "karen", "betty", "helen", "sandra",
			"donna", "carol", "ruth", "sharon", "michelle", "laura", "sarah", "kimberly", "deborah", "jessica", "shirley", "cynthia", "angela", "melissa", "brenda", "amy",
			"anna", "rebecca", "virginia", "kathleen", "pamela", "martha", "debra", "amanda", "stephanie", "carolyn", "christine", "marie", "janet", "catherine", "frances",
			"ann", "joyce", "diane", "james", "john", "robert", "michael", "william", "david", "richard", "charles", "joseph", "thomas", "christopher", "daniel", "paul",
			"mark", "donald", "george", "kenneth", "steven", "edward", "brian", "ronald", "anthony", "kevin", "jason", "matthew", "gary", "timothy", "jose", "larry", "jeffrey",
			"frank", "scott", "eric", "stephen", "andrew", "raymond", "gregory", "joshua", "jerry", "dennis", "walter", "patrick", "peter", "harold", "douglas", "henry", "carl",
			"arthur", "ryan", "roger"
		};
		@m_randomNameGen = MarkovName(names);

		@m_wContainer = m_host.m_widget.GetWidgetById("container");

		@m_wName = cast<TextInputWidget>(m_host.m_widget.GetWidgetById("name"));
		if (record !is null)
		{
			m_wName.SetText(record.name);
			m_nameOrignal = record.name;
		}
		else
			m_wName.SetText(m_randomNameGen.GenerateName());

		@m_wPortrait = cast<PortraitWidget>(m_host.m_widget.GetWidgetById("portrait"));
		if (record !is null)
			m_wPortrait.SetRecord(record);
		else
		{
			m_wPortrait.SetClass(m_charClass);
			m_wPortrait.SetFrame("default");
		}

		@m_wVoice = cast<TextWidget>(m_host.m_widget.GetWidgetById("voice"));

		@m_wButtonFinish = cast<ScalableSpriteIconButtonWidget>(m_host.m_widget.GetWidgetById("finish-button"));

		if (record !is null)
		{
			m_face = record.face;
			m_faceOriginal = m_face;
		}
		else
			m_face = randi(m_faces.length());
		FaceChanged();

		if (record !is null)
		{
			auto voice = Voices::GetVoice(record.voice);
			if (voice !is null)
				m_voice = Voices::g_voiceDefs.findByRef(voice);
			else
				m_voice = Voices::g_voiceDefs.findByRef(Voices::g_voiceDefault);
		}
		else
			m_voice = Voices::g_voiceDefs.findByRef(Voices::g_voiceDefault);

		m_voiceOriginal = m_voice;
		VoiceChanged();

		UpdateCost();

		m_tabSystem.SetTab("dyes");
	}

	void UpdateCost()
	{
		if (m_editing)
		{
			int cost = 0;

			if (m_wName.m_text.plain() != m_nameOrignal)
				cost += GetNameChangeCost();

			if (m_face != m_faceOriginal)
				cost += GetPortraitChangeCost();

			for (uint i = 0; i < m_dyes.length(); i++)
			{
				auto dye = m_dyes[i];
				if (dye !is m_dyesOriginal[i])
					cost += GetDyeChangeCost(dye);
			}

			if (m_trail !is m_trailOriginal)
				cost += GetTrailChangeCost(m_trail);

			if (m_frame !is m_frameOriginal)
				cost += GetFrameChangeCost(m_frame);

			if (m_comboStyle !is m_comboStyleOriginal)
				cost += GetComboStyleChangeCost(m_comboStyle);

			if (m_gravestone !is m_gravestoneOriginal)
				cost += GetGravestoneChangeCost(m_gravestone);

			if (m_voice != m_voiceOriginal)
			{
				auto voice = Voices::g_voiceDefs[m_voice];
				cost += GetVoiceChangeCost(voice);
			}

			m_editCost = cost;

			auto player = GetLocalPlayerRecord();

			@m_wButtonFinish.m_icon = m_def.GetSprite("gold");
			m_wButtonFinish.m_enabled = Currency::CanAfford(player, cost);
			m_wButtonFinish.SetText(formatThousands(cost));

			if (!player.freeCustomizationUsed)
				m_wButtonFinish.m_tooltipText = Resources::GetString(".mainmenu.character.free");
			else
				m_wButtonFinish.m_tooltipText = "";
		}
		else
		{
			@m_wButtonFinish.m_icon = null;
			m_wButtonFinish.SetText(Resources::GetString(".mainmenu.character.create.play"));
		}
	}

	void FaceChanged()
	{
		if (m_faces.length() == 0 || m_face >= int(m_faces.length()))
			return;

		m_wPortrait.SetFace(m_face);
		m_wPortrait.SetDyes(m_dyes);
		m_wPortrait.UpdatePortrait();

		UpdateCost();
	}

	void PlayVoiceSample()
	{
		auto voice = Voices::g_voiceDefs[m_voice];

		if (voice.m_soundChatLines.length() > 0 && randi(10) < 7)
		{
			int randomIndex = randi(voice.m_soundChatLines.length());
			auto voiceLine = voice.m_soundChatLines[randomIndex];
			PlaySound2D(voiceLine);
			return;
		}

		vec3 pos = vec3();

		auto player = GetLocalPlayer();
		if (player !is null)
			pos = player.m_unit.GetPosition();

		if (randi(2) == 0)
			PlaySound3D(voice.m_soundHurt, pos);
		else
			PlaySound3D(voice.m_soundDeath, pos);
	}

	void VoiceChanged()
	{
		auto voice = Voices::g_voiceDefs[m_voice];
		m_wVoice.SetText(Resources::GetString(voice.m_name));
	}

	bool OnFunc(Widget@ sender, string name)
	{
		auto parse = name.split(" ");
		if (parse[0] == "random-name")
		{
			m_wName.SetText(m_randomNameGen.GenerateName());
			UpdateCost();
			return true;
		}
		else if (parse[0] == "name-changed")
		{
			UpdateCost();
			return true;
		}
		else if (parse[0] == "face-left")
		{
			if (--m_face < 0)
				m_face = int(m_faces.length()) - 1;
			FaceChanged();
			UpdateCost();
			return true;
		}
		else if (parse[0] == "face-right")
		{
			if (++m_face >= int(m_faces.length()))
				m_face = 0;
			FaceChanged();
			UpdateCost();
			return true;
		}
		else if (parse[0] == "voice-down")
		{
			if (++m_voice >= int(Voices::g_voiceDefs.length()))
				m_voice = 0;
			PlayVoiceSample();
			VoiceChanged();
			UpdateCost();
			return true;
		}
		else if (parse[0] == "voice-up")
		{
			if (--m_voice < 0)
				m_voice = int(Voices::g_voiceDefs.length()) - 1;
			PlayVoiceSample();
			VoiceChanged();
			UpdateCost();
			return true;
		}
		else if (parse[0] == "play-voice")
		{
			PlayVoiceSample();
			return true;
		}
		return m_tabSystem.OnFunc(sender, name);
	}
}
