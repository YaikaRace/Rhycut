extends Node

func create_stream_from_bytes(bytes: PackedByteArray) -> AudioStream:
	if bytes.is_empty(): 
		return null
	var header_4 = bytes.slice(0, 4).get_string_from_ascii()
	if header_4 == "OggS":
		return AudioStreamOggVorbis.load_from_buffer(bytes)
	if header_4 == "RIFF":
		return AudioStreamWAV.load_from_buffer(bytes)
	var header_3 = bytes.slice(0, 3).get_string_from_ascii()
	if header_3 == "ID3" or (bytes[0] == 0xFF and (bytes[1] & 0xF0) == 0xF0):
		return AudioStreamMP3.load_from_buffer(bytes)
	return null
