if not myHero then
  myHero = GetmyHero()
end
if myHero.charName ~= "Quinn" then return end

local ScriptVersion = 0.1
local target = nil
local DespairStatus = false
local jungleMinions = minionManager(MINION_JUNGLE, 350, myHero)
local enemyMinions = minionManager(MINION_ENEMY, 350, myHero)


-- [Shared Function] --

function print_msg(msg)
  if msg ~= nil then
    msg = tostring(msg)
    print("<font color=\"#79E886\"><b>[Quinn Combo]</b></font> <font color=\"#FFFFFF\">".. msg .."</font>")
  end
end

function LoadSimpleLib()
  if FileExist(LIB_PATH .. "/SimpleLib.lua") then
    require("SimpleLib")
    return true
  else
    print_msg("Downloading SimpleLib, please don't press F9")
    DelayAction(function() DownloadFile("https://raw.githubusercontent.com/jachicao/BoL/master/SimpleLib.lua".."?rand="..math.random(1,10000), LIB_PATH.."SimpleLib.lua", function () print_msg("Successfully downloaded SimpleLib. Press F9 twice.") end) end, 3) 
    return false
  end
end

function LoadSLK()
  if FileExist(LIB_PATH .. "/SourceLibk.lua") then
    require("SourceLibk")
    return true
  else
    print_msg("Downloading SourceLibk, please don't press F9")
    DelayAction(function() DownloadFile("https://raw.githubusercontent.com/kej1191/anonym/master/Common/SourceLibk.lua".."?rand="..math.random(1,10000), LIB_PATH.."SourceLibk.lua", function () print_msg("Successfully downloaded SourceLibk. Press F9 twice.") end) end, 3) 
    return false
  end
end


-- [Script Function] --

-- OnLoad works Update and Download SLK.
function OnLoad()
  
  -- Check SLK.
  if LoadSLK() then
  
    -- Check SimpleLib
    if LoadSimpleLib() then
    
      -- Start Update with SimpleLib.
      local UpdateInfo = {}
      UpdateInfo.LocalVersion = ScriptVersion
      UpdateInfo.VersionPath = "raw.githubusercontent.com/fofofoke/pvscript/master/QuinnCombo.version"
      UpdateInfo.ScriptPath =  "raw.githubusercontent.com/fofofoke/pvscript/master/QuinnCombo.lua"
      UpdateInfo.SavePath = SCRIPT_PATH .. GetCurrentEnv().FILE_NAME
      UpdateInfo.CallbackUpdate = function(NewVersion, OldVersion) print_msg("Updated to ".. NewVersion ..". Press F9x2!") end
      UpdateInfo.CallbackNoUpdate = LoadScript()
      UpdateInfo.CallbackNewVersion = function(NewVersion) print_msg("New version found. Don't press F9.") end
      UpdateInfo.CallbackError = function(NewVersion) print_msg("Error to download new version. Please try again.") end
      _ScriptUpdate(UpdateInfo)
    end
  end
end

function LoadScript()
  -- Load script with class.
  QC = QuinnCombo()
  _G.QuinnComboLoaded = true
  DelayAction(function() print_msg("Lastset version (".. ScriptVersion ..") loaded!") end, 2)
end

-- [Main Class] --

class "QuinnCombo"

function QuinnCombo:__init()
  self:Config()
end

-- Config, menu and etc.
function QuinnCombo:Config()

  -- Set Spell with SimpleLib
  self.Spell_Q = _Spell({Slot = _Q, DamageName = "Q", Range = 1025, Width = 80, Delay = 0.125, Speed = 2000, Collision = true, Aoe = true, Type = SPELL_TYPE.LINEAR})
  self.Spell_Q:SetAccuracy(70)
  self.Spell_Q:AddDraw({Enable = true, Color = {255,0,125,255}})
  
--  self.Spell_W = _Spell({Slot = _W, DamageName = "W", Range = 300, Delay = 0, Aoe = true, Type = SPELL_TYPE.SELF})
--  self.Spell_W:AddDraw({Enable = false, Color = {255,255,140,0}})
  
  self.Spell_E = _Spell({Slot = _E, DamageName = "E", Range = 700, Delay = 0.125, Aoe = false, Type = SPELL_TYPE.TARGETTED})
  self.Spell_E:AddDraw({Enable = true, Color = {255,170,0,255}})
  
