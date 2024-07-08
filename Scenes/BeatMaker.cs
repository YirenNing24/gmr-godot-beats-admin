using System;
using System.Linq;
using Godot;
using Godot.Collections;
using Array = Godot.Collections.Array;

namespace Main
{
	public partial class BeatMaker : Control
	{
		[Signal]
		public delegate void PreviewUpdatedEventHandler();
		public PackedScene trackScene = GD.Load<PackedScene>("res://Components/BeatMakerComponents/track.tscn");

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
			public int mapStartPos;
			public int trackLength;
			public int trackSpeed;
			public float trackTempo = 130;
			public bool mapInfoWasSaved;
			public bool pendingExport;
			public int waveFormLength;
			public int waveFormScale;
			public float tempoUpdateTimeOut = 0;
			public bool tempoUpdateInProcess = false;
			public float uiScale;
			public float scaleRatio = 1;
			public int previousScaleRatio;
			public float barSize;
			public int barsCount;
			public float quarterTimeInSeconds;
			public float sampleDurationInSeconds;
			public int windowScrollSize = 0;
			public bool pendingWScrollUpdate = false;
			public bool cursorSliderPressed = false;
			public int windowScrollLastVal = 0;
			public int windowScrollAndCursorD = 0;
			public int windowsScrollLastPos = 0;
			public Array<Track> tracks = new();
			public bool isConnecting = false;
			public bool audioLoaded = false;
		}

		public MemoryVariables memoryVariables = new();

		// Grouping node variables
		public partial class NodeVariables
		{
			public MenuButton fileMenu;
			public ScrollContainer windowScroll;
			public VBoxContainer tracksContainer;
			public AudioStreamPlayer audioStreamPlayer;
			public BpmInput bpmInput;
			public StartInput startInput;
			public Control waveformContainer;
			public TextureRect waveFormNode;
			public Control cursorContainer;	
			public Slider cursorSlider;
			public CursorStatic cursorStatic;
			public CursorPlayback cursorPlayback;
			public FileDialog importMap;
			public FileDialog songfileDialog;
			public SaveMapDialog saveMapDialog;
			public Button playButton;
			public Note activeNote;
			public Track activeTrack;
			public VBoxContainer editorContainer;
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

		public void BuildEditor()
		{
			memoryVariables.loadPercent += 100;
			FileMenuItems();
			SetProcess(true);
			SetProcessInput(true);
			memoryVariables.windowScrollSize = (int)nodeVariables.windowScroll.GetMinimumSize().X;
			UpdateControls();
			UpdateLastFilePath(Utilities.Constants.LastFilePath);
			SetupEditorDirectory();
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
			Window window = GetWindow();
			nodeVariables.tracksContainer.CustomMinimumSize = new Vector2(window.Size.X, 260);
			nodeVariables.cursorContainer.Position = new Vector2(nodeVariables.cursorContainer.Position.X, (float)nodeVariables.windowScroll.GetVScrollBar().Value);
			if (memoryVariables.tempoUpdateTimeOut > 0)
			{
				memoryVariables.tempoUpdateTimeOut -= (float)delta;
			}

			else if (memoryVariables.tempoUpdateTimeOut < 0)
			{
				memoryVariables.tempoUpdateTimeOut = 0;
				memoryVariables.tempoUpdateInProcess = true;
				int oldWaveFormLength = memoryVariables.waveFormLength;
				int cursorValue = (int)nodeVariables.cursorSlider.Value;
				int scrollValue = nodeVariables.windowScroll.ScrollHorizontal;
				int dd = scrollValue - cursorValue;
				SetParams();
				RedrawMap();
				int editorScale = memoryVariables.waveFormLength / oldWaveFormLength;
				nodeVariables.cursorSlider.Value *= editorScale;
				nodeVariables.windowScroll.ScrollHorizontal = (int)(nodeVariables.cursorSlider.Value + dd);
				nodeVariables.cursorStatic.Position = new Vector2((float)nodeVariables.cursorSlider.Value, nodeVariables.cursorStatic.Position.Y);
				memoryVariables.tempoUpdateInProcess = false;
            }
			memoryVariables.windowScrollLastVal = nodeVariables.windowScroll.ScrollHorizontal;
			if (memoryVariables.isPlaying)
			{
				nodeVariables.cursorPlayback.Position = new Vector2(memoryVariables.trackSpeed * nodeVariables.audioStreamPlayer.GetPlaybackPosition()
				* memoryVariables.scaleRatio, 0);
			}
			else
			{
				nodeVariables.cursorPlayback.Position = nodeVariables.cursorStatic.Position;
			}
			if (memoryVariables.isPlaying && memoryVariables.isFollowPlaying)
			{
				if (nodeVariables.cursorPlayback.Position.X >= nodeVariables.windowScroll.Size.X * 0.5)
				{
					nodeVariables.windowScroll.ScrollHorizontal = (int)(nodeVariables.cursorPlayback.Position.X - nodeVariables.windowScroll.Size.X * 0.5);
				}
			}

		}

