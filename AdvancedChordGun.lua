-- @description Advanced ChordGun
-- @author del-paso
-- @version 5.0
-- @about
--   ### Advanced ChordGun v5
--   Expanded chord composition tool for REAPER inspired by Pandabot's ChordGun.
--   50+ chord types, chord grid, next-chord suggestions, arpeggiate, chord finder.

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
  { name = "Triads", chords = {
    { name = "Major", display = "", intervals = {0,4,7} },
    { name = "Minor", display = "m", intervals = {0,3,7} },
    { name = "Diminished", display = "dim", intervals = {0,3,6} },
    { name = "Augmented", display = "aug", intervals = {0,4,8} },
    { name = "Sus2", display = "sus2", intervals = {0,2,7} },
    { name = "Sus4", display = "sus4", intervals = {0,5,7} },
    { name = "Power (5th)", display = "5", intervals = {0,7} },
  }},
  { name = "Sixths", chords = {
    { name = "Major 6th", display = "6", intervals = {0,4,7,9} },
    { name = "Minor 6th", display = "m6", intervals = {0,3,7,9} },
    { name = "6/9", display = "6/9", intervals = {0,4,7,9,14} },
  }},
  { name = "Sevenths", chords = {
    { name = "Dominant 7", display = "7", intervals = {0,4,7,10} },
    { name = "Major 7", display = "maj7", intervals = {0,4,7,11} },
    { name = "Minor 7", display = "m7", intervals = {0,3,7,10} },
    { name = "Min/Maj 7", display = "m(M7)", intervals = {0,3,7,11} },
    { name = "Diminished 7", display = "dim7", intervals = {0,3,6,9} },
    { name = "Half-Dim 7", display = "m7b5", intervals = {0,3,6,10} },
    { name = "Aug 7", display = "7#5", intervals = {0,4,8,10} },
    { name = "Aug Maj 7", display = "M7#5", intervals = {0,4,8,11} },
    { name = "7sus4", display = "7sus4", intervals = {0,5,7,10} },
    { name = "7sus2", display = "7sus2", intervals = {0,2,7,10} },
  }},
  { name = "Ninths", chords = {
    { name = "Dominant 9", display = "9", intervals = {0,4,7,10,14} },
    { name = "Major 9", display = "maj9", intervals = {0,4,7,11,14} },
    { name = "Minor 9", display = "m9", intervals = {0,3,7,10,14} },
    { name = "m(Maj9)", display = "m(M9)", intervals = {0,3,7,11,14} },
    { name = "Add 9", display = "add9", intervals = {0,4,7,14} },
    { name = "m(add9)", display = "m(add9)", intervals = {0,3,7,14} },
  }},
  { name = "Elevenths", chords = {
    { name = "Dominant 11", display = "11", intervals = {0,4,7,10,14,17} },
    { name = "Major 11", display = "maj11", intervals = {0,4,7,11,14,17} },
    { name = "Minor 11", display = "m11", intervals = {0,3,7,10,14,17} },
    { name = "Add 11", display = "add11", intervals = {0,4,7,17} },
  }},
  { name = "Thirteenths", chords = {
    { name = "Dominant 13", display = "13", intervals = {0,4,7,10,14,21} },
    { name = "Major 13", display = "maj13", intervals = {0,4,7,11,14,21} },
    { name = "Minor 13", display = "m13", intervals = {0,3,7,10,14,21} },
  }},
  { name = "Extended Voicings (7-10 notes)", chords = {
    { name = "Maj13 full", display = "maj13*", intervals = {0,4,7,11,14,17,21} },
    { name = "Dom13 full", display = "13*", intervals = {0,4,7,10,14,17,21} },
    { name = "Min13 full", display = "m13*", intervals = {0,3,7,10,14,17,21} },
    { name = "Maj13#11", display = "M13#11", intervals = {0,4,7,11,14,18,21} },
    { name = "Polychord C/D", display = "C/D", intervals = {0,4,7,14,18,21} },
    { name = "Stack 5ths", display = "stack5", intervals = {0,7,14,21,28,35,42} },
    { name = "Cluster 9-note", display = "clst9", intervals = {0,2,4,7,9,11,14,16,19} },
    { name = "Mega 10-note", display = "mega10", intervals = {0,4,7,10,14,17,21,24,28,31} },
  }},
  { name = "Altered Dominants", chords = {
    { name = "7b9", display = "7b9", intervals = {0,4,7,10,13} },
    { name = "7#9", display = "7#9", intervals = {0,4,7,10,15} },
    { name = "7b5", display = "7b5", intervals = {0,4,6,10} },
    { name = "7#5", display = "7#5", intervals = {0,4,8,10} },
    { name = "7b5b9", display = "7b5b9", intervals = {0,4,6,10,13} },
    { name = "7#5#9", display = "7#5#9", intervals = {0,4,8,10,15} },
    { name = "7alt", display = "7alt", intervals = {0,4,6,10,13} },
  }},
}

local ALL_CHORDS = {}
local GRID_ROWS = {}
do
  local idx = 0
  for _, cat in ipairs(chordCategories) do
    table.insert(GRID_ROWS, {type="header", name=cat.name})
    for _, chord in ipairs(cat.chords) do
      idx = idx + 1
      chord.globalIdx = idx
      chord.category = cat.name
      ALL_CHORDS[idx] = chord
      table.insert(GRID_ROWS, {type="chord", chordIdx=idx, chord=chord})
    end
  end
end
local NUM_CHORD_TYPES = #ALL_CHORDS

-- ============================================================================
-- STATE
-- ============================================================================

local SECTION = "com.del-paso.AdvancedChordGun"
local PROJ = 0

-- Forward declarations
local GUI = {
  w = 930, h = 780, scrollY = 0, maxScroll = 0, lastMouseCap = 0,
  lastChordText = "", lastChordNotes = {},
  hoveredRow = -1, hoveredDeg = -1,
  currentRow = -1, currentDeg = -1,
  trail = {}, maxTrail = 8,
  dragging = false, dragChordIdx = -1, dragStartX = 0, dragStartY = 0,
  dragLabel = "",
  pianoNotes = {},  -- toggled notes for chord finder (pitch classes 0-11)
  pianoOctStart = 48, -- C3
  finderResult = "",
}

local degreeChordMap = {1,1,1,1,1,1,1}
local degreeOctOffset = {0,0,0,0,0,0,0}
local degreeInversion = {0,0,0,0,0,0,0}

local function getDegreeChord(d) return degreeChordMap[d] or 1 end
local function setDegreeChord(d,v) degreeChordMap[d] = v end
local function getDegreeOct(d) return degreeOctOffset[d] or 0 end
local function setDegreeOct(d,v) degreeOctOffset[d] = v end
local function getDegreeInv(d) return degreeInversion[d] or 0 end
local function setDegreeInv(d,v) degreeInversion[d] = v end

