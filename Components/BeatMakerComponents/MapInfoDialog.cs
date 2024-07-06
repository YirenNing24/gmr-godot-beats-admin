using Godot;
using Godot.Collections;

namespace SaveMapDialog
{
    public partial class SaveMapDialog : Panel
    {   
        // SIGNAL
        [Signal]
        public delegate void MapInfoSavedEventHandler();

        // GODOT MEMORY VARIABLES
        public Dictionary sessionData = new();
        public Dictionary audioInfo = new();
        public static readonly string[] AUDIO_FIELD_NAMES = new string[] { "TITLE", "ARTIST" };
        public static readonly string sessionFilePath = "user://editor/session";
        public string audioFileName = "";
        public string beatMapMaker = "";

        // GODOT NODE VARIABLES
        private LineEdit beatMapMakerField;
        private LineEdit artistField;
        private LineEdit titleField;
        private LineEdit difficultyField;
		private Button saveButton;

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
			saveButton = GetNode<Button>("Panel/VBoxContainer/VBoxContainer2/HBoxContainer/HBoxContainer/VBoxContainer2/VBoxContainer3/HBoxContainer/SaveButton");
        }

		public void SignalConnect()
		{
			saveButton.Pressed += OnSaveButtonPressed;
		}

        public void SetUp(string audioName, string audioComments)
        {
            audioFileName = audioName;
			InitAudioInputs(audioComments);
            InitMapInputs();
        }

        public void InitAudioInputs(string audioComments)
        {
            ParseAudioComments(audioComments);
			if (titleField.Text == "")
			{
				titleField.Text = audioFileName;
			}
        }

        public void InitMapInputs()
        {
            sessionData = Utilities.BeatMakerUtils.ReadJSONFile(sessionFilePath);
            if (sessionData == null || sessionData.Count == 0)
            {
                sessionData = new Dictionary();
                return;
            }

            if (sessionData.ContainsKey("beatmap_maker"))
            {
                beatMapMaker = sessionData["beatmap_maker"].ToString();
            }
        }

        public void ParseAudioComments(string audioComments)
        {
            string[] lines = audioComments.Split('\n');

            foreach (string line in lines)
            {
                string characters = line.Trim();

                foreach (string field in AUDIO_FIELD_NAMES)
                {
                    string searchField = field + "=";

                    // Case insensitive search
                    if (characters.ToUpper().Contains(searchField.ToUpper()))
                    {
                        string[] parts = characters.Split('=');

                        // Ensure there's a value after '='
                        if (parts.Length > 1)
                        {
                            string value = parts[1].Trim();
                            string nodeName = char.ToLower(field[0]) + field.Substring(1).ToLower();

                            VBoxContainer audioC = GetNode<VBoxContainer>("VBoxContainer");
                            if (audioC.HasNode(nodeName))
                            {
                                LineEdit n = audioC.GetNode<LineEdit>(nodeName);
                                n.Text = value;
                            }
                        }
                    }
                }
            }
        }
    
		public void ApplyMapInputs()
		{
			beatMapMaker = beatMapMakerField.Text;
			sessionData["beatmap_maker"] = beatMapMaker;
			Utilities.BeatMakerUtils.WriteJSONFile(sessionFilePath, sessionData);
		}

		public void SetData(string beatMapMakerData, Dictionary audioData)
		{
			beatMapMakerField.Text = beatMapMakerData.ToString();
			SetAudioInputsFrom(audioData);
		}


		public void SetAudioInputsFrom(Dictionary data)
		{
			artistField.Text = (string)data["artist"];
			titleField.Text = (string)data["title"];

			if (titleField.Text == "")
			{
				titleField.Text = audioFileName;
			}
			
		}

		public void ApplyAudioInputs()
		{
			audioInfo["artist"] = artistField.Text;
			audioInfo["title"] = titleField.Text;
		}

		private void OnSaveButtonPressed()
		{
			if ( beatMapMakerField.Text == "" || artistField.Text == "" || difficultyField.Text == "" || titleField.Text == "" )
			{
				Visible = false;
				return;
			}
			else 
			{	
				ApplyMapInputs();
				ApplyAudioInputs();
				EmitSignal(nameof(MapInfoSaved));
			}
		}
	}
	
}
