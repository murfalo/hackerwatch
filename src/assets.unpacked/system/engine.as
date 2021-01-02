%if EDITOR_GAME || EDITOR

vec2 ToScreenspace(vec3 pos) { return vec2(pos.x, pos.y); }
vec3 ToWorldspace(vec2 pos) { return vec3(pos.x, pos.y, 0); }

class SaveSlot
{
	int Slot;
	SValue@ Town;
	bool Modded;
	array<uint32> EnabledMods;

	void EnableMod(uint32 id) {}
	void DisableMod(uint32 id) {}
	void Write() {}
}

class GameSessionSave
{
	string GetLevelFilename() { return ""; }
	SValue@ GetScene() { return null; }
	SValue@ GetGamemode() { return null; }
}

namespace HwrSaves
{
	bool IsSaving() { return false; }
	void CreateCharacter(SValue@ char) {}
	array<SValue@>@ GetCharacters() { return null; }
	array<GameSessionSave@>@ GetLevelSaves() { return null; }
	void PickCharacter(int index) {}
	void DeleteCharacter(int index) {}
	//void SaveTown(SValue@ data) {}
	//void SaveCharacter(SValue@ data, bool saveLevel) {}
	void SaveTownAndCharacter(SValue@ town, SValue@ character, bool saveLevel) {}
	SValue@ LoadHostTown() { return null; }
	void DeleteTown(int slot) {}
	void CopyTown(int slot, int newSlot, bool withChars = true) {}
	SValue@ LoadLocalTown() { return null; }
	SValue@ LoadCharacter(int peer = -1) { return null; }
	array<SaveSlot@>@ GetSaveSlots() { return null; }
	SaveSlot@ CreateSlot(int num) { return null; }
	void SwitchSlot(int slot) {}
	bool IsModded() { return false; }
	array<ResourceMod@>@ GetEnabledMods() { return null; }
}

void RenderScene(int idt, vec2 pos, vec4 vignette) {}
void StartGame(int numPlrs, string level) {}
void ChangeLevel(string level) {}
void QuitGame() {}
void ResumeGame() {}
void StopScenario() {}
string GetCurrentLevelFilename() { return ""; }
string GetCurrentLevelName() { return ""; }
int GetRestartCount() { return 0; }
void SetRestartCount(int count) {}
void SendSystemMessage(const string& in name, SValue@ data) {}
void RestartMenu() {}
uint64 GetUniquePeerId(uint8 peer) { return 0; }
void RumbleGamepad(float strength, int length) {}
void RumbleGamepadStop() {}
void PlayAsMusic(int channel, SoundEvent@ event) {}
void PauseGame(bool paused, bool localOnly) {}
bool IsPaused() { return false; }
uint64 CurrPlaytimeLevel() { return 0; }
uint64 CurrPlaytimeTotal() { return 0; }

enum GameDifficulty
{
	Easy 	= 1,
	Normal 	= 2,
	Hard 	= 4,
	Serious = 8
}

class ScenarioStartLevel
{
	string GetName() { return ""; }
	string GetLevel() { return ""; }
}

enum ScenarioModificationVisual
{
	None,
	Separator,
	Header,
}

class ScenarioModification
{
	ScenarioModificationVisual GetVisual() { return ScenarioModificationVisual::None; }
	string GetID() { return ""; }
	string GetName() { return ""; }
	string GetTooltip() { return ""; }
	string GetLockedBy() { return ""; }
	bool GetDefaultOn() { return false; }
	string GetRadioGroup() { return ""; }
	bool GetMultiplayer() { return false; }
}

class ScenarioInfo
{
	TempTexture2D@ LoadLogos() { return null; }
	string GetID() { return ""; }
	string GetTag() { return ""; }
	string GetName() { return ""; }
	string GetDescription() { return ""; }
	bool Multiplayer() { return false; }
	bool Official() { return false; }
	bool Packaged() { return false; }
	bool Workshop() { return false; }
	array<ScenarioStartLevel@>@ GetStartLevels() { return null; }
	array<ScenarioModification@>@ GetModifications() { return null; }
	int MinPlayers() { return -1; }
	int MaxPlayers() { return -1; }
}

