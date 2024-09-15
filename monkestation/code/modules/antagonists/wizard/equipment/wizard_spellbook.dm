/obj/item/spellbook/proc/adjust_charge(adjust_by)
	log_spellbook("[src] charges adjusted by [adjust_by]. [usr ? "user: [usr]." : ""]")
	uses += adjust_by
	return TRUE
