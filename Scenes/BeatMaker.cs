using System;
using System.IO;
using System.Security.Cryptography.X509Certificates;
using Godot;
using Godot.Collections;

namespace Main
{
	public partial class BeatMaker : Control
	{
		[Signal]
		public delegate void PreviewUpdatedEventHandler();

		// Grouping memory variables
		public class MemoryVariables
		{
			public int loadPercent = 0;
			public string oggFilePath = "";
			public bool isPlaying = false;
			public bool isFollowPlaying = false;
			public int windowSize = 720;
			public AudioStreamOggVorbis stream;
			public bool isPopupActive = false;
			public string editorDir;
			public string audioFileName;
			public GodotThread audioLoadThread;
			public int mapStartPost;
			public int trackLength;
			public int trackSpeed;
			public float trackTempo;
			public bool mapInfoWasSaved;
			public bool pendingExport;
			public int waveFormLength;
			public int waveFormScale;
			public float tempoUpdateTimeOut;
			public int tempoUpdateInProcess;
			public int uiScale;
			public float scaleRatio;
			public int previousScaleRatio;
			public float barSize;
			public int barsCount;
			public int quarterTimeInSeconds;
			public float sampleDurationInSeconds;
			public int windowScrollSize = 0;
			public bool pendingWScrollUpdate = false;
			public bool cursorSliderPressed = false;
			public int windowScrollLastVal = 0;
			public int windowScrollAndCursorD = 0;
			public int windowsScrollLastPos = 0;
			public Array<Track> tracks;
			public bool isConnecting = false;
		}

		public MemoryVariables memoryVariables = new();

		// Grouping node variables
		public class NodeVariables
		{
			public MenuButton fileMenu;
			public ScrollContainer windowScroll;
			public VBoxContainer tracksContainer;
			public AudioStreamPlayer audioStreamPlayer;
			public SpinBox bpmInput;
			public SpinBox startInput;
			public Control waveformContainer;
			public TextureRect waveFormNode;
			public Control cursorContainer;	
			public Slider cursorSlider;
			public Node2D cursorStatic;
			public Node2D cursorPlayback;
			public FileDialog importMap;
			public FileDialog fileDialog;
			public Panel saveMapDialog;
			public Button playButton;
			public Node2D activeNote;
			public Control activeTrack;
		}

		public NodeVariables nodeVariables = new();

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
			nodeVariables.fileMenu = GetNode<MenuButton>("EditorContainer/Panel/HBoxContainer/FileMenu");
			nodeVariables.windowScroll = GetNode<ScrollContainer>("EditorContainer/HBoxContainer2/Panel/VBoxContainer/WindowScroll");
			nodeVariables.tracksContainer = GetNode<VBoxContainer>("EditorContainer/HBoxContainer2/Panel/VBoxContainer/WindowScroll/VBoxContainer/TracksContainer");
			nodeVariables.audioStreamPlayer = GetNode<AudioStreamPlayer>("AudioStreamPlayer");
			nodeVariables.bpmInput = GetNode<SpinBox>("EditorContainer/HBoxContainer2/Panel/VBoxContainer/Panel/HBoxContainer/BPMInput");
			nodeVariables.startInput = GetNode<SpinBox>("EditorContainer/HBoxContainer2/Panel/VBoxContainer/Panel/HBoxContainer/StartInput");
			nodeVariables.waveformContainer = GetNode<Control>("EditorContainer/HBoxContainer2/Panel/VBoxContainer/WindowScroll/VBoxContainer/WaveFormContainer");
			nodeVariables.waveFormNode = GetNode<TextureRect>("EditorContainer/HBoxContainer2/Panel/VBoxContainer/WindowScroll/VBoxContainer/WaveFormContainer/WaveFormNode");
			nodeVariables.cursorContainer = GetNode<Control>("EditorContainer/HBoxContainer2/Panel/VBoxContainer/WindowScroll/VBoxContainer/WaveFormContainer/CursorContainer");
			nodeVariables.cursorSlider = GetNode<HSlider>("EditorContainer/HBoxContainer2/Panel/VBoxContainer/WindowScroll/VBoxContainer/WaveFormContainer/CursorContainer/CursorSlider");
			nodeVariables.cursorStatic = GetNode<Node2D>("EditorContainer/HBoxContainer2/Panel/VBoxContainer/WindowScroll/VBoxContainer/WaveFormContainer/CursorContainer/CursorStatic");
			nodeVariables.cursorPlayback = GetNode<Node2D>("EditorContainer/HBoxContainer2/Panel/VBoxContainer/WindowScroll/VBoxContainer/WaveFormContainer/CursorContainer/CursorPlayback");
			nodeVariables.importMap = GetNode<FileDialog>("ImportMap");
			nodeVariables.fileDialog = GetNode<FileDialog>("FileDialog");
			nodeVariables.saveMapDialog = GetNode<Panel>("MapInfoDialog");
			nodeVariables.playButton = GetNode<Button>("EditorContainer/HBoxContainer2/Panel/VBoxContainer/Panel/HBoxContainer/PlayButton");

