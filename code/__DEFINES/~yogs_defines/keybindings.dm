GLOBAL_LIST_INIT(keybinding_validkeys, list(
	"A",
	"B",
	"C",
	"D",
	"Q",
	"S",
	"W",
	"Z",
	"Tab",
	"Unbound" = "",
))

#define UPDATE_KEY(name, dir) \
	var/keybind = input(user, "Select [name] button", "Keybinding Preference") as null|anything in GLOB.keybinding_validkeys; \
	if(keybind) { \
		var/cur_key = movement_keys_inv[num2text(dir)]; \
		movement_keys -= cur_key; \
		movement_keys[keybind] = dir; \
		movement_keys_inv[num2text(dir)] = keybind; \
	};