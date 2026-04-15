--[[
    CTLD — Internationalization class (CTLDi18n)
    src version — logic only, no dictionary data.

    Dictionary files (loaded after this file):
        CTLD_i18n_en.lua  — English reference (keys and EN text)
        CTLD_i18n_fr.lua  — French
        CTLD_i18n_es.lua  — Spanish
        CTLD_i18n_ko.lua  — Korean

    To add a new language: create CTLD_i18n_XX.lua following the EN template,
    add it to tools/merger_V2/listToMerge.txt, and regenerate the loader.

    Translators: edit only the CTLD_i18n_XX.lua files. Never edit this file.
    Run tools/merger_V2/generate_i18n_dicts.ps1 after any ctld.tr() change in scripts.
]]

if not ctld then ctld = {} end
ctld.i18n = ctld.i18n or {}

-- =====================================================================
-- Active language selector
-- Uncomment the language you want to use.
-- =====================================================================
ctld.i18n_lang = "en"
--ctld.i18n_lang = "fr"
--ctld.i18n_lang = "es"
--ctld.i18n_lang = "ko"

-- =====================================================================
-- CTLDi18n singleton
-- =====================================================================
CTLDi18n = {}
CTLDi18n._instance = nil

function CTLDi18n.getInstance()
    if not CTLDi18n._instance then
        CTLDi18n._instance = setmetatable({}, { __index = CTLDi18n })
        CTLDi18n._instance:_init()
    end
    return CTLDi18n._instance
end

--- Apply mission-maker overrides declared in CTLD_userConfig.lua.
--- Called once at startup by getInstance().
function CTLDi18n:_init()
    if ctld.i18n_overrides then
        for lang, entries in pairs(ctld.i18n_overrides) do
            if ctld.i18n[lang] then
                for key, value in pairs(entries) do
                    ctld.i18n[lang][key] = value
                end
            end
        end
    end
end

-- =====================================================================
-- Translation function
-- =====================================================================

--- Translate a string to the active language, with optional parameter substitution.
--- Fallback chain: active lang → EN → key itself (never empty, never nil).
---@param text string The key to translate (= the English text)
---@param ... any Parameters to substitute for %1, %2, ... placeholders
---@return string
function ctld.tr(text, ...)
    local _text

    if not ctld.i18n[ctld.i18n_lang] then
        env.info(string.format("E - CTLDi18n.tr: language '%s' not found, defaulting to 'en'",
            tostring(ctld.i18n_lang)))
        _text = ctld.i18n["en"][text]
    else
        _text = ctld.i18n[ctld.i18n_lang][text]
    end

    -- Fallback to English
    if _text == nil then
        _text = ctld.i18n["en"][text]
    end

    -- Final fallback: use the key itself (= the English text)
    if _text == nil or _text == "" then
        _text = text
    end

    -- Parameter substitution (%1, %2, ...)
    local args = { ... }
    if #args > 0 then
        for i, v in ipairs(args) do
            _text = string.gsub(_text, "%%" .. i, tostring(v))
        end
    end

    return _text
end

--- Backward-compatibility alias.
ctld.i18n_translate = ctld.tr

-- =====================================================================
-- Dictionary integrity checker
-- =====================================================================

--- Check that a language dictionary is complete and version-compatible with EN.
--- Logs errors for missing keys and warnings for untranslated entries.
---@param language string Language code to check (e.g. "fr")
---@param verbose boolean If true, log each passing entry as well
function ctld.i18n_check(language, verbose)
    local english = ctld.i18n["en"]
    local tocheck = ctld.i18n[language]
    if not tocheck then
        env.error(string.format("CTLDi18n.i18n_check: language '%s' not found", language))
        return false
    end

    local englishVersion = english.translation_version
    local tocheckVersion = tocheck.translation_version
    if englishVersion ~= tocheckVersion then
        env.error(string.format(
            "CTLDi18n.i18n_check: version mismatch — EN is %s, %s is %s",
            englishVersion, language, tocheckVersion))
    end

    for textRef, textEnglish in pairs(english) do
        if textRef ~= "translation_version" then
            local textTocheck = tocheck[textRef]
            if not textTocheck then
                env.error(string.format(
                    "CTLDi18n.i18n_check: MISSING in %s: [%s]", language, textRef))
            elseif textTocheck == textEnglish then
                env.warning(string.format(
                    "CTLDi18n.i18n_check: UNTRANSLATED in %s: [%s]", language, textRef))
            elseif verbose then
                env.info(string.format(
                    "CTLDi18n.i18n_check: OK in %s: [%s]", language, textRef))
            end
        end
    end
end
