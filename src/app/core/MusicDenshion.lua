--local m_nSoundId
local audioEngine = SgAudioEngine
-- local audioEngine = ccexp.AudioEngine
-- ccexp.AudioEngine:play2d("background.mp3", AudioControlTest._loopEnabled, AudioControlTest._volume)
local defaultVolume = 0.6

ChangeMusic = {}
musicSchedulerID = nil
local changeBackMusicFunc = function(changeName,dt,time,maxVolume)
	local defaultVolume = maxVolume or defaultVolume
	print("  maxVolume ===== ",maxVolume,defaultVolume)
	if changeName and type(changeName) == "string" then
		if ChangeMusic.name and ChangeMusic.name == changeName then
			return
		end
		ChangeMusic.name = changeName
		-- print("   赋值~~~~~~~~~~~  ",ChangeMusic.name)
	end
	if musicSchedulerID then
		return
	end

	local dt,time = dt or 0.05,time or 1

	local _volume = 0
	local func2 = nil
	local func = function()
		if musicSchedulerID then
			scheduler.unscheduleGlobal(musicSchedulerID) 
			musicSchedulerID = nil
		end
		local tempName = ChangeMusic.name
		musicSchedulerID = scheduler.scheduleGlobal(function()
			if ChangeMusic.name == tempName then
				_volume = _volume + dt / time
			else
				_volume = _volume - dt / time
			end
			if _volume >= defaultVolume then
				_volume = defaultVolume
			elseif _volume <= 0 then
				_volume = 0
			end
			audioEngine:setMusicVolume(_volume)
			if _volume >= defaultVolume then
				if musicSchedulerID then
					scheduler.unscheduleGlobal(musicSchedulerID) 
					musicSchedulerID = nil
				end
			elseif _volume == 0 then
				if musicSchedulerID then
					scheduler.unscheduleGlobal(musicSchedulerID) 
					musicSchedulerID = nil
					audioEngine:stopMusic(true)
					-- print("   播放~~~~~~~~~~~  ",ChangeMusic.name)
					audioEngine:playMusic(ChangeMusic.name,true)
					audioEngine:setMusicVolume(0)
					func2()
				end
			end
		end,dt)
	end

	local volume = 1
	func2 = function()
		musicSchedulerID = scheduler.scheduleGlobal(function()
			volume = volume - dt / time
			if volume <= 0 then
				volume = 0
			end
			audioEngine:setMusicVolume(volume)
			if volume == 0 then
				if musicSchedulerID then
					scheduler.unscheduleGlobal(musicSchedulerID) 
					musicSchedulerID = nil
					audioEngine:stopMusic(true)
					--print("   播放~~~~~~~~~~~  ",ChangeMusic.name)
					audioEngine:playMusic(ChangeMusic.name,true)
					audioEngine:setMusicVolume(0)
					func()
				end
			end
		end,dt)
	end
	func2()

end

function playBackMusicFunc(backName,isChange,volume)
    if GameController.SET_UP_FUNC["Music"] ~= "1" then
		return
	end

	local backName = backName
	if audioEngine:isMusicPlaying() and isChange then
		if _MainScene then
			_MainScene.otherMusic = true
		end
	end
	sceneMusicName = "music/"..backName
	audioEngine:playMusic("music/"..backName,true)
end

function stopBackMusic(isclean)
	local _isclean = isclean or false
	audioEngine:stopMusic(_isclean)
	ChangeMusic = {}
	if musicSchedulerID then
		scheduler.unscheduleGlobal(musicSchedulerID) 
		musicSchedulerID = nil
	end
end

function pauseBackMusic()
	audioEngine:pauseMusic()
end

function resumeBackMusic()
	audioEngine:resumeMusic()
end

local effectList = {}

function playEffectFunc(EFFECT_FILE, isLoop)
    if GameController.SET_UP_FUNC["Sound"] ~= "1" then
    -- if GameController.SET_UP_FUNC["Music"] ~= "1" and TutoringStep and TutoringStep.getInstance():isPassed(TutoringStepDailyQuest) then
		return -1
	end
	local EFFECT_FILE = "music/"..EFFECT_FILE
	-- if m_nSoundId then
	-- 	audioEngine:stopEffect(m_nSoundId)
	-- end
	-- audioEngine:preloadEffect(EFFECT_FILE) -- 播放音效，第二个参数表示是否循环，true表示循环
	if isLoop == nil then 
		-- print("playEffectFunc == nil")
		isLoop = false
	end

	-- print("playEffectFunc == ", EFFECT_FILE, isLoop)

	local m_nSoundId = audioEngine:playEffect(EFFECT_FILE, isLoop)
	if m_nSoundId and m_nSoundId ~= -1 then
		if effectList[EFFECT_FILE] == nil then
			effectList[EFFECT_FILE] = 1
		else
			effectList[EFFECT_FILE] = effectList[EFFECT_FILE] + 1
		end
	end

	return m_nSoundId
