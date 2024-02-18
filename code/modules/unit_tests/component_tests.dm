/datum/unit_test/component_duping/Run()
	var/list/bad_dms = list()
	var/list/bad_dts = list()
	for(var/datum/component/comp as anything in typesof(/datum/component))
		if(!isnum(initial(comp.dupe_mode)))
			bad_dms += comp
		var/dupe_type = initial(comp.dupe_type)
		if(dupe_type && !ispath(dupe_type))
			bad_dts += comp
	if(length(bad_dms) || length(bad_dts))
		TEST_FAIL("Components with invalid dupe modes: ([bad_dms.Join(",")]) ||| Components with invalid dupe types: ([bad_dts.Join(",")])")
