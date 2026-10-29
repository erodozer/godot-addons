# Multimesh Bake

Introduces a utility node extending MultiMeshInstance3D that bakes all MeshInstance3D children into a MultiMesh.

Designed as a workaround to allow for manually placing instances within the Editor, instead of only allowing for
randomized scatter or runtime code.  Gives users the ability to hand craft their levels with artistic intent,
while benefitting from batched rendering of models that only need visual representation.

# How-to Use

<img width="800" height="541" alt="video" src="https://github.com/user-attachments/assets/2480c5dc-8f7f-4585-ba6c-347751842fc7" />

The new BakableMultiMeshInstance3D node can be added to any scene, and treated as a standard MultiMeshInstance3D.

To `Bake` use the available button in the inspector when selecting the BakeableMultiMeshInstance3D.
This action will recursively fetch all MeshInstance3D children, capture their transformations relative to the MultiMeshInstance3D,
and record its data into the MultiMesh, then remove all children.  Any non-MeshInstance3D nodes will be deleted in the process as well.

It is expected that all children reference the same Mesh.  If more than one mesh is detected across the children, baking will fail.

Meshes can also be appended after Baking by simply adding more children with the same type and rebaking.

`Unbaking` allows you to restore all instances and their transformations into MeshInstance3D children.  Due to the destructive nature
of baking, only visual instances can be created.  It can not recreate the nested structures or non-MeshInstance3D nodes that may have been originally present.
This allows you to make adjustments after baking, and then rebake to regain performance benefits.
