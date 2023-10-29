extends Gift

signal viewer_joined(name)
signal viewer_left(name)
signal status(status_id: STATUS)

enum STATUS {
	NONE,
	INIT,
	AUTH_START,
	AUTH_FILE_NOT_FOUND,
	CONNECTION_FAILED,
	CONNECTING,
	CONNECTED
}

var last_status: = STATUS.NONE

var setup_scene: PackedScene = preload("res://scenes/ui/setup.tscn")


func _ready() -> void:
	start()


func start() -> void:
	emit_status(STATUS.INIT)

	var config = ConfigManager.new().data

	if !config:
		emit_status(STATUS.AUTH_FILE_NOT_FOUND)
		get_tree().change_scene_to_packed(setup_scene)
		return

	client_id = config.twitch_auth.client_id
	client_secret = config.twitch_auth.client_secret
	var initial_channel = config.twitch_auth.initial_channel

	cmd_no_permission.connect(no_permission)
	chat_message.connect(on_chat)
	event.connect(on_event)

	# When calling this method, a browser will open.
	# Log in to the account that should be used.
	emit_status(STATUS.AUTH_START)
	await authenticate(client_id, client_secret)

	emit_status(STATUS.CONNECTING)
	var success = await(connect_to_irc())
	if (success):
		request_caps()
		join_channel(initial_channel)
		emit_status(STATUS.CONNECTED)
	else:
		emit_status(STATUS.CONNECTION_FAILED)

#	await(connect_to_eventsub())
	# Refer to https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/ for details on
	# what events exist, which API versions are available and which conditions are required.
	# Make sure your token has all required scopes for the event.
#	subscribe_event("channel.follow", 2, {"broadcaster_user_id": user_id, "moderator_user_id": user_id})

	# Adds a command with a specified permission flag.
	# All implementations must take at least one arg for the command info.
	# Implementations that recieve args requrires two args,
	# the second arg will contain all params in a PackedStringArray
	# This command can only be executed by VIPS/MODS/SUBS/STREAMER
#	add_command("test", command_test, 0, 0, PermissionFlag.NON_REGULAR)

	add_command("join", add_viewer)
	add_command("leave", remove_viewer)

	# These two commands can be executed by everyone
#	add_command("helloworld", hello_world)
#	add_command("greetme", greet_me)

	# This command can only be executed by the streamer
#	add_command("streamer_only", streamer_only, 0, 0, PermissionFlag.STREAMER)

	# Command that requires exactly 1 arg.
#	add_command("greet", greet, 1, 1)

	# Command that prints every arg seperated by a comma (infinite args allowed), at least 2 required
#	add_command("list", list, -1, 2)

	# Adds a command alias
#	add_alias("test","test1")
#	add_alias("test","test2")
#	add_alias("test","test3")

	# Now no "test" command is known

	# Send a chat message to the only connected channel (<channel_name>)
	# Fails, if connected to more than one channel.
#	chat("TEST")

	# Send a chat message to channel <channel_name>
#	chat("TEST", initial_channel)

	# Send a whisper to target user
#	whisper("TEST", initial_channel)


func emit_status(new_status: STATUS) -> void:
	status.emit(new_status)
	last_status = new_status

func on_event(type : String, data : Dictionary) -> void:
	match(type):
		"channel.follow":
			print("%s followed your channel!" % data["user_name"])

func on_chat(data : SenderData, msg : String) -> void:
	pass
#	%ChatContainer.put_chat(data, msg)

# Check the CommandInfo class for the available info of the cmd_info.
func command_test(cmd_info : CommandInfo) -> void:
	print("A")

func hello_world(cmd_info : CommandInfo) -> void:
	chat("HELLO WORLD!")

func streamer_only(cmd_info : CommandInfo) -> void:
	chat("Streamer command executed")

func no_permission(cmd_info : CommandInfo) -> void:
	chat("NO PERMISSION!")

func greet(cmd_info : CommandInfo, arg_ary : PackedStringArray) -> void:
	chat("Greetings, " + arg_ary[0])

func greet_me(cmd_info : CommandInfo) -> void:
	chat("Greetings, " + cmd_info.sender_data.tags["display-name"] + "!")

func list(cmd_info : CommandInfo, arg_ary : PackedStringArray) -> void:
	var msg = ""
	for i in arg_ary.size() - 1:
		msg += arg_ary[i]
		msg += ", "
	msg += arg_ary[arg_ary.size() - 1]
	chat(msg)

func add_viewer(cmd_info: CommandInfo) -> void:
	viewer_joined.emit(cmd_info.sender_data.tags["display-name"])

func remove_viewer(cmd_info: CommandInfo) -> void:
	viewer_left.emit(cmd_info.sender_data.tags["display-name"])
