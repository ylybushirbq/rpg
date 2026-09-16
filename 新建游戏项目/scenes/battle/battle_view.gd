extends Node
## 战斗 UI。结算在 BattleResolver，这里只显示、发指令、播结果。

@onready var _player_name: Label = %PlayerName
@onready var _player_hp_bar: ProgressBar = %PlayerHpBar
@onready var _player_hp_label: Label = %PlayerHpLabel
@onready var _player_mp_bar: ProgressBar = %PlayerMpBar
@onready var _player_mp_label: Label = %PlayerMpLabel
@onready var _player_rg_bar: ProgressBar = %PlayerRgBar
@onready var _player_rg_label: Label = %PlayerRgLabel
@onready var _enemy_name: Label = %EnemyName
@onready var _enemy_hp_bar: ProgressBar = %EnemyHpBar
@onready var _enemy_hp_label: Label = %EnemyHpLabel
@onready var _turn_label: Label = %TurnLabel
@onready var _log_label: Label = %LogLabel
@onready var _action_panel: HBoxContainer = %ActionPanel
@onready var _skill_panel: VBoxContainer = %SkillPanel
@onready var _item_panel: VBoxContainer = %ItemPanel
@onready var _skill_list: VBoxContainer = %SkillList
@onready var _attack_button: Button = %AttackButton
@onready var _skill_button: Button = %SkillButton
@onready var _defend_button: Button = %DefendButton
@onready var _item_button: Button = %ItemButton
@onready var _skill_back_button: Button = %SkillBackButton
@onready var _bandage_button: Button = %BandageButton
@onready var _water_button: Button = %WaterButton
@onready var _item_back_button: Button = %ItemBackButton
@onready var _abort_button: Button = %AbortButton
@onready var _result_panel: ColorRect = %ResultPanel
@onready var _result_title: Label = %ResultTitle
@onready var _result_body: Label = %ResultBody
@onready var _result_exp: ExpBar = %ResultExpBar
@onready var _result_continue: Button = %ResultContinueButton
@onready var _anim: AnimationPlayer = %Anim
@onready var _world: Hd2dWorld = %Hd2dWorld

var _resolver: BattleResolver
var _busy: bool = false


func _ready() -> void:
	if GameState.current_encounter_id == &"":
		GameState.go_title()
		return
	_style_bar(_player_hp_bar, Color(0.75, 0.22, 0.22))
	_style_bar(_player_mp_bar, Color(0.25, 0.45, 0.85))
	_style_bar(_player_rg_bar, Color(0.9, 0.5, 0.15))
	_style_bar(_enemy_hp_bar, Color(0.75, 0.22, 0.22))
	_attack_button.pressed.connect(_on_attack_button_pressed)
	_skill_button.pressed.connect(_on_skill_button_pressed)
	_defend_button.pressed.connect(_on_defend_button_pressed)
	_item_button.pressed.connect(_on_item_button_pressed)
	_skill_back_button.pressed.connect(_on_skill_back_button_pressed)
	_bandage_button.pressed.connect(_on_bandage_button_pressed)
	_water_button.pressed.connect(_on_water_button_pressed)
	_item_back_button.pressed.connect(_on_item_back_button_pressed)
	_abort_button.pressed.connect(_on_abort_button_pressed)
	_result_continue.pressed.connect(_on_result_continue_button_pressed)
	_setup_battle()
	_refresh()
	_show_action_panel()
	if _resolver.current_side == BattleResolver.ActorSide.ENEMY:
		await _run_enemy_sequence()


func play_result(result: BattleStepResult) -> void:
	_log_label.text = result.log_line
	if _anim.has_animation("attack"):
		_anim.play("attack")
		await _anim.animation_finished
		if not is_instance_valid(self):
			return


func _setup_battle() -> void:
	var encounter := GameState.catalog.encounters.get_encounter(
			GameState.current_encounter_id
	)
	var enemy_data := GameState.catalog.enemies.get_enemy(encounter.enemies[0])
	_resolver = BattleResolver.new()
	_resolver.setup(
			GameState.catalog,
			GameState.potions,
			GameState.make_player_actor(),
			GameState.make_enemy_actor(enemy_data),
	)
	_player_name.text = _resolver.player.display_name
	_enemy_name.text = _resolver.enemy.display_name
	_world.setup_battle(_resolver.player.display_name, _resolver.enemy.display_name)
	_rebuild_skills()


func _on_attack_button_pressed() -> void:
	await _commit(_resolver.use_attack())


