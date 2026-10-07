# After Image

Spawns 3D after images in your scene for dramatic movement effects

<img width="600" alt="afterimage" src="https://github.com/user-attachments/assets/252853d6-5350-43b6-aece-37075cc13638" />


## How-to Use

Create an AfterImage node in any scene and point it to a NodePath where the node and/or its children MeshInstance3D instances can be copied into an after image.

<img width="480" alt="image" src="https://github.com/user-attachments/assets/bab6b7ac-2479-4af6-9876-ecfeb5e43074" />

When the copier is Active, it will make new after image instances on a configured interval up to a set amount, and each instance will also fade away after a configured lifetime.  Memory is managed in a pool, creating an upper bound of how many instances may exist in the scene, as well as allowing for for effecient management and updating without having to worry about scene tree thrashing.