			memoryVariables.audioLoadThread = new GodotThread();
		}

		public void BuildEditor()
		{
			memoryVariables.loadPercent += 100;
			FileMenuItems();
			CallDeferred("SetProcess", true);
			CallDeferred("SetProcessInput", true);
		}

		public override void _Process(double delta)
		{
			// Only update scroll position if there's a pending update
			if (memoryVariables.pendingWScrollUpdate)
			{
				nodeVariables.windowScroll.SetHScroll(memoryVariables.windowScrollSize);
				memoryVariables.pendingWScrollUpdate = false;
			}

			// Get the current window size
			var window = GetWindow();
			Vector2 newCustomMinSize = new Vector2(window.Size.X - 200, 260);

			// Only update CustomMinimumSize if it has changed
			if (nodeVariables.tracksContainer.CustomMinimumSize != newCustomMinSize)
			{
				nodeVariables.tracksContainer.CustomMinimumSize = newCustomMinSize;
			}

			// Only update cursor position if it has changed
			Vector2 newCursorPos = new Vector2(nodeVariables.cursorContainer.Position.X, nodeVariables.windowScroll.ScrollVertical);
			if (nodeVariables.cursorContainer.Position != newCursorPos)
			{
				nodeVariables.cursorContainer.Position = newCursorPos;
			}

			if (memoryVariables.tempoUpdateTimeOut > 0)
			{
				memoryVariables.tempoUpdateTimeOut -= (float)delta;
				int oldWaveFormLength = memoryVariables.waveFormLength;
				float cursorValue = (float)nodeVariables.cursorSlider.Value;
				float scrollValue = (float)nodeVariables.windowScroll.ScrollHorizontal;
				float dd = scrollValue - cursorValue;
				SetParams();
			}
		}

		public void SetParams()
		{
			memoryVariables.sampleDurationInSeconds = (float)memoryVariables.stream.GetLength();
			memoryVariables.quarterTimeInSeconds = (int)(60 / memoryVariables.trackTempo);
			int cellWidth = Utilities.Constants.CellWidth;
			int quartersCount = Utilities.Constants.QuartersCount;
			int cellsInQuarterCount = Utilities.Constants.CellsInQuarterCount;
			int barSize = cellWidth * quartersCount * cellsInQuarterCount;
			memoryVariables.trackSpeed = barSize / (memoryVariables.quarterTimeInSeconds * quartersCount);
			memoryVariables.trackLength = (int)(memoryVariables.trackSpeed * memoryVariables.sampleDurationInSeconds);
			memoryVariables.barsCount = (int)(memoryVariables.trackLength / memoryVariables.barSize);

			memoryVariables.waveFormScale = memoryVariables.trackLength / Utilities.Constants.WaveformWidth;
			memoryVariables.waveFormLength = memoryVariables.trackLength;
			CallDeferred("DeferedSetParams");

		}

		public void DeferedSetParams()
		{
			nodeVariables.waveformContainer.Size = new Vector2(memoryVariables.waveFormLength, Utilities.Constants.WaveformHeight);
			nodeVariables.cursorSlider.MaxValue = memoryVariables.waveFormLength;
			nodeVariables.cursorSlider.CustomMinimumSize = new Vector2(memoryVariables.waveFormLength, 16);
		}


		public void RedrawMap()
		{
			foreach (Track track in memoryVariables.tracks)
			{
				track.SetUp(memoryVariables.barsCount, true);
			}
		}


        public void FileMenuItems() 
		{
			var popUp = nodeVariables.fileMenu.GetPopup();
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

		public void OnFileMenuButtonIndexPressed(long index)
		{
			if (index == 0)
			{
				ImportAudio();
			}
			else if(index == 6)
			{
				// Your code here
			}
		}

		public void ImportAudio()
		{
			nodeVariables.fileDialog.Visible = true;
			nodeVariables.fileDialog.CurrentFile = "";
			nodeVariables.fileDialog.PopupCentered();

			EmitSignal(nameof(PreviewUpdated));
		}
	}
}
