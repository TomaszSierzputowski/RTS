extends Object
class_name Utils

enum MessageType {
	RESPONSE_OK = 0x01,
	ERROR_CONNECTION_ERROR = 0x0f,
	ERROR_TIMEOUT = 0x0e,
	ERROR_UNEXISTING_MESSAGE_TYPE = 0x0d,
	ERROR_TO_FEW_BYTES = 0x0c,
	
	SIGN_UP = 0x10,
	ERROR_LOGIN_ALREADY_IN_DATABASE = 0x1f,
	ERROR_INVALID_LOGIN = 0x1e,
	ERROR_INVALID_HASHED_PASSWORD = 0x1d,
	ERROR_INVALID_SALT = 0x1c,
	ASK_FOR_SALT = 0x11,
	ERROR_UNEXPECTED_SALT = 0x1b,
	ERROR_LOGIN_NOT_IN_DATABASE = 0x1a,
	SALT = 0x12,
	HASHED_PASSWORD = 0x13,
	
	PREPARE_GAME = 0x20,
	TOKEN_AND_KEY = 0x21,
	ERROR_UNEXPECTED_TOKEN_AND_KEY = 0x2f,
	ERROR_CANNOT_AUTHORISE_UDP = 0x2e,
	GAME_CANCELED = 0x2d,
	
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
