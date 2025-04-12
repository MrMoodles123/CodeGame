extends Node

const SWLocalFileStorage = preload("res://addons/silent_wolf/utils/SWLocalFileStorage.gd")
const SWUtils = preload("res://addons/silent_wolf/utils/SWUtils.gd")
const SWLogger = preload("res://addons/silent_wolf/utils/SWLogger.gd")
const UUID = preload("res://addons/silent_wolf/utils/UUID.gd")

signal sw_login_complete
signal sw_logout_complete
signal sw_registration_complete
signal sw_registration_user_pwd_complete
signal sw_email_verif_complete
signal sw_resend_conf_code_complete
signal sw_session_check_complete
signal sw_request_password_reset_complete
signal sw_reset_password_complete
signal sw_get_player_details_complete

var tmp_username = null
var logged_in_player = null
var logged_in_player_email = null
var logged_in_anon = false
var sw_access_token = null
var sw_id_token = null

var RegisterPlayer = null
var VerifyEmail = null
var ResendConfCode = null
var LoginPlayer = null
var ValidateSession = null
var RequestPasswordReset = null
var ResetPassword = null
var GetPlayerDetails = null

# wekrefs
var wrRegisterPlayer = null
var wrVerifyEmail = null
var wrResendConfCode = null
var wrLoginPlayer = null
var wrValidateSession = null
var wrRequestPasswordReset = null
var wrResetPassword = null
var wrGetPlayerDetails = null

var login_timeout = 0
var login_timer = null

var complete_session_check_wait_timer


func get_player_details(player_name: String) -> Node:
	var prepared_http_req = SilentWolf.prepare_http_request()
	GetPlayerDetails = prepared_http_req.request
	wrGetPlayerDetails = prepared_http_req.weakref
	GetPlayerDetails.request_completed.connect(_on_GetPlayerDetails_request_completed)
	SWLogger.info("Calling SilentWolf to get player details")
	var payload = { "game_id": SilentWolf.config.game_id, "player_name": player_name }
	var request_url = "https://api.silentwolf.com/get_player_details"
	SilentWolf.send_post_request(GetPlayerDetails, request_url, payload)
	return self


func _on_GetPlayerDetails_request_completed(result, response_code, headers, body) -> void:
	var status_check = SWUtils.check_http_response(response_code, headers, body)
	SilentWolf.free_request(wrGetPlayerDetails, GetPlayerDetails)
	
	if status_check:
		var json_body = JSON.parse_string(body.get_string_from_utf8())
		var sw_result: Dictionary = SilentWolf.build_result(json_body)
		if json_body.success:
			SWLogger.info("SilentWolf get player details success: " + str(json_body.player_details))
			sw_result["player_details"] = json_body.player_details
		else:
			SWLogger.error("SilentWolf get player details failure: " + str(json_body.error))
		sw_get_player_details_complete.emit(sw_result)


func get_anon_user_id() -> String:
	var anon_user_id = OS.get_unique_id()
	if anon_user_id == '':
		anon_user_id = UUID.generate_uuid_v4()
	print("anon_user_id: " + str(anon_user_id))
	return anon_user_id

