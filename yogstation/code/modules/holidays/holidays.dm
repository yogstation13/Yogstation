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

/datum/holiday/oakday
	name = "Oak's Birthday"
	begin_day = 5
	begin_month = JULY
	drone_hat = /obj/item/clothing/head/hardhat/cakehat

/datum/holiday/oakday/getStationPrefix()
	return pick("Gondola","Finnish","Council")
	
/datum/holiday/oakday/greet()
	return "Happy birthday to Oakboscage!"
