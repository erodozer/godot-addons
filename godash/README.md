# godash

Collection of basic utilities that I find useful for game development that overcomes some of the missing features of gdscript.

Library and name inspired by lodash for javascript.

## Usage

Preload the godash.gd file into any script that you need it.  All functions are stateless and static, so nothing needs to be instantiated to use the utilities.

## Examples

### Dynamic resource based content

```gdscript
# Content.gd

extends Node

const godash = preload("res://node_modules/@nhydock/godot-lodash/godash.gd")

var Enemies = []
var Items = []

func _ready():
  Items = godash.load_dir("res://content", "item.tres", true).values()
  Enemies = godash.load_dir("res://content", "enemy.tres", true).values()

func get_item(item_id):
  for i in Items:
    if i.id == item_id:
      return i
  return null
```

```gdscript
# Battle.gd

var formation = []
func start():
  for i in range(randi() % 5):
    formation.append(
      godash.rand_choice(Content.Enemies)
    )

func victory():
  for enemy in formation:
    Player.xp += enemy.xp
    
    # enemies have a weighted inventory of what they can drop
    var drop = godash.rand_choice(enemy.items)
    Player.pickup_item(drop)
```

```gdscript
# ShopUI.gd

func make_item_label(item_id):
  var item = Content.get_item(item_id)
  if item == null:
    return

  var label = Label.new()
  label.text = item.name
  add_child(label)
```