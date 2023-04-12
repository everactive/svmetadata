// ===================================================================
//
// Name: meta_pkg.sv
//
// Description:
// Scroll down a little to see this file's live metadata.
// Ironically we can't create the metadata structure until _after_ it has been defined.
//
// Scroll down to the bottom to see templates you can copy and paste into your code.
// ===================================================================

`include "uvm_macros.svh"

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

// ===================================================================
package meta_pkg;
// ===================================================================

	import uvm_pkg::*;

// ===================================================================
 (*_= "typedef struct metadata_t" *)
// ===================================================================
// This is the struct that holds the metadata for each element (class, block, file, task, or function).
// Each of the struct's fields is of type `string`, even if it holds a numeric value.
	
	typedef struct {

		string metatype = "";
		// ------------------
		// Indicates the metadata's type.
		//
		// Expected values are:
		// * "CLASS_TYPE"
		// * "BLOCK_TYPE"
		// * "FILE_TYPE"
		// * "TASK_TYPE"
		// * "FUNCTION_TYPE"
		//
		// Knowing the metatype helps provide context for the other fields.
		// For example if the metatype is “CLASS_TYPE” then the RCS keywords can be ignored.
		//
		// If no value is provided, this field is filled automatically.

		string name = "";
		// --------------
		// The name of the element.
		// This field is filled automatically by the metacatalog.
		// For file metadata this should be the filename.
		//
		// If no value is provided, this field is filled automatically.

		string description = "";
		// ---------------------
		// A brief one-line description of the element.

		string details = "";
		// -----------------
		// Free-form text providing more details about the element.
		// Generally longer than description.
		// May contain simple formatting like linebreaks or Markdown.

		string categories = "";
		// --------------------
		// A comma-separated list of categories the element belongs to.
		// White space surrounding the commas is ignored.
		// There are no preset categories so the definition of “category” is up to the user.
		// The intent is that a category is something that the element is as opposed to something the element has.
		// Elements can be “tagged” with a shared category to make it easier to filter and group them.
		// For example memory tests might have categories “memory, test”.
		//
		// If the element is a class descended from uvm_object then this field is automatically appended with a list of all the UVM base classes in the element’s class hierarchy.

		string attributes = "";
		// --------------------
		// A comma-separated list of attributes the element has.
		// White space surrounding the commas is ignored.
		// There are no preset attributes so the definition of “attribute” is up to the user.
		// The intent is that an attribute is something that the element has as opposed to something the element is.
		// Elements can be “tagged” with a shared attribute to make it easier to filter and group them.
		// For example a random test sequence with an interrupt handler might have attributes “random, interrupt handler”.

		string type_id = "";
		// -----------------
		// UVM objects have a `type_id` property which represents the class in the UVM factory.
		// This metadata field contains the name of the type_id which generally is the same as the class name.
		// It can be found with the function call `type_id::get().get_type_name()`.
		//
		// Only used for class metadata.
		//
		// If no value is provided, this field is filled automatically.

		string hierarchical_name = "";
		// ---------------------------
		// The full hierarchical path to the metadata block.
		//
		// Used for block, task, and function metadata.
		//
		// If no value is provided, this field is filled automatically.

		string file = "";
		// --------------
		// The full file pathname of the file in the local file system containing the element's source code.
		// The pathname generally includes the user’s home directory information so the same file will have different file metadata depending on which user generates the metadata and where.
		//
		// If no value is provided, this field is filled automatically.

		string line = "";
		// --------------
		// The line number in the `file` where the metadata is created, i.e. inside the element.
		// It's a numeric value but the field type is still `string`.
		//
		// If no value is provided, this field is filled automatically.

		// RCS keywords
		// ============
		// These fields are not filled automatically; you need to explicitly put the keywords in your metadata struct.
		// However, Perforce will expand them automatically when you check in the file with one of the `+k` file types.
		// See `icmp4 help filetypes` for more information.
		
		string id = "";
		// ------------
		// RCS `$Id$` keyword.
		// IC Manage/Perforce filename and revision number in depot syntax.
		
		string header = "";
		// ----------------
		// RCS `$Header$` keyword.
		// Synonymous with $Id$.
		
		string author = "";
		// ----------------
		// RCS `$Author$` keyword.
		// IC Manage/Perforce user submitting the file.
		
		string date = "";
		// --------------
		// RCS `$Date$` keyword.
		// Date of last submission in format "YYYY/MM/DD".
		
		string date_time = "";
		// -------------------
		// RCS `$DateTime$` keyword.
		// Date and time of last submission in format "YYYY/MM/DD hh:mm:ss".
		
		string change = "";
		// ----------------
		// RCS `$Change$` keyword.
		// IC Manage/Perforce changelist number under which file was submitted.
		
		string depot_file = "";
		// --------------------
		// RCS `$File$` keyword.
		// IC Manage/Perforce filename  in depot syntax, without revision number.
		
		string revision = "";
		// ------------------
		// RCS `$Revision$` keyword.
		// IC Manage/Perforce revision number.


		string metaoptions = "";
		// ---------------------
		// Comma-separated flags for controlling metadata operations.
		// White space surrounding the commas is ignored.
		// Currently these metaoptions are supported:
		// * "disable_auto_base_class_listing" - If present, prevents the categories field from being auto-filled with a list of UVM base classes.
		//   Some classes cause execution to fail while determining base classes, so set this metaoption to bypass the failing operation.
		// * "do_not_register" - If present, prevents the metadata from being added to the metacatalog.
		//   However the metadata is still added to the element itself.

	} metadata_t;


// ===================================================================
(*_= "typedef enum metatype_t" *)
// ===================================================================
// Enum of possible metadata `metatype` values for internal use.
// Note that the `metatype` field in the `metadata_t` struct takes a string.

	typedef enum {CLASS_TYPE, BLOCK_TYPE, FILE_TYPE, TASK_TYPE, FUNCTION_TYPE} metatype_t;
	

	class \_metadata_$_meta_pkg.sv  extends uvm_object;
		`CLASS_METADATA('{
// ===================================================================
				name: "meta_pkg.sv",
// ===================================================================

				description:
				"Utilities for adding and managing metadata in classes and blocks.",

				details: {
					"Metadata is structured information about SystemVerilog entities. ",
					"Metadata may be added to sub-classes of `uvm_object` and to procedural `begin-end` blocks. ",
					"These utilities add metadata that is accessible from within the simulation. ",
					"Run test `print_meta_catalog` to output all the metadata to a YAML file which can be processed offline. ",
					"Add metadata like this to classes and blocks almost anywhere in the design. ",
					"At the bottom of this file, there are templates you can copy and paste into other files. ",
					"Since metadata is part of the source code, it must be syntactically correct so it will compile. ",
					"Pay careful attention to syntax, especially punctuation. ",
					"This is the metadata for this file. ",
					"That makes this meta-metadata. "
				},

				categories:
				"file, package",

				attributes:
				"metadata, documentation",

				// RCS keywords
				id: "$Id$",
				header: "$Header$",
				author: "$Author$",
				date: "$Date$",
				date_time: "$DateTime$",
				change: "$Change$",
				depot_file: "$File$",
				revision: "$Revision$",

				metatype: "FILE_TYPE",

				string:
				"" // Required
			})
// ===================================================================
		`uvm_object_utils(\_metadata_$_meta_pkg.sv )

		function new(string name = "\_metadata_$_meta_pkg.sv ");
			super.new(name);
		endfunction : new
	endclass : \_metadata_$_meta_pkg.sv 


// ===================================================================
	function bit csv_to_list;
// ===================================================================
		`FUNCTION_METADATA('{

				description:
				"Take a string containing comma-separated values, split the values, and return them in the supplied SystemVerilog queue.",
				
				details:
				"White space around the commas is ignored.",
				
				categories:
				"utility",

				string: ""
			})

		// Parameters:

		output string tokens[$];	// Output queue of individual values

		input string csv;			// Incoming string of comma-separated values

// ===================================================================
		typedef enum {START, TOKEN, SEPARATOR, WHITE_SPACE, FINISH} lex_state_t;
		lex_state_t state;
		byte c;
		string token;
		bit ok;

		ok = 1;
		tokens.delete();
		state = START;
		foreach (csv[i]) begin
			c = csv.getc(i);
			case (state)
				START: begin
					token = "";
					case (c)
						" ", "\t", "\n" : begin
							state = WHITE_SPACE;
						end
						"," : begin
							state = SEPARATOR;
						end
						default : begin
							token = {token, c};
							state = TOKEN;
						end
					endcase
				end

				TOKEN: begin
					case (c)
						" ", "\t", "\n" : begin
							tokens.push_back(token);
							token = "";
							state = WHITE_SPACE;
						end
						"," : begin
							tokens.push_back(token);
							token = "";
							state = SEPARATOR;
						end
						default : begin
							token = {token, c};
							state = TOKEN;
						end
					endcase
				end

				SEPARATOR: begin
					case (c)
						" ", "\t", "\n" : begin
							state = WHITE_SPACE;
						end
						"," : begin
							state = SEPARATOR;
						end
						default : begin
							token = {token, c};
							state = TOKEN;
						end
					endcase
				end

				WHITE_SPACE: begin
					case (c)
						" ", "\t", "\n" : begin
							state = WHITE_SPACE;
						end
						"," : begin
							state = SEPARATOR;
						end
						default : begin
							token = {token, c};
							state = TOKEN;
						end
					endcase
				end

				default: begin
					$fatal(1, "Unknown lexer state");
				end
			endcase
		end

		if (state == TOKEN) begin
			tokens.push_back(token);
			state = FINISH;
		end
		return ok;
	endfunction : csv_to_list


// ===================================================================
	function bit split_string
// ===================================================================
		(
			// Parameters:

			output string tokens[$],        // Output queue of separated tokens

			input string joined_string,     // Incoming string to be split

			input string separator = "."    // One-character separator

		);
		`FUNCTION_METADATA('{

				description:
				"Split a string at the provided separator character, and fill the provided SystemVerilog queue with the separate tokens.",

				details: {
					"Useful for splitting hierarchical.path.names or /file/path/names. ",
					"Throws an error if the separator's length is not equal to one. ",
					"Returns 1 if the split is successful; 0 otherwise. ",
					""
				},

				categories:
				"utility",

				string: ""
			})
// ===================================================================
		typedef enum {START, TOKEN, SEPARATOR, FINISH} lex_state_t;
		lex_state_t state;
		byte c;
		string token;
		bit ok;

		assert_separator_len_is_1 : assert (separator.len == 1) else return 0;

		ok = 1;
		tokens.delete();
		state = START;
		foreach (joined_string[i]) begin
			c = joined_string.getc(i);
			case (state)
				START: begin
					token = "";
					case (c)
						separator[0] : begin
							state = SEPARATOR;
						end
						default : begin
							token = {token, c};
							state = TOKEN;
						end
					endcase
				end

				TOKEN: begin
					case (c)
						separator[0] : begin
							tokens.push_back(token);
							token = "";
							state = SEPARATOR;
						end
						default : begin
							token = {token, c};
							state = TOKEN;
						end
					endcase
				end

				SEPARATOR: begin
					case (c)
						separator[0] : begin
							state = SEPARATOR;
						end
						default : begin
							token = {token, c};
							state = TOKEN;
						end
					endcase
				end

				default: begin
					$fatal(1, "Unknown lexer state");
				end
			endcase
		end

		if (state == TOKEN) begin
			tokens.push_back(token);
			state = FINISH;
		end
		return ok;
	endfunction : split_string


// ===================================================================
	class _meta_component extends uvm_component;
// ===================================================================
		`CLASS_METADATA('{

				description:
				"A component that has the ability to delete its own children.",

				details: {
					"UVM does not provide a way to remove components from the component tree. ",
					"Function `list_uvm_clsses_of_object()` needs to instantiate components temporarily for quick analysis, then remove them. ",
					"Otherwise the components would persist in the component tree and their phases would run, potentially causing problems. ",
					"This `_meta_component` can serve as a parent for those temporary components that deletes them when done. ",
					"Note that the `_meta_component` itself does persist in the main component tree, but its phases are empty so there should be no side-effects. ",
					"This has a singleton-style static `get()` function that returns a single static instance of itself, located under `uvm_top`. ",
					"Please use that `get()` function instead of creating your own `_meta_component` so there aren't more than one `_meta_component` in the tree. ",
					""
				},

				attributes:
				"metadata",

				string: ""
			})
