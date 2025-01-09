local discord = require "@antiraid/discord"
local promise = require "@antiraid/promise"
local Primitives = require "@antiraid-core/primitives"
local Message = require "@antiraid-ext/events/discord/Message"

local evt: Primitives.Event, ctx: Primitives.TemplateContext = ...

local discordExecutor = discord.new(ctx)
Message(evt, function(msg)
    print(msg.content)
    local p = promise.yield(discordExecutor:get_audit_logs({}))
    print(p.data.application_commands)
    local msg_handle = promise.yield(discordExecutor:create_message({
        channel_id = "mychannelid",
        message = {
            content = "Hello, world!"
        } 
    }))  
    print(msg_handle.data.content)
end)    