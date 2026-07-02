# godash

Collection of basic utilities that I find useful for game development that overcomes some of the missing features of gdscript.  Functions often may become deprecated as gdscript evolves as a language.

Library and name inspired by lodash for javascript.

## Usage

Preload the godash.gd file into any script that you need it.  All functions are stateless and static, so nothing needs to be instantiated to use the utilities.

You can load the root level `_.gd` file and access all modules through it, or preload specifically the tools you by loading modules directly.

## Examples

### Prepopulating factory with content resources

```gdscript
# Content.gd

extends Node

const _gd = preload("res://addons/godash/_.gd")

var Enemies = []
var Items = []

func _ready():
  Items = _gd.files.load_dir("res://content", "item.tres", true).values()
  Enemies = _gd.files.load_dir("res://content", "enemy.tres", true).values()

func get_item(item_id):
  for i in Items:
    if i.id == item_id:
      return i
  return null
```

## Loading specific module

```gdscript
# Battle.gd

const _gdrand = preload("res://addons/godash/modules/random.gd")

var formation = []
func start():
  for i in range(randi() % 5):
    formation.append(
      _gdrand.choice(Content.Enemies)
    )

func victory():
  for enemy in formation:
    Player.xp += enemy.xp
    
    # enemies have a weighted inventory of what they can drop
    var drop = _gdrand.choice(enemy.items)
    Player.pickup_item(drop)
```
