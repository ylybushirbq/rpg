extends Node
## 全局进度：角色、背包、药水、已击败节点、切场景。战斗临时状态不放这里。

const CATALOG_PATH := "res://data/game_catalog.tres"
const SAVES_DIRECTORY := "user://saves"
const LEGACY_SAVE_PATH := "user://saves/auto.json"
const SAVE_SLOT_COUNT := 3
const TITLE_SCENE := preload("res://scenes/boot/boot.tscn")
const CREATE_SCENE := preload("res://scenes/create/create.tscn")
const CHARACTER_SCENE := preload("res://scenes/hub/character_page.tscn")
const EQUIPMENT_SCENE := preload("res://scenes/hub/equipment_page.tscn")
const EXPEDITION_SCENE := preload("res://scenes/hub/expedition_page.tscn")
const EXPLORATION_SCENE := preload("res://scenes/exploration/exploration.tscn")
const BATTLE_SCENE := preload("res://scenes/battle/battle.tscn")
const STAT_IDS: Array[StringName] = [&"str", &"agi", &"intl", &"con", &"spi", &"luk"]
const HUB_WORLD_POSITION := Vector3(-6.4, 0.0, -5.8)
const HUB_ARRIVAL := Vector3(-3.8, 0.0, -3.4)
const HUB_RADIUS := 2.4

var catalog: GameCatalog
var hero: PlayerCharacter
var potions: PotionBag = PotionBag.new()
var inventory: Array[StringName] = []
var cleared_node_ids: Array[StringName] = []
var corrupt_save_message: String = ""
var current_encounter_id: StringName = &""
var exploration_position: Vector3 = Vector3.ZERO
var last_reward: RewardReport
var last_hint: String = ""
var selected_save_slot: int = 1


func _ready() -> void:
	catalog = load(CATALOG_PATH) as GameCatalog
	assert(catalog != null, "缺少策划表 res://data/game_catalog.tres")
	catalog.ensure_index()
	_ensure_save_directory()
	_migrate_legacy_save()


func has_hero() -> bool:
	return hero != null and hero.class_id != &""


func is_node_cleared(node_id: StringName) -> bool:
	return cleared_node_ids.has(node_id)


func is_campaign_cleared() -> bool:
	return is_node_cleared(&"node_4")


func go_title() -> void:
	_change(TITLE_SCENE)


func go_create() -> void:
	_change(CREATE_SCENE)


func go_hub() -> void:
	exploration_position = HUB_ARRIVAL
	go_exploration()


func has_save() -> bool:
	return has_any_save()


func has_any_save() -> bool:
	for slot: int in range(1, SAVE_SLOT_COUNT + 1):
		if slot_exists(slot):
			return true
	return false


func slot_exists(slot: int) -> bool:
	return FileAccess.file_exists(_slot_path(slot))


func select_save_slot(slot: int) -> bool:
	if not _is_valid_slot(slot):
		return false
	selected_save_slot = slot
	return true


func slot_summary(slot: int) -> String:
	if not _is_valid_slot(slot):
		return "无效存档栏位"
	if not slot_exists(slot):
		return "栏位 %d　空" % slot
	var file := FileAccess.open(_slot_path(slot), FileAccess.READ)
	if file == null:
		return "栏位 %d　无法读取" % slot
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return "栏位 %d　存档损坏" % slot
	var data := parsed as Dictionary
	var hero_name := str(data.get("name", "未知角色"))
	var level := _as_int(data.get("level", 1), 1)
	return "栏位 %d　%s · Lv.%d" % [slot, hero_name, level]


func load_slot(slot: int) -> String:
	if not _is_valid_slot(slot):
		return "无效存档栏位"
	if not slot_exists(slot):
		return "该栏位没有存档"
	hero = null
	corrupt_save_message = ""
	_try_load_path(_slot_path(slot))
	if corrupt_save_message != "":
		return corrupt_save_message
	if not has_hero():
		return "没有可用存档"
	selected_save_slot = slot
	return ""


func load_game() -> String:
	return load_slot(selected_save_slot)


func is_near_hub(world_position: Vector3) -> bool:
	var flat := Vector3(world_position.x, 0.0, world_position.z)
	var hub := Vector3(HUB_WORLD_POSITION.x, 0.0, HUB_WORLD_POSITION.z)
	return flat.distance_to(hub) <= HUB_RADIUS


func go_character() -> void:
	_change(CHARACTER_SCENE)


func go_equipment() -> void:
	_change(EQUIPMENT_SCENE)


func go_expedition() -> void:
	go_exploration()


func go_exploration() -> void:
	_change(EXPLORATION_SCENE)


func go_battle(encounter_id: StringName) -> void:
	current_encounter_id = encounter_id
	_change(BATTLE_SCENE)


