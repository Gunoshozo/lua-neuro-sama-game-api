local NeuroSdkConfig = {
    game = "", 
    incoming_msg_modules = { -- WA need to write here all modules that are located under of neuro_game_sdk.messages.incoming.*, since couldn't find easy way to do it dynamicaly
        "neuro_game_sdk.messages.incoming.action",
        "neuro_game_sdk.messages.incoming.actions_reregister_all"
    }
}

return NeuroSdkConfig
