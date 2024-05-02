extends VBoxContainer

signal update_contract_request_sent
signal update_contract_request_completed

@onready var beats_address: LineEdit = %BeatsAddress
@onready var gmr_address: LineEdit = %GMRAddress
@onready var card_address: LineEdit = %CardAddress
@onready var bundle_address: LineEdit = %BundleAddress
@onready var card_marketplace_address: LineEdit = %CardMarketplaceAddress
@onready var bundle_marketplace_address: LineEdit = %BundleMarketplaceAddress
@onready var card_upgrade_item_address: LineEdit = %CardUpgradeItemAddress
@onready var update_contract_button: Button = %UpdateContractButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	signal_connect()
	
func _on_visibility_changed() -> void:
	if visible:
		BKMREngine.Contract.get_contracts()
		
func signal_connect() -> void:
	BKMREngine.Contract.get_contracts_complete.connect(_on_get_contracts_complete)
	BKMREngine.Contract.contract_update_complete.connect(_on_update_contract_complete)

func check_permissions() -> void:
	for line_edit: LineEdit in get_tree().get_nodes_in_group("ContractLineEdits"):
		if BKMREngine.Auth.permission != "0":
			line_edit.editable = false
			update_contract_button.disabled = true
			
func _on_update_contract_button_button_up() -> void:
	var contracts: Dictionary = {
		"beatsAddress": beats_address.text, 
		"gmrAddress": gmr_address.text, 
		"cardAddress": card_address.text, 
		"bundleAddress": card_marketplace_address.text, 
  		"cardMarketplaceAddress": card_marketplace_address.text, 
		"bundleMarketplaceAddress": bundle_marketplace_address.text,
		"cardItemUpgradeAddress": card_upgrade_item_address.text
	}
	update_contract_request_sent.emit()
	BKMREngine.Contract.update_contracts(contracts)
	
func _on_get_contracts_complete(contracts: Array) -> void:
	if !contracts.is_empty():
		var latest_contracts_list: Dictionary = contracts[0]
		
		for address_name: String in latest_contracts_list.keys():
			for line_edit: LineEdit in get_tree().get_nodes_in_group("ContractLineEdits"):
				if address_name.to_lower() == line_edit.name.to_lower():
					line_edit.text = latest_contracts_list[address_name]
	
func _on_update_contract_complete(_data: Dictionary) -> void:
	update_contract_request_completed.emit()
