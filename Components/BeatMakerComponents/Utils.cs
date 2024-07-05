

using System;
using System.Collections.Generic;
using System.Net.Http.Json;
using System.Text.Json;
using Godot;

namespace Utilities
{

    public partial class BeatMakerUtils

    {
	    public static Dictionary<string, Variant> ReadJSON(string filePath)
        {
            if (!FileAccess.FileExists(filePath))
            {
                GD.Print("File not found!", filePath);
                return new Dictionary<string, Variant>();

            }

            FileAccess file = FileAccess.Open(filePath, FileAccess.ModeFlags.Read);
            if (file == null)
            {
                GD.Print("File oepning error!", filePath);
                return new Dictionary<string, Variant>();
            }
            string content = file.GetAsText();
            var json = JsonSerializer.Deserialize<Dictionary<string, Variant>>(content);

            if (json == null)
            {   
                GD.Print("File JSON parse error!", filePath);
                return new Dictionary<string, Variant>();
            };

            return json;
        }

        public static void WriteJSONFile(string filePath, Dictionary<string, Variant> data)
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