using System.Collections.Generic;
using System.Text.Json;
using Godot;
using Godot.Collections;

namespace Utilities
{

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