--  self.Spell_R = _Spell({Slot = _R, DamageName = "R", Range = 550, Delay = 0.25, Aoe = true, Type = SPELL_TYPE.SELF})
--  self.Spell_R:AddDraw({Enable = true, Color = {255,255,0,0}})
  
  -- Make Menu.
  self.cfg = scriptConfig("Quinn Combo", "quinn_combo")
  
  -- Target Selector with SLK.
  self.STS = SimpleTS(STS_PRIORITY_LESS_CAST_PHYSICAL)
  self.cfg:addSubMenu("Target Selector", "ts")
  self.STS:AddToMenu(self.cfg.ts)
  
  -- Combo Menu
  self.cfg:addSubMenu("Combo Setting", "combo")
--      self.cfg.combo:addParam("autow", "Use Auto W", SCRIPT_PARAM_ONOFF, true)
--      self.cfg.combo:addParam("autowmana", "Auto W Mana", SCRIPT_PARAM_SLICE, 0,0,100)
--      self.cfg.combo:addParam("info1", "", SCRIPT_PARAM_INFO, "")
--      self.cfg.combo:addParam("autoe", "Use Auto E", SCRIPT_PARAM_ONOFF, true)
--      self.cfg.combo:addParam("autoemana", "Auto E Mana", SCRIPT_PARAM_SLICE, 20,0,100)
--      self.cfg.combo:addParam("info2", "", SCRIPT_PARAM_INFO, "")
--      self.cfg.combo:addParam("autor", "Use Auto R", SCRIPT_PARAM_ONOFF, true)
--      self.cfg.combo:addParam("autornum", "Auto R Chmps", SCRIPT_PARAM_SLICE, 3,1,5)
  
  -- Harass
  self.cfg:addSubMenu("Harass Setting", "harass")
      self.cfg.harass:addParam("autoq", "Use Q", SCRIPT_PARAM_ONOFF, true)
      self.cfg.harass:addParam("info1", "", SCRIPT_PARAM_INFO, "")
--      self.cfg.harass:addParam("autow", "Use Auto W", SCRIPT_PARAM_ONOFF, false)
--      self.cfg.harass:addParam("autowmana", "Auto W Mana", SCRIPT_PARAM_SLICE, 20,0,100)
--      self.cfg.harass:addParam("info2", "", SCRIPT_PARAM_INFO, "")
      self.cfg.harass:addParam("autoe", "Use E", SCRIPT_PARAM_ONOFF, false)
--      self.cfg.harass:addParam("autoemana", "Auto E Mana", SCRIPT_PARAM_SLICE, 30,0,100)
      
  -- Lane Clear
  self.cfg:addSubMenu("Clear Setting", "clear")
      
  -- Jungle Clear
  
  -- Spell Menu with SimpleLib.
  --self.cfg:addSubMenu("Spell Setting", "spell")
  
  -- Draw Menu
  self.cfg:addSubMenu("Draw Setting", "draw")
      
  -- Key Menu with SimpleLib
  self.cfg:addSubMenu("Key Setting", "key")
      OrbwalkManager:LoadCommonKeys(self.cfg.key)
  
  -- Etc
  self.cfg:addSubMenu("Misc Setting", "misc")
--      self.cfg.misc:addParam("autodisablew", "Auto disable W", SCRIPT_PARAM_ONOFF, true)
--      self.cfg:addParam("info1", "Auto disable W can have bug", SCRIPT_PARAM_INFO, "")
--      self.cfg:addParam("info2", "when you reload or reconnect during game.", SCRIPT_PARAM_INFO, "")
--      self.cfg:addParam("info3", "", SCRIPT_PARAM_INFO, "")
--      self.cfg.misc:addParam("debug", "Debug Mode", SCRIPT_PARAM_ONOFF, false)
    
  -- Info
  self.cfg:addParam("info1", "", SCRIPT_PARAM_INFO, "")
  self.cfg:addParam("info2", "Script by fofofoke", SCRIPT_PARAM_INFO, "")
  
  -- Set CallBack.
  AddDrawCallback(function() self:Draw() end)
  AddTickCallback(function() self:Tick() end)
  AddCastSpellCallback(function(slot) self:OnCastSpell(slot) end)
  AddDeleteObjCallback(function(obj) self:OnDeleteObj(obj) end)
end

function QuinnCombo:Draw()
  
  -- If dead, disable everything.
  if myHero.dead then
    return
  end

  -- Draw Other
  --if self.cfg.draw.drawtarget then
  
  --end
  
  -- Debug
  if self.cfg.misc.debug then
