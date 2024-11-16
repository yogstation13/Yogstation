// eww
/proc/overwrite_field_if_available(datum/record/base, datum/record/other, field_name)
	if(!istype(base) || !istype(other))
		return
	if(other.vars[field_name])
		base.vars[field_name] = other.vars[field_name]
