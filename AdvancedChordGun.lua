-- @description Advanced ChordGun
-- @author del-paso
-- @version 4.1
-- @about
--   ### Advanced ChordGun v2
--   An expanded chord composition tool for REAPER inspired by Pandabot's ChordGun.
--   40+ chord types, full chord grid, next-chord suggestions, arpeggiate mode.
--
--   #### Keyboard Shortcuts (when GUI has focus)
--   1-7 : Play/insert diatonic chord for scale degree
--   0   : Stop all notes
--   Space : Toggle insert mode
--   A   : Toggle arpeggiate
--   Up/Down : Scroll grid
--   Esc : Close

-- ============================================================================
-- NOTES AND SCALES
-- ============================================================================

local NOTE_NAMES = {"C","C#","D","D#","E","F","F#","G","G#","A","A#","B"}

local scales = {
  { name = "Major (Ionian)",          pattern = {0,2,4,5,7,9,11} },
  { name = "Natural Minor (Aeolian)", pattern = {0,2,3,5,7,8,10} },
  { name = "Dorian",                  pattern = {0,2,3,5,7,9,10} },
  { name = "Phrygian",                pattern = {0,1,3,5,7,8,10} },
  { name = "Lydian",                  pattern = {0,2,4,6,7,9,11} },
  { name = "Mixolydian",              pattern = {0,2,4,5,7,9,10} },
  { name = "Locrian",                 pattern = {0,1,3,5,6,8,10} },
}

local DEGREE_HEADERS = {
  {"I","ii","iii","IV","V","vi","vii\xC2\xB0"},
  {"i","ii\xC2\xB0","III","iv","v","VI","VII"},
  {"i","ii","III","IV","v","vi\xC2\xB0","VII"},
  {"i","II","III","iv","v\xC2\xB0","VI","vii"},
  {"I","II","iii","#iv\xC2\xB0","V","vi","vii"},
  {"I","ii","iii\xC2\xB0","IV","v","vi","VII"},
  {"i\xC2\xB0","II","iii","iv","V","VI","vii"},
}

-- ============================================================================
-- CHORD DEFINITIONS
-- ============================================================================

local chordCategories = {
  {
    name = "Triads",
    chords = {
      { name = "Major",       display = "",       intervals = {0, 4, 7} },
      { name = "Minor",       display = "m",      intervals = {0, 3, 7} },
      { name = "Diminished",  display = "dim",    intervals = {0, 3, 6} },
      { name = "Augmented",   display = "aug",    intervals = {0, 4, 8} },
      { name = "Sus2",        display = "sus2",   intervals = {0, 2, 7} },
      { name = "Sus4",        display = "sus4",   intervals = {0, 5, 7} },
      { name = "Power (5th)", display = "5",      intervals = {0, 7} },
    }
  },
  {
    name = "Sixths",
    chords = {
      { name = "Major 6th",   display = "6",      intervals = {0, 4, 7, 9} },
      { name = "Minor 6th",   display = "m6",     intervals = {0, 3, 7, 9} },
      { name = "6/9",         display = "6/9",    intervals = {0, 4, 7, 9, 14} },
    }
  },
  {
    name = "Sevenths",
    chords = {
      { name = "Dominant 7",     display = "7",       intervals = {0, 4, 7, 10} },
      { name = "Major 7",       display = "maj7",    intervals = {0, 4, 7, 11} },
      { name = "Minor 7",       display = "m7",      intervals = {0, 3, 7, 10} },
      { name = "Min/Maj 7",     display = "m(M7)",   intervals = {0, 3, 7, 11} },
      { name = "Diminished 7",  display = "dim7",    intervals = {0, 3, 6, 9} },
      { name = "Half-Dim 7",    display = "m7b5",    intervals = {0, 3, 6, 10} },
      { name = "Aug 7",         display = "7#5",     intervals = {0, 4, 8, 10} },
      { name = "Aug Maj 7",     display = "M7#5",    intervals = {0, 4, 8, 11} },
      { name = "7sus4",         display = "7sus4",   intervals = {0, 5, 7, 10} },
      { name = "7sus2",         display = "7sus2",   intervals = {0, 2, 7, 10} },
    }
  },
  {
    name = "Ninths",
    chords = {
      { name = "Dominant 9",   display = "9",       intervals = {0, 4, 7, 10, 14} },
      { name = "Major 9",      display = "maj9",    intervals = {0, 4, 7, 11, 14} },
      { name = "Minor 9",      display = "m9",      intervals = {0, 3, 7, 10, 14} },
      { name = "m(Maj9)",      display = "m(M9)",   intervals = {0, 3, 7, 11, 14} },
      { name = "Add 9",        display = "add9",    intervals = {0, 4, 7, 14} },
      { name = "m(add9)",      display = "m(add9)", intervals = {0, 3, 7, 14} },
    }
  },
  {
    name = "Elevenths",
    chords = {
      { name = "Dominant 11",  display = "11",      intervals = {0, 4, 7, 10, 14, 17} },
      { name = "Major 11",     display = "maj11",   intervals = {0, 4, 7, 11, 14, 17} },
      { name = "Minor 11",     display = "m11",     intervals = {0, 3, 7, 10, 14, 17} },
      { name = "Add 11",       display = "add11",   intervals = {0, 4, 7, 17} },
    }
  },
  {
    name = "Thirteenths",
    chords = {
      { name = "Dominant 13",  display = "13",      intervals = {0, 4, 7, 10, 14, 21} },
      { name = "Major 13",     display = "maj13",   intervals = {0, 4, 7, 11, 14, 21} },
      { name = "Minor 13",     display = "m13",     intervals = {0, 3, 7, 10, 14, 21} },
    }
  },
  {
    name = "Extended Voicings (7-10 notes)",
    chords = {
      { name = "Maj13 full",   display = "maj13*",  intervals = {0, 4, 7, 11, 14, 17, 21} },
      { name = "Dom13 full",   display = "13*",     intervals = {0, 4, 7, 10, 14, 17, 21} },
      { name = "Min13 full",   display = "m13*",    intervals = {0, 3, 7, 10, 14, 17, 21} },
      { name = "Maj13#11",     display = "M13#11",  intervals = {0, 4, 7, 11, 14, 18, 21} },
      { name = "Polychord C/D",display = "C/D",     intervals = {0, 4, 7, 14, 18, 21} },
      { name = "Stack 5ths",   display = "stack5",  intervals = {0, 7, 14, 21, 28, 35, 42} },
      { name = "Cluster 9-note",display = "clst9",  intervals = {0, 2, 4, 7, 9, 11, 14, 16, 19} },
      { name = "Mega 10-note", display = "mega10",  intervals = {0, 4, 7, 10, 14, 17, 21, 24, 28, 31} },
    }
  },
  {
    name = "Altered Dominants",
    chords = {
      { name = "7b9",          display = "7b9",     intervals = {0, 4, 7, 10, 13} },
      { name = "7#9",          display = "7#9",     intervals = {0, 4, 7, 10, 15} },
      { name = "7b5",          display = "7b5",     intervals = {0, 4, 6, 10} },
      { name = "7#5",          display = "7#5",     intervals = {0, 4, 8, 10} },
      { name = "7b5b9",        display = "7b5b9",   intervals = {0, 4, 6, 10, 13} },
      { name = "7#5#9",        display = "7#5#9",   intervals = {0, 4, 8, 10, 15} },
      { name = "7alt",         display = "7alt",    intervals = {0, 4, 6, 10, 13} },
    }
  },
}

