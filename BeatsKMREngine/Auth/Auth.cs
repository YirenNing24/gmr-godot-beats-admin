using Godot;
using Godot.Collections;

namespace BeatsEngine
{
	public partial class Auth : Node
	{
        [Signal]
        public delegate void BKMRRegisterPlayerCompleteEventHandler(Dictionary<string, string> message);
        [Signal]
        public delegate void BKMRLoginCompleteEventHandler(Dictionary<string, string> message);
        [Signal]
        public delegate void BKMRLogoutCompleteEventHandler(Dictionary<string, string> message);
        [Signal]
        public delegate void BKMRSessionCheckCompleteEventHandler(Dictionary<string, string> message);
        [Signal]
        public delegate void BKMRTokenRenewCompleteEventHandler(Dictionary<string, string> tokens);

        private BKMREngine BKMREngine = new();

        public class Player
        {
            public string Username { get; set; }
            public string Access { get; set; }
            public string Password { get; set; }
            public string Email { get; set; }
        }

        // Server host URL
        private string host = BKMREngine.host;

        // HttpRequest instances and weakrefs for server communication
        public string accessToken = "";
        public string refreshToken = "";

        public string permission;
        private HttpRequest renewToken;
        private WeakRef wrRenewToken;

        private HttpRequest loginPlayer;
        private WeakRef wrLoginPlayer;

        private HttpRequest registerPlayer;
        private WeakRef wrRegisterPlayer;

        private HttpRequest validateSession;
        private WeakRef wrValidateSession;

        private HttpRequest versionCheck;
        private WeakRef wrVersionCheck = null;

        private int loginTimeout = 0;
        private Timer loginTimer;
        private Timer completeSessionCheckWaitTimer;

        /// <summary>
        /// Sends a login request for a player.
        /// </summary>
        /// <param name="username">The username of the player.</param>
        /// <param name="password">The password of the player.</param>
        public void LoginPlayer(string username, string password)
        {
            var preparedHTTPRequest = BKMREngine.PrepareHTTPRequest();
            loginPlayer = preparedHTTPRequest.Request;
            wrLoginPlayer = preparedHTTPRequest.WeakRef;

            loginPlayer.RequestCompleted += OnLoginPlayerRequestCompleted;

            var payload = new Dictionary
            {
                { "username", username },
                { "password", password }
            };
            BKMRLogger.Info("Calling BKMREngine to login a player");
            GD.Print(payload);

            // Obfuscate the password before logging and sending the request
            var payLoadForLogging = payload;
            var obfuscatedPassword = BKMRUtils.ObfuscateString((string)payload["password"]);
            payLoadForLogging["password"] = obfuscatedPassword;
            BKMRLogger.Debug("BKMREngine login player payload: " + payLoadForLogging.ToString());

            // Define the request URL for player login
            var requestUrl = host + "/admin/login";

            // Send the POST request to initiate player login
            BKMREngine.SendLoginRequest(preparedHTTPRequest, requestUrl, payload);
        }

        /// <summary>
        /// Callback function for handling the completion of the login request.
        /// </summary>
        /// <param name="result">The result of the request.</param>
        /// <param name="responseCode">The response code of the request.</param>
        /// <param name="headers">The headers of the response.</param>
        /// <param name="body">The body of the response.</param>
        private void OnLoginPlayerRequestCompleted(long result, long responseCode, string[] headers, byte[] body)
        {
            bool statusCheck = BKMRUtils.CheckHttpResponse((int)responseCode, headers, body);
            Variant jsonBody = Json.ParseString(body.GetStringFromUtf8());
            BKMREngine.FreeRequest(wrLoginPlayer, loginPlayer);

            if (statusCheck)
            {
                // Parse the JSON Body of the response
                if (jsonBody.GetType() == null)
                {
                    EmitSignal(nameof(BKMRLoginComplete), jsonBody);
                    return;
                }

                if ((Dictionary)jsonBody != null)
                {
                    var jsonDictionary = (Dictionary)jsonBody;
                    if (jsonDictionary.ContainsKey("accessToken"))
                    {
                        BKMRLogger.Debug("Remember me access: " + jsonDictionary["accessToken"].ToString());
                    }

                    if (jsonDictionary.ContainsKey("refreshToken"))
                    {
                        BKMRLogger.Debug("Remember me access: " + jsonDictionary["refreshToken"].ToString());
                    }
                    accessToken = (string)jsonDictionary["accessToken"];
                    refreshToken = (string)jsonDictionary["refreshToken"];
                    permission = (string)jsonDictionary["admin"];

                    BKMREngine.session = true;
                    EmitSignal(nameof(BKMRLoginComplete), jsonDictionary);

                    if (jsonDictionary.ContainsKey("error"))
                    {
                        // Emit login failure if no token is present
                        EmitSignal(nameof(BKMRLoginComplete), jsonDictionary);
                        BKMRLogger.Error("BKMREngine login player failure: " + jsonDictionary["error"].ToString());
                    }
                }

            }
            else
            {
                if (jsonBody.GetType() == null)
                {
                    jsonBody = Json.ParseString(body.GetStringFromUtf8());
                    EmitSignal(nameof(BKMRLoginComplete), jsonBody);
                }
                else
                {
                    EmitSignal(nameof(BKMRLoginComplete));
                    GD.Print("Unknown server error");
                }
            }
        }

