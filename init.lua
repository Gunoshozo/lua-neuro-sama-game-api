local neuro_game_sdk = {
    config = require("neuro_game_sdk.config"),
    game_hooks = require("neuro_game_sdk.game_hooks"),
    string_consts = require("neuro_game_sdk.string_consts"),

    utils = {
        table_utils = require("neuro_game_sdk.utils.table_utils"),
        json_utils = require("neuro_game_sdk.utils.json_utils"),
    },

    third_party = {
        json = require("neuro_game_sdk.third_party.json"),
    },

    actions = {
        action_window = require("neuro_game_sdk.actions.action_window"),
        neuro_action_handler = require("neuro_game_sdk.actions.neuro_action_handler"),
        neuro_action = require("neuro_game_sdk.actions.neuro_action"),
        ws_action = require("neuro_game_sdk.actions.ws_action"),
    },

    websocket = {
        websocket_connection = require("neuro_game_sdk.websocket.websocket_connection"),
        execution_result = require("neuro_game_sdk.websocket.execution_result"),
        command_handler = require("neuro_game_sdk.websocket.command_handler"),
        message_queue = require("neuro_game_sdk.websocket.message_queue"),
    },

    messages = {
        api = {
            incoming_data = require("neuro_game_sdk.messages.api.incoming_data"),
            incoming_message = require("neuro_game_sdk.messages.api.incoming_message"),
            outgoing_message = require("neuro_game_sdk.messages.api.outgoing_message"),
            ws_message = require("neuro_game_sdk.messages.api.ws_message"),
        },

        incoming = {
            action = require("neuro_game_sdk.messages.incoming.action"),
            actions_reregister_all = require("neuro_game_sdk.messages.incoming.actions_reregister_all"),
        },

        outgoing = {
            action_force = require("neuro_game_sdk.messages.outgoing.action_force"),
            action_result = require("neuro_game_sdk.messages.outgoing.action_result"),
            action_unregistrer = require("neuro_game_sdk.messages.outgoing.action_unregistrer"),
            actions_register = require("neuro_game_sdk.messages.outgoing.actions_register"),
            context = require("neuro_game_sdk.messages.outgoing.context"),
            startup = require("neuro_game_sdk.messages.outgoing.startup"),
        },
    },
}

return neuro_game_sdk
