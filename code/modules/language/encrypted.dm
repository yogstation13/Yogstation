/datum/language/encrypted
	name = "Encrypted"
	desc = "Certain members of Central Command have special masks to encrypt their voice to sound incomprehensible to anyone listening in."
	key = "d"
	default_priority = 110 // Forced over common (100)
	flags = TONGUELESS_SPEECH | LANGUAGE_HIDE_ICON_IF_NOT_UNDERSTOOD
	icon_state = "codespeak"
	syllables = list( // https://pinetools.com/random-string-generator
		"vAaZFM", "qPxHyP", "KSfLAM", "nhYvzc", "QuJuDc", "aLFtXU", "AzcRaf", "FHpAuQ", "xWqMkq", "xXFnCk", "MaLgvR", "kLSJMn", "rVyaJj", "MRbWfD", "QQuuzX", "dZFzUN", "RLRXCj", "RbGXAy", "LgUVQW", "UrEiSQ",
		"VSrbFj", "VGjJmz", "mgvpRU", "jqtEHH", "YrPkke", "BbuJPj", "ApMcHg", "PRyMYw", "QvLWfZ", "jFQZpY", "vYJbZe", "QNDpiS", "ZYvkKa", "awvNqR", "LZpeHt", "TWGvcN", "fKfUpp", "GLtdCu", "kRaXpm", "ZeNMkZ",
		"qufbaV", "vPMqcg", "bjbSWA", "rZEqPu", "dgVjZb", "aGPyFm", "mBFHDw", "iRNEZb", "bNZcVB", "HYNfgJ", "EfzUag", "yLCjJm", "paWHQq", "DVkTBc", "dtrSwD", "YkSdNR", "jyqZeh", "PUPJmp", "mhLKjM", "AQVSqJ"
	)
