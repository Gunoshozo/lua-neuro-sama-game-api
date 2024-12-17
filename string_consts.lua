Strings = {
    action_failed_invalid_json = "Action failed. Could not parse action parameters from JSON.",
    action_failed_no_data = "Action failed. Missing command data.",
    action_failed_no_id = "Action failed. Missing command field 'id'.",
    action_failed_no_name = "Action failed. Missing command field 'name'.",
    action_failed_unregistered = "This action has been recently unregistered and can no longer be used.",

    action_failed_vedal_fault_suffix = " (This is probably not your fault, blame Vedal.)",
    action_failed_mod_fault_suffix = " (This is probably not your fault, blame the game integration.)",
    action_failed_error = "Action failed. An error occurred.",
    action_failed_unknown_action = function(token)
        return string.format("Action failed. Unknown action '%s'.", token);
    end,
    action_failed_missing_required_parameter = function(token)
        return string.format("Action failed. Missing required '%s' parameter.", token);
    end,
    action_failed_invalid_parameter = function(token)
        return string.format("Action failed. Invalid '%s' parameter.", token)
    end,
}
