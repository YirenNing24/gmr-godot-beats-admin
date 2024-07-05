using Godot;

namespace Main
{
	public partial class BeatMaker : Control
	{

		[Signal]
		public delegate void PreviewUpdatedEventHandler();

		//**GODOT MEMORY VARIABLES
		public int loadPercent = 0;
		public string oggFilePath = "";
		public bool isPlaying = false;
		public bool isFollowPlaying = false;
		public int windowSize = 720;
		public AudioStreamOggVorbis stream;
		public bool isPopupActive = false;
		public string editorDir;
		public string audioFileName;
		private GodotThread audioLoadThread;

		//**GODOT NODE VARIABLES
		private MenuButton fileMenu;
		private ScrollContainer windowScroll;
		private VBoxContainer tracksContainer;
		private AudioStreamPlayer audioStreamPlayer;
		private SpinBox bpmInput;
		private SpinBox startInput;
		private Control waveformContainer;
		private TextureRect waveFormNode;
		private Control cursorContainer;	
		private Slider cursorSlider;
		private Node2D cursorStatic;
		private Node2D cursorPlayback;
		private FileDialog importMap;
		private FileDialog fileDialog;
		private Panel saveMapDialog;
		private Button playButton;



		public override void _Ready()
		{
			LoadEditor();
		}

		private void LoadEditor()
		{
			LoadNodes();
			CallDeferred("BuildEditor");
		}

		private void LoadNodes()
		{
			fileMenu = GetNode<MenuButton>("EditorContainer/Panel/HBoxContainer/FileMenu");
			windowScroll = GetNode<ScrollContainer>("EditorContainer/HBoxContainer2/Panel/VBoxContainer/WindowScroll");
			tracksContainer = GetNode<VBoxContainer>("EditorContainer/HBoxContainer2/Panel/VBoxContainer/WindowScroll/VBoxContainer/TracksContainer");
			audioStreamPlayer = GetNode<AudioStreamPlayer>("AudioStreamPlayer");
			bpmInput = GetNode<SpinBox>("EditorContainer/HBoxContainer2/Panel/VBoxContainer/Panel/HBoxContainer/BPMInput");
			startInput = GetNode<SpinBox>("EditorContainer/HBoxContainer2/Panel/VBoxContainer/Panel/HBoxContainer/StartInput");
			waveformContainer = GetNode<Control>("EditorContainer/HBoxContainer2/Panel/VBoxContainer/WindowScroll/VBoxContainer/WaveFormContainer");
			waveFormNode = GetNode<TextureRect>("EditorContainer/HBoxContainer2/Panel/VBoxContainer/WindowScroll/VBoxContainer/WaveFormContainer/WaveFormNode");
			cursorContainer = GetNode<Control>("EditorContainer/HBoxContainer2/Panel/VBoxContainer/WindowScroll/VBoxContainer/WaveFormContainer/CursorContainer");
			cursorSlider = GetNode<HSlider>("EditorContainer/HBoxContainer2/Panel/VBoxContainer/WindowScroll/VBoxContainer/WaveFormContainer/CursorContainer/CursorSlider");
			cursorStatic = GetNode<Node2D>("EditorContainer/HBoxContainer2/Panel/VBoxContainer/WindowScroll/VBoxContainer/WaveFormContainer/CursorContainer/CursorStatic");
			cursorPlayback = GetNode<Node2D>("EditorContainer/HBoxContainer2/Panel/VBoxContainer/WindowScroll/VBoxContainer/WaveFormContainer/CursorContainer/CursorPlayback");
			importMap = GetNode<FileDialog>("ImportMap");
			fileDialog = GetNode<FileDialog>("FileDialog");
			saveMapDialog = GetNode<Panel>("MapInfoDialog");
			playButton = GetNode<Button>("EditorContainer/HBoxContainer2/Panel/VBoxContainer/Panel/HBoxContainer/PlayButton");

			audioLoadThread =  new GodotThread();
		}

		private void BuildEditor()
		{
			loadPercent += 100;
			FileMenuItems();
			CallDeferred("SetProcess", true);
			CallDeferred("SetProcessInput", true);
		}

		public override void _Process(double delta)
		{
		}

		private void FileMenuItems() 
		{
			var popUp = fileMenu.GetPopup();
			popUp.AddItem("Import Song", 0);
			popUp.AddItem("Import Beatmap File", 1);
			popUp.AddSeparator();
			popUp.AddItem("Open Song From Database", 2);
			popUp.AddItem("Open Beatmap File From Database", 3);
			popUp.AddSeparator();
			popUp.AddItem("Save Beatmap Locally", 4);
			popUp.AddItem("Export Beatmap to Database", 5);
			popUp.AddSeparator();
			popUp.AddItem("Reset", 6);
			popUp.AddItem("Exit", 7);

		 	popUp.IndexPressed += OnFileMenuButtonIndexPressed;
		}

        private void OnFileMenuButtonIndexPressed(long index)
        {
			if (index == 0)
			{
				ImportAudio();
			}

			else if(index == 6)
			{
	
			}

        }

        private void ImportAudio()
        {
			fileDialog.Visible = true;
			fileDialog.CurrentFile = "";
			fileDialog.PopupCentered();

			EmitSignal(nameof(PreviewUpdated));
        }
    }
}
