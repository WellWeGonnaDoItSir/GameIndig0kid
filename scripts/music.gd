class_name MusicDirector
extends AudioStreamPlayer

# Assign an original/licensed Indig0kid stream in a future scene or call play_track.
# Deliberately silent until a soundtrack is supplied; no third-party recordings.
func play_track(track: AudioStream, fade_seconds: float = 2.0) -> void:
	if track == null:
		return
	stream = track
	volume_db = -40
	play()
	create_tween().tween_property(self, "volume_db", -12.0, fade_seconds)
