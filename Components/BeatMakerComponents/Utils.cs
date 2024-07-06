using System.Collections.Generic;
using System.Text.Json;
using Godot;
using Godot.Collections;

namespace Utilities
{
    public partial class Constants
	{
		// Constants
		public const int WaveformHeight = 100;
		public const int WaveformWidth = 1280;

		public static readonly Color BackgroundColor = new Color("2E2A43");

		public const int TrackTempoDefault = 120;
		public const int TrackTempoMax = 900;

		public const int TrackDistance = 5;

		public const int CursorFocusOffset = 0;

		public const int CellsInQuarterCount = 4;
		public const int CellWidth = 14;
		public const int CellHeight = 28;
		public const int CellExportScale = 5;
		public const int QuartersCount = 4;

		public static readonly Color DefaultColor = new Color(71 / 255.0f, 187 / 255.0f, 255 / 255.0f, 1);
		public const int TracksDistance = 5;

		public const string Color = "ffffff00";
		public const string Extended = "extended";
		public const string Accent = "accent";

		// Variables
		public static int Height = CellHeight;
		public static int Width = CellWidth;

		public static List<string> MembersName = new List<string>();
		public static List<Color> ColorSelected = new List<Color>();

		// Add this for the lastFilePath variable
		public static string LastFilePath = "//";
	}

    public partial class BeatMakerUtils

    {
	    public static Dictionary ReadJSONFile(string filePath)
        {
            if (!FileAccess.FileExists(filePath))
            {
                GD.Print("File not found!", filePath);
                return new Dictionary();

            }

            FileAccess file = FileAccess.Open(filePath, FileAccess.ModeFlags.Read);
            if (file == null)
            {
                GD.Print("File oepning error!", filePath);
                return new Dictionary();
            }
            string content = file.GetAsText();
            var json = JsonSerializer.Deserialize<Dictionary>(content);

            if (json == null)
            {   
                GD.Print("File JSON parse error!", filePath);
                return new Dictionary();
            };

            return json;
        }

        public static void WriteJSONFile(string filePath, Dictionary data)
        {
            FileAccess file = FileAccess.Open(filePath, FileAccess.ModeFlags.Write);
            if (file == null)
            {
                GD.Print("File can't be opened to write", filePath);
                return;
            }

            string jsonString = JsonSerializer.Serialize(data);
            file.StoreLine(jsonString);
            file.Close();
        }
    }
}