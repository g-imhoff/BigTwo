extends Node

static func hash_password(password: String) -> String:
	var context = HashingContext.new()
	context.start(HashingContext.HASH_SHA256)
	context.update(password.to_utf8_buffer())
	var hash = context.finish()
	return hash.hex_encode()
	

# Called when the node enters the scene tree for the first time.
