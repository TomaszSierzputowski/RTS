extends Object
class_name Utils

enum MessageType {
	# Peer.get() returns 0 if disconnected
	ERROR_DISCONNECTED = 0x00,
	
	# Common messages
	RESPONSE_OK = 0x01,
	ERROR_CONNECTION_ERROR = 0x0f,
	ERROR_TIMEOUT = 0x0e,
	ERROR_UNEXISTING_MESSAGE_TYPE = 0x0d,
	ERROR_TO_FEW_BYTES = 0x0c,
	NO_MORE_FREE_SEATS = 0x0b,
	
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
	ERROR_NOT_LOGGED_IN = 0x3e,
	ERROR_NO_MORE_FREE_ROOMS = 0x3d,
	
	# Player in game actions messages
	BUILD = 0x80,
	ERROR_CANNOT_BUILD = 0x8f,
	SUMMON = 0x81,
	ERROR_CANNOT_SUMMON = 0x8e,
	MOVE = 0x82,
	ERROR_CANNOT_MOVE = 0x8d,
	ATTACK = 0x83,
	ERROR_CANNOT_ATTACK = 0x8c,
	ERROR_INVALID_HMAC_ERROR = 0x88,
	
	# Server in game info messages
	POS_CHANGE = 0x90,
	POS_CHANGE_OPP = 0x91,
	HP_CHANGE = 0x92,
	HP_CHANGE_OPP = 0x93,
	POS_HP_CHANGE = 0x94,
	POS_HP_CHANGE_OPP = 0x95,
	SUMMONED_BUILT = 0x96,
	SUMMONED_BUILT_OPP = 0x97,
	APPEARED = 0x98,
	DIED_DESTROYED = 0x99,
	DIED_DESTROYED_OPP = 0x9a,
	DISAPPEARED = 0x9b,
	ERROR_CHANGE_OF_NONEXISTING_ENTITY = 0x9f,
	
	# Debug messages
	JUST_STRING = 0xf0,
	TEST_BYTE_BY_BYTE = 0xf1
}

enum EntityType {
	CHARACTER = 0xfe,
	BUILDING = 0xff,
	
	
	MAIN_BASE = 0x00,
	MINE_NO = 0x01,
	MINE_YES = 0x02,
	TRIANGLE_NO = 0x03,
	TRIANGLE_YES = 0x04,
	SQUARE_NO = 0x05,
	SQUARE_YES = 0x06,
	PENTAGON_NO = 0x07,
	PENTAGON_YES = 0x08,
	
	
	WORKER = 0x10,
	TRIANGLE = 0x11,
	SQUARE = 0x12,
	PENTAGON = 0x13
}

const salt_len := 11 #TBA
const pass_len := -1 #TBA
const token_len := 64
const key_len := 64
const hmac_len := 32

static var crypto := Crypto.new()
const hash_type := HashingContext.HashType.HASH_SHA256
