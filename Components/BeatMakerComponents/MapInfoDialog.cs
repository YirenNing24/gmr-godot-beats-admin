using Godot;
using Godot.Collections;

namespace SaveMapDialog
{
	public partial class SaveMapDialog : Panel
{	

	//** SIGNAL
	[Signal]
	public delegate void MapInfoSavedEventHandler();

	//**GODOT MEMORY VARIABLES
	public Dictionary sessionData = new();
	public Dictionary audioInfo = new();
	public static readonly string[] AUDIO_FIELD_NAMES = new string[] { "TITLE", "ARTIST" };
	public static readonly string sessionFilePath = "user://editor/session";
	public string audioFileName = "";
	public string beatMapMaker = "";


	//**GODOT NODE VARIABLES
	private LineEdit beatMapMakerField;
	private LineEdit artistField;
	private LineEdit titleField;
	private LineEdit difficultyField;

	public override void _Ready()
	{
		LoadNodes();
	}


	private void LoadNodes()
	{
		beatMapMakerField = GetNode<LineEdit>("Panel/VBoxContainer/VBoxContainer2/HBoxContainer/HBoxContainer/VBoxContainer2/VBoxContainer3/UsernameField");
		artistField = GetNode<LineEdit>("Panel/VBoxContainer/VBoxContainer2/HBoxContainer/HBoxContainer/VBoxContainer2/VBoxContainer3/ArtistField");
		titleField = GetNode<LineEdit>("Panel/VBoxContainer/VBoxContainer2/HBoxContainer/HBoxContainer/VBoxContainer2/VBoxContainer3/TitleField");
		difficultyField = GetNode<LineEdit>("Panel/VBoxContainer/VBoxContainer2/HBoxContainer/HBoxContainer/VBoxContainer2/VBoxContainer3/DifficultyField");
	}

	public void SetUp(string audioName, string audioComments)
	{
		audioFileName = audioName;

	}

	public void InitAudioInputs()
	{
		sessionData = Utilities.BeatMakerUtils.ReadJSONFile(sessionFilePath);

	}


}

	
}