// ===================================================================

		local static _meta_component pseudo_singleton;

		`uvm_component_utils(_meta_component)

		function new(string name="", uvm_component parent=null);
			super.new(name, parent);
		endfunction : new


// ===================================================================
		static function _meta_component get;
// ===================================================================
			`FUNCTION_METADATA('{

					description:
					"Return a handle to the singleton _meta_component object.",

					details: {
						"It's not really a singleton because `new()` is public so anyone can create a new one. ",
						"The `uvm_component_utils` prevent us from making `new()` local. ",
						"But there can only be one static instance. ",
						"It's not enforceable, but it is _recommended_ to use this static `get()` function instead of creating your own instance. ",
						""
					},

					attributes:
					"metadata",

					string: ""
				})

			// Parameters:
			// None

// =================================================================//
			if (pseudo_singleton == null) begin
				// Create the `_meta_component` and add it to `uvm_top`.
				pseudo_singleton = _meta_component::type_id::create("_meta_component", null);
			end
			return pseudo_singleton;
		endfunction : get


// ===================================================================
		virtual function void delete_children;
// ===================================================================
			`FUNCTION_METADATA('{

					description:
					"Delete all of this component's children.",

					details: {
						"This is the raison d'etre for this class. ",
						"Remove all child components and release their handles. ",
						"Without this, children would persist in the component tree forever. ",
						""
					},

					string: ""

				})

			// Parameters;
			// None

// ===================================================================
			// In this UVM implementation child classes are stored in two protected associative arrays.
			// Clean them both out.
			// This is not a documented feature.
			// This may change in different implementations.
			foreach (m_children[i]) m_children[i] = null;
			m_children.delete();

			foreach (m_children_by_handle[i]) m_children_by_handle[i] = null;
			m_children_by_handle.delete();

			// Check the result using the documented interface.
			// This will alert us if this undocumented method fails to work for some reason.
			assert_zero_children : assert (get_num_children() == 0)
			else begin
				`uvm_error(get_name(), "Failed to delete components.")
			end
		endfunction : delete_children

	endclass : _meta_component


// ===================================================================
	function string list_uvm_classes_of_object;
