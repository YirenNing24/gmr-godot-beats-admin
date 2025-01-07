extends VBoxContainer



var mission_object: Dictionary[String, Variant] = {}
var card_reward_array: Array[String]

func _on_visibility_changed() -> void:
	pass # Replace with function body.
	
	
func _on_mission_type_field_item_selected(index: int) -> void:
	%MissionSubtypeField.clear()
	if index == 0:
		%MissionSubtypeField.add_item("uniqueSongs", 0)
		%MissionSubtypeField.add_item("score", 1)
	elif index == 1:
		%MissionSubtypeField.add_item("random", 0)
		%MissionSubtypeField.add_item("specificGroup", 1)
	
	
func _on_reward_field_item_selected(index: int) -> void:
	if index == 0:
		%CardNamesField.visible = true
		%GroupField.visible = true
		%Label3.visible = false
		%Label4.visible = false
	elif index == 1:
		%CardNamesField.visible = true
		%GroupField.visible = true
		%Label3.visible = true
		%Label4.visible = true
	
	
func _on_required_mission_value_field_text_changed(required_value: String) -> void:
	if required_value.is_valid_int():
		%RequiredMissionValueField.text = required_value
		%RequiredMissionValueField.caret_column = %RequiredMissionValueField.text.length()
	else:
		%RequiredMissionValueField.text = ""
	
	
func _on_reward_amount_field_text_changed(required_value: String) -> void:
	if required_value.is_valid_int():
		%RewardAmountField.text = required_value
		%RewardAmountField.caret_column = %RewardAmountField.text.length()
	else:
		%RewardAmountField.text = ""
	
	
func _on_review_button_pressed() -> void:
		mission_object = {
			"name": %MissionNameField.text,
			"missionType": %MissionTypeField.get_item_text().to_lower(),
			"description": %DescriptionField.text,
			"requirement": { 
				"criteria": {
					"type": %MissionSubtypeField.get_item_text(),
					"value": int(%RequiredMissionValueField.text),
					"group": "",
					"description": %DescriptionField.text,
					"reward": { 
								"name": %RewardField.get_item_text(),
								"cards": card_reward_array,
								"beats": 0,
								"amount": int(%RewardAmountField.text) 
					}
				},
			}
		}
