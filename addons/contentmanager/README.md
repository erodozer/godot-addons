# Content Management System

Introduces a new system to Godot that streamlines mass management of content associated resources within a project.

<img width="1024" alt="CMS screenshot" src="https://github.com/user-attachments/assets/552a2a54-11e0-40ed-8a08-09ef12acbec4" />

### Why was this made?

This was created based on common patterns I practiced across several games with extensive amounts of resources.
After going back and forth between managing files manually and using the tight inspector UI shared with all other types of resources, having a dedicated view for managing specifically resources associated with my games became highly desireable.  I craved a more dedicated, centralized UI for managing them, similar to tooling like RPG Maker provides.

Similar productivity addons, such as [Pandora](https://github.com/bitbrain/pandora), exist but I found they were not suitable for my preferred workflow. While feature rich, they tend to operate counter-intuitively, by working in opposition to Godot's own powerful Resource system and Editor tooling.

Instead of introducing complex new technologies, such as databases, or storing everything in a large flat JSON file, this manager acts as a tool for organizing Godot resource files (tres) that inherit a common base class.  This system embraces core patterns present in Godot through leveraging its built-in memory management systems and extensibility.

### Requirements

- Godot >= 4.7

## Asset Management

Content by convention is stored within subdirectories of `res://content`.

The `ContentManager` singleton added by the plugin exposes functions for fetching all assets of a type, which is useful for driving dynamic UIs and procedural generation.

To list files for a type, you use the StringName of the resource class name
```gdscript
var filepaths = ContentManager.list_content(&"Weapon")
```

Similarly, you can load the entire directory in memory, which is useful for driving dynamic UIs and procedural generation, such as an NPC shop.

```gdscript
var resources = ContentManager.load_content(&"Weapon")
```

### ContentResource

As we leverage Resources as the backbone of the CMS, all resource types are simply defined through scripts.  In particular, we only manage types that extend the `ContentResource` class, and conventionally those scripts are stored in `res://content/_types`.  Through the UI, you can quickly create new resource types that extend the required class.

ContentManager depends on the resource type being registered within the ClassDB.  As such, all ContentResource implementations must have a `class_name` defined, as well as tagged with `@tool` in order to appear in the Editor.

The abstract function `category()` must be implemented on the Resource class.  This defines the known path of resource files, and should be unique for each of your managed types.  The path is always relative to the base `res://content` directory.

You can also customize the icon of your resource category in the Tree view by overriding `editor_icon()` to return a different Texture.

```gdscript
@tool
class_name Weapon extends ContentResource

@export_range(1, 100) var attack: int = 1
@export_range(1, 9999) var cost: int = 1

func category():
    return "equipment/weapon"
```


#### Resource Editors

By default, the editor for each asset type is Godot's default Inspector form.  This works for many simple resource types, as the Inspector is already full featured.  This means you can also have the full power of having computed fields or dynamic enums/dropdowns based on overriding virtual property functions such as `_validate_property` and `_get_property_list`.

By default, ContentResource types prefer to hide any Editor metadata fields under the `resource` namespace, such as `resource_name` and `resource_path` to discourage editing them through the UI.

If you wish to use an alternative editor instead of the built-in Inspector, you can supply your own Control by overriding the `editor()` function in your resource script.


### The cm.db file

Traversing `res://` paths in exported projects is not possible, so instead a binary look up table is encoded to `res://content/cm.db` and read at runtime.  It's important within your export project template to include this file.

`cm.db` is described using the format

Header
- Per Type
  - 4 byte: representing the starting byte position of the file list per ContentResource type

Body
- Per file Record
  - 1 byte: length of utf-8 string
  - N byte: utf-8 buffer, representing the filename of the resource

Filenames are encoded without path or extension, as both are deterministic at runtime through the associated resource class

The Type index is based on its position in the class db, which is an ordered index with consistent determinism.  This detail is invisible to users of ContentManager, in scripting you only need to be aware of the class name in order to list resources you need.

Unlike more human readable formats like JSON, this approach was chosen to avoid needing to have the full tree in memory at any time.
