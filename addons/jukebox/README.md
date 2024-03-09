# Jukebox

Lightweight audio manager for playing back a list of supported audio files.
Designed for games with radio-like audio, where it is desired to shuffle through many songs instead of looping a BGM.

## Usage

In place of an AudioStreamPlayer, use the new Jukebox node class.

Jukeboxes take an array of filepaths, not AudioStream resources.  A Jukebox does resource management for you by loading the streams in the background and only keeping the active stream in memory.  This helps keep the usage requirements low for games with lots of audio.

By default a Jukebox will play through the list in order.
When Shuffle is enabled, it will play in random order and not repeat any tracks until the entire playlist has been exhausted.

Convenience methods are also available for setting a Jukebox's track list programmatically by referencing a directory containing audio files, instead of explicitly listing them.

Jukeboxes on scene ready are required to have at least one audio track pointing to a real file in them.
