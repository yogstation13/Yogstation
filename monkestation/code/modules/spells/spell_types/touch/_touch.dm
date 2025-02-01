/obj/item/melee/touch_attack
	/// If this touch attack is "dangerous" - this is used for martial arts bypassing intent checks.
	/// This should only be FALSE for benign / non-antag attacks, to prevent metagaming by randomly shock touching people to see if they have martial arts.
	var/dangerous = TRUE

/obj/item/melee/touch_attack/shock
	dangerous = FALSE
