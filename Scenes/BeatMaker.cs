using Godot;

namespace Main
{
	public partial class BeatMaker : Control
	{
		public int LoadPercent = 0;
		private MenuButton FileMenu;
		private ScrollContainer WindowScroll;
		private VBoxContainer TracksContainer;
		private AudioStreamPlayer AudioStreamPlayer;
		private SpinBox BPMInput;
		private SpinBox StartInput;
		private Control WaveformContainer;
		private TextureRect WaveFormNode;


		public override void _Ready()
		{
			LoadEditor();


		}


		public void LoadEditor()
		{
			LoadNodes();
			CallDeferred("BuildEditor");
		}

		public void LoadNodes()
		{
		FileMenu = GetNode<MenuButton>("EditorContainer/Panel/HBoxContainer/FileMenu");
		WindowScroll = GetNode<ScrollContainer>("EditorContainer/HBoxContainer2/Panel/VBoxContainer/WindowScroll");
		TracksContainer = GetNode<VBoxContainer>("EditorContainer/HBoxContainer2/Panel/VBoxContainer/WindowScroll/VBoxContainer/TracksContainer");
		AudioStreamPlayer = GetNode<AudioStreamPlayer>("AudioStreamPlayer");
		BPMInput = GetNode<SpinBox>("EditorContainer/HBoxContainer2/Panel/VBoxContainer/Panel/HBoxContainer/BPMInput");
		StartInput = GetNode<SpinBox>("EditorContainer/HBoxContainer2/Panel/VBoxContainer/Panel/HBoxContainer/StartInput");
		WaveformContainer = GetNode<Control>("EditorContainer/HBoxContainer2/Panel/VBoxContainer/WindowScroll/VBoxContainer/WaveFormContainer");
		WaveFormNode = GetNode<TextureRect>("EditorContainer/HBoxContainer2/Panel/VBoxContainer/WindowScroll/VBoxContainer/WaveFormContainer/WaveFormNode");
		}

		public void BuildEditor()
		{
			LoadPercent += 100;
			FileMenuItems();
			CallDeferred("SetProcess", true);
			CallDeferred("SetProcessInput", true);
		}
		public override void _Process(double delta)
		{
		}

		public void FileMenuItems() 
		{
			var PopUp = FileMenu.GetPopup();
			PopUp.AddItem("Import Song", 0);
			PopUp.AddItem("Import Beatmap File", 1);
			PopUp.AddSeparator();
			PopUp.AddItem("Open Song From Database", 2);
			PopUp.AddItem("Open Beatmap File From Database", 3);
			PopUp.AddSeparator();
			PopUp.AddItem("Save Beatmap Locally", 4);
			PopUp.AddItem("Export Beatmap to Database", 5);
			PopUp.AddSeparator();
			PopUp.AddItem("Reset", 6);
			PopUp.AddItem("Exit", 7);
		}


	}
}
