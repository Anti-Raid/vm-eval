--local once = require "@antiraid-ext/once"
local promise = require "@antiraid/promise"
local luau = require "@antiraid/luau"
local executor = require "@antiraid-ext/executor"
local Primitives = require "@antiraid-core/primitives"
local serde = require "@lune/serde"
local discordApiTypes = require "@discord-types/apiTypes"
local discordRestTypes = require "@discord-types/restTypes"
local Message = require "@antiraid-ext/events/discord/Message"
local InteractionCreate = require "@antiraid-ext/events/discord/InteractionCreate"
local toArray = require "@antiraid-ext/array".toArray
local InteractionType = require "@discord-types/interaction".InteractionType
local InteractionCallbackType = require "@discord-types/interaction".InteractionCallbackType

local evt: Primitives.Event, ctx: Primitives.TemplateContext = ...

local ge = executor.NewGlobalExecutor(ctx)
 
Message(evt, function(message) 
    if message.content ~= "eval:makeCommand" then
        return
    end

    local channelId: string;

    if message.channel_id then
        channelId = message.channel_id
    else
        return
    end
 
    local commandBuilder = require "@discord-types/builders/interaction/interaction"
    local commandOptionBuilder = require "@discord-types/builders/interaction/option"
    local ApplicationCommandOptionType = require "@discord-types/interaction".ApplicationCommandOptionType

    local command = commandBuilder.new({
        name = "vm-eval",
    })
    :addIntegrationType("GuildInstall")
    :setType("ChatInput")
    :addContext("Guild")
    :setDescription("Evaluates Luau code in a VM")
    :option(
        function(opt) 
            return commandOptionBuilder.new()
            :setType(ApplicationCommandOptionType.String)
            :setName("code")
            :setDescription("The code to evaluate")  
            :build()      
        end
    ) 

    promise.yield(ge.discord:create_message({
        channel_id = channelId,
        data = {
            content = (serde.encode("json", command:build())) :: string?
        }
    }))

    promise.yield(ge.discord:create_guild_command({
        data = command:build() :: discordRestTypes.CreateGuildApplicationCommandRequest,
    }))
end)

local function evaluateExpression(interaction: discordApiTypes.InteractionObject, content: string) 
    local status: "running" | "deferred" | "done" = "running"
    local deferInteractionThread = task.delay(3, function() 
        if status == "running" then
            promise.yield(ge.discord:create_interaction_response({
                interaction_id = interaction.id,
                interaction_token = interaction.token,
                data = {
                    type = InteractionCallbackType.DeferredChannelMessageWithSource,
                    data = {}
                } :: discordRestTypes.CreateInteractionRequest
            }))
            status = "deferred"
        end
    end)

    -- Do some work here
    local chunk = luau.load(ctx, content)
    chunk.optimization_level = 2
    chunk.chunk_name = "__vm_eval_chunk"
    local ok, result = pcall(promise.yield, chunk:call_async({}))

    -- Print result
    if status == "deferred" then
        promise.yield(ge.discord:create_followup_message({
            interaction_token = interaction.token,
            data = {
                embeds = toArray({
                    {
                        title = "Result",
                        description = "```\n" .. tostring(result) .. "\n```",
                        fields = toArray({
                            {
                                name = "OK",
                                value = tostring(ok),
                                inline = false,
                            },
                        }),
                        color = if ok then 0x00FF00 else 0xFF0000,
                    },
                })
            } :: discordRestTypes.CreateFollowupMessageRequest
        }))
    else 
        promise.yield(ge.discord:create_interaction_response({
            interaction_id = interaction.id,
            interaction_token = interaction.token,
            data = {
                type = InteractionCallbackType.ChannelMessageWithSource,
                data = {
                    embeds = toArray({
                        {
                            title = "Result",
                            description = "```\n" .. tostring(result) .. "\n```",
                            fields = toArray({
                                {
                                    name = "OK",
                                    value = tostring(ok),
                                    inline = false,
                                },
                            }),
                            color = if ok then 0x00FF00 else 0xFF0000,
                        }
                    }),
                }
            } :: discordRestTypes.CreateInteractionRequest
        }))
    end 

    -- Done!
    task.cancel(deferInteractionThread)
    status = "done"
end

InteractionCreate(evt, function(interaction)
    -- Keep store of the interaction object
    local interactionObject: discordApiTypes.InteractionObject = interaction

    if interaction.type ~= InteractionType.ApplicationCommand then
        return
    end

    if not interaction.data then
        return
    end

    if interaction.data.name ~= "vm-eval" then
        return
    end

    --- Get the code value from the interaction
    local options = interaction.data.options

    if not options or #options == 0 then
        promise.yield(ge.discord:create_interaction_response({
            interaction_id = interaction.id,
            interaction_token = interaction.token,
            data = {
                type = InteractionCallbackType.ChannelMessageWithSource,
                data = {
                    embeds = toArray({
                        {
                            title = "Result",
                            description = "Modal support is TODO",
                        }
                    })    
                }
            } :: discordRestTypes.CreateInteractionRequest
        }))    
        return
    end

    local code = tostring(options[1].value)

    if not code or code == "" then
        promise.yield(ge.discord:create_interaction_response({
            interaction_id = interaction.id,
            interaction_token = interaction.token,
            data = {
                type = InteractionCallbackType.ChannelMessageWithSource,
                data = {
                    embeds = toArray({
                        {
                            title = "Result",
                            description = "No code provided",
                        }
                    })    
                }
            } :: discordRestTypes.CreateInteractionRequest
        }))    
        return
    end

    -- Evaluate the code
    evaluateExpression(interactionObject, code)
end)       
