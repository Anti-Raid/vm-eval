local discord = require "@antiraid/discord"
local promise = require "@antiraid/promise"
local Primitives = require "@antiraid-core/primitives"
local event = require "@antiraid-ext/event"

local ctx: Primitives.TemplateContext, evt: Primitives.Event = ...

local discordExecutor = discord.new(ctx)
event.onMessage(evt, function(msg)
    print(msg.content)
    local p = promise.yield(discordExecutor.get_audit_logs({}))
    print(p.application_commands)
    local msg_handle = promise.yield(discordExecutor.create_message({
        channel_id = "mychannelid",
        data = {
            content = "Hello, world!"
        }
    }))
    print(msg_handle.data())
end) 