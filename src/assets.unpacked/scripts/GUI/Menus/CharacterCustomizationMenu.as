namespace Menu
{
	class CharacterCustomizationMenu : HwrMenu
	{
		string m_context;

		CharacterCustomizationBase@ m_base;

		string m_charClass;
		bool m_charMercenary;

		CharacterCustomizationMenu(MenuProvider@ provider, CharacterCreationMenu@ creationMenu, string context)
		{
			super(provider);

			m_context = context;

			m_charClass = creationMenu.m_charClass;
			m_charMercenary = creationMenu.m_charMercenary;
		}

		void Initialize(GUIDef@ def) override
		{
			@m_base = CharacterCustomizationBase(m_charClass, this);
			m_base.Initialize(def);
		}

		void DoLayout() override
		{
			bool invalidated = m_invalidated;
			HwrMenu::DoLayout();
			m_base.DoLayout(invalidated);
		}

		void Update(int dt) override
		{
			m_base.Update(dt);

			HwrMenu::Update(dt);
		}

		void Draw(SpriteBatch& sb, int idt) override
		{
			HwrMenu::Draw(sb, idt);

			m_base.Draw(sb, idt);
		}

		void OnFunc(Widget@ sender, string name) override
		{
			if (!m_base.OnFunc(sender, name))
			{
				auto parse = name.split(" ");
				if (parse[0] == "finish")
				{
					SValueBuilder builder;
					builder.PushDictionary();
					builder.PushString("name", m_base.m_wName.m_text.plain());
					builder.PushString("class", m_charClass);
					if (Platform::HasDLC("mt"))
						builder.PushBoolean("mercenary", m_charMercenary);
					builder.PushArray("colors");
					for (uint i = 0; i < m_base.m_dyes.length(); i++)
					{
						auto dye = m_base.m_dyes[i];

						builder.PushArray();
						builder.PushInteger(int(dye.m_category));
						builder.PushInteger(dye.m_idHash);
						builder.PopArray();
					}
					builder.PopArray();
					builder.PushInteger("face", m_base.m_face);

					if (m_base.m_trail !is null)
						builder.PushInteger("current-trail", int(m_base.m_trail.m_idHash));

					if (m_base.m_frame !is null)
						builder.PushInteger("current-frame", int(m_base.m_frame.m_idHash));

					if (m_base.m_comboStyle !is null)
						builder.PushInteger("current-combo-style", int(m_base.m_comboStyle.m_idHash));

					if (m_base.m_gravestone !is null)
						builder.PushInteger("current-corpse", int(m_base.m_gravestone.m_idHash));

					auto voice = Voices::g_voiceDefs[m_base.m_voice];
					builder.PushString("voice-id", voice.m_id);

					if (Platform::HasDLC("mt") && m_charMercenary)
					{
						Platform::Service.UnlockAchievement("merc_private");

						const int mercenaryLevel = 20;
						builder.PushInteger("level", mercenaryLevel);
						builder.PushLong("experience", int64(Tweak::ExperiencePerLevel * pow2(mercenaryLevel - 1, Tweak::ExperienceExponent)));
						builder.PushInteger("mercenary-gold", 25000);
						builder.PushBoolean("in-town", true);
						builder.PushBoolean("just-created", true);
					}
					else
					{
						// Without this, the character list shows level 0
						builder.PushInteger("level", 1);
					}

					HwrSaves::CreateCharacter(builder.Build());
					HwrSaves::PickCharacter(0);

					FinishContext(m_context);
					PopFromProvider(2);
				}
				else
					HwrMenu::OnFunc(sender, name);
			}
		}
	}
}
