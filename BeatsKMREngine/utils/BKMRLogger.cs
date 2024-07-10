using Godot;
using System;

public partial class BKMRLogger : Node
{


    public static int GetLogLevel()
    {
        int logLevel = 2;
        return logLevel;
    }

    public static void Error(string text)
    {
        GD.PrintErr(text);
        GD.PushError(text);
    }

    public static void Info(string text)
    {
        if (GetLogLevel() > 0)
        {
            GD.Print(text);
        }
    }

    public static void Debug(string text)
    {
        if (GetLogLevel() > 1)
        {
            GD.Print(text);
        }
    }

    public static void LogTime(string logText, string logLevel = "INFO")
    {
        int timestamp = (int)BKMRUtils.GetTimestamp();

        if (logLevel.Equals("ERROR", StringComparison.OrdinalIgnoreCase))
        {
            Error(logText + ": " + timestamp);
        }
        else if (logLevel.Equals("INFO", StringComparison.OrdinalIgnoreCase))
        {
            Info(logText + ": " + timestamp);
        }
        else
        {
            Debug(logText + ": " + timestamp);
        }
    }


}
