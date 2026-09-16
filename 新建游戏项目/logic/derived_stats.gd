class_name DerivedStats
extends RefCounted
## 派生属性与升级曲线。全部整数、向下取整。


static func exp_to_next(level: int, curve: LevelCurveData) -> int:
	if level >= curve.level_cap:
		return 0
	return curve.per_level * level + curve.base


static func compute(hero: PlayerCharacter, catalog: GameCatalog) -> StatBlock:
	var block := StatBlock.new()
	var weapon := catalog.equipment.try_get_item(hero.weapon_id)
	var armor := catalog.equipment.try_get_item(hero.armor_id)
	var accessory := catalog.equipment.try_get_item(hero.accessory_id)
	var gear_hp: int = _stat(weapon, &"hp") + _stat(armor, &"hp") + _stat(accessory, &"hp")
	var gear_mp: int = _stat(weapon, &"mp") + _stat(armor, &"mp") + _stat(accessory, &"mp")
	var gear_phys: int = (
			_stat(weapon, &"phys_atk")
			+ _stat(armor, &"phys_atk")
			+ _stat(accessory, &"phys_atk")
	)
	var gear_mag: int = (
			_stat(weapon, &"mag_atk")
			+ _stat(armor, &"mag_atk")
			+ _stat(accessory, &"mag_atk")
	)
	var gear_def: int = (
			_stat(weapon, &"defense")
			+ _stat(armor, &"defense")
			+ _stat(accessory, &"defense")
	)
	block.hp_max = 40 + hero.level * 8 + hero.con * 6 + gear_hp
	block.mp_max = 20 + hero.level * 4 + hero.spi * 4 + hero.intl * 1 + gear_mp
	block.rg_max = catalog.rules.rg_max
	block.phys_atk = hero.str * 2 + gear_phys
	block.mag_atk = hero.intl * 2 + gear_mag
	block.defense = hero.con * 1 + gear_def
	block.speed = 10 + hero.agi
	return block


static func apply_to_hero(hero: PlayerCharacter, catalog: GameCatalog) -> void:
	var block := compute(hero, catalog)
	hero.hp_max = block.hp_max
	hero.mp_max = block.mp_max
	hero.rg_max = block.rg_max
	hero.hp = mini(hero.hp, hero.hp_max)
	hero.mp = mini(hero.mp, hero.mp_max)


static func _stat(item: EquipmentData, field: StringName) -> int:
	if item == null:
		return 0
	if field == &"hp":
		return item.hp
	if field == &"mp":
		return item.mp
	if field == &"phys_atk":
		return item.phys_atk
	if field == &"mag_atk":
		return item.mag_atk
	if field == &"defense":
		return item.defense
	return 0
