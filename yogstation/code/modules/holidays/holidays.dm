/datum/holiday
	var/list/lobby_music = null // list of youtube URLs for lobby music to use during this holiday

/datum/holiday/october_revolution
	lobby_music = list(
		"https://www.youtube.com/watch?v=U06jlgpMtQs", // the USSR anthem
		"https://www.youtube.com/watch?v=x2YlbiyiuMc", // Polyushka Polye
		"https://www.youtube.com/watch?v=cW38y4AFGyI", // Let's Go
		"https://www.youtube.com/watch?v=zgKazTrhXmI", // Red Army is the Strongest
		"https://www.youtube.com/watch?v=Q_iIeFWJszY", // Shchors' Song
		"https://www.youtube.com/watch?v=maYCStVzjDs",  // Sacred War
		"https://www.youtube.com/watch?v=LYo9mIo54Vs" // Red Alert 3 theme
		)

/datum/holiday/labor
	lobby_music = list(
		"https://www.youtube.com/watch?v=UXKr4HSPHT8", // Internationale - german
		"https://www.youtube.com/watch?v=t8EMx7Y16Vo", // Internationale - russian
		"https://www.youtube.com/watch?v=lyfhs42mdyA", // Internationale - japanese
		"https://www.youtube.com/watch?v=5DTbashsKic" // Internationale - english
		)

/datum/holiday/spess
	lobby_music = list(
		"https://www.youtube.com/watch?v=sOM4MpN-ju0", // Glory to those who look forward
		"https://www.youtube.com/watch?v=ncx4x8rvrQU", // cosmonaut anthem
		"https://www.youtube.com/watch?v=KUwN_QaZnEE", // Before the long journey
		"https://www.youtube.com/watch?v=ckNIMPQoBPw" // And on mars there will be apple blossoms
		)

/datum/holiday/nichday/celebrate()
	name = "Nichlas Appreciation Day"
	begin_day = 2
	begin_month = NOVEMBER
	drone_hat = /obj/item/clothing/head/helmet/space/syndicate
	lobby_music = list(
		"https://www.youtube.com/watch?v=IHgvavOWzD8" // HoI4 theme
		)

/datum/holiday/nichday/greet()
	return "Have a merry Nichlas Appreciation Day! Be sure to @ Nichlas on the Discord and tell him your good wishes!"

/datum/holiday/nichday/getStationPrefix()
	return pick("Nichlas","Headcoder","Simonset","Dansk")