        /// <summary>
        /// Sends a registration request for a player.
        /// </summary>
        /// <param name="player">The player object containing registration details.</param>
        public void RegisterPlayer(Player player)
        {
            var preparedHTTPRequest = BKMREngine.PrepareHTTPRequest();
            registerPlayer = preparedHTTPRequest.Request;
            wrRegisterPlayer = preparedHTTPRequest.WeakRef;

            registerPlayer.RequestCompleted += OnRegisterPlayerRequestCompleted;

            var payload = new Dictionary
            {
                { "username", player.Username },
                { "access", player.Access },
                { "password", player.Password },
                { "email", player.Email }
            };

            BKMRLogger.Info("Calling BKMREngine to register a player");
            BKMRLogger.Debug("Validate session payload: " + payload);

            // Define the request URL for player registration
            var requestUrl = host + "/admin/register";

            // Send the POST request to initiate player registration
            BKMREngine.SendPostRequest(preparedHTTPRequest, requestUrl, payload);
        }

        /// <summary>
        /// Callback function for handling the completion of the registration request.
        /// </summary>
        /// <param name="result">The result of the request.</param>
        /// <param name="responseCode">The response code of the request.</param>
        /// <param name="headers">The headers of the response.</param>
        /// <param name="body">The body of the response.</param>
        private void OnRegisterPlayerRequestCompleted(long result, long responseCode, string[] headers, byte[] body)
        {
            // Check the HTTP response status
            bool statusCheck = BKMRUtils.CheckHttpResponse((int)responseCode, headers, body);
            var jsonBody = Json.ParseString(body.GetStringFromUtf8());

            // If the status check fails, emit an empty signal and return early
            if (!statusCheck)
            {
                EmitSignal(nameof(BKMRRegisterPlayerComplete), new Dictionary());
                return;
            }

            // If the response body is null, emit an empty signal and return early
            if (jsonBody.GetType() == null)
            {
                EmitSignal(nameof(BKMRRegisterPlayerComplete), new Dictionary());
                return;
            }

            // Cast the response body to a dictionary
            var jsonDictionary = (Dictionary)jsonBody;

            // If there's an error in the response, log it and return early
            if (jsonDictionary.ContainsKey("error"))
            {
                BKMRLogger.Error("BKMREngine register user failure: " + jsonDictionary["error"]);
                return;
            }

            // Emit the signal with the parsed JSON dictionary
            EmitSignal(nameof(BKMRRegisterPlayerComplete), jsonDictionary);
        }
        
        /// <summary>
        /// Logs out the player by clearing the refresh token and access token, 
        /// emitting a logout complete signal, and then quitting the game.
        /// </summary>
        /// <remarks>
        /// This method performs the following actions:
        /// - Clears the `refreshToken` and `accessToken` fields to ensure the player is logged out.
        /// - Emits the `BKMRLogoutComplete` signal to notify other parts of the application that the player has logged out.
        /// - Calls `GetTree().Quit()` to terminate the game/application.
        /// </remarks>
        public void LogoutPlayer()
        {
            refreshToken = "";
            accessToken = "";
            EmitSignal(nameof(BKMRLogoutComplete));
            GetTree().Quit();
        }

        /// <summary>
		/// Sends a request to renew the access token.
		/// </summary>
        /// 
        private void RequestNewAccessToken()
        {
            var preparedHTTPRequest = BKMREngine.PrepareHTTPRequest();
			renewToken = preparedHTTPRequest.Request;
			wrRenewToken = preparedHTTPRequest.WeakRef;

			renewToken.RequestCompleted += OnRequestNewAccessTokenCompleted;

			// Log the initiation of player session validation
			BKMRLogger.Info("Calling BKMREngine to validate an existing player session");

			// Create the payload with lookup and access tokens
			var payload = new Dictionary();

			// Log the payload details
			BKMRLogger.Debug("Validate session payload: " + payload.ToString());

			var requestUrl = host + "/admin/renew/access";

			// Send the POST request for session validation
			BKMREngine.SendLoginRequest(preparedHTTPRequest, requestUrl, payload);
        }

        private void OnRequestNewAccessTokenCompleted(long result, long responseCode, string[] headers, byte[] body)
        {
            bool statusCheck = BKMRUtils.CheckHttpResponse((int)responseCode, headers, body);
            var jsonBody = Json.ParseString(body.GetStringFromUtf8());
            BKMREngine.FreeRequest(wrRenewToken, renewToken);

            if (statusCheck)
            {
                var jsonDictionary = (Dictionary)jsonBody;
                if(jsonBody.GetType() == null)
                // Cast the response body to a dictionary
                {
                    EmitSignal(nameof(BKMRTokenRenewComplete), new Dictionary());
                } 

                else if (jsonDictionary.ContainsKey("error"))
                {
                    BKMRLogger.Error("BKMREngine renew token failure: " + jsonDictionary["error"]);
                    return;
                }
                if (jsonDictionary.ContainsKey("refreshToken"))
                {
                    BKMRLogger.Debug("Remember me access: " + jsonDictionary["accessToken"]);

                    refreshToken = (string)jsonDictionary["refreshToken"];
                    accessToken = (string)jsonDictionary["accessToken"];
                    EmitSignal(nameof(BKMRTokenRenewComplete), jsonBody);
                }
            }
            else
            {
                // Trigger the completion of the session check with an empty result in case of failure
                EmitSignal(nameof(BKMRTokenRenewComplete), new Dictionary());
            }



  
        }

        private void RenewAccessTokenTimer()
        {
            SceneTreeTimer timer = GetTree().CreateTimer(240.0);
            timer.Timeout += RenewAccessTokenTimer;
            timer.Timeout += RequestNewAccessToken;
        }
    
        
    }


// func logout_player() -> void:
// 	# Clear the logged-in player information
// 	logged_in_player = ""
// 	# Remove stored session if any and log the deletion success
// 	refresh_token = ""
// 	access_token = ""
// 	# Emit signal indicating completion of player logout
// 	bkmr_logout_complete.emit()
// 	get_tree().quit()

}
