@tool
extends Node
class_name HazardSystem

# ============================================================
# Config Data
# ============================================================

@export_subgroup("Health")
@export var max_health := 8:
	set(value):
		max_health = value
		_update_toxin_curve()

@export_subgroup("Toxins")
@export var max_toxins := 4: # Soft Max
	set(value):
		max_toxins = value
		_update_toxin_curve()
@export var min_toxins := 0:
	set(value):
		min_toxins = value
		_update_toxin_curve()
@export var toxin_tween: Curve = Curve.new()

@export_subgroup("Health Regeneration")
@export var health_regen_rate: float = 5.0
@export var health_regen_delay: float = 3.0
@export var can_regenerate_health := true

@export_subgroup("Cheats")
@export var toxinImmunity := false
@export var damageImunity := false

# ============================================================
# Signals
# ============================================================

signal health_changed(current_health: int, max_health: int)
signal toxin_coins_changed(toxin_coins: int)
signal toxin_level_changed(toxin_level: int)

# ============================================================
# Runtime Data
# ============================================================

# Health
var current_health := max_health

# Toxins
var toxin_coins := 0
func toxin_level() -> int:
	if toxinImmunity or toxin_tween == null:
		return 0
	
	return roundi(toxin_tween.sample(clampf(
		toxin_coins,
		min_toxins,
		max_toxins
	)))

# Health Regeneration
var health_regen_timer: float = 0.0
var health_regen_accumulator : float = 0.0

# ============================================================
# Functions
# ============================================================

# Ready
func _ready() -> void:
	if Engine.is_editor_hint():
		_update_toxin_curve()
func _process(delta: float) -> void:
	if !Engine.is_editor_hint():
		update_health_regeneration(delta)

# Health
func restore_health(amount: int) -> void:
	if amount <= 0:
		return

	var health_cap: int = mini(max_regen(), max_health)
	var previous_health: int = current_health

	current_health = mini(
		current_health + amount,
		health_cap
	)

	if current_health != previous_health:
		health_changed.emit(current_health, max_health)
func take_damage(amount: int) -> void:
	if damageImunity or amount <= 0:
		return

	var previous_health: int = current_health

	current_health = maxi(current_health - amount, 0)

	if current_health < previous_health:
		health_regen_timer = health_regen_delay
		health_regen_accumulator = 0.0
		health_changed.emit(current_health, max_health)

# Toxins
func _update_toxin_curve() -> void:
	if toxin_tween == null:
		return

	toxin_tween.min_value = 0.0
	toxin_tween.max_value = float(max_health)
	toxin_tween.min_domain = float(min_toxins)
	toxin_tween.max_domain = float(max_toxins)
func purify_toxin_coins() -> int:
	var purified_amount: int = toxin_coins

	if toxin_coins != 0:
		toxin_coins = 0
		toxin_coins_changed.emit(toxin_coins)
		toxin_level_changed.emit(toxin_level())

	return purified_amount
	
func collect_toxin_coins(amount: int) -> void:
	if amount <= 0:
		return

	var previous_coins: int = toxin_coins

	toxin_coins = clampi(
		toxin_coins + amount,
		min_toxins,
		max_toxins
	)

	if toxin_coins != previous_coins:
		toxin_coins_changed.emit(toxin_coins)
		toxin_level_changed.emit(toxin_level())

# Regeneration
func max_regen() -> int:
	return maxi(max_health - toxin_level(), 0)
	
func update_health_regeneration(delta: float) -> void:
	# Stop if regeneration is disabled.
	if not can_regenerate_health or health_regen_rate <= 0.0:
		health_regen_accumulator = 0.0
		return

	# Wait until the regeneration delay has passed.
	if health_regen_timer > 0.0:
		health_regen_timer = maxf(health_regen_timer - delta, 0.0)
		return

	# Don't regenerate if we're already at the health cap.
	var health_cap: int = mini(max_regen(), max_health)

	if current_health >= health_cap:
		health_regen_accumulator = 0.0
		return

	# Accumulate fractional healing over time.
	health_regen_accumulator += health_regen_rate * delta

	var healing: int = floori(health_regen_accumulator)

	if healing > 0:
		var previous_health: int = current_health

		current_health = mini(current_health + healing, health_cap)
		health_regen_accumulator -= float(healing)

		if current_health != previous_health:
			health_changed.emit(current_health, max_health)
