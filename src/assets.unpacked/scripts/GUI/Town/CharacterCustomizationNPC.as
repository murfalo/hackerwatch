class CharacterCustomizationNPC : ScriptWidgetHost
{
	CharacterCustomizationBase@ m_base;

	SoundEvent@ m_sndBuyGold;

	CharacterCustomizationNPC(SValue& sval)
	{
		super();

		@m_sndBuyGold = Resources::GetSoundEvent("event:/ui/buy_gold");
	}

	bool ShouldFreezeControls() override { return true; }
	bool ShouldDisplayCursor() override { return true; }
	bool ShouldSaveExistance() override { return false; }

	void Initialize(bool loaded) override
	{
		auto record = GetLocalPlayerRecord();
		@m_base = CharacterCustomizationBase(record.charClass, this);
		m_base.Initialize(m_def, GetLocalPlayerRecord());
	}

	void Stop() override
	{
		m_base.Close();

		ScriptWidgetHost::Stop();
	}

	void DoLayout() override
	{
		bool invalidated = m_invalidated;
		ScriptWidgetHost::DoLayout();
		m_base.DoLayout(invalidated);
	}

	void Update(int dt) override
	{
		m_base.Update(dt);

		ScriptWidgetHost::Update(dt);
	}

	void Draw(SpriteBatch& sb, int idt) override
	{
		ScriptWidgetHost::Draw(sb, idt);

		m_base.Draw(sb, idt);
	}

	void OnFunc(Widget@ sender, string name) override
	{
		if (!m_base.OnFunc(sender, name))
		{
			auto parse = name.split(" ");
			if (parse[0] == "finish")
			{
				if (parse.length() == 1)
				{
					g_gameMode.ShowDialog(
						"finish",
						Resources::GetString(".mainmenu.character.customize.finish", { { "cost", formatThousands(m_base.m_editCost) } }),
						Resources::GetString(".menu.yes"),
						Resources::GetString(".menu.no"),
						this);
				}
				else if (parse[1] == "yes")
				{
					if (!Currency::CanAfford(m_base.m_editCost))
					{
						PrintError("Not enough gold!");
						return;
					}

					Currency::Spend(m_base.m_editCost);

					PlaySound2D(m_sndBuyGold);

					auto voice = Voices::g_voiceDefs[m_base.m_voice];

					auto record = GetLocalPlayerRecord();
					record.name = m_base.m_wName.m_text.plain();
					record.colors = m_base.m_dyes;
					record.face = m_base.m_face;
					record.voice = voice.m_id;

					if (m_base.m_trail !is null)
						record.currentTrail = m_base.m_trail.m_idHash;
					else
						record.currentTrail = 0;

					if (m_base.m_frame !is null)
						record.currentFrame = m_base.m_frame.m_idHash;

					if (m_base.m_comboStyle !is null)
						record.currentComboStyle = m_base.m_comboStyle.m_idHash;

					if (m_base.m_gravestone !is null)
						record.currentCorpse = m_base.m_gravestone.m_idHash;
					else
						record.currentCorpse = 0;

					if (!record.freeCustomizationUsed)
						record.freeCustomizationUsed = true;

					auto player = cast<PlayerBase>(record.actor);
					player.UpdateProperties();

					SValueBuilder builder;
					builder.PushDictionary();
					builder.PushString("name", record.name);
					builder.PushInteger("face", record.face);
					builder.PushString("voice", record.voice);
					builder.PushArray("colors");
					for (uint i = 0; i < record.colors.length(); i++)
					{
						auto dye = record.colors[i];

						builder.PushArray();
						builder.PushInteger(int(dye.m_category));
						builder.PushInteger(dye.m_idHash);
						builder.PopArray();
					}
					builder.PopArray();

					builder.PushInteger("trail", int(record.currentTrail));
					builder.PushInteger("frame", int(record.currentFrame));
					builder.PushInteger("combo-style", int(record.currentComboStyle));
					builder.PushInteger("corpse", int(record.currentCorpse));

					builder.PopDictionary();
					(Network::Message("PlayerUpdateColors") << builder.Build()).SendToAll();

					Stop();
				}
			}
			else if (parse[0] == "back")
				Stop();
		}
	}
}
