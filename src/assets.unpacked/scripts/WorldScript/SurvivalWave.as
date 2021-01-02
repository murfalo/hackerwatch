namespace WorldScript
{
	[WorldScript color="255 0 255" icon="system/icons.png;32;192;32;32"]
	class SurvivalWave
	{
		[Editable validation=IsExecutable]
		UnitFeed OnFinished;

		[Editable validation=IsExecutable]
		UnitFeed OnSubWaveEarlyFinish;

		[Editable default=8000]
		int SubWaveDelay;
		[Editable default=2000]
		int SubWaveMinimumDelay;

		[Editable default=false]
		bool SubWaveWait;

		[Editable validation=IsExecutable]
		UnitFeed SubWave0;
		[Editable validation=IsExecutable]
		UnitFeed SubWave1;
		[Editable validation=IsExecutable]
		UnitFeed SubWave2;
		[Editable validation=IsExecutable]
		UnitFeed SubWave3;
		[Editable validation=IsExecutable]
		UnitFeed SubWave4;
		[Editable validation=IsExecutable]
		UnitFeed SubWave5;
		[Editable validation=IsExecutable]
		UnitFeed SubWave6;
		[Editable validation=IsExecutable]
		UnitFeed SubWave7;
		[Editable validation=IsExecutable]
		UnitFeed SubWave8;
		[Editable validation=IsExecutable]
		UnitFeed SubWave9;
		[Editable validation=IsExecutable]
		UnitFeed SubWave10;
		[Editable validation=IsExecutable]
		UnitFeed SubWave11;
		[Editable validation=IsExecutable]
		UnitFeed SubWave12;
		[Editable validation=IsExecutable]
		UnitFeed SubWave13;
		[Editable validation=IsExecutable]
		UnitFeed SubWave14;
		[Editable validation=IsExecutable]
		UnitFeed SubWave15;

		bool IsExecutable(UnitPtr unit)
		{
			WorldScript@ script = WorldScript::GetWorldScript(unit);
			if (script is null)
				return false;

			return script.IsExecutable();
		}

		SValue@ ServerExecute()
		{
			ClientExecute(null);
			return null;
		}

		void ClientExecute(SValue@ val)
		{
			Survival@ gamemode = cast<Survival>(g_gameMode);
			if (gamemode is null)
				return;

			gamemode.SetWave(this);
		}
	}
}
