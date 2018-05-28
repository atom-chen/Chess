local UseAudioEngine = false

if UseAudioEngine then

	SgAudioEngine = {}

	local engine = ccexp.AudioEngine

	local AudioState =
	{
	    ERROR  = -1,
	    INITIALZING = 0,
	    PLAYING = 1,
	    PAUSED = 2,
	};

	function SgAudioEngine:ctor()
		self.music = nil
		self.musicVolume = 1
		self.effectVolume = 1
		self.effects = {}
	end

	function SgAudioEngine:preloadEffect(effetName)
		engine:preload(effetName)
	end

	function SgAudioEngine:stopAllEffects()
		for _, effectId in pairs(self.effects) do
			engine:stop(effectId)
		end
		self.effects = {}
	end

	function SgAudioEngine:unloadEffect(effetName)
		engine:uncache(effetName)
	end

	function SgAudioEngine:isEffectPlaying(effectId)
		return engine:getState(effectId) == AudioState.PLAYING
	end

	function SgAudioEngine:playEffect(effetName, loop, volume)
		if loop == nil then
			loop = false
		end
		self.effectVolume = volume or self.effectVolume
		local effectId = engine:play2d(effetName, loop, self.effectVolume)
		table.insert(self.effects, effectId)
		return effectId
	end

	function SgAudioEngine:setEffectsVolume(volume)
		self.effectVolume = volume
		for _, effectId in pairs(self.effects) do
			engine:setVolume(effectId, self.effectVolume)
		end
	end

	function SgAudioEngine:pauseAllEffects()
		for _, effectId in pairs(self.effects) do
			engine:pause(effectId)
		end
	end

	function SgAudioEngine:resumeAllEffects()
		for _, effectId in pairs(self.effects) do
			engine:resume(effectId)
		end
	end

	function SgAudioEngine:pauseEffect(effectId)
		engine:pause(effectId)
	end

	function SgAudioEngine:resumeEffect(effectId)
		engine:resume(effectId)
	end

	function SgAudioEngine:stopEffect(effectId)
		engine:stop(effectId)
	end

	function SgAudioEngine:stopAllEffects()
		for _, effectId in pairs(self.effects) do
			engine:stop(effectId)
		end
	end


	-------------------------  音乐 ---------------------------------

	function SgAudioEngine:setMusicVolume(volume)
		self.musicVolume = volume
		if self.music and engine:getState(self.music) ~= AudioState.ERROR then
			engine:setVolume(self.music, volume)
		end
	end

	function SgAudioEngine:stopMusic()
		if self.music and engine:getState(self.music) ~= AudioState.ERROR then
			engine:stop(self.music)
			self.music = nil
		end
	end

	function SgAudioEngine:playMusic(musicName, loop, volume)
		if self.music ~= nil then
			engine:stop(self.music)
			self.music = nil
		end

		if loop == nil then
			loop = false
		end
		self.musicVolume = volume or self.musicVolume
		self.music = engine:play2d(musicName, loop, self.musicVolume)
	end

	function SgAudioEngine:isMusicPlaying()
		if self.music then
			return engine:getState(self.music) == AudioState.PLAYING
		end

		return false
	end

	function SgAudioEngine:pauseMusic()
		if self.music then
			engine:pause(self.music)
		end
	end

	function SgAudioEngine:resumeMusic()
		if self.music then
			engine:resume(self.music)
		end
	end

	function SgAudioEngine:preloadMusic(musicName)
		engine:preload(musicName)
	end

	function SgAudioEngine:getMusicVolume()
		return self.musicVolume
	end

	-------------------------  回调 ---------------------------------

	function SgAudioEngine:finishCallback(path, id, callback)
		engine:setFinishCallback(id, callback)
	end

	SgAudioEngine:ctor()

else
	SgAudioEngine = {}
	local engine = cc.SimpleAudioEngine:getInstance()

	function SgAudioEngine:preloadEffect(effetName)
		engine:preloadEffect(effetName)
	end

	function SgAudioEngine:stopAllEffects()
		engine:stopAllEffects()
	end

	function SgAudioEngine:unloadEffect(effetName)
		engine:unloadEffect(effetName)
	end

	function SgAudioEngine:isEffectPlaying(effectId)
		return engine:isEffectPlaying(effectId)
	end

	function SgAudioEngine:playEffect(effetName, loop, volume)
		if loop == nil then
			loop = false
		end
		
		if volume then
			self:setEffectsVolume(volume)
		end

		local effectId = engine:playEffect(effetName, loop)

		return effectId
	end

	function SgAudioEngine:setEffectsVolume(volume)
		engine:setEffectsVolume(volume)
	end

	function SgAudioEngine:getEffectsVolume()
		return engine:getEffectsVolume()
	end

	function SgAudioEngine:pauseAllEffects()
		engine:pauseAllEffects()
	end

	function SgAudioEngine:resumeAllEffects()
		engine:resumeAllEffects()
	end

	function SgAudioEngine:pauseEffect(effectId)
		engine:pauseEffect(effectId)
	end

	function SgAudioEngine:resumeEffect(effectId)
		engine:resumeEffect(effectId)
	end

	function SgAudioEngine:stopEffect(effectId)
		engine:stopEffect(effectId)
	end

	function SgAudioEngine:stopAllEffects()
		engine:stopAllEffects()
	end


	-------------------------  音乐 ---------------------------------

	function SgAudioEngine:setMusicVolume(volume)
		engine:setMusicVolume(volume)
	end

	function SgAudioEngine:stopMusic()
		engine:stopMusic()
	end

	function SgAudioEngine:playMusic(musicName, loop, volume)
		if volume then
			self:setMusicVolume(volume)
		end
		self:stopMusic()
		engine:playMusic(musicName, loop)
	end

	function SgAudioEngine:isMusicPlaying()
		return engine:isMusicPlaying()
	end

	function SgAudioEngine:pauseMusic()
		engine:pauseMusic()
	end

	function SgAudioEngine:resumeMusic()
		engine:resumeMusic()
	end

	function SgAudioEngine:preloadMusic(musicName)
		engine:preloadMusic(musicName)
	end

	function SgAudioEngine:getMusicVolume()
		return engine:getMusicVolume()
	end

	-------------------------  回调 ---------------------------------

	function SgAudioEngine:finishCallback(path, id, callback)
		local musicConf = OpenFile("musicConf")
		local time = musicConf[path] + 1  -- 延迟一秒
		scheduler.performWithDelayGlobal(callback, time)
	end

end

return SgAudioEngine