		public void LoadNodes()
		{
			nodeVariables.fileMenu = GetNode<MenuButton>("EditorContainer/Panel/HBoxContainer/FileMenu");
			nodeVariables.windowScroll = GetNode<ScrollContainer>("EditorContainer/HBoxContainer2/Panel/VBoxContainer/WindowScroll");
			nodeVariables.tracksContainer = GetNode<VBoxContainer>("EditorContainer/HBoxContainer2/Panel/VBoxContainer/WindowScroll/VBoxContainer/TracksContainer");
			nodeVariables.audioStreamPlayer = GetNode<AudioStreamPlayer>("AudioStreamPlayer");
			nodeVariables.bpmInput = GetNode<BpmInput>("EditorContainer/HBoxContainer2/Panel/VBoxContainer/Panel/HBoxContainer/BPMInput");
			nodeVariables.startInput = GetNode<StartInput>("EditorContainer/HBoxContainer2/Panel/VBoxContainer/Panel/HBoxContainer/StartInput");
			nodeVariables.waveformContainer = GetNode<Control>("EditorContainer/HBoxContainer2/Panel/VBoxContainer/WindowScroll/VBoxContainer/WaveFormContainer");
			nodeVariables.waveFormNode = GetNode<TextureRect>("EditorContainer/HBoxContainer2/Panel/VBoxContainer/WindowScroll/VBoxContainer/WaveFormContainer/WaveFormNode");
			nodeVariables.cursorContainer = GetNode<Control>("EditorContainer/HBoxContainer2/Panel/VBoxContainer/WindowScroll/VBoxContainer/WaveFormContainer/CursorContainer");
			nodeVariables.cursorSlider = GetNode<HSlider>("EditorContainer/HBoxContainer2/Panel/VBoxContainer/WindowScroll/VBoxContainer/WaveFormContainer/CursorContainer/CursorSlider");
			nodeVariables.cursorStatic = GetNode<CursorStatic>("EditorContainer/HBoxContainer2/Panel/VBoxContainer/WindowScroll/VBoxContainer/WaveFormContainer/CursorContainer/CursorStatic");
			nodeVariables.cursorPlayback = GetNode<CursorPlayback>("EditorContainer/HBoxContainer2/Panel/VBoxContainer/WindowScroll/VBoxContainer/WaveFormContainer/CursorContainer/CursorPlayback");
			nodeVariables.importMap = GetNode<FileDialog>("ImportMap");
			nodeVariables.songfileDialog = GetNode<FileDialog>("FileDialog");
			nodeVariables.saveMapDialog = GetNode<SaveMapDialog>("SaveMapDialog");
			nodeVariables.playButton = GetNode<Button>("EditorContainer/HBoxContainer2/Panel/VBoxContainer/Panel/HBoxContainer/PlayButton");
			nodeVariables.editorContainer = GetNode<VBoxContainer>("EditorContainer");

			memoryVariables.audioLoadThread = new GodotThread();
			ConnectSignals();
		}