-- Build flat list and row structure for grid
local ALL_CHORDS = {}
local GRID_ROWS = {}  -- each entry: {type="header", name=...} or {type="chord", chordIdx=..., chord=...}
do
  local idx = 0
  for _, cat in ipairs(chordCategories) do
    table.insert(GRID_ROWS, {type = "header", name = cat.name})
    for _, chord in ipairs(cat.chords) do
      idx = idx + 1
      chord.globalIdx = idx
      chord.category = cat.name
      ALL_CHORDS[idx] = chord
      table.insert(GRID_ROWS, {type = "chord", chordIdx = idx, chord = chord})
    end
  end
end

local NUM_CHORD_TYPES = #ALL_CHORDS

-- ============================================================================
-- STATE MANAGEMENT
-- ============================================================================

local SECTION = "com.del-paso.AdvancedChordGun"

-- Forward declarations (must exist before playChord is defined)
local GUI = {
  w = 930,
  h = 710,
  scrollY = 0,
  maxScroll = 0,
  lastMouseCap = 0,
  lastChordText = "",
  lastChordNotes = {},
  hoveredRow = -1,
  hoveredDeg = -1,
  currentRow = -1,
  currentDeg = -1,
  trail = {},
  maxTrail = 8,
}
local degreeChordMap = {1,1,1,1,1,1,1}
local function getDegreeChord(d) return degreeChordMap[d] or 1 end
local function setDegreeChord(d, idx) degreeChordMap[d] = idx end
local PROJ = 0

local function sv(k, v) reaper.SetProjExtState(PROJ, SECTION, k, tostring(v)) end
local function gv(k, d)
  local e, v = reaper.GetProjExtState(PROJ, SECTION, k)
  if e == 0 or v == "" then sv(k, d); return d end
  return v
end
local function gn(k, d) return tonumber(gv(k, d)) end

