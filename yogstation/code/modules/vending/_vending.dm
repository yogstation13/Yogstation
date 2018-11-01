/obj/machinery/vending/proc/GetIconForProduct(datum/data/vending_product/P)
	if(GLOB.vending_cache[P.product_path])
		return GLOB.vending_cache[P.product_path]
	var/product = new P.product_path()
	GLOB.vending_cache[P.product_path] = icon2base64(getFlatIcon(product, no_anim = TRUE))
	qdel(product)
	return GLOB.vending_cache[P.product_path]