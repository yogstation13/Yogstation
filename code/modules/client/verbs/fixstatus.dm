/client/verb/fixstatpanel()
	set category = "OOC"
	set name = "Fix Status Panel"
	set desc = "Resets the status panel"

    src << browse(file('html/statbrowser.html'), "window=statbrowser")