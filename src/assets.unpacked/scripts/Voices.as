namespace Voices
{
	class VoiceDef
	{
		string m_id;
		string m_name;

		int m_changeCost;

		array<SoundEvent@> m_soundChatLines;

		SoundEvent@ m_soundHurt;
		SoundEvent@ m_soundDeath;

		int opCmp(const VoiceDef &in other) const
		{
			return m_id.opCmp(other.m_id);
		}
	}

	array<VoiceDef@> g_voiceDefs;
	VoiceDef@ g_voiceDefault;

	void AddVoiceFile(SValue@ sval)
	{
		auto newDef = VoiceDef();
		newDef.m_id = GetParamString(UnitPtr(), sval, "id");

		if (GetVoice(newDef.m_id) !is null)
		{
			PrintError("There's already a voice with ID \"" + newDef.m_id + "\"!");
			return;
		}

		newDef.m_name = GetParamString(UnitPtr(), sval, "name");

		newDef.m_changeCost = GetParamInt(UnitPtr(), sval, "change-cost", false, 250);

		int numChatLines = GetParamInt(UnitPtr(), sval, "num-chat-lines", false, 0);
		if (numChatLines > 0)
		{
			string chatLinePrefix = GetParamString(UnitPtr(), sval, "sound-chat-lines");
			for (int i = 0; i < numChatLines; i++)
			{
				string chatEventPath = chatLinePrefix + (i + 1);
				auto chatLineEvent = Resources::GetSoundEvent(chatEventPath);
				if (chatLineEvent is null)
					continue;
				newDef.m_soundChatLines.insertLast(chatLineEvent);
			}
		}

		@newDef.m_soundHurt = Resources::GetSoundEvent(GetParamString(UnitPtr(), sval, "sound-hurt"));
		@newDef.m_soundDeath = Resources::GetSoundEvent(GetParamString(UnitPtr(), sval, "sound-death"));

		g_voiceDefs.insertLast(newDef);
		g_voiceDefs.sortAsc();

		if (newDef.m_id == "default")
			@g_voiceDefault = newDef;
	}

	VoiceDef@ GetVoice(const string &in id)
	{
		for (uint i = 0; i < g_voiceDefs.length(); i++)
		{
			if (g_voiceDefs[i].m_id == id)
				return g_voiceDefs[i];
		}
		return null;
	}

	VoiceDef@ GetRandomVoice()
	{
		return g_voiceDefs[randi(g_voiceDefs.length())];
	}
}