		private void ConnectSignals()
		{	
			nodeVariables.playButton.Pressed += OnPlayButtonPressed;
			nodeVariables.songfileDialog.FileSelected += OnSongFileDialogSelected;
		}

        private void OnPlayButtonPressed()
        {
            Play();
        }

        private void Play()
        {
            if (memoryVariables.isPlaying)
			{
				memoryVariables.isPlaying = false;
				nodeVariables.audioStreamPlayer.Stop();
			}
			else
			{
				UnsetActiveNote();
				UnsetActiveTrack();
				float audioTrack = (float)(nodeVariables.cursorSlider.Value / memoryVariables.trackSpeed);
				audioTrack /= memoryVariables.scaleRatio;
				nodeVariables.audioStreamPlayer.Play(audioTrack);
				GD.Print("Play");
			}
        }

        private void OnSongFileDialogSelected(string path)
        {

			Callable loadSong = Callable.From(() => LoadSongs(path));
            memoryVariables.audioLoadThread.Start(loadSong);
        }

        public void LoadSongs(string path)
         {
		 	GD.Print("Loading started ", path);
			EnableLoadSong(false);
			UpdateLoadAudio(Tr("Loading..."));
			bool isCopied = CopySong(path);
			if (isCopied)
			{
				memoryVariables.audioLoadThread.WaitToFinish();	
				EnableLoadSong(true);
			}
			if (!CheckAudio())
			{
				GD.Print("Audio file not valid or copied.");
				EnableLoadSong(true);
				memoryVariables.audioLoadThread.WaitToFinish();
				return;
			}

			UpdateLoadAudio(Tr("Loading..."));
			memoryVariables.stream = LoadOGG(memoryVariables.oggFilePath);
			GD.Print("FILE:", memoryVariables.oggFilePath, memoryVariables.stream);
			if (!IsSongLoaded(memoryVariables.stream))
			{
				return;
			}
			CallDeferred("SetAudioPlayerStream", memoryVariables.stream);
			UpdateLoadAudio(Tr("Loading..."));
			// LoadWaveform();
			SetParams();
			memoryVariables.audioLoaded = true;
			UpdateControls();
			UpdateLastFilePath(path);
			UpdateLoadAudio(Tr("Audio Loaded"));
		 }

        private void SetAudioPlayerStream(AudioStreamOggVorbis stream)
        {
			nodeVariables.audioStreamPlayer.Stream = stream;
        }

        private bool IsSongLoaded(AudioStreamOggVorbis stream)
        {
			if (stream == null)
			{
				memoryVariables.audioLoadThread.WaitToFinish();
				return false;
			}
			else
			{
				return true;
			}
        }

        private static AudioStreamOggVorbis LoadOGG(string oggFilePath)
        {
			AudioStreamOggVorbis OGGFile = AudioStreamOggVorbis.LoadFromFile(oggFilePath);
			return OGGFile;
        }

        public bool CheckAudio()
		{
			bool checker = FileAccess.FileExists(memoryVariables.oggFilePath);
			if (!checker)
			{
				GD.Print("File not found");
				return false;
			}
			return true;
		}

        private void UpdateLoadAudio(string text)
        {

        }

		public void SetupEditorDirectory()
		{
			GD.Print("user data dir:", OS.GetUserDataDir());
			memoryVariables.editorDir = "user://editor";
			if (DirAccess.Open(memoryVariables.editorDir) == null)
			{	
				_ = DirAccess.MakeDirAbsolute(memoryVariables.editorDir);
			}
			GD.Print("editor_dir:", memoryVariables.editorDir);
		}

