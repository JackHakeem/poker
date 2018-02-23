--
-- Author: shineflag
-- Date: 2017-03-01 17:51:32
--

local effect_path = "audio/"
local music_path = "audio/"
local ms_type = ".mp3"
if device.platform == "android" then
ms_type = ".ogg"
else
ms_type = ".mp3"
end

--背景音乐
local music = {
	BGM = music_path .. "bgm.mp3",
}

--音效
local effect = {
	action_failed = effect_path .. "action_failed" .. ms_type,
	action_timedown = effect_path .. "action_timedown" .. ms_type,
	check = effect_path .. "check" .. ms_type,
	click = effect_path .. "click" .. ms_type,
	fayizhangpai = effect_path .. "fayizhangpai" .. ms_type,
	flop = effect_path .. "flop" .. ms_type,
	match_over = effect_path .. "match_over" .. ms_type,
	site_down = effect_path .. "site_down" .. ms_type,
	deal = effect_path .. "deal" .. ms_type, -- 洗牌
	action_tips = effect_path .. "action_tips" .. ms_type,
	chips = effect_path .. "chips" .. ms_type, -- 移动筹码
	fold = effect_path .. "fold" .. ms_type,
	join_match = effect_path .. "join_match" .. ms_type,
	raise = effect_path .. "raise" .. ms_type,
	bet = effect_path .. "bet" .. ms_type,
	shove = effect_path .. "shove" .. ms_type,
	up_bilnd = effect_path .. "up_bilnd" .. ms_type,
	match_result = effect_path .. "match_result" .. ms_type,
	shark = effect_path .. "shark" .. ms_type,
	rose = effect_path .. "rose" .. ms_type,
	chicken = effect_path .. "chicken" .. ms_type,
	cheers = effect_path .. "cheers" .. ms_type,
	touzhu_bet = effect_path .. "touzhu_bet" .. ms_type,
	touzhu_touzhu = effect_path .. "touzhu_touzhu" .. ms_type,
	touzhu_lottery = effect_path .. "touzhu_lottery" .. ms_type,
	touzhu_winning = effect_path .. "touzhu_winning" .. ms_type,
	touzhu_lottery_dice = effect_path .. "touzhu_lottery_dice" .. ms_type,
}



local play = {}

local function init_keys ()
	for k, v in pairs(music) do
	    play[k] = v
	end

	for k, v in pairs(effect) do
	    play[k] = v
	end
end

local function preload_music()
	-- preload all musics
	for k, v in pairs(music) do
	    audio.preloadMusic(v)
	end
end

local function preload_sound( ... )
	-- preload all effects
	for k, v in pairs(effect) do
	    audio.preloadSound(v)
	end
end

local isPlayMusic = false
local musicName = nil

local function play_music( name )
	musicName = name
	local src = music[name]
	print("playMusic",src)
	if not (tt.game_data.music_btn_status == false) then
		isPlayMusic = true
		audio.playMusic(src, true)
	end
end

local function pause_music()
	audio.pauseMusic()
end

local function resume_music()
	if not (tt.game_data.music_btn_status == false) then
		if isPlayMusic then 
			audio.resumeMusic()
		else
			play_music(musicName)
		end
	end
end

local function stop_music()
	audio.stopMusic()
	isPlayMusic = false
end

local function play_sound( name ,flag )
	print("playSound",name,tt.game_data.sound_btn_status ~= false)
	if tt.game_data.sound_btn_status ~= false and effect[name] then
	    audio.playSound(effect[name], flag or false)
	end
end

local function set_music_vol( volume )
	print("setVol:",volume)
	audio.setMusicVolume(volume)
end

local function get_music_vol()
	local volume =  audio.getMusicVolume()
	print("getVol:",volume)
	return volume
end

local function set_sounds_vol(volume)
	printInfo("set_sounds_vol:",volume)
	audio.setSoundsVolume(volume)
end

local function get_sounds_vol()
	local volume = audio.getSoundsVolume()
	printInfo("get_sounds_vol:",volume)
	return volume
end

local function get_effect_config()
	return effect
end

preload_music()
preload_sound()
get_music_vol()
set_music_vol(1.0)
set_sounds_vol(1.0)
init_keys()

play.play_music = play_music
play.play_sound = play_sound
play.pause_music = pause_music
play.resume_music = resume_music
play.stop_music = stop_music
play.get_effect_config = get_effect_config
play.set_music_vol = set_music_vol
play.set_sounds_vol = set_sounds_vol
return play