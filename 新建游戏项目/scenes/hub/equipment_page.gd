extends Control
## 装备页：三槽穿脱 + 背包。

@onready var _back_button: Button = %BackButton
@onready var _weapon_label: Label = %WeaponLabel
@onready var _armor_label: Label = %ArmorLabel
@onready var _accessory_label: Label = %AccessoryLabel
@onready var _unequip_weapon: Button = %UnequipWeaponButton
@onready var _unequip_armor: Button = %UnequipArmorButton
@onready var _unequip_accessory: Button = %UnequipAccessoryButton
@onready var _bag_list: ItemList = %BagList
@onready var _equip_button: Button = %EquipButton
@onready var _empty_label: Label = %EmptyLabel
@onready var _stats_label: Label = %StatsLabel
@onready var _hint_label: Label = %HintLabel


func _ready() -> void:
	_back_button.pressed.connect(_on_back_button_pressed)
	_unequip_weapon.pressed.connect(_on_unequip_pressed.bind(&"weapon"))
	_unequip_armor.pressed.connect(_on_unequip_pressed.bind(&"armor"))
	_unequip_accessory.pressed.connect(_on_unequip_pressed.bind(&"accessory"))
	_equip_button.pressed.connect(_on_equip_button_pressed)
	_refresh()


func _on_back_button_pressed() -> void:
	GameState.go_hub()


func _on_unequip_pressed(slot: StringName) -> void:
	_hint_label.text = GameState.try_unequip(slot)
	_refresh()


func _on_equip_button_pressed() -> void:
	var selected := _bag_list.get_selected_items()
	if selected.is_empty():
		_hint_label.text = "请先选中背包里的装备"
		return
	_hint_label.text = GameState.try_equip_from_bag(selected[0])
	_refresh()


func _refresh() -> void:
	var hero := GameState.hero
	_weapon_label.text = "武器：" + _slot_text(hero.weapon_id)
	_armor_label.text = "防具：" + _slot_text(hero.armor_id)
	_accessory_label.text = "饰品：" + _slot_text(hero.accessory_id)
	_bag_list.clear()
	for item_id: StringName in GameState.inventory:
		var item := GameState.catalog.equipment.get_item(item_id)
		var extra := ""
		if not item.can_equip(hero.class_id):
			extra = "（职业不符）"
		_bag_list.add_item("%s%s" % [item.display_name, extra])
	_empty_label.visible = GameState.inventory.is_empty()
	_empty_label.text = UiText.EMPTY_BAG
	var stats := DerivedStats.compute(hero, GameState.catalog)
	_stats_label.text = "物攻 %d　法攻 %d　防御 %d　HP %d　MP %d" % [
			stats.phys_atk,
			stats.mag_atk,
			stats.defense,
			stats.hp_max,
			stats.mp_max,
	]
	if GameState.last_hint != "":
		_hint_label.text = GameState.last_hint
		GameState.last_hint = ""


func _slot_text(item_id: StringName) -> String:
	if item_id == &"":
		return "空"
	return GameState.catalog.equipment.get_item(item_id).display_name
