// Loosely based on: https://github.com/AlexeyMK/markov-baby-names/blob/master/markovbaby.py
// - Ported to Angelscript
// - Modified to add a minimum and maximum length when generating names
// - Don't include anything like "rrr" or "nnn" (2 consecutive characters max)
// - There must be at least 1 vowel for it to be valid
// - N character lookback for more realistic names

class MarkovPair
{
	string m_char;
	string m_next;
}

class MarkovName
{
	array<MarkovPair@> m_chain;
	int m_lookback;

	MarkovName(array<string>@ input, int lookback = 2)
	{
		m_lookback = lookback;

		for (uint i = 0; i < input.length(); i++)
		{
			string name = input[i];
			// name = "alice"
			for (uint j = 0; j < name.length() - 1; j++)
			{
				GetPair(name.substr(j, 1), true).m_next += name.substr(j + 1, 1);
				// "li" -> "c"
				for (int k = 2; k <= m_lookback; k++)
				{
					if (int(j) < k - 1)
						continue;
					GetPair(name.substr(j - (k - 1), k), true).m_next += name.substr(j + 1, 1);
				}
			}
			// +1 for "e" as last character
			for (int j = 1; j <= m_lookback; j++)
				GetPair(name.substr(name.length() - j, j), true).m_next += " ";
			// +1 for "a" as first character
			GetPair(" ", true).m_next += name.substr(0, 1);
		}
	}

	MarkovPair@ GetPair(string char, bool allowNew = false)
	{
		for (uint i = 0; i < m_chain.length(); i++)
		{
			if (m_chain[i].m_char == char)
				return m_chain[i];
		}

		if (allowNew)
		{
			auto newPair = MarkovPair();
			newPair.m_char = char;
			m_chain.insertLast(newPair);
			return newPair;
		}

		return null;
	}

	string GenerateName(uint lenMin = 4, uint lenMax = 12)
	{
		uint bigAttempts = 0;

		string vowels = "aoeiu";

		while (bigAttempts < 5)
		{
			bool hasVowel = false;
			uint smallAttempts = 0;

			string ret;
			string cur = " "; // used to mark both first and last character
			while ((cur != " " || ret.length() < lenMin) && ret.length() < lenMax && smallAttempts < 5)
			{
				MarkovPair@ pair;
				if (ret.length() >= 2)
				{
					for (int i = m_lookback; i >= 2; i--)
					{
						if (ret.length() < uint(i))
							continue;

						string part = ret.substr(ret.length() - i, i);
						@pair = GetPair(part);
						if (pair !is null)
							break;
					}
				}
				if (pair is null)
					@pair = GetPair(cur);
				if (pair is null)
					break;

				cur = pair.m_next.substr(randi(pair.m_next.length()), 1);

				if (vowels.findFirst(cur) != -1)
					hasVowel = true;

				if (cur == " " || (ret.length() >= 2 && ret.substr(ret.length() - 2, 1) == cur))
				{
					cur = ret.substr(ret.length() - 1, 1);
					if (ret.length() < lenMin)
					{
						smallAttempts++;
						continue;
					}
					break;
				}
				ret += cur;
			}

			if (ret.length() < lenMin || !hasVowel)
			{
				bigAttempts++;
				continue;
			}

			return ret.substr(0, 1).toUpper() + ret.substr(1);
		}

		return "Bob"; // This will hopefully never happen
	}
}