--    DrawText("W: "..tostring(DespairStatus), 20, 80, 100, ARGB(255,255,255,255))
--    DrawText("All Enemy W: "..tostring(self:GetAllEnemyW()), 20, 80, 130, ARGB(255,255,255,255))
--    DrawText("Enemy W: "..tostring(self:GetEnemyW()), 20, 80, 160, ARGB(255,255,255,255))
--    DrawText("Enemy R: "..tostring(self:GetEnemyR()), 20, 80, 190, ARGB(255,255,255,255))
    DrawText("Combo Mode: "..tostring(OrbwalkManager:IsCombo()), 20, 80, 220, ARGB(255,255,255,255))
  end
end

function QuinnCombo:Tick()
  
  -- If dead, disable everything.
  if myHero.dead then
    return
  end
  
  -- Update
  target = self.STS:GetTarget(1400)
  
  -- Auto Disable W
--  if self.cfg.misc.autodisablew then
--    self:AutoDisableW()
--  end
  
  -- Combo Logic
  if OrbwalkManager:IsCombo() then
    self:Combo()
  end
  
  -- Harass
  if OrbwalkManager:IsHarass() then
    self:Harass()
  end
  
  -- Clear
  if OrbwalkManager:IsClear() then
    self:Clear()
  end
  
  -- LastHit
  if OrbwalkManager:IsLastHit() then
    self:LastHit()
  end
  
end

function QuinnCombo:OnCastSpell(slot)
--  if slot == _W then
--    DespairStatus = true
--  end
end

function QuinnCombo:OnDeleteObj(obj)
--  if obj.name == "Despair_buf.troy" then
--    DespairStatus = false
--  end
end

function QuinnCombo:Combo()
  
  -- Cast Q for target
  if TargetHaveBuff("buffname") or myhero:CanUseSpell(_E) == ready then
   end
  else
  self.Spell_Q:Cast(target)
  
  -- Auto W
--  if self.cfg.combo.autow then
--    if self:GetEnemyW() ~= 0 and (myHero.mana / myHero.maxMana > self.cfg.combo.autowmana / 100) then
--      self:EnableW()
--    else
--      self:DisableW()
--    end
--  end
  
  -- Cast E for target
  if TargetHaveBuff("buffname") then
    end
  else
  self.Spell_E:Cast(target)
end

  -- Auto R
--  if self.cfg.combo.autor and self.Spell_R:IsReady() and myHero.mana >= self.Spell_R:Mana() then
  
    -- If enemy is many, cast on mousepos.
--    if self:GetEnemyR() >= self.cfg.combo.autornum then
--      CastSpell(_R, mousePos.x, mousePos.y)
--    end
--  end
end

function QuinnCombo:Harass()
  
  -- Cast Q for target
  if self.cfg.harass.autoq then
    self.Spell_Q:Cast(target)
  end
  
  -- Auto W
--  if self.cfg.harass.autow then
--    if self:GetEnemyW() ~= 0 and (myHero.mana / myHero.maxMana > self.cfg.harass.autowmana / 100) then
--      self:EnableW()
--    else
--      self:DisableW()
--    end
--  end
  
  -- Auto E
--  if self.cfg.harass.autoe and self.Spell_E:ValidTarget(target) and (myHero.mana / myHero.maxMana > self.cfg.harass.autoemana / 100) then
--    self.Spell_E:Cast(target)
--  end
end

function QuinnCombo:Clear()
  
end

function QuinnCombo:LastHit()

end

--function QuinnCombo:AutoDisableW()
--  if DespairStatus and not self:GetAllEnemyW() and self.Spell_W:IsReady() then
--    CastSpell(_W, mousePos.x, mousePos.y)
--  end
--end

--function QuinnCombo:EnableW()
--  if not DespairStatus and self.Spell_W:IsReady() then
--    CastSpell(_W, mousePos.x, mousePos.y)
--  end
--end

--function QuinnCombo:DisableW()
--  if DespairStatus and self.Spell_W:IsReady() then
--    CastSpell(_W, mousePos.x, mousePos.y)
--  end
--end

--function QuinnCombo:GetAllEnemyW()
  
  -- Update minions.
--  jungleMinions:update()
--  enemyMinions:update()
  
--  if jungleMinions.iCount > 0 or enemyMinions.iCount > 0 or CountEnemyHeroInRange(350) > 0 then
--    return true
--  else
--    return false
--  end
--end

--function QuinnCombo:GetEnemyW()
  
  -- Return enemy in range.
--  return CountEnemyHeroInRange(350)
--end

--function QuinnCombo:GetEnemyR()
  
  -- Set enemy is 0.
--  local EnemyCount = 0
  
  -- Find every enemy in range
--  for index, value in ipairs(GetEnemyHeroes()) do
--    if self.Spell_R:ValidTarget(value) then EnemyCount = EnemyCount + 1 end
--  end
  
  -- Return total enemy count.
--  return EnemyCount
--end
