class_name BattleResolver
extends RefCounted
## 1v1 回合结算。同步推进，不含 await。

enum ActorSide {
	PLAYER,
	ENEMY,
}

var catalog: GameCatalog
var potions: PotionBag
var player: BattleActor
var enemy: BattleActor
var current_side: ActorSide = ActorSide.PLAYER
var outcome: BattleStepResult.Outcome = BattleStepResult.Outcome.NONE


func setup(
		p_catalog: GameCatalog,
		p_potions: PotionBag,
		p_player: BattleActor,
		p_enemy: BattleActor,
) -> void:
	catalog = p_catalog
	potions = p_potions
	player = p_player
	enemy = p_enemy
	outcome = BattleStepResult.Outcome.NONE
	if player.speed >= enemy.speed:
		prepare_player_input()
	else:
		current_side = ActorSide.ENEMY


func prepare_player_input() -> void:
	current_side = ActorSide.PLAYER
	player.is_defending = false


func can_attack() -> String:
	return _player_ready()


func can_defend() -> String:
	return _player_ready()


func can_use_skill(skill_id: StringName) -> String:
	var ready := _player_ready()
	if ready != "":
		return ready
	if not player.learned_skill_ids.has(skill_id):
		return "尚未学会"
	var skill := catalog.skills.get_skill(skill_id)
	if player.mp < skill.mp_cost:
		return "MP 不足"
	if player.rg < skill.rg_cost:
		return "怒气不足"
	return ""


func can_use_item(item_id: StringName) -> String:
	var ready := _player_ready()
	if ready != "":
		return ready
	if potions.count_of(item_id, catalog.rules) <= 0:
		var item := catalog.items.get_item(item_id)
		return "没有%s" % item.display_name
	return ""


func use_attack() -> BattleStepResult:
	var reason := can_attack()
	if reason != "":
		return _blocked(reason)
	return _player_skill(_basic_skill().id)


func use_skill(skill_id: StringName) -> BattleStepResult:
	var reason := can_use_skill(skill_id)
	if reason != "":
		return _blocked(reason)
	return _player_skill(skill_id)


func use_defend() -> BattleStepResult:
	var reason := can_defend()
	if reason != "":
		return _blocked(reason)
	player.is_defending = true
	player.rg = mini(player.rg_max, player.rg + catalog.rules.rg_on_defend)
	var result := BattleStepResult.new()
	result.log_line = "%s 选择防御（本回合受伤减半，怒气+20）" % player.display_name
	_after_player_action(result)
	return result


func use_item(item_id: StringName) -> BattleStepResult:
	var reason := can_use_item(item_id)
	if reason != "":
		return _blocked(reason)
	var item := catalog.items.get_item(item_id)
	potions.consume(item_id, catalog.rules)
	player.hp = mini(player.hp_max, player.hp + item.hp_restore)
	player.mp = mini(player.mp_max, player.mp + item.mp_restore)
	var result := BattleStepResult.new()
	result.log_line = "%s 使用了%s" % [player.display_name, item.display_name]
	_after_player_action(result)
	return result


func run_enemy_turn() -> BattleStepResult:
	var result := BattleStepResult.new()
	if outcome != BattleStepResult.Outcome.NONE:
		return result
	if current_side != ActorSide.ENEMY:
		result.log_line = "还没轮到敌人"
		return result
	enemy.is_defending = false
	var damage := DamageFormula.resolve(
			enemy.phys_atk,
			player.defense,
			player.is_defending,
			catalog.rules,
	)
	player.hp = maxi(0, player.hp - damage)
	result.damage_dealt = damage
	if damage > 0:
		player.rg = mini(player.rg_max, player.rg + catalog.rules.rg_on_take_hit)
	result.log_line = "%s 攻击，造成 %d 点伤害" % [enemy.display_name, damage]
	if player.is_down():
		outcome = BattleStepResult.Outcome.DEFEAT
		result.outcome = outcome
		player.rg = 0
		result.log_line += "。你被击败了"
		return result
	prepare_player_input()
	return result


func _player_skill(skill_id: StringName) -> BattleStepResult:
	var skill := catalog.skills.get_skill(skill_id)
	player.mp = maxi(0, player.mp - skill.mp_cost)
	if skill.rg_cost > 0:
		player.rg = 0
	var scaled := DamageFormula.skill_attack(skill, player.phys_atk, player.mag_atk)
	var damage := DamageFormula.resolve(
			scaled,
			enemy.defense,
			enemy.is_defending,
			catalog.rules,
	)
	enemy.hp = maxi(0, enemy.hp - damage)
	var result := BattleStepResult.new()
	result.damage_dealt = damage
	result.log_line = "%s 使用%s，造成 %d 点伤害" % [
			player.display_name,
			skill.display_name,
			damage,
	]
	if damage > 0 and skill.rg_cost == 0:
		player.rg = mini(player.rg_max, player.rg + catalog.rules.rg_on_attack_hit)
	_after_player_action(result)
	return result


func _after_player_action(result: BattleStepResult) -> void:
	if enemy.is_down():
		outcome = BattleStepResult.Outcome.VICTORY
		result.outcome = outcome
		player.rg = 0
		result.log_line += "。战斗胜利"
		return
	if player.is_down():
		outcome = BattleStepResult.Outcome.DEFEAT
		result.outcome = outcome
		player.rg = 0
		result.log_line += "。你被击败了"
		return
	current_side = ActorSide.ENEMY
	result.wait_for_enemy = true


func _basic_skill() -> SkillData:
	for skill_id: StringName in player.learned_skill_ids:
		var skill := catalog.skills.get_skill(skill_id)
		if skill.mp_cost == 0 and skill.rg_cost == 0:
			return skill
	push_error("没有普通攻击技能")
	return catalog.skills.get_skill(player.learned_skill_ids[0])


func _player_ready() -> String:
	if outcome != BattleStepResult.Outcome.NONE:
		return "战斗已经结束"
	if current_side != ActorSide.PLAYER:
		return "还没轮到你"
	return ""


func _blocked(reason: String) -> BattleStepResult:
	var result := BattleStepResult.new()
	result.log_line = reason
	return result
