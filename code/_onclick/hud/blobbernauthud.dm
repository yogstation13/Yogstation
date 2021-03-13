
/datum/hud/blobbernaut/New(mob/owner)
	..()

	blobpwrdisplay = new /atom/movable/screen/healths/blob/naut/core()
	infodisplay += blobpwrdisplay

	healths = new /atom/movable/screen/healths/blob/naut()
	infodisplay += healths
