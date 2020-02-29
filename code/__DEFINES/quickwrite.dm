#define QUICKWRITE "quickwrite.dll"

#define QUICKWRITE_OPEN(filename) call(QUICKWRITE, "open_file")(filename)
#define QUICKWRITE_CLOSE(filename) call(QUICKWRITE, "close_file")(filename)
#define QUICKWRITE_WRITE(file, data) call(QUICKWRITE, "write_file")(file, data)
#define QUICKWRITE_CLOSE_ALL call(QUICKWRITE, "close_all")()

/proc/_quickwrite_check(res)
	if(copytext(res, 1, 6) == "ERROR")
		world.log << "<font color='red'><b>QUICKWRITE: [res]</b></span>"
		return FALSE
	return TRUE

/proc/quickwrite_open(file, data)
	return _quickwrite_check(QUICKWRITE_OPEN(file))

/proc/quickwrite_close(file, data)
	return _quickwrite_check(QUICKWRITE_CLOSE(file))

/proc/quickwrite_write(file, data)
	return _quickwrite_check(QUICKWRITE_WRITE(file, data))

/proc/quickwrite_close_all()
	QUICKWRITE_CLOSE_ALL