func create_hero(hero_name: String, class_id: StringName) -> String:
	var rules := catalog.rules
	var trimmed := hero_name.strip_edges()
	if trimmed.is_empty():
		trimmed = rules.default_hero_name
	if trimmed.length() < rules.name_min_chars or trimmed.length() > rules.name_max_chars:
		return "名字需要 %d 到 %d 个字" % [rules.name_min_chars, rules.name_max_chars]
	if not catalog.classes.has_class(class_id):
		return "未知职业"
	var class_data := catalog.classes.get_class_data(class_id)
	hero = PlayerCharacter.new()
	hero.name = trimmed
	hero.class_id = class_id
	hero.level = 1
	hero.exp = 0
	hero.str = class_data.str
	hero.agi = class_data.agi
	hero.intl = class_data.intl
	hero.con = class_data.con
	hero.spi = class_data.spi
	hero.luk = class_data.luk
	hero.unspent_stat_points = 0
	hero.weapon_id = class_data.starter_weapon_id
	hero.armor_id = class_data.starter_armor_id
	hero.accessory_id = &""
	hero.gold = 0
	hero.rg = 0
	hero.learned_skill_ids.clear()
	Progression.learn_unlocked_skills(hero, catalog)
	DerivedStats.apply_to_hero(hero, catalog)
	hero.hp = hero.hp_max
	hero.mp = hero.mp_max
	inventory.clear()
	cleared_node_ids.clear()
	exploration_position = HUB_ARRIVAL
	potions.bandage = rules.starter_bandage
	potions.water = rules.starter_water
	corrupt_save_message = ""
	last_hint = ""
	save_game()
	return ""


func rest_at_hub() -> void:
	if not has_hero():
		return
	hero.hp = hero.hp_max
	hero.mp = hero.mp_max
	hero.rg = 0
	last_hint = "已休息，HP/MP 已回满（不补充药水）"
	save_game()


func try_add_stat(stat_id: StringName) -> String:
	if not has_hero():
		return "还没有角色"
	if hero.unspent_stat_points <= 0:
		return "没有可分配点数"
	if not STAT_IDS.has(stat_id):
		return "未知属性"
	hero.set_stat_value(stat_id, hero.stat_value(stat_id) + 1)
	hero.unspent_stat_points -= 1
	DerivedStats.apply_to_hero(hero, catalog)
	return ""


func try_sub_stat(stat_id: StringName) -> String:
	if not has_hero():
		return "还没有角色"
	if not STAT_IDS.has(stat_id):
		return "未知属性"
	var floor_value := Progression.stat_floor(hero, catalog, stat_id)
	if hero.stat_value(stat_id) <= floor_value:
		return "不能低于职业成长下限"
	hero.set_stat_value(stat_id, hero.stat_value(stat_id) - 1)
	hero.unspent_stat_points += 1
	DerivedStats.apply_to_hero(hero, catalog)
	return ""


func try_equip_from_bag(index: int) -> String:
	if index < 0 or index >= inventory.size():
		return "请先选中背包里的装备"
	var item_id := inventory[index]
	var data := catalog.equipment.get_item(item_id)
	if not data.can_equip(hero.class_id):
		return "职业不符，无法装备"
	var current := hero.equipped_id(data.slot)
	inventory.remove_at(index)
	if current != &"":
		inventory.append(current)
	hero.set_equipped_id(data.slot, item_id)
	DerivedStats.apply_to_hero(hero, catalog)
	last_hint = "已装备%s" % data.display_name
	return ""


func try_unequip(slot: StringName) -> String:
	var current := hero.equipped_id(slot)
	if current == &"":
		return "该槽位是空的"
	if inventory.size() >= catalog.rules.inventory_cap:
		return "背包已满，无法卸下"
	hero.set_equipped_id(slot, &"")
	inventory.append(current)
	DerivedStats.apply_to_hero(hero, catalog)
	last_hint = "已卸下%s" % catalog.equipment.get_item(current).display_name
	return ""


func make_player_actor() -> BattleActor:
	var stats := DerivedStats.compute(hero, catalog)
	var actor := BattleActor.new()
	actor.display_name = hero.name
	actor.is_player = true
	actor.hp = hero.hp
	actor.hp_max = stats.hp_max
	actor.mp = hero.mp
	actor.mp_max = stats.mp_max
	actor.rg = 0
	actor.rg_max = stats.rg_max
	actor.phys_atk = stats.phys_atk
	actor.mag_atk = stats.mag_atk
	actor.defense = stats.defense
	actor.speed = stats.speed
	actor.learned_skill_ids = hero.learned_skill_ids.duplicate()
	return actor