end

function playFightEffectFunc(EFFECT_FILE, delay) -- 以后弃用
    -- if GameController.SET_UP_FUNC["Music"] ~= "1" and TutoringStep and TutoringStep.getInstance():isPassed(TutoringStepDailyQuest) then
    if GameController.SET_UP_FUNC["Sound"] ~= "1" then
		return -1
	end
	local m_nSoundId

    local EFFECT_FILE = "sound/"..EFFECT_FILE
    -- if m_nSoundId then
    --  audioEngine:stopEffect(m_nSoundId)
    -- end
    -- audioEngine:preloadEffect(EFFECT_FILE) -- 播放音效，第二个参数表示是否循环，true表示循环
    if delay then
        local node = cc.Node:create()
        display:getRunningScene():addChild(node)
        
        local delayTime = cc.DelayTime:create(delay)
        local callFunc = cc.CallFunc:create(function ()
           	m_nSoundId = audioEngine:playEffect(EFFECT_FILE)
            audioEngine:setEffectsVolume(0.9)
			if m_nSoundId and m_nSoundId ~= -1 then
				if effectList[EFFECT_FILE] == nil then
					effectList[EFFECT_FILE] = 1
				else
					effectList[EFFECT_FILE] = effectList[EFFECT_FILE] + 1
				end
			end
            node:removeFromParent()
        end)
        local seq = cc.Sequence:create(delayTime, callFunc)
        node:runAction(seq)
    else
        m_nSoundId = audioEngine:playEffect(EFFECT_FILE)
        audioEngine:setEffectsVolume(0.9)
		if m_nSoundId and m_nSoundId ~= -1 then
			if effectList[EFFECT_FILE] == nil then
				effectList[EFFECT_FILE] = 1
			else
				effectList[EFFECT_FILE] = effectList[EFFECT_FILE] + 1
			end
		end
    end

    return m_nSoundId
end

--heroName = 英雄的名字    animName = 动作名字
function playAnimationEffect(heroName,animName, isLoop)
	local animName = animName
	local heroName = heroName
	if not animName or not heroName then return -1 end
	if ResMgr.musicPath[heroName] and ResMgr.musicPath[heroName][animName .. ".mp3"] then 
		return playEffectFunc(heroName.."/" .. animName .. ".mp3", isLoop)
	else
		return -1
	end
end

function playBulletEffect(effectName, isLoop)
	if not effectName then return -1 end
	--print("playEffectFunc == start", isLoop)
	return playEffectFunc(effectName, isLoop)
end

function pauseAllEffects()
	audioEngine:pauseAllEffects()
end

function resumeAllEffects()
	audioEngine:resumeAllEffects()
end

function pauseEffect(soundID)
	audioEngine:pauseEffect(soundID)
end

function resumeEffect(soundID)
	audioEngine:resumeEffect(soundID)
end

function stopEffect(soundID)
	audioEngine:stopEffect(soundID)
end

function stopAllEffects()
	audioEngine:stopAllEffects()
end

function preloadEffect(path)
	local EFFECT_FILE = "music/"..path
	audioEngine:preloadEffect(EFFECT_FILE)
	

	if effectList[EFFECT_FILE] == nil then
		effectList[EFFECT_FILE] = 0
	end
end

function releaseAllEffects()
	audioEngine:stopAllEffects()
	for k,v in pairs(effectList) do
		audioEngine:unloadEffect(k)
	end

	effectList = {}
end

louderID = nil
function musicLouder()
	local volume = audioEngine:getMusicVolume()
	if not louderID then
		louderID = scheduler.scheduleGlobal(function()
			volume = volume + 0.1
			if volume >= 1 then
				volume = 1
			end
			audioEngine:setMusicVolume(volume)
			if volume >= 1 then
				if louderID then
					scheduler.unscheduleGlobal(louderID) 
					louderID = nil
				end
			end
		end, 0.1)
	end
end

function stopMusicLouder()
	if louderID then
		scheduler.unscheduleGlobal(louderID) 
		louderID = nil
	end
end