		public void UpdateControls()
		{
			if (memoryVariables.audioLoaded)
			{	
				GD.Print("Loaded na ba???");
				CallDeferred("AddTrack");

			}
			else
			{

			}
		}

		public void SetParams()
		{
			memoryVariables.sampleDurationInSeconds = (float)memoryVariables.stream.GetLength();
			memoryVariables.quarterTimeInSeconds = (60 / memoryVariables.trackTempo);
			int cellWidth = Utilities.Constants.CellWidth;
			int quartersCount = Utilities.Constants.QuartersCount;
			int cellsInQuarterCount = Utilities.Constants.CellsInQuarterCount;
			memoryVariables.barSize = cellWidth * quartersCount * cellsInQuarterCount;

			memoryVariables.trackSpeed = (int)(memoryVariables.barSize / (memoryVariables.quarterTimeInSeconds * quartersCount));
			memoryVariables.trackLength = (int)(memoryVariables.trackSpeed * memoryVariables.sampleDurationInSeconds);
			memoryVariables.barsCount = (int)MathF.Round(memoryVariables.trackLength / memoryVariables.barSize);

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
			nodeVariables.songfileDialog.Visible = true;
			nodeVariables.songfileDialog.CurrentFile = "";
			nodeVariables.songfileDialog.PopupCentered();

			EmitSignal(nameof(PreviewUpdated));
		}

		public void SetActiveNote(Note note)
		{
			nodeVariables.activeNote?.SetActive(false);
			nodeVariables.activeNote = note;
			nodeVariables.activeNote.SetActive(true);
			Track noteBarTrack = note.bar.track;
			SetActiveTrack(noteBarTrack);
		}

		public void UnsetActiveNote()
		{
			if (nodeVariables.activeNote != null)
			{
				nodeVariables.activeNote.SetActive(false);
				nodeVariables.activeNote = null;
			}
			
		}

		public void UnsetActiveTrack()
		{
			nodeVariables.activeTrack?.SetActive(false);
			nodeVariables.activeTrack = null;
		}

		public void ReDrawMap()
		{
			foreach(Track track in memoryVariables.tracks)
			{
				track.SetUp(memoryVariables.barsCount, true);
			}
		}

		public bool CopySong(string inputFilePath)
		{
			GD.Print("Copy started ", inputFilePath);
			string fileName = inputFilePath.GetFile();
			string fileFormat = fileName.GetExtension().ToLower();

			memoryVariables.oggFilePath = memoryVariables.editorDir + "/" + "audio" + ".ogg" ;
			if (fileFormat == "ogg"){
				DirAccess dir = DirAccess.Open(memoryVariables.editorDir);
				if (dir != null)
				{
                    Error error = dir.Copy(inputFilePath, memoryVariables.oggFilePath);
					GD.Print(error);
                }
			}
			else
			{	
				return false;
			}
			GD.Print("Copy finished");
			return true;
		}

