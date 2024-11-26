extends Object
class_name Utils

enum MessageType {
	# Common messages
	RESPONSE_OK = 0x01,
	ERROR_CONNECTION_ERROR = 0x0f,
	ERROR_TIMEOUT = 0x0e,
	ERROR_UNEXISTING_MESSAGE_TYPE = 0x0d,
	ERROR_TO_FEW_BYTES = 0x0c,
	
	# UDP authorisation while connecting messages
	TOKEN_AND_KEY = 0x11,
	ERROR_UNEXPECTED_TOKEN_AND_KEY = 0x1f,
	ERROR_CANNOT_AUTHORISE_UDP = 0x1e,
	
	# Login system messages
	SIGN_UP = 0x20,
	ERROR_LOGIN_ALREADY_IN_DATABASE = 0x2f,
	ERROR_INVALID_LOGIN = 0x2e,
	ERROR_INVALID_HASHED_PASSWORD = 0x2d,
	ERROR_INVALID_SALT = 0x2c,
	ASK_FOR_SALT = 0x21,
	ERROR_UNEXPECTED_SALT = 0x2b,
	ERROR_LOGIN_NOT_IN_DATABASE = 0x2a,
	SALT = 0x22,
	HASHED_PASSWORD = 0x23,
	
	# Starting game messages
	PREPARE_GAME = 0x30,
	GAME_STARTED = 0x31,
	GAME_CANCELED = 0x3f,
	
	# Player in game actions messages
	BUILD = 0x80,
	ERROR_CANNOT_BUILD = 0x8f,
	SUMMON = 0x81,
	ERROR_CANNOT_SUMMON = 0x8e,
	MOVE = 0x82,
	ERROR_CANNOT_MOVE = 0x8d,
	ATTACK = 0x83,
	ERROR_CANNOT_ATTACK = 0x84,
	
	# Server in game info messages
	BOARD_STATE = 0x90,
	ERROR_INVALID_HMAC_ERROR = 0x9f,
	
	# Debug messages
	JUST_STRING = 0xf0,
	TEST_BYTE_BY_BYTE = 0xf1
}

const salt_len := 11 #TBA
const pass_len := -1 #TBA
const token_len := 64
const key_len := 64
const hmac_len := 32

static var crypto = Crypto.new()
const hash_type := HashingContext.HashType.HASH_SHA256