func _on_skill_button_pressed() -> void:
	_action_panel.visible = false
	_item_panel.visible = false
	_skill_panel.visible = true
	_rebuild_skills()


func _on_defend_button_pressed() -> void:
	await _commit(_resolver.use_defend())


func _on_item_button_pressed() -> void:
	_action_panel.visible = false
	_skill_panel.visible = false
	_item_panel.visible = true
	_refresh_item_buttons()


func _on_skill_back_button_pressed() -> void:
	_show_action_panel()


func _on_item_back_button_pressed() -> void:
	_show_action_panel()


func _on_bandage_button_pressed() -> void:
	await _commit(_resolver.use_item(GameState.catalog.rules.bandage_id))


func _on_water_button_pressed() -> void:
	await _commit(_resolver.use_item(GameState.catalog.rules.water_id))


func _on_skill_chosen(skill_id: StringName) -> void:
	await _commit(_resolver.use_skill(skill_id))


func _on_abort_button_pressed() -> void:
	if _busy:
		return
	GameState.abort_battle(_resolver)
	GameState.go_expedition()


func _on_result_continue_button_pressed() -> void:
	if _resolver.outcome == BattleStepResult.Outcome.DEFEAT:
		GameState.go_hub()
	else:
		GameState.go_expedition()


func _commit(result: BattleStepResult) -> void:
	if _busy:
		return
	_busy = true
	_set_command_enabled(false)
	await play_result(result)
	if not is_instance_valid(self):
		return
	_refresh()
	if result.outcome == BattleStepResult.Outcome.VICTORY:
		_finish_victory()
		return
	if result.outcome == BattleStepResult.Outcome.DEFEAT:
		_finish_defeat()
		return
	if result.wait_for_enemy:
		await _run_enemy_sequence()
		return
	_busy = false
	_set_command_enabled(true)
	_show_action_panel()
	_refresh()


func _run_enemy_sequence() -> void:
	_busy = true
	_set_command_enabled(false)
	_turn_label.text = "敌人回合"
	var result := _resolver.run_enemy_turn()
	await play_result(result)
	if not is_instance_valid(self):
		return
	_refresh()
	if result.outcome == BattleStepResult.Outcome.DEFEAT:
		_finish_defeat()
		return
	_busy = false
	_set_command_enabled(true)
	_show_action_panel()
	_refresh()


func _finish_victory() -> void:
	var report := GameState.apply_victory(_resolver)
	_result_panel.visible = true
	_abort_button.visible = false
	if report.campaign_cleared:
		_result_title.text = "胜利 · 通关"
	else:
		_result_title.text = "胜利"
	var lines: PackedStringArray = PackedStringArray()
	lines.append("获得经验 +%d" % report.reward_exp)
	lines.append("金币 +%d" % report.reward_gold)
	if report.levels_gained > 0:
		lines.append("升级 +%d（获得属性点）" % report.levels_gained)
	for skill_name: String in report.new_skill_names:
		lines.append("学会技能：%s" % skill_name)
	for drop: EquipmentData in report.drops:
		lines.append("获得装备：%s" % drop.display_name)
	for discarded: String in report.discarded_drops:
		lines.append("背包已满，丢弃：%s" % discarded)
	_result_body.text = "\n".join(lines)
	await _play_exp_growth(report)


func _finish_defeat() -> void:
	GameState.apply_defeat(_resolver)
	_result_panel.visible = true
	_abort_button.visible = false
	_result_title.text = "失败"
	_result_body.text = "HP 归零。送回地图据点并回满 HP/MP。没有经验、金币和掉落。"
	_result_exp.visible = false


func _play_exp_growth(report: RewardReport) -> void:
	var curve := GameState.catalog.level_curve
	var level := report.start_level
	var exp_now := report.start_exp
	var remaining := report.gained_exp
	_result_exp.bind(level, exp_now, DerivedStats.exp_to_next(level, curve), curve.level_cap)
	if remaining <= 0 or level >= curve.level_cap:
		_result_exp.bind(report.end_level, report.end_exp, DerivedStats.exp_to_next(
				report.end_level,
				curve,
		), curve.level_cap)
		return
	while remaining > 0 and level < curve.level_cap:
		var need := DerivedStats.exp_to_next(level, curve)
		var room := need - exp_now
		var step := mini(room, remaining)
		await _tween_exp(level, exp_now, exp_now + step, need)
		if not is_instance_valid(self):
			return
		remaining -= step
		exp_now += step
		if exp_now >= need:
			level += 1
			exp_now = 0
			if level >= curve.level_cap:
				_result_exp.bind(level, 0, 0, curve.level_cap)
				return
	_result_exp.bind(
			report.end_level,
			report.end_exp,
			DerivedStats.exp_to_next(report.end_level, curve),
			curve.level_cap,
	)