class ResourceMod
{
	string get_ID() property { return ""; }
	string get_Name() property { return ""; }
	string get_Author() property { return ""; }
	string get_Description() property { return ""; }

	SValue@ get_Data() property { return null; }

	bool get_Packaged() property { return false; }
	uint64 get_WorkshopID() property { return 0; }
}

class ButtonState
{
	bool Down;
	bool Pressed;
	bool Released;
	int Delta;
}

class GameInput
{
	ButtonState Attack1;
	ButtonState Attack2;
	ButtonState Attack3;
	ButtonState Attack4;

	ButtonState Use;
	ButtonState Potion;

	ButtonState PlayerMenu;
	ButtonState GuildMenu;

	ButtonState MapOverlay;
	ButtonState Ping;

	vec2 MoveDir;
	vec2 AimDir;
	vec2 MousePos;
	int MouseWheelDelta;

	bool Assigned;
	bool UsingGamepad;
	bool UsingMouseLook;

	array<ControlMap@>@ GetControlMaps() { return null; }
	ControlMap@ GetCurrentMap() { return null; }
	int GetTextInputCount() { return 0; }
	TextInputControlEvent@ GetTextInput(int) { return null; }
}

class MenuInput
{
	ButtonState Up;
	ButtonState Down;
	ButtonState Left;
	ButtonState Right;
	
	ButtonState Forward;
	ButtonState Back;
	ButtonState Toggle;

	vec2 MouseMove;

	ButtonState ChatAll;
	ButtonState ChatTeam;

	ButtonState SwitchTeam;
}

enum StartMode
{
	StartGame,
	Continue,
	LoadGame,
	DropIn
}

enum MenuState
{
	MainMenu,
	InGameMenu,
	Hidden
}

enum MenuMessage
{
	Saved,
	LostConnection
}

enum ControllerType
{
	None,
	Keyboard,
	Mouse,
	MouseWheel,
	Gamepad,
	GamepadAxis,
	GamepadVector,
	Joystick,
	JoystickAxis,
	JoystickVector,
	JoystickHat
}

enum ControlBindingSetAxis
{
	None,
	Low,
	High
}

class ControlMapBinding
{
	string ID;
	string Action;
	ControlBindingSetAxis SetAxis;
}

class ControlMap
{
	string ID;
	int Index;
	bool UseMouseLook;
	bool Gamepad;
	bool Joystick;
	bool SteamController;

	bool get_SteamController() property { return false; }
	uint64 get_Handle() property { return 0; }

	array<ControlMapBinding@>@ GetBindings() { return null; }
	array<ControlMapBinding@>@ GetStaging() { return null; }

	string GetName() { return ""; }

	void Clear() { }
	void Remove(ControlMapBinding@ bind) { }
	void Add(ControllerType type, int key, const string &in action) { }

	void ClearStaging() { }
	void RemoveStaging(ControlMapBinding@ bind) { }
	void AddStaging(ControllerType type, int key, const string &in action) { }
	void AddStagingAxis(ControllerType type, int key, const string &in action, ControlBindingSetAxis setAxis) { }

	void BeginStaging() { }
	void CommitStaging() { }

	void Defaults() { }
}

class ControlBindings
{
	void Save() { }

	ControlMap@ GetMap(const string &in id) { return null; }
	array<ControlMap@>@ GetMaps() { return null; }
	bool IsExpectingTextInput() { return false; }
	void ExpectTextInput() { }
	void StopExpectTextInput() { }
	void ExpectInput() { }

	void AssignControls(int numSessions) { }
	void UnassignAll() { }
	void Assign(int player, ControlMap@ map) { }

	array<string>@ GetAvailableActions() { return null; }
}

ControlBindings@ GetControlBindings() { return null; }

class PlatformCursor { }

class LanguageInfo
{
	string ID;
	string Name;
}

namespace Platform
{
	void HideCursor() { }
	void ShowCursor() { }
	vec2 GetMousePosition() { return vec2(); }

	int GetInputCount() { return 0; }
	GameInput@ GetGameInput(int index) { return null; }
	MenuInput@ GetMenuInput(int index) { return null; }

