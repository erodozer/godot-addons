# Simple Content Management System

Introduces a new dedicated panel to Godot's Editor to streamline mass management of various content associated resource types within a project.

Instead of introducing complex new technologies, such as databases and different format parsers, this manager acts as a tool for organizing Godot resource files (tres) by providing a centralized UI for editing and creating new resource instances.

<img width="1024" alt="image" src="https://github.com/user-attachments/assets/acdea070-ae45-4201-9da3-ff6766395e44" />

### Why was this made?

This was created based on common patterns I practiced across several games with extensive amounts of resources.
After going back and forth between managing files manually and using the tight inspector UI shared with all other types of resources, having a dedicated view for managing specifically resources associated with my games became highly desireable.  I craved a more dedicated, centralized UI for managing them, similar to tooling like RPG Maker provides.  Hence this simple, integrated approach to managing content resources.

### Requirements

Godot >= 4.4

## Asset Management

Content by convention is stored within subdirectories of `res://content`.
The `ContentManager` singleton added by the plugin exposes functions for fetching all assets of a type, which is useful for driving dynamic UIs and procedural generation.

## Adding a new ContentResource

The content manager UI only manages types that extend the ContentResource class.
Due to limitations of GDScript's inheritance and limited reflection capabilities, it's important that your custom resource has a `class_name` defined.
It is also necessary for the script to have the `@tool` metadata hint in order for the editor UI to call any functions on it.

Two functions should be exposed on the type for the ContentManager to function properly

`editor()` exposes a node to be used by the editor UI
`category()` defines the name of the subdirectory under `res://content` that the assets should be stored

The editor will name and manage files based on the internal `resource_name` attribute of godot Resources.

## Resource Editors

By default, the editor for each asset type is Godot's default Inspector form.  This works for many simple resource types, as the Inspector is already full featured.

If you wish to customize the editor, you can either customize the inspector according to godot's Property Hint, or for something more capable you can supply a custom scene for your own hand crafted forms.  To do this, simply return an instance of your form by overriding the `editor()` function in your custom resource