func make_enemy_actor(enemy_data: EnemyData) -> BattleActor:
	var actor := BattleActor.new()
	actor.display_name = enemy_data.display_name
	actor.is_player = false
	actor.hp = enemy_data.hp
	actor.hp_max = enemy_data.hp
	actor.phys_atk = enemy_data.phys_atk
	actor.defense = enemy_data.defense
	actor.speed = enemy_data.speed
	return actor


func apply_victory(resolver: BattleResolver) -> RewardReport:
	_copy_vitals_from(resolver.player)
	hero.mp = mini(
			hero.mp_max,
			hero.mp + int(float(hero.mp_max * catalog.rules.mp_restore_percent) / 100.0),
	)
	hero.rg = 0
	var encounter := catalog.encounters.get_encounter(current_encounter_id)
	var enemy := catalog.enemies.get_enemy(encounter.enemies[0])
	var report := Progression.grant_exp(hero, catalog, enemy.reward_exp)
	hero.gold += enemy.reward_gold
	report.reward_gold = enemy.reward_gold
	var first_clear := not is_node_cleared(current_encounter_id)
	if first_clear:
		_grant_first_drops(encounter, report)
		cleared_node_ids.append(current_encounter_id)
	report.campaign_cleared = current_encounter_id == &"node_4"
	last_reward = report
	last_hint = ""
	current_encounter_id = &""
	save_game()
	return report


func apply_defeat(resolver: BattleResolver) -> void:
	_copy_vitals_from(resolver.player)
	hero.hp = hero.hp_max
	hero.mp = hero.mp_max
	hero.rg = 0
	last_reward = null
	exploration_position = HUB_ARRIVAL
	last_hint = "战斗失败，已送回地图据点并回满 HP/MP。没有经验、金币和掉落。"
	current_encounter_id = &""
	save_game()


func abort_battle(resolver: BattleResolver) -> void:
	_copy_vitals_from(resolver.player)
	hero.rg = 0
	last_reward = null
	last_hint = "已退出战斗。本场作废，已消耗的道具不退回。"
	current_encounter_id = &""
	save_game()


func save_game() -> void:
	if not has_hero():
		return
	_ensure_save_directory()
	var payload := _to_save_dict()
	var file := FileAccess.open(_slot_path(selected_save_slot), FileAccess.WRITE)
	if file == null:
		push_error("无法写入存档: %s" % error_string(FileAccess.get_open_error()))
		return
	file.store_string(JSON.stringify(payload, "\t"))


func _try_load_path(path: String) -> void:
	corrupt_save_message = ""
	if not FileAccess.file_exists(path):
		return
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		corrupt_save_message = "存档无法读取，将从创建角色开始。"
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		corrupt_save_message = "存档损坏，将从创建角色开始。"
		return
	var data: Dictionary = parsed
	if not _apply_save_dict(data):
		hero = null
		corrupt_save_message = "存档损坏，将从创建角色开始。"


func _ensure_save_directory() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SAVES_DIRECTORY))


func _migrate_legacy_save() -> void:
	if not FileAccess.file_exists(LEGACY_SAVE_PATH) or slot_exists(1):
		return
	var legacy := FileAccess.open(LEGACY_SAVE_PATH, FileAccess.READ)
	if legacy == null:
		return
	var migrated := FileAccess.open(_slot_path(1), FileAccess.WRITE)
	if migrated == null:
		return
	migrated.store_string(legacy.get_as_text())


func _slot_path(slot: int) -> String:
	return "%s/slot_%d.json" % [SAVES_DIRECTORY, slot]


func _is_valid_slot(slot: int) -> bool:
	return slot >= 1 and slot <= SAVE_SLOT_COUNT


func _to_save_dict() -> Dictionary:
	return {
		"save_version": 1,
		"name": hero.name,
		"class_id": String(hero.class_id),
		"level": hero.level,
		"exp": hero.exp,
		"str": hero.str,
		"agi": hero.agi,
		"intl": hero.intl,
		"con": hero.con,
		"spi": hero.spi,
		"luk": hero.luk,
		"unspent_stat_points": hero.unspent_stat_points,
		"hp": hero.hp,
		"mp": hero.mp,
		"weapon_id": String(hero.weapon_id),
		"armor_id": String(hero.armor_id),
		"accessory_id": String(hero.accessory_id),
		"learned_skill_ids": _names_to_strings(hero.learned_skill_ids),
		"gold": hero.gold,
		"companions": [],
		"job_change_unlocked": false,
		"statuses": [],
		"bandage": potions.bandage,
		"water": potions.water,
		"inventory": _names_to_strings(inventory),
		"cleared_node_ids": _names_to_strings(cleared_node_ids),
		"exploration_position": [
			exploration_position.x,
			exploration_position.y,
			exploration_position.z,
		],
	}


