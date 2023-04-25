// ===================================================================
// Macros
// ===================================================================

// Use these macros in your code to provide your metadata and register it with the metacatalog.
// See below for the list of possible metadata fields.
// Scroll to the bottom of this file for examples you can copy into your code.

`define CLASS_METADATA_NO_IMPL(s, m=_metadata) \
static meta_pkg::metadata_t m = meta_pkg::metacatalog::get().register_class_metadata(get_type(), type_id::get(), s, `__FILE__, `__LINE__);


`define CLASS_METADATA(s, m=_metadata) \
`CLASS_METADATA_NO_IMPL(s, m) \
static function meta_pkg::metadata_t get_class_metadata(); \
    `FUNCTION_METADATA('{ \
        description : "Returns the metadata for this class.", \
         \
        details : "This is a static function so it can be called on the class itself, e.g. `class::get_class_metadata()`.", \
         \
        attributes : "metadata", \
         \
        metaoptions : "do_not_register", \
         \
        string : "" \
    }, _fn_metadata) \
    return m; \
endfunction : get_class_metadata \
virtual function meta_pkg::metadata_t get_metadata(); \
    `FUNCTION_METADATA('{ \
        description : "Returns the metadata for this object.", \
         \
        details : "This is a virtual function so it can be called on an object or polymorphic interface class handle, e.g. `obj.get_metadata()` or `handle.get_metadata()`.", \
         \
        attributes : "metadata", \
         \
        metaoptions : "do_not_register", \
         \
        string : "" \
    }, _fn_metadata) \
    return get_class_metadata(); \
endfunction : get_metadata


`define BLOCK_METADATA(s, b=_metadata_block, m=_metadata) \
begin : b \
meta_pkg::metadata_t m; \
m = meta_pkg::metacatalog::get().register_block_metadata(s, $sformatf("%m"), meta_pkg::BLOCK_TYPE, `__FILE__, `__LINE__); \
end : b


`define FILE_METADATA(s, b=_metadata_block, m=_metadata) \
begin : b \
meta_pkg::metadata_t m; \
m = meta_pkg::metacatalog::get().register_block_metadata(s, $sformatf("%m"), meta_pkg::FILE_TYPE, `__FILE__, `__LINE__); \
end : b


`define TASK_METADATA(s, m=_metadata) \
static meta_pkg::metadata_t m = \
meta_pkg::metacatalog::get().register_subroutine_metadata(s, $sformatf("%m"), meta_pkg::TASK_TYPE, `__FILE__, `__LINE__);


`define FUNCTION_METADATA(s, m=_metadata) \
static meta_pkg::metadata_t m = \
meta_pkg::metacatalog::get().register_subroutine_metadata(s, $sformatf("%m"), meta_pkg::FUNCTION_TYPE, `__FILE__, `__LINE__);
