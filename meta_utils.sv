`ifndef META_UTILS_SV
`define META_UTILS_SV

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


`endif // META_UTILS_SV
