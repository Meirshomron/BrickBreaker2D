extends Node


signal ball_power_up_collected(powerup_id, powerup_data)
signal paddle_power_up_collected(powerup_id, powerup_data)
signal user_power_up_collected(powerup_id, powerup_data)
signal power_up_collected(powerup_id)
signal update_user_set_score(score)
signal update_user_add_score(score)

signal player_hit_brick(hit_id)
signal ball_hit_floor(ball_id)

signal decrease_user_life
signal increase_user_life

signal level_completed

signal game_over
signal start_level
signal game_completed
