/datum/holiday
	var/list/lobby_music = null // list of youtube URLs for lobby music to use during this holiday

/datum/holiday/october_revolution
	lobby_music = list(
		"https://www.youtube.com/watch?v=U06jlgpMtQs", // the USSR anthem
		"https://www.youtube.com/watch?v=x2YlbiyiuMc", // Polyushka Polye
		"https://www.youtube.com/watch?v=cW38y4AFGyI", // Let's Go
		"https://www.youtube.com/watch?v=zgKazTrhXmI", // Red Army is the Strongest
		"https://www.youtube.com/watch?v=Q_iIeFWJszY", // Shchors' Song
		"https://www.youtube.com/watch?v=8iAoibAgAvM", // Swallowing Dust
		"https://www.youtube.com/watch?v=zmI2yDAyWYI", // No Motherland Without You
		"https://www.youtube.com/watch?v=rA1LFD6xfi4", // December's Concert - Footsteps
		"https://www.youtube.com/watch?v=maYCStVzjDs",  // Sacred War
		"https://www.youtube.com/watch?v=LYo9mIo54Vs" // Red Alert 3 theme
		)

/datum/holiday/labor
	lobby_music = list(
		"https://www.youtube.com/watch?v=UXKr4HSPHT8", // Internationale - german
		"https://www.youtube.com/watch?v=t8EMx7Y16Vo", // Internationale - russian
		"https://www.youtube.com/watch?v=lyfhs42mdyA", // Internationale - japanese
		"https://www.youtube.com/watch?v=5DTbashsKic", // Internationale - english (alistair hulett)
		"https://www.youtube.com/watch?v=PPExpmtdMEw"  // Internationale - english (billy bragg)
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
	lobby_music = list(
		"https://www.youtube.com/watch?v=lM2Lr3NqUcg", // Maamme (Finnish Anthem)
		"https://www.youtube.com/watch?v=OEtyScs6djU", // Vapaussoturin Valloituslaulu
		"https://www.youtube.com/watch?v=uMszu_VgMfY", // Säkkijärven Polkka
		"https://www.youtube.com/watch?v=Qn16z3fn-j4", // Kremlin Uni
		"https://www.youtube.com/watch?v=d91FuK11QvU", // Jääkärimarssi
		"https://www.youtube.com/watch?v=8IaUXefAsCU", // The Song of the Pioneers
		"https://www.youtube.com/watch?v=PJR3xTdbXH8" // Nyet Molotov
		)

/datum/holiday/oakday/getStationPrefix()
	return pick("Gondola","Finnish","Council","Oakreich","Perkele")
	
/datum/holiday/oakday/greet()
	return "Happy birthday to Oakboscage!"

/datum/holiday/yogsday
	name = "Yogstation Day"
	begin_day = 11
	begin_month = OCTOBER
	lobby_music = list(
		"https://www.youtube.com/watch?v=bJAvwllkDjo", // yogscast outro
		"https://www.youtube.com/watch?v=F2K6wE7Wsr0" // yogs old intro
		)
	
/datum/holiday/yogsday/getStationPrefix()
	return pick("Revolution","Hardy","Xantam","Ross","Spl","UtahClock","Hitman")
	
/datum/holiday/yogsday/greet()
	return "Happy founding of Yogstation day!"
	
/datum/holiday/halflife
	name = "Half-Life Release Day"
	begin_day = 19
	begin_month = NOVEMBER
	lobby_music = list(
		"https://www.youtube.com/watch?v=eU32H6FpO2I", // Hazardous Environments (1)
		"https://www.youtube.com/watch?v=AIIm5wtE2uM", // Military Precision (1)
		"https://www.youtube.com/watch?v=meynBFQW7M8", // Diabolical Adrenaline Guitar (1)
		"https://www.youtube.com/watch?v=BcFnS3bCwpI", // Brane Scan (2)
		"https://www.youtube.com/watch?v=dvKgMWNjRk0", // Guard Down (2)
		"https://www.youtube.com/watch?v=s22XqGkuIFw", // Sector Sweep (2)
		"https://www.youtube.com/watch?v=BLJZnJe7KgU", // Ending Triump (Alyx)
		"https://www.youtube.com/watch?v=d6ZZJp2nfCc" // Vault Mirror Room (Alyx)
		)
	
/datum/holiday/halflife/getStationPrefix()
	return pick("Black-Mesa","Combine","Overwatch","Freeman","Vortigaunt","Resistance","Vance","HECU","G-Man","Borealis")
	
/datum/holiday/halflife/greet()
	return "Happy Half-Life Release Day!"
