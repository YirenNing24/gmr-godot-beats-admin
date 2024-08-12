using Godot;
using Godot.Collections;
using Array = Godot.Collections.Array;


namespace BeatsEngine
{
    public partial class Contracts : Node
    {   
        private BKMREngine BKMREngine = new();

        [Signal]
        public delegate void GetContractsCompleteEventHandler(Array<Dictionary<string, string>> contract);

        [Signal]
        public delegate void ContractUpdateCompleteEventHandler(Dictionary<string, string> data);

        readonly string host = BKMREngine.host;
        public Array Contract ;
        private HttpRequest getContracts;
        private WeakRef wrGetContracts;

        private HttpRequest updateContracts;
        private WeakRef wrUpdateContracts;

        public void UpdateContracts(Dictionary contracts)
        {
            var preparedHTTPRequest = BKMREngine.PrepareHTTPRequest();
            updateContracts = preparedHTTPRequest.Request;
            wrUpdateContracts = preparedHTTPRequest.WeakRef;

            updateContracts.RequestCompleted += OnUpdateContractsRequestCompleted;

            // # Set the payload and request URL for updating stat points.
            Dictionary payload = contracts;
            // var payload: Dictionary = contract_list
            string requestUrl = host + "/admin/update-contracts";
            BKMREngine.SendPostRequest(preparedHTTPRequest, requestUrl, payload);
        }

        private void OnUpdateContractsRequestCompleted(long result, long responseCode, string[] headers, byte[] body)
        {
            bool statusCheck = BKMRUtils.CheckHttpResponse((int)responseCode, headers, body);
            if (IsInstanceValid(updateContracts))
            {
                BKMREngine.FreeRequest(wrUpdateContracts, updateContracts);
            }

            var jsonBody = Json.ParseString(body.GetStringFromUtf8());
            if (statusCheck)
            {
                if ((Dictionary)jsonBody != null)
                {
                    var jsonDictionary = (Dictionary)jsonBody;
                    if (jsonDictionary.ContainsKey("success"))
                    {
                        BKMRLogger.Info(jsonDictionary["success"]);
                        EmitSignal(nameof(ContractUpdateComplete), jsonDictionary);
                    }
                    else
                    {
                        EmitSignal(nameof(ContractUpdateComplete), jsonDictionary);
                    }
                }
                else
                {
                    EmitSignal(nameof(ContractUpdateComplete), "Unknown Server Error");
                }
            }
            else
                {
                    EmitSignal(nameof(ContractUpdateComplete), "Unknown Server Error");
                }

        }

        public void GetContracts()
        {
            var preparedHTTPRequest = BKMREngine.PrepareHTTPRequest();
            getContracts = preparedHTTPRequest.Request;
            wrGetContracts = preparedHTTPRequest.WeakRef;

            getContracts.RequestCompleted += OnGetContractsRequestCompleted;
            BKMRLogger.Info("Calling BKMREngine to get contracts");

            string requestUrl = host + "/admin/contracts";
            BKMREngine.SendGetRequest(getContracts, requestUrl);
        }

        private void OnGetContractsRequestCompleted(long result, long responseCode, string[] headers, byte[] body)
        {
            bool statusCheck = BKMRUtils.CheckHttpResponse((int)responseCode, headers, body);
            if (IsInstanceValid(getContracts))
            {
                BKMREngine.FreeRequest(wrGetContracts, getContracts);
            }

            var jsonBody = Json.ParseString(body.GetStringFromUtf8());
            if (statusCheck)
            {
                if (jsonBody.GetType() != null)
                {
                    if (jsonBody.VariantType == Variant.Type.Dictionary)
                    {
                        var jsonDictionary = (Dictionary)jsonBody;
                        if (jsonDictionary.ContainsKey("error"))
                        {
                            EmitSignal(nameof(GetContractsComplete), new Dictionary());
                        }

                        else
                        {
                            BKMRLogger.Info("Unknown Server Info");
                        }
                    }

                    else if (jsonBody.VariantType == Variant.Type.Array)
                    {
                        var jsonArray = (Array)jsonBody;
                        {
                            EmitSignal(nameof(GetContractsComplete), jsonArray);
                        }
                    }
                }

                else
                {
                    EmitSignal(nameof(GetContractsComplete), new Dictionary { {"error", "Unknown server error"} });
                }

            }

            else
            {
                EmitSignal(nameof(GetContractsComplete), new Dictionary { {"error", "error retrieving contracts"} });
            }
        }
    }
}