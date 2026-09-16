class_name Progression
extends RefCounted
## 战胜经验、升级、学技能。只在胜利路径调用。


static func grant_exp(hero: PlayerCharacter, catalog: GameCatalog, reward_exp: int) -> RewardReport:
	var report := RewardReport.new()
	report.reward_exp = reward_exp
	report.start_level = hero.level
	report.start_exp = hero.exp
	var curve := catalog.level_curve
	if hero.level >= curve.level_cap:
		report.discarded_exp = reward_exp
		report.end_level = hero.level
		report.end_exp = 0
		hero.exp = 0
		return report
	hero.exp += reward_exp
	report.gained_exp = reward_exp
	while hero.level < curve.level_cap:
		var need := DerivedStats.exp_to_next(hero.level, curve)
		if hero.exp < need:
			break
		hero.exp -= need
		hero.level += 1
		hero.unspent_stat_points += curve.points_per_level
		_add_primary(hero, catalog)
		report.levels_gained += 1
		_learn_unlocked_skills(hero, catalog, report)
	if hero.level >= curve.level_cap:
		report.discarded_exp += hero.exp
		hero.exp = 0
	report.end_level = hero.level
	report.end_exp = hero.exp
	DerivedStats.apply_to_hero(hero, catalog)
	return report


static func learn_unlocked_skills(hero: PlayerCharacter, catalog: GameCatalog) -> Array[String]:
	var report := RewardReport.new()
	_learn_unlocked_skills(hero, catalog, report)
	return report.new_skill_names


static func _add_primary(hero: PlayerCharacter, catalog: GameCatalog) -> void:
	var class_data := catalog.classes.get_class_data(hero.class_id)
	hero.set_stat_value(
			class_data.primary_stat,
			hero.stat_value(class_data.primary_stat) + 1,
	)


static func _learn_unlocked_skills(
		hero: PlayerCharacter,
		catalog: GameCatalog,
		report: RewardReport,
) -> void:
	var class_data := catalog.classes.get_class_data(hero.class_id)
	for skill_id: StringName in class_data.skill_ids:
		var skill := catalog.skills.get_skill(skill_id)
		if hero.level >= skill.unlock_level and hero.learn_skill(skill_id):
			report.new_skill_names.append(skill.display_name)


static func class_base_stat(class_data: ClassData, stat_id: StringName) -> int:
	match stat_id:
		&"str":
			return class_data.str
		&"agi":
			return class_data.agi
		&"intl":
			return class_data.intl
		&"con":
			return class_data.con
		&"spi":
			return class_data.spi
		&"luk":
			return class_data.luk
		_:
			return 0


static func stat_floor(hero: PlayerCharacter, catalog: GameCatalog, stat_id: StringName) -> int:
	var class_data := catalog.classes.get_class_data(hero.class_id)
	var floor_value := class_base_stat(class_data, stat_id)
	if class_data.primary_stat == stat_id:
		floor_value += hero.level - 1
	return floor_value
