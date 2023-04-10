extends Node3D

var BASEROW_API_KEY: String 
var baserow_http: HTTPRequest
var row_ids: Array[int]

func print_hello_world():
	print("Hello")

func print_home_env():
	print(OS.get_environment("PATH"))

func get_baserow_api_key():
	var key = OS.get_environment("BASEROW_API_KEY")
	if key.is_empty():
		print("The BASEROW_API_KEY is empty.")
	BASEROW_API_KEY = key

func fetch_baserow_llm_chat():
	baserow_http = HTTPRequest.new()
	baserow_http.request_completed.connect(Callable(self, "_on_fetch_baserow_llm_chat"))
	var custom_headers : PackedStringArray = ["Authorization: Token %s" % BASEROW_API_KEY]
	add_child(baserow_http)
	baserow_http.owner = owner
	baserow_http.request("https://api.baserow.io/api/database/rows/table/156287/?user_field_names=true&filter_Processed__equal=false&indlue=Processed&include=id", custom_headers, HTTPClient.METHOD_GET)


func _on_fetch_baserow_llm_chat_print(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	var json_string = body.get_string_from_utf8()
	if json_string.is_empty():
		return			
	var dict = JSON.parse_string(json_string)
	if dict == null:
		return
	print(dict)


func _on_fetch_baserow_llm_chat(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	var json_string = body.get_string_from_utf8()
	if json_string.is_empty():
		return			
	var dict = JSON.parse_string(json_string)
	if dict == null:
		return
	for row in dict.results:
		var id = row.id
		for connection in baserow_http.request_completed.get_connections():
			baserow_http.request_completed.disconnect(connection.callable)
		baserow_http.request_completed.connect(Callable(self, "_on_get_baserow_llm_chat"))
		var custom_headers : PackedStringArray = ["Authorization: Token %s" % BASEROW_API_KEY]
		baserow_http.request("https://api.baserow.io/api/database/rows/table/156287/%s/?user_field_names=true&include=Prompt" % id, custom_headers, HTTPClient.METHOD_GET)
		await baserow_http.request_completed

func _on_get_baserow_llm_chat(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	var json_string = body.get_string_from_utf8()
	if json_string.is_empty():
		return			
	var dict = JSON.parse_string(json_string)
	if dict == null:
		return
	print(dict)
