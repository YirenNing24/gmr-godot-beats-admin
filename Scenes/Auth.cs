using Godot;
using Godot.Collections;
using BeatsEngine;

public partial class Auth : Control
{
    private BKMREngine BKMREngine = new();
    private LineEdit usernameField;
    private LineEdit passwordField;
    private Label errorMessageLabel;
    private Button signInButton;

    /// <summary>
    /// Called when the node is added to the scene tree for the first time.
    /// </summary>
    public override void _Ready()
    {   

        LoadNodes();
        CallDeferred("ConnectSignals");
    }

    /// <summary>
    /// Loads necessary child nodes from the scene.
    /// </summary>
    private void LoadNodes()
    {
        usernameField = GetNode<LineEdit>("Panel/VBoxContainer/VBoxContainer3/UsernameField");
        passwordField = GetNode<LineEdit>("Panel/VBoxContainer/VBoxContainer3/PasswordField");
        errorMessageLabel = GetNode<Label>("Panel/VBoxContainer/VBoxContainer4/ErrorMessage");
        signInButton = GetNode<Button>("Panel/VBoxContainer/VBoxContainer4/SignInButon"); // Assuming SignInButton is a child node
    }

    /// <summary>
    /// Connects signals for necessary UI elements.
    /// </summary>
    private void ConnectSignals()
    {
        passwordField.TextSubmitted += OnPasswordFieldTextSubmitted;
        BKMREngine.Auth.BKMRLoginComplete += OnLoginPlayerComplete;
        signInButton.Pressed += OnSignInButtonPressed;
    }

    /// <summary>
    /// Event handler for the BKMREngine login completion event.
    /// </summary>
    /// <param name="message">Dictionary containing login response data.</param>
    private void OnLoginPlayerComplete(Dictionary<string, string> message)
    {
        if (message.Count == 0)
        {
            errorMessageLabel.Text = "Unknown error";
            return;
        }
        else if (message.ContainsKey("error"))
        {
            errorMessageLabel.Text = message["error"];
            return;
        }
        else if (message.ContainsKey("username"))
        {
            GetTree().ChangeSceneToFile("res://Scenes/dashboard.tscn");
        }
        else
        {
            errorMessageLabel.Text = message["message"];
        }
    }

    /// <summary>
    /// Initiates the player login process using the provided username and password.
    /// </summary>
    private void LoginPlayer()
    {
        // BKMREngine.Auth.LoginPlayer(usernameField.Text, passwordField.Text);
    }

    /// <summary>
    /// Event handler for when text is submitted in the password field.
    /// </summary>
    /// <param name="newText">The new text entered in the password field.</param>
    private void OnPasswordFieldTextSubmitted(string newText)
    {
        if (usernameField.Text != "" && passwordField.Text != "")
        {
            return; // Both fields are empty, do nothing
        }
        else
        {
            LoginPlayer(); // At least one field is not empty, proceed with login
        }
    }

    /// <summary>
    /// Event handler for when the sign-in button is pressed.
    /// </summary>
    private void OnSignInButtonPressed()
    {
        if (string.IsNullOrEmpty(usernameField.Text) && string.IsNullOrEmpty(passwordField.Text))
        {
            return; // Both fields are empty, do nothing
        }
        else
        {
            LoginPlayer(); // At least one field is not empty, proceed with login
        }
    }
}
