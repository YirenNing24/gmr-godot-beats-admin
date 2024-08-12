extends Panel

@onready var loading_wheel: TextureProgressBar = %LoadingWheel

var tween: Tween


func fake_loader() -> void:
	visible = true
	loading_wheel.value = 0
	tween = get_tree().create_tween()
	
	var _wheel_loader: PropertyTweener = tween.tween_property(loading_wheel, "value", 100, 3.0).set_trans(Tween.TRANS_LINEAR)
	var _loader_fake: CallbackTweener = tween.tween_callback(fake_loader)
	
func tween_kill() -> void:
	if tween:
		tween.kill()

func _on_submit_confirmation_panel_request_sent() -> void:
	fake_loader()
	
	
func _on_mint_card_window_request_completed() -> void:
	tween_kill()
	visible = false

func _on_post_card_window_get_cards_request_sent() -> void:
	fake_loader()
	
	
func _on_post_card_window_get_cards_request_completed() -> void:
	tween_kill()
	visible = false
	
func _on_post_modal_list_card_request_sent() -> void:
	fake_loader()
	
	
func _on_post_modal_list_card_request_completed() -> void:
	tween_kill()
	visible = false

func _on_card_bundle_modal_get_cards_request_sent() -> void:
	fake_loader()
	
	
func _on_card_bundle_modal_get_cards_request_completed() -> void:
	tween_kill()
	visible = false

func _on_contracts_window_update_contract_request_sent() -> void:
	fake_loader()
func _on_contracts_window_update_contract_request_completed() -> void:
	tween_kill()
	visible = false

func _on_create_upgrade_items_create_upgrade_item_request_complete() -> void:
	tween_kill()
	visible = false
	
func _on_create_upgrade_items_create_upgrade_item_request_sent() -> void:
	fake_loader()
