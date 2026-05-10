extends Node

var panel: Panel = null
var container: HBoxContainer = null

func _ready() -> void:
	add_to_group("upgrade_ui")
	call_deferred("find_nodes")

func find_nodes() -> void:
	panel = get_tree().root.find_child("Panel", true, false)
	container = get_tree().root.find_child("CardsContainer", true, false)

func show_upgrades(upgrades: Array) -> void:
	if panel == null:
		find_nodes()
	if not panel or not container:
		return

	for child in container.get_children():
		child.queue_free()

	panel.visible = true

	for upgrade in upgrades:
		var card = _create_card(upgrade)
		container.add_child(card)

func _create_card(upgrade: Dictionary) -> Button:
	var btn = Button.new()
	btn.custom_minimum_size = Vector2(175, 230)
	btn.text = upgrade["icon"] + "\n\n" + upgrade["name"] + "\n\n" + upgrade["desc"]
	btn.add_theme_font_size_override("font_size", 15)
	btn.add_theme_color_override("font_color", Color(0.95, 0.85, 0.6))

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.08, 0.04)
	style.border_color = Color(0.75, 0.55, 0.1)
	style.set_border_width_all(3)
	style.set_corner_radius_all(8)
	btn.add_theme_stylebox_override("normal", style)

	var hover = StyleBoxFlat.new()
	hover.bg_color = Color(0.22, 0.16, 0.06)
	hover.border_color = Color(1.0, 0.8, 0.2)
	hover.set_border_width_all(3)
	hover.set_corner_radius_all(8)
	btn.add_theme_stylebox_override("hover", hover)

	var uid = upgrade["id"]
	btn.pressed.connect(func(): _on_selected(uid))
	return btn

func _on_selected(upgrade_id: String) -> void:
	if panel:
		panel.visible = false
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.apply_upgrade(upgrade_id)