		public void ExportData()
		{
			string songsDir = "Songs";
			string songFolder;
			string newDir;
			DirAccess dir = DirAccess.Open(songsDir);
			GD.Print("current dir: ", dir.GetCurrentDir());
			GD.Print("OPEN RETURN CODE: " + dir);

			int randInt;
			GD.Randomize();
			randInt = (int)GD.Randi();
			songFolder = randInt.ToString() + " " + nodeVariables.saveMapDialog.audioInfo["artist"] + "-" + nodeVariables.saveMapDialog.audioInfo["title"];
			GD.Print(songFolder);
			Error dirMakeError = dir.MakeDir(songFolder);
			if (dirMakeError != Error.Ok)
			{
				GD.Print("Failed to create directory: " + dirMakeError);
				return;
			}

			newDir = songsDir + "/" + songFolder;
			DirAccess dirNew = DirAccess.Open(newDir);

			
			Array tracksData = new();
			foreach (Track track in memoryVariables.tracks)
			{
				tracksData.Add(track.GetData());
			}

			Dictionary data = new()
			{
				{ "audio", nodeVariables.saveMapDialog.audioInfo },
				{ "beatmap_maker", nodeVariables.saveMapDialog.beatMapMaker },
				{ "audio_file", nodeVariables.saveMapDialog.audioInfo["artist"] + "-" + nodeVariables.saveMapDialog.audioInfo["title"] + ".ogg" },
				{ "date", GetCurrDate() },
				{ "tempo", memoryVariables.trackTempo },
				{ "song_folder", newDir },
				{ "start_pos", memoryVariables.mapStartPos * Utilities.Constants.CellExportScale},
				{ "tracks", tracksData }
			};

			newDir += "/" + "map-" + nodeVariables.saveMapDialog.audioInfo["artist"] + "-" + nodeVariables.saveMapDialog.audioInfo["title"] + ".json";
			
			Utilities.BeatMakerUtils.WriteJSONFile(newDir, data);
            UpdateLastFilePath(newDir);
			newDir = songsDir + "/" + songFolder;
			newDir += "/" + nodeVariables.saveMapDialog.audioInfo["artist"] + "-" + nodeVariables.saveMapDialog.audioInfo["title"] + ".ogg";

			string fileName = "editor_dir/audio.ogg";
			string fileFormat = fileName.GetExtension().ToLower();

			string oggFilePath = memoryVariables.editorDir + "/" + "audio" + ".ogg";

			if (fileFormat == "ogg")
			{
				Error copyError = dirNew.Copy(oggFilePath, newDir);
				if (copyError != Error.Ok)
				{
					GD.Print("Failed to copy audio file: " + copyError);
					return;
				}
			}
			else
			{
				return;
			}
		}

		public static void EnableLoadSong(bool isEnabled)
		{
			if (isEnabled)
			{

			}

			else 
			{

			}
		}

    	public void ImportData(string path)
		{
			Dictionary data = Utilities.BeatMakerUtils.ReadJSONFile(path);
			if (data == null)
			{
				return;
			}

			string dataTempo = (string)data["tempo"];
			int trackTempo = Convert.ToInt32(dataTempo);
			nodeVariables.bpmInput.SetTempo(memoryVariables.trackTempo);
	
			string dataStartPosition = (string)data["start_pos"];
			float mapStartPosition = Convert.ToInt32(dataStartPosition) / Utilities.Constants.CellExportScale;
			nodeVariables.startInput.Value = mapStartPosition;

			nodeVariables.saveMapDialog.SetData((string)data["creator"], (Dictionary)data["audio"]);

			memoryVariables.mapInfoWasSaved = false;
			memoryVariables.pendingExport = false;
			ClearTracks();
			SetParams();
			ScaleTo(0);

			int y = Utilities.Constants.CellHeight + Utilities.Constants.TrackDistance;
			foreach (Dictionary trackData in ((Array)data["tracks"]).Select(v => (Dictionary)v))
			{
				Track track = (Track)trackScene.Instantiate();
				track.SetData(trackData);
				track.SetPosition(new Vector2(0, y));
				track.SetStartPosition((int)mapStartPosition);
				nodeVariables.tracksContainer.AddChild(track);
				memoryVariables.tracks.Add(track);
				y += track.GetHeight();
			}

			UpdateCursorLength();
			UpdateLastFilePath(path);

			GD.Print("Data imported");
			GD.Print("New track data:", memoryVariables.tracks);
		}
		
		public void UpdateCursorLength()
		{
			int offset = 0;
			foreach(Track track in memoryVariables.tracks)
			{
				offset += (int)track.CustomMinimumSize.Y;
			}
			nodeVariables.cursorStatic.SetLengthOffset(offset);
			nodeVariables.cursorPlayback.SetLengthOffset(offset);
		}

