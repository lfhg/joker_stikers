

local stickers_loaded = false
table.insert(mods,
    {
        mod_id = "joker_stickers",
        name = "Show Joker Stickers",
        author = "Hatus",
        version = "1.0.1e",
        description = {
            "Shows the stake completion stickers on Jokers for easier Completionist++ hunting.",
        },
        enabled = true,
        on_enable = function()
            -- changes png
            local patch_before = "{name = 'stickers', path = \"resources/textures/\"..self.SETTINGS.GRAPHICS.texture_scaling..\"x/stickers.png\",px=71,py=95},"
            local patch = [[
                {name = 'stickers', path = "pack/"..self.SETTINGS.GRAPHICS.texture_scaling.."x/stickers_mod.png",px=71,py=95},
            ]]
            local fun_name = "Game:set_render_settings"
            local file_name = "game.lua"
            inject(file_name, fun_name, patch_before:gsub("([^%w])", "%%%1"), patch)

            -- sets win sticker on creation of a joker
            local patch = [[
                if self.ability.set == "Joker" then
                    self.sticker = get_joker_win_sticker(self.config.center)
                end
            ]]
            local fun_name = "Card:set_ability"
            local file_name = "card.lua"
            injectTail(file_name, fun_name, patch)

            -- sets sticker info on load game
            local patch_before = "self.ability = cardTable.ability"
            local patch = [[
                self.ability = cardTable.ability
                if self.ability.set == "Joker" then
                    self.sticker = get_joker_win_sticker(self.config.center)
                end
                ]]
            local fun_name = "Card:load"
            inject(file_name, fun_name, patch_before, patch)

            -- removes sticker from joker when flipped
            local patch_before = "self.flipping = 'f2b'"
            local patch = [[
            self.flipping = 'f2b'
            if self.ability.set == 'Joker' then
                self.sticker = nil
            end
            ]]
            local fun_name = "Card:flip"
            inject(file_name, fun_name, patch_before, patch)

            -- reapply sticker when flipped back
            local patch_before = "self.flipping = 'b2f'"
            local patch = [[
            self.flipping = 'b2f'
            if self.ability.set == "Joker" then
                self.sticker = get_joker_win_sticker(self.config.center)
            end
            ]]
            inject(file_name, fun_name, patch_before, patch)
        end,

        -- reloads png when mod is loaded
        on_post_update = function()
            if not stickers_loaded then
                G:set_render_settings()
                stickers_loaded = true
            end
        end
    }
)
