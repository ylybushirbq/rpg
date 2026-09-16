class_name BackpackView
extends CanvasLayer
## 探索背包：角色、道具、装备、设置、存档。

signal closed
signal request_reset_camera
signal request_title

const STAT_IDS: Array[StringName] = [&"str", &"agi", &"intl", &"con", &"spi", &"luk"]
const STAT_LABELS: Array[String] = [
	"力量 STR",
	"敏捷 AGI",
	"智力 INT",
	"体质 CON",
	"精神 SPI",
	"幸运 LUK",
]
const TAB_CHARACTER: int = 0
const TAB_ITEMS: int = 1
const TAB_EQUIPMENT: int = 2
const TAB_SETTINGS: int = 3
const TAB_SAVE: int = 4

@onready var _root: Control = %Root
@onready var _tabs: TabContainer = %Tabs
@onready var _close_button: Button = %CloseButton
@onready var _name_label: Label = %NameLabel
@onready var _exp_bar: ExpBar = %ExpBar
@onready var _points_label: Label = %PointsLabel
@onready var _derived_label: Label = %DerivedLabel
@onready var _gold_label: Label = %GoldLabel
@onready var _skill_label: Label = %SkillLabel
@onready var _char_hint: Label = %CharHint
@onready var _stat_box: VBoxContainer = %StatBox
@onready var _item_label: Label = %ItemLabel
@onready var _item_hint: Label = %ItemHint
@onready var _weapon_label: Label = %WeaponLabel
@onready var _armor_label: Label = %ArmorLabel
@onready var _accessory_label: Label = %AccessoryLabel
@onready var _unequip_weapon: Button = %UnequipWeaponButton
@onready var _unequip_armor: Button = %UnequipArmorButton
@onready var _unequip_accessory: Button = %UnequipAccessoryButton
@onready var _bag_list: ItemList = %BagList
@onready var _equip_button: Button = %EquipButton
@onready var _empty_label: Label = %EmptyLabel
@onready var _equip_stats: Label = %EquipStats
@onready var _equip_hint: Label = %EquipHint
@onready var _reset_camera_button: Button = %ResetCameraButton
@onready var _title_button: Button = %TitleButton
@onready var _quit_button: Button = %QuitButton
@onready var _save_button: Button = %SaveButton
@onready var _load_button: Button = %LoadButton
@onready var _save_hint: Label = %SaveHint
@onready var _slot_picker: Control = %SlotPicker
@onready var _overwrite_dialog: ConfirmationDialog = %OverwriteDialog

var _stat_rows_built: bool = false
var _slot_mode: StringName = &""
var _pending_slot: int = 0


func _ready() -> void:
	visible = false
	_root.visible = false
	_close_button.pressed.connect(close)
	_unequip_weapon.pressed.connect(_on_unequip_pressed.bind(&"weapon"))
	_unequip_armor.pressed.connect(_on_unequip_pressed.bind(&"armor"))
	_unequip_accessory.pressed.connect(_on_unequip_pressed.bind(&"accessory"))
	_equip_button.pressed.connect(_on_equip_button_pressed)
	_reset_camera_button.pressed.connect(_on_reset_camera_pressed)
	_title_button.pressed.connect(_on_title_pressed)
	_quit_button.pressed.connect(_on_quit_pressed)
	_save_button.pressed.connect(_on_save_pressed)
	_load_button.pressed.connect(_on_load_pressed)
	_tabs.tab_changed.connect(_on_tab_changed)
	_slot_picker.connect(&"slot_chosen", _on_slot_chosen)
	_overwrite_dialog.confirmed.connect(_on_overwrite_confirmed)
	_tabs.set_tab_title(TAB_SAVE, "存档/读档")
	_build_stat_rows()


func is_open() -> bool:
	return visible


func open(tab_index: int = TAB_CHARACTER) -> void:
	visible = true
	_root.visible = true
	_tabs.current_tab = clampi(tab_index, 0, TAB_SAVE)
	_refresh()


func close() -> void:
	visible = false
	_root.visible = false
	closed.emit()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed(&"ui_cancel"):
		close()
		get_viewport().set_input_as_handled()


func _on_tab_changed(_tab: int) -> void:
	_refresh()


func _build_stat_rows() -> void:
	if _stat_rows_built:
		return
	_stat_rows_built = true
	for i: int in STAT_IDS.size():
		var stat_id: StringName = STAT_IDS[i]
		var line := HBoxContainer.new()
		line.add_theme_constant_override("separation", 8)
		var name_label := Label.new()
		name_label.custom_minimum_size = Vector2(160, 0)
		name_label.text = STAT_LABELS[i]
		var value_label := Label.new()
		value_label.name = "Value"
		value_label.custom_minimum_size = Vector2(48, 0)
		var minus_button := Button.new()
		minus_button.text = "-"
		minus_button.custom_minimum_size = Vector2(36, 32)
		minus_button.pressed.connect(_on_stat_minus_pressed.bind(stat_id))
		var plus_button := Button.new()
		plus_button.text = "+"
		plus_button.custom_minimum_size = Vector2(36, 32)
		plus_button.pressed.connect(_on_stat_plus_pressed.bind(stat_id))
		var note_label := Label.new()
		note_label.name = "Note"
		line.add_child(name_label)
		line.add_child(minus_button)
		line.add_child(value_label)
		line.add_child(plus_button)
		line.add_child(note_label)
		line.set_meta("stat_index", i)
		_stat_box.add_child(line)