		public void AddTrack()
		{
			for (int i = 0; i < 5; i++)
			{

				Track track = (Track)trackScene.Instantiate();
				track.SetInfo();
				track.SetUp(memoryVariables.barsCount);
				track.trackIndex = i;

				track.SetStartPosition(memoryVariables.mapStartPos);
				nodeVariables.tracksContainer.AddChild(track);
				track.Position = new Vector2(0, (memoryVariables.tracks.Count + 1) * (Utilities.Constants.CellHeight + Utilities.Constants.TrackDistance));
                _ = memoryVariables.tracks.Append(track);
				SetActiveTrack(track);
				UpdateCursorLength();
				ScaleTo(0);
			}
		}

		public void SetActiveTrack(Track track)
		{
			nodeVariables.activeTrack?.SetActive(false);
			nodeVariables.activeTrack = track;
			nodeVariables.activeTrack.SetActive(true);
		}

		public void ClearTracks()
			{
				int trackSize = memoryVariables.tracks.Count();
				for (int i = 0; i < trackSize; i++)
				{
					Track track = memoryVariables.tracks[i];
					GD.Print("Track " + i + " removed");
					GD.Print("Track " + track + " removed");

					DestroyTrack(track);
				}
			}

		public void DestroyTrack(Track track)
		{
			if (nodeVariables.activeTrack == track)
			{
				nodeVariables.activeTrack = null;
			}
			nodeVariables.tracksContainer.RemoveChild(track);
			memoryVariables.tracks.Remove(track);
			UpdateCursorLength();
			
		}

		public void ScaleTo(float dir)
		{
			if (memoryVariables.pendingWScrollUpdate)
			{
				return;
			}

			float value = dir * memoryVariables.waveFormScale;
			memoryVariables.uiScale = value;
			float currentScale = memoryVariables.waveFormScale * memoryVariables.uiScale;
			memoryVariables.scaleRatio = currentScale / memoryVariables.waveFormScale;
			if (memoryVariables.scaleRatio <= 0 || memoryVariables.scaleRatio == 0)
			{
				memoryVariables.scaleRatio = (float)0.1;
				memoryVariables.uiScale -= value;
				return;
			}
			CallDeferred("DeferredScaleTo");
		}

		public void DeferredScaleTo()
		{
			float scaleD = memoryVariables.scaleRatio / memoryVariables.previousScaleRatio;
			float cursorValue = (float)nodeVariables.cursorSlider.Value;
			float scrollValue = (float)nodeVariables.windowScroll.GetHScrollBar().Value;
			float d = cursorValue - scrollValue;
			nodeVariables.cursorSlider.MaxValue = memoryVariables.waveFormLength * memoryVariables.scaleRatio;
			nodeVariables.cursorSlider.CustomMinimumSize = new Vector2(memoryVariables.waveFormLength * memoryVariables.scaleRatio, 100);
			nodeVariables.cursorSlider.Value = cursorValue * scaleD;
			Vector2 scaledSize = new(memoryVariables.waveFormLength * 1, Utilities.Constants.WaveformHeight);
			nodeVariables.waveformContainer.CustomMinimumSize = scaledSize;
			nodeVariables.waveformContainer.Size = scaledSize;
			nodeVariables.cursorPlayback.speedScale = (int)memoryVariables.scaleRatio;
			memoryVariables.windowScrollSize = (int)(nodeVariables.cursorSlider.Value - d);
			memoryVariables.pendingWScrollUpdate = true;

			foreach(Track track in memoryVariables.tracks)
			{
				track.UpdateScale(memoryVariables.scaleRatio);
			}
			memoryVariables.previousScaleRatio = (int)memoryVariables.scaleRatio;
		}

        public static string GetCurrDate()
		{
			return DateTime.Now.ToString("yyyy-MM-dd");
		}	

		public static void UpdateLastFilePath(string filePath)
		{
			Utilities.Constants.LastFilePath = filePath;
		}
	}
}
