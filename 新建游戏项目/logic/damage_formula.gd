class_name DamageFormula
extends RefCounted
## 1.0 伤害公式。无随机、无暴击。未防御最低 1；防御后可为 0。


static func skill_attack(skill: SkillData, phys_atk: int, mag_atk: int) -> int:
	var attack: int = mag_atk if skill.uses_magic else phys_atk
	if skill.multiplier_den <= 0:
		return attack
	return (attack * skill.multiplier_num) / skill.multiplier_den


static func resolve(
		scaled_attack: int,
		target_defense: int,
		target_defending: bool,
		rules: BattleRulesData,
) -> int:
	var base: int = maxi(rules.min_undefended_damage, scaled_attack - target_defense)
	if target_defending:
		return maxi(0, base / rules.defend_divisor)
	return base