func _on_stat_plus_pressed(stat_id: StringName) -> void:
	_char_hint.text = GameState.try_add_stat(stat_id)
	_refresh()


func _on_stat_minus_pressed(stat_id: StringName) -> void:
	_char_hint.text = GameState.try_sub_stat(stat_id)
	_refresh()


func _on_unequip_pressed(slot: StringName) -> void:
	_equip_hint.text = GameState.try_unequip(slot)
	_refresh()


func _on_equip_button_pressed() -> void:
	var selected := _bag_list.get_selected_items()
	if selected.is_empty():
		_equip_hint.text = "请先选中背包里的装备"
		return
	_equip_hint.text = GameState.try_equip_from_bag(selected[0])
	_refresh()


func _on_reset_camera_pressed() -> void:
	request_reset_camera.emit()
	_save_hint.text = "已请求重置镜头"


func _on_title_pressed() -> void:
	GameState.save_game()
	close()
	request_title.emit()


func _on_quit_pressed() -> void:
	GameState.save_game()
	get_tree().quit()


func _on_save_pressed() -> void:
	_slot_mode = &"save"
	_slot_picker.call(&"open", "选择存档栏位", false)


func _on_load_pressed() -> void:
	_slot_mode = &"load"
	_slot_picker.call(&"open", "选择要读取的存档", true)


func _on_slot_chosen(slot: int) -> void:
	_pending_slot = slot
	if _slot_mode == &"save":
		if GameState.slot_exists(slot):
			_overwrite_dialog.dialog_text = "栏位 %d 已有存档，是否覆盖？" % slot
			_overwrite_dialog.popup_centered()
			return
		_write_slot()
		return
	if _slot_mode != &"load":
		return
	var reason := GameState.load_slot(slot)
	if reason != "":
		_save_hint.text = reason
		return
	close()
	GameState.go_exploration()


func _on_overwrite_confirmed() -> void:
	_write_slot()


func _write_slot() -> void:
	GameState.select_save_slot(_pending_slot)
	GameState.save_game()
	_save_hint.text = "已写入栏位 %d" % _pending_slot
	_refresh()


func _refresh() -> void:
	if not GameState.has_hero():
		return
	_refresh_character()
	_refresh_items()
	_refresh_equipment()
	_load_button.disabled = not GameState.has_any_save()
	if _save_hint.text.is_empty():
		_save_hint.text = "当前栏位：%s" % GameState.slot_summary(GameState.selected_save_slot)


func _refresh_character() -> void:
	var hero := GameState.hero
	var class_data := GameState.catalog.classes.get_class_data(hero.class_id)
	_name_label.text = "%s · %s" % [hero.name, class_data.display_name]
	var need := DerivedStats.exp_to_next(hero.level, GameState.catalog.level_curve)
	_exp_bar.bind(hero.level, hero.exp, need, GameState.catalog.level_curve.level_cap)
	_points_label.text = "未分配点数：%d" % hero.unspent_stat_points
	var stats := DerivedStats.compute(hero, GameState.catalog)
	_derived_label.text = "HP %d/%d　MP %d/%d　物攻 %d　法攻 %d　防御 %d　速度 %d" % [
			hero.hp,
			stats.hp_max,
			hero.mp,
			stats.mp_max,
			stats.phys_atk,
			stats.mag_atk,
			stats.defense,
			stats.speed,
	]
	_gold_label.text = "金币 %d　%s" % [hero.gold, UiText.NO_SHOP]
	_skill_label.text = _skill_summary(hero)
	for child: Node in _stat_box.get_children():
		var box := child as HBoxContainer
		if box == null:
			continue
		var index: int = box.get_meta("stat_index", 0) as int
		var stat_id: StringName = STAT_IDS[index]
		var value_label := box.get_node("Value") as Label
		value_label.text = str(hero.stat_value(stat_id))
		var note_label := box.get_node("Note") as Label
		if stat_id == &"luk":
			note_label.text = UiText.LUK_NOTE
		else:
			note_label.text = ""


func _refresh_items() -> void:
	var potion_text := "绷带 %d\n清水 %d" % [
			GameState.potions.bandage,
			GameState.potions.water,
	]
	if GameState.potions.bandage == 0 and GameState.potions.water == 0:
		potion_text += "\n%s" % UiText.NO_POTIONS
	_item_label.text = potion_text
	_item_hint.text = "药水在战斗中使用。本版本暂无商店。"


func _refresh_equipment() -> void:
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
	_equip_stats.text = "物攻 %d　法攻 %d　防御 %d　HP %d　MP %d" % [
			stats.phys_atk,
			stats.mag_atk,
			stats.defense,
			stats.hp_max,
			stats.mp_max,
	]


func _skill_summary(hero: PlayerCharacter) -> String:
	var class_data := GameState.catalog.classes.get_class_data(hero.class_id)
	var parts: PackedStringArray = PackedStringArray()
	for skill_id: StringName in class_data.skill_ids:
		var skill := GameState.catalog.skills.get_skill(skill_id)
		if hero.has_learned(skill_id):
			parts.append(skill.display_name)
		else:
			parts.append("%s（%s Lv.%d）" % [
					skill.display_name,
					UiText.SKILL_LOCKED,
					skill.unlock_level,
			])
	return "技能：" + " / ".join(parts)


func _slot_text(item_id: StringName) -> String:
	if item_id == &"":
		return "空"
	return GameState.catalog.equipment.get_item(item_id).display_name