local function stv(k, t) reaper.SetProjExtState(PROJ, SECTION, k, table.concat(t, ",")) end
local function gtv(k, d)
  local e, v = reaper.GetProjExtState(PROJ, SECTION, k)
  if e == 0 or v == "" then stv(k, d); return {table.unpack(d)} end
  local o = {}; for m in v:gmatch("([^,]+)") do o[#o+1] = m end; return o
end

local function getScaleRoot()  return gn("root", 1) end
local function setScaleRoot(v) sv("root", v) end
local function getScaleType()  return gn("stype", 1) end
local function setScaleType(v) sv("stype", v) end
local function getOctave()     return gn("oct", 3) end
local function setOctave(v)    sv("oct", v) end
local function getVelocity()   return gn("vel", 96) end
local function setVelocity(v)  sv("vel", v) end
local function getInversion()  return gn("inv", 0) end
local function setInversion(v) sv("inv", v) end
local function getInsertMode() return gv("ins", "true") == "true" end
local function setInsertMode(v) sv("ins", tostring(v)) end
local function getArpMode()    return gv("arp", "false") == "true" end
local function setArpMode(v)   sv("arp", tostring(v)) end
local function getArpDelay()   return gn("arpms", 35) end
local function setArpDelay(v)  sv("arpms", v) end
local function getArpRR()      return gv("arprr", "true") == "true" end
local function setArpRR(v)     sv("arprr", tostring(v)) end
local function getTrailOn()    return gv("trail", "true") == "true" end
local function setTrailOn(v)   sv("trail", tostring(v)) end

-- ============================================================================
-- MUSIC THEORY
-- ============================================================================

local function getScaleNotes(rootIdx, scaleIdx)
  local pat = scales[scaleIdx].pattern
  local root = rootIdx - 1
  local notes = {}
  for i, interval in ipairs(pat) do notes[i] = (root + interval) % 12 end
  return notes
end

local function buildChordMIDI(rootMidi, chordDef, inversion)
  local notes = {}
  for i, interval in ipairs(chordDef.intervals) do
    notes[i] = rootMidi + interval
  end
  local inv = inversion or 0
  if inv > 0 then
    for i = 1, math.min(inv, #notes - 1) do
      notes[1] = notes[1] + 12
      table.sort(notes)
    end
  elseif inv < 0 then
    for i = 1, math.min(math.abs(inv), #notes - 1) do
      notes[#notes] = notes[#notes] - 12
      table.sort(notes)
    end
  end
  return notes
end

local function getChordPitchClasses(rootPitchClass, chordDef)
  local pcs = {}
  for _, interval in ipairs(chordDef.intervals) do
    pcs[(rootPitchClass + interval) % 12] = true
  end
  return pcs
end

-- Natural triad quality for a scale degree (used for diatonic row highlighting)
local function getDiatonicChordIdx(rootIdx, scaleIdx, degree)
  local sn = getScaleNotes(rootIdx, scaleIdx)
  local root = sn[degree]
  local third = sn[((degree - 1 + 2) % 7) + 1]
  local fifth = sn[((degree - 1 + 4) % 7) + 1]
  local t = (third - root) % 12
  local f = (fifth - root) % 12
  if t == 4 and f == 7 then return 1 end     -- Major
  if t == 3 and f == 7 then return 2 end     -- Minor
  if t == 3 and f == 6 then return 3 end     -- Diminished
  if t == 4 and f == 8 then return 4 end     -- Augmented
  return 1
end

-- ============================================================================
-- CHORD SUGGESTION ENGINE
-- ============================================================================

local lastPlayedRoot = nil   -- pitch class 0-11
local lastPlayedPCs = nil    -- set of pitch classes
local suggestionCache = {}   -- [gridRowIdx][degree] = score

local ROOT_MOVE_SCORES = {
  [0]  = 0.0,   -- unison (same root)
  [1]  = 0.18,  -- minor 2nd up
  [2]  = 0.25,  -- major 2nd up
  [3]  = 0.22,  -- minor 3rd up
  [4]  = 0.18,  -- major 3rd up
  [5]  = 0.38,  -- perfect 4th up (strong: V->I motion)
  [6]  = 0.08,  -- tritone
  [7]  = 0.32,  -- perfect 5th up (strong: I->V)
  [8]  = 0.18,  -- minor 6th up
  [9]  = 0.22,  -- major 6th up (relative minor/major)
  [10] = 0.25,  -- minor 7th up (= major 2nd down)
  [11] = 0.18,  -- major 7th up
}

local function computeSuggestionScore(toRoot, toChordDef)
  if not lastPlayedRoot or not lastPlayedPCs then return 0 end
  
  local toPCs = getChordPitchClasses(toRoot, toChordDef)
  
  -- Count shared pitch classes
  local shared = 0
  for pc, _ in pairs(toPCs) do
    if lastPlayedPCs[pc] then shared = shared + 1 end
  end
  
  -- Root movement score
  local interval = (toRoot - lastPlayedRoot) % 12
  local rootScore = ROOT_MOVE_SCORES[interval] or 0.1
  
  -- Combined score
  local score = shared * 0.12 + rootScore
  
  -- Bonus: if same root and different quality, moderate suggestion
  if interval == 0 then score = 0.1 end
  
  return math.min(score, 1.0)
end

local function rebuildSuggestions(rootIdx, scaleIdx)
  suggestionCache = {}
  if not lastPlayedRoot then return end
  
  local scaleNotes = getScaleNotes(rootIdx, scaleIdx)
  
  for ri, row in ipairs(GRID_ROWS) do
    suggestionCache[ri] = {}
    if row.type == "chord" then
      for deg = 1, 7 do
        local degRoot = scaleNotes[deg]
        suggestionCache[ri][deg] = computeSuggestionScore(degRoot, row.chord)
      end
    end
  end
end

local function getSuggestionColor(score)
  if score >= 0.55 then return {0.15, 0.65, 0.25, 0.45}  end -- bright green
  if score >= 0.42 then return {0.35, 0.65, 0.15, 0.35}  end -- green
  if score >= 0.30 then return {0.70, 0.70, 0.10, 0.28}  end -- yellow
  if score >= 0.20 then return {0.80, 0.50, 0.10, 0.22}  end -- orange
  return nil  -- no highlight
end

-- ============================================================================
-- MIDI PREVIEW AND ARPEGGIATE
-- ============================================================================

local notesThatArePlaying = {}
local arpQueue = {}
local arpDelays = {}  -- per-note delay times (ms) for round robin
local arpVel = 96
local arpIndex = 0
local arpNextTime = 0

math.randomseed(os.time())

local function stopAllNotes()
  for _, note in ipairs(notesThatArePlaying) do
    reaper.StuffMIDIMessage(0, 0x80, note, 0)
  end
  notesThatArePlaying = {}
  arpQueue = {}
  arpDelays = {}
  arpIndex = 0
end

local function previewChordImmediate(midiNotes, velocity)
  stopAllNotes()
  for _, note in ipairs(midiNotes) do
    if note >= 0 and note <= 127 then
      reaper.StuffMIDIMessage(0, 0x90, note, velocity)
      notesThatArePlaying[#notesThatArePlaying + 1] = note
    end
  end
end

local function previewChordArpeggiated(midiNotes, velocity)
  stopAllNotes()
  arpQueue = {}
  arpDelays = {}
  local baseDelay = getArpDelay()
  local useRR = getArpRR()
  
  for _, n in ipairs(midiNotes) do
    if n >= 0 and n <= 127 then
      arpQueue[#arpQueue + 1] = n
      -- Round robin: randomize each note's delay between 40% and 180% of base
      if useRR then
        local factor = 0.4 + math.random() * 1.4
        arpDelays[#arpDelays + 1] = math.max(8, math.floor(baseDelay * factor))
      else
        arpDelays[#arpDelays + 1] = baseDelay
      end
    end
  end
  arpVel = velocity
  arpIndex = 1
  arpNextTime = reaper.time_precise()
  -- Send first note immediately
  if #arpQueue > 0 then
    -- Round robin: also slightly randomize velocity for first note
    local v = velocity
    if useRR then v = math.max(1, math.min(127, velocity + math.random(-12, 5))) end
    reaper.StuffMIDIMessage(0, 0x90, arpQueue[1], v)
    notesThatArePlaying[#notesThatArePlaying + 1] = arpQueue[1]
    arpIndex = 2
    arpNextTime = reaper.time_precise() + (arpDelays[1] or baseDelay) / 1000
  end
end

local function updateArpeggio()
  if arpIndex <= 0 or arpIndex > #arpQueue then return end
  if reaper.time_precise() >= arpNextTime then
    local note = arpQueue[arpIndex]
    -- Round robin: slightly randomize velocity per note
    local v = arpVel
    if getArpRR() then v = math.max(1, math.min(127, arpVel + math.random(-12, 5))) end
    reaper.StuffMIDIMessage(0, 0x90, note, v)
    notesThatArePlaying[#notesThatArePlaying + 1] = note
    local delay = arpDelays[arpIndex] or getArpDelay()
    arpIndex = arpIndex + 1
    arpNextTime = reaper.time_precise() + delay / 1000
  end
end

local function previewChord(midiNotes, velocity)
  if getArpMode() then
    previewChordArpeggiated(midiNotes, velocity)
  else
    previewChordImmediate(midiNotes, velocity)
  end
end

-- ============================================================================
-- MIDI INSERTION
-- ============================================================================

local function activeTake()
  local ed = reaper.MIDIEditor_GetActive()
  if ed then return reaper.MIDIEditor_GetTake(ed) end
  return nil
end

local function insertChord(midiNotes, velocity)
  local take = activeTake()
  if not take then return end
  
  local cursorPos = reaper.GetCursorPosition()
  local startPPQ = reaper.MIDI_GetPPQPosFromProjTime(take, cursorPos)
  local gridQN = reaper.MIDI_GetGrid(take)
  local cursorQN = reaper.MIDI_GetProjQNFromPPQPos(take, startPPQ)
  local endPPQ = reaper.MIDI_GetPPQPosFromProjQN(take, cursorQN + gridQN)
  
  -- Extend item if needed
  local item = reaper.GetMediaItemTake_Item(take)
  local itemPos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
  local itemLen = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
  local endTime = reaper.MIDI_GetProjTimeFromPPQPos(take, endPPQ)
  if endTime > itemPos + itemLen then
    reaper.SetMediaItemInfo_Value(item, "D_LENGTH", endTime - itemPos)
  end
  
  reaper.Undo_BeginBlock()
  
  local arpOffset = 0
  local baseStagger = getArpMode() and math.floor((endPPQ - startPPQ) * 0.02) or 0
  local useRR = getArpRR()
  
  for i, note in ipairs(midiNotes) do
    if note >= 0 and note <= 127 then
      local noteStart = startPPQ + arpOffset
      -- Round robin: randomize velocity per note for inserted MIDI too
      local noteVel = velocity
      if getArpMode() and useRR then
        noteVel = math.max(1, math.min(127, velocity + math.random(-12, 5)))
      end
      reaper.MIDI_InsertNote(take, false, false, noteStart, endPPQ, 0, note, noteVel, false)
      if getArpMode() then
        -- Round robin: vary stagger between 40% and 180% of base
        local stagger = baseStagger
        if useRR then stagger = math.max(1, math.floor(baseStagger * (0.4 + math.random() * 1.4))) end
        arpOffset = arpOffset + stagger
      end
    end
  end
  
  reaper.MIDI_Sort(take)
  local nextPos = reaper.MIDI_GetProjTimeFromPPQPos(take, endPPQ)
  reaper.SetEditCurPos(nextPos, true, false)
  reaper.Undo_EndBlock("AdvChordGun: Insert chord", -1)
  reaper.UpdateArrange()
end

-- ============================================================================
-- PLAY A CHORD (preview + optional insert)
-- ============================================================================


local function playChord(degree, chordIdx)
  local rootIdx = getScaleRoot()
  local scaleIdx = getScaleType()
  local octave = getOctave()
  local vel = getVelocity()
  local inv = getInversion()
  
  local scaleNotes = getScaleNotes(rootIdx, scaleIdx)
  local rootMidi = scaleNotes[degree] + (octave + 1) * 12
  local chordDef = ALL_CHORDS[chordIdx]
  
  local midiNotes = buildChordMIDI(rootMidi, chordDef, inv)
  previewChord(midiNotes, vel)
  
  if getInsertMode() and activeTake() then
    insertChord(midiNotes, vel)
  end
  
  lastPlayedRoot = scaleNotes[degree]
  lastPlayedPCs = getChordPitchClasses(scaleNotes[degree], chordDef)
  rebuildSuggestions(rootIdx, scaleIdx)
  
  -- Find grid row for this chord (for highlight/trail)
  local gridRow = -1
  for ri, row in ipairs(GRID_ROWS) do
    if row.type == "chord" and row.chordIdx == chordIdx then
      gridRow = ri; break
    end
  end
  GUI.currentRow = gridRow
  GUI.currentDeg = degree
  
  -- Push to trail
  table.insert(GUI.trail, 1, {row = gridRow, deg = degree})
  while #GUI.trail > GUI.maxTrail do table.remove(GUI.trail) end
  
  local rootName = NOTE_NAMES[scaleNotes[degree] + 1]
  local chordText = rootName .. chordDef.display
  if inv ~= 0 then chordText = chordText .. " inv" .. inv end
  
  return chordText, midiNotes
end

-- ============================================================================
-- GUI STATE
-- ============================================================================

-- (GUI and degreeChordMap are forward-declared above playChord)

local function mouseJustClicked()
  return (gfx.mouse_cap & 1 == 1) and (GUI.lastMouseCap & 1 == 0)
end

local function mouseIn(x, y, w, h)
  return gfx.mouse_x >= x and gfx.mouse_x < x + w
     and gfx.mouse_y >= y and gfx.mouse_y < y + h
end

-- ============================================================================
-- COLOR PALETTE
-- ============================================================================

local C = {
  bg         = {0.12, 0.12, 0.16},
  panelBg    = {0.16, 0.16, 0.21},
  text       = {0.88, 0.88, 0.92},
  textDim    = {0.50, 0.50, 0.58},
  accent     = {0.30, 0.55, 0.90},
  accentHi   = {0.45, 0.70, 1.00},
  btnNorm    = {0.20, 0.20, 0.28},
  btnHover   = {0.28, 0.28, 0.38},
  btnActive  = {0.30, 0.55, 0.90},
  gridCell   = {0.18, 0.18, 0.25},
  gridHover  = {0.26, 0.26, 0.36},
  gridDia    = {0.22, 0.32, 0.42},  -- diatonic row highlight
  headerRow  = {0.14, 0.14, 0.20},
  catText    = {0.60, 0.50, 0.80},
  sep        = {0.28, 0.28, 0.35},
  green      = {0.30, 0.70, 0.40},
  red        = {0.75, 0.35, 0.35},
  orange     = {0.90, 0.60, 0.20},
}

local function sc(col) gfx.set(col[1], col[2], col[3], col[4] or 1) end

local function drawRR(x, y, w, h, r, fill)
  if fill then
    gfx.rect(x+r, y, w-2*r, h, true)
    gfx.rect(x, y+r, w, h-2*r, true)
    gfx.circle(x+r, y+r, r, true)
    gfx.circle(x+w-r-1, y+r, r, true)
    gfx.circle(x+r, y+h-r-1, r, true)
    gfx.circle(x+w-r-1, y+h-r-1, r, true)
  else
    gfx.roundrect(x, y, w, h, r, true)
  end
end

local function drawText(x, y, w, h, txt, align)
  gfx.x = x; gfx.y = y
  gfx.drawstr(txt, align or 1, x + w, y + h)
end

-- ============================================================================
-- DROPDOWN HELPER (using gfx.showmenu)
-- ============================================================================

local function showDropdown(x, y, options, currentIdx)
  local menuStr = ""
  for i, opt in ipairs(options) do
    if i > 1 then menuStr = menuStr .. "|" end
    if i == currentIdx then menuStr = menuStr .. "!" end
    menuStr = menuStr .. opt
  end
  gfx.x = x; gfx.y = y
  local choice = gfx.showmenu(menuStr)
  if choice > 0 then return choice end
  return currentIdx
end

-- ============================================================================
-- DRAW: TOP CONTROLS
-- ============================================================================

local function drawTopControls()
  local pad = 10
  local y = 8
  local btnH = 26
  local x = pad
  
  gfx.setfont(1, "Arial", 12)
  
  -- Root note dropdown
  sc(C.textDim)
  drawText(x, y - 1, 40, 14, "Root:", 0)
  x = x + 38
  local rootIdx = getScaleRoot()
  local rootHover = mouseIn(x, y, 50, btnH)
  sc(rootHover and C.btnHover or C.btnNorm)
  drawRR(x, y, 50, btnH, 3, true)
  gfx.setfont(1, "Arial", 13, string.byte('b'))
  sc(C.text)
  drawText(x, y, 50, btnH, NOTE_NAMES[rootIdx] .. " v", 5)
  if mouseJustClicked() and rootHover then
    local choice = showDropdown(x, y + btnH, NOTE_NAMES, rootIdx)
    setScaleRoot(choice)
    rebuildSuggestions(choice, getScaleType())
  end
  x = x + 58
  
  -- Scale type dropdown
  gfx.setfont(1, "Arial", 12)
  sc(C.textDim)
  drawText(x, y - 1, 40, 14, "Scale:", 0)
  x = x + 40
  local scaleIdx = getScaleType()
  local scaleNames = {}
  for _, s in ipairs(scales) do scaleNames[#scaleNames+1] = s.name end
  local scaleHover = mouseIn(x, y, 180, btnH)
  sc(scaleHover and C.btnHover or C.btnNorm)
  drawRR(x, y, 180, btnH, 3, true)
  gfx.setfont(1, "Arial", 12)
  sc(C.text)
  drawText(x, y, 180, btnH, scales[scaleIdx].name .. " v", 5)
  if mouseJustClicked() and scaleHover then
    local choice = showDropdown(x, y + btnH, scaleNames, scaleIdx)
    setScaleType(choice)
    rebuildSuggestions(getScaleRoot(), choice)
  end
  x = x + 188
  
  -- Octave dropdown
  sc(C.textDim)
  gfx.setfont(1, "Arial", 12)
  drawText(x, y - 1, 48, 14, "Octave:", 0)
  x = x + 48
  local oct = getOctave()
  local octNames = {}
  for i = -1, 8 do octNames[#octNames+1] = tostring(i) end
  local octMenuIdx = oct + 2  -- -1 is index 1
  local octHover = mouseIn(x, y, 40, btnH)
  sc(octHover and C.btnHover or C.btnNorm)
  drawRR(x, y, 40, btnH, 3, true)
  sc(C.text)
  drawText(x, y, 40, btnH, tostring(oct) .. " v", 5)
  if mouseJustClicked() and octHover then
    local choice = showDropdown(x, y + btnH, octNames, octMenuIdx)
    setOctave(choice - 2)
  end
  x = x + 48
  
  -- Velocity dropdown
  sc(C.textDim)
  drawText(x, y - 1, 30, 14, "Vel:", 0)
  x = x + 30
  local vel = getVelocity()
  local velNames = {}
  local velValues = {16, 32, 48, 64, 80, 96, 112, 127}
  local velMenuIdx = 6
  for i, v in ipairs(velValues) do
    velNames[#velNames+1] = tostring(v)
    if v == vel then velMenuIdx = i end
  end
  local velHover = mouseIn(x, y, 45, btnH)
  sc(velHover and C.btnHover or C.btnNorm)
  drawRR(x, y, 45, btnH, 3, true)
  sc(C.text)
  drawText(x, y, 45, btnH, tostring(vel) .. " v", 5)
  if mouseJustClicked() and velHover then
    local choice = showDropdown(x, y + btnH, velNames, velMenuIdx)
    if choice > 0 then setVelocity(velValues[choice]) end
  end
  x = x + 53
  
  -- Inversion
  sc(C.textDim)
  drawText(x, y - 1, 60, 14, "Inversion:", 0)
  x = x + 62
  local inv = getInversion()
  local invDecHover = mouseIn(x, y, 20, btnH)
  local invIncHover = mouseIn(x + 44, y, 20, btnH)
  sc(C.btnNorm)
  drawRR(x, y, 64, btnH, 3, true)
  sc(invDecHover and C.accentHi or C.textDim)
  drawText(x, y, 20, btnH, "<", 5)
  sc(invIncHover and C.accentHi or C.textDim)
  drawText(x + 44, y, 20, btnH, ">", 5)
  sc(C.text)
  gfx.setfont(1, "Arial", 13, string.byte('b'))
  drawText(x, y, 64, btnH, tostring(inv), 5)
  if mouseJustClicked() then
    if invDecHover and inv > -4 then setInversion(inv - 1) end
    if invIncHover and inv < 4 then setInversion(inv + 1) end
  end
  x = x + 72
  
  -- Insert toggle
  local insMode = getInsertMode()
  local insHover = mouseIn(x, y, 82, btnH)
  sc(insMode and C.green or C.btnNorm)
  drawRR(x, y, 82, btnH, 3, true)
  sc({1,1,1})
  gfx.setfont(1, "Arial", 11, string.byte('b'))
  drawText(x, y, 82, btnH, insMode and "INSERT ON" or "INSERT OFF", 5)
  if mouseJustClicked() and insHover then setInsertMode(not insMode) end
  x = x + 90
  
  -- Arpeggiate toggle
  local arpMode = getArpMode()
  local arpHover = mouseIn(x, y, 68, btnH)
  sc(arpMode and C.orange or C.btnNorm)
  drawRR(x, y, 68, btnH, 3, true)
  sc({1,1,1})
  drawText(x, y, 68, btnH, arpMode and "ARP ON" or "ARP OFF", 5)
  if mouseJustClicked() and arpHover then setArpMode(not arpMode) end
  
  -- Arpeggiate delay (only show if arp is on)
  if arpMode then
    x = x + 74
    local arpMs = getArpDelay()
    sc(C.textDim)
    gfx.setfont(1, "Arial", 10)
    drawText(x, y + 2, 30, 14, tostring(arpMs) .. "ms", 0)
    local arpDecH = mouseIn(x + 30, y, 14, btnH)
    local arpIncH = mouseIn(x + 46, y, 14, btnH)
    sc(arpDecH and C.accentHi or C.textDim)
    drawText(x + 30, y, 14, btnH, "-", 5)
    sc(arpIncH and C.accentHi or C.textDim)
    drawText(x + 46, y, 14, btnH, "+", 5)
    if mouseJustClicked() then
      if arpDecH and arpMs > 10 then setArpDelay(arpMs - 5) end
      if arpIncH and arpMs < 120 then setArpDelay(arpMs + 5) end
    end
    
    -- Round Robin toggle
    x = x + 64
    local rrOn = getArpRR()
    local rrHover = mouseIn(x, y, 38, btnH)
    sc(rrOn and {0.65, 0.45, 0.85} or C.btnNorm)
    drawRR(x, y, 38, btnH, 3, true)
    sc({1,1,1})
    gfx.setfont(1, "Arial", 9, string.byte('b'))
    drawText(x, y, 38, btnH, rrOn and "RR" or "RR", 5)
    if mouseJustClicked() and rrHover then setArpRR(not rrOn) end
    -- Tooltip-ish label
    sc(C.textDim)
    gfx.setfont(1, "Arial", 8)
    drawText(x - 2, y + btnH + 1, 42, 10, "humanize", 5)
    x = x + 110  -- account for arp delay (~64) + RR button (~38) + spacing
  else
    x = x + 8  -- small gap after ARP OFF button
  end
  
  -- Trail toggle (always visible)
  local trailOn = getTrailOn()
  local trailHover = mouseIn(x, y, 70, btnH)
  sc(trailOn and {0.85, 0.65, 0.20} or C.btnNorm)
  drawRR(x, y, 70, btnH, 3, true)
  sc({1,1,1})
  gfx.setfont(1, "Arial", 10, string.byte('b'))
  drawText(x, y, 70, btnH, trailOn and "TRAIL ON" or "TRAIL OFF", 5)
  if mouseJustClicked() and trailHover then
    setTrailOn(not trailOn)
    if not getTrailOn() then GUI.trail = {} end
  end
  
  -- MIDI Editor status
  local hasEditor = activeTake() ~= nil
  sc(hasEditor and C.green or C.red)
  gfx.setfont(1, "Arial", 10)
  drawText(gfx.w - 130, y + 6, 120, 14, hasEditor and "MIDI Editor: Open" or "MIDI Editor: Closed", 1)
  
  -- Scale notes display
  local y2 = y + btnH + 6
  local scaleNoteNames = {}
  local sn = getScaleNotes(getScaleRoot(), getScaleType())
  for i, n in ipairs(sn) do scaleNoteNames[i] = NOTE_NAMES[n + 1] end
  sc(C.textDim)
  gfx.setfont(1, "Arial", 11)
  drawText(pad, y2, 400, 14, "Scale notes: " .. table.concat(scaleNoteNames, "  "), 0)
  
  return y2 + 20  -- return Y position for grid start
end

-- ============================================================================
-- DRAW: CHORD GRID
-- ============================================================================

local GRID = {
  labelW = 82,    -- left column for chord type labels
  cellH = 28,     -- row height
  headerH = 22,
  cellH = 28,
  labelW = 82,
  gap = 2,
  topPad = 0,
}
-- Override header cell height for degree headers (taller to fit dropdown)
GRID.degHeaderH = 42

local function drawChordGrid(gridStartY)
  local pad = 10
  local rootIdx = getScaleRoot()
  local scaleIdx = getScaleType()
  local scaleNotes = getScaleNotes(rootIdx, scaleIdx)
  local degHeaders = DEGREE_HEADERS[scaleIdx] or DEGREE_HEADERS[1]
  local inv = getInversion()
  
  -- Calculate column width
  local availW = gfx.w - 2 * pad - GRID.labelW
  local colW = math.floor((availW - 6 * GRID.gap) / 7)
  
  -- Grid clip region
  local gridX = pad
  local gridY = gridStartY
  local gridH = gfx.h - gridY - 90  -- leave room for bottom panel
  
  -- Draw degree headers (fixed, not scrollable)
  local headerY = gridY
  gfx.setfont(1, "Arial", 14, string.byte('b'))
  
  -- Empty top-left corner
  sc(C.headerRow)
  gfx.rect(gridX, headerY, GRID.labelW, GRID.degHeaderH, true)
  sc(C.textDim)
  gfx.setfont(1, "Arial", 10)
  drawText(gridX, headerY, GRID.labelW, GRID.cellH, "Type", 5)
  
  for deg = 1, 7 do
    local cx = gridX + GRID.labelW + (deg - 1) * (colW + GRID.gap)
    sc(C.headerRow)
    gfx.rect(cx, headerY, colW, GRID.degHeaderH, true)
    sc(C.accent)
    gfx.setfont(1, "Arial", 13, string.byte('b'))
    drawText(cx, headerY, colW, 14, degHeaders[deg], 5)
    sc(C.textDim)
    gfx.setfont(1, "Arial", 9)
    drawText(cx, headerY + 13, colW, 10, NOTE_NAMES[scaleNotes[deg] + 1], 5)
    
    -- Key-binding dropdown (click to choose chord for this number key)
    local dcurIdx = getDegreeChord(deg)
    local dcur = ALL_CHORDS[dcurIdx]
    local ddY = headerY + GRID.degHeaderH - 11
    local ddHov = mouseIn(cx + 2, ddY, colW - 4, 11)
    sc(ddHov and C.btnHover or C.panelBg)
    gfx.rect(cx + 2, ddY, colW - 4, 11, true)
    sc(ddHov and C.accentHi or C.textDim)
    gfx.setfont(1, "Arial", 8)
    drawText(cx + 2, ddY - 1, colW - 4, 11, "["..deg.."] "..(dcur.display ~= "" and dcur.display or "maj").." v", 5)
    if mouseJustClicked() and ddHov then
      local opts = {}
      for i, c in ipairs(ALL_CHORDS) do
        opts[i] = c.name.." ("..(c.display ~= "" and c.display or "maj")..")"
      end
      local choice = showDropdown(cx, ddY + 12, opts, dcurIdx)
      if choice > 0 then setDegreeChord(deg, choice) end
    end
  end
  
  local scrollableY = headerY + GRID.degHeaderH + 2
  local scrollableH = gridH - GRID.cellH - 2
  
  -- Handle mouse wheel scrolling
  local wheel = gfx.mouse_wheel
  if wheel ~= 0 and mouseIn(gridX, scrollableY, gfx.w - 2*pad, scrollableH) then
    GUI.scrollY = GUI.scrollY - math.floor(wheel / 8)
    gfx.mouse_wheel = 0
  end
  
  -- Calculate total grid content height
  local totalH = 0
  for _, row in ipairs(GRID_ROWS) do
    totalH = totalH + (row.type == "header" and GRID.headerH or GRID.cellH) + GRID.gap
  end
  GUI.maxScroll = math.max(0, totalH - scrollableH)
  GUI.scrollY = math.max(0, math.min(GUI.scrollY, GUI.maxScroll))
  
  -- Determine diatonic chord indices for highlighting
  local diatonicIdx = {}
  for deg = 1, 7 do
    diatonicIdx[deg] = getDiatonicChordIdx(rootIdx, scaleIdx, deg)
  end
  
  -- Draw grid rows (clipped to scrollable area)
  local drawY = scrollableY - GUI.scrollY
  GUI.hoveredRow = -1
  GUI.hoveredDeg = -1
  
  for ri, row in ipairs(GRID_ROWS) do
    local rowH = row.type == "header" and GRID.headerH or GRID.cellH
    
    -- Skip if fully above visible area
    if drawY + rowH > scrollableY and drawY < scrollableY + scrollableH then
      
      if row.type == "header" then
        -- Category header row
        sc(C.headerRow)
        gfx.rect(gridX, math.max(drawY, scrollableY), 
                 GRID.labelW + 7 * (colW + GRID.gap), 
                 math.min(rowH, scrollableY + scrollableH - drawY), true)
        if drawY >= scrollableY then
          sc(C.catText)
          gfx.setfont(1, "Arial", 11, string.byte('b'))
          drawText(gridX + 6, drawY, 300, rowH, row.name, 0)
        end
        
      else
        -- Chord row
        local chordDef = row.chord
        local chordIdx = row.chordIdx
        
        -- Label column
        sc(C.panelBg)
        gfx.rect(gridX, drawY, GRID.labelW, rowH, true)
        sc(C.textDim)
        gfx.setfont(1, "Arial", 10)
        drawText(gridX + 4, drawY, GRID.labelW - 8, rowH, chordDef.display ~= "" and chordDef.display or chordDef.name, 5)
        
        -- Chord cells for each degree
        for deg = 1, 7 do
          local cx = gridX + GRID.labelW + (deg - 1) * (colW + GRID.gap)
          local cellVisible = drawY >= scrollableY and drawY + rowH <= scrollableY + scrollableH
          
          if cellVisible then
            local isHovered = mouseIn(cx, drawY, colW, rowH)
            local isDiatonic = (chordIdx == diatonicIdx[deg])
            
            -- Base cell color
            if isDiatonic then
              sc(C.gridDia)
            elseif isHovered then
              sc(C.gridHover)
            else
              sc(C.gridCell)
            end
            gfx.rect(cx, drawY, colW, rowH, true)
            
            -- Suggestion overlay
            if suggestionCache[ri] and suggestionCache[ri][deg] then
              local sugCol = getSuggestionColor(suggestionCache[ri][deg])
              if sugCol then
                gfx.set(sugCol[1], sugCol[2], sugCol[3], sugCol[4])
                gfx.rect(cx, drawY, colW, rowH, true)
              end
            end
            
            -- Hover outline
            if isHovered then
              sc(C.accent)
              gfx.rect(cx, drawY, colW, rowH, false)
              GUI.hoveredRow = ri
              GUI.hoveredDeg = deg
            end
            
            -- CURRENT chord: solid gold fill
            if ri == GUI.currentRow and deg == GUI.currentDeg then
              gfx.set(1.0, 0.78, 0.20, 0.55)
              gfx.rect(cx, drawY, colW, rowH, true)
              gfx.set(1.0, 0.85, 0.30, 1)
              gfx.rect(cx, drawY, colW, rowH, false)
              gfx.rect(cx+1, drawY+1, colW-2, rowH-2, false)
            else
              -- Trailing highlight: fading gold borders for recent chords
              if getTrailOn() then
                for ti, t in ipairs(GUI.trail) do
                  if ti > 1 and t.row == ri and t.deg == deg then
                    local fade = 1.0 - (ti - 1) / GUI.maxTrail
                    gfx.set(1.0, 0.82, 0.25, fade * 0.8)
                    gfx.rect(cx, drawY, colW, rowH, false)
                    gfx.rect(cx+1, drawY+1, colW-2, rowH-2, false)
                    break
                  end
                end
              end
            end
            
            -- Chord label
            local rootName = NOTE_NAMES[scaleNotes[deg] + 1]
            local label = rootName .. chordDef.display
            
            gfx.setfont(1, "Arial", 12)
            if isDiatonic then
              sc({1, 1, 1})
            else
              sc(C.text)
            end
            drawText(cx, drawY, colW, rowH, label, 5)
            
            -- Click handling
            if mouseJustClicked() and isHovered then
              GUI.lastChordText, GUI.lastChordNotes = playChord(deg, chordIdx)
            end
          end
        end
      end
    end
    
    drawY = drawY + rowH + GRID.gap
  end
  
  -- Draw scrollbar
  if GUI.maxScroll > 0 then
    local sbX = gfx.w - pad - 6
    local sbH = scrollableH
    local thumbH = math.max(20, sbH * (scrollableH / totalH))
    local thumbY = scrollableY + (GUI.scrollY / GUI.maxScroll) * (sbH - thumbH)
    
    sc({0.25, 0.25, 0.32})
    gfx.rect(sbX, scrollableY, 6, sbH, true)
    sc({0.45, 0.45, 0.55})
    drawRR(sbX, thumbY, 6, thumbH, 3, true)
  end
  
  return scrollableY + scrollableH  -- return bottom Y
end

-- ============================================================================
-- DRAW: BOTTOM PANEL (chord notes + status)
-- ============================================================================

local function drawBottomPanel(panelY)
  local pad = 10
  local y = panelY + 6
  
  -- Separator
  sc(C.sep)
  gfx.line(pad, panelY, gfx.w - pad, panelY)
  
  -- Current chord name
  gfx.setfont(1, "Arial", 22, string.byte('b'))
  sc(C.accent)
  drawText(pad, y + 4, 200, 30, GUI.lastChordText, 0)
  
  -- Clickable note buttons for the last chord
  if GUI.lastChordNotes and #GUI.lastChordNotes > 0 then
    local noteX = pad + 200
    local noteBtnW = 52
    local noteBtnH = 30
    local vel = getVelocity()
    
    gfx.setfont(1, "Arial", 10)
    sc(C.textDim)
    drawText(noteX, y - 2, 100, 14, "Chord tones (click to play):", 0)
    
    local btnX = noteX
    local btnY = y + 12
    for i, note in ipairs(GUI.lastChordNotes) do
      if note >= 0 and note <= 127 then
        local noteName = NOTE_NAMES[(note % 12) + 1]
        local noteOct = math.floor(note / 12) - 1
        local label = noteName .. noteOct
        
        local hover = mouseIn(btnX, btnY, noteBtnW, noteBtnH)
        sc(hover and C.btnHover or C.btnNorm)
        drawRR(btnX, btnY, noteBtnW, noteBtnH, 3, true)
        
        gfx.setfont(1, "Arial", 12)
        sc(hover and C.accentHi or C.text)
        drawText(btnX, btnY, noteBtnW, noteBtnH, label, 5)
        
        -- Click to play individual note
        if mouseJustClicked() and hover then
          stopAllNotes()
          reaper.StuffMIDIMessage(0, 0x90, note, vel)
          notesThatArePlaying[#notesThatArePlaying + 1] = note
          
          -- Insert single note if in insert mode
          if getInsertMode() and activeTake() then
            local take = activeTake()
            local cursorPos = reaper.GetCursorPosition()
            local startPPQ = reaper.MIDI_GetPPQPosFromProjTime(take, cursorPos)
            local gridQN = reaper.MIDI_GetGrid(take)
            local cursorQN = reaper.MIDI_GetProjQNFromPPQPos(take, startPPQ)
            local endPPQ = reaper.MIDI_GetPPQPosFromProjQN(take, cursorQN + gridQN)
            reaper.Undo_BeginBlock()
            reaper.MIDI_InsertNote(take, false, false, startPPQ, endPPQ, 0, note, vel, false)
            reaper.MIDI_Sort(take)
            local nextPos = reaper.MIDI_GetProjTimeFromPPQPos(take, endPPQ)
            reaper.SetEditCurPos(nextPos, true, false)
            reaper.Undo_EndBlock("AdvChordGun: Insert note", -1)
            reaper.UpdateArrange()
          end
        end
        
        btnX = btnX + noteBtnW + 4
      end
    end
  end
  
  -- Help / shortcuts
  gfx.setfont(1, "Arial", 9)
  sc(C.textDim)
  local helpY = gfx.h - 16
  drawText(pad, helpY, gfx.w - 2*pad, 14, 
    "Keys 1-7: diatonic chords | 0: stop | Space: insert | A: arpeggiate | Up/Down: scroll | Esc: close", 0)
end

-- ============================================================================
-- KEYBOARD
-- ============================================================================

local function handleKeyboard()
  local ch = gfx.getchar()
  if ch == -1 then return false end
  
  -- 1-7: play diatonic chord for that degree
  if ch >= string.byte('1') and ch <= string.byte('7') then
    local deg = ch - string.byte('0')
    GUI.lastChordText, GUI.lastChordNotes = playChord(deg, getDegreeChord(deg))
  end
  
  -- 0: stop
  if ch == string.byte('0') then
    stopAllNotes()
    GUI.lastChordText = ""
    GUI.lastChordNotes = {}
    lastPlayedRoot = nil
    lastPlayedPCs = nil
    suggestionCache = {}
  end
  
  
  -- A: toggle arpeggiate
  if ch == string.byte('a') or ch == string.byte('A') then
    setArpMode(not getArpMode())
  end
  
  -- Up arrow: scroll up
  if ch == 30064 then
    GUI.scrollY = math.max(0, GUI.scrollY - 30)
  end
  -- Down arrow: scroll down
  if ch == 1685026670 then
    GUI.scrollY = math.min(GUI.maxScroll, GUI.scrollY + 30)
  end
  
  -- Escape: close
  if ch == 27 then
    stopAllNotes()
    return false
  end
  
  return true
end

-- ============================================================================
-- MAIN
-- ============================================================================

local function init()
  gfx.init("Advanced ChordGun", GUI.w, GUI.h, 0)
  gfx.setfont(1, "Arial", 14)
end

local function mainLoop()
  if not handleKeyboard() then
    gfx.quit()
    return
  end
  
  -- Arpeggiate updates
  updateArpeggio()
  
  -- Clear
  sc(C.bg)
  gfx.rect(0, 0, gfx.w, gfx.h, true)
  
  -- Draw sections
  local gridStartY = drawTopControls()
  local gridBottomY = drawChordGrid(gridStartY)
  drawBottomPanel(gridBottomY)
  
  GUI.lastMouseCap = gfx.mouse_cap
  gfx.update()
  reaper.defer(mainLoop)
end

init()
mainLoop()
