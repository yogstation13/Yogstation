
GLOBAL_LIST_INIT(donator_verbs, list(
	/client/proc/cmd_donator_say,
	))
GLOBAL_PROTECT(donator_verbs)

/client/proc/add_donator_verbs()
	if(is_donator(src))
		add_verb(src, GLOB.donator_verbs)

/client/proc/remove_donator_verbs()
	remove_verb(src, GLOB.donator_verbs)
