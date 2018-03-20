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
	if("keybinding_name") { \
		var/keybind = input(user, "Select [name] button", "Keybinding Preference") as null|anything in GLOB.keybinding_validkeys; \
		if(keybind) { \
			var/cur_key = movement_keys_inv[num2text(dir)]; \
			movement_keys -= cur_key; \
			movement_keys[keybind] = dir; \
			movement_keys_inv[num2text(dir)] = keybind; \
		}; \
	};

#define BUTTON_KEY(name, id, dir) \
	dat += "<b>name:</b> <a href='?_src_=prefs;preference=keybinding_[id];task=input'>[movement_keys_inv[num2text(dir)]]</a><br>";