	int GetSessionCount() { return 1; }

	array<ivec2>@ GetResolutions() { return null; }

	array<LanguageInfo>@ GetLanguages() { return null; }

	void OpenUrl(const string &in url) { }

	ButtonState GetKeyState(int button) { return ButtonState(); }

	array<ScenarioInfo@>@ GetAllScenarios() { return null; }
	ScenarioInfo@ GetScenario(const string &in id) { return null; }
	ScenarioInfo@ GetScenario(uint32 id) { return null; }

	array<ResourceMod@>@ GetAllResourceMods() { return null; }
	ResourceMod@ GetResourceMod(const string &in id) { return null; }
	ResourceMod@ GetResourceMod(uint32 id) { return null; }
}

class PlayerLoadState
{
	uint8 Peer;
	uint8 Progress;
}

namespace Lobby
{
	uint64 GetLobbyId() { return 0; }
	bool CanOpenProfile(uint8 peer) { return false; }
	void OpenProfile(uint8 peer) { }
	bool IsInLobby() { return false; }
	void CreateLobby() { }
	void JoinLobby(uint64 id) { }
	void LeaveLobby() { }
	void SendChatMessage(string msg) { }
	string GetPlayerName(uint8 peer) { return ""; }
	string GetPlayerSkin(uint8 peer) { return ""; }
	int GetPlayerPing(uint8 peer) { return -1; }
	int GetHostPing(uint8 peer) { return -1; }
	bool IsPlayerHost(uint8 peer) { return false; }
	bool IsPlayerLocal(uint8 peer) { return false; }
	int GetLocalPeer() { return -1; }
	void SetPrivate(bool priv) { }
	void SetJoinable(bool joinable) { }
	void KickPlayer(uint8 peer) { }
	void SetLevel(string level) { }
	void StartGame() { }
	void ListLobbies() { }
	void SetLobbyData(const string &in key, const string &in value) { }
	string GetLobbyData(uint64 id, const string &in key) { return ""; }
	string GetLobbyData(const string &in key) { return ""; }
	void SetLobbyMemberData(const string &in key, const string &in value) { }
	string GetLobbyMemberData(uint8 peer, const string &in key) { return ""; }
	uint8 GetLobbyMemberDownloadProgress(uint8 peer) { return 0; }
	int GetLobbyPing(uint64 id) { return -1; }
	int GetLobbyPlayerCount() { return 0; }
	int GetLobbyPlayerCount(uint64 id) { return 0; }
	int GetLobbyPlayerCountMax() { return 0; }
	int GetLobbyPlayerCountMax(uint64 id) { return 0; }
	GameDifficulty GetDifficulty() { return GameDifficulty::Normal; }
	array<string>@ GetModifiers() { return null; }
	void SetPlayerLimit(int max) { }
	void SetGemState(GemState state) { }
	array<PlayerLoadState>@ GetPlayerLoadStates() { return null; }
}

enum TextInputControlEventType
{
	Home,
	End,
	Left,
	Right,
	LeftWord,
	RightWord,
	Backspace,
	Delete,
	Tab,
	Submit,
	Cancel,
	Copy,
	Paste,
	Cut,
	Up,
	Down,
	None
}

class TextInputControlEvent
{
	utf8string text;
	TextInputControlEventType evt;
	bool select;
}

enum GemState
{
	Inactive = 0,
	Active 	 = 1,
	Perfect  = 10,
	Moo 	 = 100
}



array<ivec2>@ OPT_FindAllPatterns(ref pattern, ref grid, ref gridConsumed) { return null; }

namespace Discord
{
	class Status
	{
		void Clear() {}

		string State;
		string Details;
		int64 StartTimestamp;
		int64 EndTimestamp;
		string LargeImageKey;
		string LargeImageText;
		string SmallImageKey;
		string SmallImageText;
		string PartyId;
		int PartySize;
		int PartyMax;
		string MatchSecret;
		string JoinSecret;
		string SpectateSecret;

		bool opEquals(const Status &in other) { return true; }
		void opAssign(const Status &in copy) {}
	}

	bool IsReady() { return false; }
	void SetStatus(const Status &in) {}
}

%endif