extends Resource
class_name SaveData

@export var application_version: String
@export var time_played: float = 0.0

# Dictionary[Enums.CurrencyType, int]
@export var currency_amounts: Dictionary = {}

# Dictionary[String, UpgradeSaveData]
@export var upgrade_save_data: Dictionary = {}
