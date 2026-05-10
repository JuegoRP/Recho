extends Node

var music_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music"
	add_child(music_player)
	
	sfx_player = AudioStreamPlayer.new()
	sfx_player.bus = "SFX"
	add_child(sfx_player)

func play_music(stream_path: String, fade_time: float = 1.0) -> void:
	var stream = load(stream_path)
	if music_player.stream == stream:
		return
		
	if music_player.playing:
		var tween = create_tween()
		tween.tween_property(music_player, "volume_db", -80, fade_time)
		await tween.finished
		
	music_player.stream = stream
	music_player.volume_db = 0
	music_player.play()

func play_sfx(stream_path: String) -> void:
	var stream = load(stream_path)
	var p = AudioStreamPlayer.new()
	add_child(p)
	p.stream = stream
	p.bus = "SFX"
	p.play()
	p.finished.connect(p.queue_free)