func _tween_exp(level: int, from_value: int, to_value: int, need: int) -> void:
	var tween := create_tween()
	tween.tween_method(
			_set_exp_preview.bind(level, need),
			float(from_value),
			float(to_value),
			0.35,
	)
	await tween.finished


func _set_exp_preview(value: float, level: int, need: int) -> void:
	_result_exp.bind(
			level,
			int(value),
			need,
			GameState.catalog.level_curve.level_cap,
	)


func _rebuild_skills() -> void:
	for child: Node in _skill_list.get_children():
		child.queue_free()
	for skill_id: StringName in _resolver.player.learned_skill_ids:
		var skill := GameState.catalog.skills.get_skill(skill_id)
		if skill.mp_cost == 0 and skill.rg_cost == 0:
			continue
		var button := Button.new()
		button.custom_minimum_size = Vector2(280, 40)
		button.text = _skill_caption(skill)
		var reason := _resolver.can_use_skill(skill_id)
		button.disabled = _busy or reason != ""
		if reason != "":
			button.text += "（%s）" % reason
		button.pressed.connect(_on_skill_chosen.bind(skill_id))
		_skill_list.add_child(button)


func _skill_caption(skill: SkillData) -> String:
	if skill.rg_cost > 0:
		return "%s　RG %d" % [skill.display_name, skill.rg_cost]
	if skill.mp_cost > 0:
		return "%s　MP %d" % [skill.display_name, skill.mp_cost]
	return skill.display_name


func _refresh() -> void:
	var player := _resolver.player
	var enemy := _resolver.enemy
	_bind_bar(_player_hp_bar, _player_hp_label, "HP", player.hp, player.hp_max)
	_bind_bar(_player_mp_bar, _player_mp_label, "MP", player.mp, player.mp_max)
	_bind_bar(_player_rg_bar, _player_rg_label, "RG", player.rg, player.rg_max)
	_bind_bar(_enemy_hp_bar, _enemy_hp_label, "HP", enemy.hp, enemy.hp_max)
	if _resolver.outcome != BattleStepResult.Outcome.NONE:
		_turn_label.text = "战斗结束"
	elif _resolver.current_side == BattleResolver.ActorSide.PLAYER:
		_turn_label.text = "你的回合"
	else:
		_turn_label.text = "敌人回合"
	_refresh_item_buttons()
	if _skill_panel.visible:
		_rebuild_skills()


func _refresh_item_buttons() -> void:
	var rules := GameState.catalog.rules
	var bandage_reason := _resolver.can_use_item(rules.bandage_id)
	_bandage_button.text = "绷带　剩余 %d" % GameState.potions.bandage
	_bandage_button.disabled = _busy or bandage_reason != ""
	if bandage_reason != "":
		_bandage_button.text += "（%s）" % bandage_reason
	var water_reason := _resolver.can_use_item(rules.water_id)
	_water_button.text = "清水　剩余 %d" % GameState.potions.water
	_water_button.disabled = _busy or water_reason != ""
	if water_reason != "":
		_water_button.text += "（%s）" % water_reason


func _show_action_panel() -> void:
	_action_panel.visible = true
	_skill_panel.visible = false
	_item_panel.visible = false


func _set_command_enabled(enabled: bool) -> void:
	_attack_button.disabled = not enabled
	_skill_button.disabled = not enabled
	_defend_button.disabled = not enabled
	_item_button.disabled = not enabled
	_abort_button.disabled = not enabled


func _bind_bar(
		bar: ProgressBar,
		label: Label,
		title: String,
		current: int,
		maximum: int,
) -> void:
	bar.max_value = float(maxi(1, maximum))
	bar.value = float(current)
	label.text = "%s %d / %d" % [title, current, maximum]


func _style_bar(bar: ProgressBar, fill_color: Color) -> void:
	var fill := StyleBoxFlat.new()
	fill.bg_color = fill_color
	fill.corner_radius_top_left = 3
	fill.corner_radius_top_right = 3
	fill.corner_radius_bottom_right = 3
	fill.corner_radius_bottom_left = 3
	bar.add_theme_stylebox_override("fill", fill)
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.16, 0.16, 0.18)
	bar.add_theme_stylebox_override("background", bg)
	bar.show_percentage = false
