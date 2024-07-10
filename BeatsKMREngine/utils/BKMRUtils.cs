using Godot;
using System;

public partial class BKMRUtils : Node
{
 
    public static float GetTimestamp()
    {
        float unixTime = DateTimeOffset.UtcNow.ToUnixTimeSeconds();
        int unixTimeInt = (int)unixTime;
        float timestamp = (unixTime - unixTimeInt) * 1000.0f;
        return (float)Math.Round(timestamp);
    }

    public static bool CheckHttpResponse(int responseCode, Array headers, byte[] body)
    {
        BKMRLogger.Debug("response code: " + responseCode);
        BKMRLogger.Debug("response headers: " + headers);

        bool checkOk = true;
        if (responseCode == 0)
        {
            NoConnectionError();
            checkOk = false;
        }
        else if (responseCode == 403 || responseCode == 401 || responseCode == 422 || responseCode == 500)
        {
            ForbiddenError();
            checkOk = false;
        }
        return checkOk;
    }

    private static void NoConnectionError()
    {
        BKMRLogger.Error("Beats couldn't connect to the server. There are several reasons why this might happen. See https://www.kmetarave.com/troubleshooting for more details. If the problem persists you can reach out to us: https://www.kmetarave.com/contact");
    }

    private static void ForbiddenError()
    {
        BKMRLogger.Error("You are not authorized to call the BKMREngine - check your device, game version or account or contact us at https://www.kmetarave.com/contact");
    }

    private static void ValidationError()
    {
        BKMRLogger.Error("Your credentials entered or used are invalid");
    }

    public static string ObfuscateString(string str)
    {
        return str.Replace(".", "*");
    }
}
