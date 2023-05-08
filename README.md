# Description

Utilities for adding and managing metadata in classes and blocks.

# Details

Metadata is structured information about SystemVerilog entities.
Metadata may be added to sub-classes of `uvm_object` and to procedural `begin-end` blocks.
These utilities add metadata that is accessible from within the simulation.
Run test `print_meta_catalog` to output all the metadata to a YAML file which can be processed offline.
Add metadata like this to classes and blocks almost anywhere in the design.
At the bottom of the main package there are templates you can copy and paste into other files.
Since metadata is part of the source code, it must be syntactically correct so it will compile.
Pay careful attention to syntax, especially punctuation.
This is the metadata for this project.
That makes this meta-metadata.
