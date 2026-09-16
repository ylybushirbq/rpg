extends SceneTree
## 无头公式自检。对照 V1-07 / V1-11 与伤害公式。


func _init() -> void:
	var catalog := load("res://data/game_catalog.tres") as GameCatalog
	if catalog == null:
		push_error("无法加载 game_catalog.tres")
		quit(1)
		return
	catalog.ensure_index()
	var failed: int = 0
	failed += _expect(
			DerivedStats.exp_to_next(1, catalog.level_curve) == 60,
			"1 级升 2 级需要 60 经验",
	)
	failed += _expect(
			DerivedStats.exp_to_next(2, catalog.level_curve) == 100,
			"2 级升 3 级需要 100 经验",
	)
	failed += _expect(
			DerivedStats.exp_to_next(10, catalog.level_curve) == 0,
			"满级 exp_to_next 为 0",
	)
	failed += _expect(
			catalog.enemies.get_enemy(&"mob_rat").reward_exp == 30,
			"灰鼠 +30",
	)
	failed += _expect(
			catalog.enemies.get_enemy(&"mob_wolf").reward_exp == 80,
			"野狼 +80",
	)
	failed += _expect(
			catalog.enemies.get_enemy(&"boss_ember_wolf").reward_exp == 200,
			"烬狼 +200",
	)
	var undefended := DamageFormula.resolve(10, 1, false, catalog.rules)
	failed += _expect(undefended == 9, "未防御 10-1=9")
	var zero_atk := DamageFormula.resolve(0, 5, false, catalog.rules)
	failed += _expect(zero_atk == 1, "未防御最低 1")
	var defended := DamageFormula.resolve(10, 1, true, catalog.rules)
	failed += _expect(defended == 4, "防御后 9//2=4")
	var defended_zero := DamageFormula.resolve(1, 0, true, catalog.rules)
	failed += _expect(defended_zero == 0, "防御后可为 0")
	var hero := PlayerCharacter.new()
	hero.class_id = &"guard"
	hero.level = 1
	hero.str = 8
	hero.con = 8
	hero.intl = 2
	hero.spi = 3
	hero.agi = 4
	hero.weapon_id = &"w_sword_1"
	hero.armor_id = &"a_cloth_1"
	var stats := DerivedStats.compute(hero, catalog)
	failed += _expect(stats.phys_atk == 22, "卫士 1 级物攻 STR*2+6=22")
	failed += _expect(stats.hp_max == 104, "卫士 1 级 HP 40+8+48+8=104")
	var random_encounter := RandomEncounter.new(12345)
	var saw_encounter := false
	for index: int in 100:
		if random_encounter.add_distance(RandomEncounter.MAX_DISTANCE):
			saw_encounter = true
			break
	failed += _expect(saw_encounter, "暗雷在多次距离判定中可触发")
	var next_encounter := random_encounter.pick_encounter(catalog, [])
	failed += _expect(
			catalog.encounters.get_encounter(next_encounter) != null,
			"暗雷能从遭遇表选择有效节点",
	)
	if failed > 0:
		push_error("公式自检失败 %d 项" % failed)
		quit(1)
		return
	print("formula_checks: ok")
	quit(0)


func _expect(ok: bool, label: String) -> int:
	if ok:
		return 0
	push_error("FAIL: %s" % label)
	return 1