// ===================================================================
		`FUNCTION_METADATA('{
				description:
				"Generate a comma-separated list of UVM base classes for a given UVM proxy class.",

				details: {
					"For a given user-extended UVM class, generates its UVM base class lineage all the way up to `uvm_void`. ",
					"Returns a string of comma-separated base class names. ",
					"The names are not in any particular order, i.e. not in lineage order. ",
					// Actually they are currently in alphabetical order but that could change.
					"This function first looks for the target class among the list of existing instantiated components. ",
					""
				},

				attributes:
				"metadata",

				string: ""
			})

		// Parameters:

		input uvm_object_wrapper object_wrapper;
		// The object or component registry proxy to analyze

// ===================================================================
		string uvm_classes;
		uvm_object target_object;
		uvm_component target_component;
		uvm_component all_components[$];

		// This list of UVM classes was scraped from $UVM_HOME/docs/html/index/Classes.html
		// then cleaned up manually.

		// Commented-out lines are known or are suspected to cause compilation errors

		uvm_agent uvm_agent$;
//          uvm_algorithmic_comparator uvm_algorithmic_comparator$;
		uvm_analysis_export uvm_analysis_export$;
//          uvm_analysis_imp uvm_analysis_imp$;
		uvm_analysis_port uvm_analysis_port$;
		uvm_barrier uvm_barrier$;
		uvm_blocking_get_export uvm_blocking_get_export$;
//          uvm_blocking_get_imp uvm_blocking_get_imp$;
		uvm_blocking_get_peek_export uvm_blocking_get_peek_export$;
//          uvm_blocking_get_peek_imp uvm_blocking_get_peek_imp$;
		uvm_blocking_get_peek_port uvm_blocking_get_peek_port$;
		uvm_blocking_get_port uvm_blocking_get_port$;
		uvm_blocking_peek_export uvm_blocking_peek_export$;
//          uvm_blocking_peek_imp uvm_blocking_peek_imp$;
		uvm_blocking_peek_port uvm_blocking_peek_port$;
		uvm_blocking_put_export uvm_blocking_put_export$;
//          uvm_blocking_put_imp uvm_blocking_put_imp$;
		uvm_blocking_put_port uvm_blocking_put_port$;
		uvm_bottom_up_visitor_adapter uvm_bottom_up_visitor_adapter$;
		uvm_bottomup_phase uvm_bottomup_phase$;
		uvm_build_phase uvm_build_phase$;
//          uvm_built_in_clone uvm_built_in_clone$;
//          uvm_built_in_comp uvm_built_in_comp$;
//          uvm_built_in_converter uvm_built_in_converter$;
//          uvm_built_in_pair uvm_built_in_pair$;
		uvm_by_level_visitor_adapter uvm_by_level_visitor_adapter$;
		uvm_callback uvm_callback$;
		uvm_callback_iter uvm_callback_iter$;
		uvm_callbacks uvm_callbacks$;
		uvm_cause_effect_link uvm_cause_effect_link$;
		uvm_check_phase uvm_check_phase$;
//          uvm_class_clone uvm_class_clone$;
//          uvm_class_comp uvm_class_comp$;
//          uvm_class_converter uvm_class_converter$;
//          uvm_class_pair uvm_class_pair$;
		uvm_cmdline_processor uvm_cmdline_processor$;
//          uvm_comparer uvm_comparer$;
		uvm_component uvm_component$;
		uvm_component_name_check_visitor uvm_component_name_check_visitor$;
		uvm_component_proxy uvm_component_proxy$;
//		uvm_component_registry uvm_component_registry$;
		uvm_config_db uvm_config_db$;
		uvm_config_db_options uvm_config_db_options$;
		uvm_configure_phase uvm_configure_phase$;
		uvm_connect_phase uvm_connect_phase$;
		uvm_coreservice_t uvm_coreservice_t$;
		uvm_default_coreservice_t uvm_default_coreservice_t$;
		uvm_default_factory uvm_default_factory$;
		uvm_default_report_server uvm_default_report_server$;
		uvm_domain uvm_domain$;
		uvm_driver uvm_driver$;
		uvm_end_of_elaboration_phase uvm_end_of_elaboration_phase$;
		uvm_enum_wrapper uvm_enum_wrapper$;
		uvm_env uvm_env$;
		uvm_event uvm_event$;
		uvm_event_base uvm_event_base$;
		uvm_event_callback uvm_event_callback$;
		uvm_external_connector uvm_external_connector$;
		uvm_extract_phase uvm_extract_phase$;
		uvm_factory uvm_factory$;
		uvm_final_phase uvm_final_phase$;
		uvm_get_export uvm_get_export$;
//          uvm_get_imp uvm_get_imp$;
		uvm_get_peek_export uvm_get_peek_export$;
//          uvm_get_peek_imp uvm_get_peek_imp$;
		uvm_get_peek_port uvm_get_peek_port$;
		uvm_get_port uvm_get_port$;
		uvm_get_to_lock_dap uvm_get_to_lock_dap$;
		uvm_hdl_path_concat uvm_hdl_path_concat$;
		uvm_heartbeat uvm_heartbeat$;
		uvm_if_base_abstract uvm_if_base_abstract$;
//          uvm_in_order_built_in_comparator uvm_in_order_built_in_comparator$;
//          uvm_in_order_class_comparator uvm_in_order_class_comparator$;
//          uvm_in_order_comparator uvm_in_order_comparator$;
		uvm_line_printer uvm_line_printer$;
		uvm_link_base uvm_link_base$;
		uvm_main_phase uvm_main_phase$;
		uvm_mem uvm_mem$;
		uvm_mem_access_seq uvm_mem_access_seq$;
		uvm_mem_mam uvm_mem_mam$;
		uvm_mem_mam_cfg uvm_mem_mam_cfg$;
		uvm_mem_mam_policy uvm_mem_mam_policy$;
		uvm_mem_region uvm_mem_region$;
		uvm_mem_shared_access_seq uvm_mem_shared_access_seq$;
		uvm_mem_single_access_seq uvm_mem_single_access_seq$;
		uvm_mem_single_walk_seq uvm_mem_single_walk_seq$;
		uvm_mem_walk_seq uvm_mem_walk_seq$;
		uvm_monitor uvm_monitor$;
		uvm_nonblocking_get_export uvm_nonblocking_get_export$;
//          uvm_nonblocking_get_imp uvm_nonblocking_get_imp$;
		uvm_nonblocking_get_peek_export uvm_nonblocking_get_peek_export$;
//          uvm_nonblocking_get_peek_imp uvm_nonblocking_get_peek_imp$;
		uvm_nonblocking_get_peek_port uvm_nonblocking_get_peek_port$;
		uvm_nonblocking_get_port uvm_nonblocking_get_port$;
		uvm_nonblocking_peek_export uvm_nonblocking_peek_export$;
//          uvm_nonblocking_peek_imp uvm_nonblocking_peek_imp$;
		uvm_nonblocking_peek_port uvm_nonblocking_peek_port$;
		uvm_nonblocking_put_export uvm_nonblocking_put_export$;
//          uvm_nonblocking_put_imp uvm_nonblocking_put_imp$;
		uvm_nonblocking_put_port uvm_nonblocking_put_port$;
		uvm_object uvm_object$;
//		uvm_object_registry uvm_object_registry$;
//		uvm_object_string_pool uvm_object_string_pool$;
		uvm_object_wrapper uvm_object_wrapper$;
		uvm_objection uvm_objection$;
		uvm_objection_callback uvm_objection_callback$;
		uvm_packer uvm_packer$;
		uvm_parent_child_link uvm_parent_child_link$;
		uvm_peek_export uvm_peek_export$;
//          uvm_peek_imp uvm_peek_imp$;
		uvm_peek_port uvm_peek_port$;
		uvm_phase uvm_phase$;
		uvm_phase_cb uvm_phase_cb$;
		uvm_phase_cb_pool uvm_phase_cb_pool$;
		uvm_phase_state_change uvm_phase_state_change$;
		uvm_pool uvm_pool$;
//          uvm_port_base uvm_port_base$;
//          uvm_port_component uvm_port_component$;
//          uvm_port_component_base uvm_port_component_base$;
		uvm_post_configure_phase uvm_post_configure_phase$;
		uvm_post_main_phase uvm_post_main_phase$;
		uvm_post_reset_phase uvm_post_reset_phase$;
		uvm_post_shutdown_phase uvm_post_shutdown_phase$;
		uvm_pre_configure_phase uvm_pre_configure_phase$;
		uvm_pre_main_phase uvm_pre_main_phase$;
		uvm_pre_reset_phase uvm_pre_reset_phase$;
		uvm_pre_shutdown_phase uvm_pre_shutdown_phase$;
		uvm_printer uvm_printer$;
		uvm_printer_knobs uvm_printer_knobs$;
		uvm_push_driver uvm_push_driver$;
		uvm_push_sequencer uvm_push_sequencer$;
		uvm_put_export uvm_put_export$;
//          uvm_put_imp uvm_put_imp$;
		uvm_put_port uvm_put_port$;
		uvm_queue uvm_queue$;
//		uvm_random_stimulus uvm_random_stimulus$;
		uvm_recorder uvm_recorder$;
		uvm_reg uvm_reg$;
		uvm_reg_access_seq uvm_reg_access_seq$;
		uvm_reg_adapter uvm_reg_adapter$;
		uvm_reg_backdoor uvm_reg_backdoor$;
		uvm_reg_bit_bash_seq uvm_reg_bit_bash_seq$;
		uvm_reg_block uvm_reg_block$;
//          uvm_reg_bus_op uvm_reg_bus_op$;
		uvm_reg_cbs uvm_reg_cbs$;
		uvm_reg_field uvm_reg_field$;
		uvm_reg_fifo uvm_reg_fifo$;
		uvm_reg_file uvm_reg_file$;
		uvm_reg_frontdoor uvm_reg_frontdoor$;
		uvm_reg_hw_reset_seq uvm_reg_hw_reset_seq$;
		uvm_reg_indirect_data uvm_reg_indirect_data$;
		uvm_reg_item uvm_reg_item$;
		uvm_reg_map uvm_reg_map$;
		uvm_reg_mem_access_seq uvm_reg_mem_access_seq$;
		uvm_reg_mem_built_in_seq uvm_reg_mem_built_in_seq$;
		uvm_reg_mem_hdl_paths_seq uvm_reg_mem_hdl_paths_seq$;
		uvm_reg_mem_shared_access_seq uvm_reg_mem_shared_access_seq$;
//          uvm_reg_predictor uvm_reg_predictor$;
		uvm_reg_read_only_cbs uvm_reg_read_only_cbs$;
		uvm_reg_sequence uvm_reg_sequence$;
		uvm_reg_shared_access_seq uvm_reg_shared_access_seq$;
		uvm_reg_single_access_seq uvm_reg_single_access_seq$;
		uvm_reg_single_bit_bash_seq uvm_reg_single_bit_bash_seq$;
		uvm_reg_tlm_adapter uvm_reg_tlm_adapter$;
		uvm_reg_transaction_order_policy uvm_reg_transaction_order_policy$;
		uvm_reg_write_only_cbs uvm_reg_write_only_cbs$;
		uvm_related_link uvm_related_link$;
		uvm_report_catcher uvm_report_catcher$;
		uvm_report_handler uvm_report_handler$;
		uvm_report_message uvm_report_message$;
		uvm_report_message_element_base uvm_report_message_element_base$;
		uvm_report_message_element_container uvm_report_message_element_container$;
		uvm_report_message_int_element uvm_report_message_int_element$;
		uvm_report_message_object_element uvm_report_message_object_element$;
		uvm_report_message_string_element uvm_report_message_string_element$;
		uvm_report_object uvm_report_object$;
		uvm_report_phase uvm_report_phase$;
		uvm_report_server uvm_report_server$;
		uvm_reset_phase uvm_reset_phase$;
		uvm_resource uvm_resource$;
		uvm_resource_base uvm_resource_base$;
		uvm_resource_db uvm_resource_db$;
		uvm_resource_db_options uvm_resource_db_options$;
		uvm_resource_options uvm_resource_options$;
		uvm_resource_pool uvm_resource_pool$;
		uvm_resource_types uvm_resource_types$;
		uvm_root uvm_root$;
		uvm_run_phase uvm_run_phase$;
		uvm_scoreboard uvm_scoreboard$;
//          uvm_seq_item_pull_export uvm_seq_item_pull_export$;
//          uvm_seq_item_pull_imp uvm_seq_item_pull_imp$;
//          uvm_seq_item_pull_port uvm_seq_item_pull_port$;
		uvm_sequence uvm_sequence$;
		uvm_sequence_base uvm_sequence_base$;
		uvm_sequence_item uvm_sequence_item$;
		uvm_sequence_library uvm_sequence_library$;
		uvm_sequence_library_cfg uvm_sequence_library_cfg$;
		uvm_sequencer uvm_sequencer$;
		uvm_sequencer_base uvm_sequencer_base$;
		uvm_sequencer_param_base uvm_sequencer_param_base$;
		uvm_set_before_get_dap uvm_set_before_get_dap$;
		uvm_set_get_dap_base uvm_set_get_dap_base$;
		uvm_shutdown_phase uvm_shutdown_phase$;
		uvm_simple_lock_dap uvm_simple_lock_dap$;
		uvm_sqr_if_base uvm_sqr_if_base$;
		uvm_start_of_simulation_phase uvm_start_of_simulation_phase$;
		uvm_structure_proxy uvm_structure_proxy$;
		uvm_subscriber uvm_subscriber$;
		uvm_table_printer uvm_table_printer$;
		uvm_task_phase uvm_task_phase$;
		uvm_test uvm_test$;
		uvm_text_recorder uvm_text_recorder$;
		uvm_text_tr_database uvm_text_tr_database$;
		uvm_text_tr_stream uvm_text_tr_stream$;
		uvm_tlm_analysis_fifo uvm_tlm_analysis_fifo$;
//          uvm_tlm_b_initiator_socket uvm_tlm_b_initiator_socket$;
//          uvm_tlm_b_initiator_socket_base uvm_tlm_b_initiator_socket_base$;
//          uvm_tlm_b_passthrough_initiator_socket uvm_tlm_b_passthrough_initiator_socket$;
//          uvm_tlm_b_passthrough_initiator_socket_base uvm_tlm_b_passthrough_initiator_socket_base$;
//          uvm_tlm_b_passthrough_target_socket uvm_tlm_b_passthrough_target_socket$;
//          uvm_tlm_b_passthrough_target_socket_base uvm_tlm_b_passthrough_target_socket_base$;
//          uvm_tlm_b_target_socket uvm_tlm_b_target_socket$;
//          uvm_tlm_b_target_socket_base uvm_tlm_b_target_socket_base$;
		uvm_tlm_b_transport_export uvm_tlm_b_transport_export$;
//          uvm_tlm_b_transport_imp uvm_tlm_b_transport_imp$;
		uvm_tlm_b_transport_port uvm_tlm_b_transport_port$;
		uvm_tlm_extension uvm_tlm_extension$;
		uvm_tlm_extension_base uvm_tlm_extension_base$;
		uvm_tlm_fifo uvm_tlm_fifo$;
		uvm_tlm_fifo_base uvm_tlm_fifo_base$;
		uvm_tlm_generic_payload uvm_tlm_generic_payload$;
		uvm_tlm_gp uvm_tlm_gp$;
		uvm_tlm_if uvm_tlm_if$;
		uvm_tlm_if_base uvm_tlm_if_base$;
//          uvm_tlm_nb_initiator_socket uvm_tlm_nb_initiator_socket$;
//          uvm_tlm_nb_initiator_socket_base uvm_tlm_nb_initiator_socket_base$;
//          uvm_tlm_nb_passthrough_initiator_socket uvm_tlm_nb_passthrough_initiator_socket$;
//          uvm_tlm_nb_passthrough_initiator_socket_base uvm_tlm_nb_passthrough_initiator_socket_base$;
//          uvm_tlm_nb_passthrough_target_socket uvm_tlm_nb_passthrough_target_socket$;
//          uvm_tlm_nb_passthrough_target_socket_base uvm_tlm_nb_passthrough_target_socket_base$;
//          uvm_tlm_nb_target_socket uvm_tlm_nb_target_socket$;
//          uvm_tlm_nb_target_socket_base uvm_tlm_nb_target_socket_base$;
		uvm_tlm_nb_transport_bw_export uvm_tlm_nb_transport_bw_export$;
//          uvm_tlm_nb_transport_bw_imp uvm_tlm_nb_transport_bw_imp$;
		uvm_tlm_nb_transport_bw_port uvm_tlm_nb_transport_bw_port$;
		uvm_tlm_nb_transport_fw_export uvm_tlm_nb_transport_fw_export$;
//          uvm_tlm_nb_transport_fw_imp uvm_tlm_nb_transport_fw_imp$;
		uvm_tlm_nb_transport_fw_port uvm_tlm_nb_transport_fw_port$;
		uvm_tlm_req_rsp_channel uvm_tlm_req_rsp_channel$;
		uvm_tlm_time uvm_tlm_time$;
		uvm_tlm_transport_channel uvm_tlm_transport_channel$;
		uvm_top_down_visitor_adapter uvm_top_down_visitor_adapter$;
		uvm_topdown_phase uvm_topdown_phase$;
		uvm_tr_database uvm_tr_database$;
		uvm_tr_stream uvm_tr_stream$;
		uvm_transaction uvm_transaction$;
		uvm_tree_printer uvm_tree_printer$;
//          uvm_utils uvm_utils$;
		uvm_visitor uvm_visitor$;
		uvm_visitor_adapter uvm_visitor_adapter$;
		uvm_void uvm_void$;
		uvm_vreg uvm_vreg$;
		uvm_vreg_cbs uvm_vreg_cbs$;
		uvm_vreg_field uvm_vreg_field$;
		uvm_vreg_field_cbs uvm_vreg_field_cbs$;

		assert (object_wrapper != null) else
			`uvm_fatal("list_uvm_classes_of_object", "obect_wrapper is null")

		`uvm_info("list_uvm_classes_of_object", object_wrapper.get_type_name(), UVM_HIGH)

		uvm_classes = "";

		// First look for the target class among the tree of existing instantiated components.
		// If there's a match, store it in the `target_component` handle
		//
		uvm_root::get().find_all("*", all_components);
		target_component = null;
		foreach (all_components[i]) begin
			if (all_components[i].get_object_type() == object_wrapper ||
					all_components[i].get_type_name() == object_wrapper.get_type_name()) begin
				target_component = all_components[i];
				break;
			end
		end

		// Failing that, see if the target class is a component by trying to instantiate it as a component.
		// We use a local `_meta_component` as a parent to instantiate the target component under.
		// Then we immediately remove the target component from the parent.
		// We don't want any references to the target remaining after this analysis.
		// We just want a standalone target component we can cleanly delete when we're done.
		// If the target component persisted in the component tree, its phases would continue to run, potentially causing problems.
		//
		if (target_component == null) begin
			target_component = object_wrapper.create_component("target_component", _meta_component::get());
			_meta_component::get().delete_children();
		end

		// If the component thing worked then point the `target_object` handle to the new component instance.
		// Release the `target_component` handle.
		// We're done with it and don't want any dangling handles to that component instance.
		//
		if (target_component) begin
			target_object = target_component;
			target_component = null; // We're done with this handle
		end

		// If the component thing didn't work, try instantiating the target class as a non-component object.
		//
		else if (target_object == null) begin
			target_object = object_wrapper.create_object();
		end

		// Failing that, give up.
		//
		if (target_object == null) begin
			`uvm_warning("list_uvm_classes_of_object", $sformatf("Could not determine UVM base classes of %s", object_wrapper.get_type_name))
			return uvm_classes;
		end
		else begin

			// At this point `target_object` is a handle to an actual instance of our target class.
			// Either one that we found or that we created ourselves.
			// Use brute force to try to cast `target_object` to every kind of UVM base class we know about.
			// If the cast succeeds, add that base class to the list of base classes.
			// This is crude but effective.
			// There might be a more elegant way to find parent classes through introspection.
			// Also we start from scratch each time.
			// It would be more efficient to build and store the UVM base class family tree as we go.
			// Some UVM base classes cause errors when we try this method so we skip those.
			// We just won't be able to identify objects of those classes.

			if ($cast(uvm_agent$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_agent"};
			//          if ($cast(uvm_algorithmic_comparator$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_algorithmic_comparator"};
			if ($cast(uvm_analysis_export$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_analysis_export"};
			//          if ($cast(uvm_analysis_imp$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_analysis_imp"};
			if ($cast(uvm_analysis_port$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_analysis_port"};
			if ($cast(uvm_barrier$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_barrier"};
			if ($cast(uvm_blocking_get_export$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_blocking_get_export"};
			//          if ($cast(uvm_blocking_get_imp$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_blocking_get_imp"};
			if ($cast(uvm_blocking_get_peek_export$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_blocking_get_peek_export"};
			//          if ($cast(uvm_blocking_get_peek_imp$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_blocking_get_peek_imp"};
			if ($cast(uvm_blocking_get_peek_port$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_blocking_get_peek_port"};
			if ($cast(uvm_blocking_get_port$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_blocking_get_port"};
			if ($cast(uvm_blocking_peek_export$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_blocking_peek_export"};
			//          if ($cast(uvm_blocking_peek_imp$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_blocking_peek_imp"};
			if ($cast(uvm_blocking_peek_port$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_blocking_peek_port"};
			if ($cast(uvm_blocking_put_export$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_blocking_put_export"};
			//          if ($cast(uvm_blocking_put_imp$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_blocking_put_imp"};
			if ($cast(uvm_blocking_put_port$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_blocking_put_port"};
			if ($cast(uvm_bottom_up_visitor_adapter$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_bottom_up_visitor_adapter"};
			if ($cast(uvm_bottomup_phase$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_bottomup_phase"};
			if ($cast(uvm_build_phase$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_build_phase"};
			//          if ($cast(uvm_built_in_clone$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_built_in_clone"};
			//          if ($cast(uvm_built_in_comp$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_built_in_comp"};
			//          if ($cast(uvm_built_in_converter$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_built_in_converter"};
			//          if ($cast(uvm_built_in_pair$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_built_in_pair"};
			if ($cast(uvm_by_level_visitor_adapter$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_by_level_visitor_adapter"};
			if ($cast(uvm_callback$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_callback"};
			if ($cast(uvm_callback_iter$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_callback_iter"};
			if ($cast(uvm_callbacks$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_callbacks"};
			if ($cast(uvm_cause_effect_link$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_cause_effect_link"};
			if ($cast(uvm_check_phase$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_check_phase"};
			//          if ($cast(uvm_class_clone$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_class_clone"};
			//          if ($cast(uvm_class_comp$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_class_comp"};
			//          if ($cast(uvm_class_converter$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_class_converter"};
			//          if ($cast(uvm_class_pair$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_class_pair"};
			if ($cast(uvm_cmdline_processor$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_cmdline_processor"};
			//          if ($cast(uvm_comparer$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_comparer"};
			if ($cast(uvm_component$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_component"};
			if ($cast(uvm_component_name_check_visitor$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_component_name_check_visitor"};
			if ($cast(uvm_component_proxy$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_component_proxy"};
//			if ($cast(uvm_component_registry$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_component_registry"};
			if ($cast(uvm_config_db$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_config_db"};
			if ($cast(uvm_config_db_options$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_config_db_options"};
			if ($cast(uvm_configure_phase$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_configure_phase"};
			if ($cast(uvm_connect_phase$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_connect_phase"};
			if ($cast(uvm_coreservice_t$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_coreservice_t"};
			if ($cast(uvm_default_coreservice_t$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_default_coreservice_t"};
			if ($cast(uvm_default_factory$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_default_factory"};
			if ($cast(uvm_default_report_server$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_default_report_server"};
			if ($cast(uvm_domain$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_domain"};
			if ($cast(uvm_driver$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_driver"};
			if ($cast(uvm_end_of_elaboration_phase$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_end_of_elaboration_phase"};
			if ($cast(uvm_enum_wrapper$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_enum_wrapper"};
			if ($cast(uvm_env$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_env"};
			if ($cast(uvm_event$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_event"};
			if ($cast(uvm_event_base$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_event_base"};
			if ($cast(uvm_event_callback$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_event_callback"};
			if ($cast(uvm_external_connector$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_external_connector"};
			if ($cast(uvm_extract_phase$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_extract_phase"};
			if ($cast(uvm_factory$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_factory"};
			if ($cast(uvm_final_phase$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_final_phase"};
			if ($cast(uvm_get_export$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_get_export"};
			//          if ($cast(uvm_get_imp$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_get_imp"};
			if ($cast(uvm_get_peek_export$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_get_peek_export"};
			//          if ($cast(uvm_get_peek_imp$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_get_peek_imp"};
			if ($cast(uvm_get_peek_port$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_get_peek_port"};
			if ($cast(uvm_get_port$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_get_port"};
			if ($cast(uvm_get_to_lock_dap$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_get_to_lock_dap"};
			if ($cast(uvm_hdl_path_concat$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_hdl_path_concat"};
			if ($cast(uvm_heartbeat$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_heartbeat"};
			if ($cast(uvm_if_base_abstract$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_if_base_abstract"};
			//          if ($cast(uvm_in_order_built_in_comparator$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_in_order_built_in_comparator"};
			//          if ($cast(uvm_in_order_class_comparator$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_in_order_class_comparator"};
			//          if ($cast(uvm_in_order_comparator$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_in_order_comparator"};
			if ($cast(uvm_line_printer$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_line_printer"};
			if ($cast(uvm_link_base$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_link_base"};
			if ($cast(uvm_main_phase$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_main_phase"};
			if ($cast(uvm_mem$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_mem"};
			if ($cast(uvm_mem_access_seq$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_mem_access_seq"};
			if ($cast(uvm_mem_mam$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_mem_mam"};
			if ($cast(uvm_mem_mam_cfg$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_mem_mam_cfg"};
			if ($cast(uvm_mem_mam_policy$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_mem_mam_policy"};
			if ($cast(uvm_mem_region$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_mem_region"};
			if ($cast(uvm_mem_shared_access_seq$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_mem_shared_access_seq"};
			if ($cast(uvm_mem_single_access_seq$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_mem_single_access_seq"};
			if ($cast(uvm_mem_single_walk_seq$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_mem_single_walk_seq"};
			if ($cast(uvm_mem_walk_seq$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_mem_walk_seq"};
			if ($cast(uvm_monitor$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_monitor"};
			if ($cast(uvm_nonblocking_get_export$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_nonblocking_get_export"};
			//          if ($cast(uvm_nonblocking_get_imp$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_nonblocking_get_imp"};
			if ($cast(uvm_nonblocking_get_peek_export$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_nonblocking_get_peek_export"};
			//          if ($cast(uvm_nonblocking_get_peek_imp$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_nonblocking_get_peek_imp"};
			if ($cast(uvm_nonblocking_get_peek_port$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_nonblocking_get_peek_port"};
			if ($cast(uvm_nonblocking_get_port$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_nonblocking_get_port"};
			if ($cast(uvm_nonblocking_peek_export$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_nonblocking_peek_export"};
			//          if ($cast(uvm_nonblocking_peek_imp$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_nonblocking_peek_imp"};
			if ($cast(uvm_nonblocking_peek_port$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_nonblocking_peek_port"};
			if ($cast(uvm_nonblocking_put_export$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_nonblocking_put_export"};
			//          if ($cast(uvm_nonblocking_put_imp$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_nonblocking_put_imp"};
			if ($cast(uvm_nonblocking_put_port$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_nonblocking_put_port"};
			if ($cast(uvm_object$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_object"};
//			if ($cast(uvm_object_registry$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_object_registry"};
//			if ($cast(uvm_object_string_pool$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_object_string_pool"};
			if ($cast(uvm_object_wrapper$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_object_wrapper"};
			if ($cast(uvm_objection$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_objection"};
			if ($cast(uvm_objection_callback$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_objection_callback"};
			if ($cast(uvm_packer$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_packer"};
			if ($cast(uvm_parent_child_link$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_parent_child_link"};
			if ($cast(uvm_peek_export$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_peek_export"};
			//          if ($cast(uvm_peek_imp$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_peek_imp"};
			if ($cast(uvm_peek_port$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_peek_port"};
			if ($cast(uvm_phase$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_phase"};
			if ($cast(uvm_phase_cb$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_phase_cb"};
			if ($cast(uvm_phase_cb_pool$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_phase_cb_pool"};
			if ($cast(uvm_phase_state_change$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_phase_state_change"};
			if ($cast(uvm_pool$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_pool"};
			//          if ($cast(uvm_port_base$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_port_base"};
			//          if ($cast(uvm_port_component$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_port_component"};
			//          if ($cast(uvm_port_component_base$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_port_component_base"};
			if ($cast(uvm_post_configure_phase$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_post_configure_phase"};
			if ($cast(uvm_post_main_phase$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_post_main_phase"};
			if ($cast(uvm_post_reset_phase$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_post_reset_phase"};
			if ($cast(uvm_post_shutdown_phase$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_post_shutdown_phase"};
			if ($cast(uvm_pre_configure_phase$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_pre_configure_phase"};
			if ($cast(uvm_pre_main_phase$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_pre_main_phase"};
			if ($cast(uvm_pre_reset_phase$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_pre_reset_phase"};
			if ($cast(uvm_pre_shutdown_phase$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_pre_shutdown_phase"};
			if ($cast(uvm_printer$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_printer"};
			if ($cast(uvm_printer_knobs$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_printer_knobs"};
			if ($cast(uvm_push_driver$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_push_driver"};
			if ($cast(uvm_push_sequencer$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_push_sequencer"};
			if ($cast(uvm_put_export$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_put_export"};
			//          if ($cast(uvm_put_imp$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_put_imp"};
			if ($cast(uvm_put_port$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_put_port"};
			if ($cast(uvm_queue$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_queue"};
//			if ($cast(uvm_random_stimulus$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_random_stimulus"};
			if ($cast(uvm_recorder$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_recorder"};
			if ($cast(uvm_reg$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_reg"};
			if ($cast(uvm_reg_access_seq$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_reg_access_seq"};
			if ($cast(uvm_reg_adapter$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_reg_adapter"};
			if ($cast(uvm_reg_backdoor$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_reg_backdoor"};
			if ($cast(uvm_reg_bit_bash_seq$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_reg_bit_bash_seq"};
			if ($cast(uvm_reg_block$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_reg_block"};
			//          if ($cast(uvm_reg_bus_op$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_reg_bus_op"};
			if ($cast(uvm_reg_cbs$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_reg_cbs"};
			if ($cast(uvm_reg_field$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_reg_field"};
			if ($cast(uvm_reg_fifo$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_reg_fifo"};
			if ($cast(uvm_reg_file$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_reg_file"};
			if ($cast(uvm_reg_frontdoor$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_reg_frontdoor"};
			if ($cast(uvm_reg_hw_reset_seq$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_reg_hw_reset_seq"};
			if ($cast(uvm_reg_indirect_data$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_reg_indirect_data"};
			if ($cast(uvm_reg_item$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_reg_item"};
			if ($cast(uvm_reg_map$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_reg_map"};
			if ($cast(uvm_reg_mem_access_seq$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_reg_mem_access_seq"};
			if ($cast(uvm_reg_mem_built_in_seq$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_reg_mem_built_in_seq"};
			if ($cast(uvm_reg_mem_hdl_paths_seq$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_reg_mem_hdl_paths_seq"};
			if ($cast(uvm_reg_mem_shared_access_seq$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_reg_mem_shared_access_seq"};
			//          if ($cast(uvm_reg_predictor$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_reg_predictor"};
			if ($cast(uvm_reg_read_only_cbs$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_reg_read_only_cbs"};
			if ($cast(uvm_reg_sequence$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_reg_sequence"};
			if ($cast(uvm_reg_shared_access_seq$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_reg_shared_access_seq"};
			if ($cast(uvm_reg_single_access_seq$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_reg_single_access_seq"};
			if ($cast(uvm_reg_single_bit_bash_seq$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_reg_single_bit_bash_seq"};
			if ($cast(uvm_reg_tlm_adapter$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_reg_tlm_adapter"};
			if ($cast(uvm_reg_transaction_order_policy$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_reg_transaction_order_policy"};
			if ($cast(uvm_reg_write_only_cbs$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_reg_write_only_cbs"};
			if ($cast(uvm_related_link$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_related_link"};
			if ($cast(uvm_report_catcher$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_report_catcher"};
			if ($cast(uvm_report_handler$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_report_handler"};
			if ($cast(uvm_report_message$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_report_message"};
			if ($cast(uvm_report_message_element_base$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_report_message_element_base"};
			if ($cast(uvm_report_message_element_container$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_report_message_element_container"};
			if ($cast(uvm_report_message_int_element$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_report_message_int_element"};
			if ($cast(uvm_report_message_object_element$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_report_message_object_element"};
			if ($cast(uvm_report_message_string_element$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_report_message_string_element"};
			if ($cast(uvm_report_object$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_report_object"};
			if ($cast(uvm_report_phase$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_report_phase"};
			if ($cast(uvm_report_server$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_report_server"};
			if ($cast(uvm_reset_phase$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_reset_phase"};
			if ($cast(uvm_resource$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_resource"};
			if ($cast(uvm_resource_base$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_resource_base"};
			if ($cast(uvm_resource_db$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_resource_db"};
			if ($cast(uvm_resource_db_options$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_resource_db_options"};
			if ($cast(uvm_resource_options$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_resource_options"};
			if ($cast(uvm_resource_pool$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_resource_pool"};
			if ($cast(uvm_resource_types$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_resource_types"};
			if ($cast(uvm_root$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_root"};
			if ($cast(uvm_run_phase$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_run_phase"};
			if ($cast(uvm_scoreboard$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_scoreboard"};
			//          if ($cast(uvm_seq_item_pull_export$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_seq_item_pull_export"};
			//          if ($cast(uvm_seq_item_pull_imp$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_seq_item_pull_imp"};
			//          if ($cast(uvm_seq_item_pull_port$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_seq_item_pull_port"};
			if ($cast(uvm_sequence$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_sequence"};
			if ($cast(uvm_sequence_base$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_sequence_base"};
			if ($cast(uvm_sequence_item$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_sequence_item"};
			if ($cast(uvm_sequence_library$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_sequence_library"};
			if ($cast(uvm_sequence_library_cfg$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_sequence_library_cfg"};
			if ($cast(uvm_sequencer$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_sequencer"};
			if ($cast(uvm_sequencer_base$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_sequencer_base"};
			if ($cast(uvm_sequencer_param_base$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_sequencer_param_base"};
			if ($cast(uvm_set_before_get_dap$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_set_before_get_dap"};
			if ($cast(uvm_set_get_dap_base$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_set_get_dap_base"};
			if ($cast(uvm_shutdown_phase$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_shutdown_phase"};
			if ($cast(uvm_simple_lock_dap$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_simple_lock_dap"};
			if ($cast(uvm_sqr_if_base$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_sqr_if_base"};
			if ($cast(uvm_start_of_simulation_phase$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_start_of_simulation_phase"};
			if ($cast(uvm_structure_proxy$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_structure_proxy"};
			if ($cast(uvm_subscriber$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_subscriber"};
			if ($cast(uvm_table_printer$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_table_printer"};
			if ($cast(uvm_task_phase$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_task_phase"};
			if ($cast(uvm_test$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_test"};
			if ($cast(uvm_text_recorder$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_text_recorder"};
			if ($cast(uvm_text_tr_database$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_text_tr_database"};
			if ($cast(uvm_text_tr_stream$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_text_tr_stream"};
			if ($cast(uvm_tlm_analysis_fifo$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_tlm_analysis_fifo"};
			//          if ($cast(uvm_tlm_b_initiator_socket$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_tlm_b_initiator_socket"};
			//          if ($cast(uvm_tlm_b_initiator_socket_base$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_tlm_b_initiator_socket_base"};
			//          if ($cast(uvm_tlm_b_passthrough_initiator_socket$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_tlm_b_passthrough_initiator_socket"};
			//          if ($cast(uvm_tlm_b_passthrough_initiator_socket_base$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_tlm_b_passthrough_initiator_socket_base"};
			//          if ($cast(uvm_tlm_b_passthrough_target_socket$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_tlm_b_passthrough_target_socket"};
			//          if ($cast(uvm_tlm_b_passthrough_target_socket_base$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_tlm_b_passthrough_target_socket_base"};
			//          if ($cast(uvm_tlm_b_target_socket$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_tlm_b_target_socket"};
			//          if ($cast(uvm_tlm_b_target_socket_base$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_tlm_b_target_socket_base"};
			if ($cast(uvm_tlm_b_transport_export$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_tlm_b_transport_export"};
			//          if ($cast(uvm_tlm_b_transport_imp$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_tlm_b_transport_imp"};
			if ($cast(uvm_tlm_b_transport_port$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_tlm_b_transport_port"};
			if ($cast(uvm_tlm_extension$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_tlm_extension"};
			if ($cast(uvm_tlm_extension_base$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_tlm_extension_base"};
			if ($cast(uvm_tlm_fifo$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_tlm_fifo"};
			if ($cast(uvm_tlm_fifo_base$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_tlm_fifo_base"};
			if ($cast(uvm_tlm_generic_payload$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_tlm_generic_payload"};
			if ($cast(uvm_tlm_gp$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_tlm_gp"};
			if ($cast(uvm_tlm_if$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_tlm_if"};
			if ($cast(uvm_tlm_if_base$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_tlm_if_base"};
			//          if ($cast(uvm_tlm_nb_initiator_socket$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_tlm_nb_initiator_socket"};
			//          if ($cast(uvm_tlm_nb_initiator_socket_base$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_tlm_nb_initiator_socket_base"};
			//          if ($cast(uvm_tlm_nb_passthrough_initiator_socket$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_tlm_nb_passthrough_initiator_socket"};
			//          if ($cast(uvm_tlm_nb_passthrough_initiator_socket_base$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_tlm_nb_passthrough_initiator_socket_base"};
			//          if ($cast(uvm_tlm_nb_passthrough_target_socket$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_tlm_nb_passthrough_target_socket"};
			//          if ($cast(uvm_tlm_nb_passthrough_target_socket_base$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_tlm_nb_passthrough_target_socket_base"};
			//          if ($cast(uvm_tlm_nb_target_socket$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_tlm_nb_target_socket"};
			//          if ($cast(uvm_tlm_nb_target_socket_base$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_tlm_nb_target_socket_base"};
			if ($cast(uvm_tlm_nb_transport_bw_export$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_tlm_nb_transport_bw_export"};
			//          if ($cast(uvm_tlm_nb_transport_bw_imp$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_tlm_nb_transport_bw_imp"};
			if ($cast(uvm_tlm_nb_transport_bw_port$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_tlm_nb_transport_bw_port"};
			if ($cast(uvm_tlm_nb_transport_fw_export$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_tlm_nb_transport_fw_export"};
			//          if ($cast(uvm_tlm_nb_transport_fw_imp$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_tlm_nb_transport_fw_imp"};
			if ($cast(uvm_tlm_nb_transport_fw_port$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_tlm_nb_transport_fw_port"};
			if ($cast(uvm_tlm_req_rsp_channel$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_tlm_req_rsp_channel"};
			if ($cast(uvm_tlm_time$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_tlm_time"};
			if ($cast(uvm_tlm_transport_channel$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_tlm_transport_channel"};
			if ($cast(uvm_top_down_visitor_adapter$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_top_down_visitor_adapter"};
			if ($cast(uvm_topdown_phase$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_topdown_phase"};
			if ($cast(uvm_tr_database$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_tr_database"};
			if ($cast(uvm_tr_stream$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_tr_stream"};
			if ($cast(uvm_transaction$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_transaction"};
			if ($cast(uvm_tree_printer$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_tree_printer"};
			//          if ($cast(uvm_utils$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_utils"};
			if ($cast(uvm_visitor$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_visitor"};
			if ($cast(uvm_visitor_adapter$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_visitor_adapter"};
			if ($cast(uvm_void$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_void"};
			if ($cast(uvm_vreg$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_vreg"};
			if ($cast(uvm_vreg_cbs$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_vreg_cbs"};
			if ($cast(uvm_vreg_field$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_vreg_field"};
			if ($cast(uvm_vreg_field_cbs$, target_object)) uvm_classes = {uvm_classes, ",", "uvm_vreg_field_cbs"};

			// Destroy the temp object we created.
			//
			target_object = null;

			// Trim leading comma.
			//
			if (uvm_classes.len() > 0) begin
				uvm_classes = uvm_classes.substr(1, uvm_classes.len() - 1);
			end

			return uvm_classes;
		end

	endfunction : list_uvm_classes_of_object


// ===================================================================
	class metacatalog;
// ===================================================================
		static function void _metacatalog_metadata();
			`FUNCTION_METADATA('{
					// Ironically can't use CLASS_METADATA here because the metacatalog is not a uvm_object.
					// So we use a dummy function to apply metadata to this class.

					name:
					"metacatalog",

					description:
					"Provides utilities for registering and retrieving metadata structures in the UVM resource database.",

					details: {
						"Implemented as a singleton. ",
						"To retrieve its instance use the static function meta_pkg::metacatalog::get(). "
					},

					categories:
					"class",

					// Override `metatype` since we're not using the `CLASS_METADATA` macro.
					metatype:
					"CLASS_TYPE",

					string:
					"" // Required
				})
// =================================================================//
		endfunction : _metacatalog_metadata

		local static metacatalog singleton;

		// Some arcana for using the `uvm_resource_pool` lookup functions
		static uvm_resource#(meta_pkg::metadata_t) metadata_type_template = new();


// ===================================================================
		local function new(string name = "");
// ===================================================================
		endfunction : new


// ===================================================================
		static function metacatalog get;
// ===================================================================
			`FUNCTION_METADATA('{

					description:
					"Return a handle to the singleton metacatalog object.",

					attributes:
					"metadata",

					string: ""
				})

			// Parameters:
			// None

// ===================================================================
			if (singleton == null) begin
				singleton = new("metacatalog");
			end
			return singleton;
		endfunction : get


// ===================================================================
		virtual function metadata_t register_class_metadata;
// ===================================================================
			`FUNCTION_METADATA('{

					description:
					"Register the given class metadata in the metacatalog and return a new, completed metadata struct.",

					details: {
						"Takes user-supplied metadata, auto-fills several fields, and registers it in the metacatalog. ",
						"Returns the auto-filled metadata so it can be stored as a static property of the class. ",
						"Don't call this function directly. ",
						"Instead use the `CLASS_METADATA()` macro. ",
						"The macro fills in most of the arguments for you. ",
						""
					},

					attributes:
					"metadata",

					string: ""
				})

			// Parameters:

			input uvm_object_wrapper obj;       // The component or object proxy for the class as returned by `uvm_object::get_type()`

			input uvm_object_wrapper type_id;   // The component or object proxy for the class as returned by `uvm_object::type_id::get()`

			input metadata_t metadata;          // The user-supplied metadata struct

			input string file;                  // The filename for the metadata `file` field, typically `__FILE__

			input int line;                     // The line number for the metadata `line` field, typically `__LINE__

// ===================================================================

			metatype_t metatype = CLASS_TYPE;
			string uvm_classes = "";
			string options_q[$];
			bit options_hash[string];
			bit ok;

			// Slurp all options into an associative array
			ok = csv_to_list(options_q, metadata.metaoptions);
			assert (ok) else `uvm_error("print", "Failed to parse metaoptions")
			foreach (options_q[i]) begin
				options_hash[options_q[i]] = 1;
			end

			// Auto-fill blank metadata

			if (metadata.name == "") begin
				if (obj.get_type_name() == "") begin
					if (type_id.get_type_name() == "") begin
						`uvm_warning("metacatalog", {"Class metadata at file ", file, " line ", $sformatf("%0d", line), " does not specify a value for `name`."})
					end
					else begin
						metadata.name = type_id.get_type_name();
					end
				end
				else begin
					metadata.name = obj.get_type_name();
				end
			end
			else `uvm_info("metacatalog", {"Class ", metadata.name, " metadata `name` field has user-supplied value; it will not be auto-filled."}, UVM_HIGH)

			if (metadata.metatype == "") metadata.metatype = metatype.name();
			else `uvm_info("metacatalog", {"Class ", metadata.name, " metadata `metatype` field has user-supplied value; it will not be auto-filled."}, UVM_HIGH)

			if (metadata.type_id == "") metadata.type_id = type_id.get_type_name();
			else `uvm_info("metacatalog", {"Class ", metadata.name, " metadata `type_id` field has user-supplied value; it will not be auto-filled."}, UVM_HIGH)

			if (metadata.file == "") metadata.file = file;
			else `uvm_info("metacatalog", {"Class ", metadata.name, " metadata `file` field has user-supplied value; it will not be auto-filled."}, UVM_HIGH)

			if (metadata.line == "") begin
				if (line > 0) begin
					metadata.line.itoa(line);
				end
			end
			else `uvm_info("metacatalog", {"Class ", metadata.name, " metadata `line` field has user-supplied value; it will not be auto-filled."}, UVM_HIGH)

			if (!options_hash.exists("disable_auto_base_class_listing")) begin
				uvm_classes = list_uvm_classes_of_object(obj);
			end
			if (metadata.categories == "") begin
				metadata.categories = uvm_classes;
			end
			else if (uvm_classes != "") begin
				metadata.categories = {metadata.categories, ",", uvm_classes};
			end

			if (!options_hash.exists("do_not_register")) begin
				uvm_resource_db#(metadata_t)::set("*", metadata.name, metadata);
				`uvm_info("metacatalog", {"Registered ", metadata.metatype, " metadata ", metadata.name}, UVM_HIGH)
			end

			// Return the auto-filled metadata for storage in the class
			return metadata;
		endfunction : register_class_metadata


// ===================================================================
		virtual function metadata_t register_block_metadata;
// ===================================================================
			`FUNCTION_METADATA('{

					description:
					"Register the given block metadata in the metacatalog and return a new, completed metadata struct.",

					details: {
						"Block metadata is typically used for modules and files. ",
						"Takes user-supplied metadata, auto-fills several fields, and registers it in the metacatalog. ",
						"Returns the auto-filled metadata so it can be stored as a variable in the block. ",
						"Don't call this function directly. ",
						"Instead use the `BLOCK_METADATA()` or `FILE_METADATA()` macro. ",
						"The macros fill in most of the arguments for you. ",
						""
					},

					attributes:
					"metadata",

					string: ""
				})

			// Parameters:

			input metadata_t metadata;          // The user-supplied metadata struct

			input string hierarchical_name;     // The hierarchical path name to the metadata block

			input metatype_t metatype;          // The type for the metadata `metatype` field, typically `BLOCK_TYPE` or `FILE_TYPE`

			input string file;                  // The filename for the metadata `file` field, typically `__FILE__

			input int line;                     // The line number for the metadata `line` field, typically `__LINE__

// ===================================================================

			string options_q[$];
			bit options_hash[string];
			bit ok;

			// Slurp all options into an associative array
			ok = csv_to_list(options_q, metadata.metaoptions);
			assert (ok) else `uvm_error("print", "Failed to parse metaoptions")
			foreach (options_q[i]) begin
				options_hash[options_q[i]] = 1;
			end

			// Auto-fill blank metadata

			if (metadata.metatype == "") metadata.metatype = metatype.name();
			else `uvm_info("metacatalog", {"Block ", metadata.name, " metadata `metatype` field has user-supplied value; it will not be auto-filled."}, UVM_HIGH)

			if (metadata.metatype == "FILE_TYPE") begin
				if (metadata.name == "") begin : get_name_from_filename
					string tokens[$];
					string temp_name;
					bit ok;

					ok = split_string(tokens, metadata.file, "/");
					assert (ok);
					if (tokens.size() >= 1) begin
						temp_name = tokens.pop_back();
					end
					metadata.name = temp_name;
				end
			end
			else if (metadata.name == "") begin : get_name_from_block_hierarchical_name
				string tokens[$];
				string temp_name;
				bit ok;

				ok = split_string(tokens, metadata.hierarchical_name, ".");
				assert (ok);
				if (tokens.size() >= 1) begin
					temp_name = tokens.pop_back();
					if (temp_name == "_metadata_block") begin : if_leaf_block_is_the_metadata_block_go_up_one_more_level
						if (tokens.size() >= 1) begin
							temp_name = tokens.pop_back();
						end
					end
				end
				metadata.name = temp_name;
			end

			if (metadata.name == "")
				`uvm_warning("metacatalog", {"Block metadata at file ", file, " line ", $sformatf("%0d", line), " does not specify a value for `name`."})

			if (metadata.hierarchical_name == "") metadata.hierarchical_name = hierarchical_name;
			else `uvm_info("metacatalog", {"Block ", metadata.name, " metadata `hierarchical_name` field has user-supplied value; it will not be auto-filled."}, UVM_HIGH)

			if (metadata.file == "") metadata.file = file;
			else `uvm_info("metacatalog", {"Block ", metadata.name, " metadata `file` field has user-supplied value; it will not be auto-filled."}, UVM_HIGH)

			if (metadata.line == "") begin
				if (line > 0) begin
					metadata.line.itoa(line);
				end
			end
			else `uvm_info("metacatalog", {"Block ", metadata.name, " metadata `line` field has user-supplied value; it will not be auto-filled."}, UVM_HIGH)

			if (!options_hash.exists("do_not_register")) begin
				uvm_resource_db#(metadata_t)::set("*", metadata.name, metadata);
				`uvm_info("metacatalog", {"Registered ", metadata.metatype, " metadata ", metadata.name, " for ", metadata.hierarchical_name}, UVM_HIGH)
			end

			// Return the auto-filled metadata for storage in the class
			return metadata;

		endfunction : register_block_metadata


// ===================================================================
		virtual function metadata_t register_subroutine_metadata;
// ===================================================================
			`FUNCTION_METADATA('{

					description:
					"Register the given subroutine metadata in the metacatalog and return a new, completed metadata struct.",

					details: {
						"Subroutine metadata is typically used for tasks and functions. ",
						"Takes user-supplied metadata, auto-fills several fields, and registers it in the metacatalog. ",
						"Returns the auto-filled metadata so it can be stored as a static variable in the subroutine. ",
						"Don't call this function directly. ",
						"Instead use the `TASK_METADATA()` or `FUNCTION_METADATA()` macro. ",
						"The macros fill in most of the arguments for you. ",
						""
					},

					attributes:
					"metadata",

					string: ""
				})

			// Parameters:

			input metadata_t metadata;          // The user-supplied metadata struct

			input string hierarchical_name;     // The hierarchical path name to the metadata block

			input metatype_t metatype;          // The type for the metadata `metatype` field, typically `TASK_TYPE` or `FUNCTION_TYPE`

			input string file;                  // The filename for the metadata `file` field, typically `__FILE__

			input int line;                     // The line number for the metadata `line` field, typically `__LINE__

// ===================================================================

			string options_q[$];
			bit options_hash[string];
			bit ok;

			// Slurp all options into an associative array
			ok = csv_to_list(options_q, metadata.metaoptions);
			assert (ok) else `uvm_error("print", "Failed to parse metaoptions")
			foreach (options_q[i]) begin
				options_hash[options_q[i]] = 1;
			end

			// Auto-fill blank metadata

			if (metadata.metatype == "") metadata.metatype = metatype.name();
			else `uvm_info("metacatalog", {"Subroutine ", metadata.name, " metadata metatype field has user-supplied value; it will not be auto-filled."}, UVM_HIGH)

			if (metadata.name == "") begin : get_name_from_hierarchical_name
				string tokens[$];
				string temp_name;
				bit ok;

				ok = split_string(tokens, hierarchical_name, ".");
				assert (ok);
				if (tokens.size() >= 1) begin
					temp_name = tokens.pop_back();
				end
				metadata.name = temp_name;
			end

			if (metadata.name == "")
				`uvm_warning("metacatalog", {"Subroutine metadata at file ", file, " line ", $sformatf("%0d", line), " does not specify a value for `name`."})

			if (metadata.hierarchical_name == "") metadata.hierarchical_name = hierarchical_name;
			else `uvm_info("metacatalog", {"Subroutine ", metadata.name, " metadata `hierarchical_name` field has user-supplied value; it will not be auto-filled."}, UVM_HIGH)

			if (metadata.file == "") metadata.file = file;
			else `uvm_info("metacatalog", {"Subroutine ", metadata.name, " metadata `file` field has user-supplied value; it will not be auto-filled."}, UVM_HIGH)

			if (metadata.line == "") begin
				if (line > 0) begin
					metadata.line.itoa(line);
				end
			end
			else `uvm_info("metacatalog", {"Subroutine ", metadata.name, " metadata `line` field has user-supplied value; it will not be auto-filled."}, UVM_HIGH)

			if (!options_hash.exists("do_not_register")) begin
				uvm_resource_db#(metadata_t)::set("*", metadata.name, metadata);
				`uvm_info("metacatalog", {"Registered ", metadata.metatype, " metadata ", metadata.name, " for ", metadata.hierarchical_name}, UVM_HIGH)
			end

			// Return the auto-filled metadata for storage in the class
			return metadata;

		endfunction : register_subroutine_metadata


// ===================================================================
		virtual function void rsrc_q_to_metadata_q;
// ===================================================================
			`FUNCTION_METADATA('{

					description:
					"Convert a UVM resource `rsrc_q_t` queue to a SystemVerilog queue of `metadata_t`.",

					details: {
						"UVM resource lookup functions return results in a parameterized queue of type `rsrc_q_t`. ",
						"This function transfers metadata items in the resource queue to the supplied SystemVerilog queue of `metadata_t`, replacing its contents. ",
						"Any non-metadata items in the incoming queue are ignored. ",
						""
					},

					attributes:
					"metadata",

					string: ""
				})

			// Parameters:

			ref metadata_t metadata_q[$];               // Outgoing metadata queue, extracted from the incoming resource queue

			ref uvm_resource_types::rsrc_q_t rsrc_q;    // Incoming resource queue received from a UVM resource lookup function

// ===================================================================

			metadata_q.delete();
			for (int i = 0; i < rsrc_q.size(); i++) begin
				uvm_resource_base rsrc;
				metadata_t metadata;
				uvm_resource#(metadata_t) metadata_resource;
				int success;

				rsrc = rsrc_q.get(i);
				success = $cast(metadata_resource, rsrc);
				if (success) begin
					// The payload must be "read" from the resource
					metadata = metadata_resource.read();

					metadata_q.push_back(metadata);
				end
			end
		endfunction : rsrc_q_to_metadata_q


// ===================================================================
		static function uvm_resource_base get_metadata_type_handle;
// ===================================================================
			// Some arcana for using the `uvm_resource_pool` lookup functions

			return metadata_type_template.get_type_handle();
		endfunction : get_metadata_type_handle


// ===================================================================
		virtual function void lookup_name;
// ===================================================================
			`FUNCTION_METADATA('{

					description:
					"Lookup metadata by name and return matches in the supplied queue.",

					details: {
						"Returns all metadata items that match the name.\n",
						"Example:\n",
						"    metadata_t q[$];", "\n",
						"    meta_pkg::metacatalog::get().lookup_name(q, \"reset_block\");", "\n",
						""
					},

					categories:
					"",

					attributes:
					"metadata",

					string:
					"" // Required
				})

			// Parameters:

			ref metadata_t metadata_q[$]; // Receives the returned metadata

			input string name;            // Name of the elements to match

// ===================================================================

			uvm_resource_types::rsrc_q_t rsrc_q;

			rsrc_q = uvm_resource_pool::get().lookup_name("", name, get_metadata_type_handle());
			rsrc_q_to_metadata_q(metadata_q, rsrc_q);
		endfunction : lookup_name


// ===================================================================
		virtual function metadata_t get_by_name;
// ===================================================================
			`FUNCTION_METADATA('{

					description:
					"Lookup metadata by name.",

					details: {
						"Returns one metadata item, even if multiple items match the name.\n",
						"Example:\n",
						"    metadata_t m = meta_pkg::metacatalog::get().get_by_name(\"meta_pkg.sv\");\n",
						"    $display(\"%p\", m);\n",
						""
					},

					attributes:
					"metadata",

					string:
					"" // Required
				})

			// Parameters:

			input string name;  // Name of the element

// ===================================================================
			uvm_resource_base rsrc;
			metadata_t metadata;
			uvm_resource#(metadata_t) metadata_resource;
			int success;

			rsrc = uvm_resource_pool::get().get_by_name("", name, get_metadata_type_handle());
			success = $cast(metadata_resource, rsrc);
			assert (success);
			metadata = metadata_resource.read();
			return metadata;
		endfunction : get_by_name


// ===================================================================
		virtual function void lookup_metadata;
// ===================================================================
			`FUNCTION_METADATA('{

					description:
					"Lookup all metadata.",

					details: {
						"Fills the supplied queue of type `metadata_t` with all metadata items.\n",
						"Example:\n",
						"    metadata_t q[$];\n",
						"    meta_pkg::metacatalog::get().lookup_metadata(q);\n",
						"    foreach (q[i]) $display(\"%p\", q[i]);\n",
						""
					},

					categories:
					"",

					attributes:
					"metadata",

					string:
					"" // Required
				})

			// Parameters:

			ref metadata_t metadata_q[$]; // Receives the returned metadata

// ===================================================================
			uvm_resource_types::rsrc_q_t rsrc_q;
			rsrc_q = uvm_resource_pool::get().lookup_type("", get_metadata_type_handle());
			rsrc_q_to_metadata_q(metadata_q, rsrc_q);
		endfunction : lookup_metadata


// ===================================================================
		virtual function void lookup_regex;
// ===================================================================
			`FUNCTION_METADATA('{

					description:
					"Lookup all metadata whose name matches regular expression.",

					details: {
						"Fills the supplied queue of type `metadata_t` with matching items. ",
						"Regular expression for name is given in a string. ",
						"If `re` is in /slashes/ then it's interpreted as a proper regular expression. ",
						"Otherwise it's interpreted as a glob (i.e. wildcards `*` and `?`). ",
						"Example:\n",
						"    metadata_t q[$];\n",
						"    // Regex matches metadata whose name starts with 'mem_'\n",
						"    meta_pkg::metacatalog::get().lookup_regex(q, \"/^mem_/\");\n",
						"    foreach (q[i]) $display(\"%p\", q[i]);\n",
						"\n",
						"    // Glob matches metadata whose name starts with 'mem_'\n",
						"    meta_pkg::metacatalog::get().lookup_regex(q, \"mem_*\");\n",
						"    foreach (q[i]) $display(\"%p\", q[i]);\n",
						""
					},

					categories:
					"",

					attributes:
					"metadata",

					string:
					"" // Required
				})

			// Parameters:

			ref metadata_t metadata_q[$]; // Receives the returned metadata

			input string re;              // Regular expression or glob for names

// ===================================================================
			uvm_resource_types::rsrc_q_t rsrc_q;

			rsrc_q = uvm_resource_pool::get().lookup_regex(re, "");
			rsrc_q_to_metadata_q(metadata_q, rsrc_q);
		endfunction : lookup_regex


// ===================================================================
		virtual function void print;
// ===================================================================
			`FUNCTION_METADATA('{

					description:
					"Print all metadata to the simulator output log file.",

					details: {
						"Output is lightly formatted for legibility. ",
						"Empty metadata fields are omitted. "
					},

					attributes:
					"metadata",

					string: ""
				})

			// Parameters:
			// None

// ===================================================================
			metadata_t metadata_q[$];

			lookup_metadata(metadata_q);

			$display("Catalog");
			$display("=======");
			$display("```");

			foreach (metadata_q[i]) begin
				string categories[$];
				string attributes[$];
				bit ok;
				metadata_t metadata;

				metadata = metadata_q[i];

				$display({"Metatype:\n\t", metadata.metatype});

				$display({"Name:\n\t", metadata.name});

				if (metadata.description != "") $display({"Description:\n\t", metadata.description});

				if (metadata.categories != "") begin
					$display({"Categories as string:\n\t", metadata.categories});
					ok = csv_to_list(categories, metadata.categories);
					assert (ok) else `uvm_error("print", "Failed to parse categories")
					$write("Categories as list:\n\t(");
					foreach (categories[j]) begin
						$write({j ? "," : "", categories[j]});
					end
					$write(")\n");
				end

				if (metadata.attributes != "") begin
					$display({"Attributes as string:\n\t", metadata.attributes});
					ok = csv_to_list(attributes, metadata.attributes);
					assert (ok) else `uvm_error("print", "Failed to parse attributes")
					$write("Attributes as list:\n\t(");
					foreach (attributes[j]) begin
						$write({j ? "," : "", attributes[j]});
					end
					$write(")\n");
				end

				if (metadata.details != "") begin
					$write("Details:\n\t");
					foreach (metadata.details[j]) begin
						byte c = metadata.details.getc(j);
						$write("%s", c);
						if (c == "\n") $write("\t");
					end
					$write("\n");
				end

				if (metadata.type_id != "") $display({"Type ID: \n\t", metadata.type_id});

				if (metadata.hierarchical_name != "") $display({"Hierarchical Name: \n\t", metadata.hierarchical_name});

				if (metadata.file != "") $display({"File:\n\t", metadata.file, " (", metadata.line, ")"});

				if (metadata.id != "") $display({"RCS Id:\n\t", metadata.id});

				if (metadata.header != "") $display({"RCS Header:\n\t", metadata.header});

				if (metadata.date != "") $display({"RCS Date:\n\t", metadata.date});

				if (metadata.date_time != "") $display({"RCS DateTime:\n\t", metadata.date_time});

				if (metadata.change != "") $display({"RCS Change:\n\t", metadata.change});

				if (metadata.depot_file != "") $display({"RCS File:\n\t", metadata.depot_file});

				if (metadata.author != "") $display({"RCS Author:\n\t", metadata.author});

				$display("\n---");
			end
			$display("```");
		endfunction : print


// ===================================================================
		virtual function void print_yaml;
// ===================================================================
			`FUNCTION_METADATA('{

					description:
					"Write all metadata to the specified YAML file.",

					details: {
						"The YAML file is human-readable. ",
						"It is also readily parsed by a post-processing script. ",
						""
					},

					attributes:
					"metadata",

					string: ""
				})

			// Parameters:

			input string filename;  // YAML filename. Conventional suffix is ".yaml".

// ===================================================================
			metadata_t metadata_q[$];
			int fd;

			fd = $fopen(filename, "w");

			lookup_metadata(metadata_q);

			$fdisplay(fd, "# metacatalog");

			foreach (metadata_q[i]) begin
				string categories[$];
				string attributes[$];
				bit ok;
				metadata_t metadata;

				metadata = metadata_q[i];

				$fdisplay(fd, "-");

				$fdisplay(fd, {"  metatype: ", metadata.metatype});

				$fdisplay(fd, {"  name: ", metadata.name});

				$fdisplay(fd, {"  description: ", metadata.description});

				ok = csv_to_list(categories, metadata.categories);
				assert (ok) else `uvm_error("print", "Failed to parse categories")
				$fwrite(fd, "  categories: [");
				foreach (categories[j]) begin
					$fwrite(fd, {j ? "," : "", categories[j]});
				end
				$fwrite(fd, "]\n");

				ok = csv_to_list(attributes, metadata.attributes);
				assert (ok) else `uvm_error("print", "Failed to parse attributes")
				$fwrite(fd, "  attributes: [");
				foreach (attributes[j]) begin
					$fwrite(fd, {j ? "," : "", attributes[j]});
				end
				$fwrite(fd, "]\n");

				$fdisplay(fd, {"  type_id: ", metadata.type_id});

				$fdisplay(fd, {"  hierarchical_name: ", metadata.hierarchical_name});

				$fdisplay(fd, {"  file: ", metadata.file});

				$fdisplay(fd, {"  line: ", metadata.line});

				$fdisplay(fd, {"  id: \"", metadata.id, "\""});

				$fdisplay(fd, {"  header: \"", metadata.header, "\""});

				$fdisplay(fd, {"  date: \"", metadata.date, "\""});

				$fdisplay(fd, {"  date_time: \"", metadata.date_time, "\""});

				$fdisplay(fd, {"  change: \"", metadata.change, "\""});

				$fdisplay(fd, {"  depot_file: \"", metadata.depot_file, "\""});

				$fdisplay(fd, {"  revision: \"", metadata.revision, "\""});

				$fdisplay(fd, {"  author: \"", metadata.author, "\""});

				$fdisplay(fd, "  details: |");
				$fwrite(fd, "    ");
				foreach (metadata.details[j]) begin
					byte c = metadata.details.getc(j);
					if (c == "#") $fwrite(fd, "\%s", c);
					else if (c == "\n") $fwrite(fd, "\n    ");
					else $fwrite(fd, "%s", c);
				end
				$fwrite(fd, "\n");
			end

			$fclose(fd);
		endfunction : print_yaml

	endclass : metacatalog


// ===================================================================
	class print_meta_catalog extends uvm_test;
// ===================================================================
		`CLASS_METADATA('{

				description:
				"UVM test prints the entire metacatalog in a variety of formats.",

				details: {
					"Command line: `run +UVM_TESTNAME=print_meta_catalog`\n",
					"- Prints the entire metacatalog to the log file.\n",
					"- Writes the entire metacatalog to YAML file 'print_meta_catalog.yaml'.\n",
					"- Prints all classes registered in the UVM factory. For diagnostic purposes.\n",
					"- Dumps the entire UVM resource database. For diagnostic purposes.\n",
					"- Dumps all metadata in the UVM resource pool. For diagnostic purposes.\n",
					"The most valuable output of this test is the metacatalog printout in the log file and the YAML file, ready for post-processing. ",
					""
				},

				attributes:
				"metadata",

				string: ""
			})
// ===================================================================

		`uvm_component_utils(print_meta_catalog)

		function new(string name, uvm_component parent);
			super.new(name, parent);
			uvm_config_db#(string)::set(null, "*", "test_name",get_type_name());
		endfunction : new

		virtual task run_phase(uvm_phase phase);
			uvm_resource_types::rsrc_q_t metacatalog;

			super.run_phase(phase);

			`uvm_info(get_name(), "Print my own metadata", UVM_NONE)
			$display("%p", get_metadata());

			`uvm_info(get_name(), "Print metacatalog", UVM_NONE)
			meta_pkg::metacatalog::get().print();

			`uvm_info(get_name(), "Print metacatalog.yaml", UVM_NONE)
			meta_pkg::metacatalog::get().print_yaml("print_meta_catalog.yaml");

			`uvm_info(get_name(), "Print uvm_factory", UVM_NONE)
			uvm_factory::get().print(2);

			`uvm_info(get_name(), "Dump uvm_resource_db", UVM_NONE)
			uvm_resource_db#()::dump();

			metacatalog = uvm_resource_pool::get().lookup_type("", meta_pkg::metacatalog::get_metadata_type_handle());

			`uvm_info(get_name(), "Print metadata from uvm_resource_pool", UVM_NONE)
			uvm_resource_pool::get().print_resources(metacatalog);

		endtask : run_phase

	endclass : print_meta_catalog


// ===================================================================
	interface class metadata_interface;
// ===================================================================
		/*
		 * Ironically an interface class cannot have live metadata so these are comments.
		 *
		 * description:
		 * Provides introspection of an object's metadata.
		 *
		 * details:
		 *   A class with metadata may optionally implement this interface.
		 *   With this interface you can use a polymorphic handle to query whether a class instance has metadata and to retrieve that metadata.
		 *   Without this interface, metadata can still be retrieved but you need to use the concrete class to do so.
		 *   Metadata is still stored in the metacatalog whether this interface is implemented or not.
		 *   The `CLASS_METADATA() macro automatically provides the implementation of the interface.
		 *
		 * Example:
		 *
		 * class my_class extends uvm_object implements meta_pkg::metadata_interface;
		 *     `CLASS_METADATA('{description: "Example of a class which implements metadata_interface.", string: ""})
		 * endclass
		 *
		 * class some_class;
		 *     meta_pkg::metadata_interface my_handle;
		 *     meta_pkg::metadata_t my_metadata;
		 *     my_class my_object = new("my_object");
		 *
		 *     if ($cast(my_handle, my_object)) begin
		 *         // Use the polymorphic handle `my_handle` to retrieve metadata
		 *         my_metadata = my_handle.get_metadata();
		 *         if (my_metadata) `uvm_info("metadata", my_metadata.description, UVM_LOW)
		 *         else `uvm_info("metadata", "Null metadata", UVM_LOW)
		 *     end
		 *     else begin
		 *         // You can still use the concrete class instance `my_object` to retrieve metadata
		 *         my_metadata = my_object.get_metadata();
		 *         if (my_metadata) `uvm_info("metadata", my_metadata.description, UVM_LOW)
		 *         else `uvm_info("metadata", "Null metadata", UVM_LOW)
		 *     end
		 * endclass
		 *
		 */
// ===================================================================

// ===================================================================
		pure virtual function meta_pkg::metadata_t get_metadata();
// ===================================================================
	/*
	 * Ironically a pure virtual function cannot have live metadata so these are comments.
	 *
	 * description:
	 * Returns the class' static metadata structure.
	 */
// ===================================================================

	endclass : metadata_interface
	
	
// ===================================================================
//
// Metadata Examples
//
// ===================================================================


// ===================================================================
	class _class_metadata_example extends uvm_object;
// ===================================================================
		`CLASS_METADATA('{

				description:
				"This is an example showing how to define class metadata.",

				details: {
					"Class metadata can only be applied to a uvm_object. ",
					"You can copy and paste this example into your class and replace this text with your own. ",
					"Locate the `CLASS_METADATA macro immediately after the class declaration as shown here. ",
					"Class metadata is a static class property. ",
					"It is allocated and initialized when the class is defined. ",
					"All instances of the class share the same static metadata. ",
					"Your class will automatically get a static function `get_class_metadata()` and a default implementation of virtual function `get_metadata()`. ",
					"Use the functions in your code to retrieve metadata from a class or object. ",
					"The functions are identical except the static function can be called on a class (e.g. `class::get_class_metadata()`) and the virtual function can be called on an object handle (e.g. `obj.get_metadata()`). ",
					""
				},

				categories:
				"example, class",

				attributes:
				"metadata, documentation",

				string:
				"" // Required
			})
// ===================================================================
		`uvm_object_utils(_class_metadata_example)

		function new(string name = "_class_metadata_example");
			super.new(name);
		endfunction : new


// ===================================================================
		task _task_metadata_example;
// ===================================================================
			`TASK_METADATA('{

					description:
					"This is an example showing how to define task metadata.",

					details: {
						"You can copy and paste this example into your task and replace this text with your own. ",
						"Locate the metadata construct immediately after the task declaration as shown here. ",
						"Task metadata is a static local variable. ",
						"It is allocated and initialized when the task is defined. ",
						""
					},

					categories:
					"example, task",

					attributes:
					"metadata, documentation",

					string:
					"" // Required
				})
// ===================================================================\

		endtask : _task_metadata_example


// ===================================================================
		function void _function_metadata_example;
// ===================================================================
			`FUNCTION_METADATA('{

					name: "_function_metadata_example",

					description:
					"This is an example showing how to define function metadata.",

					details: {
						"You can copy and paste this example into your function and replace this text with your own. ",
						"Locate the metadata construct immediately after the function declaration as shown here. ",
						"Function metadata is a static local variable. ",
						"It is allocated and initialized when the function is defined. ",
						""
					},

					categories:
					"example, function",

					attributes:
					"metadata, documentation",

					string:
					"" // Required
				})
// ===================================================================\

		endfunction : _function_metadata_example

	endclass : _class_metadata_example

endpackage : meta_pkg


module _file_metadata_example();
	initial `FILE_METADATA('{
// ===================================================================
				name: "_file_metadata_example.sv",
// ===================================================================

				description:
				"This is an example showing how to define metadata for a file.",

				details: {
					"Locate this metadata near the top of your file. ",
					"You can copy and paste this `FILE_METADATA() macro into your file and replace this text with your own. ",
					"File metadata should include RCS keywords as shown below. ",
					"There is no need to modify the RCS keyword values, even if they contain data for a different file. ",
					"As long as they are formatted correctly IC Manage/Perforce will update the RCS fields with the correct values when you check in the file. ",
					"File metadata must execute in order to be registered. ",
					"That's why this example is included in an `initial` statement inside a dummy module. ",
					"Furthermore the dummy module needs to be instantiated somewhere--anywhere--under the top module so the initial block will run. ",
					"If your file is already `included inside a module, you don't need a dummy. ",
					"All you need is the `initial` statement. ",
					"Alternatively you could put a `CLASS_METADATA() macro inside a dummy class. ",
					""
				},

				categories:
				"example, file",

				attributes:
				"metadata, documentation",

				// RCS keywords
				id: "$Id$",
				header: "$Header$",
				author: "$Author$",
				date: "$Date$",
				date_time: "$DateTime$",
				change: "$Change$",
				depot_file: "$File$",
				revision: "$Revision$",

				string:
				"" // Required
			})
// ===================================================================
endmodule : _file_metadata_example


module _block_metadata_example();
	initial `BLOCK_METADATA('{
// ===================================================================
				name: "_block_metadata_example",
// ===================================================================

				description:
				"This is an example showing how to define block metadata for a block.",

				details: {
					"Block metadata like this is ideal for module definitions. ",
					"You can copy and paste this `initial` statement inside your module and replace this text with your own. ",
					"Block metadata must execute in order to be registered. ",
					"That's why this example is included in an `initial` statement. ",
					"According to the SystemVerilog standard, `initial` constructs can be located inside modules and programs. ",
					"This example is located inside a dummy program whose sole purpose is to host this metadata. ",
					"Note however that in order for a module's or program's initial blocks to run, that module or program needs to be instantiated somewhere--anywhere--under module `top`. ",
					"This program is accordingly instantiated inside module `top` in file `top.sv`. ",
					"If your file is already `included inside a module, you don't need a dummy module. ",
					"All you need is the `initial` statement. ",
					""
				},

				categories:
				"example, block",

				attributes:
				"metadata, documentation",

				string:
				"" // Required
			})
// ===================================================================
endmodule : _block_metadata_example

