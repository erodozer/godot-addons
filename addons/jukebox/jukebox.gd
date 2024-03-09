"""
Jukebox.gd
@author erodozer <ero@erodozer.moe>

Ultra simple extension to AudioStreamPlayer for playlist capabilities.
Takes an array of File Paths instead of AudioStreams to save on memory.
Only the currently playing file will be in memory at one time.
This may result in buffering when the next track starts, so files
are loaded in the background.
"""

extends AudioStreamPlayer
class_name Jukebox

static func list_audio_tracks_in_directory(dir: String) -> Array:
	var fp = ProjectSettings.globalize_path(dir)
	var t = []
	for f in DirAccess.get_files_at(fp):
		match f.get_extension():
			"mp3", "ogg":
				t.append("%s/%s" % [fp, f])
	return t
	
static func create_from_directory(dir: String) -> Jukebox:
	var j = Jukebox.new()
	j.tracks = list_audio_tracks_in_directory(dir)
	return j
				
@export var tracks = []
@export var shuffle: bool = false

# keeps track of played tracks so that it doesn't double up
var _track_idx = 0
var _shuffle_history = []

func _ready():
	assert(len(tracks) > 0, "at least one audio track is required")
	assert(tracks.all(func (x): return x is String and (x.is_absolute_path() or x.is_relative_path())), "tracks must be defined as filepaths")
	tracks = tracks.map(func (x): return ProjectSettings.globalize_path(x))
	_shuffle_history = tracks.duplicate()
	_shuffle_history.shuffle()
	await _load_stream(_shuffle_history[0] if shuffle else tracks[0])
	finished.connect(next_track)
	
func _load_stream(fp):
	var loading = ResourceLoader.load_threaded_request(fp)
	if loading == OK:
		while ResourceLoader.load_threaded_get_status(fp) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			await get_tree().process_frame
		if ResourceLoader.load_threaded_get_status(fp) == ResourceLoader.THREAD_LOAD_LOADED:
			stream = ResourceLoader.load_threaded_get(fp)
	
func next_track():
	_track_idx += 1
	if _track_idx >= len(tracks):
		_track_idx = 0
		_shuffle_history.shuffle()
	
	var next = _shuffle_history[_track_idx] if shuffle else tracks[_track_idx]
	await _load_stream(next)
	play()
