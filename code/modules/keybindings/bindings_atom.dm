// You might be wondering why this isn't client level. If focus is null, we don't want you to move.
// Only way to do that is to tie the behavior into the focus's keyLoop().

/atom/movable/keyLoop(client/user)
	if(!user.keys_held["Ctrl"]) 
		var/movement_dir = NONE 
		for(var/_key in user.keys_held) 
			movement_dir = SSinput.movement_keys[_key] 
		user.Move(get_step(src, movement_dir), movement_dir)