math.randomseed(os.time())

local function sv(k,v) reaper.SetProjExtState(PROJ,SECTION,k,tostring(v)) end
local function gv(k,d)
  local e,v = reaper.GetProjExtState(PROJ,SECTION,k)
  if e==0 or v=="" then sv(k,d); return d end; return v
end
local function gn(k,d) return tonumber(gv(k,d)) end
local function stv(k,t) reaper.SetProjExtState(PROJ,SECTION,k,table.concat(t,",")) end
local function gtv(k,d)
  local e,v = reaper.GetProjExtState(PROJ,SECTION,k)
  if e==0 or v=="" then stv(k,d); return {table.unpack(d)} end
  local o={}; for m in v:gmatch("([^,]+)") do o[#o+1]=m end; return o
end

local function getScaleRoot()   return gn("root",1) end
local function setScaleRoot(v)  sv("root",v) end
local function getScaleType()   return gn("stype",1) end
local function setScaleType(v)  sv("stype",v) end
local function getOctave()      return gn("oct",3) end
local function setOctave(v)     sv("oct",v) end
local function getVelocity()    return gn("vel",96) end
local function setVelocity(v)   sv("vel",v) end
local function getInversion()   return gn("inv",0) end
local function setInversion(v)  sv("inv",v) end
local function getInsertMode()  return gv("ins","true")=="true" end
local function setInsertMode(v) sv("ins",tostring(v)) end
local function getArpMode()     return gv("arp","false")=="true" end
local function setArpMode(v)    sv("arp",tostring(v)) end
local function getArpDelay()    return gn("arpms",35) end
local function setArpDelay(v)   sv("arpms",v) end
local function getArpRR()       return gv("arprr","true")=="true" end
local function setArpRR(v)      sv("arprr",tostring(v)) end
local function getTrailOn()     return gv("trail","true")=="true" end
local function setTrailOn(v)    sv("trail",tostring(v)) end

-- Text size: 0=small, 1=normal, 2=large, 3=xlarge
local function getTextSize()    return gn("txtsz",1) end
local function setTextSize(v)   sv("txtsz",v) end

-- Window size persistence
local function getWinW() return gn("winw",930) end
local function setWinW(v) sv("winw",v) end
local function getWinH() return gn("winh",780) end
local function setWinH(v) sv("winh",v) end
local function getWinX() return gn("winx",-1) end
local function setWinX(v) sv("winx",v) end
local function getWinY() return gn("winy",-1) end
local function setWinY(v) sv("winy",v) end

-- Text scaling
local TEXT_SCALES = {0.8, 1.0, 1.2, 1.45}
local TEXT_LABELS = {"S","M","L","XL"}
local function fs(baseSize)
  return math.floor(baseSize * TEXT_SCALES[getTextSize()+1] + 0.5)
end

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
  for i, interval in ipairs(chordDef.intervals) do notes[i] = rootMidi + interval end
  local inv = inversion or 0
  if inv > 0 then
    for i = 1, math.min(inv, #notes-1) do notes[1]=notes[1]+12; table.sort(notes) end
  elseif inv < 0 then
    for i = 1, math.min(-inv, #notes-1) do notes[#notes]=notes[#notes]-12; table.sort(notes) end
  end
  return notes
end

local function getChordPitchClasses(rootPC, chordDef)
  local pcs = {}
  for _, interval in ipairs(chordDef.intervals) do pcs[(rootPC+interval)%12] = true end
  return pcs
end

local function getDiatonicChordIdx(rootIdx, scaleIdx, degree)
  local sn = getScaleNotes(rootIdx, scaleIdx)
  local root = sn[degree]
  local third = sn[((degree-1+2)%7)+1]
  local fifth = sn[((degree-1+4)%7)+1]
  local t = (third-root)%12
  local f = (fifth-root)%12
  if t==4 and f==7 then return 1 end
  if t==3 and f==7 then return 2 end
  if t==3 and f==6 then return 3 end
  if t==4 and f==8 then return 4 end
  return 1
end

-- ============================================================================
-- CHORD FINDER
-- ============================================================================

local function identifyChord(pitchClasses)
  if #pitchClasses < 2 then return "" end
  table.sort(pitchClasses)
  local results = {}
  -- Try each pitch class as potential root
  for _, root in ipairs(pitchClasses) do
    local intervals = {}
    for _, pc in ipairs(pitchClasses) do
      intervals[#intervals+1] = (pc - root) % 12
    end
    table.sort(intervals)
    -- Remove duplicate 0 if present
    local uniq = {}
    local seen = {}
    for _, iv in ipairs(intervals) do
      if not seen[iv] then seen[iv]=true; uniq[#uniq+1]=iv end
    end
    -- Match against chord definitions (check if chord intervals mod 12 match)
    for _, chord in ipairs(ALL_CHORDS) do
      local cIntervals = {}
      local cSeen = {}
      for _, ci in ipairs(chord.intervals) do
        local m = ci % 12
        if not cSeen[m] then cSeen[m]=true; cIntervals[#cIntervals+1]=m end
      end
      table.sort(cIntervals)
      if #cIntervals == #uniq then
        local match = true
        for k = 1, #uniq do
          if uniq[k] ~= cIntervals[k] then match = false; break end
        end
        if match then
          local rootName = NOTE_NAMES[root+1]
          results[#results+1] = rootName .. chord.display
        end
      end
    end
  end
  if #results == 0 then return "No match" end
  -- Deduplicate
  local seen2 = {}; local deduped = {}
  for _, r in ipairs(results) do
    if not seen2[r] then seen2[r]=true; deduped[#deduped+1]=r end
  end
  return table.concat(deduped, ", ")
end

-- ============================================================================
-- SUGGESTIONS
-- ============================================================================

local lastPlayedRoot = nil
local lastPlayedPCs = nil
local suggestionCache = {}

local ROOT_MOVE_SCORES = {
  [0]=0.0,[1]=0.18,[2]=0.25,[3]=0.22,[4]=0.18,[5]=0.38,
  [6]=0.08,[7]=0.32,[8]=0.18,[9]=0.22,[10]=0.25,[11]=0.18,
}

local function computeSuggestionScore(toRoot, toChordDef)
  if not lastPlayedRoot or not lastPlayedPCs then return 0 end
  local toPCs = getChordPitchClasses(toRoot, toChordDef)
  local shared = 0
  for pc, _ in pairs(toPCs) do if lastPlayedPCs[pc] then shared=shared+1 end end
  local interval = (toRoot - lastPlayedRoot) % 12
  local rootScore = ROOT_MOVE_SCORES[interval] or 0.1
  local score = shared * 0.12 + rootScore
  if interval == 0 then score = 0.1 end
  return math.min(score, 1.0)
end

local function rebuildSuggestions(rootIdx, scaleIdx)
  suggestionCache = {}
  if not lastPlayedRoot then return end
  local sn = getScaleNotes(rootIdx, scaleIdx)
  for ri, row in ipairs(GRID_ROWS) do
    suggestionCache[ri] = {}
    if row.type == "chord" then
      for deg = 1, 7 do
        suggestionCache[ri][deg] = computeSuggestionScore(sn[deg], row.chord)
      end
    end
  end
end

local function getSuggestionColor(score)
  if score >= 0.55 then return {0.15,0.65,0.25,0.45} end
  if score >= 0.42 then return {0.35,0.65,0.15,0.35} end
  if score >= 0.30 then return {0.70,0.70,0.10,0.28} end
  if score >= 0.20 then return {0.80,0.50,0.10,0.22} end
  return nil
end

-- ============================================================================
-- MIDI PREVIEW AND ARPEGGIATE
-- ============================================================================

local notesThatArePlaying = {}
local arpQueue = {}
local arpDelays = {}
local arpVel = 96
local arpIndex = 0
local arpNextTime = 0

local function stopAllNotes()
  for _, note in ipairs(notesThatArePlaying) do
    reaper.StuffMIDIMessage(0, 0x80, note, 0)
  end
  notesThatArePlaying = {}; arpQueue = {}; arpDelays = {}; arpIndex = 0
end

local function previewChordImmediate(midiNotes, velocity)
  stopAllNotes()
  for _, note in ipairs(midiNotes) do
    if note >= 0 and note <= 127 then
      reaper.StuffMIDIMessage(0, 0x90, note, velocity)
      notesThatArePlaying[#notesThatArePlaying+1] = note
    end
  end
end

local function previewChordArpeggiated(midiNotes, velocity)
  stopAllNotes()
  arpQueue = {}; arpDelays = {}
  local baseDelay = getArpDelay()
  local useRR = getArpRR()
  for _, n in ipairs(midiNotes) do
    if n >= 0 and n <= 127 then
      arpQueue[#arpQueue+1] = n
      if useRR then
        arpDelays[#arpDelays+1] = math.max(8, math.floor(baseDelay * (0.4 + math.random()*1.4)))
      else
        arpDelays[#arpDelays+1] = baseDelay
      end
    end
  end
  arpVel = velocity; arpIndex = 1; arpNextTime = reaper.time_precise()
  if #arpQueue > 0 then
    local v = velocity
    if useRR then v = math.max(1, math.min(127, velocity + math.random(-12,5))) end
    reaper.StuffMIDIMessage(0, 0x90, arpQueue[1], v)
    notesThatArePlaying[#notesThatArePlaying+1] = arpQueue[1]
    arpIndex = 2
    arpNextTime = reaper.time_precise() + (arpDelays[1] or baseDelay) / 1000
  end
end

local function updateArpeggio()
  if arpIndex <= 0 or arpIndex > #arpQueue then return end
  if reaper.time_precise() >= arpNextTime then
    local note = arpQueue[arpIndex]
    local v = arpVel
    if getArpRR() then v = math.max(1, math.min(127, arpVel + math.random(-12,5))) end
    reaper.StuffMIDIMessage(0, 0x90, note, v)
    notesThatArePlaying[#notesThatArePlaying+1] = note
    local delay = arpDelays[arpIndex] or getArpDelay()
    arpIndex = arpIndex + 1
    arpNextTime = reaper.time_precise() + delay / 1000
  end
end

local function previewChord(midiNotes, velocity)
  if getArpMode() then previewChordArpeggiated(midiNotes, velocity)
  else previewChordImmediate(midiNotes, velocity) end
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
      local noteVel = velocity
      if getArpMode() and useRR then noteVel = math.max(1, math.min(127, velocity + math.random(-12,5))) end
      reaper.MIDI_InsertNote(take, false, false, startPPQ + arpOffset, endPPQ, 0, note, noteVel, false)
      if getArpMode() then
        local stagger = baseStagger
        if useRR then stagger = math.max(1, math.floor(baseStagger * (0.4 + math.random()*1.4))) end
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
-- PLAY CHORD
-- ============================================================================

local function playChord(degree, chordIdx)
  local rootIdx = getScaleRoot()
  local scaleIdx = getScaleType()
  local octave = getOctave() + getDegreeOct(degree)
  local vel = getVelocity()
  local inv = getInversion() + getDegreeInv(degree)
  local scaleNotes = getScaleNotes(rootIdx, scaleIdx)
  local rootMidi = scaleNotes[degree] + (octave + 1) * 12
  local chordDef = ALL_CHORDS[chordIdx]
  local midiNotes = buildChordMIDI(rootMidi, chordDef, inv)
  previewChord(midiNotes, vel)
  if getInsertMode() and activeTake() then insertChord(midiNotes, vel) end
  lastPlayedRoot = scaleNotes[degree]
  lastPlayedPCs = getChordPitchClasses(scaleNotes[degree], chordDef)
  rebuildSuggestions(rootIdx, scaleIdx)
  local gridRow = -1
  for ri, row in ipairs(GRID_ROWS) do
    if row.type == "chord" and row.chordIdx == chordIdx then gridRow = ri; break end
  end
  GUI.currentRow = gridRow; GUI.currentDeg = degree
  table.insert(GUI.trail, 1, {row = gridRow, deg = degree})
  while #GUI.trail > GUI.maxTrail do table.remove(GUI.trail) end
  local rootName = NOTE_NAMES[scaleNotes[degree]+1]
  local chordText = rootName .. chordDef.display
  if inv ~= 0 then chordText = chordText .. " inv" .. inv end
  return chordText, midiNotes
end

-- ============================================================================
-- GUI HELPERS
-- ============================================================================

local function mouseJustClicked()
  return (gfx.mouse_cap & 1 == 1) and (GUI.lastMouseCap & 1 == 0)
end
local function mouseJustReleased()
  return (gfx.mouse_cap & 1 == 0) and (GUI.lastMouseCap & 1 == 1)
end
local function mouseDown() return gfx.mouse_cap & 1 == 1 end
local function mouseIn(x,y,w,h)
  return gfx.mouse_x>=x and gfx.mouse_x<x+w and gfx.mouse_y>=y and gfx.mouse_y<y+h
end

-- ============================================================================
-- COLORS
-- ============================================================================

local C = {
  bg={0.12,0.12,0.16}, panelBg={0.16,0.16,0.21}, text={0.88,0.88,0.92},
  textDim={0.50,0.50,0.58}, accent={0.30,0.55,0.90}, accentHi={0.45,0.70,1.00},
  btnNorm={0.20,0.20,0.28}, btnHover={0.28,0.28,0.38}, btnActive={0.30,0.55,0.90},
  gridCell={0.18,0.18,0.25}, gridHover={0.26,0.26,0.36}, gridDia={0.22,0.32,0.42},
  headerRow={0.14,0.14,0.20}, catText={0.60,0.50,0.80}, sep={0.28,0.28,0.35},
  green={0.30,0.70,0.40}, red={0.75,0.35,0.35}, orange={0.90,0.60,0.20},
  pianoWhite={0.90,0.90,0.92}, pianoBlack={0.15,0.15,0.20},
  pianoActive={0.40,0.65,1.00},
}
local function sc(col) gfx.set(col[1],col[2],col[3],col[4] or 1) end

local function drawRR(x,y,w,h,r,fill)
  if fill then
    gfx.rect(x+r,y,w-2*r,h,true); gfx.rect(x,y+r,w,h-2*r,true)
    gfx.circle(x+r,y+r,r,true); gfx.circle(x+w-r-1,y+r,r,true)
    gfx.circle(x+r,y+h-r-1,r,true); gfx.circle(x+w-r-1,y+h-r-1,r,true)
  else gfx.roundrect(x,y,w,h,r,true) end
end

local function drawText(x,y,w,h,txt,align)
  gfx.x=x; gfx.y=y; gfx.drawstr(txt,align or 1,x+w,y+h)
end

local function showDropdown(x,y,options,curIdx)
  local s = ""
  for i,opt in ipairs(options) do
    if i>1 then s=s.."|" end
    if i==curIdx then s=s.."!" end
    s=s..opt
  end
  gfx.x=x; gfx.y=y
  local c = gfx.showmenu(s)
  if c>0 then return c end; return curIdx
end

-- ============================================================================
-- DRAW: TOP CONTROLS (Row 1: dropdowns, Row 2: degree assignments)
-- ============================================================================

-- Store degree header positions for drag-drop targets
local degreeSlots = {} -- [deg] = {x,y,w,h}

local function drawTopControls()
  local pad = 10
  local y = 8
  local btnH = 24
  local x = pad

  -- ROW 1: Root, Scale, Octave, Vel, Inv, Insert, Arp, Trail, TextSize
  gfx.setfont(1, "Arial", fs(11))
  sc(C.textDim); drawText(x,y,35,14,"Root:",0); x=x+35
  local rootIdx = getScaleRoot()
  local rootHov = mouseIn(x,y,48,btnH)
  sc(rootHov and C.btnHover or C.btnNorm); drawRR(x,y,48,btnH,3,true)
  gfx.setfont(1,"Arial",fs(12),string.byte('b')); sc(C.text)
  drawText(x,y,48,btnH,NOTE_NAMES[rootIdx].." v",5)
  if mouseJustClicked() and rootHov then
    local c = showDropdown(x,y+btnH,NOTE_NAMES,rootIdx); setScaleRoot(c)
    rebuildSuggestions(c,getScaleType())
  end; x=x+54

  gfx.setfont(1,"Arial",fs(11)); sc(C.textDim); drawText(x,y,38,14,"Scale:",0); x=x+38
  local scaleIdx = getScaleType()
  local sNames = {}; for _,s in ipairs(scales) do sNames[#sNames+1]=s.name end
  local scaleHov = mouseIn(x,y,168,btnH)
  sc(scaleHov and C.btnHover or C.btnNorm); drawRR(x,y,168,btnH,3,true)
  gfx.setfont(1,"Arial",fs(11)); sc(C.text)
  drawText(x,y,168,btnH,scales[scaleIdx].name.." v",5)
  if mouseJustClicked() and scaleHov then
    local c = showDropdown(x,y+btnH,sNames,scaleIdx); setScaleType(c)
    rebuildSuggestions(getScaleRoot(),c)
  end; x=x+174

  sc(C.textDim); drawText(x,y,36,14,"Oct:",0); x=x+36
  local oct = getOctave()
  local octNames = {}; for i=-1,8 do octNames[#octNames+1]=tostring(i) end
  local octHov = mouseIn(x,y,36,btnH)
  sc(octHov and C.btnHover or C.btnNorm); drawRR(x,y,36,btnH,3,true)
  sc(C.text); drawText(x,y,36,btnH,tostring(oct).." v",5)
  if mouseJustClicked() and octHov then setOctave(showDropdown(x,y+btnH,octNames,oct+2)-2) end; x=x+42

  sc(C.textDim); drawText(x,y,28,14,"Vel:",0); x=x+28
  local vel = getVelocity()
  local velVals = {16,32,48,64,80,96,112,127}
  local velNames = {}; local velMI = 6
  for i,v in ipairs(velVals) do velNames[i]=tostring(v); if v==vel then velMI=i end end
  local velHov = mouseIn(x,y,42,btnH)
  sc(velHov and C.btnHover or C.btnNorm); drawRR(x,y,42,btnH,3,true)
  sc(C.text); drawText(x,y,42,btnH,tostring(vel).." v",5)
  if mouseJustClicked() and velHov then
    local c = showDropdown(x,y+btnH,velNames,velMI); if c>0 then setVelocity(velVals[c]) end
  end; x=x+48

  -- Global Inversion
  sc(C.textDim); drawText(x,y,28,14,"Inv:",0); x=x+28
  local inv = getInversion()
  local invDH = mouseIn(x,y,18,btnH); local invIH = mouseIn(x+40,y,18,btnH)
  sc(C.btnNorm); drawRR(x,y,58,btnH,3,true)
  sc(invDH and C.accentHi or C.textDim); drawText(x,y,18,btnH,"<",5)
  sc(invIH and C.accentHi or C.textDim); drawText(x+40,y,18,btnH,">",5)
  sc(C.text); gfx.setfont(1,"Arial",fs(12),string.byte('b'))
  drawText(x,y,58,btnH,tostring(inv),5)
  if mouseJustClicked() then
    if invDH and inv>-4 then setInversion(inv-1) end
    if invIH and inv<4 then setInversion(inv+1) end
  end; x=x+64

  -- Insert toggle
  local insMode = getInsertMode(); local insHov = mouseIn(x,y,72,btnH)
  sc(insMode and C.green or C.btnNorm); drawRR(x,y,72,btnH,3,true)
  sc({1,1,1}); gfx.setfont(1,"Arial",fs(10),string.byte('b'))
  drawText(x,y,72,btnH,insMode and "INSERT ON" or "INSERT OFF",5)
  if mouseJustClicked() and insHov then setInsertMode(not insMode) end; x=x+78

  -- Arp toggle
  local arpMode = getArpMode(); local arpHov = mouseIn(x,y,60,btnH)
  sc(arpMode and C.orange or C.btnNorm); drawRR(x,y,60,btnH,3,true)
  sc({1,1,1}); drawText(x,y,60,btnH,arpMode and "ARP ON" or "ARP OFF",5)
  if mouseJustClicked() and arpHov then setArpMode(not arpMode) end
  x = x + 66  -- ALWAYS advance past the arp button

  -- Arp sub-controls (only when arp is on)
  if arpMode then
    local arpMs = getArpDelay()
    sc(C.textDim); gfx.setfont(1,"Arial",fs(9))
    drawText(x,y+4,30,14,tostring(arpMs).."ms",0)
    local adH = mouseIn(x+30,y,14,btnH); local aiH = mouseIn(x+46,y,14,btnH)
    sc(adH and C.accentHi or C.textDim); drawText(x+30,y,14,btnH,"-",5)
    sc(aiH and C.accentHi or C.textDim); drawText(x+46,y,14,btnH,"+",5)
    if mouseJustClicked() then
      if adH and arpMs>10 then setArpDelay(arpMs-5) end
      if aiH and arpMs<120 then setArpDelay(arpMs+5) end
    end; x=x+62
    local rrOn = getArpRR(); local rrH = mouseIn(x,y,32,btnH)
    sc(rrOn and {0.65,0.45,0.85} or C.btnNorm); drawRR(x,y,32,btnH,3,true)
    sc({1,1,1}); gfx.setfont(1,"Arial",fs(8),string.byte('b'))
    drawText(x,y,32,btnH,"RR",5)
    if mouseJustClicked() and rrH then setArpRR(not rrOn) end; x=x+38
  end

  -- Trail toggle (ALWAYS visible regardless of arp state)
  local trailOn = getTrailOn(); local trailHov = mouseIn(x,y,64,btnH)
  sc(trailOn and {0.85,0.65,0.20} or C.btnNorm); drawRR(x,y,64,btnH,3,true)
  sc({1,1,1}); gfx.setfont(1,"Arial",fs(9),string.byte('b'))
  drawText(x,y,64,btnH,trailOn and "TRAIL ON" or "TRAIL OFF",5)
  if mouseJustClicked() and trailHov then
    setTrailOn(not trailOn); if not getTrailOn() then GUI.trail = {} end
  end; x=x+70

  -- Text size: - [size] +
  local tsz = getTextSize()
  local tsDecH = mouseIn(x,y,16,btnH); local tsIncH = mouseIn(x+50,y,16,btnH)
  sc(C.btnNorm); drawRR(x,y,66,btnH,3,true)
  sc(tsDecH and C.accentHi or C.textDim); drawText(x,y,16,btnH,"-",5)
  sc(tsIncH and C.accentHi or C.textDim); drawText(x+50,y,16,btnH,"+",5)
  sc(C.text); gfx.setfont(1,"Arial",fs(9),string.byte('b'))
  drawText(x,y,66,btnH,TEXT_LABELS[tsz+1],5)
  if mouseJustClicked() then
    if tsDecH and tsz > 0 then setTextSize(tsz-1) end
    if tsIncH and tsz < 3 then setTextSize(tsz+1) end
  end

  -- MIDI Editor status
  local hasEditor = activeTake() ~= nil
  sc(hasEditor and C.green or C.red); gfx.setfont(1,"Arial",fs(9))
  drawText(gfx.w-128,y+4,120,14,hasEditor and "MIDI Editor: Open" or "MIDI Editor: Closed",1)

  -- ROW 2: Per-degree chord assignments with octave/inversion
  local y2 = y + btnH + 6
  local scaleNotes = getScaleNotes(getScaleRoot(), getScaleType())
  local degH = DEGREE_HEADERS[getScaleType()] or DEGREE_HEADERS[1]
  local availW = gfx.w - 2*pad
  local degW = math.floor((availW - 6*4) / 7)
  local degGap = 4

  for deg = 1, 7 do
    local dx = pad + (deg-1) * (degW + degGap)
    local slotH = 52
    degreeSlots[deg] = {x=dx, y=y2, w=degW, h=slotH}

    -- Check if drag is being released over this slot
    if GUI.dragging and mouseJustReleased() and mouseIn(dx,y2,degW,slotH) then
      setDegreeChord(deg, GUI.dragChordIdx)
      GUI.dragging = false
    end

    -- Highlight if drag is hovering over
    if GUI.dragging and mouseIn(dx,y2,degW,slotH) then
      sc({0.40,0.65,1.0,0.3}); gfx.rect(dx,y2,degW,slotH,true)
    end

    sc(C.headerRow); drawRR(dx,y2,degW,slotH,3,true)

    -- Degree number + roman numeral
    gfx.setfont(1,"Arial",fs(12),string.byte('b')); sc(C.accent)
    drawText(dx,y2,degW,14,degH[deg].." ("..NOTE_NAMES[scaleNotes[deg]+1]..")",5)

    -- Chord type dropdown
    local dcurIdx = getDegreeChord(deg)
    local dcur = ALL_CHORDS[dcurIdx]
    local ddY = y2 + 14
    local ddHov = mouseIn(dx+2,ddY,degW-4,14)
    sc(ddHov and C.btnHover or C.panelBg); gfx.rect(dx+2,ddY,degW-4,14,true)
    sc(ddHov and C.accentHi or C.text)
    gfx.setfont(1,"Arial",fs(10))
    local ddLabel = "["..deg.."] "..(dcur.display ~= "" and dcur.display or "maj").." v"
    drawText(dx+2,ddY,degW-4,14,ddLabel,5)
    if mouseJustClicked() and ddHov then
      local opts = {}
      for i,c in ipairs(ALL_CHORDS) do opts[i]=c.name.." ("..(c.display~="" and c.display or "maj")..")" end
      local choice = showDropdown(dx, ddY+14, opts, dcurIdx)
      if choice > 0 then setDegreeChord(deg, choice) end
    end

    -- Per-degree octave offset
    local oY = ddY + 16
    local doct = getDegreeOct(deg)
    sc(C.textDim); gfx.setfont(1,"Arial",fs(8))
    drawText(dx,oY,degW/2,12,"oct:"..((doct>=0 and "+" or "")..doct),5)
    local odH = mouseIn(dx,oY,degW/4,12); local oiH = mouseIn(dx+degW/4,oY,degW/4,12)
    if mouseJustClicked() and odH and doct>-3 then setDegreeOct(deg,doct-1) end
    if mouseJustClicked() and oiH and doct<3 then setDegreeOct(deg,doct+1) end
    sc(odH and C.accentHi or C.textDim); drawText(dx,oY,12,12,"-",5)
    sc(oiH and C.accentHi or C.textDim); drawText(dx+degW/4,oY,12,12,"+",5)

    -- Per-degree inversion offset
    local dinv = getDegreeInv(deg)
    sc(C.textDim)
    drawText(dx+degW/2,oY,degW/2,12,"inv:"..((dinv>=0 and "+" or "")..dinv),5)
    local idH = mouseIn(dx+degW/2,oY,degW/4,12); local iiH = mouseIn(dx+3*degW/4,oY,degW/4,12)
    if mouseJustClicked() and idH and dinv>-4 then setDegreeInv(deg,dinv-1) end
    if mouseJustClicked() and iiH and dinv<4 then setDegreeInv(deg,dinv+1) end
    sc(idH and C.accentHi or C.textDim); drawText(dx+degW/2,oY,12,12,"-",5)
    sc(iiH and C.accentHi or C.textDim); drawText(dx+3*degW/4,oY,12,12,"+",5)
  end

  -- Scale notes display
  local y3 = y2 + 56
  local snNames = {}; for i,n in ipairs(scaleNotes) do snNames[i]=NOTE_NAMES[n+1] end
  sc(C.textDim); gfx.setfont(1,"Arial",fs(10))
  drawText(pad,y3,400,14,"Scale notes: "..table.concat(snNames,"  "),0)

  return y3 + 18
end

-- ============================================================================
-- DRAW: CHORD GRID
-- ============================================================================

local GRID = { labelW=82, cellH=26, headerH=20, gap=2 }

local function drawChordGrid(gridStartY)
  local pad = 10
  local rootIdx = getScaleRoot(); local scaleIdx = getScaleType()
  local scaleNotes = getScaleNotes(rootIdx, scaleIdx)
  local degHeaders = DEGREE_HEADERS[scaleIdx] or DEGREE_HEADERS[1]

  local availW = gfx.w - 2*pad - GRID.labelW
  local colW = math.floor((availW - 6*GRID.gap) / 7)
  local gridX = pad; local gridY = gridStartY
  local gridH = gfx.h - gridY - 130  -- leave room for bottom panel + piano

  -- Column headers
  local headerY = gridY; local colHeaderH = 24
  sc(C.headerRow); gfx.rect(gridX,headerY,GRID.labelW,colHeaderH,true)
  sc(C.textDim); gfx.setfont(1,"Arial",fs(9)); drawText(gridX,headerY,GRID.labelW,colHeaderH,"Type",5)

  for deg=1,7 do
    local cx = gridX + GRID.labelW + (deg-1)*(colW+GRID.gap)
    sc(C.headerRow); gfx.rect(cx,headerY,colW,colHeaderH,true)
    sc(C.accent); gfx.setfont(1,"Arial",fs(12),string.byte('b'))
    drawText(cx,headerY,colW,colHeaderH,degHeaders[deg].." ("..NOTE_NAMES[scaleNotes[deg]+1]..")",5)
  end

  local scrollableY = headerY + colHeaderH + 2
  local scrollableH = gridH - colHeaderH - 2

  -- Mouse wheel scroll
  local wheel = gfx.mouse_wheel
  if wheel ~= 0 and mouseIn(gridX,scrollableY,gfx.w-2*pad,scrollableH) then
    GUI.scrollY = GUI.scrollY - math.floor(wheel / 8)
    gfx.mouse_wheel = 0
  end

  -- Total content height
  local totalH = 0
  for _, row in ipairs(GRID_ROWS) do
    totalH = totalH + (row.type=="header" and GRID.headerH or GRID.cellH) + GRID.gap
  end
  GUI.maxScroll = math.max(0, totalH - scrollableH)
  GUI.scrollY = math.max(0, math.min(GUI.scrollY, GUI.maxScroll))

  local diatonicIdx = {}
  for deg=1,7 do diatonicIdx[deg] = getDiatonicChordIdx(rootIdx,scaleIdx,deg) end

  local drawY = scrollableY - GUI.scrollY
  GUI.hoveredRow = -1; GUI.hoveredDeg = -1

  for ri, row in ipairs(GRID_ROWS) do
    local rowH = row.type=="header" and GRID.headerH or GRID.cellH
    if drawY + rowH > scrollableY and drawY < scrollableY + scrollableH then
      if row.type == "header" then
        sc(C.headerRow)
        gfx.rect(gridX,math.max(drawY,scrollableY),GRID.labelW+7*(colW+GRID.gap),
          math.min(rowH,scrollableY+scrollableH-drawY),true)
        if drawY >= scrollableY then
          sc(C.catText); gfx.setfont(1,"Arial",fs(10),string.byte('b'))
          drawText(gridX+6,drawY,300,rowH,row.name,0)
        end
      else
        local chordDef = row.chord; local chordIdx = row.chordIdx
        sc(C.panelBg); gfx.rect(gridX,drawY,GRID.labelW,rowH,true)
        sc(C.textDim); gfx.setfont(1,"Arial",fs(9))
        drawText(gridX+4,drawY,GRID.labelW-8,rowH,chordDef.display~="" and chordDef.display or chordDef.name,5)

        for deg=1,7 do
          local cx = gridX+GRID.labelW+(deg-1)*(colW+GRID.gap)
          local cellVis = drawY>=scrollableY and drawY+rowH<=scrollableY+scrollableH
          if cellVis then
            local isHov = mouseIn(cx,drawY,colW,rowH)
            local isDia = (chordIdx == diatonicIdx[deg])
            sc(isDia and C.gridDia or (isHov and C.gridHover or C.gridCell))
            gfx.rect(cx,drawY,colW,rowH,true)

            -- Suggestion overlay
            if suggestionCache[ri] and suggestionCache[ri][deg] then
              local sugCol = getSuggestionColor(suggestionCache[ri][deg])
              if sugCol then gfx.set(sugCol[1],sugCol[2],sugCol[3],sugCol[4]); gfx.rect(cx,drawY,colW,rowH,true) end
            end

            -- Hover outline
            if isHov then sc(C.accent); gfx.rect(cx,drawY,colW,rowH,false); GUI.hoveredRow=ri; GUI.hoveredDeg=deg end

            -- Current chord gold
            if ri==GUI.currentRow and deg==GUI.currentDeg then
              gfx.set(1.0,0.78,0.20,0.55); gfx.rect(cx,drawY,colW,rowH,true)
              gfx.set(1.0,0.85,0.30,1); gfx.rect(cx,drawY,colW,rowH,false)
              gfx.rect(cx+1,drawY+1,colW-2,rowH-2,false)
            else
              -- Trail
              if getTrailOn() then
                for ti,t in ipairs(GUI.trail) do
                  if ti>1 and t.row==ri and t.deg==deg then
                    local fade = 1.0-(ti-1)/GUI.maxTrail
                    gfx.set(1.0,0.82,0.25,fade*0.8)
                    gfx.rect(cx,drawY,colW,rowH,false); gfx.rect(cx+1,drawY+1,colW-2,rowH-2,false)
                    break
                  end
                end
              end
            end

            -- Label
            local rootName = NOTE_NAMES[scaleNotes[deg]+1]
            gfx.setfont(1,"Arial",fs(11))
            sc(isDia and {1,1,1} or C.text)
            drawText(cx,drawY,colW,rowH,rootName..chordDef.display,5)

            -- Click: play
            if mouseJustClicked() and isHov then
              GUI.lastChordText, GUI.lastChordNotes = playChord(deg, chordIdx)
            end

            -- Start drag on mousedown (hold for 0.15s threshold handled by checking movement)
            if mouseDown() and isHov and not GUI.dragging and (GUI.lastMouseCap & 1 == 0) then
              GUI.dragStartX = gfx.mouse_x; GUI.dragStartY = gfx.mouse_y
              GUI.dragChordIdx = chordIdx
              GUI.dragLabel = rootName..chordDef.display
            end
          end
        end
      end
    end
    drawY = drawY + rowH + GRID.gap
  end

  -- Detect drag start (moved > 8px from click origin)
  if mouseDown() and not GUI.dragging and GUI.dragChordIdx > 0 then
    local dx = math.abs(gfx.mouse_x - GUI.dragStartX)
    local dy = math.abs(gfx.mouse_y - GUI.dragStartY)
    if dx + dy > 8 then GUI.dragging = true end
  end

  -- Draw drag indicator
  if GUI.dragging and mouseDown() then
    gfx.set(1.0,0.85,0.30,0.85)
    drawRR(gfx.mouse_x-30,gfx.mouse_y-12,60,24,4,true)
    sc({0,0,0}); gfx.setfont(1,"Arial",fs(11),string.byte('b'))
    drawText(gfx.mouse_x-30,gfx.mouse_y-12,60,24,GUI.dragLabel,5)
  end

  -- Cancel drag on release if not over a slot
  if mouseJustReleased() then GUI.dragging = false; GUI.dragChordIdx = -1 end

  -- Scrollbar
  if GUI.maxScroll > 0 then
    local sbX = gfx.w-pad-6
    local thumbH = math.max(20,scrollableH*(scrollableH/totalH))
    local thumbY = scrollableY+(GUI.scrollY/GUI.maxScroll)*(scrollableH-thumbH)
    sc({0.25,0.25,0.32}); gfx.rect(sbX,scrollableY,6,scrollableH,true)
    sc({0.45,0.45,0.55}); drawRR(sbX,thumbY,6,thumbH,3,true)
  end

  return scrollableY + scrollableH
end

-- ============================================================================
-- DRAW: BOTTOM PANEL (chord tones + chord finder piano)
-- ============================================================================

local function drawBottomPanel(panelY)
  local pad = 10; local y = panelY + 6
  sc(C.sep); gfx.line(pad,panelY,gfx.w-pad,panelY)

  -- Current chord name
  gfx.setfont(1,"Arial",fs(20),string.byte('b')); sc(C.accent)
  drawText(pad,y+2,160,28,GUI.lastChordText,0)

  -- Chord tone buttons (left side)
  local toneEndX = pad + 160
  if GUI.lastChordNotes and #GUI.lastChordNotes > 0 then
    local noteX = pad + 160; local noteBtnW = 44; local noteBtnH = 24
    local vel = getVelocity()
    gfx.setfont(1,"Arial",fs(8)); sc(C.textDim)
    drawText(noteX,y-2,100,12,"Chord tones:",0)
    local btnX = noteX; local btnY = y + 10
    for i,note in ipairs(GUI.lastChordNotes) do
      if note>=0 and note<=127 then
        local nName = NOTE_NAMES[(note%12)+1]..math.floor(note/12)-1
        local hover = mouseIn(btnX,btnY,noteBtnW,noteBtnH)
        sc(hover and C.btnHover or C.btnNorm); drawRR(btnX,btnY,noteBtnW,noteBtnH,3,true)
        gfx.setfont(1,"Arial",fs(10)); sc(hover and C.accentHi or C.text)
        drawText(btnX,btnY,noteBtnW,noteBtnH,nName,5)
        if mouseJustClicked() and hover then
          stopAllNotes(); reaper.StuffMIDIMessage(0,0x90,note,vel)
          notesThatArePlaying[#notesThatArePlaying+1] = note
          if getInsertMode() and activeTake() then
            local take = activeTake(); local cursorPos = reaper.GetCursorPosition()
            local sPPQ = reaper.MIDI_GetPPQPosFromProjTime(take,cursorPos)
            local gQN = reaper.MIDI_GetGrid(take)
            local cQN = reaper.MIDI_GetProjQNFromPPQPos(take,sPPQ)
            local ePPQ = reaper.MIDI_GetPPQPosFromProjQN(take,cQN+gQN)
            reaper.Undo_BeginBlock()
            reaper.MIDI_InsertNote(take,false,false,sPPQ,ePPQ,0,note,vel,false)
            reaper.MIDI_Sort(take)
            reaper.SetEditCurPos(reaper.MIDI_GetProjTimeFromPPQPos(take,ePPQ),true,false)
            reaper.Undo_EndBlock("AdvChordGun: Insert note",-1); reaper.UpdateArrange()
          end
        end
        btnX = btnX + noteBtnW + 3
        toneEndX = btnX
      end
    end
  end

  -- CHORD FINDER: 3-octave piano to the right of chord tones
  local pianoX = math.max(toneEndX + 10, pad + 420)
  local pianoTopY = y - 2

  gfx.setfont(1,"Arial",fs(12),string.byte('b')); sc(C.text)
  drawText(pianoX,pianoTopY-16,160,14,"Chord Finder",0)

  local numOctaves = 3
  local numWhiteKeys = numOctaves * 7
  local pianoAvailW = gfx.w - pianoX - pad - 10
  local whiteW = math.max(12, math.floor(pianoAvailW / numWhiteKeys))
  local whiteH = 58
  local blackW = math.max(8, math.floor(whiteW * 0.65))
  local blackH = 36

  local whitePattern = {0,2,4,5,7,9,11}
  local isBlackNote = {[1]=true,[3]=true,[6]=true,[8]=true,[10]=true}

  local activeKeys = {}
  for _,kid in ipairs(GUI.pianoNotes) do activeKeys[kid] = true end

  -- Draw white keys
  local wX = pianoX
  local whiteKeyIDs = {}

  for octOff = 0, numOctaves-1 do
    for wi, pc in ipairs(whitePattern) do
      local kid = octOff * 12 + pc
      local isActive = activeKeys[kid]
      local hover = mouseIn(wX, pianoTopY, whiteW-1, whiteH)
      sc(isActive and C.pianoActive or (hover and {0.80,0.80,0.85} or C.pianoWhite))
      gfx.rect(wX, pianoTopY, whiteW-1, whiteH, true)
      sc({0.35,0.35,0.38}); gfx.rect(wX, pianoTopY, whiteW-1, whiteH, false)
      if octOff == 0 then
        gfx.setfont(1,"Arial",fs(7)); sc(isActive and {1,1,1} or {0.45,0.45,0.5})
        drawText(wX,pianoTopY+whiteH-11,whiteW-1,10,NOTE_NAMES[pc+1],5)
      end
      whiteKeyIDs[#whiteKeyIDs+1] = {x=wX, kid=kid}
      wX = wX + whiteW
    end
  end

  -- Draw black keys on top
  local blackClicked = false
  wX = pianoX
  for octOff = 0, numOctaves-1 do
    for wi, pc in ipairs(whitePattern) do
      if wi < 7 then
        local bPC = pc + 1
        if isBlackNote[bPC] then
          local kid = octOff * 12 + bPC
          local bx = wX + whiteW - math.floor(blackW/2)
          local isActive = activeKeys[kid]
          local hover = mouseIn(bx, pianoTopY, blackW, blackH)
          sc(isActive and C.pianoActive or (hover and {0.30,0.30,0.38} or C.pianoBlack))
          gfx.rect(bx, pianoTopY, blackW, blackH, true)
          sc({0.08,0.08,0.10}); gfx.rect(bx, pianoTopY, blackW, blackH, false)
          if mouseJustClicked() and hover then
            blackClicked = true
            if isActive then
              local new = {}; for _,k in ipairs(GUI.pianoNotes) do if k~=kid then new[#new+1]=k end end
              GUI.pianoNotes = new
            else
              GUI.pianoNotes[#GUI.pianoNotes+1] = kid
            end
            local pcs = {}; local seen = {}
            for _,k in ipairs(GUI.pianoNotes) do
              local p = k % 12; if not seen[p] then seen[p]=true; pcs[#pcs+1]=p end
            end
            GUI.finderResult = identifyChord(pcs)
          end
        end
      end
      wX = wX + whiteW
    end
  end

  -- White key clicks (only if no black key was clicked)
  if not blackClicked then
    for _, wk in ipairs(whiteKeyIDs) do
      local hover = mouseIn(wk.x, pianoTopY, whiteW-1, whiteH)
      if mouseJustClicked() and hover then
        local kid = wk.kid
        if activeKeys[kid] then
          local new = {}; for _,k in ipairs(GUI.pianoNotes) do if k~=kid then new[#new+1]=k end end
          GUI.pianoNotes = new
        else
          GUI.pianoNotes[#GUI.pianoNotes+1] = kid
        end
        local pcs = {}; local seen = {}
        for _,k in ipairs(GUI.pianoNotes) do
          local p = k % 12; if not seen[p] then seen[p]=true; pcs[#pcs+1]=p end
        end
        GUI.finderResult = identifyChord(pcs)
        break
      end
    end
  end

  -- Result and Clear button below piano
  local resultY = pianoTopY + whiteH + 4
  
  -- Clear button
  local clrBtnW = 50; local clrBtnH = 20
  local clrBtnX = pianoX
  local clrHov = mouseIn(clrBtnX, resultY, clrBtnW, clrBtnH)
  sc(clrHov and {0.65,0.25,0.25} or C.btnNorm); drawRR(clrBtnX,resultY,clrBtnW,clrBtnH,3,true)
  sc(clrHov and {1,1,1} or C.textDim); gfx.setfont(1,"Arial",fs(9),string.byte('b'))
  drawText(clrBtnX,resultY,clrBtnW,clrBtnH,"Clear",5)
  if mouseJustClicked() and clrHov then GUI.pianoNotes = {}; GUI.finderResult = "" end
  
  -- Chord name result
  gfx.setfont(1,"Arial",fs(12),string.byte('b')); sc(C.accent)
  drawText(pianoX + clrBtnW + 8, resultY, pianoAvailW - clrBtnW - 8, 16, GUI.finderResult, 0)

  if #GUI.pianoNotes > 0 then
    local selNames = {}
    for _, kid in ipairs(GUI.pianoNotes) do selNames[#selNames+1] = NOTE_NAMES[(kid%12)+1] end
    sc(C.textDim); gfx.setfont(1,"Arial",fs(8))
    drawText(pianoX + clrBtnW + 8, resultY+16, pianoAvailW, 12, "Notes: "..table.concat(selNames," "), 0)
  end

  -- Help
  gfx.setfont(1,"Arial",fs(8)); sc(C.textDim)
  drawText(pad,gfx.h-14,gfx.w-2*pad,12,
    "Keys 1-7: play degree chord | 0: stop | A: toggle arp | Drag grid cell to degree slot to assign | Esc: close",0)
end

-- ============================================================================
-- KEYBOARD
-- ============================================================================

local function handleKeyboard()
  local ch = gfx.getchar()
  if ch == -1 then return false end
  if ch >= string.byte('1') and ch <= string.byte('7') then
    local deg = ch - string.byte('0')
    GUI.lastChordText, GUI.lastChordNotes = playChord(deg, getDegreeChord(deg))
  end
  if ch == string.byte('0') then
    stopAllNotes(); GUI.lastChordText=""; GUI.lastChordNotes={}
    lastPlayedRoot=nil; lastPlayedPCs=nil; suggestionCache={}
    GUI.currentRow=-1; GUI.currentDeg=-1; GUI.trail={}
  end
  if ch == string.byte('a') or ch == string.byte('A') then setArpMode(not getArpMode()) end
  if ch == 30064 then GUI.scrollY = math.max(0, GUI.scrollY-30) end
  if ch == 1685026670 then GUI.scrollY = math.min(GUI.maxScroll, GUI.scrollY+30) end
  if ch == 27 then stopAllNotes(); return false end
  return true
end

-- ============================================================================
-- MAIN
-- ============================================================================

local function init()
  local w = getWinW(); local h = getWinH()
  local x = getWinX(); local y = getWinY()
  gfx.init("Advanced ChordGun", w, h, 0, x, y)
  gfx.setfont(1, "Arial", 14)
end

local lastSavedW, lastSavedH = 0, 0
local lastSavedX, lastSavedY = -99, -99

local function mainLoop()
  if not handleKeyboard() then gfx.quit(); return end
  updateArpeggio()

  -- Save window size and position if changed
  if gfx.w ~= lastSavedW or gfx.h ~= lastSavedH then
    setWinW(gfx.w); setWinH(gfx.h)
    lastSavedW = gfx.w; lastSavedH = gfx.h
  end
  local wx, wy = gfx.clienttoscreen(0, 0)
  if wx ~= lastSavedX or wy ~= lastSavedY then
    setWinX(wx); setWinY(wy)
    lastSavedX = wx; lastSavedY = wy
  end

  sc(C.bg); gfx.rect(0,0,gfx.w,gfx.h,true)
  local gridStartY = drawTopControls()
  local gridBottomY = drawChordGrid(gridStartY)
  drawBottomPanel(gridBottomY)
  GUI.lastMouseCap = gfx.mouse_cap
  gfx.update()
  reaper.defer(mainLoop)
end

init()
mainLoop()
