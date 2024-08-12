using System.Linq;
using Godot;
using Godot.Collections;

namespace BeatsEngine
{
    /// <summary>
    /// Partial class representing the main engine functionality.
    /// </summary>
    public partial class BKMREngine : Node
    {
        public bool session = false;
        // Create an instance of Auth as a property
        public AuthMiddle Auth = new();
        public Contracts Contracts;

        // Constant representing the plugin version
        private const string version = "0.1";

        // Gets the Godot engine version
        public string godotVersion = Engine.GetVersionInfo().ToString();

        // Static fields for server connection
        public static string port = ":8086";
        public static string host = "http://" + "localhost" + port;



        // public override void _Ready()
        // {
        //     Auth = new();
        //     Contracts = new();
        // }

        /// <summary>
        /// Partial class representing an extended HttpRequest with WeakRef.
        /// </summary>
        public partial class HttpRequestInfo : HttpRequest
        {
            public new HttpRequest Request { get; set; }
            public new WeakRef WeakRef { get; set; }
        }

        /// <summary>
        /// Prepares an HttpRequest and WeakRef, sets up threading, and adds the HttpRequest to the scene tree.
        /// </summary>
        /// <returns>A HttpRequestInfo object containing the HttpRequest and its WeakRef.</returns>
        public HttpRequestInfo PrepareHTTPRequest()
        {
            HttpRequest request = new();
            WeakRef weakRef = new();

            if (OS.GetName() != "Web")
            {
                request.UseThreads = true;
            }

            request.ProcessMode = ProcessModeEnum.Always;
            GetTree().Root.CallDeferred("AddChild", request);

            return new HttpRequestInfo
            {
                Request = request,
                WeakRef = weakRef
            };
        }

        /// <summary>
        /// Sends a login request asynchronously.
        /// </summary>
        /// <param name="httpNode">The HttpRequestInfo instance to use for the request.</param>
        /// <param name="requestUrl">The URL to send the request to.</param>
        /// <param name="payload">The payload to send with the request.</param>
        public async void SendLoginRequest(HttpRequest httpNode, string requestUrl, Dictionary payload)
        {
            string[] headers =
            {
                "content-Type: application/json",
                "x-bkmr-plugin-version: " + version,
                "x-bkmr-godot-version: " + godotVersion
            };
            headers = AddJWTRefreshTokenHeaders(headers);

            if (!httpNode.IsInsideTree())
            {
                await ToSignal(GetTree().CreateTimer(0.05), "timeout");
            }

            string query = Json.Stringify(payload);
            BKMRLogger.Debug("Method: POST");
            BKMRLogger.Debug("request_url: " + requestUrl.ToString());
            BKMRLogger.Debug("headers: " + headers.ToString());
            BKMRLogger.Debug("query: " + query.ToString());
            _ = httpNode.Request(requestUrl, headers, HttpClient.Method.Post, query);
        }

        public async void SendPostRequest(HttpRequest httpNode, string requestUrl, Dictionary payload)
        {
            string[] headers =
            {
                "content-Type: application/json",
                "x-bkmr-plugin-version: " + version,
                "x-bkmr-godot-version: " + godotVersion
            };
            headers = AddAccessTokenHeaders(headers);

            if (!httpNode.IsInsideTree())
            {
                await ToSignal(GetTree().CreateTimer(0.05), "timeout");
            }

            string query = Json.Stringify(payload);
            BKMRLogger.Debug("Method: POST");
            BKMRLogger.Debug("request_url: " + requestUrl.ToString());
            BKMRLogger.Debug("headers: " + headers.ToString());
            BKMRLogger.Debug("query: " + query.ToString());
            _ = httpNode.Request(requestUrl, headers, HttpClient.Method.Post, query);
        }

        public async void SendGetRequest(HttpRequest httpNode, string requestUrl)
        {
            string[] headers =
            {
                "content-Type: application/json",
                "x-bkmr-plugin-version: " + version,
                "x-bkmr-godot-version: " + godotVersion
            };
            headers = AddJWTRefreshTokenHeaders(headers);
            if (!httpNode.IsInsideTree())
            {
                await ToSignal(GetTree().CreateTimer(0.05), "timeout");
            }

            BKMRLogger.Debug("Method: POST");
            BKMRLogger.Debug("request_url: " + requestUrl.ToString());
            BKMRLogger.Debug("headers: " + headers.ToString());
            _ = httpNode.Request(requestUrl, headers, HttpClient.Method.Get);
        }

        public void FreeRequest(WeakRef weakRef, HttpRequest httpRequest)
        {
            if (weakRef.GetRef().GetType() != null)
            {
                httpRequest.QueueFree();
            }

        }

        /// <summary>
        /// Adds JWT refresh token headers to the existing headers array if a refresh token is present.
        /// </summary>
        /// <param name="headers">The current headers array.</param>
        /// <returns>The updated headers array.</returns>
        private string[] AddJWTRefreshTokenHeaders(string[] headers)
        {
            if (Auth.refreshToken != "")
            {
                _ = headers.Append("Authorization: Bearer " + Auth.refreshToken);
                return headers;
            }
            return headers;
        }

        private string[] AddAccessTokenHeaders(string[] headers)
        {
            if (Auth.accessToken != "")
            {
                _ = headers.Append("Authorization: Bearer " + Auth.accessToken);
                return headers;
            }
            return headers;
        }


    }



}
