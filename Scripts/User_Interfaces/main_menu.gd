extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	$Options/ContinueGame.grab_focus()

##function to be called on new game
func _on_new_game_pressed():
	LevelManager.start_new_game()
