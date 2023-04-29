# godot-tonemapper

Basic screenspace LUT based one dimensional tone mapper.  Used in A:\dventure to provide luminosity based paletting swapping.

## Usage

Add the ToneMap.tscn to your singletons for it to affect your entire project, or in a specific location in your scene tree to affect only a select amount of the viewport.
You may have multiple tonemaps attached to the Node if you desire to support palette cycling.  The package comes with 4 example palettes to test with.

You will need to resize the BackBufferCopy node to equal your desired viewport's target resolution.

## Input Binding

Included is palette cycling support using an input binding of name `ui_palette_cycle`.
