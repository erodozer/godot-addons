@tool
extends Control
class_name ContentResourceEditor

var record: ContentResource

func _ready():
	%Name/Value.text_changed.connect(
		func (text):
			record.resource_name = text
	)
		
func edit(resource: ContentResource):
	%Name/Value.text = record.resource_name
