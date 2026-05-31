using System;
using System.Text;
using System.Collections;
using UnityEngine;
using UnityEngine.Networking;

// This script is the "Nervous System" of WeeLysium.
// It tracks in-game credits and sends them to the server for real-world impact.

public class WeeBridge : MonoBehaviour
{
    // Allows other scripts to find this easily (Singleton)
    public static WeeBridge Instance;

    [Header("Backend Settings")]
    public string serverUrl = "http://localhost:3000";

    [Header("Player Data")]
    public string playerId = "Player_123";
    public string zipCode = "30308";
    public int pendingCredits = 0;

    void Awake()
    {
        // Setup Singleton
        if (Instance == null) Instance = this;
        else Destroy(gameObject);
    }

    // This is called whenever a player does something good (like rescue an animal)
    public void TrackAction(int creditCost)
    {
        pendingCredits += creditCost;
        Debug.Log($"[WEE-BRIDGE] +{creditCost} Credits. Total Pending: {pendingCredits}");
    }

    // This is called at the end of a session (The Sunday Review)
    public void FinalizeSession()
    {
        StartCoroutine(SendSessionToServer());
    }

    private IEnumerator SendSessionToServer()
    {
        string endpoint = serverUrl + "/api/v1/session/terminate";

        // Create the data package (matches what our server.js expects)
        SessionData data = new SessionData();
        data.user_id = playerId;
        data.session_zip_code = zipCode;
        data.credits_spent = pendingCredits;

        string json = JsonUtility.ToJson(data);
        byte[] bodyRaw = Encoding.UTF8.GetBytes(json);

        using (UnityWebRequest request = new UnityWebRequest(endpoint, "POST"))
        {
            request.uploadHandler = new UploadHandlerRaw(bodyRaw);
            request.downloadHandler = new DownloadHandlerBuffer();
            request.SetRequestHeader("Content-Type", "application/json");

            Debug.Log("[WEE-BRIDGE] Syncing with server...");
            yield return request.SendWebRequest();

            if (request.result == UnityWebRequest.Result.Success)
            {
                // Parse the server's response to get the Secure Checkout URL
                ServerResponse response = JsonUtility.FromJson<ServerResponse>(request.downloadHandler.text);
                
                Debug.Log($"[WEE-BRIDGE] Success! Redirecting to: {response.checkout_url}");
                
                // RESET local credits after successful sync
                pendingCredits = 0;

                // OPEN browser to finalize donation (Bypassing 30% App Store Fee)
                Application.OpenURL(response.checkout_url);
            }
            else
            {
                Debug.LogError($"[WEE-BRIDGE] Server Error: {request.error}");
            }
        }
    }

    // Helper classes to format the JSON data
    [Serializable]
    public class SessionData
    {
        public string user_id;
        public string session_zip_code;
        public int credits_spent;
    }

    [Serializable]
    public class ServerResponse
    {
        public string message;
        public string checkout_url;
    }
}