func _apply_save_dict(data: Dictionary) -> bool:
	var class_id := StringName(str(data.get("class_id", "")))
	if not catalog.classes.has_class(class_id):
		return false
	hero = PlayerCharacter.new()
	hero.name = str(data.get("name", catalog.rules.default_hero_name))
	hero.class_id = class_id
	hero.level = _as_int(data.get("level", 1), 1)
	hero.exp = _as_int(data.get("exp", 0), 0)
	hero.str = _as_int(data.get("str", 0), 0)
	hero.agi = _as_int(data.get("agi", 0), 0)
	hero.intl = _as_int(data.get("intl", 0), 0)
	hero.con = _as_int(data.get("con", 0), 0)
	hero.spi = _as_int(data.get("spi", 0), 0)
	hero.luk = _as_int(data.get("luk", 0), 0)
	hero.unspent_stat_points = _as_int(data.get("unspent_stat_points", 0), 0)
	hero.weapon_id = StringName(str(data.get("weapon_id", "")))
	hero.armor_id = StringName(str(data.get("armor_id", "")))
	hero.accessory_id = StringName(str(data.get("accessory_id", "")))
	hero.learned_skill_ids = _strings_to_names(data.get("learned_skill_ids", []))
	hero.gold = _as_int(data.get("gold", 0), 0)
	hero.companions = []
	hero.job_change_unlocked = false
	hero.statuses = []
	potions.bandage = _as_int(data.get("bandage", 0), 0)
	potions.water = _as_int(data.get("water", 0), 0)
	inventory = _strings_to_names(data.get("inventory", []))
	cleared_node_ids = _strings_to_names(data.get("cleared_node_ids", []))
	exploration_position = _array_to_vector3(data.get("exploration_position", []))
	DerivedStats.apply_to_hero(hero, catalog)
	hero.hp = clampi(_as_int(data.get("hp", hero.hp_max), hero.hp_max), 0, hero.hp_max)
	hero.mp = clampi(_as_int(data.get("mp", hero.mp_max), hero.mp_max), 0, hero.mp_max)
	hero.rg = 0
	if hero.learned_skill_ids.is_empty():
		Progression.learn_unlocked_skills(hero, catalog)
	return true


func _grant_first_drops(encounter: EncounterData, report: RewardReport) -> void:
	var drop_ids: Array[StringName] = []
	if hero.class_id == &"guard" and encounter.guard_extra_drop_id != &"":
		drop_ids.append(encounter.guard_extra_drop_id)
	elif hero.class_id == &"sorcerer" and encounter.sorcerer_extra_drop_id != &"":
		drop_ids.append(encounter.sorcerer_extra_drop_id)
	for drop_id: StringName in encounter.first_drop_ids:
		drop_ids.append(drop_id)
	for drop_id: StringName in drop_ids:
		var item := catalog.equipment.get_item(drop_id)
		if inventory.size() >= catalog.rules.inventory_cap:
			report.discarded_drops.append(item.display_name)
			last_hint = "背包已满"
			continue
		inventory.append(drop_id)
		report.drops.append(item)


func _copy_vitals_from(actor: BattleActor) -> void:
	hero.hp = actor.hp
	hero.mp = actor.mp
	hero.rg = 0


func _change(scene: PackedScene) -> void:
	call_deferred("_change_now", scene)


func _change_now(scene: PackedScene) -> void:
	var err := get_tree().change_scene_to_packed(scene)
	if err != OK:
		push_error("切场景失败: %s" % error_string(err))


func _names_to_strings(ids: Array[StringName]) -> Array[String]:
	var result: Array[String] = []
	for id_value: StringName in ids:
		result.append(String(id_value))
	return result


func _strings_to_names(value: Variant) -> Array[StringName]:
	var result: Array[StringName] = []
	if typeof(value) != TYPE_ARRAY:
		return result
	var values: Array = value
	for entry: Variant in values:
		result.append(StringName(str(entry)))
	return result


func _as_int(value: Variant, fallback: int) -> int:
	match typeof(value):
		TYPE_INT:
			return value as int
		TYPE_FLOAT:
			return int(value as float)
		TYPE_STRING:
			var text := value as String
			if text.is_valid_int():
				return text.to_int()
			return fallback
		_:
			return fallback


func _array_to_vector3(value: Variant) -> Vector3:
	if typeof(value) != TYPE_ARRAY:
		return Vector3.ZERO
	var values := value as Array
	if values.size() != 3:
		return Vector3.ZERO
	return Vector3(
			_as_float(values[0]),
			_as_float(values[1]),
			_as_float(values[2]),
	)


func _as_float(value: Variant) -> float:
	if typeof(value) == TYPE_FLOAT:
		return value as float
	if typeof(value) == TYPE_INT:
		return float(value as int)
	return 0.0
