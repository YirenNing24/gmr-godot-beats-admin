using System;
using System.Linq;
using BeatsEngine;
using Godot;
using Godot.Collections;

public partial class ContractsWindow : VBoxContainer
{   
    private BKMREngine BKMREngine = new();

	[Signal]
	public delegate void UpdateContractRequestSentEventHandler();
	[Signal]
	public delegate void UpdateContractRequestCompletedEventHandler(Dictionary message);

	private LineEdit beatsAddress;
	private LineEdit gmrAddress;
	private LineEdit cardAddress;
	private LineEdit bundleAddress;
	private LineEdit cardMarketplaceAddress;
	private LineEdit bundleMarketplaceAddress;
	private LineEdit cardItemUpgradeAddress;
	private LineEdit cardMarketplaceUpgradeItemAddress;
	private Button updateContractButton;

	public override void _Ready()
	{
        LoadNodes();
        ConnectSignals();
	}

    private void LoadNodes()
    {
		// Initialize variables based on node paths
		beatsAddress = GetNode<LineEdit>("%BeatsAddress");
		gmrAddress = GetNode<LineEdit>("%GMRAddress");
		cardAddress = GetNode<LineEdit>("%CardAddress");
		bundleAddress = GetNode<LineEdit>("%BundleAddress");
		cardMarketplaceAddress = GetNode<LineEdit>("%CardMarketplaceAddress");
		bundleMarketplaceAddress = GetNode<LineEdit>("%BundleMarketplaceAddress");
		cardItemUpgradeAddress = GetNode<LineEdit>("%CardItemUpgradeAddress");
		cardMarketplaceUpgradeItemAddress = GetNode<LineEdit>("%CardMarketplaceUpgradeMarketplaceAddress");
		updateContractButton = GetNode<Button>("%UpdateContractButton");
    }

    private void ConnectSignals()
    {
        

        updateContractButton.Pressed += OnUpdateContractButtonPressed;
        UpdateContractRequestCompleted += OnUpdateContractsRequestCompleted;
        VisibilityChanged += OnVisibilityChanged;

    }

    private void OnVisibilityChanged()
    {
        if (Visible)
        {
            // BKMREngine.Contracts.GetContracts();
        }
    }

    private void OnGetContractsComplete(Array<Dictionary<string, string>> contracts)
    {
        foreach(LineEdit lineEdit in GetTree().GetNodesInGroup("ContractLineEdits").Cast<LineEdit>())
        {
            
        }
    }

    private void OnUpdateContractButtonPressed()
	{
		var contracts = new Dictionary
		{
			{"beatsAddress", beatsAddress.Text},
			{"gmrAddress", gmrAddress.Text},
			{"cardAddress", cardAddress.Text},
			{"bundleAddress", bundleAddress.Text},
			{"cardMarketplaceAddress", cardMarketplaceAddress.Text},
			{"bundleMarketplaceAddress", bundleMarketplaceAddress.Text},
			{"cardItemUpgradeAddress", cardItemUpgradeAddress.Text},
			{"cardMarketplaceUpgradeItemAddress", cardMarketplaceUpgradeItemAddress.Text}
		};

        // BKMREngine.Contracts.UpdateContracts(contracts);
        EmitSignal(nameof(UpdateContractRequestSent));  
	}

    private void OnUpdateContractsRequestCompleted(Dictionary message)
    {

    }


}
