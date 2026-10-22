extends Node

# ============================================================
# Player Data
# ============================================================

var current_health: int = 8
var max_health: int = 8

var toxin_coins: int = 0

# Future spendable currency.
var coins: int = 0


func start_new_game() -> void:
	current_health = max_health
	toxin_coins = 0
	coins = 0
