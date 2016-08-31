--[[============================================================================
com.renoise.PhraseMate.xrnx/main.lua
============================================================================]]--
--[[

PhraseMate aims to make it more convenient to work with phrases. Launch the tool from the tool menu, by using the right-click (context-menu) shortcuts in the pattern editor or pattern matrix, or via the supplied keyboard shortcuts / MIDI mappings.

.
#

## Links

Renoise: [Tool page](http://www.renoise.com/tools/phrasemate)

Renoise Forum: [Feedback and bugs](http://forum.renoise.com/index.php/topic/46284-new-tool-31-phrasemate/)

Github: [Documentation and source](https://github.com/renoise/xrnx/tree/master/Tools/com.renoise.PhraseMate.xrnx/) 


]]

--------------------------------------------------------------------------------
-- required files
--------------------------------------------------------------------------------

rns = nil
_trace_filters = nil
--_trace_filters = {".*"}

_clibroot = 'source/cLib/classes/'
require (_clibroot..'cLib')
require (_clibroot..'cDebug')
require (_clibroot.."cConfig")
require (_clibroot..'cFilesystem')
require (_clibroot.."cParseXML")
require (_clibroot.."cProcessSlicer")

_xlibroot = 'source/xLib/classes/'
require (_xlibroot..'xLib')
require (_xlibroot.."xPhrase")
require (_xlibroot..'xLinePattern')
require (_xlibroot..'xInstrument')
require (_xlibroot..'xNoteColumn') 
require (_xlibroot..'xPhraseManager')
require (_xlibroot..'xSelection')

_vlibroot = 'source/vLib/classes/'
require (_vlibroot..'vLib')
require (_vlibroot..'vDialog')
require (_vlibroot..'vArrowButton')

require ('source/PhraseMate')
require ('source/PhraseMateUI')
require ('source/PhraseMatePrefs')

--------------------------------------------------------------------------------
-- Variables
--------------------------------------------------------------------------------

rns = nil
phrasemate = nil
APP_DISPLAY_NAME = "PhraseMate"

local prefs = PhraseMatePrefs()
renoise.tool().preferences = prefs

--------------------------------------------------------------------------------
-- Menu entries & MIDI/Key mappings
--------------------------------------------------------------------------------

renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:PhraseMate...",
  invoke = function() 
    show() 
  end
} 
renoise.tool():add_keybinding {
  name = "Global:PhraseMate:Show preferences...",
  invoke = function(repeated)
    if (not repeated) then 
      show() 
    end
  end
}

-- input : SELECTION_IN_PATTERN

renoise.tool():add_midi_mapping{
  name = "Tools:PhraseMate:Create Phrase from Selection in Pattern [Trigger]",
  invoke = function(msg)
    if msg:is_trigger() then
      phrasemate:collect_phrases(INPUT_SCOPE.SELECTION_IN_PATTERN)
    end
  end
}
renoise.tool():add_menu_entry {
  name = "Pattern Editor:PhraseMate:Create Phrase from Selection",
  invoke = function() 
    phrasemate:collect_phrases(INPUT_SCOPE.SELECTION_IN_PATTERN)
  end
}
renoise.tool():add_keybinding {
  name = "Global:PhraseMate:Create Phrase from Selection in Pattern",
  invoke = function(repeated)
    if (not repeated) then 
      phrasemate:collect_phrases(INPUT_SCOPE.SELECTION_IN_PATTERN)
    end
  end
}

-- input : SELECTION_IN_MATRIX

renoise.tool():add_midi_mapping{
  name = "Tools:PhraseMate:Create Phrase from Selection in Matrix [Trigger]",
  invoke = function(msg)
    if msg:is_trigger() then
      phrasemate:collect_phrases(INPUT_SCOPE.SELECTION_IN_MATRIX)
    end
  end
}
renoise.tool():add_menu_entry {
  name = "Pattern Matrix:PhraseMate:Create Phrase from Selection",
  invoke = function() 
    phrasemate:collect_phrases(INPUT_SCOPE.SELECTION_IN_MATRIX)
  end
}
renoise.tool():add_keybinding {
  name = "Global:PhraseMate:Create Phrase from Selection in Matrix",
  invoke = function(repeated)
    if (not repeated) then 
      phrasemate:collect_phrases(INPUT_SCOPE.SELECTION_IN_MATRIX)
    end
  end
}

-- input : TRACK_IN_PATTERN

renoise.tool():add_midi_mapping{
  name = "Tools:PhraseMate:Create Phrase from Track [Trigger]",
  invoke = function(msg)
    if msg:is_trigger() then
      phrasemate:collect_phrases(INPUT_SCOPE.TRACK_IN_PATTERN)
    end
  end
}
renoise.tool():add_menu_entry {
  name = "Pattern Editor:PhraseMate:Create Phrase from Track",
  invoke = function() 
    phrasemate:collect_phrases(INPUT_SCOPE.TRACK_IN_PATTERN)
  end
}
renoise.tool():add_keybinding {
  name = "Global:PhraseMate:Create Phrase from Track",
  invoke = function(repeated)
    if (not repeated) then 
      phrasemate:collect_phrases(INPUT_SCOPE.TRACK_IN_PATTERN)
    end
  end
}

-- input : TRACK_IN_SONG

renoise.tool():add_midi_mapping{
  name = "Tools:PhraseMate:Create Phrases from Track in Song [Trigger]",
  invoke = function(msg)
    if msg:is_trigger() then
      phrasemate:collect_phrases(INPUT_SCOPE.TRACK_IN_SONG)
    end
  end
}
renoise.tool():add_menu_entry {
  name = "Pattern Editor:PhraseMate:Create Phrases from Track in Song",
  invoke = function() 
    phrasemate:collect_phrases(INPUT_SCOPE.TRACK_IN_SONG)
  end
}
renoise.tool():add_keybinding {
  name = "Global:PhraseMate:Create Phrases from Track in Song",
  invoke = function(repeated)
    if (not repeated) then 
      phrasemate:collect_phrases(INPUT_SCOPE.TRACK_IN_SONG)
    end
  end
}

-- output : apply_phrase_to_selection

renoise.tool():add_midi_mapping{
  name = "Tools:PhraseMate:Write Phrase to Selection In Pattern [Trigger]",
  invoke = function(msg)
    if msg:is_trigger() then
      phrasemate:apply_phrase_to_selection()
    end
  end
}
renoise.tool():add_menu_entry {
  name = "--- Pattern Editor:PhraseMate:Write Phrase to Selection In Pattern",
  invoke = function() 
    phrasemate:apply_phrase_to_selection()
  end
} 
renoise.tool():add_keybinding {
  name = "Global:PhraseMate:Write Phrase to Selection in Pattern",
  invoke = function(repeated)
    if (not repeated) then 
      phrasemate:apply_phrase_to_selection()
    end
  end
}

-- output : apply_phrase_to_track

renoise.tool():add_midi_mapping{
  name = "Tools:PhraseMate:Write Phrase to Track [Trigger]",
  invoke = function(msg)
    if msg:is_trigger() then
      phrasemate:apply_phrase_to_track()
    end
  end
}
renoise.tool():add_menu_entry {
  name = "Pattern Editor:PhraseMate:Write Phrase to Track",
  invoke = function() 
    phrasemate:apply_phrase_to_track()
  end
} 

renoise.tool():add_keybinding {
  name = "Global:PhraseMate:Write Phrase to Track",
  invoke = function(repeated)
    if (not repeated) then 
      phrasemate:apply_phrase_to_track()
    end
  end
}

-- realtime

renoise.tool():add_keybinding {
  name = "Global:PhraseMate:Toggle Realtime/Zxx mode",
  invoke = function(repeated)
    if (not repeated) then 
      prefs.zxx_mode = not prefs.zxx_mode
    end
  end
}

renoise.tool():add_keybinding {
  name = "Global:PhraseMate:Select Previous Phrase in Instrument",
  invoke = function()
    phrasemate:invoke_task(xPhraseManager.select_previous_phrase)
  end
}
renoise.tool():add_midi_mapping {
  name = PhraseMate.MIDI_MAPPING.PREV_PHRASE_IN_INSTR,
  invoke = function(msg)
    if msg:is_trigger() then
      phrasemate:invoke_task(xPhraseManager.select_previous_phrase)
    end
  end
}

renoise.tool():add_keybinding {
  name = "Global:PhraseMate:Select Next Phrase in Instrument",
  invoke = function()
    phrasemate:invoke_task(xPhraseManager.select_next_phrase)
  end
}
renoise.tool():add_midi_mapping {
  name = PhraseMate.MIDI_MAPPING.NEXT_PHRASE_IN_INSTR,
  invoke = function(msg)
    if msg:is_trigger() then
      phrasemate:invoke_task(xPhraseManager.select_next_phrase())
    end
  end
}

renoise.tool():add_keybinding {
  name = "Global:PhraseMate:Set Playback Mode to 'Off'",
  invoke = function(repeated)
    if (not repeated) then 
      phrasemate:invoke_task(xPhraseManager.set_playback_mode,renoise.Instrument.PHRASES_OFF)
    end
  end
}
renoise.tool():add_keybinding {
  name = "Global:PhraseMate:Set Playback Mode to 'Program'",
  invoke = function(repeated)
    if (not repeated) then 
      phrasemate:invoke_task(xPhraseManager.set_playback_mode,renoise.Instrument.PHRASES_PLAY_SELECTIVE)
    end
  end
}
renoise.tool():add_keybinding {
  name = "Global:PhraseMate:Set Playback Mode to 'Keymap'",
  invoke = function(repeated)
    if (not repeated) then 
      phrasemate:invoke_task(xPhraseManager.set_playback_mode,renoise.Instrument.PHRASES_PLAY_KEYMAP)
    end
  end
}
renoise.tool():add_midi_mapping {
  name = PhraseMate.MIDI_MAPPING.SET_PLAYBACK_MODE,
  invoke = function(msg)
    local mode = cLib.clamp_value(msg.int_value,1,3)
    phrasemate:invoke_task(xPhraseManager.set_playback_mode,renoise.Instrument.PHRASES_PLAY_KEYMAP)
  end
}

-- addendum

renoise.tool():add_menu_entry {
  name = "--- Pattern Editor:PhraseMate:Adjust settings...",
  invoke = function() 
    show()
  end
}
renoise.tool():add_menu_entry {
  name = "--- Pattern Matrix:PhraseMate:Adjust settings...",
  invoke = function() 
    show()
  end
}

--------------------------------------------------------------------------------

renoise.tool().app_new_document_observable:add_notifier(function()
  rns = renoise.song()
  phrasemate = PhraseMate{
    app_display_name = APP_DISPLAY_NAME,
  }
end)

--------------------------------------------------------------------------------
-- invoked by menu entries, autostart - 
-- first time around, the UI/class instances are created 

function show()


  --if not phrasemate then
    --phrasemate = PhraseMate{
      --app_display_name = APP_DISPLAY_NAME,
    --}
  --end

  phrasemate.ui:show()

end




