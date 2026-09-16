extends Control
## 角色页：六维加减、派生、经验条、药水。

const STAT_IDS: Array[StringName] = [&"str", &"agi", &"intl", &"con", &"spi", &"luk"]
const STAT_LABELS: Array[String] = [
	"力量 STR",
	"敏捷 AGI",
	"智力 INT",
	"体质 CON",
	"精神 SPI",
	"幸运 LUK",
]

@onready var _back_button: Button = %BackButton
@onready var _name_label: Label = %NameLabel
@onready var _exp_bar: ExpBar = %ExpBar
@onready var _points_label: Label = %PointsLabel
@onready var _derived_label: Label = %DerivedLabel
@onready var _potion_label: Label = %PotionLabel
@onready var _gold_label: Label = %GoldLabel
@onready var _skill_label: Label = %SkillLabel
@onready var _hint_label: Label = %HintLabel
@onready var _stat_box: VBoxContainer = %StatBox


func _ready() -> void:
	_back_button.pressed.connect(_on_back_button_pressed)
	_build_stat_rows()
	_refresh()


func _on_back_button_pressed() -> void:
	GameState.go_hub()


func _build_stat_rows() -> void:
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
	_hint_label.text = GameState.try_add_stat(stat_id)
	_refresh()


func _on_stat_minus_pressed(stat_id: StringName) -> void:
	_hint_label.text = GameState.try_sub_stat(stat_id)
	_refresh()


func _refresh() -> void:
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
	var potion_text := "绷带 %d / 清水 %d" % [
			GameState.potions.bandage,
			GameState.potions.water,
	]
	if GameState.potions.bandage == 0 and GameState.potions.water == 0:
		potion_text += "　%s" % UiText.NO_POTIONS
	_potion_label.text = potion_text
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
