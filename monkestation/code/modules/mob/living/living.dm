// This adds extra overhead to getting `lying_angle` directly but doing so upsets SpacemanDMM as it's set to protected
/mob/living/proc/get_lying_angle()
	return lying_angle
