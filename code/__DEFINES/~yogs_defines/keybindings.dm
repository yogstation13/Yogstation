GLOBAL_LIST_INIT(keybinding_validkeys, list(
	"A",
	"B",
	"C",
	"D",
	"E",
	"F",
	"G",
	"H",
	"I",
	"J",
	"K",
	"L",
	"M",
	"N",
	"O",
	"P",
	"Q",
	"R",
	"S",
	"T",
	"U",
	"V",
	"W",
	"X",
	"Y",
	"Z",
	"Unbound", // this is broken fix me (:
))

#define BUTTON_KEY(name, id, dir) \
	button = movement_keys_inv[num2text(dir)]; \
	button_bound = TRUE; \
	if(!button || button == "") \
		button_bound = FALSE; \
	dat += "<b>[name]:</b> <a href='?_src_=prefs;preference=keybinding_[id];task=input' [button_bound ? "" : "style='color:red'"]>[button_bound ? button : "Unbound"]</a><br>";

#define UPDATE_KEY(name, dir) \
	if("keybinding_" + name) { \
		var/keybind = input(user, "Select [name] button", "Keybinding Preference") as null|anything in GLOB.keybinding_validkeys; \
		if(keybind) { \
			var/cur_key = movement_keys_inv[num2text(dir)]; \
			movement_keys -= cur_key; \
			movement_keys[keybind] = dir; \
			refresh_keybindings(); \ // "uh this looks retarded" - This is calculated when its changed to minimize lag caused by the input SS
		}; \
	};