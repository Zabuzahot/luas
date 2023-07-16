script_name("MedicalHelper")
script_authors("Alberto Kane")
script_description("Script for the Ministries of Health Arizona Role Play")
script_version("3.2.0")
script_properties("work-in-pause")

local text_err_and_read = {
	[1] = [[
 Не обнаружен файл SAMPFUNCS.asi в папке игры, вследствие чего
скрипту не удалось запуститься.

		Для решения проблемы:
1. Закройте игру;
2. Зайдите во вкладку "Моды" в лаунчере Аризоны.
Найдите во вкладке "Моды" установщик "Moonloader" и нажмите кнопку "Установить".
После завершения установки вновь запустите игру. Проблема исчезнет.

Если Вам это не помогло, то обращайтесь в сообщения:
		vk.com/marseloy

Игра была свернута, поэтому можете продолжить играть. 
]],
	[2] = [[
		  Внимание! 
Не обнаружены некоторые важные файлы для работы скрипта.
В следствии чего, скрипт перестал работать.
	Список необнаруженных файлов:
		%s

		Для решения проблемы:
1. Закройте игру;
2. Зайдите во вкладку "Моды" в лаунчере Аризоны.
Найдите во вкладке "Моды" установщик "Moonloader" и нажмите кнопку "Установить".
После завершения установки вновь запустите игру. Проблема исчезнет.

Если Вам это не помогло, то обращайтесь в сообщения:
		vk.com/marseloy

Игра была свернута, поэтому можете продолжить играть. . 
]],
	[3] = {
		"/lib/imgui.lua",
		"/lib/samp/events.lua",
		"/lib/rkeysMH.lua",
		"/lib/faIcons.lua",
		"/lib/crc32ffi.lua",
		"/lib/bitex.lua",
		"/lib/MoonImGui.dll",
		"/lib/matrix3x3.lua"
	},
	[4] = {}
}

if doesFileExist(getWorkingDirectory().."/lib/rkeysMH.lua") then
	print("{82E28C}Чтение библиотеки rkeysMH...")
	local f = io.open(getWorkingDirectory().."/lib/rkeysMH.lua")
	f:close()
else
	print("{F54A4A}Ошибка. Отсутствует библиотека rkeysMH {82E28C}Создание библиотеки rkeysMH...")
	local textrkeys = [[
local vkeys = require 'vkeys'

vkeys.key_names[vkeys.VK_LMENU] = "LAlt"
vkeys.key_names[vkeys.VK_RMENU] = "RAlt"
vkeys.key_names[vkeys.VK_LSHIFT] = "LShift"
vkeys.key_names[vkeys.VK_RSHIFT] = "RShift"
vkeys.key_names[vkeys.VK_LCONTROL] = "LCtrl"
vkeys.key_names[vkeys.VK_RCONTROL] = "RCtrl"

local tHotKey = {}
local tKeyList = {}
local tKeysCheck = {}
local iCountCheck = 0
local tBlockKeys = {[vkeys.VK_LMENU] = true, [vkeys.VK_RMENU] = true, [vkeys.VK_RSHIFT] = true, [vkeys.VK_LSHIFT] = true, [vkeys.VK_LCONTROL] = true, [vkeys.VK_RCONTROL] = true}
local tModKeys = {[vkeys.VK_MENU] = true, [vkeys.VK_SHIFT] = true, [vkeys.VK_CONTROL] = true}
local tBlockNext = {}
local module = {}
module._VERSION = "1.0.7"
module._MODKEYS = tModKeys
module._LOCKKEYS = false

local function getKeyNum(id)
   for k, v in pairs(tKeyList) do
      if v == id then
         return k
      end
   end
   return 0
end

function module.blockNextHotKey(keys)
   local bool = false
   if not module.isBlockedHotKey(keys) then
      tBlockNext[#tBlockNext + 1] = keys
      bool = true
   end
   return bool
end

function module.isHotKeyHotKey(keys, keys2)
   local bool
   for k, v in pairs(keys) do
      local lBool = true
      for i = 1, #keys2 do
         if v ~= keys2[i] then
            lBool = false
            break
         end
      end
      if lBool then
         bool = true
         break
      end
   end
   return bool
end


function module.isBlockedHotKey(keys)
   local bool, hkId = false, -1
   for k, v in pairs(tBlockNext) do
      if module.isHotKeyHotKey(keys, v) then
         bool = true
         hkId = k
         break
      end
   end
   return bool, hkId
end

function module.unBlockNextHotKey(keys)
   local result = false
   local count = 0
   while module.isBlockedHotKey(keys) do
      local _, id = module.isBlockedHotKey(keys)
      tHotKey[id] = nil
      result = true
      count = count + 1
   end
   local id = 1
   for k, v in pairs(tBlockNext) do
      tBlockNext[id] = v
      id = id + 1
   end
   return result, count
end

function module.isKeyModified(id)
   return (tModKeys[id] or false) or (tBlockKeys[id] or false)
end

function module.isModifiedDown()
   local bool = false
   for k, v in pairs(tModKeys) do
      if isKeyDown(k) then
         bool = true
         break
      end
   end
   return bool
end

lua_thread.create(function ()
   while true do
      wait(0)
      local tDownKeys = module.getCurrentHotKey()
      for k, v in pairs(tHotKey) do
         if #v.keys > 0 then
            local bool = true
            for i = 1, #v.keys do
               if i ~= #v.keys and (getKeyNum(v.keys[i]) > getKeyNum(v.keys[i + 1]) or getKeyNum(v.keys[i]) == 0) then
                  bool = false
                  break
               elseif i == #v.keys and (v.pressed and not wasKeyPressed(v.keys[i]) or not v.pressed and not isKeyDown(v.keys[i])) or (#v.keys == 1 and module.isModifiedDown()) then
                  bool = false
                  break
               end
            end
            if bool and ((module.onHotKey and module.onHotKey(k, v.keys) ~= false) or module.onHotKey == nil) then
               local result, id = module.isBlockedHotKey(v.keys)
               if not result then
                  v.callback(k, v.keys)
               else
                  tBlockNext[id] = nil
               end
            end
         end
      end
   end
end)

function module.registerHotKey(keys, pressed, callback)
   tHotKey[#tHotKey + 1] = {keys = keys, pressed = pressed, callback = callback}
   return true, #tHotKey
end

function module.getAllHotKey()
   return tHotKey
end

function module.unRegisterHotKey(keys)

   local result = false
   local count = 0
   while module.isHotKeyDefined(keys) do
      local _, id = module.isHotKeyDefined(keys)
      tHotKey[id] = nil
      result = true
      count = count + 1
   end
   local id = 1
   local tNewHotKey = {}
   for k, v in pairs(tHotKey) do
      tNewHotKey[id] = v
      id = id + 1
   end
   tHotKey = tNewHotKey
   return result, count
 
end

function module.isHotKeyDefined(keys)
   local bool, hkId = false, -1
   for k, v in pairs(tHotKey) do
      if module.isHotKeyHotKey(keys, v.keys) then
         bool = true
         hkId = k
         break
      end
   end
   return bool, hkId
end

function module.getKeysName(keys)
   local tKeysName = {}
   for k, v in ipairs(keys) do
      tKeysName[k] = vkeys.id_to_name(v)
   end
   return tKeysName
end

function module.getCurrentHotKey(type)
   local type = type or 0
   local tCurKeys = {}
   for k, v in pairs(vkeys) do
      if tBlockKeys[v] == nil then
         local num, down = getKeyNum(v), isKeyDown(v)
         if down and num == 0 then
            tKeyList[#tKeyList + 1] = v
         elseif num > 0 and not down then
            tKeyList[num] = nil
         end
      end
   end
   local i = 1
   for k, v in pairs(tKeyList) do
      tCurKeys[i] = type == 0 and v or vkeys.id_to_name(v)
      i = i + 1
   end
   return tCurKeys
end

return module

]]
	local f = io.open(getWorkingDirectory().."/lib/rkeysMH.lua", "w")
	f:write(textrkeys)
	f:close()			
end

for i,v in ipairs(text_err_and_read[3]) do
	if not doesFileExist(getWorkingDirectory()..v) then
		table.insert(text_err_and_read[4], v)
	end
end

local ffi = require 'ffi'
ffi.cdef [[
		typedef int BOOL;
		typedef unsigned long HANDLE;
		typedef HANDLE HWND;
		typedef const char* LPCSTR;
		typedef unsigned UINT;
		
        void* __stdcall ShellExecuteA(void* hwnd, const char* op, const char* file, const char* params, const char* dir, int show_cmd);
        uint32_t __stdcall CoInitializeEx(void*, uint32_t);
		
		BOOL ShowWindow(HWND hWnd, int  nCmdShow);
		HWND GetActiveWindow();
		
		
		int MessageBoxA(
		  HWND   hWnd,
		  LPCSTR lpText,
		  LPCSTR lpCaption,
		  UINT   uType
		);
		
		short GetKeyState(int nVirtKey);
		bool GetKeyboardLayoutNameA(char* pwszKLID);
		int GetLocaleInfoA(int Locale, int LCType, char* lpLCData, int cchData);
  ]]

require "lib.sampfuncs"
require "lib.moonloader"
local mem = require "memory"
local vkeys = require "vkeys"

local encoding = require "encoding"
if not doesFileExist(getWorkingDirectory().."/lib/effil.lua") then
	effilNOT = true
else
	effil = require "effil"
	effilNOT = false
end
if not doesFileExist(getWorkingDirectory().."/lib/bass.lua") then
	bassNOT = true
else
	bass = require "bass"
	bass.BASS_Stop()
	bass.BASS_Start()
	bassNOT = false
end
encoding.default = "CP1251"
local u8 = encoding.UTF8
local dlstatus = require("moonloader").download_status
local shell32 = ffi.load 'Shell32'
local ole32 = ffi.load 'Ole32'
ole32.CoInitializeEx(nil, 2 + 4)

if not doesFileExist(getGameDirectory().."/SAMPFUNCS.asi") then
	ffi.C.ShowWindow(ffi.C.GetActiveWindow(), 6)
	ffi.C.MessageBoxA(0, text_err_and_read[1], "MedicalHelper", 0x00000030 + 0x00010000)
end
if #text_err_and_read[4] > 0 then
	ffi.C.ShowWindow(ffi.C.GetActiveWindow(), 6)
	ffi.C.MessageBoxA(0, text_err_and_read[2]:format(table.concat(text_err_and_read[4], "\n\t\t")), "MedicalHelper", 0x00000030 + 0x00010000)
end
text_err_and_read = nil

local res, hook = pcall(require, 'lib.samp.events')
assert(res, "Библиотека SAMP Event не найдена")
---------------------------------------------------
local res, imgui = pcall(require, "imgui")
assert(res, "Библиотека Imgui не найдена")
---------------------------------------------------
local res, fa = pcall(require, 'faIcons')
assert(res, "Библиотека faIcons не найдена")
---------------------------------------------------
local res, rkeys = pcall(require, 'rkeysMH')
assert(res, "Библиотека Rkeys не найдена")
vkeys.key_names[vkeys.VK_RBUTTON] = "RBut"
vkeys.key_names[vkeys.VK_XBUTTON1] = "XBut1"
vkeys.key_names[vkeys.VK_XBUTTON2] = 'XBut2'
vkeys.key_names[vkeys.VK_NUMPAD1] = 'Num 1'
vkeys.key_names[vkeys.VK_NUMPAD2] = 'Num 2'
vkeys.key_names[vkeys.VK_NUMPAD3] = 'Num 3'
vkeys.key_names[vkeys.VK_NUMPAD4] = 'Num 4'
vkeys.key_names[vkeys.VK_NUMPAD5] = 'Num 5'
vkeys.key_names[vkeys.VK_NUMPAD6] = 'Num 6'
vkeys.key_names[vkeys.VK_NUMPAD7] = 'Num 7'
vkeys.key_names[vkeys.VK_NUMPAD8] = 'Num 8'
vkeys.key_names[vkeys.VK_NUMPAD9] = 'Num 9'
vkeys.key_names[vkeys.VK_MULTIPLY] = 'Num *'
vkeys.key_names[vkeys.VK_ADD] = 'Num +'
vkeys.key_names[vkeys.VK_SEPARATOR] = 'Separator'
vkeys.key_names[vkeys.VK_SUBTRACT] = 'Num -'
vkeys.key_names[vkeys.VK_DECIMAL] = 'Num .Del'
vkeys.key_names[vkeys.VK_DIVIDE] = 'Num /'
vkeys.key_names[vkeys.VK_LEFT] = 'Ar.Left'
vkeys.key_names[vkeys.VK_UP] = 'Ar.Up'
vkeys.key_names[vkeys.VK_RIGHT] = 'Ar.Right'
vkeys.key_names[vkeys.VK_DOWN] = 'Ar.Down'

imgRECORD = {}
function download_image()
	if not doesFileExist(getWorkingDirectory().."/MedicalHelper/record.png") then
		print("{F54A4A}Ошибка. Не найдено изображение.{82E28C} Произвожу скачивание png.")
		download_id = downloadUrlToFile('https://i.imgur.com/gPNNH1g.png', getWorkingDirectory().."/MedicalHelper/record.png", function(id, status, p1, p2)
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then
				print("{82E28C}Изображение успешно загружено!")
			end
		end)
	end

	if not doesFileExist(getWorkingDirectory().."/MedicalHelper/recordMegamix.png") then
		download_id = downloadUrlToFile('https://i.imgur.com/Hv3PIen.png', getWorkingDirectory().."/MedicalHelper/recordMegamix.png", function(id, status, p1, p2)
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then 
				imgRecordMegamix = imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/recordMegamix.png")
			end
		end)
	end

	if not doesFileExist(getWorkingDirectory().."/MedicalHelper/recordparty.png") then
		download_id = downloadUrlToFile('https://i.imgur.com/JEIc2L1.png', getWorkingDirectory().."/MedicalHelper/recordparty.png", function(id, status, p1, p2)
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then 
				imgRecordParty = imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/recordparty.png")
			end
		end)
	end

	if not doesFileExist(getWorkingDirectory().."/MedicalHelper/nolabel.png") then
		download_id = downloadUrlToFile('https://ru.apporange.space/static/images/no-cover-150.jpg', getWorkingDirectory().."/MedicalHelper/nolabel.png", function(id, status, p1, p2)
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then 
				imgNoLabel = imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/nolabel.png")
				local texture_im = imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/nolabel.png")
				imgRECORD = {texture_im, texture_im, texture_im, texture_im, texture_im, texture_im, texture_im, texture_im, texture_im}
			end
		end)
	end

	if not doesDirectoryExist(getWorkingDirectory().."/MedicalHelper/Изображения/") then
		print("{F54A4A}Ошибка. Отсутствует папка. {82E28C}Создание папки для изображений...")
		createDirectory(getWorkingDirectory().."/MedicalHelper/Изображения/")
	end

	if not doesFileExist(getWorkingDirectory().."/MedicalHelper/Изображения/DANCE.png") then
		download_id = downloadUrlToFile('https://i.imgur.com/F6hxtdC.png', getWorkingDirectory().."/MedicalHelper/Изображения/DANCE.png", function(id, status, p1, p2)
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then 
				imgRECORD[1] = imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/Изображения/DANCE.png")
			end
		end)
	end
	
	if not doesFileExist(getWorkingDirectory().."/MedicalHelper/Изображения/MEGAMIX.png") then
		download_id = downloadUrlToFile('https://imgur.com/lsYixKr.png', getWorkingDirectory().."/MedicalHelper/Изображения/MEGAMIX.png", function(id, status, p1, p2)
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then 
				imgRECORD[2] = imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/Изображения/MEGAMIX.png")
			end
		end)
	end
	
	if not doesFileExist(getWorkingDirectory().."/MedicalHelper/Изображения/PARTY.png") then
		download_id = downloadUrlToFile('https://imgur.com/lEpOpLy.png', getWorkingDirectory().."/MedicalHelper/Изображения/PARTY.png", function(id, status, p1, p2)
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then 
				imgRECORD[3] = imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/Изображения/PARTY.png")
			end
		end)
	end
	
	if not doesFileExist(getWorkingDirectory().."/MedicalHelper/Изображения/PHONK.png") then
		download_id = downloadUrlToFile('https://imgur.com/UWHK1nN.png', getWorkingDirectory().."/MedicalHelper/Изображения/PHONK.png", function(id, status, p1, p2)
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then 
				imgRECORD[4] = imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/Изображения/PHONK.png")
			end
		end)
	end
	
	if not doesFileExist(getWorkingDirectory().."/MedicalHelper/Изображения/GOPFM.png") then
		download_id = downloadUrlToFile('https://imgur.com/GkovIZT.png', getWorkingDirectory().."/MedicalHelper/Изображения/GOPFM.png", function(id, status, p1, p2)
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then 
				imgRECORD[5] = imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/Изображения/GOPFM.png")
			end
		end)
	end
	
	if not doesFileExist(getWorkingDirectory().."/MedicalHelper/Изображения/RUKIVVERH.png") then
		download_id = downloadUrlToFile('https://imgur.com/ZftaAuK.png', getWorkingDirectory().."/MedicalHelper/Изображения/RUKIVVERH.png", function(id, status, p1, p2)
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then 
				imgRECORD[6] = imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/Изображения/RUKIVVERH.png")
			end
		end)
	end
	
	if not doesFileExist(getWorkingDirectory().."/MedicalHelper/Изображения/DUPSTEP.png") then
		download_id = downloadUrlToFile('https://imgur.com/Q8Jed4R.png', getWorkingDirectory().."/MedicalHelper/Изображения/DUPSTEP.png", function(id, status, p1, p2)
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then 
				imgRECORD[7] = imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/Изображения/DUPSTEP.png")
			end
		end)
	end
	
	if not doesFileExist(getWorkingDirectory().."/MedicalHelper/Изображения/BIGHITS.png") then
		download_id = downloadUrlToFile('https://imgur.com/OeGdMu8.png', getWorkingDirectory().."/MedicalHelper/Изображения/BIGHITS.png", function(id, status, p1, p2)
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then 
				imgRECORD[8] = imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/Изображения/BIGHITS.png")
			end
		end)
	end
	
	if not doesFileExist(getWorkingDirectory().."/MedicalHelper/Изображения/ORGANIC.png") then
		download_id = downloadUrlToFile('https://imgur.com/xuOZVCU.png', getWorkingDirectory().."/MedicalHelper/Изображения/ORGANIC.png", function(id, status, p1, p2)
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then 
				imgRECORD[9] = imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/Изображения/ORGANIC.png")
			end
		end)
	end
	if not doesFileExist(getWorkingDirectory().."/MedicalHelper/Изображения/RUSSIANHITS.png") then
		download_id = downloadUrlToFile('https://imgur.com/SnA1FR8.png', getWorkingDirectory().."/MedicalHelper/Изображения/RUSSIANHITS.png", function(id, status, p1, p2)
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then 
				imgRECORD[10] = imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/Изображения/RUSSIANHITS.png")
			end
		end)
	end
end
download_image()

--> Файловая система
deck = getFolderPath(0) --> Деск
doc = getFolderPath(5) --> Скрины
dirml = getWorkingDirectory() ---> Мун
dirGame = getGameDirectory()
scr = thisScript()
font = renderCreateFont("Trebuchet MS", 14, 5)
fontPD = renderCreateFont("Trebuchet MS", 12, 5)
fontH =  renderGetFontDrawHeight(font)
sx, sy = getScreenResolution()

mainWin	= imgui.ImBool(false) --> Гл.окно
paramWin = imgui.ImBool(false) --> Окно параметров
actingOutWind = imgui.ImBool(false) ---> Окно редактора отыгровки
spurBig = imgui.ImBool(false) --> Большое окно шпоры
sobWin = imgui.ImBool(false) --> Окно собески
depWin = imgui.ImBool(false) --> Окно департамента
updWin = imgui.ImBool(false) --> Окно обновлений
iconwin	= imgui.ImBool(false)
profbWin = imgui.ImBool(false)
choiceWin	= imgui.ImBool(false)
select_menu = {true, false, false, false, false, false, false, false, false, false} --> Для переключения меню
getposcur = 2
poshovbut = 2
poshovbuttr = {false, false, false, false, false, false, false, false, false, false}
visbut = 0.00

--> Для обновления
upd_beta = false
upd_release = false
newversb = scr.version:gsub("%D","")
newversr = scr.version:gsub("%D","")
scrvers = scr.version:gsub("%D","")

--> Транслитизаторные переменные
local trstl1 = {['ph'] = 'ф',['Ph'] = 'Ф',['Ch'] = 'Ч',['ch'] = 'ч',['Th'] = 'Т',['th'] = 'т',['Sh'] = 'Ш',['sh'] = 'ш', ['ea'] = 'и',['Ae'] = 'Э',['ae'] = 'э',['size'] = 'сайз',['Jj'] = 'Джейджей',['Whi'] = 'Вай',['lack'] = 'лэк',['whi'] = 'вай',['Ck'] = 'К',['ck'] = 'к',['Kh'] = 'Х',['kh'] = 'х',['hn'] = 'н',['Hen'] = 'Ген',['Zh'] = 'Ж',['zh'] = 'ж',['Yu'] = 'Ю',['yu'] = 'ю',['Yo'] = 'Ё',['yo'] = 'ё',['Cz'] = 'Ц',['cz'] = 'ц', ['ia'] = 'я', ['ea'] = 'и',['Ya'] = 'Я', ['ya'] = 'я', ['ove'] = 'ав',['ay'] = 'эй', ['rise'] = 'райз',['oo'] = 'у', ['Oo'] = 'У', ['Ee'] = 'И', ['ee'] = 'и', ['Un'] = 'Ан', ['un'] = 'ан', ['Ci'] = 'Ци', ['ci'] = 'ци', ['yse'] = 'уз', ['cate'] = 'кейт', ['eow'] = 'яу', ['rown'] = 'раун', ['yev'] = 'уев', ['Babe'] = 'Бэйби', ['Jason'] = 'Джейсон', ['liy'] = 'лий', ['ane'] = 'ейн', ['ame'] = 'ейм'}
local trstl = {['B'] = 'Б',['Z'] = 'З',['T'] = 'Т',['Y'] = 'Й',['P'] = 'П',['J'] = 'Дж',['X'] = 'Кс',['G'] = 'Г',['V'] = 'В',['H'] = 'Х',['N'] = 'Н',['E'] = 'Е',['I'] = 'И',['D'] = 'Д',['O'] = 'О',['K'] = 'К',['F'] = 'Ф',['y`'] = 'ы',['e`'] = 'э',['A'] = 'А',['C'] = 'К',['L'] = 'Л',['M'] = 'М',['W'] = 'В',['Q'] = 'К',['U'] = 'А',['R'] = 'Р',['S'] = 'С',['zm'] = 'зьм',['h'] = 'х',['q'] = 'к',['y'] = 'и',['a'] = 'а',['w'] = 'в',['b'] = 'б',['v'] = 'в',['g'] = 'г',['d'] = 'д',['e'] = 'е',['z'] = 'з',['i'] = 'и',['j'] = 'ж',['k'] = 'к',['l'] = 'л',['m'] = 'м',['n'] = 'н',['o'] = 'о',['p'] = 'п',['r'] = 'р',['s'] = 'с',['t'] = 'т',['u'] = 'у',['f'] = 'ф',['x'] = 'x',['c'] = 'к',['``'] = 'ъ',['`'] = 'ь',['_'] = ' '}
local trsliterCMD = {['q'] = 'й',['w'] = 'ц',['e'] = 'у',['r'] = 'к',['t'] = 'е',['y'] = 'н',['u'] = 'г',['i'] = 'ш', ['o'] = 'щ',['p'] = 'з',['a'] = 'ф',['s'] = 'ы',['d'] = 'в',['f'] = 'а',['g'] = 'п',['h'] = 'р',['j'] = 'о',['k'] = 'л',['l'] = 'д',['z'] = 'я',['x'] = 'ч',['c'] = 'с',['v'] = 'м',['b'] = 'и',['n'] = 'т',['m'] = 'ь',['/'] = '.'}
local trsliterEng = {['а'] = 'a',['б'] = 'b',['в'] = 'v',['г'] = 'g',['д'] = 'd',['е'] = 'e',['ё'] = 'e',['ж'] = 'zh', ['з'] = 'z',['и'] = 'i',['й'] = 'i',['к'] = 'k',['л'] = 'l',['м'] = 'm',['н'] = 'n',['о'] = 'o',['п'] = 'p',['р'] = 'r',['с'] = 's',['т'] = 't',['у'] = 'u',['ф'] = 'f',['х'] = 'kh',['ц'] = 'ts',['ч'] = 'ch',['ш'] = 'sh',['щ'] = 'shch',['ъ'] = 'ie',['ы'] = 'y',['ь'] = '',['э'] = 'e',['ю'] = 'iu',['я'] = 'ia',['А'] = 'a',['Б'] = 'b',['В'] = 'v',['Г'] = 'g',['Д'] = 'd',['Е'] = 'e',['Ё'] = 'e',['Ж'] = 'zh', ['З'] = 'z',['И'] = 'i',['Й'] = 'i',['К'] = 'k',['Л'] = 'l',['М'] = 'm',['Н'] = 'n',['О'] = 'o',['П'] = 'p',['Р'] = 'r',['С'] = 's',['Т'] = 't',['У'] = 'u',['Ф'] = 'f',['Х'] = 'kh',['Ц'] = 'ts',['Ч'] = 'ch',['Ш'] = 'sh',['Щ'] = 'shch',['Ъ'] = 'ie',['Ы'] = 'y',['Ь'] = '',['Э'] = 'e',['Ю'] = 'iu',['Я'] = 'ia'}

function getPlayerNickName(idplayer)
	if sampGetGamestate() == 3 then
		end_nick = sampGetPlayerNickname(idplayer)
	else
		end_nick = "Nick_Name"
		return end_nick
	end
	return end_nick
end

--> Транслитизатор
function trst(name)
if name:match('%a+') then
        for k, v in pairs(trstl1) do
            name = name:gsub(k, v) 
        end
		for k, v in pairs(trstl) do
            name = name:gsub(k, v) 
        end
        return name
    end
 return name
end

--> Главные настройки
local setting = {
	nick = "",
	teg = "",
	org = 0,
	sex = 0,
	rank = 0,
	time = false,
	timeDo = false, 
	timeTx = "",
	rac = false,
	racTx = "",
	lec = "",
	mede = {"20000", "40000", "60000", "80000"},
	upmede = {"40000", "60000", "80000", "100000"},
	rec = "",
	narko = "",
	tatu = "",
	ant = "",
	chat1 = false,
	chat2 = false,
	chat3 = false,
	chathud = false,
	arp = false,
	setver = 1,
	imageUp = false,
	imageDis = false,
	theme = 0,
	themAngle = true,
	spawn = false,
	autolec = false,
	prikol = false
}
setdepteg = {
	tegtext_one = u8"к",
	tegtext_two = u8" от ",
	tegtext_three = ":",
	tegpref_one = 0,
	tegpref_two = 2,
	prefix = {u8"ВСЕМ", u8"Пра-во", u8"ГЦЛ", u8"СТК", u8"ЦБ", u8"ЛСа", u8"СФа", u8"ТСР", u8"ФБР", u8"РКШД", u8"ЛСПД", u8"СФПД", u8"ЛВМПД", u8"ЛСМЦ", u8"СФМЦ", u8"ЛВМЦ", u8"ЧБЛС", u8"СМИ ЛС", u8"СМИ СФ", u8"СМИ ЛВ", u8"ЦА", u8"МО", u8"МЗ", u8"МЮ"}
}
buf_nick	= imgui.ImBuffer(256)
buf_teg 	= imgui.ImBuffer(256)
your_tag = imgui.ImBuffer(256)
num_org		= imgui.ImInt(0)
num_sex		= imgui.ImInt(0)
num_dep		= imgui.ImInt(0)
num_dep2		= imgui.ImInt(0)
num_dep3		= imgui.ImInt(0)
num_pref		= imgui.ImInt(0)
num_theme		= imgui.ImInt(0)
num_rank	= imgui.ImInt(0)
chgName = {}
chgDepSetD = {imgui.ImBuffer(128),imgui.ImBuffer(128),imgui.ImBuffer(128)}
chgDepSetTeg = imgui.ImBuffer(128)
chgDepSetPref = imgui.ImBuffer(128)
chgName.inp = imgui.ImBuffer(100)
chgName.org = {u8"Больница ЛС", u8"Больница СФ", u8"Больница ЛВ", u8"Больница Джефферсон"}
chgName.rank = {u8"Интерн", u8"Участковый врач", u8"Терапевт", u8"Нарколог", u8"Окулист", u8"Хирург", u8"Психолог", u8"Завед. отделением", u8"Зам.Гл.Врача", u8"Глав.Врач", u8"Министр Здравоохранения"}
list_cmd = {u8"mh", u8"r", u8"rb", u8"mb", u8"hl", u8"post", u8"mc", u8"narko", u8"recep", u8"osm", u8"dep", u8"sob", u8"tatu", u8"vig", u8"unvig", u8"muteorg", u8"unmuteorg", u8"gr", u8"inv", u8"unv", u8"time", u8"exp", u8"vac", u8"info", u8"za", u8"zd", u8"ant", u8"strah", u8"cur", u8"hall", u8"hilka", u8"shpora", u8"hme", u8"show", u8"cam", u8"godeath"}
prefix_end = {"","","","",""}
positbut = 0
positbut2 = 0
positbut3 = 0
prikol = imgui.ImBool(false)
activebutanim = {false, false, 1}
activebutanim2 = {false, false, 1}
activebutanim3 = {false, false, 1}

--> Напоминания
local ReminderWin = imgui.ImBool(false)
local reminder = {}
local reminder_buf = {
	timer = {year = imgui.ImInt(0), mon = imgui.ImInt(0), day = imgui.ImInt(0), hour = imgui.ImFloat(1.0), min = imgui.ImFloat(1.0)},
	text = imgui.ImBuffer(1024),
	repeats = {imgui.ImBool(false), imgui.ImBool(false), imgui.ImBool(false), imgui.ImBool(false), imgui.ImBool(false), imgui.ImBool(false), imgui.ImBool(false)},
	sound = imgui.ImBool(true)
}

local list_org_BL = {"Больница LS", "Больница SF", "Больница LV", "Больница Jafferson"} 
local list_org	= {u8"Больница ЛС", u8"Больница СФ", u8"Больница ЛВ", u8"Больница Джефферсон"}
local list_org_en = {"Los-Santos Medical Center","San-Fierro Medical Center","Las-Venturas Medical Center","Jafferson Medical Center"}
local list_sex	= {fa.ICON_MALE .. u8" Мужской", fa.ICON_FEMALE .. u8" Женский"} 
local list_rank	= {u8"Интерн", u8"Участковый врач", u8"Терапевт", u8"Нарколог", u8"Окулист", u8"Хирург", u8"Психолог", u8"Завед. отделением", u8"Зам.Гл.Врача", u8"Глав.Врач", u8"Министр Здравоохранения"}
local list_theme = {u8"Пурпурная", u8"Синяя", u8"Красная", u8"Голубая", u8"Оранжевая", u8"Чёрно-белая", u8"Зелёная", u8"Монохром"}
local list_dep_pref_one	= {u8"Тег к обращаемому \nсо скобками",u8"Тег к обращаемому \nбез скобок",u8"Ваш тег \nсо скобками",u8"Ваш тег \nбез скобок",u8"Без тега"}
local list_dep_pref_two	= {u8"Тег к обращаемому \nсо скобками",u8"Тег к обращаемому \nбез скобок",u8"Ваш тег \nсо скобками",u8"Ваш тег \nбез скобок",u8"Без тега"} 

--> Чат
local cb_chat1	= imgui.ImBool(false)
local cb_chat2	= imgui.ImBool(false)
local cb_chat3	= imgui.ImBool(false)
local cb_hud		= imgui.ImBool(false)
local hudPing = false
local cb_hudTime	= imgui.ImBool(false)
local theme_Angle = imgui.ImBool(true)
local accept_spawn = imgui.ImBool(false)
local accept_autolec = imgui.ImBool(false)
local healme = false
local deadgov = false
local searchtext = imgui.ImBuffer(256)
local textes
local select_menu_money = true

--> Время
local cb_time		= imgui.ImBool(false)
local cb_timeDo	= imgui.ImBool(false)
local cb_rac		= imgui.ImBool(false)
local buf_time	= imgui.ImBuffer(256)
local buf_rac		= imgui.ImBuffer(256)

--> Цены
local buf_lec		= imgui.ImBuffer(10);
local buf_mede = {imgui.ImBuffer(10), imgui.ImBuffer(10), imgui.ImBuffer(10), imgui.ImBuffer(10)}
local buf_upmede = {imgui.ImBuffer(10), imgui.ImBuffer(10), imgui.ImBuffer(10), imgui.ImBuffer(10)}
local buf_rec		= imgui.ImBuffer(10);
local buf_narko	= imgui.ImBuffer(10);
local buf_tatu	= imgui.ImBuffer(10);
local buf_ant	= imgui.ImBuffer(10);
buf_mede[1].v = "20000"
buf_mede[2].v = "40000"
buf_mede[3].v = "60000"
buf_mede[4].v = "80000"
buf_upmede[1].v = "40000"
buf_upmede[2].v = "60000"
buf_upmede[3].v = "80000"
buf_upmede[4].v = "100000"
local lectime = false
local statusvac = false
local errorspawn = false
local session_clean = imgui.ImInt(0)
local session_afk = imgui.ImInt(0)
local session_all = imgui.ImInt(0)

--> Шпора
local spur = {
text = imgui.ImBuffer(51200),
name = imgui.ImBuffer(256),
list = {},
select_spur = -1,
edit = false
}

--> Для команды бинда
function translatizator(name)
	if name:match('%a+') then
        for k, v in pairs(trsliterCMD) do
            name = name:gsub(k, v) 
        end
        return name
    end
 return name
end
function translatizatorEng(name)
	if name:match('%A+') then
        for k, v in pairs(trsliterEng) do
            name = name:gsub(k, v)
        end
        return name
    end
 return name
end
local online_stat = {
	clean = {0, 0, 0, 0, 0, 0, 0}, --> Чистый онлайн за день (payday)
	afk = {0, 0, 0, 0, 0, 0, 0}, --> АФК за день (lec)
	all = {0, 0, 0, 0, 0, 0, 0}, --> Общий за день
	total_week = 0, --> Всего за неделю
	total_all = 0, --> Итого
	date_num = {0, 0}, --> Дата в цифровом формате {Сегодня, вчера}
	date_today = {os.date("%d") + 0, os.date("%m") + 0, os.date("%Y") + 0}, --> Дата захода в реальном времени в формате {день, месяц, год}
	date_last = {os.date("%d") + 0, os.date("%m") + 0, os.date("%Y") + 0}, --> Дата вчерашняя в формате {день, месяц, год}
	date_week = {os.date("%d.%m.%Y"), "", "", "", "", "", ""} --> Дата за неделю в формате [день, месяц, год]
}

function round(num, step) --> 1) число | 2) шаг округления
  return math.ceil(num / step) * step
end

local sw, sh = getScreenResolution()
local membScr = {
	func = false,
	pos = {x = round(sw - 30, 1), y = round(sh / 3, 1)},
	forma = true,
	numrank = true,
	id = true,
	afk = true,
	dialog = false,
	vergor = false,
	font = {
		size = 12.0,
		flag = 5.0,
		distance = 21.0,
		visible = 200
	},
	color = {
    	col_title 	= 0xFFFFAAAA,
    	col_default = 0xFFFFFFFF,
    	col_no_work = 0xFFAA3333
	}
}
local await = {
	members = false,
	next_page = {
		bool = false,
		i = 0
	}
}
local members = {}
local org = {
	name = 'Организация',
	online = 0,
	afk = 0
}
local myforma = false
local dontShowMeMembers = false
local lastDialogWasActive = 0
local script_cursor = false

--> Функции главных настроек
local PlayerSet = {}
function PlayerSet.name()
	if buf_nick.v ~= "" then
		return buf_nick.v
	else
		return u8"Не указаны"
	end
end
function PlayerSet.org()
	return chgName.org[num_org.v+1]
end
function PlayerSet.rank()
	return chgName.rank[num_rank.v+1]
end
function PlayerSet.sex()
	return list_sex[num_sex.v+1]
end
function PlayerSet.dep()
	return list_dep_pref_one[num_dep.v+1]
end
function PlayerSet.depTwo()
	return setdepteg.prefix[num_org.v+14]
end
function PlayerSet.theme()
	return list_theme[num_theme.v+1]
end
function DepTxtEnd(textbox)
	if setdepteg.tegtext_one ~= "" then
		spacetext_one = setdepteg.tegtext_one.." "
	else
		spacetext_one = ""
	end
	if setdepteg.tegtext_two ~= "" then
		if setdepteg.tegpref_two ~= 4 then
			spacetext_two = setdepteg.tegtext_two
		else
			spacetext_two = setdepteg.tegtext_two.." "
		end
	elseif setdepteg.tegpref_one ~= 4 and setdepteg.tegpref_two ~= 4 then
		spacetext_two = " "
	elseif setdepteg.tegpref_one < 5 or setdepteg.tegpref_two < 5 then
		spacetext_two = ""
	end
	if setdepteg.tegtext_three ~= "" then
		spacetext_three = setdepteg.tegtext_three.." "
	elseif setdepteg.tegpref_two < 4 then
		spacetext_three = " "
	else
		spacetext_three = ""
	end
	if setdepteg.tegtext_two == "" and setdepteg.tegtext_three == "" and setdepteg.tegpref_one < 4 and setdepteg.tegpref_two == 4 then
		spacetext_three = " "
	end
	if select_depart == 2 then
		if setdepteg.tegpref_one < 2 then
			if your_tag.v == "" or your_tag.v == nil then
				if setdepteg.tegpref_one == 0 then
					oneteg = "[".. setdepteg.prefix[num_dep3.v + 1] .."]"
				else
					oneteg = setdepteg.prefix[num_dep3.v + 1]
				end
			else
				if setdepteg.tegpref_one == 0 then
					oneteg = "[".. your_tag.v .."]"
				else
					oneteg = your_tag.v
				end
			end
		elseif setdepteg.tegpref_one == 4 then
			oneteg = u8""
		elseif setdepteg.tegpref_one ~= 4 then
			if setdepteg.tegpref_one == 2 then
				if num_rank.v == 10 then
					oneteg = "[".. setdepteg.prefix[23] .."]"
				else
					oneteg = "[".. setdepteg.prefix[num_org.v + 14] .."]"
				end
			else
				if num_rank.v == 10 then
					oneteg = setdepteg.prefix[23]
				else
					oneteg = setdepteg.prefix[num_org.v + 14]
				end
			end
		end
		if setdepteg.tegpref_two < 2 then
			if your_tag.v == "" or your_tag.v == nil then
				if setdepteg.tegpref_two == 0 then
					twoteg = "[".. setdepteg.prefix[num_dep3.v + 1] .."]"
				else
					twoteg = setdepteg.prefix[num_dep3.v + 1]
				end
			else
				if setdepteg.tegpref_two == 0 then
					twoteg = "[".. your_tag.v .."]"
				else
					twoteg = your_tag.v
				end
			end
		elseif setdepteg.tegpref_two == 4 then
			twoteg = u8""
		elseif setdepteg.tegpref_two ~= 4 then
			if setdepteg.tegpref_two == 2 then
				if num_rank.v == 10 then
					twoteg = "[".. setdepteg.prefix[23] .."]"
				else
					twoteg = "[".. setdepteg.prefix[num_org.v + 14] .."]"
				end
			else
				if num_rank.v == 10 then
					twoteg = setdepteg.prefix[23]
				else
					twoteg = setdepteg.prefix[num_org.v + 14]
				end
			end
		end
	else
		if setdepteg.tegpref_one < 2 then
			if setdepteg.tegpref_one == 0 then
				oneteg = "[".. setdepteg.prefix[1] .."]"
			else
				oneteg = setdepteg.prefix[1]
			end
		elseif setdepteg.tegpref_one == 4 then
			oneteg = u8""
		elseif setdepteg.tegpref_one ~= 4 then
			if setdepteg.tegpref_one == 2 then
				oneteg = "[".. setdepteg.prefix[num_org.v + 14] .."]"
			else
				oneteg = setdepteg.prefix[num_org.v + 14]
			end
		end
		if setdepteg.tegpref_two < 2 then
			if setdepteg.tegpref_two == 0 then
				twoteg = "[".. setdepteg.prefix[1] .."]"
			else
				twoteg = setdepteg.prefix[1]
			end
		elseif setdepteg.tegpref_two == 4 then
			twoteg = u8""
		elseif setdepteg.tegpref_two ~= 4 then
			if setdepteg.tegpref_two == 2 then
				twoteg = "[".. setdepteg.prefix[num_org.v + 14] .."]"
			else
				twoteg = setdepteg.prefix[num_org.v + 14]
			end
		end
	end
	textbox = spacetext_one.. oneteg ..spacetext_two.. twoteg ..spacetext_three
	return textbox
end
function DepTxtEndSetting(textbox)
	if chgDepSetD[1].v ~= "" then
		spacetext_oneset = chgDepSetD[1].v.." "
	else
		spacetext_oneset = ""
	end
	if chgDepSetD[2].v ~= "" then
		if num_dep2.v ~= 4 then
			spacetext_twoset = chgDepSetD[2].v
		else
			spacetext_twoset = chgDepSetD[2].v.." "
		end
	elseif num_dep.v ~= 4 and num_dep2.v ~= 4 then
		spacetext_twoset = " "
	elseif num_dep.v < 5 or num_dep2.v < 5 then
		spacetext_twoset = ""
	end
	if chgDepSetD[3].v ~= "" then
		spacetext_threeset = chgDepSetD[3].v.." "
	elseif num_dep2.v < 4 then
		spacetext_threeset = " "
	else
		spacetext_threeset = ""
	end
	if chgDepSetD[2].v == "" and chgDepSetD[3].v == "" and num_dep.v < 4 and num_dep2.v == 4 then
		spacetext_threeset = " "
	end
	if num_dep.v < 2 then
		if num_dep.v == 0 then
			onetegset = "[".. setdepteg.prefix[9] .."]"
		else
			onetegset = setdepteg.prefix[9]
		end
	elseif num_dep.v == 4 then
		onetegset = u8""
	elseif num_dep.v ~= 4 then
		if num_dep.v == 2 then
			if num_rank.v == 10 then
				onetegset = "[".. setdepteg.prefix[23] .."]"
			else
				onetegset = "[".. setdepteg.prefix[num_org.v + 14] .."]"
			end
		else
			if num_rank.v == 10 then
				onetegset = setdepteg.prefix[23]
			else
				onetegset = setdepteg.prefix[num_org.v + 14]
			end
		end
	end
	if num_dep2.v < 2 then
		if num_dep2.v == 0 then
			twotegset = "[".. setdepteg.prefix[9] .."]"
		else
			twotegset = setdepteg.prefix[9]
		end
	elseif num_dep2.v == 4 then
		twotegset = u8""
	elseif num_dep2.v ~= 4 then
		if num_dep2.v == 2 then
			if num_rank.v == 10 then
				twotegset = "[".. setdepteg.prefix[23] .."]"
			else
				twotegset = "[".. setdepteg.prefix[num_org.v + 14] .."]"
			end
		else
			if num_rank.v == 10 then
				twotegset = setdepteg.prefix[23]
			else
				twotegset = setdepteg.prefix[num_org.v + 14]
			end
		end
	end
	textbox = spacetext_oneset.. onetegset ..spacetext_twoset.. twotegset ..spacetext_threeset
	return textbox
end

--> Для биндера
local selected_cmd = 1
local currentKey	= {"",{}}
local cb_RBUT		= imgui.ImBool(false)
local cb_x1		= imgui.ImBool(false)
local cb_x2		= imgui.ImBool(false)
local isHotKeyDefined = false
local p_open = false
local helpd = {}
helpd.exp = imgui.ImBuffer(256)
binder = {
	list = {},
	select_bind,
	edit = false,
	sleep = imgui.ImFloat(0.5),
	name = imgui.ImBuffer(256),
	cmd = imgui.ImBuffer(256),
	text = imgui.ImBuffer(51200),
	key = {}
}
helpd.exp.v =  u8[[
{dialog}
[name]=Выдача мед.карты
[1]=Полностью здоровый
Отыгровка №1
Отыгровка №2
[2]=Имеются отклонения 
Отыгровка №1
Отыгровка №2
{dialogEnd}
]]
helpd.key = {
	{k = "MBUTTON", n = 'Кнопка мыши'},
	{k = "XBUTTON1", n = 'Боковая кнопка мыши 1'},
	{k = "XBUTTON2", n = 'Боковая кнопка мыши 2'},
	{k = "BACK", n = 'Backspace'},
	{k = "SHIFT", n = 'Shift'},
	{k = "CONTROL", n = 'Ctrl'},
	{k = "PAUSE", n = 'Pause'},
	{k = "CAPITAL", n = 'Caps Lock'},
	{k = "SPACE", n = 'Space'},
	{k = "PRIOR", n = 'Page Up'},
	{k = "NEXT", n = 'Page Down'},
	{k = "END", n = 'End'},
	{k = "HOME", n = 'Home'},
	{k = "LEFT", n = 'Стрелка влево'},
	{k = "UP", n = 'Стрелка вверх'},
	{k = "RIGHT", n = 'Стрелка вправо'},
	{k = "DOWN", n = 'Стрелка вниз'},
	{k = "SNAPSHOT", n = 'Print Screen'},
	{k = "INSERT", n = 'Insert'},
	{k = "DELETE", n = 'Delete'},
	{k = "0", n = '0'},
	{k = "1", n = '1'},
	{k = "2", n = '2'},
	{k = "3", n = '3'},
	{k = "4", n = '4'},
	{k = "5", n = '5'},
	{k = "6", n = '6'},
	{k = "7", n = '7'},
	{k = "8", n = '8'},
	{k = "9", n = '9'},
	{k = "A", n = 'A'},
	{k = "B", n = 'B'},
	{k = "C", n = 'C'},
	{k = "D", n = 'D'},
	{k = "E", n = 'E'},
	{k = "F", n = 'F'},
	{k = "G", n = 'G'},
	{k = "H", n = 'H'},
	{k = "I", n = 'I'},
	{k = "J", n = 'J'},
	{k = "K", n = 'K'},
	{k = "L", n = 'L'},
	{k = "M", n = 'M'},
	{k = "N", n = 'N'},
	{k = "O", n = 'O'},
	{k = "P", n = 'P'},
	{k = "Q", n = 'Q'},
	{k = "R", n = 'R'},
	{k = "S", n = 'S'},
	{k = "T", n = 'T'},
	{k = "U", n = 'U'},
	{k = "V", n = 'V'},
	{k = "W", n = 'W'},
	{k = "X", n = 'X'},
	{k = "Y", n = 'Y'},
	{k = "Z", n = 'Z'},
	{k = "NUMPAD0", n = 'Numpad 0'},
	{k = "NUMPAD1", n = 'Numpad 1'},
	{k = "NUMPAD2", n = 'Numpad 2'},
	{k = "NUMPAD3", n = 'Numpad 3'},
	{k = "NUMPAD4", n = 'Numpad 4'},
	{k = "NUMPAD5", n = 'Numpad 5'},
	{k = "NUMPAD6", n = 'Numpad 6'},
	{k = "NUMPAD7", n = 'Numpad 7'},
	{k = "NUMPAD8", n = 'Numpad 8'},
	{k = "NUMPAD9", n = 'Numpad 9'},
	{k = "MULTIPLY", n = 'Numpad *'},
	{k = "ADD", n = 'Numpad +'},
	{k = "SEPARATOR", n = 'Separator'},
	{k = "SUBTRACT", n = 'Numpad -'},
	{k = "DECIMAL", n = 'Numpad .'},
	{k = "DIVIDE", n = 'Numpad /'},
	{k = "F1", n = 'F1'},
	{k = "F2", n = 'F2'},
	{k = "F3", n = 'F3'},
	{k = "F4", n = 'F4'},
	{k = "F5", n = 'F5'},
	{k = "F6", n = 'F6'},
	{k = "F7", n = 'F7'},
	{k = "F8", n = 'F8'},
	{k = "F9", n = 'F9'},
	{k = "F10", n = 'F10'},
	{k = "F11", n = 'F11'},
	{k = "F12", n = 'F12'},
	{k = "F13", n = 'F13'},
	{k = "F14", n = 'F14'},
	{k = "F15", n = 'F15'},
	{k = "F16", n = 'F16'},
	{k = "F17", n = 'F17'},
	{k = "F18", n = 'F18'},
	{k = "F19", n = 'F19'},
	{k = "F20", n = 'F20'},
	{k = "F21", n = 'F21'},
	{k = "F22", n = 'F22'},
	{k = "F23", n = 'F23'},
	{k = "F24", n = 'F24'},
	{k = "LSHIFT", n = 'Левый Shift'},
	{k = "RSHIFT", n = 'Правый Shift'},
	{k = "LCONTROL", n = 'Левый Ctrl'},
	{k = "RCONTROL", n = 'Правый Ctrl'},
	{k = "LMENU", n = 'Левый Alt'},
	{k = "RMENU", n = 'Правый Alt'},
	{k = "OEM_1", n = '; :'},
	{k = "OEM_PLUS", n = '= +'},
	{k = "OEM_MINUS", n = '- _'},
	{k = "OEM_COMMA", n = ', <'},
	{k = "OEM_PERIOD", n = '. >'},
	{k = "OEM_2", n = '/ ?'},
	{k = "OEM_4", n = ' { '},
	{k = "OEM_6", n = ' } '},
	{k = "OEM_5", n = '\\ |'},
	{k = "OEM_8", n = '! §'},
	{k = "OEM_102", n = '> <'}
}
--> Собеседование
local sobes = {
	input = imgui.ImBuffer(256),
	player = {name = "", let = 0, zak = 0, work = "", bl = "", heal = "", narko = 0.1},
	selID = imgui.ImBuffer(4),
	logChat = {},
	nextQ = false,
	num = 0
}

--> Вакцина
local vactimer = {59, 1}
local vaccine_two = false
local vaccine_id

--> Департамент
local dep = {
	list = {"nil", "Все гос. структуры", "nil", "nil", "Собеседование", "[Инфо] - Тех. неполадки","/gov - Новости"},
	sel_all = {u8"Все структуры", u8"Правительство", u8"Центр Лицензирования", u8"Страховая Компания", u8"Центральный банк", u8"Армия ЛС", u8"Армия СФ", u8"ТСР", u8"ФБР", u8"Областная полиция", u8"Полиция ЛС", u8"Полиция СФ", u8"Полиция ЛВ", u8"Больница ЛС", u8"Больница СФ", u8"Больница ЛВ", u8"Больница Джефферсон", u8"СМИ ЛС", u8"СМИ СФ", u8"СМИ ЛВ", u8"Центральный Аппарат", u8"Министерство Обороны", u8"Министерство Здравоохранения", u8"Министерство Юстиции"},
	sel_chp = {u8"Все структуры", u8"Правительство", u8"Центр Лицензирования", u8"Страховая Компания", u8"Центральный банк", u8"Армия ЛС", u8"Армия СФ", u8"ТСР", u8"ФБР", u8"Областная полиция", u8"Полиция ЛС", u8"Полиция СФ", u8"Полиция ЛВ", u8"Больница ЛС", u8"Больница СФ", u8"Больница ЛВ", u8"Больница Джефферсон", u8"СМИ ЛС", u8"СМИ СФ", u8"СМИ ЛВ", u8"Центральный Аппарат", u8"Министерство Обороны", u8"Министерство Здравоохранения", u8"Министерство Юстиции"},
	sel_tsr = {u8"Тюрьма ЛВ", u8"Министр Обороны"},
	sel_mzmomu = {u8"Армия ЛС", u8"ВМС", u8"Тюрьма ЛВ", u8"Полиция ЛС", u8"Полиция СФ", u8"Полиция ЛВ", u8"Областная полиция", u8"ФБР", u8"Министр Обороны", u8"Министр Юстиций"},
	sel = imgui.ImInt(0),
	select_dep = {0, 0},
	input = imgui.ImBuffer(256),
	bool = {false, false, false, false, false, false},
	time = {0,0}, 
	newsN = imgui.ImInt(0),
	news = {},
	dlog = {}
}
prefixDefolt = {u8"ВСЕМ", u8"Пра-во", u8"ГЦЛ", u8"СТК", u8"ЦБ", u8"ЛСа", u8"СФа", u8"ТСР", u8"ФБР", u8"РКШД", u8"ЛСПД", u8"СФПД", u8"ЛВПД", u8"ЛСМЦ", u8"СФМЦ", u8"ЛВМЦ", u8"ЧБЛС", u8"СМИ ЛС", u8"СМИ СФ", u8"СМИ ЛВ", u8"ЦА", u8"МО", u8"МЗ", u8"МЮ"}
trtxt = {}
trtxt = {imgui.ImBuffer(512000), imgui.ImBuffer(512000), imgui.ImBuffer(512000), imgui.ImBuffer(512000), imgui.ImBuffer(512000), imgui.ImBuffer(512000), imgui.ImBuffer(512000)}
--> Вспомогательные для мед. карты
local buf_mcedit = imgui.ImBuffer(51200) 
local error_mce = ""

--> ЧатХуд
local BuffSize = 32
local KeyboardLayoutName = ffi.new("char[?]", BuffSize)
local LocalInfo = ffi.new("char[?]", BuffSize)
local textFont = renderCreateFont("Trebuchet MS", 12, FCR_BORDER + FCR_BOLD)
local fontPing = renderCreateFont("Trebuchet MS", 10, 5)
local pingLog = {}
local musicHUD = imgui.ImBool(false)

lua_thread.create(function()
	while true do
		repeat wait(100) until isSampAvailable()
		repeat wait(100) until sampIsLocalPlayerSpawned()
		wait(1500)
		if sampIsLocalPlayerSpawned() then
			local ping = sampGetPlayerPing(myid)
			table.insert(pingLog, ping)
			if #pingLog == 41 then table.remove(pingLog, 1) end
		end
	end
end)
--> ЧатХуд
local week = {"Воскресенье", "Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота"}
local month = {"Января", "Февраля", "Марта", "Апреля", "Мая", "Июня", "Июля", "Августа", "Сентября", "Октября", "Ноября", "Декабря"}
editKey = false
keysList = {}
arep = false
newversion = ""
updinfo = ""
needSave = false
urlupd = ""
vacplayer = {"Error_nickname", "2"}
local BlockKeys = {{vkeys.VK_T}, {vkeys.VK_F6}, {vkeys.VK_F8}, {vkeys.VK_RETURN}, {vkeys.VK_OEM_3}, {vkeys.VK_LWIN}, {vkeys.VK_RWIN}}

rkeys.isBlockedHotKey = function(keys)
	local bool, hkId = false, -1
	for k, v in pairs(BlockKeys) do
	   if rkeys.isHotKeyHotKey(keys, v) then
		  bool = true
		  hkId = k
		  break
	   end
	end
	return bool, hkId
end

function rkeys.isHotKeyExist(keys)
local bool = false
	for i,v in ipairs(keysList) do
		if table.concat(v,"+") == table.concat(keys, "+") then
			if #keys ~= 0 then
				bool = true
				break
			end
		end
	end
	return bool
end

function unRegisterHotKey(keys)
	for i,v in ipairs(keysList) do
		if v == keys then
			keysList[i] = nil
			break
		end
	end
	local listRes = {}
	for i,v in ipairs(keysList) do
		if #v > 0 then
			listRes[#listRes+1] = v
		end
	end
	keysList = listRes
end

function urlencode(str)
   if (str) then
      str = string.gsub (str, "\n", "\r\n")
      str = string.gsub (str, "([^%w ])",
         function (c) return string.format ("%%%02X", string.byte(c)) end)
      str = string.gsub (str, " ", "+")
   end
   return str
end

--> Музыка собственной разработки и её функции на основе либа bass.
-- Я запрещаю копирование вкладки "Музыка" без моего уведомления об этом. --

local stream_music
local site_link = 'ru.apporange.space'
local selectis = 0
local menu_play_track = {false, false, false}
local status_track_pl = "STOP"
local player_HUD = imgui.ImBool(true)
local volume_music = imgui.ImFloat(1.0)
local buf_find_music = imgui.ImBuffer(256)
local repeatmusic = imgui.ImBool(false)
local trackplaysave = false
local sel_menu_set = 1
local select_music = 0
local select_menu_music = 1
local timetr = {0, 0}
local track_time_hc = 0
local url_track_pack
local anim_hud_tr = {1, 6, 3}
local active_anim_hud = {true, false, true}
local sectime_track = imgui.ImFloat(1.0)
local Y_rewind = 5
local record_text_name = {'Record Dance', 'Megamix', 'Party 24/7', 'Phonk', 'Гоп FM', 'Руки Вверх', 'Dubstep', 'Big Hits', 'Organic', 'Russian Hits'}
local tracks = {
	link = {},
	artist = {},
	name = {},
	time = {},
	image = {}
}
local save_tracks = {
	link = {},
	artist = {},
	name = {},
	time = {},
	image = {}
}

function rewind_song(time_position) --> Перемотка трека на указанную позицию (позиция трека в секундах)
	if status_track_pl ~= "STOP" and not menu_play_track[3] and get_status_potok_song() ~= 0 then
		local length = bass.BASS_ChannelGetLength(stream_music, BASS_POS_BYTE)
		length = tostring(length)
		length = length:gsub("(%D+)", "")
		length = tonumber(length)
		local poslt = ((length/track_time_hc) * time_position) - 100
		bass.BASS_ChannelSetPosition(stream_music, poslt, BASS_POS_BYTE)
		local time_song = 0
		time_song = time_song_position(track_time_hc)
		time_song = round(time_song, 1)
		timetr[1] = time_song % 60
		timetr[2] = math.floor(time_song / 60)
	end
end

function time_song_position(song_length) --> Получить позицию трека в секундах
	song_length = tonumber(song_length)
	local posByte = bass.BASS_ChannelGetPosition(stream_music, BASS_POS_BYTE)
	posByte = tostring(posByte)
	posByte = posByte:gsub("(%D+)", "")
	posByte = tonumber(posByte)
	local length = bass.BASS_ChannelGetLength(stream_music, BASS_POS_BYTE)
	length = tostring(length)
	length = length:gsub("(%D+)", "")
	length = tonumber(length)
	local postrack = posByte / (length / song_length)
	
	return postrack
end

function get_status_potok_song() --> Получить статус потока
	local status_potok
	if stream_music ~= nil then
		status_potok = bass.BASS_ChannelIsActive(stream_music)
		status_potok = tonumber(status_potok)
	else
		status_potok = 0
	end
	return status_potok
	--[[
	[0] - Ничего не воспроизводится
	[1] - Играет
	[2] - Блок
	[3] - Пауза
	--]]
end

function get_track_length() --> Получить длину трека в секундах
	local len_song = 0
	if menu_play_track[1] or menu_play_track[2] then
		local min_tr = 0
		local sec_tr = 0
		if menu_play_track[1] then
			min_tr = tracks.time[selectis]:gsub(':(.+)', '')
			sec_tr = tracks.time[selectis]:gsub('(.+):', '')
		else
			min_tr = save_tracks.time[selectis]:gsub(':(.+)', '')
			sec_tr = save_tracks.time[selectis]:gsub('(.+):', '')
		end
		min_tr = tonumber(min_tr)
		sec_tr = tonumber(sec_tr)
		len_song = (min_tr * 60) + sec_tr
	end
	
	return len_song
end

function play_song(url_track, loop_track) --> Включить песню
	imgNoLabel = imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/nolabel.png")
	timetr = {0, 0}
	track_time_hc = 0
	status_track_pl = "PLAY"
	url_track_pack = url_track
	if menu_play_track[1] or menu_play_track[2] then
		select_music = 0
		if menu_play_track[1] then
			local tri = tracks.time[selectis]:gsub(":(.+)$", "")
			local tri2 = tracks.time[selectis]:gsub("^(.+):", "")
			timetri = 400/((tonumber(tri)*60)+tonumber(tri2))
		else
			local tri = save_tracks.time[selectis]:gsub(":(.+)$", "")
			local tri2 = save_tracks.time[selectis]:gsub("^(.+):", "")
			timetri = 400/((tonumber(tri)*60)+tonumber(tri2))
		end
		track_time_hc = get_track_length()
	end
	if get_status_potok_song() ~= 0 then
		bass.BASS_ChannelStop(stream_music)
	end
	stream_music = bass.BASS_StreamCreateURL(url_track, 0, BASS_STREAM_AUTOFREE, nil, nil)
	if loop_track ~= true then
		bass.BASS_ChannelPlay(stream_music, false)
	elseif loop_track == true then
		bass.BASS_ChannelPlay(stream_music, BASS_SAMPLE_LOOP)
	end
	bass.BASS_ChannelSetAttribute(stream_music, BASS_ATTRIB_VOL, volume_music.v)
	if menu_play_track[1] then
		download_id = downloadUrlToFile(tracks.image[selectis], getWorkingDirectory().."/MedicalHelper/label.png", function(id, status, p1, p2)
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then
				statusimage = selectis
				imgLabel = imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/label.png")
			end
		end)
	elseif menu_play_track[2] then
		download_id = downloadUrlToFile(save_tracks.image[selectis], getWorkingDirectory().."/MedicalHelper/label.png", function(id, status, p1, p2)
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then
				statusimage = selectis
				imgLabel = imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/label.png")
			end
		end)
	end
end

function action_song(action_music) --> Остановить/Пауза/Продолжить
	if stream_music ~= nil and get_status_potok_song() ~= 0 then
		if action_music == "PLAY" then
			status_track_pl = 'PLAY'
			bass.BASS_ChannelPlay(stream_music, false)
		elseif action_music == "PAUSE" then
			status_track_pl = 'PAUSE'
			bass.BASS_ChannelPause(stream_music)
		elseif action_music == "STOP" then
			selectis = 0
			select_music = 0
			menu_play_track = {false, false, false}
			status_track_pl = 'STOP'
			bass.BASS_ChannelStop(stream_music)
		end
	end
end

function volume_song(volume_music) --> Установить громкость песни
	if stream_music ~= nil and get_status_potok_song() ~= 0 then
		bass.BASS_ChannelSetAttribute(stream_music, BASS_ATTRIB_VOL, volume_music)
	end
end

function find_track_link(search_text) --> Поиск песни в интернете
	asyncHttpRequest('GET', 'https://'..site_link..'/search?q='..urlencode(u8(u8:decode(search_text))), nil,
		function(response)
			for link in string.gmatch(u8:decode(response.text), 'По вашему запросу ничего не найдено') do
				tracks.link[1] = 'Ошибка404'
				tracks.artist[1] = 'Ошибка404'
			end
			for link in string.gmatch(u8:decode(response.text), 'href="(.-)" class=') do
				if link:find('https://'..site_link..'/get/music/') then
					track = link:match('(.+).mp3')
					tracks.link[#tracks.link + 1] = track..'.mp3'
				end
			end
			for link in string.gmatch(u8:decode(response.text), '"track%_%_title"%>(.-)%</div') do
				if link:find('(.+)') then
					nametrack = link:match('(.+)')
					nametrack = nametrack:gsub('^%s+', '')
					tracks.name[#tracks.name + 1] = nametrack:gsub('%s+$', '')
				end
			end
			for link in string.gmatch(u8:decode(response.text), '"track%_%_desc"%>(.-)%</div') do
				if link:find('(.+)') then
					tracks.artist[#tracks.artist + 1] = link:match('(.+)')
				end
			end
			for link in string.gmatch(u8:decode(response.text), '"track%_%_fulltime"%>(.-)%</div') do
				if link:find('(.+)') then
					tracks.time[#tracks.time + 1] = link:match('(.+)')
				end
			end
			for link in string.gmatch(u8:decode(response.text), '"track%_%_img" style="background%-image: url%(\'(.-)\'%)%;"%>%</div%>') do
				if link:find('(.+)') then
					tracks.image[#tracks.image + 1] = 'https://'..site_link..link:match('(.+)')
				end
			end
		end,
		function(err)
		print(err)
	end)
end

--> Для редактора отыгровок
local acting_buf = {}
local arg_options = {u8"Числовой аргумент", u8"Текстовый аргумент"}
local type_options = {u8"Отправить в чат", u8"Ожидание нажатия Enter", u8"Диалог выбора действия", u8"Информация в чат", u8"Изменить переменную"}
local acting = {
	[5] = {
		argfunc = true,
		arg = {{0, u8"id игрока"}},
		varfunc = false,
		var = {},
		chatopen = false,
		typeAct = {{0, u8"/do Медицинская сумка весит на левом плече."}, {0, u8"/me открыл{sex:|а} медицинскую сумку и тут же нащупал{sex:|а} в ней необходимое лекарство"}, {0, u8"/me достав препарат из сумки, после чего передал{sex:|а} его человеку напротив"}, 
		{0, u8"/heal {arg1} {pricelec}"}, {0, u8"/todo Вот, держите, хорошего Вам дня!*закрывая сумку"}},
		sec = 2.0
	},
	[7] = {
		argfunc = true,
		arg = {{0, u8"id игрока"}},
		varfunc = true,
		var = {u8"0", u8"0", u8"0", u8"0", u8"0", u8"0", u8"0"},
		chatopen = false,
		typeAct = {{0, u8"Вам необходимо получить новую медицинскую карту или обновить имеющуюся?"}, {0, u8"Для оформления медицинской карты предоставьте, пожалуйста, Ваш паспорт."}, {0, u8'/b Для этого введите /showpass {myID}'}, {1, u8""}, {0, u8"/me взял{sex:|а} паспорт из рук пациента и внимательно изучил{sex:|а} его"}, {2, {u8"Новая мед. карта", u8"Обновить мед. карту"}}, {0, u8"{dialog1}Стоимость оформления новой мед. карты зависит от её срока."}, {0, u8"{dialog1}7 дней: {med7}$. 14 дней: {med14}$"}, {0, u8"{dialog1}30 дней: {med30}$. 60 дней: {med60}$"}, {4, 0, u8"{med7}"}, {4, 1, u8"{med14}"}, {4, 2, u8"{med30}"}, {4, 3, u8"{med60}"}, {0, u8"{dialog2}Стоимость обновления мед. карты зависит от её срока."}, {0, u8"{dialog2}7 дней: {medup7}$. 14 дней: {medup14}$"}, {0, u8"{dialog2}30 дней: {medup30}$. 60 дней: {medup60}$"}, {4, 0, u8"{medup7}"}, {4, 1, u8"{medup14}"}, {4, 2, u8"{medup30}"}, {4, 3, u8"{medup60}"},
		{0, u8"/n Оплачивать ничего не нужно, система сама предложит."}, {0, u8"На какой срок желаете оформить?"}, {2, {u8"7 дней", u8"14 дней", u8"30 дней", u8"60 дней"}}, {0, u8"{dialog1}"}, {4, 4, u8"{var1}"}, {4, 5, u8"0"}, {0, u8"{dialog2}"}, {4, 4, u8"{var2}"}, {4, 5, u8"1"}, {0, u8"{dialog3}"}, {4, 4, u8"{var3}"}, {4, 5, u8"2"}, {0, u8"{dialog4}"}, {4, 4, u8"{var4}"}, {4, 5, u8"3"}, {0, u8"Хорошо, сейчас задам пару вопросов, отвечайте чесно."}, {0, u8"Вы можете видеть имена проходящих мимо Вас людей?"}, {1, u8""}, {0, u8"Вас когда-нибудь убивали?"}, {2, {u8"Полностью здоров", u8"Наблюдаются отклонения", u8"Психически не здоров", u8"Не определён"}}, 
		{0, u8"{dialog1}"}, {4, 6, u8"3"}, {0, u8"{dialog2}"}, {4, 6, u8"2"}, {0, u8"{dialog3}"}, {4, 6, u8"1"}, {0, u8"{dialog4}"}, {4, 6, u8"0"},
		{0, u8"/me берёт в правую руку из мед. кейса печать и наносит штамп в углу бланка"}, {0, u8"/do Печать больницы нанесена на бланк."}, {0, u8"/me кладёт печать в мед. кейс, после чего ручкой ставит подпись и сегодняшнюю дату"}, {0, u8"/do Страница мединцинской карты полностью заполнена."}, {0, u8"/me передаёт медицинскую карту в руки обратившемуся"},
		{0, u8"/medcard {arg1} {var7} {var6} {var5}"}},
		sec = 2.0
	},
	[8] = {
		argfunc = true,
		arg = {{0, u8"id игрока"}},
		varfunc = false,
		var = {},
		chatopen = false,
		typeAct = {{0, u8"Очень замечательно, что Вы решили излечиться от наркозависимости."}, {0, u8"Стоимость одного сеанса составит {pricenarko}$"}, {0, u8'Метод лечения современный, называется "Нейроочищение". Он полностью сотрёт информацию о наркотиках с Вашего мозга.'}, 
		{0, u8"Вы согласны? Если да, то ложитесь на кушетку и мы приступим."}, {1, u8""}, {0, u8"/do На столе лежат стерильные перчатки и медицинская маска."}, {0, u8"/me взяв со стола средства индивидуальной защиты, надел{sex:|а} их на себя"}, {0, u8"/todo А теперь максимально расслабьтесь*подвигая спец. аппарат ближе к пациенту"}, {0, u8"/me взял{sex:|а} шлем от аппарата, после чего надел{sex:|а} его на голову пациента"}, {0, u8"/me включил{sex:|а} устройство, затем, подождав пять секунд, выключил{sex:|а} его"},
		{0, u8"/do Аппарат успешно завершил работу."}, {0, u8"/me снял{sex:|а} шлем с пациента и повесил{sex:|а} его обратно на аппарат"}, {0, u8"/healbad {arg1}"}, {0, u8"/todo Вот и всё! Тяга к запрещённым веществам должна исчезнуть*снимая с себя маску с перчатками"}},
		sec = 2.0
	},
	[9] = {
		argfunc = true,
		arg = {{0, u8"id игрока"}},
		varfunc = true,
		var = {u8"1"},
		chatopen = false,
		typeAct = {{0, u8"Мы выписываем рецепты в ограниченном количестве."}, {0, u8"/n Не более 5 штук в минуту."}, {0, u8"Стоимость одного рецепта составляет {pricerecept}$"}, {0, u8"Вы согласны? Если да, то какое количество Вам необходимо?"}, {3, u8"Выберите количество выдаваемых рецептов."}, {2, {u8"1 рецепт", u8"2 рецепта", u8"3 рецепта", u8"4 рецепта", u8"5 рецептов"}}, {0, u8"{dialog1}"}, {4, 0, u8"1"}, {0, u8"{dialog2}"}, {4, 0, u8"2"}, {0, u8"{dialog3}"}, {4, 0, u8"3"}, {0, u8"{dialog4}"}, {4, 0, u8"4"}, {0, u8"{dialog5}"}, {4, 0, u8"5"},
		{0, u8"/do На столе лежат бланки для оформления рецептов."},{0, u8"/me взяв ручку с печатью, заполнил{sex:|а} необходимые бланки, после чего поставил{sex:|а} печати в углу листа"}, {0, u8"/do Все бланки рецептов успешно заполнены."}, {0, u8"/todo Держите и строго соблюдайте инструкцию!*передавая рецепты человеку напротив"}, {0, u8"/recept {arg1} {var1}"}},
		sec = 2.0
	},
	[10] = {
		argfunc = false,
		arg = {},
		varfunc = false,
		var = {},
		chatopen = false,
		typeAct = {{0, u8"Сейчас я проведу для Вас небольшое мед. обследование."}, {0, u8"Пожалуйста, предоставьте Вашу мед. карту."}, {1, u8""}, {0, u8"/me взял{sex:|а} мед. карту из рук человека"}, {0, u8"/do Медицинская карта и ручка с печатью в руках."}, {0, u8"Итак, сейчас я задам некоторые вопросы для оценки состояния здоровья."},{0, u8"Давно ли Вы болели? Если да, то какими болезнями?"}, 
		{1, u8""}, {0, u8"Были ли у Вас травмы?"}, {1, u8""}, {0, u8"Имеются ли какие-то аллергические реакции?"}, {1, u8""}, {0, u8"/me сделал{sex:|а} записи в мед. карте"}, {0, u8"Так, откройте рот."}, {0, u8"/b /me открыл(а) рот"}, {1, u8""}, 
		{0, u8"/do В кармане фонарик."}, {0, u8"/me достал{sex:|а} фонарик из кармана, после чего включил{sex:|а} его"}, {0, u8"/me осмотрел{sex:|а} горло пациента"}, {0, u8"Можете закрыть рот."}, {0, u8"/me проверил{sex:|а} реакцию зрачков пациента на свет, посветив в глаза"}, 
		{0, u8"/do Зрачоки глаз обследуемого сузились."}, {0, u8"/me выключил{sex:|а} фонарик и убрал{sex:|а} его в карман"}, {0, u8"Присядьте, пожалуйста, на корточки и коснитесь кончиком пальца до носа."}, {1, u8""}, {0, u8"Вставайте."}, {0, u8"/me сделал{sex:|а} записи в медицинской карте"}, {0, u8"/me вернул{sex:|а} мед. карту человеку напротив"}, {0, u8"Спасибо, можете быть свободны."}},
		sec = 2.0
	},
	[13] = {
		argfunc = true,
		arg = {{0, u8"id игрока"}},
		varfunc = false,
		var = {},
		chatopen = false,
		typeAct = {{0, u8"Сейчас мы начнём сеанс по выведению татуировки с Вашего тела."}, {0, u8"Покажите Ваш паспорт, пожалуйста."}, {1, u8""}, {0, u8"/me принял{sex:|а} с рук обратившегося паспорт"}, 
		{0, u8"/do Паспорт обратившегося в правой руке."}, {0, u8"/me ознакомившись с паспортом, вернул{sex:|а} его обратно владельцу"}, {0, u8"Стоимость выведения татуировки составит {pricetatu}$. Вы согласны?"}, 
		{0, u8"/n Оплачивать не требуется, сервер сам предложит."}, {0, u8"/b Покажите татуировки с помощью команды /showtatu"}, {1, u8""}, {0, u8"Я смотрю, Вы готовы, тогда снимайте с себя рубашку, чтобы я вывел{sex:|а} Вашу татуировку."},
		{0, u8"/do У стены стоит инструментальный столик с подносом."}, {0, u8"/do Аппарат для выведения тату на подносе."}, {0, u8"/me взял{sex:|а} аппарат для выведения татуировки с подноса"}, {0, u8"/me осмотрев пациента, принял{sex:ся|лась} выводить его татуировку"}, {0, u8"/unstuff {arg1} {pricetatu}"}},
		sec = 2.0
	},
	[14] = {
		argfunc = true,
		arg = {{0, u8"id игрока"}, {1, u8"Причина"}},
		varfunc = false,
		var = {},
		chatopen = false,
		typeAct = {{0, u8"/do В левом кармане лежит телефон."}, {0, u8"/me достал{sex:|а} телефон из кармана, после чего {sex:зашел|зашла} в базу данных {myHospEn}"}, {0, u8"/me изменил{sex:|а} информацию о сотруднике {namePlayerRus[{arg1}]}"}, {0, u8"/fwarn {arg1} {arg2}"}, {0, u8"/r {namePlayerRus[{arg1}]} получил строгий выговор! Причина: {arg2}"}},
		sec = 2.0
	},
	[15] = {
		argfunc = true,
		arg = {{0, u8"id игрока"}},
		varfunc = false,
		var = {},
		chatopen = false,
		typeAct = {{0, u8"/do В левом кармане лежит телефон."}, {0, u8"/me достал{sex:|а} телефон из кармана, после чего {sex:зашел|зашла} в базу данных {myHospEn}"}, {0, u8"/me изменил{sex:|а} информацию о сотруднике {namePlayerRus[{arg1}]}"}, {0, u8"/unfwarn {arg1}"}, {0, u8"/r Сотруднику {namePlayerRus[{arg1}]} снят строгий выговор!"}},
		sec = 2.0
	},
	[16] = {
		argfunc = true,
		arg = {{0, u8"id игрока"}, {0, u8"Время заглушки в минутах"}, {1, u8"Причина"}},
		varfunc = false,
		var = {},
		chatopen = false,
		typeAct = {{0, u8"/do Рация весит на поясе."}, {0, u8"/me снял{sex:|а} рацию с пояса, после чего {sex:зашел|зашла} в настройки локальных частот вещания"}, {0, u8"/me заглушил{sex:|а} локальную частоту вещания сотруднику {namePlayerRus[{arg1}]}"}, {0, u8"/fmute {arg1} {arg2} {arg3}"}, {0, u8"/r Сотруднику {namePlayerRus[{arg1}]} была отключена рация. Причина: {arg3}"}, {0, u8"/me повесил{sex:|а} рацию обратно на пояс"}},
		sec = 2.0
	},
	[17] = {
		argfunc = true,
		arg = {{0, u8"id игрока"}},
		varfunc = false,
		var = {},
		chatopen = false,
		typeAct = {{0, u8"/do Рация весит на поясе."}, {0, u8"/me снял{sex:|а} рацию с пояса, после чего {sex:зашел|зашла} в настройки локальных частот вещания"}, {0, u8"/me освободил{sex:|а} локальную частоту вещания сотруднику {namePlayerRus[{arg1}]}"}, {0, u8"/funmute {arg1}"}, {0, u8"/r Сотруднику {namePlayerRus[{arg1}]} снова включена рация!"}, {0, u8"/me повесил{sex:|а} рацию обратно на пояс"}},
		sec = 2.0
	},
	[18] = {
		argfunc = true,
		arg = {{0, u8"id игрока"}, {0, u8"Номер ранга"}},
		varfunc = false,
		var = {},
		chatopen = false,
		typeAct = {{0, u8"/do В кармане халата находится футляр с ключами от шкафчиков с формой."}, {0, u8"/me потянувшись во внутренний карман халата, достал{sex:|а} оттуда футляр"}, {0, u8"/me открыв футляр, достал{sex:|а} оттуда ключ от шкафчика с формой"}, {0, u8"/me передал{sex:|а} ключ от шкафчика человеку напротив"}, {0, u8"/giverank {arg1} {arg2}"}, {0, u8"/r Сотрудник {namePlayerRus[{arg1}]} получил новую должность. Поздравляем!"}},
		sec = 2.0
	},
	[19] = {
		argfunc = true,
		arg = {{0, u8"id игрока"}},
		varfunc = false,
		var = {},
		chatopen = false,
		typeAct = {{0, u8"/do В кармане халата находятся ключи от шкафчика."}, {0, u8"/me потянувшись во внутренний карман халата, достал{sex:|а} оттуда ключ"}, {0, u8"/me передал{sex:|а} ключ от шкафчика с формой Интерна человеку напротив"}, {0, u8"/invite {arg1}"}, {0, u8"/r Приветствуем нового сотрудника нашей организации - {namePlayerRus[{arg1}]}"}},
		sec = 2.0
	},
	[20] = {
		argfunc = true,
		arg = {{0, u8"id игрока"}, {1, u8"Причина"}},
		varfunc = false,
		var = {},
		chatopen = false,
		typeAct = {{0, u8"/do В левом кармане лежит телефон."}, {0, u8"/me достал{sex:|а} телефон из кармана, после чего {sex:зашел|зашла} в базу данных {myHospEn}"}, {0, u8"/me изменил{sex:|а} информацию о сотруднике {namePlayerRus[{arg1}]}"}, {0, u8"/uninvite {arg1} {arg2}"}, {0, u8"/r Сотрудник {namePlayerRus[{arg1}]} был уволен из организации. Причина: {arg2}"}},
		sec = 2.0
	},
	[22] = {
		argfunc = true,
		arg = {{0, u8"id игрока"}, {1, u8"Причина"}},
		varfunc = false,
		var = {},
		chatopen = false,
		typeAct = {{0, u8"/me резким движением руки ухватил{sex:ась|ся} за воротник нарушителя"}, {0, u8"/do Крепко держит нарушителя за воротник."}, {0, u8"/todo Я вынужден{sex:|а} вывести вас из здания*направляясь к выходу."}, {0, u8"/me движением левой руки открыл{sex:|а} входную дверь, после чего вытолкнул{sex:|а} нарушителя"}, {0, u8"/expel {arg1} {arg2}"}},
		sec = 2.0
	},
	[23] = {
		argfunc = true,
		arg = {{0, u8"id игрока"}},
		varfunc = false,
		var = {},
		chatopen = false,
		typeAct = {{3, u8"Вакцина первая или вторая?"}, {2, {u8"Первая вакцина", u8"Вторая вакцина"}},
		{0, u8"{dialog1}Очень хорошо, что Вы решили вакцинироваться."}, {0, u8"{dialog1}Стоимость всего сеанса вакцинации составляет 600.000$. Вы согласны?"}, {0, u8"{dialog1}Если да, то присаживайтесь на кушетку и мы приступим."}, {1, u8""}, 
		{0, u8'{dialog1}/do На столе лежит шприц и баночка с надписью "BioNTech".'}, {0, u8"{dialog1}/me взяв баночку со шприцом, приступил{sex:|а} к закачке в неё жидкости"}, {0, u8"{dialog1}/do Жидкость в шприце."}, {0, u8"{dialog1}/me достал{sex:|а} из под стола ватку со спиртом и аккуратно протёр{sex:|ла} будущее место укола"}, {0, u8"{dialog1}/do Место для укола продезинфицировано."}, {0, u8"{dialog1}/me выбросив ватку, резко воткнул{sex:|а} в мышцу шприц и высадил{sex:|а} всю содержащуюся жидкость"}, {0, u8"{dialog1}/me выбросил{sex:|а} шприц в мусорное ведро и приложил{sex:|а} к телу пациента стерильную ватку"}, {0, u8"{dialog1}/vaccine {arg1}"}, {0, u8"{dialog1}/n Ждём две минуты до второй вакцины. Никуда не уходите, иначе статус первой пропадёт."},
		{0, u8'{dialog2}/do На столе лежит шприц и баночка с надписью "BioNTech".'}, {0, u8"{dialog2}/me взяв баночку со шприцом, приступил{sex:|а} к закачке в неё жидкости"}, {0, u8"{dialog2}/do Жидкость в шприце."}, {0, u8"{dialog2}/me достал{sex:|а} из под стола ватку со спиртом и аккуратно протёр{sex:|ла} будущее место укола"}, {0, u8"{dialog2}/do Место для укола продезинфицировано."}, {0, u8"{dialog2}/me выбросив ватку, резко воткнул{sex:|а} в мышцу шприц и высадил{sex:|а} всю содержащуюся жидкость"}, {0, u8"{dialog2}/me выбросил{sex:|а} шприц в мусорное ведро и приложил{sex:|а} к телу пациента стерильную ватку"}, {0, u8"{dialog2}/vaccine {arg1}"}},
		sec = 2.0
	},
	[25] = {
		argfunc = false,
		arg = {},
		varfunc = false,
		var = {},
		chatopen = false,
		typeAct = {{0, u8"Пройдёмте за мной."}},
		sec = 2.0
	},
	[26] = {
		argfunc = false,
		arg = {},
		varfunc = false,
		var = {},
		chatopen = false,
		typeAct = {{0, u8"Здравствуйте, меня зовут {myRusNick}, чем могу помочь?"}},
		sec = 2.0
	},
	[27] = {
		argfunc = true,
		arg = {{0, u8"id игрока"}},
		varfunc = false,
		var = {},
		chatopen = true,
		typeAct = {{0, u8"Насколько я понял{sex:|а}, Вам нужны антибиотики."}, {0, u8"Стоимость одного антибиотика составляет {priceant}$. Вы согласны?"}, {0, u8"Если да, то какое количество Вам необходимо?"}, 
		{3, u8"Ожидайте ответа о количестве от пациента."}, {1, u8""}, {0, u8"/me открыв мед.сумку, схватил{sex:ась|ся} за пачку антибиотиков, после чего вытянул{sex:|а} их и положил на стол"}, {0, u8"/do Антибиотики находятся на столе."}, {0, u8"/todo Вот держите, употребляйте их строго по рецепту!*закрывая мед. сумку"}, {3, u8"Введите количество антибиотиков в чат."}, {0, u8"/antibiotik {arg1} "}},
		sec = 2.0
	},
	[28] = {
		argfunc = true,
		arg = {{0, u8"id игрока"}},
		varfunc = false,
		var = {},
		chatopen = false,
		typeAct = {{0, u8"Насколько я понял, Вам нужна медицинская страховка?"}, {0, u8"Предоставьте, пожалуйста, Вашу мед. карту."}, {0, u8"/b /showmc {myID}"}, {1, u8""}, {0, u8"/todo Благодарю Вас!*взяв мед. карту в руки и начав её изучать."}, {0, u8"Для оформления медицинской страховки необходимо заплатить гос. пошлину, которая зависит от срока."}, {0, u8"На 1 неделю - 4ОО.ООО$. На 2 недели - 8ОО.ООО$. На 3 недели - 1.2ОО.ООО$"}, {0, u8"На какой срок оформляем?"}, {1, u8""}, 
		{0, u8"Хорошо, тогда приступим к оформлению."}, {0, u8"/me вытащил{sex:|а} из нагрудного кармана шариковую ручку"}, {0, u8"/me открыл{sex:|а} шкафчик, затем достал{sex:|а} оттуда пустые бланки"}, {0, u8"/me разложил{sex:|а} пальцами правой руки мед. карту на нужной страничке и начал{sex:|а} переписывать данные в бланк"}, {0, u8"/me взял{sex:|а} штамп в правую руку из ящика стола и {sex:нанес|ненесла} оттиск в углу бланка"}, {0, u8"/do Печать нанесена."},
		{0, u8"/me отложив штамп в сторону, поставил{sex:|а} свою подпись и сегодняшнюю дату"}, {0, u8"/do Бланк успешно заполнен."}, {0, u8"Всё готово, держите свою медицинскую страховку. Удачного дня!"}, {0, u8"/givemedinsurance {arg1}"}},
		sec = 2.0
	},
	[29] = {
		argfunc = true,
		arg = {{0, u8"id игрока"}},
		varfunc = false,
		var = {},
		chatopen = false,
		typeAct = {{0, u8"Не волнуйтесь, сейчас я окажу Вам экстренную помощь!"}, {0, u8"/me легким движением пальца прислонил{sex:|а} к шее пациента, после чего начал{sex:|а} измерять пульс"}, {0, u8"/do У пациента отсутствует пульс."}, {0, u8"/todo Нужно быстро принять меры!*посмотрев на мед. сумку"}, {0, u8"/me легким движением руки открыл{sex:|а} мед. сумку, после чего достал{sex:|а} платок"}, 
		{0, u8"/me аккуратно приложил{sex:|а} платок ко рту пострадавшего, после чего сделал{sex:|а} глубокий вдох"}, {0, u8"/do В лёгких много воздуха."}, {0, u8"/me встал{sex:|а} на колени, после чего прислонил{sex:ся|ась} к пациенту"}, {0, u8"/me {sex:подвел|подвела} губы ко рту пострадавшего, после чего начал{sex:|а} делать искусственное дыхание"}, 
		{0, u8"/me отвел{sex:|а} губы от рта пострадавшего, после чего сделал{sex:|а} глубокий вдох"}, {0, u8"/me подвел{sex:|а} губы ко рту пострадавшего, после чего начал{sex:|а} делать искусственное дыхание"}, {0, u8"/do Пациент очнулся."}, {0, u8"/cure {arg1}"}},
		sec = 2.0
	},
	[34] = {
		argfunc = true,
		arg = {{0, u8"id игрока"}},
		varfunc = false,
		var = {},
		chatopen = false,
		typeAct = {{2, {u8"Показать паспорт", u8"Показать мед. карту", u8"Показать лицензии"}}, {0, u8"{dialog1}/do Паспорт гражданина находится в заднем кармане."}, {0, u8"{dialog1}/me засунув руку в карман, достал{sex:|а} паспорт, после чего передал{sex:|а} его человеку напротив"}, {0, u8"{dialog1}/showpass {arg1}"}, 
		{0, u8"{dialog2}/do Медицинская карта находится в нагрудном кармане."}, {0, u8"{dialog2}/me засунув руку в карман, достал{sex:|а} мед. карту, после чего передал{sex:|а} её человеку напротив"}, {0, u8"{dialog2}/showmc {arg1}"}, 
		{0, u8"{dialog3}/do Пакет лицензий находится в нагрудном кармане."}, {0, u8"{dialog3}/me засунув руку в карман, достал{sex:|а} лицензии, после чего передал{sex:|а} их человеку напротив"}, {0, u8"{dialog3}/showlic {arg1}"}},
		sec = 2.0
	},
	[35] = {
		argfunc = true,
		arg = {},
		varfunc = false,
		var = {},
		chatopen = false,
		typeAct = {{2, {u8"Включить камеру", u8"Выключить камеру"}}, {0, u8"{dialog1}/do Телефон находится в левом кармане."}, {0, u8'{dialog1}/me засунув руку в карман, достал{sex:|а} оттуда телефон, после чего заш{sex:ел|ла} в приложение "Камера"'}, {0, u8"{dialog1}/me нажав на кнопку записи, приступил{sex:|а} к съёмке происходящего"}, {0, u8"{dialog1}/do Камера смартфона начала записывать видео и звук."}, 
		{0, u8"{dialog2}/do Телефон находится в руке и ведёт запись."}, {0, u8"{dialog2}/me нажал{sex:|а} на кнопку отключения записи, после чего убрал{sex:|а} телефон в задний карман"}, {0, u8"{dialog2}/do Видеофиксация происходящего приостановлена."}},
		sec = 2.0
	},
	[36] = {
		argfunc = true,
		arg = {},
		varfunc = false,
		var = {},
		chatopen = true,
		typeAct = {{0, u8"Насколько я понял{sex:|а}, Вам нужны антибиотики."}, {0, u8"Стоимость одного антибиотика составляет {priceant}$. Вы согласны?"}, {0, u8"Если да, то какое количество Вам необходимо?"}, 
		{3, u8"Ожидайте ответа о количестве от пациента."}, {1, u8""}, {0, u8"/me открыв мед.сумку, схватил{sex:ась|ся} за пачку антибиотиков, после чего вытянул{sex:|а} их и положил на стол"}, {0, u8"/do Антибиотики находятся на столе."}, {0, u8"/todo Вот держите, употребляйте их строго по рецепту!*закрывая мед. сумку"}, {3, u8"Введите количество антибиотиков в чат."}, {0, u8"/antibiotik {arg1} "}},
		sec = 2.0
	}
}
local acting_defoult = {
	[5] = {
		argfunc = true,
		arg = {{0, u8"id игрока"}},
		varfunc = false,
		var = {},
		chatopen = false,
		typeAct = {{0, u8"/do Медицинская сумка весит на левом плече."}, {0, u8"/me открыл{sex:|а} медицинскую сумку и тут же нащупал{sex:|а} в ней необходимое лекарство."}, {0, u8"/me достав препарат из сумки, после чего передал{sex:|а} его человеку напротив"}, 
		{0, u8"/heal {arg1} {pricelec}"}, {0, u8"/todo Вот, держите, хорошего Вам дня!*закрывая сумку"}},
		sec = 2.0
	},
	[7] = {
		argfunc = true,
		arg = {{0, u8"id игрока"}},
		varfunc = true,
		var = {u8"0", u8"0", u8"0", u8"0", u8"0", u8"0", u8"0"},
		chatopen = false,
		typeAct = {{0, u8"Вам необходимо получить новую медицинскую карту или обновить имеющуюся?"}, {0, u8"Для оформления медицинской карты предоставьте, пожалуйста, Ваш паспорт."}, {0, u8'/b Для этого введите /showpass {myID}'}, {1, u8""}, {0, u8"/me взял{sex:|а} паспорт из рук пациента и внимательно изучил{sex:|а} его"}, {2, {u8"Новая мед. карта", u8"Обновить мед. карту"}}, {0, u8"{dialog1}Стоимость оформления новой мед. карты зависит от её срока."}, {0, u8"{dialog1}7 дней: {med7}$. 14 дней: {med14}$"}, {0, u8"{dialog1}30 дней: {med30}$. 60 дней: {med60}$"}, {4, 0, u8"{med7}"}, {4, 1, u8"{med14}"}, {4, 2, u8"{med30}"}, {4, 3, u8"{med60}"}, {0, u8"{dialog2}Стоимость обновления мед. карты зависит от её срока."}, {0, u8"{dialog2}7 дней: {medup7}$. 14 дней: {medup14}$"}, {0, u8"{dialog2}30 дней: {medup30}$. 60 дней: {medup60}$"}, {4, 0, u8"{medup7}"}, {4, 1, u8"{medup14}"}, {4, 2, u8"{medup30}"}, {4, 3, u8"{medup60}"},
		{0, u8"/n Оплачивать ничего не нужно, система сама предложит."}, {0, u8"На какой срок желаете оформить?"}, {2, {u8"7 дней", u8"14 дней", u8"30 дней", u8"60 дней"}}, {0, u8"{dialog1}"}, {4, 4, u8"{var1}"}, {4, 5, u8"0"}, {0, u8"{dialog2}"}, {4, 4, u8"{var2}"}, {4, 5, u8"1"}, {0, u8"{dialog3}"}, {4, 4, u8"{var3}"}, {4, 5, u8"2"}, {0, u8"{dialog4}"}, {4, 4, u8"{var4}"}, {4, 5, u8"3"}, {0, u8"Хорошо, сейчас задам пару вопросов, отвечайте чесно."}, {0, u8"Вы можете видеть имена проходящих мимо Вас людей?"}, {1, u8""}, {0, u8"Вас когда-нибудь убивали?"}, {2, {u8"Полностью здоров", u8"Наблюдаются отклонения", u8"Психически не здоров", u8"Не определён"}}, 
		{0, u8"{dialog1}"}, {4, 6, u8"3"}, {0, u8"{dialog2}"}, {4, 6, u8"2"}, {0, u8"{dialog3}"}, {4, 6, u8"1"}, {0, u8"{dialog4}"}, {4, 6, u8"0"},
		{0, u8"/me берёт в правую руку из мед. кейса печать и наносит штамп в углу бланка"}, {0, u8"/do Печать больницы нанесена на бланк."}, {0, u8"/me кладёт печать в мед. кейс, после чего ручкой ставит подпись и сегодняшнюю дату"}, {0, u8"/do Страница мединцинской карты полностью заполнена."}, {0, u8"/me передаёт медицинскую карту в руки обратившемуся"},
		{0, u8"/medcard {arg1} {var7} {var6} {var5}"}},
		sec = 2.0
	},
	[8] = {
		argfunc = true,
		arg = {{0, u8"id игрока"}},
		varfunc = false,
		var = {},
		chatopen = false,
		typeAct = {{0, u8"Очень замечательно, что Вы решили излечиться от наркозависимости."}, {0, u8"Стоимость одного сеанса составит {pricenarko}$"}, {0, u8'Метод лечения современный, называется "Нейроочищение". Он полностью сотрёт информацию о наркотиках с Вашего мозга.'}, 
		{0, u8"Вы согласны? Если да, то ложитесь на кушетку и мы приступим."}, {1, u8""}, {0, u8"/do На столе лежат стерильные перчатки и медицинская маска."}, {0, u8"/me взяв со стола средства индивидуальной защиты, надел{sex:|а} их на себя"}, {0, u8"/todo А теперь максимально расслабьтесь*подвигая спец. аппарат ближе к пациенту"}, {0, u8"/me взял{sex:|а} шлем от аппарата, после чего надел{sex:|а} его на голову пациента"}, {0, u8"/me включил{sex:|а} устройство, затем, подождав пять секунд, выключил{sex:|а} его"},
		{0, u8"/do Аппарат успешно завершил работу."}, {0, u8"/me снял{sex:|а} шлем с пациента и повесил{sex:|а} его обратно на аппарат"}, {0, u8"/healbad {arg1}"}, {0, u8"/todo Вот и всё! Тяга к запрещённым веществам должна исчезнуть*снимая с себя маску с перчатками"}},
		sec = 2.0
	},
	[9] = {
		argfunc = true,
		arg = {{0, u8"id игрока"}},
		varfunc = true,
		var = {u8"1"},
		chatopen = false,
		typeAct = {{0, u8"Мы выписываем рецепты в ограниченном количестве."}, {0, u8"/n Не более 5 штук в минуту."}, {0, u8"Стоимость одного рецепта составляет {pricerecept}$"}, {0, u8"Вы согласны? Если да, то какое количество Вам необходимо?"}, {3, u8"Выберите количество выдаваемых рецептов."}, {2, {u8"1 рецепт", u8"2 рецепта", u8"3 рецепта", u8"4 рецепта", u8"5 рецептов"}}, {0, u8"{dialog1}"}, {4, 0, u8"1"}, {0, u8"{dialog2}"}, {4, 0, u8"2"}, {0, u8"{dialog3}"}, {4, 0, u8"3"}, {0, u8"{dialog4}"}, {4, 0, u8"4"}, {0, u8"{dialog5}"}, {4, 0, u8"5"},
		{0, u8"/do На столе лежат бланки для оформления рецептов."},{0, u8"/me взяв ручку с печатью, заполнил{sex:|а} необходимые бланки, после чего поставил{sex:|а} печати в углу листа"}, {0, u8"/do Все бланки рецептов успешно заполнены."}, {0, u8"/todo Держите и строго соблюдайте инструкцию!*передавая рецепты человеку напротив"}, {0, u8"/recept {arg1} {var1}"}},
		sec = 2.0
	},
	[10] = {
		argfunc = false,
		arg = {},
		varfunc = false,
		var = {},
		chatopen = false,
		typeAct = {{0, u8"Сейчас я проведу для Вас небольшое мед. обследование."}, {0, u8"Пожалуйста, предоставьте Вашу мед. карту."}, {1, u8""}, {0, u8"/me взял{sex:|а} мед. карту из рук человека"}, {0, u8"/do Медицинская карта и ручка с печатью в руках."}, {0, u8"Итак, сейчас я задам некоторые вопросы для оценки состояния здоровья."},{0, u8"Давно ли Вы болели? Если да, то какими болезнями?"}, 
		{1, u8""}, {0, u8"Были ли у Вас травмы?"}, {1, u8""}, {0, u8"Имеются ли какие-то аллергические реакции?"}, {1, u8""}, {0, u8"/me сделал{sex:|а} записи в мед. карте"}, {0, u8"Так, откройте рот."}, {0, u8"/b /me открыл(а) рот"}, {1, u8""}, 
		{0, u8"/do В кармане фонарик."}, {0, u8"/me достал{sex:|а} фонарик из кармана, после чего включил{sex:|а} его"}, {0, u8"/me осмотрел{sex:|а} горло пациента"}, {0, u8"Можете закрыть рот."}, {0, u8"/me проверил{sex:|а} реакцию зрачков пациента на свет, посветив в глаза"}, 
		{0, u8"/do Зрачоки глаз обследуемого сузились."}, {0, u8"/me выключил{sex:|а} фонарик и убрал{sex:|а} его в карман"}, {0, u8"Присядьте, пожалуйста, на корточки и коснитесь кончиком пальца до носа."}, {1, u8""}, {0, u8"Вставайте."}, {0, u8"/me сделал{sex:|а} записи в медицинской карте"}, {0, u8"/me вернул{sex:|а} мед. карту человеку напротив"}, {0, u8"Спасибо, можете быть свободны."}},
		sec = 2.0
	},
	[13] = {
		argfunc = true,
		arg = {{0, u8"id игрока"}},
		varfunc = false,
		var = {},
		chatopen = false,
		typeAct = {{0, u8"Сейчас мы начнём сеанс по выведению татуировки с Вашего тела."}, {0, u8"Покажите Ваш паспорт, пожалуйста."}, {1, u8""}, {0, u8"/me принял{sex:|а} с рук обратившегося паспорт"}, 
		{0, u8"/do Паспорт обратившегося в правой руке."}, {0, u8"/me ознакомившись с паспортом, вернул{sex:|а} его обратно владельцу"}, {0, u8"Стоимость выведения татуировки составит {pricetatu}$. Вы согласны?"}, 
		{0, u8"/n Оплачивать не требуется, сервер сам предложит."}, {0, u8"/b Покажите татуировки с помощью команды /showtatu"}, {1, u8""}, {0, u8"Я смотрю, Вы готовы, тогда снимайте с себя рубашку, чтобы я вывел{sex:|а} Вашу татуировку."},
		{0, u8"/do У стены стоит инструментальный столик с подносом."}, {0, u8"/do Аппарат для выведения тату на подносе."}, {0, u8"/me взял{sex:|а} аппарат для выведения татуировки с подноса"}, {0, u8"/me осмотрев пациента, принял{sex:ся|лась} выводить его татуировку"}, {0, u8"/unstuff {arg1} {pricetatu}"}},
		sec = 2.0
	},
	[14] = {
		argfunc = true,
		arg = {{0, u8"id игрока"}, {1, u8"Причина"}},
		varfunc = false,
		var = {},
		chatopen = false,
		typeAct = {{0, u8"/do В левом кармане лежит телефон."}, {0, u8"/me достал{sex:|а} телефон из кармана, после чего {sex:зашел|зашла} в базу данных {myHospEn}"}, {0, u8"/me изменил{sex:|а} информацию о сотруднике {namePlayerRus[{arg1}]}"}, {0, u8"/fwarn {arg1} {arg2}"}, {0, u8"/r {namePlayerRus[{arg1}]} получил строгий выговор! Причина: {arg2}"}},
		sec = 2.0
	},
	[15] = {
		argfunc = true,
		arg = {{0, u8"id игрока"}},
		varfunc = false,
		var = {},
		chatopen = false,
		typeAct = {{0, u8"/do В левом кармане лежит телефон."}, {0, u8"/me достал{sex:|а} телефон из кармана, после чего {sex:зашел|зашла} в базу данных {myHospEn}"}, {0, u8"/me изменил{sex:|а} информацию о сотруднике {namePlayerRus[{arg1}]}"}, {0, u8"/unfwarn {arg1}"}, {0, u8"/r Сотруднику {namePlayerRus[{arg1}]} снят строгий выговор!"}},
		sec = 2.0
	},
	[16] = {
		argfunc = true,
		arg = {{0, u8"id игрока"}, {0, u8"Время заглушки в минутах"}, {1, u8"Причина"}},
		varfunc = false,
		var = {},
		chatopen = false,
		typeAct = {{0, u8"/do Рация весит на поясе."}, {0, u8"/me снял{sex:|а} рацию с пояса, после чего {sex:зашел|зашла} в настройки локальных частот вещания"}, {0, u8"/me заглушил{sex:|а} локальную частоту вещания сотруднику {namePlayerRus[{arg1}]}"}, {0, u8"/fmute {arg1} {arg2} {arg3}"}, {0, u8"/r Сотруднику {namePlayerRus[{arg1}]} была отключена рация. Причина: {arg3}"}, {0, u8"/me повесил{sex:|а} рацию обратно на пояс"}},
		sec = 2.0
	},
	[17] = {
		argfunc = true,
		arg = {{0, u8"id игрока"}},
		varfunc = false,
		var = {},
		chatopen = false,
		typeAct = {{0, u8"/do Рация весит на поясе."}, {0, u8"/me снял{sex:|а} рацию с пояса, после чего {sex:зашел|зашла} в настройки локальных частот вещания"}, {0, u8"/me освободил{sex:|а} локальную частоту вещания сотруднику {namePlayerRus[{arg1}]}"}, {0, u8"/funmute {arg1}"}, {0, u8"/r Сотруднику {namePlayerRus[{arg1}]} снова включена рация!"}, {0, u8"/me повесил{sex:|а} рацию обратно на пояс"}},
		sec = 2.0
	},
	[18] = {
		argfunc = true,
		arg = {{0, u8"id игрока"}, {0, u8"Номер ранга"}},
		varfunc = false,
		var = {},
		chatopen = false,
		typeAct = {{0, u8"/do В кармане халата находится футляр с ключами от шкафчиков с формой."}, {0, u8"/me потянувшись во внутренний карман халата, достал{sex:|а} оттуда футляр"}, {0, u8"/me открыв футляр, достал{sex:|а} оттуда ключ от шкафчика с формой"}, {0, u8"/me передал{sex:|а} ключ от шкафчика человеку напротив"}, {0, u8"/giverank {arg1} {arg2}"}, {0, u8"/r Сотрудник {namePlayerRus[{arg1}]} получил новую должность. Поздравляем!"}},
		sec = 2.0
	},
	[19] = {
		argfunc = true,
		arg = {{0, u8"id игрока"}},
		varfunc = false,
		var = {},
		chatopen = false,
		typeAct = {{0, u8"/do В кармане халата находятся ключи от шкафчика."}, {0, u8"/me потянувшись во внутренний карман халата, достал{sex:|а} оттуда ключ"}, {0, u8"/me передал{sex:|а} ключ от шкафчика с формой Интерна человеку напротив"}, {0, u8"/invite {arg1}"}, {0, u8"/r Приветствуем нового сотрудника нашей организации - {namePlayerRus[{arg1}]}"}},
		sec = 2.0
	},
	[20] = {
		argfunc = true,
		arg = {{0, u8"id игрока"}, {1, u8"Причина"}},
		varfunc = false,
		var = {},
		chatopen = false,
		typeAct = {{0, u8"/do В левом кармане лежит телефон."}, {0, u8"/me достал{sex:|а} телефон из кармана, после чего {sex:зашел|зашла} в базу данных {myHospEn}"}, {0, u8"/me изменил{sex:|а} информацию о сотруднике {namePlayerRus[{arg1}]}"}, {0, u8"/uninvite {arg1} {arg2}"}, {0, u8"/r Сотрудник {namePlayerRus[{arg1}]} был уволен из организации. Причина: {arg2}"}},
		sec = 2.0
	},
	[22] = {
		argfunc = true,
		arg = {{0, u8"id игрока"}, {1, u8"Причина"}},
		varfunc = false,
		var = {},
		chatopen = false,
		typeAct = {{0, u8"/me резким движением руки ухватил{sex:ась|ся} за воротник нарушителя"}, {0, u8"/do Крепко держит нарушителя за воротник."}, {0, u8"/todo Я вынужден{sex:|а} вывести вас из здания*направляясь к выходу."}, {0, u8"/me движением левой руки открыл{sex:|а} входную дверь, после чего вытолкнул{sex:|а} нарушителя"}, {0, u8"/expel {arg1} {arg2}"}},
		sec = 2.0
	},
	[23] = {
		argfunc = true,
		arg = {{0, u8"id игрока"}},
		varfunc = false,
		var = {},
		chatopen = false,
		typeAct = {{3, u8"Вакцина первая или вторая?"}, {2, {u8"Первая вакцина", u8"Вторая вакцина"}},
		{0, u8"{dialog1}Очень хорошо, что Вы решили вакцинироваться."}, {0, u8"{dialog1}Стоимость всего сеанса вакцинации составляет 600.000$. Вы согласны?"}, {0, u8"{dialog1}Если да, то присаживайтесь на кушетку и мы приступим."}, {1, u8""}, 
		{0, u8'{dialog1}/do На столе лежит шприц и баночка с надписью "BioNTech".'}, {0, u8"{dialog1}/me взяв баночку со шприцом, приступил{sex:|а} к закачке в неё жидкости"}, {0, u8"{dialog1}/do Жидкость в шприце."}, {0, u8"{dialog1}/me достал{sex:|а} из под стола ватку со спиртом и аккуратно протёр{sex:|ла} будущее место укола"}, {0, u8"{dialog1}/do Место для укола продезинфицировано."}, {0, u8"{dialog1}/me выбросив ватку, резко воткнул{sex:|а} в мышцу шприц и высадил{sex:|а} всю содержащуюся жидкость"}, {0, u8"{dialog1}/me выбросил{sex:|а} шприц в мусорное ведро и приложил{sex:|а} к телу пациента стерильную ватку"}, {0, u8"{dialog1}/vaccine {arg1}"}, {0, u8"{dialog1}/n Ждём две минуты до второй вакцины. Никуда не уходите, иначе статус первой пропадёт."},
		{0, u8'{dialog2}/do На столе лежит шприц и баночка с надписью "BioNTech".'}, {0, u8"{dialog2}/me взяв баночку со шприцом, приступил{sex:|а} к закачке в неё жидкости"}, {0, u8"{dialog2}/do Жидкость в шприце."}, {0, u8"{dialog2}/me достал{sex:|а} из под стола ватку со спиртом и аккуратно протёр{sex:|ла} будущее место укола"}, {0, u8"{dialog2}/do Место для укола продезинфицировано."}, {0, u8"{dialog2}/me выбросив ватку, резко воткнул{sex:|а} в мышцу шприц и высадил{sex:|а} всю содержащуюся жидкость"}, {0, u8"{dialog2}/me выбросил{sex:|а} шприц в мусорное ведро и приложил{sex:|а} к телу пациента стерильную ватку"}, {0, u8"{dialog2}/vaccine {arg1}"}},
		sec = 2.0
	},
	[25] = {
		argfunc = false,
		arg = {},
		varfunc = false,
		var = {},
		chatopen = false,
		typeAct = {{0, u8"Пройдёмте за мной."}},
		sec = 2.0
	},
	[26] = {
		argfunc = false,
		arg = {},
		varfunc = false,
		var = {},
		chatopen = false,
		typeAct = {{0, u8"Здравствуйте, меня зовут {myRusNick}, чем могу помочь?"}},
		sec = 2.0
	},
	[27] = {
		argfunc = true,
		arg = {{0, u8"id игрока"}},
		varfunc = false,
		var = {},
		chatopen = true,
		typeAct = {{0, u8"Насколько я понял{sex:|а}, Вам нужны антибиотики."}, {0, u8"Стоимость одного антибиотика составляет {priceant}$. Вы согласны?"}, {0, u8"Если да, то какое количество Вам необходимо?"}, 
		{3, u8"Ожидайте ответа о количестве от пациента."}, {1, u8""}, {0, u8"/me открыв мед.сумку, схватил{sex:ась|ся} за пачку антибиотиков, после чего вытянул{sex:|а} их и положил на стол"}, {0, u8"/do Антибиотики находятся на столе."}, {0, u8"/todo Вот держите, употребляйте их строго по рецепту!*закрывая мед. сумку"}, {3, u8"Введите количество антибиотиков в чат."}, {0, u8"/antibiotik {arg1} "}},
		sec = 2.0
	},
	[28] = {
		argfunc = true,
		arg = {{0, u8"id игрока"}},
		varfunc = false,
		var = {},
		chatopen = false,
		typeAct = {{0, u8"Насколько я понял, Вам нужна медицинская страховка?"}, {0, u8"Предоставьте, пожалуйста, Вашу мед. карту."}, {0, u8"/b /showmc {myID}"}, {1, u8""}, {0, u8"/todo Благодарю Вас!*взяв мед. карту в руки и начав её изучать."}, {0, u8"Для оформления медицинской страховки необходимо заплатить гос. пошлину, которая зависит от срока."}, {0, u8"На 1 неделю - 4ОО.ООО$. На 2 недели - 8ОО.ООО$. На 3 недели - 1.2ОО.ООО$"}, {0, u8"На какой срок оформляем?"}, {1, u8""}, 
		{0, u8"Хорошо, тогда приступим к оформлению."}, {0, u8"/me вытащил{sex:|а} из нагрудного кармана шариковую ручку"}, {0, u8"/me открыл{sex:|а} шкафчик, затем достал{sex:|а} оттуда пустые бланки"}, {0, u8"/me разложил{sex:|а} пальцами правой руки мед. карту на нужной страничке и начал{sex:|а} переписывать данные в бланк"}, {0, u8"/me взял{sex:|а} штамп в правую руку из ящика стола и {sex:нанес|ненесла} оттиск в углу бланка"}, {0, u8"/do Печать нанесена."},
		{0, u8"/me отложив штамп в сторону, поставил{sex:|а} свою подпись и сегодняшнюю дату"}, {0, u8"/do Бланк успешно заполнен."}, {0, u8"Всё готово, держите свою медицинскую страховку. Удачного дня!"}, {0, u8"/givemedinsurance {arg1}"}},
		sec = 2.0
	},
	[29] = {
		argfunc = true,
		arg = {{0, u8"id игрока"}},
		varfunc = false,
		var = {},
		chatopen = false,
		typeAct = {{0, u8"Не волнуйтесь, сейчас я окажу Вам экстренную помощь!"}, {0, u8"/me легким движением пальца прислонил{sex:|а} к шее пациента, после чего начал{sex:|а} измерять пульс"}, {0, u8"/do У пациента отсутствует пульс."}, {0, u8"/todo Нужно быстро принять меры!*посмотрев на мед. сумку"}, {0, u8"/me легким движением руки открыл{sex:|а} мед. сумку, после чего достал{sex:|а} платок"}, 
		{0, u8"/me аккуратно приложил{sex:|а} платок ко рту пострадавшего, после чего сделал{sex:|а} глубокий вдох"}, {0, u8"/do В лёгких много воздуха."}, {0, u8"/me встал{sex:|а} на колени, после чего прислонил{sex:ся|ась} к пациенту"}, {0, u8"/me {sex:подвел|подвела} губы ко рту пострадавшего, после чего начал{sex:|а} делать искусственное дыхание"}, 
		{0, u8"/me отвел{sex:|а} губы от рта пострадавшего, после чего сделал{sex:|а} глубокий вдох"}, {0, u8"/me подвел{sex:|а} губы ко рту пострадавшего, после чего начал{sex:|а} делать искусственное дыхание"}, {0, u8"/do Пациент очнулся."}, {0, u8"/cure {arg1}"}},
		sec = 2.0
	},
	[34] = {
		argfunc = true,
		arg = {{0, u8"id игрока"}},
		varfunc = false,
		var = {},
		chatopen = false,
		typeAct = {{2, {u8"Показать паспорт", u8"Показать мед. карту", u8"Показать лицензии"}}, {0, u8"{dialog1}/do Паспорт гражданина находится в заднем кармане."}, {0, u8"{dialog1}/me засунув руку в карман, достал{sex:|а} паспорт, после чего передал{sex:|а} его человеку напротив"}, {0, u8"{dialog1}/showpass {arg1}"}, 
		{0, u8"{dialog2}/do Медицинская карта находится в нагрудном кармане."}, {0, u8"{dialog2}/me засунув руку в карман, достал{sex:|а} мед. карту, после чего передал{sex:|а} её человеку напротив"}, {0, u8"{dialog2}/showmc {arg1}"}, 
		{0, u8"{dialog3}/do Пакет лицензий находится в нагрудном кармане."}, {0, u8"{dialog3}/me засунув руку в карман, достал{sex:|а} лицензии, после чего передал{sex:|а} их человеку напротив"}, {0, u8"{dialog3}/showlic {arg1}"}},
		sec = 2.0
	},
	[35] = {
		argfunc = true,
		arg = {},
		varfunc = false,
		var = {},
		chatopen = false,
		typeAct = {{2, {u8"Включить камеру", u8"Выключить камеру"}}, {0, u8"{dialog1}/do Телефон находится в левом кармане."}, {0, u8'{dialog1}/me засунув руку в карман, достал{sex:|а} оттуда телефон, после чего заш{sex:ел|ла} в приложение "Камера"'}, {0, u8"{dialog1}/me нажав на кнопку записи, приступил{sex:|а} к съёмке происходящего"}, {0, u8"{dialog1}/do Камера смартфона начала записывать видео и звук."}, 
		{0, u8"{dialog2}/do Телефон находится в руке и ведёт запись."}, {0, u8"{dialog2}/me нажал{sex:|а} на кнопку отключения записи, после чего убрал{sex:|а} телефон в задний карман"}, {0, u8"{dialog2}/do Видеофиксация происходящего приостановлена."}},
		sec = 2.0
	},
	[36] = {
		argfunc = true,
		arg = {},
		varfunc = false,
		var = {},
		chatopen = true,
		typeAct = {{0, u8"Насколько я понял{sex:|а}, Вам нужны антибиотики."}, {0, u8"Стоимость одного антибиотика составляет {priceant}$. Вы согласны?"}, {0, u8"Если да, то какое количество Вам необходимо?"}, 
		{3, u8"Ожидайте ответа о количестве от пациента."}, {1, u8""}, {0, u8"/me открыв мед.сумку, схватил{sex:ась|ся} за пачку антибиотиков, после чего вытянул{sex:|а} их и положил на стол"}, {0, u8"/do Антибиотики находятся на столе."}, {0, u8"/todo Вот держите, употребляйте их строго по рецепту!*закрывая мед. сумку"}, {3, u8"Введите количество антибиотиков в чат."}, {0, u8"/antibiotik {arg1} "}},
		sec = 2.0
	}
}

local optionsPKM = {u8"Вылечить", u8"Выдать мед.карту", u8"Вакцинировать", u8"Снять нарко", u8"Выдать антибиотики", u8"Выдать рецепт", u8"Выгнать из больницы", u8"Провести собеседование", u8"Изменить должность", u8"Принять в организацию", u8"Поднять на ноги", u8"Показать документы", u8"Провести сделку"}
local setting2 = {
	funcPKM = {
		func = false,
		slider = {0, 1, 2, 3, 4, 6}
	},
	color_int = 0xFFED2626
}
local chg_funcPKM = {
	func = imgui.ImBool(false),
	slider = {imgui.ImInt(0), imgui.ImInt(0), imgui.ImInt(0), imgui.ImInt(0), imgui.ImInt(0), imgui.ImInt(0)}
}
for i, v in ipairs(chg_funcPKM.slider) do
	chg_funcPKM.slider[i].v = setting2.funcPKM.slider[i]
end
inventoryOpen = false
--> Для департамента
setDep = {"","",""}
--> Настройки основных команд
cmdBind = {
	[1] = {
		cmd = "mh",
		key = {},
		desc = "Открывает меню скрипта.",
		rank = 1,
		rb = false
	},
	[2] = {
		cmd = "r",
		key = {},
		desc = "Команда для вызова рации с тегом (если тег прописан).",
		rank = 1,
		rb = false
	},
	[3] = {
		cmd = "rb",
		key = {},
		desc = "Команда для написания НонРп сообщения в рацию.",
		rank = 1,
		rb = false
	},
	[4] = {
		cmd = "mb",
		key = {},
		desc = "Сокращённая команда /members",
		rank = 1,
		rb = false
	},
	[5] = {
		cmd = "hl",
		key = {},
		desc = "Лечение с автоматической РП отыгровкой.",
		rank = 2,
		rb = false
	},
	[6] = {
		cmd = "post",
		key = {},
		desc = "Доклад с мобильного поста. Также информация о постах.",
		rank = 2,
		rb = false
	},
	[7] = {
		cmd = "mc",
		key = {},
		desc = "Выдача или обновление медицинской карты.",
		rank = 2,
		rb = false
	},
	[8] = {
		cmd = "narko",
		key = {},
		desc = "Лечение от наркозависимости.",
		rank = 4,
		rb = false
	},
	[9] = {
		cmd = "recep",
		key = {},
		desc = "Выдача рецептов.",
		rank = 4,
		rb = false
	},
	[10] = {
		cmd = "osm",
		key = {},
		desc = "Произвести медицинский осмотр.",
		rank = 5,
		rb = false
	},
	[11] = {
		cmd = "dep",
		key = {},
		desc = "Меню рации депортамента.",
		rank = 5,
		rb = false
	},
	[12] = {
		cmd = "sob",
		key = {},
		desc = "Меню собеседования с игроком.",
		rank = 5,
		rb = false
	},
	[13] = {
		cmd = "tatu",
		key = {},
		desc = "Сведение татуировки с тела.",
		rank = 7,
		rb = false
	},
	[14] = {
		cmd = "vig",
		key = {},
		desc = "Выдача выговора сотруднику.",
		rank = 8,
		rb = false
	},
	[15] = {
		cmd = "unvig",
		key = {},
		desc = "Снять выговор сотруднику.",
		rank = 8,
		rb = false
	},
	[16] = {
		cmd = "muteorg",
		key = {},
		desc = "Выдать мут сотруднику.",
		rank = 8,
		rb = false
	},
	[17] = {
		cmd = "unmuteorg",
		key = {},
		desc = "Снять мут сотруднику.",
		rank = 8,
		rb = false
	},
	[18] = {
		cmd = "gr",
		key = {},
		desc = "Изменить ранг (должность) сотруднику с РП отыгровкой.",
		rank = 9,
		rb = false
	},
	[19] = {
		cmd = "inv",
		key = {},
		desc = "Принять в организацию игрока с РП отыгровкой.",
		rank = 9,
		rb = false
	},
	[20] = {
		cmd = "unv",
		key = {},
		desc = "Уволить сотрудника из организации с РП отыгровкой.",
		rank = 9,
		rb = false
	},
	[21] = {
		cmd = "time",
		key = {},
		desc = "Посмотреть на часы с гравировкой.",
		rank = 1,
		rb = false
	},
	[22] = {
		cmd = "exp",
		key = {},
		desc = "Выгнать из больницы с РП отыгровкой.",
		rank = 1,
		rb = false
	},
	[23] = {
		cmd = "vac",
		key = {},
		desc = "Вакцинация с РП отыгровкой.",
		rank = 3,
		rb = false
	},
	[24] = {
		cmd = "info",
		key = {},
		desc = "Информацию о частых командах выведет в чат.",
		rank = 1,
		rb = false
	},
	[25] = {
		cmd = "za",
		key = {},
		desc = "Отправляет в чат фразу \"Пройдёмте за мной.\"",
		rank = 1,
		rb = false
	},
	[26] = {
		cmd = "zd",
		key = {},
		desc = "Отправляет в чат приветствие.",
		rank = 1,
		rb = false
	},
	[27] = {
		cmd = "ant",
		key = {},
		desc = "Продать антибиотики с РП отыгровкой.",
		rank = 4,
		rb = false
	},
	[28] = {
		cmd = "strah",
		key = {},
		desc = "Выдать медицинскую страховку с РП отыгровкой.",
		rank = 3,
		rb = false
	},
	[29] = {
		cmd = "cur",
		key = {},
		desc = "Поднять человека на ноги на вызове с РП отыгровкой.",
		rank = 2,
		rb = false
	},
	[30] = {
		cmd = "hall",
		key = {2,50},
		desc = "Вылечить игрока по прицелу мыши на него.",
		rank = 1.5,
		rb = false
	},
	[31] = {
		cmd = "hilka",
		key = {2,49},
		desc = "Вылечить ближайшего игрока с РП отыгровкой.",
		rank = 1.5,
		rb = false
	},
	[32] = {
		cmd = "shpora",
		key = {},
		desc = "Открыть шпаргалку по его порядковому номеру.",
		rank = 1,
		rb = false
	},
	[33] = {
		cmd = "hme",
		key = {},
		desc = "Вылечить самого себя.",
		rank = 1,
		rb = false
	},
	[34] = {
		cmd = "show",
		key = {},
		desc = "Показать паспорт, лицензии или мед. карту.",
		rank = 1,
		rb = false
	},
	[35] = {
		cmd = "cam",
		key = {},
		desc = "Включить/выключить видеофиксацию.",
		rank = 1,
		rb = false
	},
	[36] = {
		cmd = "godeath",
		key = {},
		desc = "Акабака.",
		rank = 3,
		rb = false
	}
}

function isCursorAvailable()
	return (not sampIsChatInputActive() and not sampIsDialogActive() and not sampIsScoreboardOpen())
end

function renderFontDrawClickableText(active, font, text, posX, posY, color, color_hovered, align, b_symbol)
	local cursorX, cursorY = getCursorPos()
	local lenght = renderGetFontDrawTextLength(font, text)
	local height = renderGetFontDrawHeight(font)
	local symb_len = renderGetFontDrawTextLength(font, '>')
	local hovered = false
	local result = false
    b_symbol = b_symbol == nil and false or b_symbol
    align = align or 1

    if align == 2 then
    	posX = posX - (lenght / 2)
    elseif align == 3 then
    	posX = posX - lenght
	end

    if active and cursorX > posX and cursorY > posY and cursorX < posX + lenght and cursorY < posY + height then
        hovered = true
        if isKeyJustPressed(0x01) then -- LButton
        	result = true 
        end
    end

    local anim = math.floor(math.sin(os.clock() * 10) * 3 + 5)

 	if hovered and b_symbol and (align == 2 or align == 1) then
    	renderFontDrawText(font, '>', posX - symb_len - anim, posY, 0x90FFFFFF)
    end 

    renderFontDrawText(font, text, posX, posY, hovered and color_hovered or color)

    if hovered and b_symbol and (align == 2 or align == 3) then
    	renderFontDrawText(font, '<', posX + lenght + anim, posY, 0x90FFFFFF)
    end 

    return result
end

local convert_color = function(argb)
	local col = imgui.ColorConvertU32ToFloat4(argb)
	return imgui.ImFloat4(col.z, col.y, col.x, col.w)
end

function explode_U32(u32)
	local a = bit.band(bit.rshift(u32, 24), 0xFF)
	local r = bit.band(bit.rshift(u32, 16), 0xFF)
	local g = bit.band(bit.rshift(u32, 8), 0xFF)
	local b = bit.band(u32, 0xFF)
	return a, r, g, b
end

function join_argb(a, r, g, b)
	local argb = b
	argb = bit.bor(argb, bit.lshift(g, 8))
	argb = bit.bor(argb, bit.lshift(r, 16))
	argb = bit.bor(argb, bit.lshift(a, 24))
	return argb
end

function changeColorAlpha(argb, alpha)
	local _, r, g, b = explode_U32(argb)
	return join_argb(alpha, r, g, b)
end

function ARGBtoStringRGB(abgr)
	local a, r, g, b = explode_U32(abgr)
	local argb = join_argb(a, r, g, b)
	local color = ('%x'):format(bit.band(argb, 0xFFFFFF))
	return ('{%s%s}'):format(('0'):rep(6 - #color), color)
end

function imgui.ColorConvertFloat4ToARGB(float4)
	local abgr = imgui.ColorConvertFloat4ToU32(float4)
	local a, b, g, r = explode_U32(abgr)
	return join_argb(a, r, g, b)
end

function changePosition()
	if C_membScr.func.v then
		lua_thread.create(function()
			local backup = {
				['x'] = C_membScr.pos.x.v,
                ['y'] = C_membScr.pos.y.v
			}
			local ChangePos = true
			sampSetCursorMode(4)
			mainWin.v = false
			sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} Нажмите {FF6060}ЛКМ{FFFFFF}, чтобы применить или {FF6060}ESC{FFFFFF} для отмены.", 0xFF8FA2)
            if not sampIsChatInputActive() then
                while not sampIsChatInputActive() and ChangePos do
                    wait(0)
                    local cX, cY = getCursorPos()
                    C_membScr.pos.x.v = cX
                    C_membScr.pos.y.v = cY
                    if isKeyDown(0x01) then
                    	while isKeyDown(0x01) do wait(0) end
                        ChangePos = false
						settingMassiveMembers()
                        sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} Позиция сохранена.", 0xFF8FA2)
                    elseif isKeyJustPressed(VK_ESCAPE) then
                        ChangePos = false
						C_membScr.pos.x.v = backup['x']
						C_membScr.pos.y.v = backup['y']
                        sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} Вы отменили изменение позиции.", 0xFF8FA2)
                    end
                end
            end
            sampSetCursorMode(0)
            mainWin.v = true
            ChangePos = false
		end)
	end
end

local fa_font = nil
local fa_font2 = nil
local fa_font3 = nil

local fontsize = nil
local fa_font_mus = nil
local fa_glyph_ranges = imgui.ImGlyphRanges({ fa.min_range, fa.max_range })
local the_path_to_the_file_font = 'moonloader/lib/fontawesome-webfont.ttf'
if not doesFileExist(getWorkingDirectory()..'/lib/fontawesome-webfont.ttf') then
	the_path_to_the_file_font = 'moonloader/resource/fonts/fontawesome-webfont.ttf'
end
function imgui.BeforeDrawFrame()
	if fa_font == nil then
		local font_config = imgui.ImFontConfig()
		font_config.MergeMode = true
		fa_font = imgui.GetIO().Fonts:AddFontFromFileTTF(the_path_to_the_file_font, 14.0, font_config, fa_glyph_ranges)
	end
	if fa_font2 == nil then
		local font_config = imgui.ImFontConfig()
		font_config.MergeMode = false
		fa_font2 = imgui.GetIO().Fonts:AddFontFromFileTTF(the_path_to_the_file_font, 20.0, font_config, fa_glyph_ranges)
	end
	if fa_font3 == nil then
		local font_config = imgui.ImFontConfig()
		font_config.MergeMode = false
		fa_font3 = imgui.GetIO().Fonts:AddFontFromFileTTF(the_path_to_the_file_font, 18.0, font_config, fa_glyph_ranges)
	end
	if fa_font_mus == nil then
		local font_config = imgui.ImFontConfig()
		font_config.MergeMode = false
		fa_font_mus = imgui.GetIO().Fonts:AddFontFromFileTTF(the_path_to_the_file_font, 30.0, font_config, fa_glyph_ranges)
	end
	if fontsize == nil then
		fontsize = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\trebucbd.ttf', 15.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
	end
end
notes = {}
function main()	
	repeat wait(300) until isSampAvailable()
	local base = getModuleHandle("samp.dll")
	local sampVer = mem.tohex( base + 0xBABE, 10, true )
	if sampVer == "E86D9A0A0083C41C85C0" then
		sampIsLocalPlayerSpawned = function()
			local res, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
			return sampGetGamestate() == 3 and res and sampGetPlayerAnimationId(id) ~= 0
		end
	end
	if script.this.filename:find("%.luac") then
		os.rename(getWorkingDirectory().."\\MedicalHelper.luac", getWorkingDirectory().."\\MedicalHelper.lua") 
	end
	thread = lua_thread.create(function() return end)
	sectator = lua_thread.create(function() return end)
	sound_reminder = lua_thread.create(function() return end)
	
	if not doesDirectoryExist(dirml.."/MedicalHelper/files/") then
		print("{F54A4A}Ошибка. Отсутствует папка. {82E28C}Создание папки под файлы")
		createDirectory(dirml.."/MedicalHelper/files/")
	end
	if not doesDirectoryExist(dirml.."/MedicalHelper/Binder/") then
		print("{F54A4A}Ошибка. Отсутствует папка. {82E28C}Создание папки для биндера.")
		createDirectory(dirml.."/MedicalHelper/Binder/")
	end
	if not doesDirectoryExist(dirml.."/MedicalHelper/Шпаргалки/") then
		print("{F54A4A}Ошибка. Отсутствует папка. {82E28C}Создание папки для шпор")
		createDirectory(dirml.."/MedicalHelper/Шпаргалки/")
	end
	if not doesDirectoryExist(dirml.."/MedicalHelper/Департамент/") then
		print("{F54A4A}Ошибка. Отсутствует папка. {82E28C}Создание папки для новостей в департамент")
		createDirectory(dirml.."/MedicalHelper/Департамент/")
	end
	if doesDirectoryExist(dirml.."/MedicalHelper/Департамент/") then
		getGovFile()
	end
	local function check_table(arg, table, mode)
		if mode == 1 then -- Поиск по ключу
			for k, v in pairs(table) do
				if k == arg then
					return true
				end
			end
		else -- Поиск по значению
			for k, v in pairs(table) do
				if v == arg then
					return true
				end
			end
		end
		return false
	end
	if doesFileExist(dirml.."/MedicalHelper/Отыгровки.med") then
		os.remove(dirml.."/MedicalHelper/Отыгровки.med")
	end
	if doesFileExist(dirml.."/MedicalHelper/Отыгровки команд.med") then
		print("{82E28C}Чтение настроек отыгровок команд...")
		local f = io.open(dirml.."/MedicalHelper/Отыгровки команд.med")
		local setf = f:read("*a")
		f:close()
		local res, sets = pcall(decodeJson, setf)
		if res and type(sets) == "table" then 
			acting = sets
		else
			os.remove(dirml.."/MedicalHelper/Отыгровки команд.med")
			print("{F54A4A}Ошибка. Файл отыгровок команд повреждён.")
			print("{82E28C}Создание файла отыгровок команд...")
			local f = io.open(dirml.."/MedicalHelper/Отыгровки команд.med", "w")
			f:write(encodeJson(acting))
			f:flush()
			f:close()
		end
	else
		print("{F54A4A}Ошибка. Файл отыгровок команд не найден.")
		print("{82E28C}Создание файла отыгровок команд...")
		if not doesFileExist(dirml.."/MedicalHelper/Отыгровки команд.med") then
			local f = io.open(dirml.."/MedicalHelper/Отыгровки команд.med", "w")
			f:write(encodeJson(acting))
			f:flush()
			f:close()
		end
	end
	if doesFileExist(dirml.."/MedicalHelper/Треки.med") then
		print("{82E28C}Чтение избранных треков...")
		local f = io.open(dirml.."/MedicalHelper/Треки.med")
		local setf = f:read("*a")
		f:close()
		local res, sets = pcall(decodeJson, setf)
		if res and type(sets) == "table" then 
			save_tracks = sets
			if save_tracks.link[1] ~= nil then
				for i = 1, #save_tracks.link do
					if save_tracks.link[i]:find('ru.hitmotop.com') then
						save_tracks.link[i] = save_tracks.link[i]:gsub('ru%.hitmotop%.com', 'ru%.apporange%.space')
						save_tracks.image[i] = save_tracks.image[i]:gsub('ru%.hitmotop%.com', 'ru%.apporange%.space')
					end
					if save_tracks.link[i]:find('rur.hitmotop.com') then
						save_tracks.link[i] = save_tracks.link[i]:gsub('rur%.hitmotop%.com', 'ru%.apporange%.space')
						save_tracks.image[i] = save_tracks.image[i]:gsub('rur%.hitmotop%.com', 'ru%.apporange%.space')
					end
				end
			end
			local f = io.open(dirml.."/MedicalHelper/Треки.med", "w")
			f:write(encodeJson(save_tracks))
			f:flush()
			f:close()
		else
			os.remove(dirml.."/MedicalHelper/Треки.med")
			print("{F54A4A}Ошибка. Файл избранных треков повреждён.")
			print("{82E28C}Создание файла избранных треков...")
			local f = io.open(dirml.."/MedicalHelper/Треки.med", "w")
			f:write(encodeJson(save_tracks))
			f:flush()
			f:close()
		end
	else
		print("{F54A4A}Ошибка. Файл избранных треков не найден.")
		print("{82E28C}Создание файла избранных треков...")
		if not doesFileExist(dirml.."/MedicalHelper/Треки.med") then
			local f = io.open(dirml.."/MedicalHelper/Треки.med", "w")
			f:write(encodeJson(save_tracks))
			f:flush()
			f:close()
		end
	end
	if doesFileExist(dirml.."/MedicalHelper/depsetting.med") then
		print("{82E28C}Чтение настроек департамента...")
		local f = io.open(dirml.."/MedicalHelper/depsetting.med")
		local setf = f:read("*a")
		f:close()
		local res, setdept = pcall(decodeJson, setf)
		if res and type(setdept) == "table" then 
			setdepteg.tegtext_one = setdept.tegtext_one
			setdepteg.tegtext_two = setdept.tegtext_two
			setdepteg.tegtext_three = setdept.tegtext_three
			setdepteg.tegpref_one = setdept.tegpref_one
			setdepteg.tegpref_two = setdept.tegpref_two
			setdepteg.prefix = setdept.prefix
		else
			os.remove(dirml.."/MedicalHelper/depsetting.med")
			print("{F54A4A}Ошибка. Файл настроек департамента повреждён.")
			print("{82E28C}Пересоздание файла настроек департамента...")
			local f = io.open(dirml.."/MedicalHelper/depsetting.med", "w")
			f:write(encodeJson(setdepteg))
			f:flush()
			f:close()
		end
	else
		print("{F54A4A}Ошибка. Файл настроек департамента не найден.")
		print("{82E28C}Создание файла настроек департамента...")
		if not doesFileExist(dirml.."/MedicalHelper/depsetting.med") then
			local f = io.open(dirml.."/MedicalHelper/depsetting.med", "w")
			f:write(encodeJson(setdepteg))
			f:flush()
			f:close()
		end
	end
	if doesFileExist(dirml.."/MedicalHelper/MainSetting_2.med") then
		print("{82E28C}Чтение основных настроек 2...")
		local f = io.open(dirml.."/MedicalHelper/MainSetting_2.med")
		local setf = f:read("*a")
		f:close()
		local res, set2 = pcall(decodeJson, setf)
		if res and type(set2) == "table" then 
			setting2 = set2
			chg_funcPKM.func.v = set2.funcPKM.func
			for i = 1, #set2.funcPKM.slider do
				chg_funcPKM.slider[i] = imgui.ImInt(0)
				chg_funcPKM.slider[i].v = set2.funcPKM.slider[i]
			end
		else
			os.remove(dirml.."/MedicalHelper/MainSetting_2.med")
			print("{F54A4A}Ошибка. Файл основных настроек 2 повреждён.")
			print("{82E28C}Пересоздание файла основных настроек 2...")
			local f = io.open(dirml.."/MedicalHelper/MainSetting_2.med", "w")
			f:write(encodeJson(setting2))
			f:flush()
			f:close()
		end
	else
		print("{F54A4A}Ошибка. Файл основных настроек 2 не найден.")
		print("{82E28C}Создание файла основных настроек 2...")
		if not doesFileExist(dirml.."/MedicalHelper/MainSetting_2.med") then
			local f = io.open(dirml.."/MedicalHelper/MainSetting_2.med", "w")
			f:write(encodeJson(setting2))
			f:flush()
			f:close()
		end
	end
	col_interface = convert_color(setting2.color_int)
	if doesFileExist(dirml.."/MedicalHelper/MainMembers.med") then
		print("{82E28C}Чтение настроек мемберса...")
		local f = io.open(dirml.."/MedicalHelper/MainMembers.med")
		local setm = f:read("*a")
		f:close()
		local res, setmemb = pcall(decodeJson, setm)
		if res and type(setmemb) == "table" then 
			membScr = setmemb
		else
			os.remove(dirml.."/MedicalHelper/MainMembers.med")
			print("{F54A4A}Ошибка. Файл настроек мемберса повреждён.")
			print("{82E28C}Пересоздание файла настроек мемберса...")
			local f = io.open(dirml.."/MedicalHelper/MainMembers.med", "w")
			f:write(encodeJson(membScr))
			f:flush()
			f:close()
		end
	else
		print("{F54A4A}Ошибка. Файл онастроек мемберса не найден.")
		print("{82E28C}Создание файла настроек мемберса...")
		if not doesFileExist(dirml.."/MedicalHelper/MainMembers.med") then
			local f = io.open(dirml.."/MedicalHelper/MainMembers.med", "w")
			f:write(encodeJson(membScr))
			f:flush()
			f:close()
		end
	end
	C_membScr = {
		func = imgui.ImBool(membScr.func),
		pos = {x = imgui.ImInt(membScr.pos.x), y = imgui.ImInt(membScr.pos.y)},
		forma = imgui.ImBool(membScr.forma),
		numrank = imgui.ImBool(membScr.numrank),
		id = imgui.ImBool(membScr.id),
		afk = imgui.ImBool(membScr.afk),
		dialog = imgui.ImBool(membScr.dialog),
		vergor = imgui.ImBool(membScr.vergor),
		font = {
			size = imgui.ImFloat(membScr.font.size),
			flag = imgui.ImFloat(membScr.font.flag),
			distance = imgui.ImFloat(membScr.font.distance),
			visible = imgui.ImFloat(membScr.font.visible)
		},
		color = {
			col_title 	= membScr.color.col_title,
			col_default = membScr.color.col_default,
			col_no_work = membScr.color.col_no_work
		}
	}
	fontes = renderCreateFont("Trebuchet MS", C_membScr.font.size.v, C_membScr.font.flag.v)
	col = {
		title = convert_color(membScr.color.col_title),
		default = convert_color(membScr.color.col_default),
		no_work = convert_color(membScr.color.col_no_work)
	}
	profit_money = {
		payday = {0, 0, 0, 0, 0, 0, 0}, --> Зарплата
		lec = {0, 0, 0, 0, 0, 0, 0}, --> Лечение
		medcard = {0, 0, 0, 0, 0, 0, 0}, --> Мед. карта
		narko = {0, 0, 0, 0, 0, 0, 0}, --> Наркозависимость
		vac = {0, 0, 0, 0, 0, 0, 0}, --> Вакцинация
		ant = {0, 0, 0, 0, 0, 0, 0}, --> Антибиотики
		rec = {0, 0, 0, 0, 0, 0, 0}, --> Рецепты
		medcam = {0, 0, 0, 0, 0, 0, 0}, --> Медикаменты
		cure = {0, 0, 0, 0, 0, 0, 0}, --> Поднятие на ноги
		strah = {0, 0, 0, 0, 0, 0, 0}, --> Страховка
		tatu = {0, 0, 0, 0, 0, 0, 0}, --> Татуировка
		premium = {0, 0, 0, 0, 0, 0, 0}, --> Премия
		other = {0, 0, 0, 0, 0, 0, 0}, --> Другое
		total_week = 0, --> Всего за неделю
		total_all = 0, --> Итого
		date_num = {0, 0}, --> Дата в цифровом формате {Сегодня, вчера}
		date_today = {os.date("%d") + 0, os.date("%m") + 0, os.date("%Y") + 0}, --> Дата захода в реальном времени в формате {день, месяц, год}
		date_last = {os.date("%d") + 0, os.date("%m") + 0, os.date("%Y") + 0}, --> Дата вчерашняя в формате {день, месяц, год}
		date_week = {os.date("%d.%m.%Y"), "", "", "", "", "", ""} --> Дата за неделю в формате [день, месяц, год]
	}
	if doesFileExist(dirml.."/MedicalHelper/profit.med") then
		print("{82E28C}Чтение настроек прибыли...")
		local f = io.open(dirml.."/MedicalHelper/profit.med")
		local setp = f:read("*a")
		f:close()
		local res, setprofit = pcall(decodeJson, setp)
		if res and type(setprofit) == "table" then 
			profit_money = setprofit 
			profit_money.date_today[1] = os.date("%d") + 0
			profit_money.date_today[2] = os.date("%m") + 0
			profit_money.date_today[3] = os.date("%Y") + 0
			if profit_money.date_today[1] ~= profit_money.date_last[1] or profit_money.date_today[2] ~= profit_money.date_last[2] or profit_money.date_today[3] ~= profit_money.date_last[3] then
				profit_money.date_num[1] = profit_money.date_num[1] + 1
			end
			if profit_money.date_num[1] > profit_money.date_num[2] then --> Если сегодняшняя дата отличается от вчерашней
				profit_money.date_last[1] = os.date("%d") + 0
				profit_money.date_last[2] = os.date("%m") + 0
				profit_money.date_last[3] = os.date("%Y") + 0
				profit_money.date_num[2] = profit_money.date_num[1]
				profit_money.date_week[1], profit_money.date_week[2], profit_money.date_week[3], profit_money.date_week[4], profit_money.date_week[5], profit_money.date_week[6], profit_money.date_week[7] = os.date("%d.%m.%Y"), setprofit.date_week[1], setprofit.date_week[2], setprofit.date_week[3], setprofit.date_week[4], setprofit.date_week[5], setprofit.date_week[6]
				profit_money.payday[1], profit_money.payday[2], profit_money.payday[3], profit_money.payday[4], profit_money.payday[5], profit_money.payday[6], profit_money.payday[7] = 		 			  0, setprofit.payday[1], setprofit.payday[2], setprofit.payday[3], setprofit.payday[4], setprofit.payday[5], setprofit.payday[6]
				profit_money.lec[1], profit_money.lec[2], profit_money.lec[3], profit_money.lec[4], profit_money.lec[5], profit_money.lec[6], profit_money.lec[7] = 										  0, setprofit.lec[1], setprofit.lec[2], setprofit.lec[3], setprofit.lec[4], setprofit.lec[5], setprofit.lec[6]
				profit_money.medcard[1], profit_money.medcard[2], profit_money.medcard[3], profit_money.medcard[4], profit_money.medcard[5], profit_money.medcard[6], profit_money.medcard[7] = 			  0, setprofit.medcard[1], setprofit.medcard[2], setprofit.medcard[3], setprofit.medcard[4], setprofit.medcard[5], setprofit.medcard[6]
				profit_money.narko[1], profit_money.narko[2], profit_money.narko[3], profit_money.narko[4], profit_money.narko[5], profit_money.narko[6], profit_money.narko[7] = 				 			  0, setprofit.narko[1], setprofit.narko[2], setprofit.narko[3], setprofit.narko[4], setprofit.narko[5], setprofit.narko[6]
				profit_money.vac[1], profit_money.vac[2], profit_money.vac[3], profit_money.vac[4], profit_money.vac[5], profit_money.vac[6], profit_money.vac[7] = 										  0, setprofit.vac[1], setprofit.vac[2], setprofit.vac[3], setprofit.vac[4], setprofit.vac[5], setprofit.vac[6]
				profit_money.ant[1], profit_money.ant[2], profit_money.ant[3], profit_money.ant[4], profit_money.ant[5], profit_money.ant[6], profit_money.ant[7] = 										  0, setprofit.ant[1], setprofit.ant[2], setprofit.ant[3], setprofit.ant[4], setprofit.ant[5], setprofit.ant[6]
				profit_money.rec[1], profit_money.rec[2], profit_money.rec[3], profit_money.rec[4], profit_money.rec[5], profit_money.rec[6], profit_money.rec[7] = 										  0, setprofit.rec[1], setprofit.rec[2], setprofit.rec[3], setprofit.rec[4], setprofit.rec[5], setprofit.rec[6]
				profit_money.medcam[1], profit_money.medcam[2], profit_money.medcam[3], profit_money.medcam[4], profit_money.medcam[5], profit_money.medcam[6], profit_money.medcam[7] = 		 			  0, setprofit.medcam[1], setprofit.medcam[2], setprofit.medcam[3], setprofit.medcam[4], setprofit.medcam[5], setprofit.medcam[6]
				profit_money.cure[1], profit_money.cure[2], profit_money.cure[3], profit_money.cure[4], profit_money.cure[5], profit_money.cure[6], profit_money.cure[7] = 								   	  0, setprofit.cure[1], setprofit.cure[2], setprofit.cure[3], setprofit.cure[4], setprofit.cure[5], setprofit.cure[6]
				profit_money.strah[1], profit_money.strah[2], profit_money.strah[3], profit_money.strah[4], profit_money.strah[5], profit_money.strah[6], profit_money.strah[7] = 							  0, setprofit.strah[1], setprofit.strah[2], setprofit.strah[3], setprofit.strah[4], setprofit.strah[5], setprofit.strah[6]
				profit_money.tatu[1], profit_money.tatu[2], profit_money.tatu[3], profit_money.tatu[4], profit_money.tatu[5], profit_money.tatu[6], profit_money.tatu[7] = 								  	  0, setprofit.tatu[1], setprofit.tatu[2], setprofit.tatu[3], setprofit.tatu[4], setprofit.tatu[5], setprofit.tatu[6]
				profit_money.premium[1], profit_money.premium[2], profit_money.premium[3], profit_money.premium[4], profit_money.premium[5], profit_money.premium[6], profit_money.premium[7] =			  	  0, setprofit.premium[1], setprofit.premium[2], setprofit.premium[3], setprofit.premium[4], setprofit.premium[5], setprofit.premium[6]
				profit_money.other[1], profit_money.other[2], profit_money.other[3], profit_money.other[4], profit_money.other[5], profit_money.other[6], profit_money.other[7] = 				 			  0, setprofit.other[1], setprofit.other[2], setprofit.other[3], setprofit.other[4], setprofit.other[5], setprofit.other[6]
			end
				profit_money.total_week = profit_money.payday[1] + profit_money.payday[2] + profit_money.payday[3] + profit_money.payday[4] + profit_money.payday[5] + profit_money.payday[6] + profit_money.payday[7] +
				profit_money.lec[1] + profit_money.lec[2] + profit_money.lec[3] + profit_money.lec[4] + profit_money.lec[5] + profit_money.lec[6] + profit_money.lec[7] +
				profit_money.medcard[1] + profit_money.medcard[2] + profit_money.medcard[3] + profit_money.medcard[4] + profit_money.medcard[5] + profit_money.medcard[6] + profit_money.medcard[7] +
				profit_money.narko[1] + profit_money.narko[2] + profit_money.narko[3] + profit_money.narko[4] + profit_money.narko[5] + profit_money.narko[6] + profit_money.narko[7] +
				profit_money.vac[1] + profit_money.vac[2] + profit_money.vac[3] + profit_money.vac[4] + profit_money.vac[5] + profit_money.vac[6] + profit_money.vac[7] +
				profit_money.ant[1] + profit_money.ant[2] + profit_money.ant[3] + profit_money.ant[4] + profit_money.ant[5] + profit_money.ant[6] + profit_money.ant[7] +
				profit_money.rec[1] + profit_money.rec[2] + profit_money.rec[3] + profit_money.rec[4] + profit_money.rec[5] + profit_money.rec[6] + profit_money.rec[7] +
				profit_money.medcam[1] + profit_money.medcam[2] + profit_money.medcam[3] + profit_money.medcam[4] + profit_money.medcam[5] + profit_money.medcam[6] + profit_money.medcam[7] +
				profit_money.cure[1] + profit_money.cure[2] + profit_money.cure[3] + profit_money.cure[4] + profit_money.cure[5] + profit_money.cure[6] + profit_money.cure[7] +
				profit_money.strah[1] + profit_money.strah[2] + profit_money.strah[3] + profit_money.strah[4] + profit_money.strah[5] + profit_money.strah[6] + profit_money.strah[7] +
				profit_money.tatu[1] + profit_money.tatu[2] + profit_money.tatu[3] + profit_money.tatu[4] + profit_money.tatu[5] + profit_money.tatu[6] + profit_money.tatu[7] +
				profit_money.premium[1] + profit_money.premium[2] + profit_money.premium[3] + profit_money.premium[4] + profit_money.premium[5] + profit_money.premium[6] + profit_money.premium[7] +
				profit_money.other[1] + profit_money.other[2] + profit_money.other[3] + profit_money.other[4] + profit_money.other[5] + profit_money.other[6] + profit_money.other[7]
				local f = io.open(dirml.."/MedicalHelper/profit.med", "w")
				f:write(encodeJson(profit_money))
				f:flush()
				f:close()
		else
			os.remove(dirml.."/MedicalHelper/profit.med")
			print("{F54A4A}Ошибка. Файл настроек прибыли повреждён.")
			print("{82E28C}Пересоздание файла настроек прибыли...")
			local f = io.open(dirml.."/MedicalHelper/profit.med", "w")
			f:write(encodeJson(profit_money))
			f:flush()
			f:close()
		end
	else
		print("{F54A4A}Ошибка. Файл настроек прибыли не найден.")
		print("{82E28C}Создание файла настроек прибыли...")
		if not doesFileExist(dirml.."/MedicalHelper/profit.med") then
			local f = io.open(dirml.."/MedicalHelper/profit.med", "w")
			f:write(encodeJson(profit_money))
			f:flush()
			f:close()
		end
	end
	if doesFileExist(dirml.."/MedicalHelper/onlinestat.med") then
		print("{82E28C}Чтение информации онлайна...")
		local f = io.open(dirml.."/MedicalHelper/onlinestat.med")
		local seton = f:read("*a")
		f:close()
		local res, setonline = pcall(decodeJson, seton)
		if res and type(setonline) == "table" then 
			online_stat = setonline 
			online_stat.date_today[1] = os.date("%d") + 0
			online_stat.date_today[2] = os.date("%m") + 0
			online_stat.date_today[3] = os.date("%Y") + 0
			if online_stat.date_today[1] ~= online_stat.date_last[1] or online_stat.date_today[2] ~= online_stat.date_last[2] or online_stat.date_today[3] ~= online_stat.date_last[3] then
				online_stat.date_num[1] = online_stat.date_num[1] + 1
			end
			if online_stat.date_num[1] > online_stat.date_num[2] then --> Если сегодняшняя дата отличается от вчерашней
				online_stat.date_last[1] = os.date("%d") + 0
				online_stat.date_last[2] = os.date("%m") + 0
				online_stat.date_last[3] = os.date("%Y") + 0
				online_stat.date_num[2] = online_stat.date_num[1]
				online_stat.date_week[1], online_stat.date_week[2], online_stat.date_week[3], online_stat.date_week[4], online_stat.date_week[5], online_stat.date_week[6], online_stat.date_week[7] = os.date("%d.%m.%Y"), setonline.date_week[1], setonline.date_week[2], setonline.date_week[3], setonline.date_week[4], setonline.date_week[5], setonline.date_week[6]
				online_stat.clean[1], online_stat.clean[2], online_stat.clean[3], online_stat.clean[4], online_stat.clean[5], online_stat.clean[6], online_stat.clean[7] = 		 			  0, setonline.clean[1], setonline.clean[2], setonline.clean[3], setonline.clean[4], setonline.clean[5], setonline.clean[6]
				online_stat.afk[1], online_stat.afk[2], online_stat.afk[3], online_stat.afk[4], online_stat.afk[5], online_stat.afk[6], online_stat.afk[7] = 										  0, setonline.afk[1], setonline.afk[2], setonline.afk[3], setonline.afk[4], setonline.afk[5], setonline.afk[6]
				online_stat.all[1], online_stat.all[2], online_stat.all[3], online_stat.all[4], online_stat.all[5], online_stat.all[6], online_stat.all[7] = 										  0, setonline.all[1], setonline.all[2], setonline.all[3], setonline.all[4], setonline.all[5], setonline.all[6]
			end
			local f = io.open(dirml.."/MedicalHelper/onlinestat.med", "w")
			f:write(encodeJson(online_stat))
			f:flush()
			f:close()
		else
			os.remove(dirml.."/MedicalHelper/onlinestat.med")
			print("{F54A4A}Ошибка. Файл информации онлайна повреждён.")
			print("{82E28C}Пересоздание файла информации онлайна...")
			local f = io.open(dirml.."/MedicalHelper/onlinestat.med", "w")
			f:write(encodeJson(online_stat))
			f:flush()
			f:close()
		end
	else
		print("{F54A4A}Ошибка. Файл информации онлайна не найден.")
		print("{82E28C}Создание файла информации онлайна...")
		if not doesFileExist(dirml.."/MedicalHelper/onlinestat.med") then
			local f = io.open(dirml.."/MedicalHelper/onlinestat.med", "w")
			f:write(encodeJson(online_stat))
			f:flush()
			f:close()
		end
	end
	
	if doesFileExist(dirml.."/MedicalHelper/reminders.med") then
		print("{82E28C}Чтение файла напоминаний...")
		local f = io.open(dirml.."/MedicalHelper/reminders.med")
		local seton = f:read("*a")
		f:close()
		local res, setreminer = pcall(decodeJson, seton)
		if res and type(setreminer) == "table" then 
			reminder = setreminer
		else
			os.remove(dirml.."/MedicalHelper/reminders.med")
			print("{F54A4A}Ошибка. Файл напоминаний повреждён.")
			print("{82E28C}Пересоздание файла напоминаний...")
			local f = io.open(dirml.."/MedicalHelper/reminders.med", "w")
			f:write(encodeJson(reminder))
			f:flush()
			f:close()
		end
	else
		print("{F54A4A}Ошибка. Файл напоминаний не найден.")
		print("{82E28C}Создание файла напоминаний...")
		if not doesFileExist(dirml.."/MedicalHelper/reminders.med") then
			local f = io.open(dirml.."/MedicalHelper/reminders.med", "w")
			f:write(encodeJson(reminder))
			f:flush()
			f:close()
		end
	end
	
	local function settingMassiveStart()
		setting.nick = u8:decode(buf_nick.v)
		setting.teg = u8:decode(buf_teg.v)
		setting.org = num_org.v
		setting.sex = num_sex.v
		setting.rank = num_rank.v
		setting.time = cb_time.v
		setting.timeTx = u8:decode(buf_time.v)
		setting.timeDo = cb_timeDo.v
		setting.rac = cb_rac.v
		setting.racTx = u8:decode(buf_rac.v)
		setting.lec = buf_lec.v
		setting.rec = buf_rec.v
		setting.narko = buf_narko.v
		setting.tatu = buf_tatu.v
		setting.ant = buf_ant.v
		setting.chat1 = cb_chat1.v
		setting.chat2 = cb_chat2.v
		setting.chat3 = cb_chat3.v
		setting.chathud = cb_hud.v
		setting.arp = arep
		setting.setver = setver
		setting.htime = cb_hudTime.v
		setting.hping = hudPing
		setting.orgl = {}
		setting.rankl = {}
		setting.theme = num_theme.v
	end
	_, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
	myNick = sampGetPlayerNickname(myid)
	mynickname = trst(myNick)
	if doesFileExist(dirml.."/MedicalHelper/MainSetting.med") then
		print("{82E28C}Чтение настроек...")
		local f = io.open(dirml.."/MedicalHelper/MainSetting.med")
		local setf = f:read("*a")
		f:close()
		local res, set = pcall(decodeJson, setf)
		if res and type(set) == "table" then 
			buf_nick.v = u8(set.nick)
			buf_teg.v = u8(set.teg)
			num_org.v = set.org
			num_sex.v = set.sex
			num_rank.v = set.rank
			cb_time.v = set.time
			buf_time.v = u8(set.timeTx)
			cb_timeDo.v = set.timeDo
			cb_rac.v = set.rac
			buf_rac.v = u8(set.racTx)
			buf_lec.v = u8(set.lec)
			buf_rec.v = u8(set.rec)
			buf_narko.v = u8(set.narko)
			buf_tatu.v = u8(set.tatu)
			buf_ant.v = u8(set.ant)
			cb_chat1.v = set.chat1
			cb_chat2.v = set.chat2
			cb_chat3.v = set.chat3
			cb_hud.v = set.chathud
			arep = set.arp
			setver = set.setver
			hudPing = set.hping
			cb_hudTime.v = set.htime
			if check_table('theme', set, 1) then
				num_theme.v = set.theme
				num_themeTest = set.theme
			else
				settingMassiveStart()
				local f = io.open(dirml.."/MedicalHelper/MainSetting.med", "w")
				f:write(encodeJson(setting))
				f:flush()
				f:close()
			end
			if check_table('mede', set, 1) then
				for i = 1, 4 do
					buf_mede[i].v = u8(set.mede[i])
					buf_upmede[i].v = u8(set.upmede[i])
				end
				accept_spawn.v = set.spawn
				accept_autolec.v = set.autolec
				prikol.v = set.prikol
			else
				settingMassiveStart()
				for i = 1, 4 do
					setting.mede[i] = buf_mede[i].v
					setting.upmede[i] = buf_upmede[i].v
				end
				setting.spawn = accept_spawn.v
				setting.autolec = accept_autolec.v
				setting.prikol = prikol.v
				local f = io.open(dirml.."/MedicalHelper/MainSetting.med", "w")
				f:write(encodeJson(setting))
				f:flush()
				f:close()
			end
			if set.orgl then
				for i,v in ipairs(set.orgl) do
					chgName.org[tonumber(i)] = u8(v)
				end
			end
			if set.rankl then
				for i,v in ipairs(set.rankl) do
					chgName.rank[tonumber(i)] = u8(v)
				end
			end
		else
			os.remove(dirml.."/MedicalHelper/MainSetting.med")
			print("{F54A4A}Ошибка. Файл настроек повреждён.")
			print("{82E28C}Создание новых собственных настроек...")
			buf_nick.v = u8(mynickname)
			buf_lec.v = "10000"
			buf_mede[1].v = "20000"
			buf_mede[2].v = "40000"
			buf_mede[3].v = "60000"
			buf_mede[4].v = "80000"
			buf_upmede[1].v = "40000"
			buf_upmede[2].v = "60000"
			buf_upmede[3].v = "80000"
			buf_upmede[4].v = "100000"
			buf_narko.v = "100000"
			buf_tatu.v = "50000"
			buf_rec.v = "30000"
			buf_ant.v = "25000"
			num_theme.v = 0
			buf_time.v = u8"/me посмотрел на часы с гравировкой \"Made in China\""
			buf_rac.v = u8"/me сняв рацию с пояса, что-то сказал в неё"
		end
	else
		print("{F54A4A}Ошибка. Файл настроек не найден.")
		print("{82E28C}Создание собственных настроек...")
		buf_nick.v = u8(mynickname)
		buf_lec.v = "10000"
		buf_mede[1].v = "20000"
		buf_mede[2].v = "40000"
		buf_mede[3].v = "60000"
		buf_mede[4].v = "80000"
		buf_upmede[1].v = "40000"
		buf_upmede[2].v = "60000"
		buf_upmede[3].v = "80000"
		buf_upmede[4].v = "100000"
		buf_narko.v = "100000"
		buf_tatu.v = "50000"
		buf_rec.v = "30000"
		buf_ant.v = "25000"
		num_theme.v = 0
		buf_time.v = u8"/me посмотрел на часы с гравировкой \"Made in China\""
		buf_rac.v = u8"/me сняв рацию с пояса, что-то сказал в неё"	
	end
	print("{82E28C}Чтение настроек команд...")
	if doesFileExist(dirml.."/MedicalHelper/cmdSetting.med") then
		local f = io.open(dirml.."/MedicalHelper/cmdSetting.med")
		local res, keys = pcall(decodeJson, f:read("*a"))
		f:flush()
		f:close()
		if res and type(keys) == "table" then
			for i, v in ipairs(keys) do
				cmdBind[i].cmd = v.cmd
				if #v.key > 0 then
					rkeys.registerHotKey(v.key, true, onHotKeyCMD)
					cmdBind[i].key = v.key
					table.insert(keysList, v.key)
				end
			end
		else
			print("{82E28C}Применины стандартные настройки команд")
			os.remove(dirml.."/MedicalHelper/cmdSetting.med")
		end
	end
	print("{82E28C}Чтение настроек биндера...")
	if doesFileExist(dirml.."/MedicalHelper/bindSetting.med") then
		local f = io.open(dirml.."/MedicalHelper/bindSetting.med")
		local res, list = pcall(decodeJson, f:read("*a"))
		f:flush()
		f:close()
		if res and type(list) == "table" then
			binder.list = list
			for i, v in ipairs(binder.list) do
				if #v.key > 0 then
					binder.list[i].key = v.key
					rkeys.registerHotKey(v.key, true, onHotKeyBIND)
					table.insert(keysList, v.key)
				end
			end
		else
			os.remove(dirml.."/MedicalHelper/bindSetting.med")
			print("{F54A4A}Ошибка. Файл настроек биндера повреждён.")
			print("{82E28C}Применины стандартные настройки")
		end
	else 
		print("{82E28C}Применины стандартные настройки биндера")
	end
	lockPlayerControl(false)
	sampfuncsRegisterConsoleCommand("arep", function(bool) 
		if tonumber(bool) == 1 then 
			arep = true 
		else 
			arep = false 
		end 
	end)
	function styleWin()
		imgui.SwitchContext()
		local style = imgui.GetStyle()
		local colors = style.Colors
		local clr = imgui.Col
		local ImVec4 = imgui.ImVec4
		local ImVec4Choice = imgui.ImVec4(col_interface.v[1], col_interface.v[2], col_interface.v[3], col_interface.v[4])
		style.WindowRounding = 15.0
		style.ChildWindowRounding = 10.0
		style.FrameRounding = 8.0
		style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		style.ScrollbarSize = 15.0
		style.FramePadding = imgui.ImVec2(5, 3)
		style.ItemSpacing = imgui.ImVec2(5.0, 4.0)
		style.ScrollbarRounding = 0
		style.GrabMinSize = 18.0
		style.GrabRounding = 4.0
		style.ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		
		colors[clr.FrameBg] 			   = ImVec4(0.35, 0.35, 0.35, 1.00)
		colors[clr.FrameBgHovered]         = ImVec4(0.55, 0.55, 0.55, 1.00)
		colors[clr.FrameBgActive]          = ImVec4(0.30, 0.30, 0.30, 1.00)
		colors[clr.TitleBg]                = ImVec4(0.00, 0.00, 0.00, 0.50)
		colors[clr.TitleBgActive]          = imgui.ImVec4(col_interface.v[1], col_interface.v[2], col_interface.v[3], 0.90)
		colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.50)
		colors[clr.CheckMark]              = imgui.ImVec4(col_interface.v[1], col_interface.v[2], col_interface.v[3], 0.90) --!!
		colors[clr.SliderGrab]             = ImVec4Choice
		colors[clr.SliderGrabActive]       = ImVec4Choice
		colors[clr.Button]                 = imgui.ImVec4(1.00, 1.00, 1.00, 0.23)
		colors[clr.ButtonHovered]          = imgui.ImVec4(1.00, 1.00, 1.00, 0.31)
		colors[clr.ButtonActive]           = imgui.ImVec4(1.00, 1.00, 1.00, 0.12)
		colors[clr.Header]                 = imgui.ImVec4(col_interface.v[1], col_interface.v[2], col_interface.v[3], 0.65)
		colors[clr.HeaderHovered]          = imgui.ImVec4(col_interface.v[1], col_interface.v[2], col_interface.v[3], 0.80)
		colors[clr.HeaderActive]           = imgui.ImVec4(col_interface.v[1], col_interface.v[2], col_interface.v[3], 0.90)
		colors[clr.Separator]              = imgui.ImVec4(0.37, 0.37, 0.37, 0.60)
		colors[clr.SeparatorHovered]       = imgui.ImVec4(0.37, 0.37, 0.37, 0.60)
		colors[clr.SeparatorActive]        = imgui.ImVec4(0.37, 0.37, 0.37, 0.60)
		colors[clr.ResizeGrip]             = ImVec4Choice
		colors[clr.ResizeGripHovered]      = ImVec4Choice
		colors[clr.ResizeGripActive]       = ImVec4Choice
		colors[clr.TextSelectedBg]         = ImVec4Choice
		colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
		colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
		colors[clr.WindowBg]               = ImVec4(0.08, 0.08, 0.08, 1.00)
		colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
		colors[clr.PopupBg]                = ImVec4(0.12, 0.12, 0.12, 1.00)
		colors[clr.ComboBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
		colors[clr.Border]                 = imgui.ImVec4(col_interface.v[1], col_interface.v[2], col_interface.v[3], 0.50)
		colors[clr.BorderShadow]           = ImVec4(0.26, 0.59, 0.98, 0.00)
		colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
		colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
		colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
		colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
		colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
		colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
		colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
		colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
		colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
	
		colBut = colors[clr.Button]
		colButActive = colors[clr.ButtonActive]
		colButActiveMenu = imgui.ImColor(col_interface.v[1]*255, col_interface.v[2]*255, col_interface.v[3]*255, 204):GetVec4()
		ButtonNoAct = imgui.ImColor(20, 20, 20, 220):GetVec4()
		colors[clr.Border] = colBut
	end
	styleWin()
	sampRegCMDLoadScript()
	repeat wait(100) until sampIsLocalPlayerSpawned()
	_, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
	myNick = getPlayerNickName(myid) 
	sampAddChatMessage(string.format("{FF8FA2}[Medical Helper]{FFFFFF} %s, для активации главного меню, отправьте в чат {a8a8a8}/"..cmdBind[1].cmd, getPlayerNickName(myid):gsub("_"," ")), 0xFF8FA2)
	wait(200)
	if buf_nick.v == "" then  
		sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} Обнаружилось, что у Вас не настроена основная информация.", 0xFF8FA2)
		sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} Зайдите в главном меню в раздел \"Настройки\" и заполните необходимую информацию.", 0xFF8FA2)
	end
	--// ПРОВЕРКА ОБНОВЛЕНИЙ
	lua_thread.create(funCMD.updateCheck)
	lua_thread.create(time)
	lua_thread.create(saveCounOnl)
	lua_thread.create(membfunc)
	while true do wait(0)
		if sampIsDialogActive() then
    		lastDialogWasActive = os.clock()
    	end
		resTarg, pedTar = getCharPlayerIsTargeting(PLAYER_HANDLE)
		if resTarg then
			_, targID = sampGetPlayerIdByCharHandle(pedTar)
			if setting2.funcPKM.func then
			renderFontDrawText(fontPD, "[{F25D33}Num 2{FFFFFF}] - Вылечить игрока с ID "..targID, sx-350, sy-30, 0xFFFFFFFF)
				if isKeyJustPressed(VK_R) then
					if #optionsPKM > 13 then
						for m = 14, #optionsPKM do
							table.remove(optionsPKM, 14)
						end
						for m = 1, #binder.list do
							optionsPKM[m + 13] = u8(binder.list[m].name)
						end
					else
						for m = 1, #binder.list do
							optionsPKM[m + 13] = u8(binder.list[m].name)
						end
					end
					choiceWin.v = true
					imgui.ShowCursor = true
					_, targetID = sampGetPlayerIdByCharHandle(pedTar)
				end
			end
			renderFontDrawText(fontPD, "[{F25D33}R{FFFFFF}] - Открыть действия с ID "..targID, sx-350, sy-60, 0xFFFFFFFF)
		end
	if status_track_pl ~= "STOP" and player_HUD.v then
		musicHUD.v = true
	else
		musicHUD.v = false
	end
	if not isGamePaused() and status_track_pl ~= 'STOP' then
		stalecatin()
	elseif isGamePaused() and status_track_pl == 'PLAY' then
		if get_status_potok_song() == 1 then
			bass.BASS_ChannelPause(stream_music)
		end
	end
	if vaccine_two then
		if vactimer[1] >= 0 and vactimer[2] >= 0 then
			if not isGamePaused() then
				local timervac = {string.len(tostring(vactimer[1])), string.len(tostring(vactimer[2]))}
				if timervac[1] == 1 then
					minutevac = "0"..vactimer[1]
				else
					minutevac = vactimer[1]
				end
				if timervac[2] == 1 then
					hourvac = "0"..vactimer[2]
				else
					hourvac = vactimer[2]
				end
				renderFontDrawText(fontPD, "{FFFFFF}Таймер вакцинации:\n           {11B835}"..hourvac.."{FFFFFF}:{11B835}"..minutevac, sx-200, sy-60, 0xFFFFFFFF)
				renderFontDrawText(fontPD, "Таймер вакцины: [{F25D33}Delete{FFFFFF}] - Приостановить", 20, sy-30, 0xFFFFFFFF)
			end
		else
			if not isGamePaused() then
				renderFontDrawText(fontPD, "  [{11B835}Num 1{FFFFFF}] - Поставить вакцину.\n [{F25D33}Delete{FFFFFF}] - Отменить.", sx-300, sy-60, 0xFFFFFFFF)
			end
			if isKeyJustPressed(VK_1) then
				vaccine_two = false
				funCMD.vac(vaccine_id)
			end
		end
		if isKeyJustPressed(VK_DELETE) then
			vaccine_two = false
		end
	end
	if thread:status() ~= "dead" and not isGamePaused() then
		renderFontDrawText(fontPD, "Отыгровка: [{F25D33}Page Down{FFFFFF}] - Приостановить", 20, sy-30, 0xFFFFFFFF)
		if isKeyJustPressed(VK_NEXT) and not sampIsChatInputActive() and not sampIsDialogActive() then
			thread:terminate()
			statusvac = false
		end
	end
	if sampIsDialogActive() then
		if arep then
			local idD = sampGetCurrentDialogId()
			if idD == 1333 then
				HideDialog()
			lockPlayerControl(false)
			end
		end
	end
	if cb_hud.v then showInputHelp() end
	if cb_hudTime.v and not isPauseMenuActive() then hudTimeF() end
	imgui.Process = mainWin.v or iconwin.v or sobWin.v or depWin.v or updWin.v or spurBig.v or choiceWin.v or musicHUD.v or ReminderWin.v
	if C_membScr.func.v and isCursorAvailable() and isKeyJustPressed(0xA5) then
    	script_cursor = not script_cursor
    	showCursor(script_cursor, false)
    end
	------------------------------------------------------------RNDER
	if C_membScr.func.v and not isGamePaused() and ((C_membScr.dialog.v and not sampIsDialogActive() and not sampIsCursorActive() and not sampIsChatInputActive() and not isSampfuncsConsoleActive()) or not C_membScr.dialog.v) then
	    	rendering_func()
		end
	------------------------------------------------------------RNDER
	end
end

function rendering_func()
	local X, Y = C_membScr.pos.x.v, C_membScr.pos.y.v
	local title = string.format('%s | Онлайн: %s%s', org.name, org.online, (C_membScr.afk.v and (' (%s в АФК)'):format(org.afk) or ''))
	local col_title = changeColorAlpha(C_membScr.color.col_title, C_membScr.font.visible.v)
	if C_membScr.vergor.v then
		if renderFontDrawClickableText(script_cursor, fontes, title, X, Y - C_membScr.font.distance.v - 5, col_title, col_title, 4, false) then
			sampSendChat('/members')
		end
	else
		if renderFontDrawClickableText(script_cursor, fontes, title, X, Y - C_membScr.font.distance.v - 5, col_title, col_title, 3, false) then
			sampSendChat('/members')
		end
	end
	if org.name == 'Гражданин' then
		if C_membScr.vergor.v then
		renderFontDrawClickableText(script_cursor, fontes, 'Вы не состоите в организации', X, Y, 0xAAFFFFFF, 0xAAFFFFFF,  4, false)
		else
		renderFontDrawClickableText(script_cursor, fontes, 'Вы не состоите в организации', X, Y, 0xAAFFFFFF, 0xAAFFFFFF,  3, false)
		end
	elseif #members > 0 then
		for i, member in ipairs(members) do
			if i <= tonumber(org.online) then
				local color = changeColorAlpha(C_membScr.forma.v and (member.uniform and C_membScr.color.col_default or C_membScr.color.col_no_work) or C_membScr.color.col_default, C_membScr.font.visible.v)
				local rank = C_membScr.numrank.v and string.format('[%s]', member.rank.count) or nil
				local nick = member.nick .. (C_membScr.id.v and string.format('(%s)', member.id) or '')
				local afk = C_membScr.afk.v and string.format(' (AFK: %s)', member.afk) or ''
				local out_string
				if C_membScr.vergor.v then
					out_string = ('%s%s%s'):format(rank and rank .. ' ' or '', nick, afk)
					renderFontDrawClickableText(script_cursor, fontes, out_string, X, Y, color, color,  4, true) --C_membScr.vergor.v
				else
					out_string = ('%s%s%s'):format(rank and rank .. ' ' or '', nick, afk)
					renderFontDrawClickableText(script_cursor, fontes, out_string, X, Y, color, color,  3, true)
				end
				Y = Y + C_membScr.font.distance.v
			end
		end
	else
		if C_membScr.vergor.v then
			renderFontDrawClickableText(script_cursor, fontes, 'Ни один игрок не найден', X, Y, 0xAAFFFFFF, 0xAAFFFFFF,  4, false)
		else
			renderFontDrawClickableText(script_cursor, fontes, 'Ни один игрок не найден', X, Y, 0xAAFFFFFF, 0xAAFFFFFF,  3, false)
		end
	end
end

function back_track()
	if menu_play_track[1] then
		if selectis > 1 and tracks.link[selectis] == url_track_pack then
			selectis = selectis - 1
			imgNoLabel = imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/nolabel.png")
			play_song(tracks.link[selectis], false)
			download_id = downloadUrlToFile(tracks.image[selectis], getWorkingDirectory().."/MedicalHelper/label.png", function(id, status, p1, p2)
				if status == dlstatus.STATUS_ENDDOWNLOADDATA then
					statusimage = selectis
					imgLabel = imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/label.png")
				end
			end)
		elseif selectis == 1 or tracks.link[selectis] ~= url_track_pack then
			action_song('STOP')
			selectis = 0
			menu_play_track = {false, false, false}
			status_track_pl = 'STOP'
		end
	elseif menu_play_track[2] then
		if selectis > 1 and save_tracks.link[selectis - 1] ~= nil then
			selectis = selectis - 1
			imgNoLabel = imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/nolabel.png")
			play_song(save_tracks.link[selectis], false)
			download_id = downloadUrlToFile(save_tracks.image[selectis], getWorkingDirectory().."/MedicalHelper/label.png", function(id, status, p1, p2)
				if status == dlstatus.STATUS_ENDDOWNLOADDATA then
					statusimage = selectis
					imgLabel = imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/label.png")
				end
			end)
		elseif selectis == 1 or save_tracks.link[selectis - 1] == nil then
			action_song('STOP')
			selectis = 0
			menu_play_track = {false, false, false}
			status_track_pl = 'STOP'
		end
	end
end

function next_track()
	if menu_play_track[1] then
		if selectis ~= 0 and selectis < #tracks.link and tracks.link[selectis] == url_track_pack then
			selectis = selectis + 1
			imgNoLabel = imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/nolabel.png")
			play_song(tracks.link[selectis], false)
			download_id = downloadUrlToFile(tracks.image[selectis], getWorkingDirectory().."/MedicalHelper/label.png", function(id, status, p1, p2)
				if status == dlstatus.STATUS_ENDDOWNLOADDATA then
					statusimage = selectis
					imgLabel = imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/label.png")
				end
			end)
		elseif (selectis ~= 0 and selectis == #tracks.link) or tracks.link[selectis] ~= url_track_pack then
			action_song('STOP')
			selectis = 0
			menu_play_track = {false, false, false}
			status_track_pl = 'STOP'
		end
	elseif menu_play_track[2] then
		if selectis ~= 0 and selectis < #save_tracks.link and save_tracks.link[selectis + 1] ~= nil then
			selectis = selectis + 1
			imgNoLabel = imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/nolabel.png")
			play_song(save_tracks.link[selectis], false)
			download_id = downloadUrlToFile(save_tracks.image[selectis], getWorkingDirectory().."/MedicalHelper/label.png", function(id, status, p1, p2)
				if status == dlstatus.STATUS_ENDDOWNLOADDATA then
					statusimage = selectis
					imgLabel = imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/label.png")
				end
			end)
		elseif (selectis ~= 0 and selectis == #save_tracks.link) or save_tracks.link[selectis + 1] == nil then
			action_song('STOP')
			selectis = 0
			menu_play_track = {false, false, false}
			status_track_pl = 'STOP'
		end
	end
end

function stalecatin()
	if get_status_potok_song() == 3 and status_track_pl == 'PLAY' then
		action_song('PLAY')
	elseif get_status_potok_song() == 0 and status_track_pl == 'PLAY' then
		if repeatmusic.v then
			play_song(url_track_pack, false)
		else
			next_track()
		end
	end
end

function Window_Reminder(param)
	if ReminderWin.v then ReminderWin.v = false end
	remin_text = param.text
	ReminderWin.v = true
	if param.sound then
		sound_reminder = lua_thread.create(function()
			local stap = 0
			while true do
				repeat wait(200) 
					addOneOffSound(0, 0, 0, 1057)
					stap = stap + 1
				until stap > 15
				wait(5000)
				stap = 0
			end
		end)
	end
end

--> Анимация окон имгуи
local swx, shy = getScreenResolution()
local posWinStarted = {x = 1, y = 1}
local posWinClosed

local animka_main = {MoveAnim = false, paramOff = false, posX = 0, posY = 0} --> mainWin
local animka_dep = {MoveAnim = false, paramOff = false, posX = 0, posY = 0} --> depWin
local animka_sob = {MoveAnim = false, paramOff = false, posX = 0, posY = 0} --> sobWin
local animka_upd = {MoveAnim = false, paramOff = false, posX = 0, posY = 0} --> updWin
local animka_big = {MoveAnim = false, paramOff = false, posX = 0, posY = 0} --> spurBig

function styleAnimationOpen(idWin)
	local fps = mem.getfloat(0xB7CB50, true)
	local pert = 15
	if fps < 60 and fps >= 50 then
		pert = 20
	elseif fps < 50 and fps >= 40 then
		pert = 40
	elseif fps < 40 and fps >= 30 then
		pert = 70
	elseif fps < 30 then
		pert = 120
	end
	if idWin == 1 then --> mainWin
		animka_main.posY = shy / 2
		animka_main.posX = swx * 2
		
		lua_thread.create(function()
			animka_main.MoveAnim = true
			repeat wait(0)
				animka_main.posX = (animka_main.posX/1.04) - pert
				pert = pert
			until animka_main.posX < swx/2
			animka_main.MoveAnim = false
		end)
	end
	if idWin == 2 then --> depWin
		animka_dep.posY = shy / 2
		animka_dep.posX = swx * 2
		lua_thread.create(function()
			animka_dep.MoveAnim = true
			repeat wait(0)
				animka_dep.posX = (animka_dep.posX/1.04) - pert
				pert = pert
			until animka_dep.posX < swx/2
			animka_dep.MoveAnim = false
		end)
	end
	if idWin == 3 then --> sobWin
		animka_sob.posY = shy / 2
		animka_sob.posX = swx * 2
		lua_thread.create(function()
			animka_sob.MoveAnim = true
			repeat wait(0)
				animka_sob.posX = (animka_sob.posX/1.04) - pert
				pert = pert
			until animka_sob.posX < swx/2
			animka_sob.MoveAnim = false
		end)
	end
	if idWin == 4 then --> updWin
		animka_upd.posY = shy / 2
		animka_upd.posX = swx * 2
		lua_thread.create(function()
			animka_upd.MoveAnim = true
			repeat wait(0)
				animka_upd.posX = (animka_upd.posX/1.04) - pert
				pert = pert
			until animka_upd.posX < swx/2
			animka_upd.MoveAnim = false
		end)
	end
	if idWin == 5 then --> spurBig
		animka_big.posY = shy / 2
		animka_big.posX = swx * 2
		lua_thread.create(function()
			animka_big.MoveAnim = true
			repeat wait(0)
				animka_big.posX = (animka_big.posX/1.04) - pert
				pert = pert
			until animka_big.posX < swx/2
			animka_big.MoveAnim = false
		end)
	end
	imgui.ShowCursor = true
end

function styleAnimationClose(idWin, xWin, yWin)
	local fps = mem.getfloat(0xB7CB50, true)
	local pert = 18
	if fps < 60 and fps >= 50 then
		pert = 20
	elseif fps < 50 and fps >= 40 then
		pert = 40
	elseif fps < 40 and fps >= 30 then
		pert = 70
	elseif fps < 30 then
		pert = 120
	end
	if idWin == 1 then --> mainWin
		if not depWin.v and not iconwin.v and not sobWin.v and not updWin.v and not spurBig.v then
			imgui.ShowCursor = false
		end
		animka_main.posY = posWinClosed.y + (yWin/2)
		if posWinClosed.x > 0 then
			animka_main.posX = posWinClosed.x + (xWin/2)
		else
			animka_main.posX = xWin/2
		end
		lua_thread.create(function()
			animka_main.MoveAnim = true
			repeat wait(0)
				animka_main.posX = (animka_main.posX*1.04) + pert
				pert = pert
			until animka_main.posX > swx + xWin
			mainWin.v = false
			animka_main.MoveAnim = false
			imgui.ShowCursor = true
			showCursor(false)
		end)
	end
	if idWin == 2 then --> depWin
		if not mainWin.v and not iconwin.v and not sobWin.v and not updWin.v and not spurBig.v then
			imgui.ShowCursor = false
		end
		animka_dep.posY = posWinClosed.y + (yWin/2)
		if posWinClosed.x > 0 then
			animka_dep.posX = posWinClosed.x + (xWin/2)
		else
			animka_dep.posX = xWin/2
		end
		lua_thread.create(function()
			animka_dep.MoveAnim = true
			repeat wait(0)
				animka_dep.posX = (animka_dep.posX*1.04) + pert
				pert = pert
			until animka_dep.posX > swx + xWin
			depWin.v = false
			animka_dep.MoveAnim = false
			imgui.ShowCursor = true
			showCursor(false)
		end)
	end
	if idWin == 3 then --> sobWin
		if not mainWin.v and not iconwin.v and not depWin.v and not updWin.v and not spurBig.v then
			imgui.ShowCursor = false
		end
		animka_sob.posY = posWinClosed.y + (yWin/2)
		if posWinClosed.x > 0 then
			animka_sob.posX = posWinClosed.x + (xWin/2)
		else
			animka_sob.posX = xWin/2
		end
		lua_thread.create(function()
			animka_sob.MoveAnim = true
			repeat wait(0)
				animka_sob.posX = (animka_sob.posX*1.04) + pert
				pert = pert
			until animka_sob.posX > swx + xWin
			sobWin.v = false
			animka_sob.MoveAnim = false
			imgui.ShowCursor = true
			showCursor(false)
		end)
	end
	if idWin == 4 then --> updWin
		if not mainWin.v and not iconwin.v and not depWin.v and not sobWin.v and not spurBig.v then
			imgui.ShowCursor = false
		end
		animka_upd.posY = posWinClosed.y + (yWin/2)
		if posWinClosed.x > 0 then
			animka_upd.posX = posWinClosed.x + (xWin/2)
		else
			animka_upd.posX = xWin/2
		end
		lua_thread.create(function()
			animka_upd.MoveAnim = true
			repeat wait(0)
				animka_upd.posX = (animka_upd.posX*1.04) + pert
				pert = pert
			until animka_upd.posX > swx + xWin
			updWin.v = false
			animka_upd.MoveAnim = false
			imgui.ShowCursor = true
			showCursor(false)
		end)
	end
	if idWin == 5 then --> spurBig
		if not mainWin.v and not iconwin.v and not depWin.v and not sobWin.v and not updWin.v then
			imgui.ShowCursor = false
		end
		animka_big.posY = posWinClosed.y + (yWin/2)
		if posWinClosed.x > 0 then
			animka_big.posX = posWinClosed.x + (xWin/2)
		else
			animka_big.posX = xWin/2
		end
		lua_thread.create(function()
			animka_big.MoveAnim = true
			repeat wait(0)
				animka_big.posX = (animka_big.posX*1.04) + pert
				pert = pert
			until animka_big.posX > swx + xWin
			spurBig.v = false
			animka_big.MoveAnim = false
			imgui.ShowCursor = true
			showCursor(false)
		end)
	end
end

function sampRegCMDLoadScript()
	sampRegisterChatCommand(cmdBind[1].cmd, function()
		if not mainWin.v then
			styleAnimationOpen(1)
			mainWin.v = true
		else
			animka_main.paramOff = true
		end
	end)
	sampRegisterChatCommand(cmdBind[4].cmd, funCMD.memb)
	sampRegisterChatCommand(cmdBind[5].cmd, funCMD.lec)
	sampRegisterChatCommand(cmdBind[6].cmd, funCMD.post)
	sampRegisterChatCommand(cmdBind[7].cmd, funCMD.med)
	sampRegisterChatCommand(cmdBind[8].cmd, funCMD.narko)
	sampRegisterChatCommand(cmdBind[9].cmd, funCMD.recep)
	sampRegisterChatCommand(cmdBind[10].cmd, funCMD.osm)
	sampRegisterChatCommand(cmdBind[11].cmd, funCMD.dep)
	sampRegisterChatCommand(cmdBind[12].cmd, funCMD.sob)
	sampRegisterChatCommand(cmdBind[13].cmd, funCMD.tatu)
	sampRegisterChatCommand(cmdBind[14].cmd, funCMD.warn)
	sampRegisterChatCommand(cmdBind[15].cmd, funCMD.uwarn)
	sampRegisterChatCommand(cmdBind[16].cmd, funCMD.mute)
	sampRegisterChatCommand(cmdBind[17].cmd, funCMD.umute)
	sampRegisterChatCommand(cmdBind[18].cmd, funCMD.rank)
	sampRegisterChatCommand(cmdBind[19].cmd, funCMD.inv)
	sampRegisterChatCommand(cmdBind[20].cmd, funCMD.unv)
	sampRegisterChatCommand(cmdBind[22].cmd, funCMD.expel)
	sampRegisterChatCommand(cmdBind[23].cmd, funCMD.vac)
	sampRegisterChatCommand(cmdBind[24].cmd, funCMD.info)
	sampRegisterChatCommand(cmdBind[25].cmd, funCMD.za)
	sampRegisterChatCommand(cmdBind[26].cmd, funCMD.zd)
	sampRegisterChatCommand(cmdBind[27].cmd, funCMD.ant)
	sampRegisterChatCommand(cmdBind[28].cmd, funCMD.strah)
	sampRegisterChatCommand(cmdBind[29].cmd, funCMD.cur)
	sampRegisterChatCommand(cmdBind[32].cmd, funCMD.shpora)
	sampRegisterChatCommand(cmdBind[33].cmd, funCMD.hme)
	sampRegisterChatCommand(cmdBind[34].cmd, funCMD.show)
	sampRegisterChatCommand(cmdBind[35].cmd, funCMD.cam)
	sampRegisterChatCommand(cmdBind[36].cmd, funCMD.godeath)
	sampRegisterChatCommand("hall", funCMD.hall)
	sampRegisterChatCommand("hilka", funCMD.hilka)
	sampRegisterChatCommand("reload", function() scr:reload() end)
	sampRegisterChatCommand("updatemh", 
	function() 
		if not updWin.v then
			styleAnimationOpen(4)
			updWin.v = true
		else
			animka_upd.paramOff = true
		end
	end)
	sampRegisterChatCommand("ts", funCMD.time)
	sampRegisterChatCommand("downloadupd", downloadupd)
	--sampRegisterChatCommand("testmh", funCMD.testmh)
	sampRegisterChatCommand("mh-delete", funCMD.del)
	for i,v in ipairs(binder.list) do
		sampRegisterChatCommand(binder.list[i].cmd, function() binderCmdStart() end)
	end
end

function sampRegCMD()
	if cmdBind[selected_cmd].cmd ==	cmdBind[1].cmd then sampRegisterChatCommand(cmdBind[1].cmd, 
		function()
			if not mainWin.v then
				styleAnimationOpen(1)
				mainWin.v = true
			else
				animka_main.paramOff = true
			end
		end) 
	end
	if cmdBind[selected_cmd].cmd ==	cmdBind[4].cmd then	sampRegisterChatCommand(cmdBind[4].cmd, funCMD.memb) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[5].cmd then	sampRegisterChatCommand(cmdBind[5].cmd, funCMD.lec) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[6].cmd then	sampRegisterChatCommand(cmdBind[6].cmd, funCMD.post) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[7].cmd then	sampRegisterChatCommand(cmdBind[7].cmd, funCMD.med) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[8].cmd then	sampRegisterChatCommand(cmdBind[8].cmd, funCMD.narko) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[9].cmd then	sampRegisterChatCommand(cmdBind[9].cmd, funCMD.recep) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[10].cmd then sampRegisterChatCommand(cmdBind[10].cmd, funCMD.osm) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[11].cmd then sampRegisterChatCommand(cmdBind[11].cmd, funCMD.dep) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[12].cmd then sampRegisterChatCommand(cmdBind[12].cmd, funCMD.sob) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[13].cmd then sampRegisterChatCommand(cmdBind[13].cmd, funCMD.tatu) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[14].cmd then sampRegisterChatCommand(cmdBind[14].cmd, funCMD.warn) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[15].cmd then sampRegisterChatCommand(cmdBind[15].cmd, funCMD.uwarn) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[16].cmd then sampRegisterChatCommand(cmdBind[16].cmd, funCMD.mute) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[17].cmd then sampRegisterChatCommand(cmdBind[17].cmd, funCMD.umute) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[18].cmd then sampRegisterChatCommand(cmdBind[18].cmd, funCMD.rank) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[19].cmd then sampRegisterChatCommand(cmdBind[19].cmd, funCMD.inv) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[20].cmd then sampRegisterChatCommand(cmdBind[20].cmd, funCMD.unv) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[22].cmd then sampRegisterChatCommand(cmdBind[22].cmd, funCMD.expel) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[23].cmd then sampRegisterChatCommand(cmdBind[23].cmd, funCMD.vac) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[24].cmd then sampRegisterChatCommand(cmdBind[24].cmd, funCMD.info) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[25].cmd then sampRegisterChatCommand(cmdBind[25].cmd, funCMD.za) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[26].cmd then sampRegisterChatCommand(cmdBind[26].cmd, funCMD.zd) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[27].cmd then sampRegisterChatCommand(cmdBind[27].cmd, funCMD.ant) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[28].cmd then sampRegisterChatCommand(cmdBind[28].cmd, funCMD.strah) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[29].cmd then sampRegisterChatCommand(cmdBind[29].cmd, funCMD.cur) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[32].cmd then sampRegisterChatCommand(cmdBind[32].cmd, funCMD.shpora) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[33].cmd then sampRegisterChatCommand(cmdBind[33].cmd, funCMD.hme) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[34].cmd then sampRegisterChatCommand(cmdBind[34].cmd, funCMD.show) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[35].cmd then sampRegisterChatCommand(cmdBind[35].cmd, funCMD.cam) end
	if cmdBind[selected_cmd].cmd ==	cmdBind[36].cmd then sampRegisterChatCommand(cmdBind[36].cmd, funCMD.godeath) end
	for i,v in ipairs(binder.list) do
		sampRegisterChatCommand(binder.list[i].cmd, function() binderCmdStart() end)
	end
end

function HideDialog(bool)
	lua_thread.create(function()
		repeat wait(0) until sampIsDialogActive()
		while sampIsDialogActive() do
			mem.setint64(sampGetDialogInfoPtr()+40, bool and 1 or 0, true)
			sampToggleCursor(bool)
		end
	end)
end
imgui.GetIO().FontGlobalScale = 1.1

function getNearestID()
    local chars = getAllChars()
    local mx, my, mz = getCharCoordinates(PLAYER_PED)
    local nearId, dist = nil, 10000
    for i,v in ipairs(chars) do
        if doesCharExist(v) and v ~= PLAYER_PED then
            local vx, vy, vz = getCharCoordinates(v)
            local cDist = getDistanceBetweenCoords3d(mx, my, mz, vx, vy, vz)
            local r, id = sampGetPlayerIdByCharHandle(v)
            if r and cDist < dist then
                dist = cDist
                nearId = id
            end
        end
    end
    return nearId
end

function ButtonSwitch(namebut, bool)
    local rBool = false
    if LastActiveTime == nil then
        LastActiveTime = {}
    end
    if LastActive == nil then
        LastActive = {}
    end
    local function ImSaturate(f)
        return f < 0.06 and 0.06 or (f > 1.0 and 1.0 or f)
    end
    local p = imgui.GetCursorScreenPos()
    local draw_list = imgui.GetWindowDrawList()
    local height = imgui.GetTextLineHeightWithSpacing() * 1.15
    local width = height * 1.35
    local radius = height * 0.30
    local ANIM_SPEED = 0.09
    local butPos = imgui.GetCursorPos()
    if imgui.InvisibleButton(namebut, imgui.ImVec2(width, height)) then
        bool.v = not bool.v
        rBool = true
        LastActiveTime[tostring(namebut)] = os.clock()
        LastActive[tostring(namebut)] = true
    end
    imgui.SetCursorPos(imgui.ImVec2(butPos.x + width + 3, butPos.y + 3.8))
    imgui.Text( namebut:gsub('##.+', ''))
    local t = bool.v and 1.0 or 0.06
    if LastActive[tostring(namebut)] then
        local time = os.clock() - LastActiveTime[tostring(namebut)]
        if time <= ANIM_SPEED then
            local t_anim = ImSaturate(time / ANIM_SPEED)
            t = bool.v and t_anim or 1.0 - t_anim
        else
            LastActive[tostring(namebut)] = false
        end
    end
    local col_static = 0xFFFFFFFF
    local col = bool.v and imgui.ColorConvertFloat4ToU32(imgui.ImVec4(0.18, 0.82, 0.35, 0.80)) or 0xFF606060
    draw_list:AddRectFilled(imgui.ImVec2(p.x, p.y + (height / 6)), imgui.ImVec2(p.x + width - 1.0, p.y + (height - (height / 6))), col, 7.0)
    draw_list:AddCircleFilled(imgui.ImVec2(p.x + radius + t * (width - radius * 2.3), p.y+4.6 + radius), radius - 0.75, col_static)

    return rBool
end

dragtest = imgui.ImFloat(12.0)
function CastomDragFloat(DragText, DragParam, DragMIN, DragMAX, DragWidth, posx, poxy)
	local function convert(param)
		param = tonumber(param)*100
		return round(param, 1)
	end
	local DragWidthEnd = (DragWidth-15) / DragMAX
	imgui.SetCursorPos(imgui.ImVec2(posx+5, poxy+9))
	local p = imgui.GetCursorScreenPos()
	local DragPos = imgui.GetCursorPos()
	imgui.SetCursorPos(imgui.ImVec2(posx, poxy))
	imgui.PushItemWidth(DragWidth)
	imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImColor(0, 0, 0, 0):GetVec4())
	imgui.PushStyleColor(imgui.Col.SliderGrab, imgui.ImColor(0, 0, 0, 0):GetVec4())
	imgui.PushStyleColor(imgui.Col.SliderGrabActive, imgui.ImColor(0, 0, 0, 0):GetVec4())
	local thisisDrag = imgui.SliderFloat(u8"##"..DragText, DragParam, DragMIN, DragMAX, u8"")
	imgui.PopStyleColor(3)
	
	imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + DragWidth-15, p.y + 5), imgui.GetColorU32(imgui.ImVec4(1.00, 1.00, 1.00 ,0.50)), 10, 15)
	imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + (DragParam.v*DragWidthEnd), p.y + 5), imgui.GetColorU32(imgui.ImVec4(0.11, 0.60, 0.88 ,1.00)), 10, 15)
	imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + (DragParam.v*DragWidthEnd), p.y + 2), 9, imgui.GetColorU32(imgui.ImVec4(1.00, 1.00, 1.00 ,1.00)))
	imgui.SameLine()
	if DragText:find("##") then
	else
		imgui.Text(DragText)
	end
	
	return 	thisisDrag
end

local ptY = 235
local visible = 0
function mainSet()
	local function text_save()
		if sectator:status() ~= "dead" then
			sectator:terminate()
		end
		visible = 255
		sectator = lua_thread.create(function()
			wait(2000)
			repeat wait(0)
				visible = visible - 6
			until visible <= 0
		end)
	end
	local function TheBackground(IsItem, posX, posY, sizeX, sizeY, rounding, flag)
		imgui.SetCursorPos(imgui.ImVec2(posX, posY))
		local p = imgui.GetCursorScreenPos()
		if IsItem == 1 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + sizeX, p.y + sizeY), imgui.GetColorU32(imgui.ImVec4(0.15, 0.15, 0.15 ,1.00)), rounding, flag)
		elseif IsItem == 2 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + sizeX, p.y + 1), imgui.GetColorU32(imgui.ImVec4(0.35, 0.35, 0.35 ,1.00)))
		end
	end
	imgui.SetCursorPos(imgui.ImVec2(547, ptY))
	imgui.TextColored(imgui.ImColor(255, 255, 255, visible):GetVec4(), u8"Изменения сохранены")
	if sel_menu_set == 1 then
		ptY = 230
		TheBackground(1, 410, 48, 426, 176, 10, 15)
		imgui.SetCursorPos(imgui.ImVec2(425, 60))
		imgui.PushItemWidth(295);
		if imgui.InputText(u8" Имя Фамилия ", buf_nick, imgui.InputTextFlags.CallbackCharFilter, filter(1, "[а-Я%s]+")) then settingMassiveSave() text_save() end
		if not imgui.IsItemActive() and buf_nick.v == "" then
			imgui.SameLine()
			imgui.SetCursorPosX(432)
			imgui.TextColored(imgui.ImColor(200, 200, 200, 200):GetVec4(), u8"Введите Ваше Имя и Фамилию");
		end
		imgui.SetCursorPos(imgui.ImVec2(425, 92))
		imgui.PushItemWidth(295);
		if imgui.InputText(u8" Тег в рацию ", buf_teg) then settingMassiveSave() text_save() end
		if not imgui.IsItemActive() and buf_teg.v == "" then
			imgui.SameLine()
			imgui.SetCursorPosX(432)
			imgui.TextColored(imgui.ImColor(200, 200, 200, 200):GetVec4(), u8"Введите тег рации, если он есть");
		end
		imgui.SetCursorPos(imgui.ImVec2(425, 124))
		imgui.PushItemWidth(295);
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(60, 60, 60, 0):GetVec4())
		imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(77, 77, 77, 255):GetVec4())
		imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(30, 30, 30, 255):GetVec4())
		if imgui.Combo(u8" Ваш пол ", num_sex, list_sex) then settingMassiveSave() text_save() end
		imgui.PopStyleColor(3)
		imgui.PopItemWidth()
		imgui.PushItemWidth(283);
		imgui.PushStyleVar(imgui.StyleVar.FramePadding, imgui.ImVec2(1, 3))
		imgui.SetCursorPos(imgui.ImVec2(702, 156))
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(51, 51, 51, 255):GetVec4())
		imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(77, 77, 77, 255):GetVec4())
		imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(30, 30, 30, 255):GetVec4())
		if imgui.Button(fa.ICON_COG.."##1", imgui.ImVec2(21,21)) then
			chgName.inp.v = chgName.org[num_org.v+1]
			imgui.OpenPopup(u8"MH | Изменение названия больницы")
		end
		imgui.PopStyleColor(3)
		imgui.PopStyleVar(1)
		imgui.SetCursorPos(imgui.ImVec2(425, 156))
		imgui.PushItemWidth(275);
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(60, 60, 60, 0):GetVec4())
		imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(77, 77, 77, 255):GetVec4())
		imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(30, 30, 30, 255):GetVec4())
		if imgui.Combo(u8"      Организация ", num_org, chgName.org) then settingMassiveSave() text_save() end
		imgui.PopStyleColor(3)
		imgui.PushStyleVar(imgui.StyleVar.FramePadding, imgui.ImVec2(1, 3))
		imgui.SetCursorPos(imgui.ImVec2(702, 188))
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(51, 51, 51, 255):GetVec4())
		imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(77, 77, 77, 255):GetVec4())
		imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(30, 30, 30, 255):GetVec4())
		if imgui.Button(fa.ICON_COG.."##2", imgui.ImVec2(21,21)) then
			chgName.inp.v = chgName.rank[num_rank.v+1]
			imgui.OpenPopup(u8"MH | Изменение названия должности")
		end
		imgui.PopStyleColor(3)
		imgui.PopStyleVar(1)
		imgui.SetCursorPos(imgui.ImVec2(425, 188))
		imgui.PushItemWidth(275);
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(60, 60, 60, 0):GetVec4())
		imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(77, 77, 77, 255):GetVec4())
		imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(30, 30, 30, 255):GetVec4())
		if imgui.Combo(u8"      Должность ", num_rank, chgName.rank) then settingMassiveSave() text_save() end
		imgui.PopStyleColor(3)
		if imgui.BeginPopupModal(u8"MH | Изменение названия больницы", null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove) then
			imgui.Text(u8"Название больницы будет применено к текущему названию")
			imgui.PushItemWidth(395)
			imgui.InputText(u8"##inpcastname", chgName.inp, 512, filter(1, "[%s%a%-]+"))
			imgui.PopItemWidth()
			if imgui.Button(u8"Сохранить", imgui.ImVec2(126,23)) then
				local exist = false
				for i,v in ipairs(chgName.org) do
					if v == chgName.inp.v and i ~= num_org.v+1 then
						exist = true
					end
				end
				if not exist then
					chgName.org[num_org.v+1] = chgName.inp.v
					settingMassiveSave() text_save()
					imgui.CloseCurrentPopup()
				end
			end
			imgui.SameLine()
			if imgui.Button(u8"Сбросить", imgui.ImVec2(128,23)) then
				chgName.org[num_org.v+1] = list_org[num_org.v+1]
				needSave = true
				imgui.CloseCurrentPopup()
			end
			imgui.SameLine()
			if imgui.Button(u8"Отмена", imgui.ImVec2(126,23)) then
				imgui.CloseCurrentPopup()
			end
			imgui.EndPopup()
		end
		if imgui.BeginPopupModal(u8"MH | Изменение названия должности", null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove) then
			imgui.Text(u8"Название должности будет применено к текущему названию")
			imgui.PushItemWidth(200)
			imgui.InputText(u8"##inpcastname", chgName.inp, 512, filter(1, "[.%s%a%-]+"))
			imgui.PopItemWidth()
			if imgui.Button(u8"Сохранить", imgui.ImVec2(126,23)) then
				local exist = false
				for i,v in ipairs(chgName.rank) do
					if v == chgName.inp.v and i ~= num_rank.v+1 then
						exist = true
					end
				end
				if not exist then
					chgName.rank[num_rank.v+1] = chgName.inp.v
					settingMassiveSave() text_save()
					imgui.CloseCurrentPopup()
				end
			end
			imgui.SameLine()
			if imgui.Button(u8"Сбросить", imgui.ImVec2(128,23)) then
				chgName.rank[num_rank.v+1] = list_rank[num_rank.v+1]
				needSave = true
				imgui.CloseCurrentPopup()
			end
			imgui.SameLine()
			if imgui.Button(u8"Отмена", imgui.ImVec2(126,23)) then
				imgui.CloseCurrentPopup()
			end
			imgui.EndPopup()
		end
	end
	if sel_menu_set == 2 then
		ptY = 303
		TheBackground(1, 410, 48, 426, 245, 10, 15)
		imgui.SetCursorPos(imgui.ImVec2(425, 59))
		if ButtonSwitch(u8" Скрыть объявления от игроков", cb_chat1) then settingMassiveSave() text_save() end
		imgui.SetCursorPos(imgui.ImVec2(425, 92))
		if ButtonSwitch(u8" Скрыть частые подсказки сервера", cb_chat2) then settingMassiveSave() text_save() end
		imgui.SetCursorPos(imgui.ImVec2(425, 125))
		if ButtonSwitch(u8" Скрыть новости СМИ", cb_chat3) then settingMassiveSave() text_save() end
		imgui.SetCursorPos(imgui.ImVec2(425, 158))
		if ButtonSwitch(u8" ChatHUD", cb_hud) then settingMassiveSave() text_save() end;
		imgui.SetCursorPos(imgui.ImVec2(425, 191))
		if ButtonSwitch(u8" TimeHUD", cb_hudTime) then settingMassiveSave() text_save() end
		imgui.SetCursorPos(imgui.ImVec2(425, 224))
		if ButtonSwitch(u8" Отыгровка /time ", cb_time) then settingMassiveSave() text_save() end
		if imgui.IsItemHovered() then
			imgui.SetTooltip(u8"Отыгровка после просмотра времени /time")
		end
		imgui.SameLine()
		imgui.PushItemWidth(250);
		if imgui.InputText(u8"##Отыгровка после /time", buf_time) then settingMassiveSave() text_save()end
		if not imgui.IsItemActive() and buf_time.v == "" then
			imgui.SameLine()
			imgui.SetCursorPosX(582)
			imgui.TextColored(imgui.ImColor(200, 200, 200, 200):GetVec4(), u8"Введите отыгровку");
		end
		imgui.SetCursorPos(imgui.ImVec2(425, 257))
		if ButtonSwitch(u8" Отыгровка /r ", cb_rac) then settingMassiveSave() text_save() end
		if imgui.IsItemHovered() then
			imgui.SetTooltip(u8"Отыгровка после отправки сообщения в рацию /r")
		end
		imgui.SameLine()
		imgui.SetCursorPosX(575)
		imgui.PushItemWidth(250);
		if imgui.InputText(u8"##Отыгровка перед /r", buf_rac) then settingMassiveSave() text_save() end
		if not imgui.IsItemActive() and buf_rac.v == "" then
			imgui.SameLine()
			imgui.SetCursorPosX(582)
			imgui.TextColored(imgui.ImColor(200, 200, 200, 200):GetVec4(), u8"Введите отыгровку");
		end
	end
	if sel_menu_set == 3 then
		ptY = 442
		TheBackground(1, 410, 48, 426, 390, 10, 15)
		TheBackground(2, 410, 159, 426, 2, 0, 0)
		imgui.SetCursorPos(imgui.ImVec2(425, 59))
		imgui.PushItemWidth(80)
		if imgui.InputText(u8" Лечение", buf_lec, imgui.InputTextFlags.CharsDecimal) then settingMassiveSave() text_save() end
		imgui.SameLine()
		imgui.SetCursorPosX(610)
		if imgui.InputText(u8" Антибиотик", buf_ant, imgui.InputTextFlags.CharsDecimal) then settingMassiveSave() text_save() end
		imgui.SetCursorPos(imgui.ImVec2(425, 92))
		if imgui.InputText(u8" Рецепт", buf_rec, imgui.InputTextFlags.CharsDecimal) then settingMassiveSave() text_save() end
		imgui.SameLine()
		imgui.SetCursorPosX(610)
		if imgui.InputText(u8" Наркозависимость", buf_narko, imgui.InputTextFlags.CharsDecimal) then settingMassiveSave() text_save() end
		imgui.SetCursorPos(imgui.ImVec2(425, 125))
		if imgui.InputText(u8" Татуировка", buf_tatu, imgui.InputTextFlags.CharsDecimal) then settingMassiveSave() text_save() end
		imgui.PopItemWidth()
		imgui.PushItemWidth(80)
		imgui.SetCursorPos(imgui.ImVec2(425, 173))
		if imgui.InputText(u8" Мед. карта новая на 7 дней", buf_mede[1], imgui.InputTextFlags.CharsDecimal) then settingMassiveSave() text_save() end
		imgui.SetCursorPos(imgui.ImVec2(425, 206))
		if imgui.InputText(u8" Мед. карта новая на 14 дней", buf_mede[2], imgui.InputTextFlags.CharsDecimal) then settingMassiveSave() text_save() end
		imgui.SetCursorPos(imgui.ImVec2(425, 239))
		if imgui.InputText(u8" Мед. карта новая на 30 дней", buf_mede[3], imgui.InputTextFlags.CharsDecimal) then settingMassiveSave() text_save() end
		imgui.SetCursorPos(imgui.ImVec2(425, 272))
		if imgui.InputText(u8" Мед. карта новая на 60 дней", buf_mede[4], imgui.InputTextFlags.CharsDecimal) then settingMassiveSave() text_save() end
		imgui.SetCursorPos(imgui.ImVec2(425, 305))
		if imgui.InputText(u8" Мед. карта обновление на 7 дней", buf_upmede[1], imgui.InputTextFlags.CharsDecimal) then settingMassiveSave() text_save() end
		imgui.SetCursorPos(imgui.ImVec2(425, 338))
		if imgui.InputText(u8" Мед. карта обновление на 14 дней", buf_upmede[2], imgui.InputTextFlags.CharsDecimal) then settingMassiveSave() text_save() end
		imgui.SetCursorPos(imgui.ImVec2(425, 371))
		if imgui.InputText(u8" Мед. карта обновление на 30 дней", buf_upmede[3], imgui.InputTextFlags.CharsDecimal) then settingMassiveSave() text_save() end
		imgui.SetCursorPos(imgui.ImVec2(425, 404))
		if imgui.InputText(u8" Мед. карта обновление на 60 дней", buf_upmede[4], imgui.InputTextFlags.CharsDecimal) then settingMassiveSave() text_save() end
		imgui.PopItemWidth()
	end
	if sel_menu_set == 4 then
		if C_membScr.func.v then
			ptY = 443
			TheBackground(1, 410, 48, 426, 393, 10, 15)
			TheBackground(2, 410, 93, 426, 2, 0, 0)
			TheBackground(2, 410, 205, 426, 2, 0, 0)
			TheBackground(2, 410, 348, 426, 2, 0, 0)
			TheBackground(2, 410, 395, 426, 2, 0, 0)
		else
			ptY = 100
			TheBackground(1, 410, 48, 426, 44, 10, 15)
		end
		imgui.SetCursorPos(imgui.ImVec2(425, 59))
		if ButtonSwitch(u8" Мемберс организации на Вашем экране", C_membScr.func) then settingMassiveMembers() text_save() end
		if C_membScr.func.v then
			imgui.SetCursorPos(imgui.ImVec2(425, 106))
			if ButtonSwitch(u8" Скрывать при диалоге", C_membScr.dialog) then settingMassiveMembers() text_save() end
			imgui.SameLine()
			imgui.SetCursorPos(imgui.ImVec2(625, 106))
			if ButtonSwitch(u8" Инверсировать текст", C_membScr.vergor) then settingMassiveMembers() text_save() end
			imgui.SetCursorPos(imgui.ImVec2(425, 139))
			if ButtonSwitch(u8" Отображать форму", C_membScr.forma) then settingMassiveMembers() text_save() end
			imgui.SameLine()
			imgui.SetCursorPos(imgui.ImVec2(625, 139))
			if ButtonSwitch(u8" Отображать ранг", C_membScr.numrank) then settingMassiveMembers() text_save() end
			imgui.SetCursorPos(imgui.ImVec2(425, 172))
			if ButtonSwitch(u8" Отображать id", C_membScr.id) then settingMassiveMembers() text_save() end
			imgui.SameLine()
			imgui.SetCursorPos(imgui.ImVec2(625, 172))
			if ButtonSwitch(u8" Отображать АФК", C_membScr.afk) then settingMassiveMembers() text_save() end
			if CastomDragFloat(u8"Размер шрифта", C_membScr.font.size, 1, 25, 205, 425, 216) then 
				settingMassiveMembers()
				text_save()
				fontes = renderCreateFont("Trebuchet MS", C_membScr.font.size.v, C_membScr.font.flag.v)
			end
			if CastomDragFloat(u8"Флаг шрифта", C_membScr.font.flag, 1, 25, 205, 425, 249) then 
				settingMassiveMembers()
				text_save()
				fontes = renderCreateFont("Trebuchet MS", C_membScr.font.size.v, C_membScr.font.flag.v)
			end
			if CastomDragFloat(u8"Расстояние между строками", C_membScr.font.distance, 1, 30, 205, 425, 282) then 
				settingMassiveMembers()
				text_save()
				fontes = renderCreateFont("Trebuchet MS", C_membScr.font.size.v, C_membScr.font.flag.v)
			end
			if CastomDragFloat(u8"Прозрачность текста", C_membScr.font.visible, 1, 255, 205, 425, 315) then 
				settingMassiveMembers()
				text_save()
				fontes = renderCreateFont("Trebuchet MS", C_membScr.font.size.v, C_membScr.font.flag.v)
			end
			imgui.SetCursorPos(imgui.ImVec2(425, 359))
			imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(85, 85, 85, 255):GetVec4())
			imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(105, 105, 105, 255):GetVec4())
			imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(60, 60, 60, 255):GetVec4())
			if imgui.Button(u8"Местоположение", imgui.ImVec2(397, 26)) then changePosition() end
			imgui.PopStyleColor(3)
			imgui.SetCursorPos(imgui.ImVec2(425, 408))
			if imgui.ColorEdit4('##TitleColor', col.title, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoLabel + imgui.ColorEditFlags.NoAlpha) then
				local c = imgui.ImVec4(col.title.v[1], col.title.v[2], col.title.v[3], col.title.v[4])
				local argb = imgui.ColorConvertFloat4ToARGB(c)
				C_membScr.color.col_title = imgui.ColorConvertFloat4ToARGB(c)
				C_membScr.color.col_default = membScr.color.col_default
				C_membScr.color.col_no_work = membScr.color.col_no_work
				settingMassiveMembers()
				text_save()
			end
			imgui.SameLine()
			imgui.Text(u8'Заголовок')
			imgui.SetCursorPos(imgui.ImVec2(575, 408))
			if imgui.ColorEdit4('##DefaultColor', col.default, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoLabel + imgui.ColorEditFlags.NoAlpha) then
				local c = imgui.ImVec4(col.default.v[1], col.default.v[2], col.default.v[3], col.default.v[4]) 
				C_membScr.color.col_default = imgui.ColorConvertFloat4ToARGB(c)
				C_membScr.color.col_no_work = membScr.color.col_no_work
				C_membScr.color.col_title = membScr.color.col_title
				settingMassiveMembers()
				text_save()
			end
			imgui.SameLine()
			imgui.Text(u8'В форме')
			imgui.SetCursorPos(imgui.ImVec2(717, 408))
			if imgui.ColorEdit4('##NoWorkColor', col.no_work, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoLabel + imgui.ColorEditFlags.NoAlpha) then
				local c = imgui.ImVec4(col.no_work.v[1], col.no_work.v[2], col.no_work.v[3], col.no_work.v[4])
				C_membScr.color.col_no_work = imgui.ColorConvertFloat4ToARGB(c)
				C_membScr.color.col_default = membScr.color.col_default
				C_membScr.color.col_title = membScr.color.col_title
				settingMassiveMembers()
				text_save()
			end
			imgui.SameLine()
			imgui.Text(u8'Без формы')
		end	
	end
	if sel_menu_set == 5 then
		ptY = 170
		TheBackground(1, 410, 48, 426, 112, 10, 15)
		--TheBackground(2, 410, 125, 426, 2, 0, 0)
		imgui.SetCursorPos(imgui.ImVec2(425, 59))
		if ButtonSwitch(u8" Уведомлять звуковым сигналом о спавне авто", accept_spawn) then settingMassiveSave() text_save() end
		if imgui.IsItemHovered() then
			imgui.SetTooltip(u8"Когда в чате от администрации появится сообщение о том, что в скором\nвремени будет спавн авто, Вы будете уведомлены звуковым сигналом.")
		end
		imgui.SetCursorPos(imgui.ImVec2(425, 92))
		if ButtonSwitch(u8" Автолечение по просьбе в чат", accept_autolec) then settingMassiveSave() text_save() end
		if imgui.IsItemHovered() then
			imgui.SetTooltip(u8"Когда игрок в чат напишет сообщение, что его нужно вылечить,\nВам будет предложено вылечить его по нажатию кнопки.")
		end
		imgui.SetCursorPos(imgui.ImVec2(425, 127))
		if ButtonSwitch(u8" Уведомлять звуковым сигналом при вызове /d", prikol) then settingMassiveSave() text_save() end
		if imgui.IsItemHovered() then
			imgui.SetTooltip(u8"Когда к Вашей организации обратятся в рацию департамента,\nВы будете уведомлены звуковым сигналом.")
		end
	end
	if sel_menu_set == 6 then --findnap
		local function	timenull(param)
			param = round(param, 1)
			if param <= 9 then
				return tostring("0"..param)
			else
				return tostring(param)
			end
		end
		ptY = 102
		imgui.SetCursorPos(imgui.ImVec2(410, 48))
		imgui.BeginChild("Reminers", imgui.ImVec2(426, 395), false, imgui.WindowFlags.NoScrollbar)
		if #reminder == 0 then
			TheBackground(1, 0, 0, 426, 32, 10, 15)
			TheBackground(1, 0, 50, 426, 50, 10, 15)
		else
			TheBackground(1, 0, 0, 426, 80 * (#reminder), 10, 15)
			TheBackground(1, 0, 13 + (80 * (#reminder)), 426, 50, 10, 15)
		end
		
		
		if #reminder == 0 then
			imgui.SetCursorPos(imgui.ImVec2(129, 7))
			imgui.Text(u8"Напоминаний не найдено")
		else
			for pren = 1, #reminder do
				imgui.SetCursorPos(imgui.ImVec2(0, (80 * (pren - 1))))
				if imgui.InvisibleButton("##RemoveReminder"..pren, imgui.ImVec2(426, 80)) then local removereminder = pren; imgui.OpenPopup(u8"Удалить напоминание") end
				if imgui.IsItemHovered() and not imgui.IsItemActive() then
					imgui.SetCursorPos(imgui.ImVec2(0, (80 * (pren - 1))))
					local p = imgui.GetCursorScreenPos()
					if pren ~= 1 and pren ~= #reminder then
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 426, p.y + 80), imgui.GetColorU32(imgui.ImVec4(1.00, 1.00, 1.00 ,0.15)))
					elseif pren == 1 and #reminder ~= 1 then
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 426, p.y + 80), imgui.GetColorU32(imgui.ImVec4(1.00, 1.00, 1.00 ,0.15)), 10, 3)
					elseif pren == 1 and #reminder == 1 then
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 426, p.y + 80), imgui.GetColorU32(imgui.ImVec4(1.00, 1.00, 1.00 ,0.15)), 10, 15)
					elseif pren == #reminder then
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 426, p.y + 80), imgui.GetColorU32(imgui.ImVec4(1.00, 1.00, 1.00 ,0.15)), 10, 12)
					end
				elseif imgui.IsItemActive() then
					imgui.SetCursorPos(imgui.ImVec2(0, (80 * (pren - 1))))
					local p = imgui.GetCursorScreenPos()
					if pren ~= 1 and pren ~= #reminder then
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 426, p.y + 80), imgui.GetColorU32(imgui.ImVec4(1.00, 1.00, 1.00 ,0.03)))
					elseif pren == 1 and #reminder ~= 1 then
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 426, p.y + 80), imgui.GetColorU32(imgui.ImVec4(1.00, 1.00, 1.00 ,0.03)), 10, 3)
					elseif pren == 1 and #reminder == 1 then
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 426, p.y + 80), imgui.GetColorU32(imgui.ImVec4(1.00, 1.00, 1.00 ,0.03)), 10, 15)
					elseif pren == #reminder then
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 426, p.y + 80), imgui.GetColorU32(imgui.ImVec4(1.00, 1.00, 1.00 ,0.03)), 10, 12)
					end
				end
			end
			for qun = 1, #reminder do
				TheBackground(2, 20, 30 + (80 * (qun - 1)), 386, 1, 0, 0)
				imgui.SetCursorPos(imgui.ImVec2(20, 7 + (80 * (qun - 1))))
				imgui.Text(reminder[qun].timer.day.." "..u8(month[reminder[qun].timer.mon])..u8", "..timenull(reminder[qun].timer.hour)..u8":"..timenull(reminder[qun].timer.min))
				if not reminder[qun].repeats[1] and not reminder[qun].repeats[2] and not reminder[qun].repeats[3] and not reminder[qun].repeats[4] and not reminder[qun].repeats[5] and not reminder[qun].repeats[6] and not reminder[qun].repeats[7] then
					imgui.SetCursorPos(imgui.ImVec2(302, 7 + (80 * (qun - 1))))
					imgui.Text(u8"Повторений нет")
				elseif reminder[qun].repeats[1] and reminder[qun].repeats[2] and reminder[qun].repeats[3] and reminder[qun].repeats[4] and reminder[qun].repeats[5] and reminder[qun].repeats[6] and reminder[qun].repeats[7] then
					imgui.SetCursorPos(imgui.ImVec2(266, 7 + (80 * (qun - 1))))
					imgui.Text(u8"Повтор: каждый день")
				else
					textesweek = ""
					local weekcut = {u8" ПН", u8" ВТ", u8" СР", u8" ЧТ", u8" ПТ", u8" СБ", u8" ВС"}
					for j = 1, 7 do
						if reminder[qun].repeats[j] then
							textesweek = textesweek..weekcut[j]
						end
					end
					local calc = imgui.CalcTextSize(textesweek)
					imgui.SetCursorPos(imgui.ImVec2(353 -  calc.x, 7 + (80 * (qun - 1))))
					imgui.Text(u8"Повтор:"..textesweek)			
				end
				imgui.SetCursorPos(imgui.ImVec2(21, 40+  (80 * (qun - 1))))
				local p = imgui.GetCursorScreenPos()
				imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 3, p.y + 17), imgui.GetColorU32(imgui.ImVec4(1.00, 0.58, 0.02 ,1.00)), 10, 15)
				imgui.SetCursorPos(imgui.ImVec2(30, 40+  (80 * (qun - 1))))
				if reminder[qun].text ~= "" then
					imgui.Text(reminder[qun].text)
				else
					imgui.Text(u8"Без названия")
				end
			end
			imgui.Dummy(imgui.ImVec2(0, 90))
		end
		if #reminder == 0 then
			imgui.SetCursorPos(imgui.ImVec2(20, 60))
		else
			imgui.SetCursorPos(imgui.ImVec2(20, 23 + (80 * (#reminder))))
		end
		local function get_days_in_months(year)
			local is_leap = year % 4 == 0 and (year % 100 ~= 0 or year % 400 == 0)
			local days_in_month = {31, is_leap and 29 or 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}
			return days_in_month
		end
		if imgui.Button(u8"Создать напоминание", imgui.ImVec2(386, 30)) then
			reminder_buf = {
				timer = {year = imgui.ImInt(0), mon = imgui.ImInt(0), day = imgui.ImInt(0), hour = imgui.ImFloat(1.0), min = imgui.ImFloat(1.0)},
				text = imgui.ImBuffer(100),
				repeats = {imgui.ImBool(false), imgui.ImBool(false), imgui.ImBool(false), imgui.ImBool(false), imgui.ImBool(false), imgui.ImBool(false), imgui.ImBool(false)},
				sound = imgui.ImBool(true)
			}
			reminder_buf.timer.year.v = tonumber(os.date("%Y"))
			reminder_buf.timer.mon.v = tonumber(os.date("%m"))
			reminder_buf.timer.day.v = tonumber(os.date("%d")) 
			reminder_buf.timer.hour.v = tonumber(os.date("%H"))
			if tonumber(os.date("%M")) <= 55 then
				reminder_buf.timer.min.v = tonumber(os.date("%M")) + 2
			else
				reminder_buf.timer.min.v = 0
				if tonumber(os.date("%H")) ~= 23 then
					reminder_buf.timer.hour.v = tonumber(os.date("%H")) + 1
				else
					reminder_buf.timer.hour.v = 0
				end
			end
			reminder_buf.text.v = u8""
			date_rem = {
				month = {u8"Январь", u8"Февраль", u8"Март", u8"Апрель", u8"Май", u8"Июнь", u8"Июль", u8"Август", u8"Сентябрь", u8"Октябрь", u8"Ноябрь", u8"Декабрь"},
				day = get_days_in_months(reminder_buf.timer.year.v)
			}
			weekday = tonumber(os.date("%w"))
			imgui.OpenPopup(u8"Новое напоминание") 
		end
		
		if imgui.BeginPopupModal(u8"Удалить напоминание", null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoScrollWithMouse) then
		imgui.SetCursorPosX(77)
			imgui.PushFont(fontsize)
			imgui.SetCursorPosY(6)
			imgui.Text(u8"Подтверждение действия")
			imgui.PopFont()
			imgui.SameLine()
			imgui.SetCursorPosX(303)
			imgui.SetCursorPosY(6)
			if imgui.InvisibleButton(u8" #askd", imgui.ImVec2(24, 24)) or animka_sob.paramOff then 
				imgui.CloseCurrentPopup()
			end
			if imgui.IsItemHovered() then
				imgui.SameLine()
				imgui.SetCursorPosX(308)
				imgui.SetCursorPosY(3)
				imgui.PushFont(fa_font2)
				imgui.TextColored(imgui.ImVec4(1.0, 0.56, 0.64 ,1.00), fa.ICON_TIMES)
				imgui.PopFont()
			else
				imgui.SameLine()
				imgui.SetCursorPosX(308)
				imgui.SetCursorPosY(3)
				imgui.PushFont(fa_font2)
				imgui.Text(fa.ICON_TIMES)
				imgui.PopFont()
			end
			imgui.Separator()
			imgui.Dummy(imgui.ImVec2(0, 1))
			imgui.BeginChild("ChildHZG", imgui.ImVec2(313, 35), false, imgui.WindowFlags.NoScrollbar)
			imgui.Dummy(imgui.ImVec2(0, 3))
			imgui.Text(u8" Вы уверены, что хотите удалить напоминание?")
			imgui.EndChild()
			if imgui.Button(u8"Удалить##nal", imgui.ImVec2(156, 24)) then
				imgui.CloseCurrentPopup() 
				table.remove(reminder, removereminder) 
				local f = io.open(dirml.."/MedicalHelper/reminders.med", "w")
				f:write(encodeJson(reminder))
				f:flush()
				f:close()
			end
			imgui.SameLine()
			if imgui.Button(u8"Отмена##nal", imgui.ImVec2(156, 24)) then imgui.CloseCurrentPopup() end
			imgui.EndPopup()
		end
			
		if imgui.BeginPopupModal(u8"Новое напоминание", null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoScrollWithMouse) then
		local function get_first_day_of_month(year, month)
			local first_day = os.date("*t", os.time{year=year, month=month, day=1})
			if first_day.wday == 1 then 
				first_day.wday = 6 
			else 
				first_day.wday = first_day.wday - 2
			end
			return first_day.wday
		end
		imgui.SetCursorPosX(195)
			imgui.PushFont(fontsize)
			imgui.SetCursorPosY(6)
			imgui.Text(u8"Новое напоминание")
			imgui.PopFont()
			imgui.SameLine()
			imgui.SetCursorPosX(485)
			imgui.SetCursorPosY(6)
			if imgui.InvisibleButton(u8" #as", imgui.ImVec2(24, 24)) or animka_sob.paramOff then 
				imgui.CloseCurrentPopup()
			end
			if imgui.IsItemHovered() then
				imgui.SameLine()
				imgui.SetCursorPosX(490)
				imgui.SetCursorPosY(3)
				imgui.PushFont(fa_font2)
				imgui.TextColored(imgui.ImVec4(1.0, 0.56, 0.64 ,1.00), fa.ICON_TIMES)
				imgui.PopFont()
			else
				imgui.SameLine()
				imgui.SetCursorPosX(490)
				imgui.SetCursorPosY(3)
				imgui.PushFont(fa_font2)
				imgui.Text(fa.ICON_TIMES)
				imgui.PopFont()
			end
			imgui.Separator()
			imgui.Dummy(imgui.ImVec2(0, 1))
			imgui.BeginChild("ChildHZ", imgui.ImVec2(500, 555), false, imgui.WindowFlags.NoScrollbar)
			imgui.PushItemWidth(480)
			imgui.SetCursorPosX(10)
			if imgui.InputText(u8"##Текст напоминания ", reminder_buf.text) then end
			imgui.PopItemWidth()
			if not imgui.IsItemActive() and reminder_buf.text.v == "" then
				imgui.SameLine()
				imgui.SetCursorPosX(20)
				imgui.TextColored(imgui.ImColor(200, 200, 200, 200):GetVec4(), u8"Введите текст напоминания");
			end
			imgui.Dummy(imgui.ImVec2(0, 1))
			imgui.Separator()
			imgui.Dummy(imgui.ImVec2(0, 3))
			
			imgui.SetCursorPos(imgui.ImVec2(10, 45))
			local p = imgui.GetCursorScreenPos()
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 480, p.y + 275), imgui.GetColorU32(imgui.ImVec4(1.00, 1.00, 1.00 ,0.10)), 10, 15)
			imgui.SetCursorPos(imgui.ImVec2(25, 80))
			local p = imgui.GetCursorScreenPos()
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 450, p.y + 1), imgui.GetColorU32(imgui.ImVec4(1.00, 1.00, 1.00 ,0.10)))
			imgui.SetCursorPos(imgui.ImVec2(10, 335))
			local p = imgui.GetCursorScreenPos()
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 480, p.y + 60), imgui.GetColorU32(imgui.ImVec4(1.00, 1.00, 1.00 ,0.10)), 10, 15)
			imgui.SetCursorPos(imgui.ImVec2(10, 410))
			local p = imgui.GetCursorScreenPos()
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 480, p.y + 90), imgui.GetColorU32(imgui.ImVec4(1.00, 1.00, 1.00 ,0.10)), 10, 15)
			imgui.SetCursorPos(imgui.ImVec2(25, 440))
			local p = imgui.GetCursorScreenPos()
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 450, p.y + 1), imgui.GetColorU32(imgui.ImVec4(1.00, 1.00, 1.00 ,0.10)))		
		imgui.SetCursorPos(imgui.ImVec2(10, 515))
			local p = imgui.GetCursorScreenPos()
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 480, p.y + 30), imgui.GetColorU32(imgui.ImVec4(1.00, 1.00, 1.00 ,0.10)), 10, 15)
			
			imgui.SetCursorPos(imgui.ImVec2(25, 55))
			imgui.Text(date_rem.month[reminder_buf.timer.mon.v].." "..reminder_buf.timer.year.v..u8" г.")
			imgui.SetCursorPos(imgui.ImVec2(440, 55))
			if imgui.InvisibleButton("##ButDateStampDown", imgui.ImVec2(18, 18)) then
				date_rem.day = get_days_in_months(reminder_buf.timer.year.v)
				if reminder_buf.timer.mon.v ~= 1 then
					reminder_buf.timer.mon.v = reminder_buf.timer.mon.v - 1
				else
					reminder_buf.timer.year.v = reminder_buf.timer.year.v - 1
					reminder_buf.timer.mon.v = 12
				end
				for m = 1, date_rem.day[reminder_buf.timer.mon.v] do
					if weekday == 1 then
						weekday = 0
					elseif weekday == 0 then
						weekday = 6
					elseif weekday == 6 then
						weekday = 5
					elseif weekday == 5 then
						weekday = 4
					elseif weekday == 4 then
						weekday = 3
					elseif weekday == 3 then
						weekday = 2
					elseif weekday == 2 then
						weekday = 1
					end
				end
				reminder_buf.timer.day.v = date_rem.day[reminder_buf.timer.mon.v]
			end
			imgui.SetCursorPos(imgui.ImVec2(442, 57))
			if imgui.IsItemHovered() then
				imgui.TextColored(imgui.ImVec4(0.95, 0.34, 0.34 ,1.00), fa.ICON_CHEVRON_LEFT)
			else
				imgui.TextColored(imgui.ImVec4(0.83, 0.14, 0.14 ,1.00), fa.ICON_CHEVRON_LEFT)
			end
			imgui.SetCursorPos(imgui.ImVec2(460, 55))
			if imgui.InvisibleButton("##ButDateStampUp", imgui.ImVec2(18, 18)) then 
				date_rem.day = get_days_in_months(reminder_buf.timer.year.v)
				for m = 1, date_rem.day[reminder_buf.timer.mon.v] do
					if weekday <= 5 then
						weekday = weekday + 1
					elseif weekday == 6 then
						weekday = 0
					end
				end
				if reminder_buf.timer.mon.v ~= 12 then
					reminder_buf.timer.mon.v = reminder_buf.timer.mon.v + 1
				else
					reminder_buf.timer.year.v = reminder_buf.timer.year.v + 1
					reminder_buf.timer.mon.v = 1
				end
				reminder_buf.timer.day.v = 1
			end
			imgui.SetCursorPos(imgui.ImVec2(465, 57))
			if imgui.IsItemHovered() then
				imgui.TextColored(imgui.ImVec4(0.95, 0.34, 0.34 ,1.00), fa.ICON_CHEVRON_RIGHT)
			else
				imgui.TextColored(imgui.ImVec4(0.83, 0.14, 0.14 ,1.00), fa.ICON_CHEVRON_RIGHT)
			end
			imgui.SetCursorPos(imgui.ImVec2(35, 92))
			imgui.TextColored(imgui.ImVec4(1.00, 1.00, 1.00 ,0.40), u8"ПН             ВТ             СР             ЧТ             ПТ             СБ             ВС")
			local dt_weekday = get_first_day_of_month(reminder_buf.timer.year.v, reminder_buf.timer.mon.v)
			local dt_string = 1
			for k = 1, date_rem.day[reminder_buf.timer.mon.v] do
				local numdt = tostring(k)
				if dt_weekday <= 6 then
					imgui.SetCursorPos(imgui.ImVec2(30 + (dt_weekday * 69), 91 + (dt_string * 33)))
					if imgui.InvisibleButton("##thisdtbut"..k, imgui.ImVec2(26, 26)) then reminder_buf.timer.day.v = k end
					if imgui.IsItemHovered() then
						imgui.SetCursorPos(imgui.ImVec2(44 + (dt_weekday * 69), 104 + (dt_string * 33)))
						local p = imgui.GetCursorScreenPos()
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x-0.2, p.y-0.4), 15, imgui.GetColorU32(imgui.ImVec4(1.00, 1.00, 1.00 ,0.25)), 60)
					end
					if k == reminder_buf.timer.day.v then
						imgui.SetCursorPos(imgui.ImVec2(44 + (dt_weekday * 69), 104 + (dt_string * 33)))
						local p = imgui.GetCursorScreenPos()
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x-0.2, p.y-0.4), 15, imgui.GetColorU32(imgui.ImVec4(0.83, 0.14, 0.14 ,1.00)), 60)
					end
					if k >= 10 then
						imgui.SetCursorPos(imgui.ImVec2(35 + (dt_weekday * 69), 95 + (dt_string * 33)))
					else
						imgui.SetCursorPos(imgui.ImVec2(39 + (dt_weekday * 69), 95 + (dt_string * 33)))
					end
					imgui.Text(numdt)
					dt_weekday = dt_weekday + 1
				elseif dt_weekday == 7 then
					dt_weekday = 0
					dt_string = dt_string + 1
					imgui.SetCursorPos(imgui.ImVec2(30 + (dt_weekday * 69), 91 + (dt_string * 33)))
					if imgui.InvisibleButton("##thisdtbut"..k, imgui.ImVec2(26, 26)) then reminder_buf.timer.day.v = k end
					if imgui.IsItemHovered() then
						imgui.SetCursorPos(imgui.ImVec2(44 + (dt_weekday * 69), 104 + (dt_string * 33)))
						local p = imgui.GetCursorScreenPos()
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x-0.2, p.y-0.4), 15, imgui.GetColorU32(imgui.ImVec4(1.00, 1.00, 1.00 ,0.25)), 60)
					end
					if k == reminder_buf.timer.day.v then
						imgui.SetCursorPos(imgui.ImVec2(44 + (dt_weekday * 69), 104 + (dt_string * 33)))
						local p = imgui.GetCursorScreenPos()
						imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x-0.2, p.y-0.4), 15, imgui.GetColorU32(imgui.ImVec4(0.83, 0.14, 0.14 ,1.00)), 60)
					end
					if k >= 10 then
						imgui.SetCursorPos(imgui.ImVec2(35 + (dt_weekday * 69), 95 + (dt_string * 33)))
					else
						imgui.SetCursorPos(imgui.ImVec2(39 + (dt_weekday * 69), 95 + (dt_string * 33)))
					end
					imgui.Text(numdt)
					dt_weekday = 1
				end
			end
			
			if CastomDragFloat(u8"##часыНапоминания", reminder_buf.timer.hour, 0, 22, 220, 25, 365) then end
			if CastomDragFloat(u8"##минутыНапоминания", reminder_buf.timer.min, 0, 58, 220, 260, 365) then end
			imgui.SetCursorPos(imgui.ImVec2(120, 342))
			imgui.Text(timenull(reminder_buf.timer.hour.v)..u8" ч.")
			imgui.SetCursorPos(imgui.ImVec2(343, 345))
			imgui.Text(timenull(reminder_buf.timer.min.v)..u8" мин.")
			imgui.SetCursorPos(imgui.ImVec2(212, 417))
			imgui.Text(u8"Повторение")
			
			
			imgui.SetCursorPos(imgui.ImVec2(32, 469))
			ButtonSwitch(u8"##ПН", reminder_buf.repeats[1])
			imgui.SetCursorPos(imgui.ImVec2(100, 469))
			ButtonSwitch(u8"##ВТ", reminder_buf.repeats[2])
			imgui.SetCursorPos(imgui.ImVec2(168, 469))
			ButtonSwitch(u8"##СР", reminder_buf.repeats[3])
			imgui.SetCursorPos(imgui.ImVec2(236, 469))
			ButtonSwitch(u8"##ЧТ", reminder_buf.repeats[4])
			imgui.SetCursorPos(imgui.ImVec2(304, 469))
			ButtonSwitch(u8"##ПТ", reminder_buf.repeats[5])
			imgui.SetCursorPos(imgui.ImVec2(372, 469))
			ButtonSwitch(u8"##СБ", reminder_buf.repeats[6])
			imgui.SetCursorPos(imgui.ImVec2(440, 469))
			ButtonSwitch(u8"##ВС", reminder_buf.repeats[7])
			imgui.SetCursorPos(imgui.ImVec2(38, 449))
			imgui.Text(u8"ПН             ВТ")
			imgui.SetCursorPos(imgui.ImVec2(175, 449))
			imgui.Text(u8"СР             ЧТ             ПТ             СБ             ВС")
			
			imgui.SetCursorPos(imgui.ImVec2(25, 522))
			imgui.TextColoredRGB("Среагирует {ffc800}"..reminder_buf.timer.day.v.." "..(month[reminder_buf.timer.mon.v]).." "..reminder_buf.timer.year.v.." г. {FFFFFF}в {ffc800}"..timenull(reminder_buf.timer.hour.v)..":"..timenull(reminder_buf.timer.min.v))
			imgui.SetCursorPos(imgui.ImVec2(330, 519))
			ButtonSwitch(u8" Звуковой сигнал", reminder_buf.sound)
			imgui.EndChild()
			imgui.Separator()
			imgui.Dummy(imgui.ImVec2(0, 3))
			imgui.SetCursorPosX(20)
			if imgui.Button(u8"Создать напоминание##12", imgui.ImVec2(236, 25)) then
				reminder[#reminder + 1] = {
					timer = {year = reminder_buf.timer.year.v, mon = reminder_buf.timer.mon.v, day = reminder_buf.timer.day.v, hour = round(reminder_buf.timer.hour.v, 1), min = round(reminder_buf.timer.min.v, 1)},
					text = reminder_buf.text.v,
					repeats = {reminder_buf.repeats[1].v, reminder_buf.repeats[2].v, reminder_buf.repeats[3].v, reminder_buf.repeats[4].v, reminder_buf.repeats[5].v, reminder_buf.repeats[6].v, reminder_buf.repeats[7].v},
					sound = reminder_buf.sound.v
				}
				imgui.CloseCurrentPopup()
				reminder_buf = {}
				local f = io.open(dirml.."/MedicalHelper/reminders.med", "w")
				f:write(encodeJson(reminder))
				f:flush()
				f:close()
			end
			imgui.SameLine()
			if imgui.Button(u8"Отмена", imgui.ImVec2(236, 25)) then imgui.CloseCurrentPopup() reminder_buf = {} end
			imgui.Dummy(imgui.ImVec2(0, 1))
		imgui.EndPopup()
		end
		imgui.EndChild()
	end
	if sel_menu_set == 7 then
		ptY = 199
		TheBackground(1, 410, 48, 426, 141, 10, 15)
		TheBackground(2, 410, 86, 426, 2, 0, 0)
		TheBackground(2, 410, 138, 426, 2, 0, 0)
		imgui.SetCursorPos(imgui.ImVec2(532, 59))
		imgui.TextColoredRGB("Версия скрипта - {FFB700}".. scr.version .. " Бета")
		imgui.SetCursorPos(imgui.ImVec2(425, 100))
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(85, 85, 85, 255):GetVec4())
		imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(105, 105, 105, 255):GetVec4())
		imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(60, 60, 60, 255):GetVec4())
		if imgui.Button(u8"Проверить обновление", imgui.ImVec2(397, 26)) then funCMD.updateCheck() animka_main.paramOff = true end
		imgui.PopStyleColor(3)
		imgui.SetCursorPos(imgui.ImVec2(425, 151))
		if scrvers > newversr then
			imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(85, 85, 85, 255):GetVec4())
			imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(105, 105, 105, 255):GetVec4())
			imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(60, 60, 60, 255):GetVec4())
			if imgui.Button(u8"Откатиться до релиз версии", imgui.ImVec2(397, 26)) then 
				imgui.OpenPopup(u8"Подтверждение отката")
			end
			imgui.PopStyleColor(3)
			if imgui.IsItemHovered() then
				imgui.SetTooltip(u8"Если Вы находитесь на бета версии скрипта, то можете легко откатиться обратно до релиза.\nОткат возможен только до последней версии релиза.")
			end
		else
			imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(156, 156, 156, 200):GetVec4())
			imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(156, 156, 156, 200):GetVec4())
			imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(156, 156, 156, 200):GetVec4())
			imgui.Button(u8"Откатиться до релиз версии", imgui.ImVec2(397, 26))
			imgui.PopStyleColor(3)
			if imgui.IsItemHovered() then
				imgui.SetTooltip(u8"Если Вы находитесь на бета версии скрипта, то можете легко откатиться обратно до релиза.\nОткат возможен только до последней версии релиза. Сейчас у Вас последняя релиз версия.")
			end
		end
		if imgui.BeginPopupModal(u8"Подтверждение отката", null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove) then
			imgui.Dummy(imgui.ImVec2(0, 3))
			imgui.TextColoredRGB("Вы действительно хотите откатиться до последней релиз версии?")
			imgui.Dummy(imgui.ImVec2(0, 5))
			imgui.Separator()
			imgui.Dummy(imgui.ImVec2(0, 1))
			if imgui.Button(u8"Откатиться", imgui.ImVec2(213, 0)) then 
				funCMD.updaterelease()
			end 
			imgui.SameLine();
			if imgui.Button(u8"Отмена", imgui.ImVec2(213, 0)) then 
				imgui.CloseCurrentPopup();
				lockPlayerControl(false);
			end 
			imgui.EndPopup()
		end
	end
	if sel_menu_set == 8 then
		for m = 1, #binder.list do
			optionsPKM[m + 13] = u8(binder.list[m].name)
		end
		if chg_funcPKM.func.v then
			ptY = 160 + (#chg_funcPKM.slider * 30)
			TheBackground(1, 410, 48, 426, 102 + (#chg_funcPKM.slider * 30), 10, 15)
			TheBackground(2, 410, 93, 426, 2, 0, 0)
		else
			ptY = 102
			TheBackground(1, 410, 48, 426, 44, 10, 15)
		end
		imgui.SetCursorPos(imgui.ImVec2(425, 59))
		if ButtonSwitch(u8" Выбор действий на правую кнопку мыши + R", chg_funcPKM.func) then settingMassiveSave() text_save() end
		if imgui.IsItemHovered() then
			imgui.SetTooltip(u8"Наведите на игрока правой кнопкой мыши и одновременно нажмите R.\nПеред Вами появится быстрый выбор действий выбранного игрока.")
		end
		
		if chg_funcPKM.func.v then
			for k = 1, #chg_funcPKM.slider do
				if chg_funcPKM.slider[k] ~= nil then
					imgui.PushItemWidth(363);
					imgui.SetCursorPos(imgui.ImVec2(425, 79 + (k * 30)))
					if imgui.Combo(u8" ##sliderPKM"..k, chg_funcPKM.slider[k], optionsPKM) then settingMassiveSave() text_save() end
					imgui.PopItemWidth()
					imgui.SameLine()
					imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(255, 255, 255, 60):GetVec4())
					imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(255, 255, 255, 30):GetVec4())
					imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(255, 255, 255, 80):GetVec4())
					if imgui.Button(fa.ICON_TRASH.."##DELFF"..k, imgui.ImVec2(26, 23)) then
						table.remove(chg_funcPKM.slider, k)
						table.remove(setting2.funcPKM.slider, k)
						settingMassiveSave()
						text_save()
					end
					imgui.PopStyleColor(3)
				end
			end
			if #chg_funcPKM.slider < 9 then
				imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(255, 255, 255, 60):GetVec4())
				imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(255, 255, 255, 30):GetVec4())
				imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(255, 255, 255, 80):GetVec4())
				imgui.SetCursorPos(imgui.ImVec2(593, 113 + (#chg_funcPKM.slider * 30)))
				imgui.TextColoredRGB('{FFFFFF}Добавить')
			else
				imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(255, 255, 255, 10):GetVec4())
				imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(255, 255, 255, 10):GetVec4())
				imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(255, 255, 255, 10):GetVec4())
				imgui.SetCursorPos(imgui.ImVec2(593, 113 + (#chg_funcPKM.slider * 30)))
				imgui.TextColoredRGB('{858585}Добавить')
			end
			imgui.SetCursorPos(imgui.ImVec2(425, 110 + (#chg_funcPKM.slider * 30)))
			if imgui.Button(u8"##ДобавитьNE", imgui.ImVec2(397, 25)) then
				if #chg_funcPKM.slider < 9 then
					chg_funcPKM.slider[#chg_funcPKM.slider + 1] = imgui.ImInt(0)
					settingMassiveSave()
					text_save()
				end
			end
			imgui.PopStyleColor(3)
		end
	end
end

function mainGameSimplification()
	imgui.SetCursorPosX(25)
	imgui.BeginGroup()
	imgui.PushItemWidth(150);
	imgui.Dummy(imgui.ImVec2(0, 2))
	if ButtonSwitch(u8"Уведомлять звуковым сигналом о спавне авто", accept_spawn) then needSave = true end
	imgui.SameLine()
	ShowHelpMarker(u8"Когда в чате от администрации появится сообщение о том, что в скором\nвремени будет спавн авто, Вы будете уведомлены звуковым сигналом.")
	imgui.Dummy(imgui.ImVec2(0, 2))
	imgui.Separator()
	imgui.Dummy(imgui.ImVec2(0, 2))
	if ButtonSwitch(u8"Автолечение по просьбе", accept_autolec) then needSave = true end
	imgui.SameLine()
	ShowHelpMarker(u8"Когда игрок в чат напишет сообщение, что его нужно вылечить,\nВам будет предложено вылечить его по нажатию кнопки.")
	imgui.PopItemWidth()
	imgui.EndGroup()
end

function point_sum(n)
	local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
end

function imgui.ButtonArrow()
	imgui.SetCursorPosX(134)
	if select_menu[1] then
		imgui.SetCursorPosY(5)
	elseif select_menu[2] then
		imgui.SetCursorPosY(52)
	elseif select_menu[3] then
		imgui.SetCursorPosY(99)
	elseif select_menu[4] then
		imgui.SetCursorPosY(146)
	elseif select_menu[5] then
		imgui.SetCursorPosY(193)
	elseif select_menu[7] then
		imgui.SetCursorPosY(240)
	elseif select_menu[10] then
		imgui.SetCursorPosY(287)
	elseif select_menu[6] then
		imgui.SetCursorPosY(334)
	elseif select_menu[9] then
		imgui.SetCursorPosY(381)
	end
    local p = imgui.GetCursorScreenPos()
	imgui.GetWindowDrawList():AddTriangleFilled(imgui.ImVec2(p.x + 15, p.y + 35), imgui.ImVec2(p.x - 16, p.y + 35),imgui.ImVec2(p.x + 15, p.y + 5), imgui.GetColorU32(imgui.GetStyle().Colors[imgui.Col.WindowBg]))
end
function imgui.ButtonArrowLine()
	imgui.SetCursorPosX(134)
	if select_menu[1] then
		imgui.SetCursorPosY(-5)
	elseif select_menu[2] then
		imgui.SetCursorPosY(42)
	elseif select_menu[3] then
		imgui.SetCursorPosY(89)
	elseif select_menu[4] then
		imgui.SetCursorPosY(136)
	elseif select_menu[5] then
		imgui.SetCursorPosY(183)
	elseif select_menu[7] then
		imgui.SetCursorPosY(230)
	elseif select_menu[10] then
		imgui.SetCursorPosY(277)
	elseif select_menu[6] then
		imgui.SetCursorPosY(324)
	elseif select_menu[9] then
		imgui.SetCursorPosY(371)
	end
    local p = imgui.GetCursorScreenPos()
	imgui.GetWindowDrawList():AddTriangleFilled(imgui.ImVec2(p.x + 15, p.y + 35), imgui.ImVec2(p.x - 16, p.y + 5),imgui.ImVec2(p.x + 15, p.y + 5), imgui.GetColorU32(imgui.GetStyle().Colors[imgui.Col.WindowBg]))
end

function imgui.GetCursorPosNil()
end

function mainWind()
	if not animka_main.MoveAnim then
		seelM = imgui.Cond.FirstUseEver
	else
		seelM = imgui.Cond.Always
	end
	local sw, sh = getScreenResolution()
	imgui.SetNextWindowSize(imgui.ImVec2(854, 465), seelM)
	imgui.SetNextWindowPos(imgui.ImVec2(animka_main.posX, animka_main.posY), seelM, imgui.ImVec2(0.5, 0.5))
	imgui.Begin(fa.ICON_HEARTBEAT .. " Medical Helper by Kane "..scr.version.. u8" Бета", mainWin, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoScrollWithMouse);
	imgui.SetCursorPosX(374)
	imgui.PushFont(fontsize)
	imgui.SetCursorPosY(6)
	imgui.TextColored(imgui.ImVec4(1.00, 0.56, 0.64 ,1.00), " Medical Helper")
	imgui.PopFont()
	imgui.SameLine()
	imgui.SetCursorPosX(825)
	imgui.SetCursorPosY(6)
	--iconwin.v = true --findes
	if imgui.InvisibleButton(u8" ", imgui.ImVec2(24, 24)) or animka_main.paramOff then 
		posWinClosed = imgui.GetWindowPos()
		styleAnimationClose(1, 854, 465)
		animka_main.paramOff = false
	end
	if imgui.IsItemHovered() then
		imgui.SameLine()
		imgui.SetCursorPosX(830)
		imgui.SetCursorPosY(3)
		imgui.PushFont(fa_font2)
		imgui.TextColored(imgui.ImVec4(1.00, 0.56, 0.64 ,1.00), fa.ICON_TIMES)
		imgui.PopFont()
	else
		imgui.SameLine()
		imgui.SetCursorPosX(830)
		imgui.SetCursorPosY(3)
		imgui.PushFont(fa_font2)
		imgui.Text(fa.ICON_TIMES)
		imgui.PopFont()
	end
	imgui.Separator()
	
	--> Кнопки главного меню
	imgui.SetCursorPos(imgui.ImVec2(-10, getposcur + 37))
	local p = imgui.GetCursorScreenPos()
	imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 153, p.y + 40), imgui.GetColorU32(imgui.ImVec4(1.00, 1.00, 1.00 ,0.10)), 10, 15)
	if poshovbuttr[1] or poshovbuttr[2] or poshovbuttr[3] or poshovbuttr[4] or poshovbuttr[5] or poshovbuttr[6] or poshovbuttr[7] or poshovbuttr[9] or poshovbuttr[10] then
		visbut = 0.05
	else
		visbut = 0.00
	end
	imgui.SetCursorPos(imgui.ImVec2(-10, poshovbut + 37))
	local p = imgui.GetCursorScreenPos()
	imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 153, p.y + 40), imgui.GetColorU32(imgui.ImVec4(1.00, 1.00, 1.00 ,visbut)), 10, 15)
	imgui.GetCursorStartPos()
	
	imgui.SetCursorPos(imgui.ImVec2(13, 40))
	imgui.BeginChild("Mine menu", imgui.ImVec2(137, 0), false)
	imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(20, 20, 20, 0):GetVec4())
	imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(20, 20, 20, 0):GetVec4())
	imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(20, 20, 20, 0):GetVec4())
	if imgui.Button(u8"##Главная", imgui.ImVec2(128, 39)) then select_menu = {true, false, false, false, false, false, false, false, false, false}; end
	if imgui.IsItemHovered() then
		poshovbuttr[1] = true
		poshovbut = 2
	else poshovbuttr[1] = false
	end
	imgui.Spacing()
	if imgui.Button(u8"##Наcтрoйки", imgui.ImVec2(128, 39)) then select_menu = {false, true, false, false, false, false, false, false, false, false} end	
	if imgui.IsItemHovered() then
		poshovbuttr[2] = true
		poshovbut = 49
	else poshovbuttr[2] = false
	end
	imgui.Spacing()
	if imgui.Button(u8"##Команды", imgui.ImVec2(128, 39)) then select_menu = {false, false, true, false , false, false, false, false, false, false} end	
	if imgui.IsItemHovered() then
		poshovbuttr[3] = true
		poshovbut = 96
	else poshovbuttr[3] = false
	end
	imgui.Spacing()
	if imgui.Button(u8"##Биндер", imgui.ImVec2(128, 39)) then select_menu = {false, false, false, true, false, false, false, false, false, false} end
	if imgui.IsItemHovered() then
		poshovbuttr[4] = true
		poshovbut = 143
	else poshovbuttr[4] = false
	end
	imgui.Spacing()
	if imgui.Button(u8"##Шпоры", imgui.ImVec2(128, 39)) then select_menu = {false, false, false, false, true, false, false, false, false, false}; 
		getSpurFile() 
		spur.name.v = ""
		spur.text.v = ""
		spur.edit = false
		spurBig.v = false
		spur.select_spur = -1
	end
	if imgui.IsItemHovered() then
		poshovbuttr[5] = true
		poshovbut = 190
	else poshovbuttr[5] = false
	end
	imgui.Spacing()
	if imgui.Button(u8"##Статистика", imgui.ImVec2(128, 39)) then select_menu = {false, false, false, false, false, false, true, false, false, false} end
	if imgui.IsItemHovered() then
		poshovbuttr[7] = true
		poshovbut = 237
	else poshovbuttr[7] = false
	end
	imgui.Spacing()
	if imgui.Button(u8"##Музыка", imgui.ImVec2(128, 39)) then select_menu = {false, false, false, false, false, false, false, false, false, true} 
		imgRECORD = {imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/Изображения/DANCE.png"),
			imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/Изображения/MEGAMIX.png"),
			imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/Изображения/PARTY.png"),
			imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/Изображения/PHONK.png"),
			imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/Изображения/GOPFM.png"),
			imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/Изображения/RUKIVVERH.png"),
			imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/Изображения/DUPSTEP.png"),
			imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/Изображения/BIGHITS.png"),
			imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/Изображения/ORGANIC.png"),
			imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/Изображения/RUSSIANHITS.png")
		}
		imgNoLabel = imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/nolabel.png")
	end
	if imgui.IsItemHovered() then
		poshovbuttr[10] = true
		poshovbut = 284
	else poshovbuttr[10] = false
	end
	imgui.Spacing()
	if imgui.Button(u8"##Помощь", imgui.ImVec2(128, 39)) then select_menu = {false, false, false, false, false, true, false, false, false, false} end
	if imgui.IsItemHovered() then
		poshovbuttr[6] = true
		poshovbut = 331
	else poshovbuttr[6] = false
	end
	imgui.Spacing()
	if imgui.Button(u8"##О скрипте",imgui.ImVec2(128, 39)) then select_menu = {false, false, false, false, false, false, false, false, true, false} end
	if imgui.IsItemHovered() then
		poshovbuttr[9] = true
		poshovbut = 378
	else poshovbuttr[9] = false
	end
	imgui.PopStyleColor(3)
	imgui.SetCursorPos(imgui.ImVec2(13, 11))
	if select_menu[1] then
		imgui.TextColored(imgui.ImColor(255, 255, 255, 255):GetVec4(), fa.ICON_USERS.. u8"   Главная")
		getposcur = 2
	else
		imgui.TextColored(imgui.ImColor(255, 255, 255, 150):GetVec4(), fa.ICON_USERS.. u8"   Главная")
	end
	imgui.SetCursorPos(imgui.ImVec2(13, 58))
	if select_menu[2] then
		imgui.TextColored(imgui.ImColor(255, 255, 255, 255):GetVec4(), fa.ICON_TOGGLE_ON.. u8"   Наcтрoйки")
		getposcur = 49
	else
		imgui.TextColored(imgui.ImColor(255, 255, 255, 150):GetVec4(), fa.ICON_TOGGLE_ON.. u8"   Наcтрoйки")
	end
	
	imgui.SetCursorPos(imgui.ImVec2(15, 105))
	if select_menu[3] then
		imgui.TextColored(imgui.ImColor(255, 255, 255, 255):GetVec4(), fa.ICON_TERMINAL.. u8"   Команды")
		getposcur = 96
	else
		imgui.TextColored(imgui.ImColor(255, 255, 255, 150):GetVec4(), fa.ICON_TERMINAL.. u8"   Команды")
	end
	
	imgui.SetCursorPos(imgui.ImVec2(14, 152))
	if select_menu[4] then
		imgui.TextColored(imgui.ImColor(255, 255, 255, 255):GetVec4(), fa.ICON_DESKTOP.. u8"   Биндер")
		getposcur = 143
	else
		imgui.TextColored(imgui.ImColor(255, 255, 255, 150):GetVec4(), fa.ICON_DESKTOP.. u8"   Биндер")
	end
	
	imgui.SetCursorPos(imgui.ImVec2(14, 200))
	if select_menu[5] then
		imgui.TextColored(imgui.ImColor(255, 255, 255, 255):GetVec4(), fa.ICON_BOOK.. u8"   Шпоры")
		getposcur = 190
	else
		imgui.TextColored(imgui.ImColor(255, 255, 255, 150):GetVec4(), fa.ICON_BOOK.. u8"   Шпоры")
	end
	
	imgui.SetCursorPos(imgui.ImVec2(14, 246))
	if select_menu[7] then
		imgui.TextColored(imgui.ImColor(255, 255, 255, 255):GetVec4(), fa.ICON_AREA_CHART.. u8"   Статистика")
		getposcur = 237
	else
		imgui.TextColored(imgui.ImColor(255, 255, 255, 150):GetVec4(), fa.ICON_AREA_CHART.. u8"   Статистика")
	end
	
	imgui.SetCursorPos(imgui.ImVec2(14, 293))
	if select_menu[10] then
		imgui.TextColored(imgui.ImColor(255, 255, 255, 255):GetVec4(), fa.ICON_MUSIC.. u8"   Музыка")
		getposcur = 284
	else
		imgui.TextColored(imgui.ImColor(255, 255, 255, 150):GetVec4(), fa.ICON_MUSIC.. u8"   Музыка")
	end
	
	
	imgui.SetCursorPos(imgui.ImVec2(16, 340))
	if select_menu[6] then
		imgui.TextColored(imgui.ImColor(255, 255, 255, 255):GetVec4(), fa.ICON_QUESTION.. u8"   Помощь")
		getposcur = 331
	else
		imgui.TextColored(imgui.ImColor(255, 255, 255, 150):GetVec4(), fa.ICON_QUESTION.. u8"   Помощь")
	end
	
	imgui.SetCursorPos(imgui.ImVec2(13, 387))
	if select_menu[9] then
		imgui.TextColored(imgui.ImColor(255, 255, 255, 255):GetVec4(), fa.ICON_CODE.. u8"   О скрипте")
		getposcur = 378
	else
		imgui.TextColored(imgui.ImColor(255, 255, 255, 150):GetVec4(), fa.ICON_CODE.. u8"   О скрипте")
	end
	
	imgui.GetCursorStartPos()
	imgui.EndChild();	
	---> Главное меню [1]
	if select_menu[1] then
		local colorInfo = imgui.ImColor(240, 170, 40, 255):GetVec4()
		imgui.SameLine()
		imgui.BeginGroup()
		imgui.BeginGroup()
		imgui.SetCursorPosY(153)
		imgui.Separator()
		imgui.SameLine();
		imgui.SetCursorPosX(168)
		imgui.SetCursorPosY(255)
		local p = imgui.GetCursorScreenPos()
		imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 125, p.y + 75), imgui.GetColorU32(imgui.ImVec4(1.00, 0.56, 0.64 ,0.90)), 10, 15)
		imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x+63, p.y-30), 52, imgui.GetColorU32(imgui.GetStyle().Colors[imgui.Col.WindowBg]), 60)
		imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x+63, p.y-40), 50, imgui.GetColorU32(imgui.ImVec4(1.00, 0.56, 0.64 ,0.90)), 60)
		imgui.SameLine();
		imgui.SetCursorPosX(311)
		imgui.SetCursorPosY(168)
		imgui.Text(fa.ICON_ADDRESS_CARD .. u8"  Имя и Фамилия: ");
		imgui.SameLine();
		imgui.TextColored(colorInfo, PlayerSet.name())
		imgui.SameLine();
		imgui.SetCursorPosX(311)
		imgui.SetCursorPosY(216)
		imgui.Text(fa.ICON_HOSPITAL_O .. u8"  Организация: ");
		imgui.SameLine();
		imgui.TextColored(colorInfo, PlayerSet.org());
		imgui.SameLine();
		imgui.SetCursorPosX(311)
		imgui.SetCursorPosY(263)
		imgui.Text(fa.ICON_USER .. u8"  Должность: ");
		imgui.SameLine();
		imgui.TextColored(colorInfo, PlayerSet.rank());
		imgui.SameLine();
		imgui.SetCursorPosX(311)
		imgui.SetCursorPosY(311)
		imgui.Text(fa.ICON_TRANSGENDER .. u8"  Пол: ");
		imgui.SameLine();
		imgui.TextColored(colorInfo, PlayerSet.sex())
		imgui.Dummy(imgui.ImVec2(0, 8))
		imgui.Separator()	
		imgui.EndGroup()
		imgui.EndGroup()
	end
	---> Настройки [2]
	if select_menu[2] then
		imgui.SameLine()
		imgui.BeginGroup()
	--- НАЧАЛО ГРУППЫ ПЕРЕХОДА ---
		local function Separatordraw(xsep, ysep, pxs)
			imgui.SetCursorPos(imgui.ImVec2(xsep, ysep))
			local p = imgui.GetCursorScreenPos()
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + pxs, p.y + 1), imgui.GetColorU32(imgui.ImVec4(0.35, 0.35, 0.35 ,1.00)))
		end
		local function IconsBackground(xicon, yicon, imvec)
			imgui.SetCursorPos(imgui.ImVec2(xicon, yicon))
			local p = imgui.GetCursorScreenPos()
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 24, p.y + 24), imgui.GetColorU32(imvec), 5, 15)
		end
		--------------------------------------------------------------------------------
		imgui.SetCursorPos(imgui.ImVec2(158, 49))
		if imgui.InvisibleButton(u8"##Основная информация", imgui.ImVec2(234, 37)) then sel_menu_set = 1 end
		imgui.SetCursorPos(imgui.ImVec2(156, 47))
		local p = imgui.GetCursorScreenPos()
		if imgui.IsItemActive() and sel_menu_set ~= 1 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 237, p.y + 38), imgui.GetColorU32(imgui.ImVec4(0.10, 0.10, 0.10 ,1.00)), 10, 3)
		elseif imgui.IsItemHovered() and sel_menu_set ~= 1 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 237, p.y + 38), imgui.GetColorU32(imgui.ImVec4(0.30, 0.30, 0.30 ,1.00)), 10, 3)
		elseif sel_menu_set ~= 1 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 237, p.y + 38), imgui.GetColorU32(imgui.ImVec4(0.15, 0.15, 0.15 ,1.00)), 10, 3)
		elseif sel_menu_set == 1 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 237, p.y + 38), imgui.GetColorU32(imgui.ImVec4(0.35, 0.35, 0.35 ,1.00)), 10, 3)
			mainSet()
		end
		IconsBackground(168, 54, imgui.ImVec4(0.50, 0.50, 0.50 ,1.00))
		imgui.SameLine()
		if sel_menu_set == 1 then
			imgui.SetCursorPos(imgui.ImVec2(172, 55))
		else
			imgui.SetCursorPos(imgui.ImVec2(172, 58))
		end
		imgui.Text(fa.ICON_COGS)
		imgui.SetCursorPos(imgui.ImVec2(200, 58))
		imgui.Text(u8" Основная информация")
		imgui.SetCursorPos(imgui.ImVec2(375, 60))
		imgui.TextColored(imgui.ImVec4(1.00, 1.00, 1.00 ,0.50), fa.ICON_CHEVRON_RIGHT)
		imgui.SetCursorPos(imgui.ImVec2(158, 86))
		if imgui.InvisibleButton(u8"##Настройки чата", imgui.ImVec2(234, 37)) then sel_menu_set = 2 end
		imgui.SetCursorPos(imgui.ImVec2(156, 85))
		local p = imgui.GetCursorScreenPos()
		if imgui.IsItemActive() and sel_menu_set ~= 2 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 237, p.y + 38), imgui.GetColorU32(imgui.ImVec4(0.10, 0.10, 0.10 ,1.00)))
		elseif imgui.IsItemHovered() and sel_menu_set ~= 2 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 237, p.y + 38), imgui.GetColorU32(imgui.ImVec4(0.30, 0.30, 0.30 ,1.00)))
		elseif sel_menu_set ~= 2 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 237, p.y + 38), imgui.GetColorU32(imgui.ImVec4(0.15, 0.15, 0.15 ,1.00)))
		elseif sel_menu_set == 2 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 237, p.y + 38), imgui.GetColorU32(imgui.ImVec4(0.35, 0.35, 0.35 ,1.00)))
			mainSet()
		end
		IconsBackground(168, 92, imgui.ImVec4(0.99, 0.60, 0.00 ,1.00))
		if sel_menu_set == 1 or imgui.IsItemHovered() then
			Separatordraw(204, 84, 189)
		else
			Separatordraw(204, 85, 189)
		end
		imgui.SameLine()
		if sel_menu_set == 2 then
			imgui.SetCursorPos(imgui.ImVec2(173, 93))
		else
			imgui.SetCursorPos(imgui.ImVec2(173, 96))
		end
		imgui.Text(fa.ICON_BARS)
		imgui.SetCursorPos(imgui.ImVec2(200, 96))
		imgui.Text(u8" Настройки чата")
		imgui.SetCursorPos(imgui.ImVec2(375, 98))
		imgui.TextColored(imgui.ImVec4(1.00, 1.00, 1.00 ,0.50), fa.ICON_CHEVRON_RIGHT)
		imgui.SetCursorPos(imgui.ImVec2(158, 124))
		if imgui.InvisibleButton(u8"##Ценовая политика", imgui.ImVec2(234, 37)) then sel_menu_set = 3 end
		imgui.SetCursorPos(imgui.ImVec2(156, 123))
		local p = imgui.GetCursorScreenPos()
		if imgui.IsItemActive() and sel_menu_set ~= 3 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 237, p.y + 38), imgui.GetColorU32(imgui.ImVec4(0.10, 0.10, 0.10 ,1.00)))
		elseif imgui.IsItemHovered() and sel_menu_set ~= 3 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 237, p.y + 38), imgui.GetColorU32(imgui.ImVec4(0.30, 0.30, 0.30 ,1.00)))
		elseif sel_menu_set ~= 3 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 237, p.y + 38), imgui.GetColorU32(imgui.ImVec4(0.15, 0.15, 0.15 ,1.00)))
		elseif sel_menu_set == 3 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 237, p.y + 38), imgui.GetColorU32(imgui.ImVec4(0.35, 0.35, 0.35 ,1.00)))
			mainSet()
		end
		imgui.SameLine()
		IconsBackground(168, 130, imgui.ImVec4(0.20, 0.78, 0.35 ,1.00))
		if sel_menu_set == 2 or imgui.IsItemHovered() then
			Separatordraw(204, 122, 189)
		else
			Separatordraw(204, 123, 189)
		end
		if sel_menu_set == 3 then
			imgui.SetCursorPos(imgui.ImVec2(176, 132))
		else
			imgui.SetCursorPos(imgui.ImVec2(176, 135))
		end
		imgui.Text(fa.ICON_USD)
		imgui.SetCursorPos(imgui.ImVec2(200, 135))
		imgui.Text(u8" Ценовая политика")
		imgui.SetCursorPos(imgui.ImVec2(375, 137))
		imgui.TextColored(imgui.ImVec4(1.00, 1.00, 1.00 ,0.50), fa.ICON_CHEVRON_RIGHT)
		
		imgui.SetCursorPos(imgui.ImVec2(158, 162))
		if imgui.InvisibleButton(u8"##Обновления", imgui.ImVec2(234, 37)) then sel_menu_set = 7 end
		imgui.SetCursorPos(imgui.ImVec2(156, 161))
		local p = imgui.GetCursorScreenPos()
		if imgui.IsItemActive() and sel_menu_set ~= 7 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 237, p.y + 38), imgui.GetColorU32(imgui.ImVec4(0.10, 0.10, 0.10 ,1.00)), 10, 12)
		elseif imgui.IsItemHovered() and sel_menu_set ~= 7 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 237, p.y + 38), imgui.GetColorU32(imgui.ImVec4(0.30, 0.30, 0.30 ,1.00)), 10, 12)
		elseif sel_menu_set ~= 7 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 237, p.y + 38), imgui.GetColorU32(imgui.ImVec4(0.15, 0.15, 0.15 ,1.00)), 10, 12)
		elseif sel_menu_set == 7 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 237, p.y + 38), imgui.GetColorU32(imgui.ImVec4(0.35, 0.35, 0.35 ,1.00)), 10, 12)
			mainSet()
		end
		imgui.SameLine()
		IconsBackground(168, 168, imgui.ImVec4(0.50, 0.50, 0.50 ,1.00))
		if sel_menu_set == 3 or imgui.IsItemHovered() then
			Separatordraw(204, 160, 189)
		else
			Separatordraw(204, 161, 189)
		end
		if sel_menu_set == 7 then
			imgui.SetCursorPos(imgui.ImVec2(173, 169))
		else
			imgui.SetCursorPos(imgui.ImVec2(173, 172))
		end
		imgui.Text(fa.ICON_DOWNLOAD)
		imgui.SetCursorPos(imgui.ImVec2(200, 172))
		imgui.Text(u8" Обновления")
		imgui.SetCursorPos(imgui.ImVec2(375, 174))
		imgui.TextColored(imgui.ImVec4(1.00, 1.00, 1.00 ,0.50), fa.ICON_CHEVRON_RIGHT)
		
		imgui.SetCursorPos(imgui.ImVec2(158, 220))
		if imgui.InvisibleButton(u8"##Функции", imgui.ImVec2(234, 37)) then sel_menu_set = 5 end
		imgui.SetCursorPos(imgui.ImVec2(156, 219))
		local p = imgui.GetCursorScreenPos()
		if imgui.IsItemActive() and sel_menu_set ~= 5 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 237, p.y + 38), imgui.GetColorU32(imgui.ImVec4(0.10, 0.10, 0.10 ,1.00)), 10, 3)
		elseif imgui.IsItemHovered() and sel_menu_set ~= 5 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 237, p.y + 38), imgui.GetColorU32(imgui.ImVec4(0.30, 0.30, 0.30 ,1.00)), 10, 3)
		elseif sel_menu_set ~= 5 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 237, p.y + 38), imgui.GetColorU32(imgui.ImVec4(0.15, 0.15, 0.15 ,1.00)), 10, 3)
		elseif sel_menu_set == 5 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 237, p.y + 38), imgui.GetColorU32(imgui.ImVec4(0.35, 0.35, 0.35 ,1.00)), 10, 3)
			mainSet()
		end
		imgui.SameLine()
		IconsBackground(168, 226, imgui.ImVec4(0.97, 0.23, 0.19 ,1.00))
		if sel_menu_set == 5 then
			imgui.SetCursorPos(imgui.ImVec2(175, 231))
		else
			imgui.SetCursorPos(imgui.ImVec2(175, 231))
		end
		imgui.Text(fa.ICON_FACEBOOK)
		imgui.SetCursorPos(imgui.ImVec2(200, 230))
		imgui.Text(u8" Функции")
		imgui.SetCursorPos(imgui.ImVec2(375, 232))
		imgui.TextColored(imgui.ImVec4(1.00, 1.00, 1.00 ,0.50), fa.ICON_CHEVRON_RIGHT)
		
		imgui.SetCursorPos(imgui.ImVec2(158, 258))
		if imgui.InvisibleButton(u8"##Напоминания", imgui.ImVec2(234, 37)) then sel_menu_set = 6 end
		imgui.SetCursorPos(imgui.ImVec2(156, 257))
		local p = imgui.GetCursorScreenPos()
		if imgui.IsItemActive() and sel_menu_set ~= 6 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 237, p.y + 38), imgui.GetColorU32(imgui.ImVec4(0.10, 0.10, 0.10 ,1.00)))
		elseif imgui.IsItemHovered() and sel_menu_set ~= 6 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 237, p.y + 38), imgui.GetColorU32(imgui.ImVec4(0.30, 0.30, 0.30 ,1.00)))
		elseif sel_menu_set ~= 6 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 237, p.y + 38), imgui.GetColorU32(imgui.ImVec4(0.15, 0.15, 0.15 ,1.00)))
		elseif sel_menu_set == 6 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 237, p.y + 38), imgui.GetColorU32(imgui.ImVec4(0.35, 0.35, 0.35 ,1.00)))
			mainSet()
		end
		imgui.SameLine()
		IconsBackground(168, 264, imgui.ImVec4(0.34, 0.33, 0.83 ,1.00))
		if sel_menu_set == 5 or imgui.IsItemHovered() then
			Separatordraw(204, 256, 189)
		else
			Separatordraw(204, 257, 189)
		end
		if sel_menu_set == 6 then
			imgui.SetCursorPos(imgui.ImVec2(173, 268))
		else
			imgui.SetCursorPos(imgui.ImVec2(173, 268))
		end
		imgui.Text(fa.ICON_BELL)
		imgui.SetCursorPos(imgui.ImVec2(200, 268))
		imgui.Text(u8" Напоминания")
		imgui.SetCursorPos(imgui.ImVec2(375, 270))
		imgui.TextColored(imgui.ImVec4(1.00, 1.00, 1.00 ,0.50), fa.ICON_CHEVRON_RIGHT)
		
		imgui.SetCursorPos(imgui.ImVec2(158, 296))
		if imgui.InvisibleButton(u8"##Мемберс", imgui.ImVec2(234, 37)) then sel_menu_set = 4 end
		imgui.SetCursorPos(imgui.ImVec2(156, 295))
		local p = imgui.GetCursorScreenPos()
		if imgui.IsItemActive() and sel_menu_set ~= 4 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 237, p.y + 38), imgui.GetColorU32(imgui.ImVec4(0.10, 0.10, 0.10 ,1.00)))
		elseif imgui.IsItemHovered() and sel_menu_set ~= 4 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 237, p.y + 38), imgui.GetColorU32(imgui.ImVec4(0.30, 0.30, 0.30 ,1.00)))
		elseif sel_menu_set ~= 4 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 237, p.y + 38), imgui.GetColorU32(imgui.ImVec4(0.15, 0.15, 0.15 ,1.00)))
		elseif sel_menu_set == 4 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 237, p.y + 38), imgui.GetColorU32(imgui.ImVec4(0.35, 0.35, 0.35 ,1.00)))
			mainSet()
		end
		imgui.SameLine()
		IconsBackground(168, 302, imgui.ImVec4(0.0, 0.47, 0.99 ,1.00))
		if sel_menu_set == 6 or imgui.IsItemHovered() then
			Separatordraw(204, 294, 189)
		else
			Separatordraw(204, 295, 189)
		end
		if sel_menu_set == 4 then
			if C_membScr.func.v then
				imgui.SetCursorPos(imgui.ImVec2(173, 303))
			else
				imgui.SetCursorPos(imgui.ImVec2(173, 306))
			end
		else
			imgui.SetCursorPos(imgui.ImVec2(173, 306))
		end
		imgui.Text(fa.ICON_USER_CIRCLE_O)
		imgui.SetCursorPos(imgui.ImVec2(200, 306))
		imgui.Text(u8" Мемберс")
		imgui.SetCursorPos(imgui.ImVec2(375, 308))
		imgui.TextColored(imgui.ImVec4(1.00, 1.00, 1.00 ,0.50), fa.ICON_CHEVRON_RIGHT)
		----> Быстрый доступ
		imgui.SetCursorPos(imgui.ImVec2(158, 334))
		if imgui.InvisibleButton(u8"##Быстрый доступ", imgui.ImVec2(234, 37)) then
			if #optionsPKM > 13 then
				for m = 14, #optionsPKM do
					table.remove(optionsPKM, 14)
				end
			end
			sel_menu_set = 8 
		end
		imgui.SetCursorPos(imgui.ImVec2(156, 333))
		local p = imgui.GetCursorScreenPos()
		if imgui.IsItemActive() and sel_menu_set ~= 8 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 237, p.y + 38), imgui.GetColorU32(imgui.ImVec4(0.10, 0.10, 0.10 ,1.00)), 10, 12)
		elseif imgui.IsItemHovered() and sel_menu_set ~= 8 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 237, p.y + 38), imgui.GetColorU32(imgui.ImVec4(0.30, 0.30, 0.30 ,1.00)), 10, 12)
		elseif sel_menu_set ~= 8 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 237, p.y + 38), imgui.GetColorU32(imgui.ImVec4(0.15, 0.15, 0.15 ,1.00)), 10, 12)
		elseif sel_menu_set == 8 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 237, p.y + 38), imgui.GetColorU32(imgui.ImVec4(0.35, 0.35, 0.35 ,1.00)), 10, 12)
			mainSet()
		end
		imgui.SameLine()
		IconsBackground(168, 340, imgui.ImVec4(1.0, 0.14, 0.33 ,1.00))
		if sel_menu_set == 4 or imgui.IsItemHovered() then
			Separatordraw(204, 332, 189)
		else
			Separatordraw(204, 333, 189)
		end
		if sel_menu_set == 8 then
			if chg_funcPKM.func.v then
				imgui.SetCursorPos(imgui.ImVec2(173, 342))
			else
				imgui.SetCursorPos(imgui.ImVec2(173, 345))
			end
		else
			imgui.SetCursorPos(imgui.ImVec2(173, 345))
		end
		imgui.Text(fa.ICON_LINK)
		imgui.SetCursorPos(imgui.ImVec2(200, 344))
		imgui.Text(u8" Быстрый доступ")
		imgui.SetCursorPos(imgui.ImVec2(375, 346))
		imgui.TextColored(imgui.ImVec4(1.00, 1.00, 1.00 ,0.50), fa.ICON_CHEVRON_RIGHT)
		imgui.EndGroup()
	end
	--> Команды [3]
	if select_menu[3] then
		imgui.SameLine()
		imgui.BeginGroup()
		imgui.BeginChild("cmd list", imgui.ImVec2(0, 360), false)
		
		for i = 1, #cmdBind do
			if i ~= selected_cmd and cmdBind[i].rank <= num_rank.v+1 and cmdBind[i].rank ~= 1.5 then
				imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(255, 255, 255, 7):GetVec4())
				imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(255, 255, 255, 15):GetVec4())
				imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(255, 255, 255, 8):GetVec4())
			elseif cmdBind[i].rank <= num_rank.v+1 and cmdBind[i].rank ~= 1.5 then
				imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(255, 255, 255, 26):GetVec4())
				imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(255, 255, 255, 33):GetVec4())
				imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(255, 255, 255, 28):GetVec4())
			end
			if (i ~= selected_cmd and cmdBind[i].rank > num_rank.v+1) or (cmdBind[i].rank == 1.5 and i ~= selected_cmd) then
				imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(255, 255, 255, 5):GetVec4())
				imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(255, 255, 255, 12):GetVec4())
				imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(255, 255, 255, 6):GetVec4())
			elseif (i == selected_cmd and cmdBind[i].rank > num_rank.v+1) or (cmdBind[i].rank == 1.5 and i == selected_cmd) then
				imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(255, 255, 255, 13):GetVec4())
				imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(255, 255, 255, 20):GetVec4())
				imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(255, 255, 255, 15):GetVec4())
			end
			if imgui.Button(u8"##cmdB"..i, imgui.ImVec2(665, 30)) then
				selected_cmd = i
			end
			imgui.PopStyleColor(3)
		end
		
		for i = 1, #cmdBind do
			imgui.SetCursorPos(imgui.ImVec2(18, -28 + (i*34)))
			if cmdBind[i].rank <= num_rank.v+1 and cmdBind[i].rank ~= 1.5 then
				imgui.TextColoredRGB("/"..cmdBind[i].cmd.."  {858585}—  "..cmdBind[i].desc)
			else
				imgui.TextColoredRGB("{4d4d4d}/"..cmdBind[i].cmd.."  —  "..cmdBind[i].desc)
			end
		end
		
		imgui.EndChild()
		if cmdBind[selected_cmd].rank <= num_rank.v+1 and cmdBind[selected_cmd].rank ~= 1.5 then
			imgui.SetCursorPos(imgui.ImVec2(630, 423))
			if #cmdBind[selected_cmd].key == 0 then
				imgui.TextColoredRGB("{FFFFFF}Текущая клавиша:  {e84a4a}Отсутствует")
			else
				imgui.TextColoredRGB("{FFFFFF}Текущая клавиша:  {3cc74e}"..table.concat(rkeys.getKeysName(cmdBind[selected_cmd].key), " + "))
			end
			if selected_cmd == 5 or selected_cmd == 7 or selected_cmd == 8 or selected_cmd == 9 or selected_cmd == 10 or selected_cmd == 13
			or selected_cmd == 14 or selected_cmd == 15 or selected_cmd == 16 or selected_cmd == 17 or selected_cmd == 18
			or selected_cmd == 19 or selected_cmd == 20 or selected_cmd == 22 or selected_cmd == 23 or selected_cmd == 25 or selected_cmd == 26 
			or selected_cmd == 27 or selected_cmd == 28 or selected_cmd == 29 or selected_cmd == 34 or selected_cmd == 35 or selected_cmd == 36 then
				imgui.SetCursorPos(imgui.ImVec2(155, 404))
				if imgui.Button(u8"Редактировать отыгровку", imgui.ImVec2(230, 25)) then
					acting_buf = {argfunc = imgui.ImBool(false), arg = {}, varfunc = imgui.ImBool(false), var = {},  
					chatopen = imgui.ImBool(false),	typeAct = {}, sec = imgui.ImFloat(1.0)}
					acting_buf.argfunc.v = acting[selected_cmd].argfunc
					acting_buf.varfunc.v = acting[selected_cmd].varfunc
					acting_buf.sec.v = acting[selected_cmd].sec
					acting_buf.chatopen.v = acting[selected_cmd].chatopen
					variab = {}
					for k = 1, #acting[selected_cmd].typeAct do
						if acting[selected_cmd].typeAct[k][1] ~= 2 and acting[selected_cmd].typeAct[k][1] ~= 4 then
							acting_buf.typeAct[k] = {imgui.ImInt(0), imgui.ImBuffer(acting[selected_cmd].typeAct[k][2], 1024)}
							acting_buf.typeAct[k][1].v = acting[selected_cmd].typeAct[k][1]
						elseif acting[selected_cmd].typeAct[k][1] == 2 then
							acting_buf.typeAct[k] = {imgui.ImInt(0), {}}
							acting_buf.typeAct[k][1].v = acting[selected_cmd].typeAct[k][1]
							for m = 1, #acting[selected_cmd].typeAct[k][2] do
								acting_buf.typeAct[k][2][m] = imgui.ImBuffer(1024)
								acting_buf.typeAct[k][2][m].v = acting[selected_cmd].typeAct[k][2][m]
							end
						elseif acting[selected_cmd].typeAct[k][1] == 4 then
							acting_buf.typeAct[k] = {imgui.ImInt(0), imgui.ImInt(0), imgui.ImBuffer(128)}
							acting_buf.typeAct[k][1].v = acting[selected_cmd].typeAct[k][1]
							acting_buf.typeAct[k][2].v = acting[selected_cmd].typeAct[k][2]
							acting_buf.typeAct[k][3].v = acting[selected_cmd].typeAct[k][3]
						end
					end
					for k = 1, #acting[selected_cmd].arg do
						acting_buf.arg[k] = {imgui.ImInt(0), imgui.ImBuffer(128)}
						acting_buf.arg[k][1].v = acting[selected_cmd].arg[k][1]
						acting_buf.arg[k][2].v = acting[selected_cmd].arg[k][2]
					end
					for k = 1, #acting[selected_cmd].var do
						acting_buf.var[k] = imgui.ImBuffer(128)
						acting_buf.var[k].v = acting[selected_cmd].var[k]
						variab[k] = "{var"..k.."}"
					end
					actingOutWind.v = true
				end
			else
				imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(255, 255, 255, 20):GetVec4())
				imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(255, 255, 255, 20):GetVec4())
				imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(255, 255, 255, 20):GetVec4())
				imgui.SetCursorPos(imgui.ImVec2(155, 404))
				imgui.Button(u8"##Редактировать отыгровку", imgui.ImVec2(230, 25))
				imgui.SetCursorPos(imgui.ImVec2(187, 408))
				imgui.TextColoredRGB("{6e6e6e}Редактировать отыгровку")
				imgui.PopStyleColor(3)
			end
			imgui.SetCursorPos(imgui.ImVec2(390, 404))
			if imgui.Button(u8"Назначить клавишу", imgui.ImVec2(230, 25)) then 
				imgui.OpenPopup(u8"MH | Установка клавиши для активации");
				lockPlayerControl(true)
				editKey = true
			end
			if cmdBind[selected_cmd].cmd ~= "r" and cmdBind[selected_cmd].cmd ~= "rb" and cmdBind[selected_cmd].cmd ~= "time" then
				imgui.SetCursorPos(imgui.ImVec2(155, 433))
				if imgui.Button(u8"Изменить команду", imgui.ImVec2(230, 25)) then 
					chgName.inp.v = cmdBind[selected_cmd].cmd
					unregcmd = chgName.inp.v
					imgui.OpenPopup(u8"MH | Редактирование команды")
				end
			else
				imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(255, 255, 255, 20):GetVec4())
				imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(255, 255, 255, 20):GetVec4())
				imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(255, 255, 255, 20):GetVec4())
				imgui.Button(u8"##Изменить команду", imgui.ImVec2(230, 25))
				imgui.PopStyleColor(3)
				imgui.SetCursorPos(imgui.ImVec2(210, 437))
				imgui.TextColoredRGB("{6e6e6e}Изменить команду")
			end
			imgui.SetCursorPos(imgui.ImVec2(390, 433))
			if imgui.Button(u8"Очистить активацию", imgui.ImVec2(230, 25)) then 
				rkeys.unRegisterHotKey(cmdBind[selected_cmd].key)
				unRegisterHotKey(cmdBind[selected_cmd].key)
				cmdBind[selected_cmd].key = {}
				local f = io.open(dirml.."/MedicalHelper/cmdSetting.med", "w")
				f:write(encodeJson(cmdBind))
				f:flush()
				f:close()
			end	
		else
			imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(255, 255, 255, 20):GetVec4())
			imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(255, 255, 255, 20):GetVec4())
			imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(255, 255, 255, 20):GetVec4())
			imgui.Button(u8"##Редактировать отыгровку", imgui.ImVec2(230, 25))
			imgui.SameLine()
			imgui.Button(u8"##Назначить клавишу", imgui.ImVec2(230, 25))
			imgui.Button(u8"##Изменить команду", imgui.ImVec2(230, 25))
			imgui.SameLine()
			imgui.Button(u8"##Очистить активацию", imgui.ImVec2(230, 25))
			imgui.PopStyleColor(3)
			imgui.SetCursorPos(imgui.ImVec2(187, 408))
			imgui.TextColoredRGB("{6e6e6e}Редактировать отыгровку                      Назначить клавишу")
			imgui.SetCursorPos(imgui.ImVec2(210, 437))
			imgui.TextColoredRGB("{6e6e6e}Изменить команду                           Очистить активацию")
			if cmdBind[selected_cmd].rank ~= 1.5 then
				imgui.SetCursorPos(imgui.ImVec2(630, 414))
				imgui.Text(u8"Данная команда доступна\nминимум с "..cmdBind[selected_cmd].rank..u8" ранга.")
			elseif cmdBind[selected_cmd].cmd == "hall" then
				imgui.SetCursorPos(imgui.ImVec2(630, 414))
				imgui.Text(u8"Данная команда доступна\nс помощью клавиш ПКМ + 2")
			elseif cmdBind[selected_cmd].cmd == "hilka" then
				imgui.SetCursorPos(imgui.ImVec2(630, 414))
				imgui.Text(u8"Данная команда доступна\nс помощью клавиш ПКМ + 1")
			end
		end	
		imgui.EndGroup()
	end
	--> Шпаргалка
	if select_menu[5] then
		imgui.SameLine()
		imgui.BeginChild("shpora but", imgui.ImVec2(0, 0), false)
		imgui.SetCursorPos(imgui.ImVec2(positbut3, 2))
		imgui.BeginChild("shpora list", imgui.ImVec2(0, 355), false)
		
		if #spur.list ~= 0 then
			if spur.select_spur == -1 then
				spur.select_spur = 1
			end
			for i = 1, #spur.list do
				if i ~= spur.select_spur then
					imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(255, 255, 255, 7):GetVec4())
					imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(255, 255, 255, 15):GetVec4())
					imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(255, 255, 255, 8):GetVec4())
				else
					imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(255, 255, 255, 24):GetVec4())
					imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(255, 255, 255, 40):GetVec4())
					imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(255, 255, 255, 26):GetVec4())
				end
				if imgui.Button(u8"##spurBut"..i, imgui.ImVec2(665, 30)) then
					spur.select_spur = i
					spur.text.v = ""
					spur.name.v = ""
					spur.edit = false
					spurBig.v = false
				end
				imgui.PopStyleColor(3)
			end
			for i = 1, #spur.list do
				imgui.SetCursorPos(imgui.ImVec2(18, -28 + (i*34)))
				imgui.Text(i..".  "..u8(spur.list[i]))
				--imgui.SetCursorPos(imgui.ImVec2(640, -26 + (i*34)))
				--imgui.TextColored(imgui.ImColor(255, 255, 255, 100):GetVec4(), fa.ICON_CHEVRON_RIGHT)
			end
		else
			imgui.SetCursorPos(imgui.ImVec2(145, 175))
			imgui.TextColoredRGB('Нажмите на нижнюю кнопку для создания новой шпаргалки.')
		end
		
		
		imgui.EndChild()
		if #spur.list ~= 0 then
			imgui.SetCursorPos(imgui.ImVec2(positbut3, 360))
			if imgui.Button(u8"Открыть для просмотра##шпору", imgui.ImVec2(226, 25)) then
				if not spurBig.v then
					styleAnimationOpen(5)
					spurBig.v = true
					examination = true
					textEndShpora = {}
				else
					animka_big.paramOff = true
				end
			end
			imgui.SameLine()
			if imgui.Button(u8"Редактировать шпору##шпору", imgui.ImVec2(226, 25)) then
				activebutanim3[1] = true
				spur.edit = true
				local f = io.open(dirml.."/MedicalHelper/Шпаргалки/"..spur.list[spur.select_spur]..".txt", "r")
				spur.text.v = u8(f:read("*a"))
				f:close()
				spur.name.v = u8(spur.list[spur.select_spur])
			end
			imgui.SameLine()
			if imgui.Button(u8"Удалить шпору##шпору", imgui.ImVec2(226, 25)) then 
				if doesFileExist(dirml.."/MedicalHelper/Шпаргалки/"..spur.list[spur.select_spur]..".txt") then
					os.remove(dirml.."/MedicalHelper/Шпаргалки/"..spur.list[spur.select_spur]..".txt")
				end
				table.remove(spur.list, spur.select_spur)
				if #spur.list >= 2 then
					if spur.select_spur ~= 1 then
						spur.select_spur = spur.select_spur -1
					else
						spur.select_spur = -1
					end
				else
					spur.select_spur = -1
				end
			end
			
		end
		imgui.SetCursorPos(imgui.ImVec2(positbut3, 390))
		if imgui.Button(u8"Создать новую шпаргалку##шпору", imgui.ImVec2(688, 25)) then 
			if #spur.list ~= 20 then
				for i = 1, 20 do
					if not table.concat(spur.list, "|"):find("Шпаргалка '"..i.."'") then
						table.insert(spur.list, "Шпаргалка '"..i.."'")
						spur.edit = true
						spur.select_spur = #spur.list
						spur.name.v = ""
						spur.text.v = ""
						spurBig.v = false
						local f = io.open(dirml.."/MedicalHelper/Шпаргалки/Шпаргалка '"..i.."'.txt", "w")
						f:write("")
						f:flush()
						f:close()
						break
					end
				end
			end
		end
		imgui.SetCursorPos(imgui.ImVec2(positbut3 + 699, 2))
		imgui.BeginChild("ShporaEdit", imgui.ImVec2(691, 415), false)
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(255, 255, 255, 3):GetVec4())
		imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(255, 255, 255, 5):GetVec4())
		imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(255, 255, 255, 8):GetVec4())
		if imgui.Button(fa.ICON_CHEVRON_LEFT, imgui.ImVec2(40, 410)) then
			activebutanim3[2] = true
		end
		imgui.PopStyleColor(3)
		
		if spur.edit and not spurBig.v then
			imgui.SetCursorPos(imgui.ImVec2(300, 0))
			imgui.Text(u8"Поле для заполнения")
			imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImColor(70, 70, 70, 200):GetVec4())
			imgui.SetCursorPosX(50)
			imgui.InputTextMultiline("##spur", spur.text, imgui.ImVec2(640, 300))
			imgui.PopStyleColor(1)
			imgui.PushItemWidth(400)
			imgui.SetCursorPosX(50)
			if imgui.Button(u8"Открыть большой редактор/просмотр", imgui.ImVec2(640, 25)) then
				if not spurBig.v then
					styleAnimationOpen(5)
					spurBig.v = true
					examination = true
					textEndShpora = {}
				else
					animka_big.paramOff = true
				end
			end
			imgui.Spacing()
			imgui.SetCursorPosX(50)
			imgui.PushItemWidth(526)
			imgui.InputText(u8"Название шпоры", spur.name, imgui.InputTextFlags.CallbackCharFilter, filter(1, "[%wа-Я%+%№%#%(%)%s]"))
			imgui.Spacing()
			imgui.PopItemWidth()
			imgui.SetCursorPosX(50)
			if imgui.Button(u8"Удалить", imgui.ImVec2(317, 25)) then
				activebutanim3[2] = true
				if doesFileExist(dirml.."/MedicalHelper/Шпаргалки/"..spur.list[spur.select_spur]..".txt") then
					os.remove(dirml.."/MedicalHelper/Шпаргалки/"..spur.list[spur.select_spur]..".txt")
				end
				table.remove(spur.list, spur.select_spur) 
				spur.edit = false
				spur.name.v = ""
				spur.text.v = ""
				if #spur.list >= 2 then
					if spur.select_spur ~= 1 then
						spur.select_spur = spur.select_spur -1
					else
						spur.select_spur = -1
					end
				else
					spur.select_spur = -1
				end
			end
			imgui.SameLine()
			if imgui.Button(u8"Сохранить", imgui.ImVec2(317, 25)) then
				activebutanim3[2] = true
				local name = ""
				local bool = false
				if spur.name.v ~= "" then 
					name = u8:decode(spur.name.v)
					if doesFileExist(dirml.."/MedicalHelper/Шпаргалки/"..name..".txt") and spur.list[spur.select_spur] ~= name then
						bool = true
						imgui.OpenPopup(u8"Ошибка")
					else
						os.remove(dirml.."/MedicalHelper/Шпаргалки/"..spur.list[spur.select_spur]..".txt")
						spur.list[spur.select_spur] = u8:decode(spur.name.v)
					end
				else
					name = spur.list[spur.select_spur]
				end
				if not bool then
					local f = io.open(dirml.."/MedicalHelper/Шпаргалки/"..name..".txt", "w")
					f:write(u8:decode(spur.text.v))
					f:flush()
					f:close()
					spur.text.v = ""
					spur.name.v = ""
				end
			end
		elseif spurBig.v then
			imgui.SetCursorPos(imgui.ImVec2(270, 200))
			imgui.TextColoredRGB("Включено большое окно")
		end
		imgui.EndChild()
		imgui.EndChild()
		if activebutanim3[1] then 
			if positbut3 > -699 then
				positbut3 = positbut3 - 23
			else
				activebutanim3[1] = false
				positbut3 = - 699
			end
		end
		
		if activebutanim3[2] then 
			if positbut3 < 0 then
				positbut3 = positbut3 + 27
			else
				activebutanim3[2] = false
				positbut3 = 0
			end
		end
	--[[

		if spur.edit and not spurBig.v then
			imgui.SetCursorPosX(515)
			imgui.Text(u8"Поле для заполнения")
			imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImColor(70, 70, 70, 200):GetVec4())
			imgui.InputTextMultiline("##spur", spur.text, imgui.ImVec2(550, 306))
			imgui.PopStyleColor(1)
			imgui.PushItemWidth(400)
			if imgui.Button(u8"Открыть большой редактор/просмотр", imgui.ImVec2(550, 25)) then
				if not spurBig.v then
					styleAnimationOpen(5)
					spurBig.v = true
					examination = true
					textEndShpora = {}
				else
					animka_big.paramOff = true
				end
			end
			imgui.Spacing() 
			imgui.InputText(u8"Название шпоры", spur.name, imgui.InputTextFlags.CallbackCharFilter, filter(1, "[%wа-Я%+%№%#%(%)%s]"))
			imgui.Spacing()
			imgui.PopItemWidth()
			if imgui.Button(u8"Удалить", imgui.ImVec2(272, 25)) then
				if doesFileExist(dirml.."/MedicalHelper/Шпаргалки/"..spur.list[spur.select_spur]..".txt") then
					os.remove(dirml.."/MedicalHelper/Шпаргалки/"..spur.list[spur.select_spur]..".txt")
				end
				table.remove(spur.list, spur.select_spur) 
				spur.edit = false
				spur.select_spur = -1
				spur.name.v = ""
				spur.text.v = ""
			end
			imgui.SameLine()
			if imgui.Button(u8"Сохранить", imgui.ImVec2(272, 25)) then
				local name = ""
				local bool = false
				if spur.name.v ~= "" then 
					name = u8:decode(spur.name.v)
					if doesFileExist(dirml.."/MedicalHelper/Шпаргалки/"..name..".txt") and spur.list[spur.select_spur] ~= name then
						bool = true
						imgui.OpenPopup(u8"Ошибка")
					else
						os.remove(dirml.."/MedicalHelper/Шпаргалки/"..spur.list[spur.select_spur]..".txt")
						spur.list[spur.select_spur] = u8:decode(spur.name.v)
					end
				else
					name = spur.list[spur.select_spur]
				end
				if not bool then
					local f = io.open(dirml.."/MedicalHelper/Шпаргалки/"..name..".txt", "w")
					f:write(u8:decode(spur.text.v))
					f:flush()
					f:close()
					spur.text.v = ""
					spur.name.v = ""
					spur.edit = false
				end
			end
		elseif spurBig.v then
			imgui.Dummy(imgui.ImVec2(0, 150))
			imgui.SetCursorPosX(500)
			imgui.TextColoredRGB("Включено большое окно")
		elseif not spurBig.v and (spur.select_spur >= 1 and spur.select_spur <= 20) then
			imgui.Dummy(imgui.ImVec2(0, 150))
			imgui.SetCursorPosX(515)
			imgui.Text(u8"Выберите действие")
			imgui.Spacing()
			imgui.Spacing()
			imgui.SetCursorPosX(490)
			if imgui.Button(u8"Открыть для просмотра", imgui.ImVec2(170, 25)) then
				if not spurBig.v then
					styleAnimationOpen(5)
					spurBig.v = true
					examination = true
					textEndShpora = {}
				else
					animka_big.paramOff = true
				end
			end
			imgui.Spacing()
			imgui.SetCursorPosX(490)
			if imgui.Button(u8"Редактировать", imgui.ImVec2(170, 25)) then
				spur.edit = true
				local f = io.open(dirml.."/MedicalHelper/Шпаргалки/"..spur.list[spur.select_spur]..".txt", "r")
				spur.text.v = u8(f:read("*a"))
				f:close()
				spur.name.v = u8(spur.list[spur.select_spur])
			end
			imgui.Spacing()
			imgui.SetCursorPosX(490)
			if imgui.Button(u8"Удалить", imgui.ImVec2(170, 25)) then
				if doesFileExist(dirml.."/MedicalHelper/Шпаргалки/"..spur.list[spur.select_spur]..".txt") then
					os.remove(dirml.."/MedicalHelper/Шпаргалки/"..spur.list[spur.select_spur]..".txt")
				end
				table.remove(spur.list, spur.select_spur) 
				spur.select_spur = -1
			end
		else
			imgui.Dummy(imgui.ImVec2(0, 150))
			imgui.SetCursorPosX(370)
			imgui.TextColoredRGB("Нажмите на кнопку {FF8400} \"Добавить\"")
			imgui.SameLine()
			imgui.TextColoredRGB("для создания новой шпаргалки\n\t\t\t\t\t\t\t\t\tили выберите уже существующую.")
		end
		imgui.EndGroup()]]
	end
	--> Биндер [4]
	if select_menu[4] then
		imgui.SameLine()
		imgui.BeginChild("bind but", imgui.ImVec2(0, 0), false)
		imgui.SetCursorPos(imgui.ImVec2(positbut2, 2))
		imgui.BeginChild("bind list", imgui.ImVec2(0, 385), false)
		imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(255, 255, 255, 7):GetVec4())
		imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(255, 255, 255, 15):GetVec4())
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(255, 255, 255, 8):GetVec4())
		if #binder.list ~= 0 then
			for i = 1, #binder.list do
				if imgui.Button(u8"##BindBut"..i, imgui.ImVec2(665, 30)) then
					activebutanim2[1] = true
					binder.select_bind = i
					binder.name.v = u8(binder.list[binder.select_bind].name)
					binder.sleep.v = binder.list[binder.select_bind].sleep
					binder.cmd.v = u8(binder.list[binder.select_bind].cmd)
					binder.key = binder.list[binder.select_bind].key
					if doesFileExist(dirml.."/MedicalHelper/Binder/bind-"..binder.list[binder.select_bind].name..".txt") then
						local f = io.open(dirml.."/MedicalHelper/Binder/bind-"..binder.list[binder.select_bind].name..".txt", "r")
						binder.text.v = u8(f:read("*a"))
						f:flush()
						f:close()
					end
					binder.edit = true
				end
			end
			for i = 1, #binder.list do
				imgui.SetCursorPos(imgui.ImVec2(18, -28 + (i*34)))
				imgui.Text(i..".  "..u8(binder.list[i].name))
				imgui.SetCursorPos(imgui.ImVec2(640, -26 + (i*34)))
				imgui.TextColored(imgui.ImColor(255, 255, 255, 100):GetVec4(), fa.ICON_CHEVRON_RIGHT)
			end
		else
			imgui.SetCursorPos(imgui.ImVec2(145, 175))
			imgui.TextColoredRGB('Нажмите на кнопку {FF8400} "Добавить"{FFFFFF} для создания нового бинда.')
		end
		imgui.PopStyleColor(3)
		imgui.EndChild()
		imgui.SetCursorPosX(positbut2)
		if imgui.Button(u8"Добавить##биндер", imgui.ImVec2(689, 25)) then
			if #binder.list < 100 then
				for i = 1, 100 do
					local bool = false
					for ix,v in ipairs(binder.list) do
						if v.name == "Noname bind '"..i.."'" then bool = true end
					end
					if not bool then
						binder.list[#binder.list+1] = {name = "Без названия ("..i..")", key = {}, sleep = 0.5, cmd = ""}
						binder.edit = true
						binder.select_bind = #binder.list
						binder.name.v = ""
						binder.cmd.v = ""
						binder.sleep.v = 0.5
						binder.text.v = ""
						binder.key = {}
						break 
					end
				end
			end
		end
		
		imgui.SetCursorPos(imgui.ImVec2(positbut2 + 699, 2))
		imgui.BeginChild("BindEdit", imgui.ImVec2(691, 415), false)
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(255, 255, 255, 3):GetVec4())
		imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(255, 255, 255, 5):GetVec4())
		imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(255, 255, 255, 8):GetVec4())
		if imgui.Button(fa.ICON_CHEVRON_LEFT, imgui.ImVec2(40, 410)) then
			activebutanim2[2] = true
		end
		imgui.PopStyleColor(3)
		if binder.edit then
			imgui.SameLine()
			imgui.SetCursorPosX(300)
			imgui.Text(u8"Поле для заполнения")
			imgui.SetCursorPos(imgui.ImVec2(50, 30))
			imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImColor(70, 70, 70, 200):GetVec4())
			imgui.InputTextMultiline("##bind", binder.text, imgui.ImVec2(635, 245))
			imgui.PopStyleColor(1)
			imgui.PushItemWidth(300)
			imgui.SetCursorPosX(50)
			imgui.InputText(u8"Название бинда", binder.name, imgui.InputTextFlags.CallbackCharFilter, filter(1, "[%wа-Я%+%№%#%(%)%s]"))
			imgui.SetCursorPosX(50)
			if imgui.Button(u8"Назначить клавишу активации", imgui.ImVec2(300, 25)) then 
				imgui.OpenPopup(u8"MH | Установка клавиши для активации бинда")
				editKey = true
			end
			if imgui.BeginPopupModal(u8"MH | Установка клавиши для активации бинда", null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove) then		
				imgui.Text(u8"Нажмите на клавишу или сочетание клавиш для установки активации."); imgui.Separator()
				imgui.Text(u8"Допускаются клавиши:")
				imgui.Bullet()	imgui.TextDisabled(u8"Клавиши для сочетаний - Alt, Ctrl, Shift")
				imgui.Bullet()	imgui.TextDisabled(u8"Английские буквы")
				imgui.Bullet()	imgui.TextDisabled(u8"Функциональные клавиши F1-F12")
				imgui.Bullet()	imgui.TextDisabled(u8"Цифры верхней панели")
				imgui.Bullet()	imgui.TextDisabled(u8"Боковая панель Numpad")
				ButtonSwitch(u8"Использовать ПКМ в комбинации с клавишами", cb_RBUT)
				imgui.Separator()
				if imgui.TreeNode(u8"Для пользователей 5-кнопочной мыши") then
					ButtonSwitch(u8"X Button 1", cb_x1)
					ButtonSwitch(u8"X Button 2", cb_x2)
					imgui.Separator()
					imgui.TreePop();
				end
				imgui.Text(u8"Текущая клавиша(и): ");
				imgui.SameLine();
				if imgui.IsMouseClicked(0) then
					lua_thread.create(function()
						wait(500)			
						setVirtualKeyDown(3, true)
						wait(0)
						setVirtualKeyDown(3, false)
					end)
				end
				if #(rkeys.getCurrentHotKey()) ~= 0 and not rkeys.isBlockedHotKey(rkeys.getCurrentHotKey()) then	
					if not rkeys.isKeyModified((rkeys.getCurrentHotKey())[#(rkeys.getCurrentHotKey())]) then
						currentKey[1] = table.concat(rkeys.getKeysName(rkeys.getCurrentHotKey()), " + ")
						currentKey[2] = rkeys.getCurrentHotKey()
					end
				end
				imgui.TextColored(imgui.ImColor(255, 205, 0, 200):GetVec4(), currentKey[1])
				if isHotKeyDefined then
					imgui.TextColoredRGB("{FF0000}[Ошибка]{FFFFFF} Данный бинд уже существует!")
				end
				if isHotKeyExists then
					imgui.TextColoredRGB("{FF0000}[Ошибка]{FFFFFF} Клавиша назначена на другом бинде/команде!")
				end
				if imgui.Button(u8"Установить", imgui.ImVec2(150, 0)) then
					if select_menu[4] then
						if cb_RBUT.v then table.insert(currentKey[2], 1, vkeys.VK_RBUTTON) end
						if cb_x1.v then table.insert(currentKey[2], vkeys.VK_XBUTTON1) end
						if cb_x2.v then table.insert(currentKey[2], vkeys.VK_XBUTTON2) end
						if rkeys.isHotKeyExist(currentKey[2]) then 
							isHotKeyExists = true
						else	
							rkeys.unRegisterHotKey(binder.list[binder.select_bind].key)
							unRegisterHotKey(binder.list[binder.select_bind].key)
							binder.key = currentKey[2]
							lockPlayerControl(false)
							cb_RBUT.v = false
							cb_x1.v, cb_x2.v = false, false
							isHotKeyExists = false
							imgui.CloseCurrentPopup();
							editKey = false
						end
					end
				end
				imgui.SameLine();
				if imgui.Button(u8"Закрыть", imgui.ImVec2(150, 0)) then 
					imgui.CloseCurrentPopup(); 
					currentKey = {"",{}}
					cb_RBUT.v = false
					cb_x1.v, cb_x2.v = false, false
					lockPlayerControl(false)
					isHotKeyExists = false
					editKey = false
				end 
				imgui.SameLine()
				if imgui.Button(u8"Очистить", imgui.ImVec2(150, 0)) then
					currentKey = {"",{}}
					cb_x1.v, cb_x2.v = false, false
					cb_RBUT.v = false
					isHotKeyExists = false
				end
				imgui.EndPopup()
			end
			imgui.SetCursorPosX(50)
			if #binder.list[binder.select_bind].key == 0 and #binder.key == 0 then
				imgui.SameLine()
				imgui.TextColoredRGB("Текущая клавиша: {F02626}Отсутствует")
			else
				imgui.SameLine()
				imgui.TextColoredRGB("Текущая клавиша: {1AEB1D}"..table.concat(rkeys.getKeysName(binder.key), " + "))
			end
			imgui.SetCursorPosX(50)
			if imgui.Button(u8"Задать команду для активации", imgui.ImVec2(300, 25)) then 
				chgName.inp.v = binder.cmd.v
				unregcmd = chgName.inp.v
				imgui.OpenPopup(u8"MH | Редактирование команды бинда")
				editKey = true
			end
			if imgui.BeginPopupModal(u8"MH | Редактирование команды бинда", null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove) then
			imgui.SetCursorPosX(70)
			imgui.Text(u8"Введите новую команду на этот бинд, которую Вы пожелаете."); imgui.Separator()
			imgui.Text(u8"Примечания:")
			imgui.Bullet()	imgui.TextColoredRGB("{00ff8c}Разрешается заменять серверные команды.")
			imgui.Bullet()	imgui.TextColoredRGB("{00ff8c}Если Вы замените серверную команду - Ваша команда станет приоритетной.")
			imgui.Bullet()	imgui.TextColoredRGB("{00ff8c}Нельзя использовать цифры и символы. Только английские буквы.")
			if select_menu[4] then
				imgui.Bullet()	imgui.TextColoredRGB("{00ff8c}Бинд на сокращение команд {e3071d}/findihouse{00ff8c} и {e3071d}/findibiz {00ff8c}карается баном!")
			end
			imgui.Text(u8"/");
			imgui.SameLine();
			imgui.PushItemWidth(520)
			imgui.InputText(u8"##inpcastname", chgName.inp, 512, filter(1, "[%a]+"))
			if isHotKeyDefined then
				imgui.TextColoredRGB("{FF0000}[Ошибка]{FFFFFF} Данная команда уже существует!")
			end
			if russkieBukviNahyi then
				imgui.TextColoredRGB("{FF0000}[Ошибка]{FFFFFF} Нельзя использовать русские буквы!")
			end
			if dlinaStroki then
				imgui.TextColoredRGB("{FF0000}[Ошибка]{FFFFFF} Максимальная длина команды - 15 букв!")
			end		
			if select_menu[4] then
				if imgui.Button(u8"Применить", imgui.ImVec2(174, 0)) then
					local exits = false
					if chgName.inp.v:find("%A") then
						russkieBukviNahyi = true
						isHotKeyDefined = false
						dlinaStroki = false
						exits = true
					elseif chgName.inp.v:len() > 15 then
						dlinaStroki = true
						russkieBukviNahyi = false
						isHotKeyDefined = false
						exits = true
					end
					for i,v in ipairs(cmdBind) do
						if v.cmd == chgName.inp.v then
							exits = true
							isHotKeyDefined = true
							russkieBukviNahyi = false
							dlinaStroki = false
						end
					end
					for i,v in ipairs(binder.list) do
						if binder.list[i].cmd == chgName.inp.v and chgName.inp.v ~= binder.cmd.v and chgName.inp.v ~= "" then
							exits = true
							isHotKeyDefined = true
							russkieBukviNahyi = false
							dlinaStroki = false
						end
					end
					if not exits then
						if binder.cmd.v == chgName.inp.v then
							unregcmd = ""
							isHotKeyDefined = false
							russkieBukviNahyi = false
							dlinaStroki = false
							imgui.CloseCurrentPopup();
						else
							isHotKeyDefined = false
							russkieBukviNahyi = false
							dlinaStroki = false
							binder.cmd.v = chgName.inp.v
							imgui.CloseCurrentPopup();
							editKey = false
						end
					end
				end
			end				
			imgui.SameLine();
			if imgui.Button(u8"Закрыть", imgui.ImVec2(174, 0)) then 
				imgui.CloseCurrentPopup(); 
				currentKey = {"",{}}
				cb_RBUT.v = false
				cb_x1.v, cb_x2.v = false, false
				lockPlayerControl(false)
				isHotKeyDefined = false
				russkieBukviNahyi = false
				dlinaStroki = false
				editKey = false
				unregcmd = ""
			end 
			imgui.SameLine()
			if select_menu[4] then
				if imgui.Button(u8"Очистить строку", imgui.ImVec2(174, 0)) then
					chgName.inp.v = ""
					isHotKeyDefined = false
					russkieBukviNahyi = false
					dlinaStroki = false
				end
			end
			imgui.EndPopup()
		end
			imgui.SetCursorPosX(50)
			if binder.cmd.v == "" then
				imgui.SameLine()
				imgui.TextColoredRGB("Текущая команда: {F02626}Отсутствует")
			else
				imgui.SameLine()
				imgui.TextColoredRGB("Текущая команда: {1AEB1D}/"..binder.cmd.v)
			end
			imgui.PushItemWidth(250)
			imgui.SetCursorPosX(50)
			imgui.DragFloat("##sleep", binder.sleep, 0.1, 0.5, 10.0, u8"Задержка = %.1f сек.")
			imgui.SameLine()
			if imgui.Button("-", imgui.ImVec2(20, 20)) and binder.sleep.v ~= 0.5 then binder.sleep.v = binder.sleep.v - 0.1 end
			imgui.SameLine()
			if imgui.Button("+", imgui.ImVec2(20, 20)) and binder.sleep.v ~= 10 then binder.sleep.v = binder.sleep.v + 0.1 end
			imgui.PopItemWidth()
			imgui.SameLine()
			imgui.Text(u8"Интервал времени между проигрыванием строк")
			imgui.SetCursorPosX(50)
			if imgui.Button(u8"Удалить", imgui.ImVec2(152, 25)) then
				activebutanim2[2] = true
				sampUnregisterChatCommand(binder.cmd.v)
				binder.text.v = ""
				binder.sleep.v = 0.5
				binder.name.v = ""
				binder.cmd.v = ""
				binder.edit = false 
				rkeys.unRegisterHotKey(binder.key)
				unRegisterHotKey(binder.key)
				binder.key = {}
				if doesFileExist(dirml.."/MedicalHelper/Binder/bind-"..binder.list[binder.select_bind].name..".txt") then
					os.remove(dirml.."/MedicalHelper/Binder/bind-"..binder.list[binder.select_bind].name..".txt")
				end
				table.remove(binder.list, binder.select_bind) 
				local f = io.open(dirml.."/MedicalHelper/bindSetting.med", "w")
				f:write(encodeJson(binder.list))
				f:flush()
				f:close()
				binder.select_bind = -1 
			end
			imgui.SameLine()
			if imgui.Button(u8"Сохранить", imgui.ImVec2(152, 25)) then
				local bool = false
				if binder.name.v ~= "" then
					for i,v in ipairs(binder.list) do
						if v.name == u8:decode(binder.name.v) and i ~= binder.select_bind then bool = true end
					end		
					if not bool then
						binder.list[binder.select_bind].name = u8:decode(binder.name.v)
					else
						imgui.OpenPopup(u8"Ошибка")
					end
				end
				if not bool then
					rkeys.registerHotKey(binder.key, true, onHotKeyBIND)
					binder.list[binder.select_bind].key = binder.key
					binder.list[binder.select_bind].cmd = binder.cmd.v
					local sec = string.format("%.1f", binder.sleep.v)
					binder.list[binder.select_bind].sleep = sec
					local text = u8:decode(binder.text.v)
					local cmd = u8:decode(binder.cmd.v)
					local saveJS = encodeJson(binder.list) 
					sampRegCMD()
					sampUnregisterChatCommand(unregcmd)
					local f = io.open(dirml.."/MedicalHelper/bindSetting.med", "w")
					local ftx = io.open(dirml.."/MedicalHelper/Binder/bind-"..binder.list[binder.select_bind].name..".txt", "w")
					f:write(saveJS)
					ftx:write(text)
					f:flush()
					ftx:flush()
					f:close()
					ftx:close()
				end
			end
			imgui.SameLine()
			if imgui.Button(u8"Тег-функции", imgui.ImVec2(152, 25)) then paramWin.v = not paramWin.v end
			imgui.SameLine()
			if imgui.Button(u8"Расширенные функции", imgui.ImVec2(165, 25)) then 
				profbWin.v = not profbWin.v
			end	
		end
		imgui.EndChild()
		imgui.EndChild()
		if activebutanim2[1] then 
			if positbut2 > -699 then
				positbut2 = positbut2 - 23
			else
				activebutanim2[1] = false
				positbut2 = - 699
			end
		end
		
		if activebutanim2[2] then 
			if positbut2 < 0 then
				positbut2 = positbut2 + 27
			else
				activebutanim2[2] = false
				positbut2 = 0
			end
		end
	end
	--> Помощь [6]
	if select_menu[6] then
		imgui.SameLine()
		imgui.BeginChild("help but", imgui.ImVec2(0, 0), false)
		--positbut activebutanim
			local text_question = {u8"Для чего этот скрипт? Кто его разработал?", u8"Я нашёл баг и хочу предложить улучшение. Куда мне обращаться?", u8"А скрипт точно без стиллеров?", u8"Как мне изменить отыгровку или команду отыгровки?", u8"Как работает редактор отыгровок?",
			u8"Как мне сделать свою отыгровку?", u8"Что такое биндер и как в нём всё работает?", u8"А можно ли сократить отыгровки?", u8"У меня не работает какая-то функция. Что делать?", u8"А есть ли биндер для мобильной версии игры?",
			u8"Что за вкладка со статистикой? Для чего она?", u8"Как мне пользоваться вкладкой с музыкой?", u8"У моего друга не работает этот скрипт. Что делать?", u8"Где я могу узнать ценовую политику своей больницы?",
			u8"Как мне подключиться к дискорду? Где взять ссылку на канал?", u8"Как сильно скрипт влияет на мой ФПС в игре?", u8"Как мне повыситься в моей организации?", u8"Когда проверят мой отчёт на форуме для повышения?", u8"Мой отчёт на повышение проверили. Что делать дальше?",
			u8"Мне говорят про МГ и РП. Что это такое?", u8"Как правильно делать Role Play отыгровки?"}
			local icon_question = {fa.ICON_CUBE, fa.ICON_USER_SECRET, fa.ICON_BUG, fa.ICON_PENCIL, fa.ICON_ASTERISK,
			fa.ICON_PENCIL_SQUARE_O, fa.ICON_KEYBOARD_O, fa.ICON_SCISSORS, fa.ICON_FACEBOOK, fa.ICON_GAMEPAD,
			fa.ICON_LINE_CHART, fa.ICON_MUSIC, fa.ICON_WRENCH, fa.ICON_USD,
			fa.ICON_SIMPLYBUILT, fa.ICON_CUBES, fa.ICON_ARROW_UP, fa.ICON_FOLDER_OPEN, fa.ICON_CHECK_SQUARE,
			fa.ICON_EXCLAMATION_CIRCLE, fa.ICON_CHECK}
			imgui.SetCursorPos(imgui.ImVec2(positbut, 2))
			imgui.BeginChild("help2 but", imgui.ImVec2(691, 415), false)
			imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(255, 255, 255, 9):GetVec4())
			imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(255, 255, 255, 8):GetVec4())
			imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(255, 255, 255, 16):GetVec4())
			for i = 1, 21 do
				if imgui.Button(u8"##Quest"..i, imgui.ImVec2(665, 45)) then
					activebutanim[1] = true
					activebutanim[3] = i
				end
			end
			for i = 1, 21 do
				imgui.SetCursorPos(imgui.ImVec2(635, -33 + (i*49)))
				imgui.TextColored(imgui.ImColor(255, 255, 255, 120):GetVec4(), fa.ICON_CHEVRON_RIGHT)
				imgui.SetCursorPos(imgui.ImVec2(50, -35 + (i*49)))
				imgui.Text(text_question[i])
				imgui.SetCursorPos(imgui.ImVec2(18, -35 + (i*49)))
				imgui.Text(icon_question[i])
			end
			imgui.PopStyleColor(3)
			imgui.EndChild()
			
			imgui.SetCursorPos(imgui.ImVec2(positbut + 699, 2))
			imgui.BeginChild("help22 but", imgui.ImVec2(691, 415), false)
			imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(255, 255, 255, 3):GetVec4())
			imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(255, 255, 255, 5):GetVec4())
			imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(255, 255, 255, 8):GetVec4())
			if activebutanim[3] ~= 5 then
				if imgui.Button(fa.ICON_CHEVRON_LEFT, imgui.ImVec2(40, 413)) then
					activebutanim[2] = true
				end
			else
				if imgui.Button(fa.ICON_CHEVRON_LEFT, imgui.ImVec2(40, 1480)) then
					activebutanim[2] = true
				end
			end
			imgui.SameLine()
			imgui.SetCursorPosX(50)
			if activebutanim[3] == 1 then
				imgui.TextWrapped(u8'    Medical Helper это скрипт, который призван упростить работу сотрудников больниц на проекте Arizona Role Play. Скрипт обеспечивает более эффективное взаимодействие между игроками. Наряду с этой основной задачей, скрипт также содержит множество дополнительных функций, которые позволяют более удобно и быстро выполнять повседневные задачи в игре.\n\nСкрипт изначально разработан Hatiko (до 3.0.0 версии). В настоящее время скрипт находится под активной разработкой Kane, который продолжает улучшать и дополнять его функциональность.')
			elseif activebutanim[3] == 2 then
				imgui.TextWrapped(u8'    Для решения проблем с использованием скрипта Вам следует обратиться к разработчику Kane напрямую, для этого можно воспользоваться социальной сетью ВКонтакте. В случае возникновения ошибки, рекомендуется предоставить файл moonloader.log, который находится в папке moonloader, где был установлен данный скрипт. Отправляя обращение, необходимо максимально подробно описать проблему, указать последовательность Ваших действий, которые привели к ошибке. Такие сведения помогут быстрее и эффективнее решить возникшую проблему.')
			elseif activebutanim[3] == 3 then
				imgui.TextWrapped(u8'    Если у Вас возникли сомнения относительно того, откуда Вы загрузили данный скрипт, необходимо обратиться к разработчику Kane, чтобы убедиться в его подлинности. Контактные данные разработчика можно найти в разделе "О скрипте". Важно отметить, что страница разработчика в социальной сети ВКонтакте должна быть подтверждена галочкой. Если страница не подтверждена, то, вероятно, ссылка ведёт не на страницу разработчика, а скрипт, который Вы установили, может быть заражен и представлять опасность для Вашей системы. В этом случае необходимо немедленно переустановить операционную систему и поменять пароли на основных сайтах, таких как ВКонтакте, Госуслуги, Аризона, Дискорд, Киви, Яндекс, Google и другие. Также следует заблокировать действующие банковские карты и включить двухфакторную аутентификацию входа с помощью Google Authenticator.\n\nСкрипт, которым Вы пользуетесь, принадлежит разработчику Kane. Информация о разработчике полностью открыта и доступна для просмотра любому пользователю. Исходный код скрипта также открыт для просмотра. Если вы все же боитесь обновлений скрипта, то можете просто не обновлять его, так как автоматического обновления у скрипта нет, все обновления происходят только с Вашего разрешения.')
			elseif activebutanim[3] == 4 then
				imgui.TextWrapped(u8'   Для изменения отыгровки или команды отыгровки, необходимо зайти во вкладку "Команды", где будет доступен полный список доступных команд. Найдите интересующую Вас команду и нажмите на неё. Внизу появятся кнопки, позволяющие изменить текст отыгровки команды и саму команду, а также её клавишу активации. Если случайно испортили отыгровку или команду в редакторе, можно легко вернуть обратно стандартную отыгрывку или команду. Если желаете создать свою собственную отыгровку, которой нет в списке, можно воспользоваться вкладкой "Биндер".')
			elseif activebutanim[3] == 5 then
				imgui.TextWrapped(u8'Редактор отыгровок работает следующим образом:\n\nПосле того, как Вы выбрали нужную Вам отыгровку для редактирования, перед Вами будет окно с названием "Редактирование отыгровки". Первым делом необходимо знать, нужны ли Вам аргументы и переменные в Вашей отыгровке. Что же делают аргументы и переменные? Аргумент задаёт команде  условия, например\n/medcard [id] [Статус] [Срок] [Цена] содержит в себе четыре аргумента. А команда /heal [id] [Цена] всего два аргумента. Аргументы бывают числовыми и текстовыми. Числовой аргумент принимает только числа, а текстовый любой текст на любом языке с любым количеством цифр и знаков. Если у Вас указан числовой аргумент, а во время использования команды вписан текстовый, то выйдет ошибка о том, что Вам необходимо исправиться. Это нужно для того, чтобы минимизировать человеческий фактор при вводе значений в команду. После объявления аргумента, ему присваивается тег, например {arg1}. Этот тег будет содержать в себе тот аргумент, который Вы ввели. Эта информация будет храниться пока отыгровка не закончится. Теги можно использовать для отправки сообщения в чат или вывода информации в чат.\nНапример, если Вы введёте в редакторе: /heal {arg1} {priceheal}, то в чат отправится значение Вашего аргумента и стоимость лечения. Например, если Вы, когда вводили команду, ввели в аргумент число "24", а стоимость лечения в настройках у Вас "5000", то в чат отправится следующее: /heal 24 5000\n{priceheal} это индивидуальный тег стоимости лечения.\n\n')
				imgui.SetCursorPos(imgui.ImVec2(50, 350))
				imgui.TextWrapped(u8'С этим разобрались. Но что же делают переменные? Всё просто: Вы создаёте переменную или несколько переменных, в зависимости от сложности отыгровки, после чего можете сразу вписать в переменную её значение. Значение может быть любым: числа, буквы, знаки. Впоследствии, это значение можно будет изменить во время отыгровки. Это удобно, если у Вас есть диалоги.\n\nВ самом верху имеются два переключателя "Использовать аргументы" и "Использовать переменные". Если Вы не используете переменные или аргументы, то рекомендуется отключить их использование вовсе. Это снизит нагрузку на скрипт во время проигрывания отыгровки и ускорит её работу.\n\nНиже Вы увидите настройку задержки проигрывания отыгровки. Её значение отображается в секундах. Передвигайте слайдер, чтобы установить необходимое значение. Это даст необходимую задержку между функцией отправки сообщения в чат, чтобы не повелось сообщение "Не флуди". Оптимальная задержка - 2 секунды.\n\nПосле того, как Вы определились с аргументами и переменными, а также значением задержки проигрывания отыгровки, можете переходить к созданию основных задач отыгровки - выполнение функций. Всего имеются 5 функций:\n\n')
				imgui.SetCursorPos(imgui.ImVec2(50, 630))
				imgui.TextWrapped(u8'\n\n1. Отправить в чат\n2. Ожидание нажатия Enter\n3. Диалог выбора действий\n4. Информация в чат\n5. Изменить переменную\n\nРазберём что делает каждая из них:\n\n1. Функция "Отправить в чат" позволяет отправить сообщение в чат, которое увидят другие игроки. В эту функцию Вы должны вписать текст Вашей отыгровки, например "Здравствуйте, Вы на вакцинацию?" или "/me презрительно посмотрел на уличного бродягу". Сюда Вы можете списать заранее установленные значения переменных или значение аргумента, например "Стоимость медицинской карты для Вас составит {var1}" Переменная {var1}$ во время проигрывания отыгровки превратится в заранее введённое значение. Если заранее введённое значение "25000", то отправится текст "Стоимость медицинской карты для Вас составит 25000$". Аналогично с аргументами.\n\n2. Функция "Ожидание нажатия Enter" приостанавливает отыгровку. Она продолжится только после того, как Вы нажмёте Enter на Вашей клавиатуре.\n\n')
				imgui.SetCursorPos(imgui.ImVec2(50, 970))
				imgui.TextWrapped(u8'3. Функция "Диалог выбора действий" позволяет создать несколько вариантов дальнейшей отыгровки, чтобы Вы смогли выбрать подходящую под определённую ситуацию. Первым делом необходимо настроить количество диалогов и их названия. Для этого нажмите "Редактировать количество диалогов", после чего, в открывшемся окне сделайте необходимую настройку количества диалогов и их названий.\n\nДалее ориентируйтесь на количество диалогов. Если их два, то и диалоговых тегов будет два: {dialog1} и {dialog2} соответсвенно. Чтобы применить действие первого диалога, необходимо выбрать функцию "Отправить в чат" и ввести тег первого диалога {dialog1}. Если этого не сделать сразу после того, как Вы выбрали функцию "Диалог выбора действий", то эта функция сбросится, думая, что её работа завершена. После того, как Вы вписали тег диалога в функцию "Отправить в чат", Вы можете выбрать дальнейшие функции, кроме "Отправить в чат" уже без необходимости вводить тег диалога, но если дальнейшие функции у Вас "Отправить в чат", то в них необходимо также ввести тег диалога, чтобы функция "Диалог выбора действий" не завершила работу. Когда первый диалог готов, то можете приступать ко второму просто добавив новую функцию "Отправить в чат" и введя тег второго диалога. Далее по аналогичной схеме. Когда Вы закончите действия с диалогами, то Вам необходимо завершить работу диалогов, для этого добавьте функцию "Отправить в чат" и оставьте поле пустым, тогда функция "Диалог выбора действий" завершится. Далее будут идти отыгровки, которые не привязаны к диалогу, то есть эти отыгровки пойдут сразу после того, как завершится диалог.\n\n')
				imgui.SetCursorPos(imgui.ImVec2(50, 1300))
				imgui.TextWrapped(u8'4. Функция "Информация в чат" отправить в чат от имени скрипта текст, который Вы напишете. Этот текст будет виден только Вам.\n\n5. Функция "Изменить переменную" позволяет в процессе отыгровки изменить переменную на другое значение, которое Вы укажите. Полезно использовать в блоке функции диалогов.\n\nСнизу есть флажок "Не отправлять последнее сообщение в чат". Это позволит не отправить в чат последнее сообщение, а место этого просто открыть командную строку. Полезно, если необходимо вписать аргументы, которые невозможно установить в процессе выполнения отыгровки.')
			elseif activebutanim[3] == 6 then
				imgui.TextWrapped(u8'    Для создания собственной отыгровки Вам необходимо открыть вкладку "Биндер", которая расположена слева в основном меню скрипта, там, где Вы сейчас находитесь.')
			elseif activebutanim[3] == 7 then
				imgui.TextWrapped(u8'    Биндер - это инструмент, который позволяет создать свою отыгровку, которая будет автоматически проигрываться по команде или клавише активации, которую Вы сами же установите.\n\nПеред Вами текстовый редактор. Каждая новая строка в редакторе означает следующее действие. Ниже имеется кнопка "Теги". Кликнув по ней, перед Вами откроется список существующих тегов, каждый из которых выполняет вывод заготовленной информации. Подробнее о том, что делает каждый из тегов, Вы можете узнать прямо там.\n\nСоздав свою отыгровку Вас необходимо определить задержку проигрывания отыгровки, чтобы не появилась ошибка "Не флуди!". Рекомендуемое значение - 2 секунды.\n\nПосле этого определяется команда или клавиша активации, либо же и то, и другое.\n\nПосле выполнения всего вышеперечисленного, нажмите на кнопку "Сохранить" и можете начать использовать Вашу отыгровку.')
			elseif activebutanim[3] == 8 then
				imgui.TextWrapped(u8'    Если Вы собираетесь сокращать отыгровки, то помните, что чересчур короткая отыгровка может вызвать вопросы у администрации о качестве отыгрывания Вами РП. На каждом сервере своя политика на этот счёт, поэтому советуем обратиться к Вашему лидеру для уточнения данного вопроса.')
			elseif activebutanim[3] == 9 then
				imgui.TextWrapped(u8'    Если какая-то из функций не работает, то в первую очередь поинтересуйтесь у коллег Вашей организации, работает ли она у них. Если работает, то спросите у них, какие условия должны быть выполнены, чтобы функция работала. В противном случае, попробуйте установить последнюю версию скрипта, возможно, что в последней версии эта проблема была решена. Если всё равно ничего не помогает, то можете спросить у разработчика в чём может быть проблема. Контакты разработчика можно найти во вкладке "О скрипте".')
			elseif activebutanim[3] == 10 then
				imgui.TextWrapped(u8'    Да, есть встроенный в мод сервера биндер. Он работает как на мобильной версии, так и на версии для ПК. Для этого ничего не нужно скачивать. Просто введите команду /binder')
			elseif activebutanim[3] == 11 then
				imgui.TextWrapped(u8'    В этой вкладке в режиме реального времени сохраняется статистика Вашей игры: заработок и время нахождения в игре. Благодаря этой информации Вы можете мотивировать себя, соревноваться с товарищами или ставить себе цель и чётко следить за ходом её выполнения.')
			elseif activebutanim[3] == 12 then
				imgui.TextWrapped(u8'    Здесь всё просто. В разделе "Поиск в интернете" Вы вводите название песни или её исполнителя, либо и то, и другое и получаете список песен, найденных в интернете. Если песня, которую Вы нашли, понравилась Вам, то Вы с лёгкостью может добавить её в пункт "Избранные" нажав на плюсик рядом с необходимым треком. В разделе "Избранные" треки сразу отображаются без надобности искать их снова.\n\nЕсли Вы хотите расслабиться и послушать радио Рекорд, то для этого имеется отдельный раздел "Радио рекорд", где доступны три радиостанции, которые украсят Ваш вечер.')
			elseif activebutanim[3] == 13 then
				imgui.TextWrapped(u8'    Если у Вашего товарища не работает скрипт, то посоветуйте ему установить Moonloader через вкладку "Моды" в лаунчере. Обычно, проблемы возникают из-за отсутствия некоторых важных библиотек. Если ему не помогло - пусть напишет разработчику. Его контакты во вкладке "О скрипте".')
			elseif activebutanim[3] == 14 then
				imgui.TextWrapped(u8'    Обычно, ценовая политика написана на форуме, в разделе Вашей больницы или общем разделе МЗ. В зависимости от сервера, ценовая политика может устанавливаться лидером организации. В таком случае, Вы можете обратиться к Вашему лидеру или заместителю, чтобы получить информацию о ценовой политике и не нарушить устав Министерства Здравоохранения.')
			elseif activebutanim[3] == 15 then
				imgui.TextWrapped(u8'    Ссылка на дискорд всегда имеется на форуме, в разделе Вашей больницы или в общем разделе МЗ. Если Вам по каким-то причинам не удаётся найти ссылку на канал, то обратитесь к любому сотруднику организации от 2 ранга. Он подскажет где взять ссылку на канал Вашего сервера и как получить роль Вашей организации.')
			elseif activebutanim[3] == 16 then
				imgui.TextWrapped(u8'    К сожалению, скрипт имеет небольшую нагрузку на Ваш ПК, но незначительную. В процессе пользования скрипта, Вы теряете не более 3 ФПС. Разработчик старается максимально оптимизировать скрипт, чтобы пользователь не чувствовал дискомфорта, но с добавлением новых функций это становится всё сложнее. В любом случае, разницы с производительностью Вы даже не заметите.')
			elseif activebutanim[3] == 17 then
				imgui.TextWrapped(u8'    Если Вы собираетесь повыситься до 4 ранга включительно, но необходимо уточнить способ повышения на форуме Вашего сервера в разделе Министерства Здравоохранения. На разных серверах разная система повышения. Но чаще всего необходимо составить отчёт, как и при повышении от 5 до 8 ранга включительно. Отчёт составляется по шаблону, который Вы также найдёте на форуме в разделе "Единая система повышения". Если Вы составите отчёт не по необходимой форме, то его могут не принять и Вам придётся составлять его заново. Поэтому ознакомьтесь с нужной информацией до начала принятия мер по повышению Вашей должности.')
			elseif activebutanim[3] == 18 then
				imgui.TextWrapped(u8'    Если Вы повышаетесь в пределах 1-4 ранг, то Ваш отчёт проверяет лидер или заместитель Вашей организации, после чего, решает, одобрить его или отклонить. Если отчёт одобрен, то в месте, где Вы оставили свой отчёт, будет пометка от лидера, что отчёт проверен и рядом написан вердикт.\n\nЕсли одобрено, то подойдите к лидеру или заместителю и скажите о том, что Ваш отчёт был одобрен и Вам необходимо повышение. Если отклонено, то необходимо узнать причину отказа и исправиться, опубликовав новый отчёт с учётом исправления предыдущих ошибок.\n\nЕсли же Вы повышаетесь с 5-8 ранг, то после одобрения отчёта лидером или заместителем организации, он публикует его в систему "Анти-блат", где проверкой отчёта займётся уже следящая администрация МЗ. Только после их одобрения Вы имеете право требовать повышения в должности.')
			elseif activebutanim[3] == 19 then
				imgui.TextWrapped(u8'    Если Вы 1-4 ранг, то обратитесь к лидеру или заместителю Вашей организации в игре. Скажите им, что Ваш отчёт проверен и одобрен и Вам необходимо повышение.\n\nЕсли в 5-8 ранг, то сначала убедитесь, что Ваш отчёт проверила следящая администрация МЗ. Только убедившись в этом, Вы имеете право требовать повышения в должности у Вашего лидера или заместителя организации.')
			elseif activebutanim[3] == 20 then
				imgui.TextWrapped(u8'    Метагейминг (МГ) - это когда игрок использует информацию, которую он знает вне игры, чтобы получить преимущество внутри игры.\n\nДопустим, ты играешь в САМП и знаешь, что твой друг находится в команде противника. Если ты используешь эту информацию и нападаешь на своего друга, чтобы выиграть игру, это будет считаться МГ.\n\nМетагейминг несправедлив и неэтичен, потому что он нарушает правила игры. В САМП, как и в других играх, МГ может привести к наказанию, так что лучше не использовать его, чтобы получать преимущество в игре.\n\nРолевая игра (РП) - это игровой режим, в котором игроки воплощают различные роли и взаимодействуют внутри игры, как если бы они находились в настоящем мире.\n\nВ режиме RP игроки могут выбирать разные профессии (например, полицейский, врач, бизнесмен) и выполнять соответствующие задачи внутри игры. Они также могут взаимодействовать друг с другом, общаться и создавать различные сценарии, которые могут быть связаны с работой, личной жизнью или преступными делами.\n\nРолевая игра в САМП позволяет игрокам создавать свои собственные истории и переживать различные ситуации внутри игры. Она также требует от игроков соблюдения правил и уважения других игроков, чтобы обеспечить приятный и безопасный опыт игры для всех участников.')
			elseif activebutanim[3] == 21 then
				imgui.TextWrapped(u8'    Чтобы делать качественную Role Play отыгровку в САМП, нужно следовать нескольким правилам:\n\n1. Соблюдать роли и характеры персонажей. Каждый персонаж должен иметь свои собственные цели, мотивы и характеристики. Ваш персонаж должен действовать соответственно своей роли и характеру.\n2.Слушать и отвечать на действия других игроков. Role Play - это взаимодействие между игроками, поэтому необходимо уметь слушать и отвечать на действия других игроков. Если вы играете, например, полицейского, вы должны реагировать на действия других игроков, которые нарушают закон.\n3. Играть честно и не использовать МГ. Метагейминг (MG) может нарушить атмосферу игры и затруднить Role Play. Играйте честно и используйте только ту информацию, которую ваш персонаж знает внутри игры.\n\nПримеры качественных Role Play отыгровок могут включать:\n\n1. Отыгрыш врача, который лечит пациентов в больнице. Вам нужно будет играть по роли и отвечать на запросы пациентов. Вы можете создавать сценарии, например, операции или скорую помощь.\n2. Отыгрыш криминальной группировки. Вам нужно будет играть членом группировки, выполнять задания и создавать различные ситуации, которые будут связаны с преступным миром.\n3. Отыгрыш полицейского, который охраняет улицы города. Ваша задача - бороться с преступниками и нарушителями закона, следовать инструкциям своего начальства и отвечать на звонки о преступлениях.\n\nВажно помнить, что Role Play - это сотрудничество и взаимодействие между игроками. Играйте честно и уважайте других игроков, чтобы создать приятную атмосферу игры.')
			end
			imgui.PopStyleColor(3)
			imgui.EndChild()
			
			if activebutanim[1] then 
				if positbut > -699 then
					positbut = positbut - 23
				else
					activebutanim[1] = false
					positbut = - 699
				end
			end
			
			if activebutanim[2] then 
				if positbut < 0 then
					positbut = positbut + 27
				else
					activebutanim[2] = false
					positbut = 0
				end
			end
		imgui.EndChild()
	end
	--> Музыка [10]
	if select_menu[10] and not bassNOT then
		local record = {'http://radio-srv1.11one.ru/record192k.mp3', 'http://radiorecord.hostingradio.ru/mix96.aacp', 'http://radiorecord.hostingradio.ru/party96.aacp', 'http://radiorecord.hostingradio.ru/phonk96.aacp', 'http://radiorecord.hostingradio.ru/gop96.aacp', 'http://radiorecord.hostingradio.ru/rv96.aacp', 'http://radiorecord.hostingradio.ru/dub96.aacp', 'http://radiorecord.hostingradio.ru/bighits96.aacp', 'http://radiorecord.hostingradio.ru/organic96.aacp', 'http://radiorecord.hostingradio.ru/russianhits96.aacp', 'http://radiorecord.hostingradio.ru/gold96.aacp'}
		--local megamix = {'http://muzmurka.com/audio/125052967403828/play.mp3', 'http://muzmurka.com/audio/125100659413465/play.mp3', 'http://muzmurka.com/audio/125073246175628/play.mp3', 'http://muzmurka.com/audio/125106436727174/play.mp3', 'http://muzmurka.com/audio/124798872736165/play.mp3'}
		local action = require('moonloader').audiostream_state
		imgui.SameLine()
		if imgui.InvisibleButton(u8"##Поиск в интернете", imgui.ImVec2(227, 30)) then select_menu_music = 1 end
		imgui.SetCursorPos(imgui.ImVec2(156, 40))
		local p = imgui.GetCursorScreenPos()
		if imgui.IsItemActive() and select_menu_music ~= 1 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 228, p.y + 30), imgui.GetColorU32(imgui.ImVec4(0.10, 0.10, 0.10 ,1.00)), 10, 9)
		elseif imgui.IsItemHovered() and select_menu_music ~= 1 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 228, p.y + 30), imgui.GetColorU32(imgui.ImVec4(0.30, 0.30, 0.30 ,1.00)), 10, 9)
		elseif select_menu_music ~= 1 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 228, p.y + 30), imgui.GetColorU32(imgui.ImVec4(0.15, 0.15, 0.15 ,1.00)), 10, 9)
		elseif select_menu_music == 1 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 228, p.y + 30), imgui.GetColorU32(colButActiveMenu), 10, 9)
		end
		imgui.SameLine()
		if imgui.InvisibleButton(u8"##Избранные", imgui.ImVec2(227, 30)) then select_menu_music = 2 end
		imgui.SetCursorPos(imgui.ImVec2(384, 40))
		local p = imgui.GetCursorScreenPos()
		if imgui.IsItemActive() and select_menu_music ~= 2 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 228, p.y + 30), imgui.GetColorU32(imgui.ImVec4(0.10, 0.10, 0.10 ,1.00)))
		elseif imgui.IsItemHovered() and select_menu_music ~= 2 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 228, p.y + 30), imgui.GetColorU32(imgui.ImVec4(0.30, 0.30, 0.30 ,1.00)))
		elseif select_menu_music ~= 2 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 228, p.y + 30), imgui.GetColorU32(imgui.ImVec4(0.15, 0.15, 0.15 ,1.00)))
		elseif select_menu_music == 2 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 228, p.y + 30), imgui.GetColorU32(colButActiveMenu))
		end
		imgui.SameLine()
		if imgui.InvisibleButton(u8"##Радио Record", imgui.ImVec2(227, 30)) then select_menu_music = 3 end
		imgui.SetCursorPos(imgui.ImVec2(612, 40))
		local p = imgui.GetCursorScreenPos()
		if imgui.IsItemActive() and select_menu_music ~= 3 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 228, p.y + 30), imgui.GetColorU32(imgui.ImVec4(0.10, 0.10, 0.10 ,1.00)), 10, 6)
		elseif imgui.IsItemHovered() and select_menu_music ~= 3 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 228, p.y + 30), imgui.GetColorU32(imgui.ImVec4(0.30, 0.30, 0.30 ,1.00)), 10, 6)
		elseif select_menu_music ~= 3 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 228, p.y + 30), imgui.GetColorU32(imgui.ImVec4(0.15, 0.15, 0.15 ,1.00)), 10, 6)
		elseif select_menu_music == 3 then
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 228, p.y + 30), imgui.GetColorU32(colButActiveMenu), 10, 6)
		end
		imgui.SetCursorPos(imgui.ImVec2(209, 47))
		imgui.Text(u8"Поиск в интернете")
		imgui.SetCursorPos(imgui.ImVec2(463, 47))
		imgui.Text(u8"Избранные")
		imgui.SetCursorPos(imgui.ImVec2(682, 47))
		imgui.Text(u8"Радио Record")
		imgui.SetCursorPos(imgui.ImVec2(153, 78))
		imgui.BeginChild("separator", imgui.ImVec2(0, 2), false)
		imgui.Separator()
		imgui.EndChild()
		imgui.SetCursorPos(imgui.ImVec2(150, 79))
		if select_menu_music == 1 and not effilNOT then
			
			imgui.SetCursorPos(imgui.ImVec2(150, 80))
			imgui.BeginChild("musical", imgui.ImVec2(0, 320), false)
			imgui.SetCursorPos(imgui.ImVec2(7, 8))
			if #tracks.link > 10 then
				imgui.PushItemWidth(609)
			else
				imgui.PushItemWidth(618)
			end
			if imgui.InputText(u8"##Поиск песен", buf_find_music, imgui.InputTextFlags.CallbackCharFilter, filter(1, "[%w+%s+]+")) then end
			if not imgui.IsItemActive() and buf_find_music.v == "" then
				imgui.SameLine()
				imgui.SetCursorPos(imgui.ImVec2(15, 7))
				imgui.TextColored(imgui.ImColor(200, 200, 200, 200):GetVec4(), u8"Название песни или его исполнитель");
			end
			imgui.SameLine()
			if #tracks.link > 10 then
				imgui.SetCursorPos(imgui.ImVec2(620, 8))
			else
				imgui.SetCursorPos(imgui.ImVec2(629, 8))
			end
			if imgui.Button(u8"Поиск", imgui.ImVec2(60, 21)) then
				if buf_find_music.v ~= "" then
					tracks = {
						link = {},
						artist = {},
						name = {},
						time = {},
						image = {}
					}
					selectis = 0
					find_track_link(buf_find_music.v)
				end
			end
			imgui.SetCursorPosY(40)
			if #tracks.link > 0 and tracks.link[1] ~= "Ошибка404" then
				for i = 1, #tracks.link do
					local im = i
					checktrack = 1
					for hy = 1, #save_tracks.link do
						if save_tracks.link[hy] == tracks.link[im] then
							checktrack = 2
							tracknim = hy
							break
						end
					end
					imgui.SetCursorPosY(13 + (im * 35))
					if imgui.InvisibleButton(fa.ICON_PLUS..i,imgui.ImVec2(25, 25)) then
						if checktrack == 1 then
							table.insert(save_tracks.link, 1, tracks.link[i])
							table.insert(save_tracks.artist, 1, tracks.artist[i])
							table.insert(save_tracks.name, 1, tracks.name[i])
							table.insert(save_tracks.time, 1, tracks.time[i])
							table.insert(save_tracks.image, 1, tracks.image[i])
							local f = io.open(dirml.."/MedicalHelper/Треки.med", "w")
							f:write(encodeJson(save_tracks))
							f:flush()
							f:close()
							if selectis ~= 0 and status_track_pl ~= "STOP" and menu_play_track[2] then
								selectis = selectis + 1
								statusimage = statusimage + 1
							end
						end
						if checktrack == 2 then
							local checktracknext = save_tracks.link[tracknim]
							table.remove(save_tracks.link, tracknim)
							table.remove(save_tracks.artist, tracknim)
							table.remove(save_tracks.name, tracknim)
							table.remove(save_tracks.time, tracknim)
							table.remove(save_tracks.image, tracknim)
							local f = io.open(dirml.."/MedicalHelper/Треки.med", "w")
							f:write(encodeJson(save_tracks))
							f:flush()
							f:close()
							if selectis ~= 0 and menu_play_track[2] then
								if tracknim <= selectis and selectis ~= 1 and tracknim ~= selectis and #save_tracks.link ~= 0 then
									selectis = selectis - 1
									statusimage = selectis
								elseif tracknim == #save_tracks.link+1 and selectis == tracknim and #save_tracks.link ~= 0 then
									selectis = selectis - 1
									imgNoLabel = imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/nolabel.png")
									play_song(save_tracks.link[selectis], false)
								elseif tracknim == selectis and tracknim ~= #save_tracks.link + 1 and #save_tracks.link ~= 0 then
									imgNoLabel = imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/nolabel.png")
									play_song(save_tracks.link[selectis], false)
								end
								if #save_tracks.link == 0 then
									action_song('STOP')
								end
							end
						end
					end
					if imgui.IsItemHovered() then
						imgui.SameLine()
						imgui.SetCursorPosX(10)
						if checktrack == 1 then
							imgui.TextColored(imgui.ImVec4(1.0, 0.56, 0.64 ,1.00), fa.ICON_PLUS.." ")
						else
							imgui.TextColored(imgui.ImVec4(1.0, 0.56, 0.64 ,1.00), fa.ICON_MINUS.." ")
						end
					else
						imgui.SameLine()
						imgui.SetCursorPosX(10)
						if checktrack == 1 then
							imgui.Text(fa.ICON_PLUS.." ")
						else
							imgui.Text(fa.ICON_CHECK.." ")
						end
					end
					imgui.GetCursorStartPos()
					imgui.SameLine()
					imgui.SetCursorPosX(31)
					if selectis == i and menu_play_track[1] then
						imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(255, 255, 255, 42):GetVec4())
						imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(255, 255, 255, 52):GetVec4())
						imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(255, 255, 255, 37):GetVec4())
					else
						imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(255, 255, 255, 25):GetVec4())
						imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(255, 255, 255, 35):GetVec4())
						imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(255, 255, 255, 15):GetVec4())
					end
					imgui.SetCursorPosY(5 + (im * 35))
					if imgui.Button(u8"##MusicFindTrack"..i, imgui.ImVec2(645, 30)) then
						local menuu = {}
						menuu = menu_play_track
						tracknames = tracks.artist[i].." - "..tracks.name[i]
						tracknames_art = tracks.artist[i]
						tracknames_nm = tracks.name[i]
						menu_play_track = {true, false, false}
						if (selectis ~= i and menuu[1]) or not menuu[1] then
							imgNoLabel = imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/nolabel.png")
							selectis = i
							play_song(tracks.link[im], false)
							status_track_pl = "PLAY"
						elseif status_track_pl == "PAUSE" and menuu[1] then
							status_track_pl = "PLAY"
							action_song("PLAY")
						elseif status_track_pl == "PLAY" and menuu[1] then
							status_track_pl = "PAUSE"
							action_song("PAUSE")
						end
					end
					imgui.PopStyleColor(3)
					imgui.SameLine()
					imgui.SetCursorPosX(45)
					imgui.SetCursorPosY(9 + (im * 35))
					if i ~= selectis or (status_track_pl == "PAUSE" and menu_play_track[1]) then
						imgui.Text(fa.ICON_PLAY)
					elseif status_track_pl == "PLAY" and menu_play_track[1] then
						imgui.Text(fa.ICON_PAUSE)
					elseif status_track_pl == "PLAY" and menu_play_track[1] then
						imgui.Text(fa.ICON_PLAY)
					elseif not menu_play_track[1] then
						imgui.Text(fa.ICON_PLAY)
					end
					imgui.SameLine()
					imgui.SetCursorPosX(45)
					imgui.SetCursorPosY(8 + (im * 35))
					local textsize = "     {FFFFFF}"..tracks.artist[i].."{BDBDBD}  —  {BDBDBD}"..tracks.name[i]
					if #textsize > 107 then
						textsize = string.sub(textsize, 1, 107) .. ".."
					end
					imgui.TextColoredRGB(textsize)
					imgui.SameLine()
					imgui.SetCursorPosX(630)
					imgui.SetCursorPosY(8 + (im * 35))
					imgui.TextColoredRGB("{FFFFFF}"..tracks.time[i])
				end
			elseif tracks.link[1] == "Ошибка404" then
				selectis = 0
				imgui.SetCursorPosX(15)
				imgui.Text(u8"Ни один трек не найден. Возможные проблемы:\n\n1. В названии песни допущена ошибка.\n2. Правообладатель ограничил доступ к песне.\n3. Песни музыканта были удалены в связи со статусом инагента.")
			else
				imgui.SetCursorPosX(15)
				imgui.Text(u8"Здесь будут отображаться найденные треки. Для поиска песен воспользуйтесь строкой выше.")
			end
			imgui.EndChild()
		elseif select_menu_music == 1 and effilNOT then
			imgui.SetCursorPosX(155)
			imgui.SetCursorPosY(90)
			imgui.Text(u8"Поиск треков невозможен. Отсутствует библиотека \"effil\" \n\nСкачайте данную библиотеку и перенесите в папку lib для поддержки данной функции.")
		end
		if select_menu_music == 2 then
			imgui.SetCursorPos(imgui.ImVec2(150, 90))
			imgui.BeginChild("musicsave", imgui.ImVec2(0, 310), false)
			imgui.SetCursorPos(imgui.ImVec2(7, 8))
			if #save_tracks.link > 0 then
				for i = 1, #save_tracks.link do
					local im = i
					imgui.SetCursorPosY(13 + ((im-1) * 35))
					if imgui.InvisibleButton(fa.ICON_PLUS..i.."n",imgui.ImVec2(25, 25)) then
						table.remove(save_tracks.link, i)
						table.remove(save_tracks.artist, i)
						table.remove(save_tracks.name, i)
						table.remove(save_tracks.time, i)
						table.remove(save_tracks.image, i)
						local f = io.open(dirml.."/MedicalHelper/Треки.med", "w")
						f:write(encodeJson(save_tracks))
						f:flush()
						f:close()
						if selectis ~= 0 and menu_play_track[2] then
							if i <= selectis and selectis ~= 1 and i ~= selectis and #save_tracks.link ~= 0 then
								selectis = selectis - 1
								statusimage = selectis
							elseif i == #save_tracks.link+1 and selectis == i and #save_tracks.link ~= 0 then
								selectis = selectis - 1
								imgNoLabel = imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/nolabel.png")
								play_song(save_tracks.link[selectis], false)
							elseif i == selectis and i ~= #save_tracks.link + 1 and #save_tracks.link ~= 0 then
								imgNoLabel = imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/nolabel.png")
								play_song(save_tracks.link[selectis], false)
							end
							if #save_tracks.link == 0 then
								action_song('STOP')
								selectis = 0
							end
							break
						end
						if selectis == 0 then
							break
						end
					end
					
					if imgui.IsItemHovered() then
						imgui.SameLine()
						imgui.SetCursorPosX(10)
						imgui.TextColored(imgui.ImVec4(1.0, 0.56, 0.64 ,1.00), fa.ICON_MINUS.." ")
					else
						imgui.SameLine()
						imgui.SetCursorPosX(10)
						imgui.Text(fa.ICON_MINUS.." ")
					end
					imgui.GetCursorStartPos()
					imgui.SameLine()
					imgui.SetCursorPosX(31)
					if selectis == i and menu_play_track[2] then
						imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(255, 255, 255, 42):GetVec4())
						imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(255, 255, 255, 52):GetVec4())
						imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(255, 255, 255, 37):GetVec4())
					else
						imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(255, 255, 255, 25):GetVec4())
						imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(255, 255, 255, 35):GetVec4())
						imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(255, 255, 255, 15):GetVec4())
					end
					imgui.SetCursorPosY(5 + ((im-1) * 35))
					if imgui.Button(u8"##MusicSaveTrack"..i, imgui.ImVec2(645, 30)) then
						local menuu = {}
						menuu = menu_play_track
						tracknames = save_tracks.artist[i].." - "..save_tracks.name[i]
						tracknames_art = save_tracks.artist[i]
						tracknames_nm = save_tracks.name[i]
						menu_play_track = {false, true, false}
						if (selectis ~= i and menuu[2]) or not menuu[2] then
							imgNoLabel = imgui.CreateTextureFromFile(getWorkingDirectory().."/MedicalHelper/nolabel.png")
							selectis = i
							play_song(save_tracks.link[im], false)
							status_track_pl = "PLAY"
						elseif status_track_pl == "PAUSE" and menuu[2] then
							status_track_pl = "PLAY"
							action_song("PLAY")
						elseif status_track_pl == "PLAY" and menuu[2] then
							status_track_pl = "PAUSE"
							action_song("PAUSE")
						end
					end
					imgui.PopStyleColor(3)
			
					imgui.SameLine()
					imgui.SetCursorPosX(45)
					imgui.SetCursorPosY(9 + ((im-1) * 35))
					if i ~= selectis or (status_track_pl == "PAUSE" and menu_play_track[2]) then
						imgui.Text(fa.ICON_PLAY)
					elseif status_track_pl == "PLAY" and menu_play_track[2] then
						imgui.Text(fa.ICON_PAUSE)
					elseif status_track_pl == "PLAY" and menu_play_track[2] then
						imgui.Text(fa.ICON_PLAY)
					elseif not menu_play_track[2] then
						imgui.Text(fa.ICON_PLAY)
					end
					imgui.SameLine()
					imgui.SetCursorPosX(45)
					imgui.SetCursorPosY(8 + ((im-1) * 35))
					local textsize = "     {FFFFFF}"..save_tracks.artist[i].."{BDBDBD}  —  {BDBDBD}"..save_tracks.name[i]
					if #textsize > 107 then
						textsize = string.sub(textsize, 1, 107) .. ".."
					end
					imgui.TextColoredRGB(textsize)
					imgui.SameLine()
					imgui.SetCursorPosX(630)
					imgui.SetCursorPosY(8 + ((im-1) * 35))
					imgui.TextColoredRGB("{FFFFFF}"..save_tracks.time[i])
				end
			elseif #save_tracks.link == 0 then
				imgui.SetCursorPosX(15)
				imgui.Text(u8"Здесь будут отображаться треки, которые Вы дабавите через вкладку \"Поиск в интернете\".")
			end
			imgui.EndChild()
		end
		if select_menu_music == 3 then -- 125 138   pos -> 15 13
			local function background_record_card(posX_R, posY_R, i_R)
				imgui.SetCursorPos(imgui.ImVec2(posX_R, posY_R))
				if imgui.InvisibleButton(u8"##РЕКОРД RADIO"..i_R, imgui.ImVec2(125, 145)) then
					selectis = 0
					menu_play_track = {false, false, true}
					if select_music ~= i_R then
						select_music = i_R
						play_song(record[i_R])
					elseif status_track_pl == 'PLAY' then
						action_song('PAUSE')
					elseif status_track_pl == 'PAUSE' then
						action_song('PLAY')
					end
				end
				imgui.SetCursorPos(imgui.ImVec2(posX_R, posY_R))
				local p = imgui.GetCursorScreenPos()
				if select_music ~= i_R then
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 125, p.y + 143), imgui.GetColorU32(imgui.ImVec4(0.15, 0.15, 0.15 ,1.00)), 10, 15)
				elseif select_music == i_R then
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 125, p.y + 143), imgui.GetColorU32(imgui.ImVec4(0.99, 0.35, 0.12 ,0.90)), 10, 15)
				end
				if imgui.IsItemActive() then	
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 125, p.y + 143), imgui.GetColorU32(imgui.ImVec4(0.10, 0.10, 0.10 ,1.00)), 10, 15)
				elseif imgui.IsItemHovered() and select_music ~= i_R then
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 125, p.y + 143), imgui.GetColorU32(imgui.ImVec4(0.20, 0.20, 0.20 ,1.00)), 10, 15)
				end
				imgui.SetCursorPos(imgui.ImVec2(posX_R + 16, posY_R + 2))
				imgui.Image(imgRECORD[i_R], imgui.ImVec2(94, 94))
				local calc = imgui.CalcTextSize(u8(record_text_name[i_R]))
				imgui.SetCursorPos(imgui.ImVec2(posX_R + (63 - calc.x / 2 ), posY_R + 109))
				imgui.Text(u8(record_text_name[i_R]))
			end
			imgui.BeginChild("musicrecord", imgui.ImVec2(0, 320), false)
			--> Record Dance
			background_record_card(15, 13, 1)
			background_record_card(151, 13, 2)
			background_record_card(287, 13, 3)
			background_record_card(423, 13, 4)
			background_record_card(559, 13, 5)
			
			background_record_card(15, 166, 6)
			background_record_card(151, 166, 7)
			background_record_card(287, 166, 8)
			background_record_card(423, 166, 9)
			background_record_card(559, 166, 10)
			
			imgui.EndChild()
		end
		imgui.SetCursorPos(imgui.ImVec2(159, 400))
		local p = imgui.GetCursorScreenPos()
		imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 685, p.y + 55), imgui.GetColorU32(imgui.ImVec4(0.15, 0.15, 0.15 ,1.00)), 10, 15)
		imgui.GetCursorStartPos()
		local function convert(param)
			param = tonumber(param)*100
			return round(param, 1)
		end
		imgui.PushFont(fa_font_mus)
		if status_track_pl == "PAUSE" then
			imgui.SetCursorPos(imgui.ImVec2(199, 412))
			if imgui.InvisibleButton(u8"##PLAYMUSIC", imgui.ImVec2(30, 30)) then 
				if get_status_potok_song() ~= 0 then
					action_song("PLAY")
					status_track_pl = "PLAY"
				end
			end
			if imgui.IsItemHovered() then
				imgui.SetCursorPos(imgui.ImVec2(200, 410))
				imgui.TextColored(imgui.ImVec4(1.0, 0.56, 0.64 ,1.00), fa.ICON_PLAY_CIRCLE_O)
			else
				imgui.SetCursorPos(imgui.ImVec2(200, 410))
				imgui.TextColored(imgui.ImVec4(1.0, 1.00, 1.00 ,0.85), fa.ICON_PLAY_CIRCLE_O)
			end
		elseif status_track_pl == "PLAY" then
			imgui.SetCursorPos(imgui.ImVec2(199, 412))
			if imgui.InvisibleButton(u8"##STOPMUSIC", imgui.ImVec2(30, 30)) then
				action_song("PAUSE")
				status_track_pl = "PAUSE"
			end
			if imgui.IsItemHovered() then
				imgui.SetCursorPos(imgui.ImVec2(200, 410))
				imgui.TextColored(imgui.ImVec4(1.0, 0.56, 0.64 ,1.00), fa.ICON_PAUSE_CIRCLE_O)
			else
				imgui.SetCursorPos(imgui.ImVec2(200, 410))
				imgui.TextColored(imgui.ImVec4(1.0, 1.00, 1.00 ,0.85), fa.ICON_PAUSE_CIRCLE_O)
			end
		elseif status_track_pl == "STOP" then 
			imgui.SetCursorPos(imgui.ImVec2(200, 410))
			imgui.TextColored(imgui.ImVec4(1.0, 1.00, 1.00 ,0.50), fa.ICON_PLAY_CIRCLE_O)
		end
		imgui.PopFont()
		imgui.PushFont(fa_font)
		if status_track_pl ~= "STOP" and select_music == 0 then 
			imgui.SetCursorPos(imgui.ImVec2(174, 418))
			if imgui.InvisibleButton(u8"##BACKMUSIC", imgui.ImVec2(19, 18)) then
				back_track()
			end
			if imgui.IsItemHovered() then
				imgui.SetCursorPos(imgui.ImVec2(175, 420))
				imgui.TextColored(imgui.ImVec4(1.0, 0.56, 0.64 ,1.00), fa.ICON_BACKWARD)
			else
				imgui.SetCursorPos(imgui.ImVec2(175, 420))
				imgui.TextColored(imgui.ImVec4(1.0, 1.00, 1.00 ,0.85), fa.ICON_BACKWARD)
			end
			imgui.SetCursorPos(imgui.ImVec2(235, 418))
			if imgui.InvisibleButton(u8"##NEXTMUSIC", imgui.ImVec2(19, 18)) then
				next_track()
			end
			if imgui.IsItemHovered() then
				imgui.SetCursorPos(imgui.ImVec2(239, 420))
				imgui.TextColored(imgui.ImVec4(1.0, 0.56, 0.64 ,1.00), fa.ICON_FORWARD)
			else
				imgui.SetCursorPos(imgui.ImVec2(239, 420))
				imgui.TextColored(imgui.ImVec4(1.0, 1.00, 1.00 ,0.85), fa.ICON_FORWARD)
			end
		else
			imgui.SetCursorPos(imgui.ImVec2(175, 420))
			imgui.TextColored(imgui.ImVec4(1.0, 1.00, 1.00 ,0.50), fa.ICON_BACKWARD)
			imgui.SetCursorPos(imgui.ImVec2(239, 420))
			imgui.TextColored(imgui.ImVec4(1.0, 1.00, 1.00 ,0.50), fa.ICON_FORWARD)
		end
		imgui.PopFont()
		if status_track_pl ~= "STOP" then
			if selectis ~= 0 and menu_play_track[1] then
				local textsizel = "{FFFFFF}"..tracks.name[selectis]
				local textsizela = "{BDBDBD}"..tracks.artist[selectis]
				if #textsizel > 57 then
					textsizel = string.sub(textsizel, 1, 57) .. "..."
				end
				if #textsizela > 57 then
					textsizela = string.sub(textsizela, 1, 57) .. "..."
				end
				imgui.SetCursorPos(imgui.ImVec2(325, 403))
				imgui.TextColoredRGB(textsizel)
				imgui.SetCursorPos(imgui.ImVec2(325, 420))
				imgui.TextColoredRGB(textsizela)
				imgui.SetCursorPos(imgui.ImVec2(267, 405))
				if statusimage == selectis then
					imgui.Image(imgLabel, imgui.ImVec2(46, 46))
				else
					imgui.Image(imgNoLabel, imgui.ImVec2(46, 46))
				end
			elseif selectis ~= 0 and menu_play_track[2] then
				local textsizel = "{FFFFFF}"..save_tracks.name[selectis]
				local textsizela = "{BDBDBD}"..save_tracks.artist[selectis]
				if #textsizel > 57 then
					textsizel = string.sub(textsizel, 1, 57) .. "..."
				end
				if #textsizela > 57 then
					textsizela = string.sub(textsizela, 1, 57) .. "..."
				end
				imgui.SetCursorPos(imgui.ImVec2(325, 403))
				imgui.TextColoredRGB(textsizel)
				imgui.SetCursorPos(imgui.ImVec2(325, 420))
				imgui.TextColoredRGB(textsizela)
				imgui.SetCursorPos(imgui.ImVec2(267, 405))
				if statusimage == selectis then
					imgui.Image(imgLabel, imgui.ImVec2(46, 46))
				else
					imgui.Image(imgNoLabel, imgui.ImVec2(46, 46))
				end
			elseif select_music ~= 0 then
				imgui.SetCursorPos(imgui.ImVec2(325, 403))
				imgui.TextColoredRGB("{FFFFFF}"..record_text_name[select_music])
				imgui.SetCursorPos(imgui.ImVec2(325, 420))
				imgui.TextColoredRGB("{BDBDBD}Record")
				imgui.SetCursorPos(imgui.ImVec2(267, 405))
				imgui.Image(imgRECORD[select_music], imgui.ImVec2(46, 46))
			elseif selectis == 0 and select_music == 0 and status_track_pl ~= 'STOP' then
				imgui.SetCursorPos(imgui.ImVec2(325, 403))
				imgui.TextColoredRGB("{FFFFFF}"..tracknames_nm)
				imgui.SetCursorPos(imgui.ImVec2(325, 420))
				imgui.TextColoredRGB("{BDBDBD}"..tracknames_art)
				imgui.SetCursorPos(imgui.ImVec2(267, 405))
				imgui.Image(imgLabel, imgui.ImVec2(46, 46))
			end
			if selectis == 0 and select_music == 0 then
				imgui.SetCursorPos(imgui.ImVec2(325, 403))
				imgui.TextColoredRGB("{FFFFFF}"..tracknames_nm)
				imgui.SetCursorPos(imgui.ImVec2(325, 420))
				imgui.TextColoredRGB("{BDBDBD}"..tracknames_art)
				imgui.SetCursorPos(imgui.ImVec2(267, 405))
				imgui.Image(imgLabel, imgui.ImVec2(46, 46))
			end
		elseif selectis == 0 and not menu_play_track[3] then
			imgui.SetCursorPos(imgui.ImVec2(325, 403))
			imgui.TextColoredRGB("{FFFFFF}".."Ничего не воспроизводится")
			imgui.SetCursorPos(imgui.ImVec2(325, 420))
			imgui.TextColoredRGB("{BDBDBD}".."")
			imgui.SetCursorPos(imgui.ImVec2(267, 405))
			imgui.Image(imgNoLabel, imgui.ImVec2(46, 46))
		end
		imgui.SetCursorPos(imgui.ImVec2(325, 442))
		local p = imgui.GetCursorScreenPos()
		imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 400, p.y + Y_rewind), imgui.GetColorU32(imgui.ImVec4(1.00, 1.00, 1.00 ,0.50)), 10, 15)
		imgui.SetCursorPos(imgui.ImVec2(325, 442))
		local p = imgui.GetCursorScreenPos()
		if get_status_potok_song() ~= 0 then --findmh
			local function thetime()
				if timetr[1] < 10 then
					trt = "0"..timetr[1]
				else
					trt = timetr[1]
				end
				if timetr[2] < 10 then
					trt2 = "0"..timetr[2]
				else
					trt2 = timetr[2]
				end
				return trt2..":"..trt
			end
			if select_music == 0 then
				local sizeXline = (timetr[2]*60+timetr[1])*timetri
				if sizeXline > 400 then
					sizeXline = 400
				end
				imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + sizeXline, p.y + Y_rewind), imgui.GetColorU32(imgui.ImVec4(0.05, 0.45, 0.67 ,0.90)), 100, 9)
				imgui.SetCursorPos(imgui.ImVec2(690, 421))
				imgui.TextColoredRGB("{FFFFFF}"..thetime())
				imgui.SetCursorPos(imgui.ImVec2(325, 442))
			else
				imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 400, p.y + Y_rewind), imgui.GetColorU32(imgui.ImVec4(0.05, 0.45, 0.67 ,0.90)), 100, 15)
			end 
		end
		imgui.PushFont(fa_font)
		
		imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImColor(255, 255, 255, 0):GetVec4())
		imgui.PushStyleColor(imgui.Col.SliderGrab, imgui.ImColor(255, 255, 255, 0):GetVec4())
		imgui.PushStyleColor(imgui.Col.SliderGrabActive, imgui.ImColor(255, 255, 255, 0):GetVec4())
		--------------
		imgui.SetCursorPos(imgui.ImVec2(315, 434))
		imgui.PushItemWidth(419)
		if imgui.SliderFloat(u8"##Перемотка песенки", sectime_track, 0, track_time_hc - 2, u8"") then
			rewind_song(sectime_track.v)
		end
		if imgui.IsItemHovered() then
			if Y_rewind < 9 then
				Y_rewind = Y_rewind + 0.5
			end
		else
			if Y_rewind > 5 then
				Y_rewind = Y_rewind - 0.5
			end
		end
		
		imgui.PopStyleColor(3)
		
		imgui.SetCursorPos(imgui.ImVec2(761, 410))
		if imgui.InvisibleButton(u8"##REPEATMUSIC", imgui.ImVec2(19, 18)) then
			repeatmusic.v = not repeatmusic.v
		end
		if imgui.IsItemHovered() then
			imgui.SetCursorPos(imgui.ImVec2(764, 412))
			imgui.TextColored(imgui.ImVec4(1.0, 0.56, 0.64 ,1.00), fa.ICON_REPEAT)
		else
			imgui.SetCursorPos(imgui.ImVec2(764, 412))
			if repeatmusic.v then
				imgui.TextColored(imgui.ImVec4(1.0, 1.00, 1.00 ,1.00), fa.ICON_REPEAT)
			else
				imgui.TextColored(imgui.ImVec4(1.0, 1.00, 1.00 ,0.45), fa.ICON_REPEAT)
			end
		end
		imgui.SetCursorPos(imgui.ImVec2(787, 410))
		if imgui.InvisibleButton(u8"##DONWSCREENPLAYER", imgui.ImVec2(19, 18)) then
			player_HUD.v = not player_HUD.v
		end
		if imgui.IsItemHovered() then
			imgui.SetCursorPos(imgui.ImVec2(789, 412))
			imgui.TextColored(imgui.ImVec4(1.0, 0.56, 0.64 ,1.00), fa.ICON_WINDOW_MAXIMIZE)
		else
			imgui.SetCursorPos(imgui.ImVec2(789, 412))
			if player_HUD.v then
				imgui.TextColored(imgui.ImVec4(1.0, 1.00, 1.00 ,1.00), fa.ICON_WINDOW_MAXIMIZE)
			else
				imgui.TextColored(imgui.ImVec4(1.0, 1.00, 1.00 ,0.45), fa.ICON_WINDOW_MAXIMIZE)
			end
		end
		imgui.SetCursorPos(imgui.ImVec2(813, 411))
		if imgui.InvisibleButton(u8"##ENDSTOPMUSIC", imgui.ImVec2(19, 18)) then
			if status_track_pl ~= "STOP" and get_status_potok_song() ~= 0 then
				action_song("STOP")
				status_track_pl = "STOP"
			end
		end
		if imgui.IsItemHovered() then
			if status_track_pl ~= "STOP" then
				imgui.SetCursorPos(imgui.ImVec2(816, 412))
				imgui.TextColored(imgui.ImVec4(1.0, 0.56, 0.64 ,1.00), fa.ICON_STOP)
			else
				imgui.SetCursorPos(imgui.ImVec2(816, 412))
				imgui.TextColored(imgui.ImVec4(1.0, 1.00, 1.00 ,0.40), fa.ICON_STOP)
			end
		else
			imgui.SetCursorPos(imgui.ImVec2(816, 412))
			if status_track_pl == "STOP" then
				imgui.TextColored(imgui.ImVec4(1.0, 1.00, 1.00 ,0.40), fa.ICON_STOP)
			else
				imgui.TextColored(imgui.ImVec4(1.0, 1.00, 1.00 ,1.00), fa.ICON_STOP)
			end	
		end
		imgui.PopFont()
		imgui.SetCursorPos(imgui.ImVec2(740, 437))
		if volume_music.v >= 0.7 then
			imgui.Text(fa.ICON_VOLUME_UP)
		elseif volume_music.v >= 0.2 and volume_music.v < 0.7 then
			imgui.Text(fa.ICON_VOLUME_DOWN)
		elseif volume_music.v < 0.2 then
			imgui.Text(fa.ICON_VOLUME_OFF)
		end
		imgui.SetCursorPos(imgui.ImVec2(760, 432))
		imgui.PushItemWidth(80)
		imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImColor(0, 0, 0, 0):GetVec4())
		imgui.PushStyleColor(imgui.Col.SliderGrab, imgui.ImColor(0, 0, 0, 0):GetVec4())
		imgui.PushStyleColor(imgui.Col.SliderGrabActive, imgui.ImColor(0, 0, 0, 0):GetVec4())
		if imgui.SliderFloat(u8"##Громкость", volume_music, 0, 2, u8"") then 
			if status_track_pl ~= "STOP" then
				volume_song(volume_music.v)
			end
		end
		imgui.PopStyleColor(3)
		imgui.PopItemWidth()
		imgui.SetCursorPos(imgui.ImVec2(760, 442))
		local p = imgui.GetCursorScreenPos()
		imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 75, p.y + 5), imgui.GetColorU32(imgui.ImVec4(1.00, 1.00, 1.00 ,0.50)), 10, 15)
		imgui.SetCursorPos(imgui.ImVec2(760, 442))
		local p = imgui.GetCursorScreenPos()
		imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + (convert(volume_music.v)/2.66), p.y + 5), imgui.GetColorU32(imgui.ImVec4(1.00, 1.00, 1.00 ,1.00)), 10, 15)
	elseif bassNOT and select_menu[10] then
		imgui.SetCursorPosX(155)
		imgui.SetCursorPosY(210)
		imgui.Text(u8"Использование музыки невозможно. Отсутствует библиотека \"bass.lua\" \n\nСкачайте данную библиотеку и перенесите в папку lib для поддержки данной функции.")
	end
	--> О скрипте [9]
	if select_menu[9] then
		local function TheBackground(IsItem, posX, posY, sizeX, sizeY, rounding, flag)
			imgui.SetCursorPos(imgui.ImVec2(posX, posY))
			local p = imgui.GetCursorScreenPos()
			if IsItem == 1 then
				imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + sizeX, p.y + sizeY), imgui.GetColorU32(imgui.ImVec4(0.15, 0.15, 0.15 ,1.00)), rounding, flag)
			elseif IsItem == 2 then
				imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + sizeX, p.y + 2), imgui.GetColorU32(imgui.ImVec4(0.35, 0.35, 0.35 ,1.00)))
			end
		end
		TheBackground(1, 390, 40, 222, 50, 10, 15)
		TheBackground(1, 165, 77, 675, 166, 10, 15)
		TheBackground(1, 165, 253, 675, 140, 10, 15)
		TheBackground(1, 165, 403, 675, 47, 10, 15)
		TheBackground(2, 165, 113, 675, 2, 0, 0)
		TheBackground(2, 165, 187, 675, 2, 0, 0)
		imgui.SetCursorPos(imgui.ImVec2(429, 50))
		imgui.TextColored(imgui.ImVec4(1.0, 0.56, 0.64 ,1.00), "Medical Helper by Kane")
		imgui.SetCursorPos(imgui.ImVec2(176, 86))
		imgui.Text(u8"Скрипт разработан для проекта Arizona Role Play для облегчения работы сотрудникам больниц.")
		imgui.SetCursorPos(imgui.ImVec2(176, 121))
		imgui.TextColoredRGB("Нынешний разработчик - {FFB700}Kane")
		imgui.SetCursorPos(imgui.ImVec2(176, 142))
		imgui.TextColoredRGB("Версия скрипта - {FFB700}".. scr.version .. " Бета")
		imgui.SetCursorPos(imgui.ImVec2(176, 163))
		imgui.TextColoredRGB("Благодарность {32CD32}blast.hk{FFFFFF}, скриптеру {32CD32}Hatiko{FFFFFF} и тестировщику {32CD32}Ilya Kustov{FFFFFF}.")
		imgui.SetCursorPos(imgui.ImVec2(176, 194))
		imgui.TextColoredRGB("Распространение скрипта разрешено только на официальном сайте/канале {32CD32}Arizona RP{FFFFFF}!")
		imgui.SetCursorPos(imgui.ImVec2(176, 215))
		imgui.TextColoredRGB("Нашли баг, ошибку или же есть предложение?")
		imgui.SameLine()
		imgui.TextColoredRGB("Напиши {74BAF4}разработчику скрипта.")
		if imgui.IsItemHovered() then imgui.SetTooltip(u8"Кликните ЛКМ, чтобы скопировать, или ПКМ, чтобы открыть в браузере") end
		if imgui.IsItemClicked(0) then setClipboardText("https://vk.com/marseloy") end
		if imgui.IsItemClicked(1) then shell32.ShellExecuteA(nil, 'open', 'https://vk.com/marseloy', nil, nil, 1) end
		imgui.SetCursorPos(imgui.ImVec2(176, 262))
		imgui.TextColoredRGB("    Изначально {FF8FA2}Medical Helper{FFFFFF} появился на свет благодаря разработчику {32CD32}Hatiko{FFFFFF}, но уже несколько")
		imgui.SetCursorPos(imgui.ImVec2(176, 283))
		imgui.TextColoredRGB("лет известный программист не обновляет свой скрипт, вследствие чего он потерял актуальность.")
		imgui.SetCursorPos(imgui.ImVec2(176, 304))
		imgui.TextColoredRGB("Но, благо, легендарный {32CD32}Hatiko{FFFFFF} дал добро на дальшейную поддержку и модернизацию скрипта.")
		imgui.SetCursorPos(imgui.ImVec2(176, 325))
		imgui.TextColoredRGB("Именно поэтому сейчас Вы имеете возможность бесплатно использовать текущую, улучшенную")
		imgui.SetCursorPos(imgui.ImVec2(176, 346))
		imgui.TextColoredRGB("версию скрипта, которая актуализирована под последнее обновление Аризоны и будет актуальна")
		imgui.SetCursorPos(imgui.ImVec2(176, 367))
		imgui.TextColoredRGB("благодаря регулярным обновлениям со стороны нынешнего разработчика.")
		imgui.SetCursorPos(imgui.ImVec2(176, 413))
		if imgui.Button(u8"Отключить", imgui.ImVec2(215, 26)) then showCursor(false); scr:unload() end
		imgui.SameLine()
		if imgui.Button(u8"Перезагрузить", imgui.ImVec2(214, 26)) then showCursor(false); scr:reload() end
		imgui.SameLine()
		if imgui.Button(u8"Удалить скрипт", imgui.ImVec2(214, 26)) then 
			addOneOffSound(0, 0, 0, 1058)
			sampAddChatMessage("", 0xFF8FA2); sampAddChatMessage("", 0xFF8FA2); sampAddChatMessage("", 0xFF8FA2)
			sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} Внимание! Подтвердите удаление командой {77DF63}/mh-delete.", 0xFF8FA2)
			mainWin.v = false
		end
	end
	--> Статистика [7]
	if select_menu[7] then
		profitmoney()
	end
	--> Установка клавиши
	imgui.PushStyleColor(imgui.Col.PopupBg, imgui.ImVec4(0.06, 0.06, 0.06, 0.94))
	if imgui.BeginPopupModal(u8"MH | Установка клавиши для активации", null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove) then		
		imgui.Text(u8"Нажмите на клавишу или сочетание клавиш для установки активации."); imgui.Separator()
		imgui.Text(u8"Допускаются клавиши:")
		imgui.Bullet()	imgui.TextDisabled(u8"Клавиши для сочетаний - Alt, Ctrl, Shift")
		imgui.Bullet()	imgui.TextDisabled(u8"Английские буквы")
		imgui.Bullet()	imgui.TextDisabled(u8"Функциональные клавиши F1-F12")
		imgui.Bullet()	imgui.TextDisabled(u8"Цифры верхней панели")
		imgui.Bullet()	imgui.TextDisabled(u8"Боковая панель Numpad")
		ButtonSwitch(u8"Использовать ПКМ в комбинации с клавишами", cb_RBUT)
		imgui.Separator()
		if imgui.TreeNode(u8"Для пользователей 5-кнопочной мыши") then
			ButtonSwitch(u8"X Button 1", cb_x1)
			ButtonSwitch(u8"X Button 2", cb_x2)
			imgui.Separator()
			imgui.TreePop();
		end
		imgui.Text(u8"Текущая клавиша(и): ");
		imgui.SameLine();
		if imgui.IsMouseClicked(0) then
			lua_thread.create(function()
				wait(500)			
				setVirtualKeyDown(3, true)
				wait(0)
				setVirtualKeyDown(3, false)
			end)
		end
		if #(rkeys.getCurrentHotKey()) ~= 0 and not rkeys.isBlockedHotKey(rkeys.getCurrentHotKey()) then	
			if not rkeys.isKeyModified((rkeys.getCurrentHotKey())[#(rkeys.getCurrentHotKey())]) then
				currentKey[1] = table.concat(rkeys.getKeysName(rkeys.getCurrentHotKey()), " + ")
				currentKey[2] = rkeys.getCurrentHotKey()
			end
		end
		imgui.TextColored(imgui.ImColor(255, 205, 0, 200):GetVec4(), currentKey[1])
		if isHotKeyDefined then
			imgui.TextColoredRGB("{FF0000}[Ошибка]{FFFFFF} Данный бинд уже существует!")
		end
		if isHotKeyExists then
			imgui.TextColoredRGB("{FF0000}[Ошибка]{FFFFFF} Клавиша назначена на другом бинде/команде!")
		end
		if imgui.Button(u8"Установить", imgui.ImVec2(150, 0)) then
			if select_menu[3] then
				if cb_RBUT.v then table.insert(currentKey[2], 1, vkeys.VK_RBUTTON) end
				if cb_x1.v then table.insert(currentKey[2], vkeys.VK_XBUTTON1) end
				if cb_x2.v then table.insert(currentKey[2], vkeys.VK_XBUTTON2) end
				if rkeys.isHotKeyExist(currentKey[2]) then 
					isHotKeyExists = true
				else
					rkeys.unRegisterHotKey(cmdBind[selected_cmd].key)
					unRegisterHotKey(cmdBind[selected_cmd].key)
					cmdBind[selected_cmd].key = currentKey[2]
					rkeys.registerHotKey(currentKey[2], true, onHotKeyCMD)
					table.insert(keysList, currentKey[2])
					currentKey = {"",{}}
					lockPlayerControl(false)
					cb_RBUT.v = false
					cb_x1.v, cb_x2.v = false, false
					isHotKeyExists = false
					imgui.CloseCurrentPopup();
					local f = io.open(dirml.."/MedicalHelper/cmdSetting.med", "w")
					f:write(encodeJson(cmdBind))
					f:flush()
					f:close()
					editKey = false
				end	
			elseif select_menu[4] then
				if cb_RBUT.v then table.insert(currentKey[2], 1, vkeys.VK_RBUTTON) end
				if cb_x1.v then table.insert(currentKey[2], vkeys.VK_XBUTTON1) end
				if cb_x2.v then table.insert(currentKey[2], vkeys.VK_XBUTTON2) end
				if rkeys.isHotKeyExist(currentKey[2]) then 
					isHotKeyExists = true
				else	
					rkeys.unRegisterHotKey(binder.list[binder.select_bind].key)
					unRegisterHotKey(binder.list[binder.select_bind].key)
					binder.key = currentKey[2]
					lockPlayerControl(false)
					cb_RBUT.v = false
					cb_x1.v, cb_x2.v = false, false
					isHotKeyExists = false
					imgui.CloseCurrentPopup();
					editKey = false
				end
			end
		end
		imgui.SameLine();
		if imgui.Button(u8"Закрыть", imgui.ImVec2(150, 0)) then 
			imgui.CloseCurrentPopup(); 
			currentKey = {"",{}}
			cb_RBUT.v = false
			cb_x1.v, cb_x2.v = false, false
			lockPlayerControl(false)
			isHotKeyExists = false
			editKey = false
		end 
		imgui.SameLine()
		if imgui.Button(u8"Очистить", imgui.ImVec2(150, 0)) then
			currentKey = {"",{}}
			cb_x1.v, cb_x2.v = false, false
			cb_RBUT.v = false
			isHotKeyExists = false
		end
		imgui.EndPopup()
	end
	--> Редактор команд
	if imgui.BeginPopupModal(u8"MH | Редактирование команды", null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove) then
		imgui.SetCursorPosX(70)
		imgui.Text(u8"Введите новую команду на этот бинд, которую Вы пожелаете."); imgui.Separator()
		imgui.Text(u8"Примечания:")
		imgui.Bullet()	imgui.TextColoredRGB("{00ff8c}Разрешается заменять серверные команды.")
		imgui.Bullet()	imgui.TextColoredRGB("{00ff8c}Если Вы замените серверную команду - Ваша команда станет приоритетной.")
		imgui.Bullet()	imgui.TextColoredRGB("{00ff8c}Нельзя использовать цифры и символы. Только английские буквы.")
		if select_menu[4] then
			imgui.Bullet()	imgui.TextColoredRGB("{00ff8c}Бинд на сокращение команд {e3071d}/findihouse{00ff8c} и {e3071d}/findibiz {00ff8c}карается баном!")
		end
		imgui.Text(u8"/");
		imgui.SameLine();
		imgui.PushItemWidth(520)
		imgui.InputText(u8"##inpcastname", chgName.inp, 512, filter(1, "[%a]+"))
		if isHotKeyDefined then
			imgui.TextColoredRGB("{FF0000}[Ошибка]{FFFFFF} Данная команда уже существует!")
		end
		if russkieBukviNahyi then
			imgui.TextColoredRGB("{FF0000}[Ошибка]{FFFFFF} Нельзя использовать русские буквы!")
		end
		if dlinaStroki then
			imgui.TextColoredRGB("{FF0000}[Ошибка]{FFFFFF} Максимальная длина команды - 15 букв!")
		end		
		if select_menu[3] then
			if imgui.Button(u8"Сохранить", imgui.ImVec2(174, 0)) then
				local exits = false
				if chgName.inp.v:find("%A") then
					russkieBukviNahyi = true
					isHotKeyDefined = false
					dlinaStroki = false
					exits = true
				elseif chgName.inp.v:len() > 15 then
					dlinaStroki = true
					russkieBukviNahyi = false
					isHotKeyDefined = false
					exits = true
				end
				for i,v in ipairs(binder.list) do
					if binder.list[i].cmd == chgName.inp.v then
						exits = true
						isHotKeyDefined = true
						russkieBukviNahyi = false
						dlinaStroki = false
					end
					if chgName.inp.v == binder.cmd.v then
						exits = true
						isHotKeyDefined = true
						russkieBukviNahyi = false
						dlinaStroki = false
					end
				end
				for i,v in ipairs(cmdBind) do
					if v.cmd == chgName.inp.v and chgName.inp.v ~= cmdBind[selected_cmd].cmd then
						exits = true
						isHotKeyDefined = true
						russkieBukviNahyi = false
						dlinaStroki = false
					end
				end
				if not exits then
					if cmdBind[selected_cmd].cmd == chgName.inp.v then
						isHotKeyDefined = false
						russkieBukviNahyi = false
						dlinaStroki = false
						imgui.CloseCurrentPopup();
					else
						isHotKeyDefined = false
						russkieBukviNahyi = false
						dlinaStroki = false
						cmdBind[selected_cmd].cmd = chgName.inp.v
						imgui.CloseCurrentPopup();
						local f = io.open(dirml.."/MedicalHelper/cmdSetting.med", "w")
						f:write(encodeJson(cmdBind))
						f:flush()
						f:close()
						sampRegCMD()
						sampUnregisterChatCommand(unregcmd)
						editKey = false
					end
				end
			end
		end			
		if select_menu[4] then
			if imgui.Button(u8"Применить", imgui.ImVec2(174, 0)) then
				local exits = false
				if chgName.inp.v:find("%A") then
					russkieBukviNahyi = true
					isHotKeyDefined = false
					dlinaStroki = false
					exits = true
				elseif chgName.inp.v:len() > 15 then
					dlinaStroki = true
					russkieBukviNahyi = false
					isHotKeyDefined = false
					exits = true
				end
				for i,v in ipairs(cmdBind) do
					if v.cmd == chgName.inp.v then
						exits = true
						isHotKeyDefined = true
						russkieBukviNahyi = false
						dlinaStroki = false
					end
				end
				for i,v in ipairs(binder.list) do
					if binder.list[i].cmd == chgName.inp.v and chgName.inp.v ~= binder.cmd.v and chgName.inp.v ~= "" then
						exits = true
						isHotKeyDefined = true
						russkieBukviNahyi = false
						dlinaStroki = false
					end
				end
				if not exits then
					if binder.cmd.v == chgName.inp.v then
						unregcmd = ""
						isHotKeyDefined = false
						russkieBukviNahyi = false
						dlinaStroki = false
						imgui.CloseCurrentPopup();
					else
						isHotKeyDefined = false
						russkieBukviNahyi = false
						dlinaStroki = false
						binder.cmd.v = chgName.inp.v
						imgui.CloseCurrentPopup();
						editKey = false
					end
				end
			end
		end				
		imgui.SameLine();
		if imgui.Button(u8"Закрыть", imgui.ImVec2(174, 0)) then 
			imgui.CloseCurrentPopup(); 
			currentKey = {"",{}}
			cb_RBUT.v = false
			cb_x1.v, cb_x2.v = false, false
			lockPlayerControl(false)
			isHotKeyDefined = false
			russkieBukviNahyi = false
			dlinaStroki = false
			editKey = false
			unregcmd = ""
		end 
		imgui.SameLine()
		if select_menu[3] then
			if imgui.Button(u8"Вернуть стандартную", imgui.ImVec2(174, 0)) then
				chgName.inp.v = list_cmd[selected_cmd]
				isHotKeyDefined = false
				russkieBukviNahyi = false
				dlinaStroki = false
			end
		end
		if select_menu[4] then
			if imgui.Button(u8"Очистить строку", imgui.ImVec2(174, 0)) then
				chgName.inp.v = ""
				isHotKeyDefined = false
				russkieBukviNahyi = false
				dlinaStroki = false
			end
		end
		imgui.EndPopup()
	end
	if imgui.BeginPopupModal(u8"Ошибка", null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove) then
		imgui.Text(u8"Данное название уже существует")
		imgui.SetCursorPosX(60)
		if imgui.Button(u8"Ок", imgui.ImVec2(120, 20)) then imgui.CloseCurrentPopup() end
		imgui.EndPopup()
	end	
	imgui.PopStyleColor(1)
	imgui.End()
end

function imgui.OnDrawFrame()
	if mainWin.v then
		mainWind()
	end
	if choiceWin.v then
		choiceWind()
	end
	if ReminderWin.v then
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowSize(imgui.ImVec2(300, 130), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(sw/2, sh/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"Напоминание", mainWin, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoScrollWithMouse);
		imgui.SetCursorPosX(105)
		imgui.PushFont(fontsize)
		imgui.SetCursorPosY(6)
		imgui.Text(u8" Напоминание")
		imgui.PopFont()
		imgui.SameLine()
		imgui.SetCursorPosX(270)
		imgui.SetCursorPosY(6)
		if imgui.InvisibleButton(u8"closef", imgui.ImVec2(24, 24)) then
			if sound_reminder:status() ~= "dead" then
				sound_reminder:terminate()
			end
			ReminderWin.v = false
		end
		if imgui.IsItemHovered() then
			imgui.SameLine()
			imgui.SetCursorPosX(275)
			imgui.SetCursorPosY(3)
			imgui.PushFont(fa_font2)
			imgui.TextColored(imgui.ImVec4(1.00, 0.56, 0.64 ,1.00), fa.ICON_TIMES)
			imgui.PopFont()
		else
			imgui.SameLine()
			imgui.SetCursorPosX(275)
			imgui.SetCursorPosY(3)
			imgui.PushFont(fa_font2)
			imgui.Text(fa.ICON_TIMES)
			imgui.PopFont()
		end
		imgui.Separator()
		imgui.Dummy(imgui.ImVec2(0, 1))
		imgui.PushFont(fontsize)
		imgui.TextWrapped(remin_text)
		imgui.PopFont()
		imgui.Dummy(imgui.ImVec2(0, 2))
		if imgui.Button(u8"Остановить", imgui.ImVec2(286, 30)) then
			if sound_reminder:status() ~= "dead" then
				sound_reminder:terminate()
			end
			ReminderWin.v = false
		end
		imgui.Dummy(imgui.ImVec2(0, 2))
		imgui.End()
	end
	if player_HUD.v then
		if musicHUD.v then
			if not mainWin.v and not iconwin.v and not sobWin.v and not depWin.v and not updWin.v and not spurBig.v and not choiceWin.v and not ReminderWin.v then
				imgui.ShowCursor = false
			end
			if status_track_pl == "STOP" then
				musicHUD.v = false
			end
			imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 1.06), imgui.Cond.Always, imgui.ImVec2(0.5, 0.5))
			if not menu_play_track[3] then
				imgui.SetNextWindowSize(imgui.ImVec2(346, 70))
			else
				imgui.SetNextWindowSize(imgui.ImVec2(308, 70))
			end
			imgui.PushStyleColor(imgui.Col.WindowBg, imgui.ImVec4(0.11, 0.15, 0.17, 0.85))
			imgui.Begin(u8"ХудМузыки", musicHUD, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar)
			if status_track_pl ~= "STOP" then
				if selectis ~= 0 and menu_play_track[1] then
					local textsizel = "{FFFFFF}"..tracks.name[selectis]
					local textsizela = "{BDBDBD}"..tracks.artist[selectis]
					if #textsizel > 27 then
						textsizel = string.sub(textsizel, 1, 27) .. "..."
					end
					if #textsizela > 27 then
						textsizela = string.sub(textsizela, 1, 27) .. "..."
					end
					imgui.SetCursorPos(imgui.ImVec2(88, 9))
					imgui.TextColoredRGB(textsizel)
					imgui.SetCursorPos(imgui.ImVec2(88, 27))
					imgui.TextColoredRGB(textsizela)
					imgui.SetCursorPos(imgui.ImVec2(17, 5))
					if statusimage == selectis then
						imgui.Image(imgLabel, imgui.ImVec2(60, 60))
					else
						imgui.Image(imgNoLabel, imgui.ImVec2(60, 60))
					end
				elseif selectis ~= 0  and menu_play_track[2] then
					local textsizel = "{FFFFFF}"..save_tracks.name[selectis]
					local textsizela = "{BDBDBD}"..save_tracks.artist[selectis]
					if #textsizel > 27 then
						textsizel = string.sub(textsizel, 1, 27) .. "..."
					end
					if #textsizela > 27 then
						textsizela = string.sub(textsizela, 1, 27) .. "..."
					end
					imgui.SetCursorPos(imgui.ImVec2(88, 9))
					imgui.TextColoredRGB(textsizel)
					imgui.SetCursorPos(imgui.ImVec2(88, 27))
					imgui.TextColoredRGB(textsizela)
					imgui.SetCursorPos(imgui.ImVec2(17, 5))
					if statusimage == selectis then
						imgui.Image(imgLabel, imgui.ImVec2(60, 60))
					else
						imgui.Image(imgNoLabel, imgui.ImVec2(60, 60))
					end
				elseif select_music ~= 0 then
					imgui.SetCursorPos(imgui.ImVec2(88, 9))
					imgui.TextColoredRGB("{FFFFFF}"..record_text_name[select_music])
					imgui.SetCursorPos(imgui.ImVec2(88, 27))
					imgui.TextColoredRGB("{BDBDBD}Record")
					imgui.SetCursorPos(imgui.ImVec2(14, 5))
					imgui.Image(imgRECORD[select_music], imgui.ImVec2(60, 60))
				elseif selectis == 0 and select_music == 0 and status_track_pl ~= 'STOP' then
					imgui.SetCursorPos(imgui.ImVec2(88, 9))
					imgui.TextColoredRGB("{FFFFFF}"..tracknames_nm)
					imgui.SetCursorPos(imgui.ImVec2(88, 27))
					imgui.TextColoredRGB("{BDBDBD}"..tracknames_art)
					imgui.SetCursorPos(imgui.ImVec2(14, 5))
					imgui.Image(imgLabel, imgui.ImVec2(60, 60))
				end
				if selectis == 0 and select_music == 0 then
					imgui.SetCursorPos(imgui.ImVec2(88, 9))
					imgui.TextColoredRGB("{FFFFFF}"..tracknames_nm)
					imgui.SetCursorPos(imgui.ImVec2(88, 27))
					imgui.TextColoredRGB("{BDBDBD}"..tracknames_art)
					imgui.SetCursorPos(imgui.ImVec2(17, 5))
					imgui.Image(imgLabel, imgui.ImVec2(60, 60))
				end
			elseif selectis == 0 and select_music == 0 then
				imgui.SetCursorPos(imgui.ImVec2(88, 9))
				imgui.TextColoredRGB("{FFFFFF}".."Ничего не воспроизводится")
				imgui.SetCursorPos(imgui.ImVec2(88, 27))
				imgui.TextColoredRGB("{BDBDBD}".."")
				imgui.SetCursorPos(imgui.ImVec2(17, 5))
				imgui.Image(imgNoLabel, imgui.ImVec2(60, 60))
			end
			imgui.SetCursorPos(imgui.ImVec2(88, 55))
			local p = imgui.GetCursorScreenPos()
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 200, p.y + 5), imgui.GetColorU32(imgui.ImVec4(1.00, 1.00, 1.00 ,0.50)), 10, 15)
			imgui.SetCursorPos(imgui.ImVec2(88, 55))
			local p = imgui.GetCursorScreenPos()
			if get_status_potok_song() ~= 0 then
				local function thetime()
					if timetr[1] < 10 then
						trt = "0"..timetr[1]
					else
						trt = timetr[1]
					end
					if timetr[2] < 10 then
						trt2 = "0"..timetr[2]
					else
						trt2 = timetr[2]
					end
					return trt2..":"..trt
				end
				if select_music == 0 then
					local sizeXline = (timetr[2]*60+timetr[1])*(timetri/2)
					if sizeXline > 200 then
						sizeXline = 200
					end
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + sizeXline, p.y + 5), imgui.GetColorU32(imgui.ImVec4(0.05, 0.45, 0.67 ,0.90)), 100, 15)
					imgui.SetCursorPos(imgui.ImVec2(296, 48))
					imgui.TextColoredRGB("{FFFFFF}"..thetime())
				else
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 200, p.y + 5), imgui.GetColorU32(imgui.ImVec4(0.05, 0.45, 0.67 ,0.90)), 100, 15)
				end
			else
				imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x, p.y + 5), imgui.GetColorU32(imgui.ImVec4(1.00, 1.00, 1.00 ,0.50)), 100, 15)
			end
			imgui.PushFont(fa_font_mus)
			if status_track_pl == "PAUSE" or status_track_pl == "STOP" then
				if select_music == 0 then
					imgui.SetCursorPos(imgui.ImVec2(17, 5))
					local p = imgui.GetCursorScreenPos()
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 60, p.y + 60), imgui.GetColorU32(imgui.ImVec4(0.00, 0.00, 0.00 ,0.50)))
					imgui.SetCursorPos(imgui.ImVec2(33, 17))
					imgui.TextColored(imgui.ImVec4(1.0, 1.00, 1.00 ,0.85), fa.ICON_PAUSE_CIRCLE_O)
				else
					imgui.SetCursorPos(imgui.ImVec2(30, 18))
					imgui.TextColored(imgui.ImVec4(1.0, 1.00, 1.00 ,0.85), fa.ICON_PAUSE_CIRCLE_O)
				end
			end
			imgui.PopFont()
			if anim_hud_tr[1] <= 1 then
				active_anim_hud[1] = true
			elseif anim_hud_tr[1] >= 11 then
				active_anim_hud[1] = false
			end
			if anim_hud_tr[2] <= 1 then
				active_anim_hud[2] = true
			elseif anim_hud_tr[2] >= 11 then
				active_anim_hud[2] = false
			end
			if anim_hud_tr[3] <= 1 then
				active_anim_hud[3] = true
			elseif anim_hud_tr[3] >= 11 then
				active_anim_hud[3] = false
			end
			if status_track_pl == 'PLAY' then
				if active_anim_hud[1] then
					anim_hud_tr[1] = anim_hud_tr[1] + 0.1
				else
					anim_hud_tr[1] = anim_hud_tr[1] - 0.1
				end
				if active_anim_hud[2] then
					anim_hud_tr[2] = anim_hud_tr[2] + 0.25
				else
					anim_hud_tr[2] = anim_hud_tr[2] - 0.25
				end
				if active_anim_hud[3] then
					anim_hud_tr[3] = anim_hud_tr[3] + 0.17
				else
					anim_hud_tr[3] = anim_hud_tr[3] - 0.17
				end
			end
			imgui.SetCursorPos(imgui.ImVec2(272, 48))
			local p = imgui.GetCursorScreenPos()
	--[[]]	imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 3, p.y + -anim_hud_tr[1]), imgui.GetColorU32(imgui.ImVec4(1.00, 1.00, 1.00 ,0.90)))
			
			imgui.SetCursorPos(imgui.ImVec2(277, 48))
			local p = imgui.GetCursorScreenPos()
	--[[]]	imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 3, p.y + -anim_hud_tr[2]), imgui.GetColorU32(imgui.ImVec4(1.00, 1.00, 1.00 ,0.90)))
			
			imgui.SetCursorPos(imgui.ImVec2(282, 48))
			local p = imgui.GetCursorScreenPos()
	--[[]]	imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 3, p.y + -anim_hud_tr[3]), imgui.GetColorU32(imgui.ImVec4(1.00, 1.00, 1.00 ,0.90)))
			imgui.End()
			imgui.PopStyleColor()
		end
    end
	if iconwin.v then
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowSize(imgui.ImVec2(250, 900), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin("Icons ", iconwin, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize);
			for i,v in pairs(fa) do
				if imgui.Button(fa[i].." - "..i, imgui.ImVec2(200, 25)) then setClipboardText(i) end
			end
			
		imgui.End()
	
	end
	
	if actingOutWind.v then 
	local function ButtonMinPl(iv, effect, parvararg)
		if parvararg == "arg" then
			if effect == "remove" then
				imgui.SetCursorPos(imgui.ImVec2(15, 35 + (iv*30)))
				if imgui.InvisibleButton(iv.. u8"##CreateFunct", imgui.ImVec2(15, 8)) then
					table.remove(acting_buf.arg, iv)
				end
				imgui.SetCursorPos(imgui.ImVec2(17, 32 + (iv*30)))
				if imgui.IsItemHovered() then
					imgui.TextColored(imgui.ImVec4(1.0, 0.56, 0.64 ,1.00), fa.ICON_MINUS)
				else
					imgui.Text(fa.ICON_MINUS)
				end
			else
				imgui.SetCursorPos(imgui.ImVec2(17, 32 + ((#acting_buf.arg + 1)*30)))
				if #acting_buf.arg <= 4 then
					if imgui.InvisibleButton(u8"##CreateFunctAdd", imgui.ImVec2(100, 30)) then
						table.insert(acting_buf.arg, (#acting_buf.arg + 1), {imgui.ImInt(0), imgui.ImBuffer(u8"Параметр "..#acting_buf.arg, 128)})
					end
					imgui.SetCursorPos(imgui.ImVec2(17, 32 + ((#acting_buf.arg+1)*30)))
					local p = imgui.GetCursorScreenPos()
					if imgui.IsItemHovered() and not imgui.IsItemActive() then
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 100, p.y + 30), imgui.GetColorU32(imgui.ImVec4(0.45, 0.45, 0.45 ,1.00)), 10, 15)
					elseif imgui.IsItemActive() then
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 100, p.y + 30), imgui.GetColorU32(imgui.ImVec4(0.25, 0.25, 0.25 ,1.00)), 10, 15)
					else
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 100, p.y + 30), imgui.GetColorU32(imgui.ImVec4(0.40, 0.40, 0.40 ,1.00)), 10, 15)
					end
				else
					imgui.SetCursorPos(imgui.ImVec2(17, 32 + ((#acting_buf.arg+1)*30)))
					local p = imgui.GetCursorScreenPos()
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 100, p.y + 30), imgui.GetColorU32(imgui.ImVec4(0.25, 0.25, 0.25 ,1.00)), 10, 15)
				end
				imgui.SetCursorPos(imgui.ImVec2(35, 38 + ((#acting_buf.arg+1)*30)))
				if #acting_buf.arg <= 4 then
					imgui.Text(u8"Добавить")
				else
					imgui.TextColored(imgui.ImVec4(1.00, 1.00, 1.00 ,0.50), u8"Добавить")
				end
			end
		else
			if effect == "remove" then
				if acting_buf.argfunc.v then
					imgui.SetCursorPos(imgui.ImVec2(557, 35 + (iv*30)))
				else
					imgui.SetCursorPos(imgui.ImVec2(15, 35 + (iv*30)))
				end
				if imgui.InvisibleButton(iv.. u8"##CreateFunct2", imgui.ImVec2(15, 8)) then
					table.remove(acting_buf.var, iv)
					variab = {}
					for j = 1, #acting_buf.var do
						variab[j] = "{var"..j.."}"
					end
					for j = 1, #acting_buf.typeAct do
						if acting_buf.typeAct[j][1].v == 4 and acting_buf.typeAct[j][2].v == #acting_buf.var then
							acting_buf.typeAct[j][2].v = acting_buf.typeAct[j][2].v - 1
						end
					end
				end
				if acting_buf.argfunc.v then
					imgui.SetCursorPos(imgui.ImVec2(559, 32 + (iv*30)))
				else
					imgui.SetCursorPos(imgui.ImVec2(17, 32 + (iv*30)))
				end
				if imgui.IsItemHovered() then
					imgui.TextColored(imgui.ImVec4(1.0, 0.56, 0.64 ,1.00), fa.ICON_MINUS)
				else
					imgui.Text(fa.ICON_MINUS)
				end
			else
				if acting_buf.argfunc.v then
					imgui.SetCursorPos(imgui.ImVec2(559, 32 + ((#acting_buf.var + 1)*30)))
				else
					imgui.SetCursorPos(imgui.ImVec2(17, 32 + ((#acting_buf.var + 1)*30)))
				end
				if #acting_buf.var <= 19 then
					if imgui.InvisibleButton(u8"##CreateFunctAdd2", imgui.ImVec2(100, 30)) then
						table.insert(acting_buf.var, (#acting_buf.var + 1), imgui.ImBuffer(u8"", 128))
						for j = 1, #acting_buf.var do
							variab[j] = "{var"..j.."}"
						end
					end
					if acting_buf.argfunc.v then 
						imgui.SetCursorPos(imgui.ImVec2(559, 32 + ((#acting_buf.var+1)*30)))
					else
						imgui.SetCursorPos(imgui.ImVec2(17, 32 + ((#acting_buf.var+1)*30)))
					end
					local p = imgui.GetCursorScreenPos()
					if imgui.IsItemHovered() and not imgui.IsItemActive() then
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 100, p.y + 30), imgui.GetColorU32(imgui.ImVec4(0.45, 0.45, 0.45 ,1.00)), 10, 15)
					elseif imgui.IsItemActive() then
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 100, p.y + 30), imgui.GetColorU32(imgui.ImVec4(0.25, 0.25, 0.25 ,1.00)), 10, 15)
					else
						imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 100, p.y + 30), imgui.GetColorU32(imgui.ImVec4(0.40, 0.40, 0.40 ,1.00)), 10, 15)
					end
				else
					if acting_buf.argfunc.v then  
						imgui.SetCursorPos(imgui.ImVec2(559, 32 + ((#acting_buf.var+1)*30)))
					else
						imgui.SetCursorPos(imgui.ImVec2(17, 32 + ((#acting_buf.var+1)*30)))
					end
					local p = imgui.GetCursorScreenPos()
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 100, p.y + 30), imgui.GetColorU32(imgui.ImVec4(0.25, 0.25, 0.25 ,1.00)), 10, 15)
				end
				if acting_buf.argfunc.v then  
					imgui.SetCursorPos(imgui.ImVec2(577, 38 + ((#acting_buf.var+1)*30)))
				else
					imgui.SetCursorPos(imgui.ImVec2(35, 38 + ((#acting_buf.var+1)*30)))
				end
				if #acting_buf.var <= 19 then
					imgui.Text(u8"Добавить")
				else
					imgui.TextColored(imgui.ImVec4(1.00, 1.00, 1.00 ,0.50), u8"Добавить")
				end
			end
		end
	end
	local function ButtomPosition(parx, pary)
		if acting_buf.argfunc.v and acting_buf.varfunc.v then
			if #acting_buf.arg >= #acting_buf.var then
				imgui.SetCursorPos(imgui.ImVec2(parx, pary + ((#acting_buf.typeAct + 1) * 40) + (#acting_buf.arg * 30)))
			elseif #acting_buf.var >= #acting_buf.arg then
				imgui.SetCursorPos(imgui.ImVec2(parx, pary + ((#acting_buf.typeAct + 1) * 40) + (#acting_buf.var * 30)))
			end
			elseif acting_buf.argfunc.v then
				imgui.SetCursorPos(imgui.ImVec2(parx, pary + ((#acting_buf.typeAct + 1) * 40) + (#acting_buf.arg * 30)))
			elseif acting_buf.varfunc.v then 
				imgui.SetCursorPos(imgui.ImVec2(parx, pary + ((#acting_buf.typeAct + 1) * 40) + (#acting_buf.var * 30)))
			else
				imgui.SetCursorPos(imgui.ImVec2(parx, pary - 75 + ((#acting_buf.typeAct + 1) * 40)))
		end
	end
	local function ButtonRemAdd()
		if #acting_buf.typeAct <= 99 then
			ButtomPosition(15, 175)
			if imgui.InvisibleButton(u8"##NewTypeAdd", imgui.ImVec2(100, 30)) then
				table.insert(acting_buf.typeAct, (#acting_buf.typeAct + 1), {imgui.ImInt(0), imgui.ImBuffer(u8"", 1024)})
			end
			ButtomPosition(15, 175)
			local p = imgui.GetCursorScreenPos()
			if imgui.IsItemHovered() and not imgui.IsItemActive() then
				imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 100, p.y + 30), imgui.GetColorU32(imgui.ImVec4(0.45, 0.45, 0.45 ,1.00)), 10, 15)
			elseif imgui.IsItemActive() then
				imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 100, p.y + 30), imgui.GetColorU32(imgui.ImVec4(0.25, 0.25, 0.25 ,1.00)), 10, 15)
			else
				imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 100, p.y + 30), imgui.GetColorU32(imgui.ImVec4(0.40, 0.40, 0.40 ,1.00)), 10, 15)
			end
		else
			ButtomPosition(15, 175)
			local p = imgui.GetCursorScreenPos()
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 100, p.y + 30), imgui.GetColorU32(imgui.ImVec4(0.25, 0.25, 0.25 ,1.00)), 10, 15)
		end
		
		if #acting_buf.typeAct <= 99 then
			ButtomPosition(31, 180)
			imgui.Text(u8"Добавить")
		else
			ButtomPosition(31, 180)
			imgui.TextColored(imgui.ImVec4(1.00, 1.00, 1.00 ,0.50), u8"Добавить")
		end
	end
	local function waitvar()
		local param = round(acting_buf.sec.v, 0.1)
		return tostring(param)
	end
	local sw, sh = getScreenResolution()
		imgui.SetNextWindowSize(imgui.ImVec2(1100, 580), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		
		imgui.Begin(u8"MH | Редактирование отыгровки", actingOutWind, imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoScrollbar);
		imgui.SetCursorPosX(430)
			imgui.PushFont(fontsize)
			imgui.SetCursorPosY(6)
			imgui.Text(u8"Редактирование отыгровки")
			imgui.PopFont()
			imgui.SameLine()
			imgui.SetCursorPosX(1070)
			imgui.SetCursorPosY(6)
			if imgui.InvisibleButton(u8" ", imgui.ImVec2(24, 24)) or animka_sob.paramOff then 
				actingOutWind.v = false
			end
			if imgui.IsItemHovered() then
				imgui.SameLine()
				imgui.SetCursorPosX(1075)
				imgui.SetCursorPosY(3)
				imgui.PushFont(fa_font2)
				imgui.TextColored(imgui.ImVec4(1.0, 0.56, 0.64 ,1.00), fa.ICON_TIMES)
				imgui.PopFont()
			else
				imgui.SameLine()
				imgui.SetCursorPosX(1075)
				imgui.SetCursorPosY(3)
				imgui.PushFont(fa_font2)
				imgui.Text(fa.ICON_TIMES)
				imgui.PopFont()
			end
			imgui.Separator()
			imgui.Dummy(imgui.ImVec2(0, 1))
			imgui.BeginChild("RedactorActingOut", imgui.ImVec2(1085, 496), false, imgui.WindowFlags.NoScrollbar)
			imgui.SetCursorPos(imgui.ImVec2(5, 5))
			local p = imgui.GetCursorScreenPos()
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 1074, p.y + 30), imgui.GetColorU32(imgui.ImVec4(0.15, 0.15, 0.15 ,1.00)), 10, 15)
			imgui.SetWindowFontScale(1.1)
			imgui.SetCursorPos(imgui.ImVec2(300, 7))
			if ButtonSwitch(u8" Использовать аргументы", acting_buf.argfunc) then end
			imgui.SetCursorPos(imgui.ImVec2(540, 7))
			if ButtonSwitch(u8" Использовать переменные", acting_buf.varfunc) then end
			if acting_buf.argfunc.v then
				imgui.SetCursorPos(imgui.ImVec2(5, 45))
				local p = imgui.GetCursorScreenPos()
				if acting_buf.varfunc.v then
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 532, p.y + 63 + (#acting_buf.arg*30)), imgui.GetColorU32(imgui.ImVec4(0.15, 0.15, 0.15 ,1.00)), 10, 15)
				else
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 1074, p.y + 63 + (#acting_buf.arg*30)), imgui.GetColorU32(imgui.ImVec4(0.15, 0.15, 0.15 ,1.00)), 10, 15)
				end
				for i = 1, #acting_buf.arg do
					ButtonMinPl(i, "remove", "arg")
					imgui.SetCursorPos(imgui.ImVec2(37, 30 + (i*30)))
					imgui.Text(i.. u8" Арг.  ")
					imgui.SameLine()
					imgui.PushItemWidth(180)
					if acting_buf.arg[i] ~= nil then
						if imgui.Combo(u8"##TypeVariable"..i, acting_buf.arg[i][1], arg_options) then end
					end
					imgui.PopItemWidth()
					imgui.SameLine()
					imgui.TextColoredRGB("  Аргументу присвоен тег {E6BA39}{arg"..i.."}")
				end
				ButtonMinPl(i, "create", "arg")
			end
			if acting_buf.varfunc.v then
				if acting_buf.argfunc.v then
					imgui.SetCursorPos(imgui.ImVec2(547, 45))
				else
					imgui.SetCursorPos(imgui.ImVec2(5, 45))
				end
				local p = imgui.GetCursorScreenPos()
				if acting_buf.argfunc.v then
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 532, p.y + 63 + (#acting_buf.var*30)), imgui.GetColorU32(imgui.ImVec4(0.15, 0.15, 0.15 ,1.00)), 10, 15)
				else
					imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 1074, p.y + 63 + (#acting_buf.var*30)), imgui.GetColorU32(imgui.ImVec4(0.15, 0.15, 0.15 ,1.00)), 10, 15)
				end
				for i = 1, #acting_buf.var do
					ButtonMinPl(i, "remove", "var")
					if not acting_buf.argfunc.v then
						imgui.SetCursorPos(imgui.ImVec2(37, 30 + (i*30)))
					else
						imgui.SetCursorPos(imgui.ImVec2(579, 30 + (i*30)))
					end
					imgui.Text(i.. u8" Пер.  ")
					imgui.SameLine()
					imgui.PushItemWidth(140)
					if acting_buf.var[i] ~= nil then
						if imgui.InputText(u8"##TextVariable"..i, acting_buf.var[i], type_options) then end
					end
					imgui.PopItemWidth()
					imgui.SameLine()
					imgui.TextColoredRGB(" Значение переменной с тегом {E6BA39}{var"..i.."}")
				end
				ButtonMinPl(i, "create", "var")
			end
			local function GetPosField()
				local parametrY = 0
				if acting_buf.argfunc.v and acting_buf.varfunc.v then
					if #acting_buf.arg >= #acting_buf.var then
						parametrY = 74 + (#acting_buf.arg * 30)
					elseif #acting_buf.var >= #acting_buf.arg then
						parametrY = 74 + (#acting_buf.var * 30)
					end
				elseif acting_buf.argfunc.v then
					parametrY = 74 + (#acting_buf.arg * 30)
				elseif acting_buf.varfunc.v then 
					parametrY = 74 + (#acting_buf.var * 30)
				else
					parametrY = 0
				end
				return parametrY
			end
			local function find_last_index(array, element)
				local index = 0
				for i = 1, #array do
					if array[i][1].v == element then
						index = i
					end
				end
				return index
			end
			imgui.SetCursorPos(imgui.ImVec2(5, 44 + GetPosField()))
			local p = imgui.GetCursorScreenPos()
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 1074, p.y + 68), imgui.GetColorU32(imgui.ImVec4(0.15, 0.15, 0.15 ,1.00)), 10, 15)
			imgui.SetCursorPos(imgui.ImVec2(16, 78 + GetPosField()))
			imgui.PushItemWidth(150)
			imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImColor(0, 0, 0, 0):GetVec4())
			imgui.PushStyleColor(imgui.Col.SliderGrab, imgui.ImColor(0, 0, 0, 0):GetVec4())
			imgui.PushStyleColor(imgui.Col.SliderGrabActive, imgui.ImColor(0, 0, 0, 0):GetVec4())
			if imgui.SliderFloat(u8"##Задержка проигрывания отыгровки", acting_buf.sec, 1, 10, u8"") then 
			
			end
			imgui.PopStyleColor(3)
			imgui.PopItemWidth()
			imgui.SetCursorPos(imgui.ImVec2(68, 55 + GetPosField()))
			imgui.Text(waitvar()..u8" сек.")
			imgui.SetCursorPos(imgui.ImVec2(16, 86 + GetPosField()))
			local p = imgui.GetCursorScreenPos()
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 140, p.y + 5), imgui.GetColorU32(imgui.ImVec4(1.00, 1.00, 1.00 ,0.50)), 10, 15)
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + (acting_buf.sec.v*14), p.y + 5), imgui.GetColorU32(imgui.ImVec4(0.11, 0.60, 0.88 ,1.00)), 10, 15)
			imgui.GetWindowDrawList():AddCircleFilled(imgui.ImVec2(p.x + (acting_buf.sec.v*14), p.y + 2), 9, imgui.GetColorU32(imgui.ImVec4(1.00, 1.00, 1.00 ,1.00)))
			imgui.SetCursorPos(imgui.ImVec2(166, 79 + GetPosField()))
			imgui.TextColoredRGB(" Задержка проигрывания отыгровки")
			if acting_buf.sec.v < 1.8 then
				imgui.SameLine()
				imgui.TextColored(imgui.ImVec4(0.86, 0.18, 0.18, 1.00), u8"   Внимание! Из-за такого низкого значения возможно появление сообщения \"Не флуди!\"")
			end
			imgui.SetCursorPos(imgui.ImVec2(5, 123 + GetPosField()))
			local p = imgui.GetCursorScreenPos()
			imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 1074, p.y + 60 + (#acting_buf.typeAct * 40)), imgui.GetColorU32(imgui.ImVec4(0.15, 0.15, 0.15 ,1.00)), 10, 15)
			
			for c = 1, #acting_buf.typeAct do
				local pd = c
				if acting_buf.argfunc.v and acting_buf.varfunc.v then
					if #acting_buf.arg >= #acting_buf.var and acting_buf.argfunc.v then
						imgui.SetCursorPos(imgui.ImVec2(15, 175 + (pd * 40) + (#acting_buf.arg * 30)))
						parsic = 175 + (pd * 40) + (#acting_buf.arg * 30)
					elseif #acting_buf.var >= #acting_buf.arg and acting_buf.varfunc.v then
						imgui.SetCursorPos(imgui.ImVec2(15, 175 + (pd * 40) + (#acting_buf.var * 30)))
						parsic = 175 + (pd * 40) + (#acting_buf.var * 30)
					end
				elseif acting_buf.argfunc.v then
					imgui.SetCursorPos(imgui.ImVec2(15, 175 + (pd * 40) + (#acting_buf.arg * 30)))
					parsic = 175 + (pd * 40) + (#acting_buf.arg * 30)
				elseif acting_buf.varfunc.v then 
					imgui.SetCursorPos(imgui.ImVec2(15, 175 + (pd * 40) + (#acting_buf.var * 30)))
					parsic = 175 + (pd * 40) + (#acting_buf.var * 30)
				else
					imgui.SetCursorPos(imgui.ImVec2(15, 100 + (pd * 40)))
					parsic = 100 + (pd * 40)
				end
				imgui.Text(pd.. u8".  ")
				imgui.SameLine()
				local trush = fa.ICON_TRASH
				imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(70, 70, 70, 0):GetVec4())
				imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(70, 70, 70, 0):GetVec4())
				imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(70, 70, 70, 0):GetVec4())
				if imgui.Button(trush..u8"##"..pd, imgui.ImVec2(21, 21)) then 
					table.remove(acting_buf.typeAct, pd)
				end
				imgui.PopStyleColor(3)
				imgui.SameLine()
				imgui.PushItemWidth(220)
				if acting_buf.typeAct[c] ~= nil then
					if imgui.Combo(u8"##ComboType"..pd, acting_buf.typeAct[c][1], type_options) then
						if acting_buf.typeAct[c][1].v ~= 2 and acting_buf.typeAct[c][1].v ~= 4 then
							acting_buf.typeAct[c][2] = imgui.ImBuffer(u8"", 1024)
						elseif acting_buf.typeAct[c][1].v == 2 then
							acting_buf.typeAct[c][2] = {imgui.ImBuffer(u8"Действие1", 128)}
						elseif acting_buf.typeAct[c][1].v == 4 then
							acting_buf.typeAct[c][2] = imgui.ImInt(0)
							acting_buf.typeAct[c][3] = imgui.ImBuffer(128)
						end
					end
					imgui.PopItemWidth()
					if acting_buf.typeAct[c][1].v == 0 then
						imgui.SameLine()
						imgui.Text(u8"  Текст отыгровки ")
						imgui.SameLine()
						imgui.PushItemWidth(630)
						if imgui.InputText(u8"##Text"..pd, acting_buf.typeAct[c][2]) then end
						imgui.PopItemWidth()
						if find_last_index(acting_buf.typeAct, 0) == c then
							if acting_buf.argfunc.v and acting_buf.varfunc.v then
								if #acting_buf.arg >= #acting_buf.var and acting_buf.argfunc.v then
									imgui.SetCursorPos(imgui.ImVec2(130, 178 + ((#acting_buf.typeAct + 1) * 40) + (#acting_buf.arg * 30)))
								elseif #acting_buf.var >= #acting_buf.arg and acting_buf.varfunc.v then
									imgui.SetCursorPos(imgui.ImVec2(130, 178 + ((#acting_buf.typeAct + 1) * 40) + (#acting_buf.var * 30)))
								end
							elseif acting_buf.argfunc.v then
								imgui.SetCursorPos(imgui.ImVec2(130, 178 + ((#acting_buf.typeAct + 1) * 40) + (#acting_buf.arg * 30)))
							elseif acting_buf.varfunc.v then 
								imgui.SetCursorPos(imgui.ImVec2(130, 178 + ((#acting_buf.typeAct + 1) * 40) + (#acting_buf.var * 30)))
							else
								imgui.SetCursorPos(imgui.ImVec2(130, 103 + ((#acting_buf.typeAct + 1) * 40)))
							end
							if ButtonSwitch(u8" Не отправлять последнее сообщение в чат", acting_buf.chatopen) then end
						end
					end
					if acting_buf.typeAct[c][1].v == 1 and acting_buf.typeAct[c] ~= nil then
						imgui.SameLine()
						imgui.Text(u8"  Отыгровка продолжится после нажатия клавиши Enter.")
					end
					if acting_buf.typeAct[c][1].v == 2 and acting_buf.typeAct[c] ~= nil then
						imgui.SetCursorPos(imgui.ImVec2(302, parsic - 1))
						if imgui.InvisibleButton(u8"##EditDialogAct"..pd, imgui.ImVec2(367, 25)) then 
							imgui.OpenPopup(u8"Редактирование диалогов")
							popumodDialog = pd
						end
						imgui.SetCursorPos(imgui.ImVec2(302, parsic - 1))
						local p = imgui.GetCursorScreenPos()
						if imgui.IsItemHovered() and not imgui.IsItemActive() then
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 367, p.y + 25), imgui.GetColorU32(imgui.ImVec4(0.45, 0.45, 0.45 ,1.00)), 8, 15)
						elseif imgui.IsItemActive() then
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 367, p.y + 25), imgui.GetColorU32(imgui.ImVec4(0.25, 0.25, 0.25 ,1.00)), 8, 15)
						else
							imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 367, p.y + 25), imgui.GetColorU32(imgui.ImVec4(0.40, 0.40, 0.40 ,1.00)), 8, 15)
						end
						imgui.SetCursorPos(imgui.ImVec2(314, 2 + parsic))
						imgui.Text(u8"Редактировать количество и названия диалогов     (Кол-во диалогов: ".. #acting_buf.typeAct[c][2].. ")")
					end
					if acting_buf.typeAct[c][1].v == 3 and acting_buf.typeAct[c] ~= nil then
						imgui.SameLine()
						imgui.Text(u8"  Текст сообщения ")
						imgui.SameLine()
						imgui.PushItemWidth(630)
						if imgui.InputText(u8"##Text"..pd, acting_buf.typeAct[c][2]) then end
						imgui.PopItemWidth()
					end
					if acting_buf.typeAct[c][1].v == 4 and acting_buf.typeAct[c] ~= nil then
						imgui.SameLine()
						if acting_buf.varfunc.v and #acting_buf.var ~= 0 then
							imgui.Text(u8"  Выберите переменную ")
							imgui.SameLine()
							imgui.PushItemWidth(90)
							if imgui.Combo(u8"##VarEdit"..pd, acting_buf.typeAct[c][2], variab) then end
							imgui.SameLine()
							imgui.Text(u8"  Введите новое значение переменной ")
							imgui.SameLine()
							imgui.PushItemWidth(180)
							if imgui.InputText(u8"##variabname"..pd, acting_buf.typeAct[c][3]) then end
						else
							imgui.Text(u8"  Фукнция переменных отключена или они отсутствуют.")
						end
					end
				end
			end
			if acting_buf.argfunc.v and acting_buf.varfunc.v then
				if #acting_buf.arg >= #acting_buf.var and acting_buf.argfunc.v then
					imgui.SetCursorPos(imgui.ImVec2(15, 175 + ((#acting_buf.typeAct + 1) * 40) + (#acting_buf.arg * 30)))
				elseif #acting_buf.var >= #acting_buf.arg and acting_buf.varfunc.v then
					imgui.SetCursorPos(imgui.ImVec2(15, 175 + ((#acting_buf.typeAct + 1) * 40) + (#acting_buf.var * 30)))
				end
			elseif acting_buf.argfunc.v then
				imgui.SetCursorPos(imgui.ImVec2(15, 175 + ((#acting_buf.typeAct + 1) * 40) + (#acting_buf.arg * 30)))
			elseif acting_buf.varfunc.v then 
				imgui.SetCursorPos(imgui.ImVec2(15, 175 + ((#acting_buf.typeAct + 1) * 40) + (#acting_buf.var * 30)))
			else
				imgui.SetCursorPos(imgui.ImVec2(15, 100 + ((#acting_buf.typeAct + 1) * 40)))
			end
			ButtonRemAdd()
			imgui.Dummy(imgui.ImVec2(0, 20)) 
			if imgui.BeginPopupModal(u8"Редактирование диалогов", null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar) then
				imgui.SetCursorPosX(140)
				imgui.PushFont(fontsize)
				imgui.SetCursorPosY(6)
				imgui.Text(u8"Редактирование диалога")
				imgui.SameLine()
				ShowHelpMarker(u8"Во время отыгровки, когда начинается данная функция диалогов,\nВам доступен выбор дальнейших действий.\n\nНиже Вы выбираете количество диалогов и их название для удобства.\nКаждому диалогу присваивается свой тег.\n\nДля того, чтобы после нажатия клавиши начался нужный диалог,\nв текст отыгровки после выбора этой функции вставляйте тег диалога\nв любое место строки \"Отправить сообщение в чат\".\n\nЕсли следующее действие \"Отправка сообщения в чат\" не будет иметь в себе\nтег диалога, то действие функции обнуляется.\n\nЧтобы обнулить действие диалога без отправки сообщения в чат,\nпросто оставьте строку пустой.")
				imgui.PopFont()
				imgui.Separator()
				imgui.Dummy(imgui.ImVec2(0, 1))
				for i = 1, #acting_buf.typeAct[popumodDialog][2] do
					imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(70, 70, 70, 0):GetVec4())
					imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(70, 70, 70, 0):GetVec4())
					imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(70, 70, 70, 0):GetVec4())
					if imgui.Button(fa.ICON_TRASH..u8"##12"..i, imgui.ImVec2(21, 21)) then 
						table.remove(acting_buf.typeAct[popumodDialog][2], i)
					end
					imgui.PopStyleColor(3)
					if acting_buf.typeAct[popumodDialog][2][i] ~= nil then
						imgui.SameLine()
						imgui.Text(u8" Имя "..i..u8" диалога  ")
						imgui.SameLine()
						imgui.PushItemWidth(150)
						if imgui.InputText(u8"##TextDialogTest"..i, acting_buf.typeAct[popumodDialog][2][i]) then end
						imgui.PopItemWidth()
						imgui.SameLine()
						imgui.TextColoredRGB(" Тег диалога - {E6BA39}{Dialog"..i.."}{FFFFFF} ")
					end
				end
				imgui.Dummy(imgui.ImVec2(0, 3))
				if imgui.Button(u8"Добавить диалог", imgui.ImVec2(140, 25)) then 
					if #acting_buf.typeAct[popumodDialog][2] < 8 then
						table.insert(acting_buf.typeAct[popumodDialog][2], (#acting_buf.typeAct[popumodDialog][2] + 1), imgui.ImBuffer(u8"Действие"..#acting_buf.typeAct[popumodDialog][2] + 1, 128))
					end
				end
				if #acting_buf.typeAct[popumodDialog][2] >= 8 then
					imgui.SameLine()
					imgui.TextColoredRGB("  {d42629}Больше восьми нельзя!")
				end
				imgui.Dummy(imgui.ImVec2(0, 3))
				imgui.Separator()
				imgui.Dummy(imgui.ImVec2(0, 3))
				imgui.Text(u8'Как это будет выглядеть:')
				imgui.TextColoredRGB('{1dcc25}Для продолжения выберите действие:')
				for i = 1, #acting_buf.typeAct[popumodDialog][2] do
					imgui.TextColoredRGB('{cca61d}[Num '..i.."]{FFFFFF} - "..u8:decode(acting_buf.typeAct[popumodDialog][2][i].v))
					if i > 1 then
						imgui.Text("...")
						break
					end
				end
				imgui.Dummy(imgui.ImVec2(0, 3))
				imgui.Separator()
				imgui.Dummy(imgui.ImVec2(0, 3))
				if imgui.Button(u8"Применить", imgui.ImVec2(440, 25)) then imgui.CloseCurrentPopup() end
			imgui.EndPopup()
			end
			imgui.EndChild()
			imgui.Dummy(imgui.ImVec2(0, 1))
			imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(102, 102, 102, 255):GetVec4())
			imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(77, 77, 77, 255):GetVec4())
			imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(115, 115, 115, 255):GetVec4())
			if imgui.Button(u8"Сохранить##svag", imgui.ImVec2(357, 25)) then
				acting[selected_cmd] = {argfunc = false, arg = {}, varfunc = false, var = {}, chatopen = false, typeAct = {}, sec = 2.0}
				acting[selected_cmd].argfunc = acting_buf.argfunc.v
				acting[selected_cmd].varfunc = acting_buf.varfunc.v
				acting[selected_cmd].sec = acting_buf.sec.v
				acting[selected_cmd].chatopen = acting_buf.chatopen.v
				for k = 1, #acting_buf.typeAct do
					if acting_buf.typeAct[k][1].v ~= 2 and acting_buf.typeAct[k][1].v ~= 4 then
						acting[selected_cmd].typeAct[k] = {acting_buf.typeAct[k][1].v, acting_buf.typeAct[k][2].v}
					elseif acting_buf.typeAct[k][1].v == 2 then
						acting[selected_cmd].typeAct[k] = {acting_buf.typeAct[k][1].v, {}}
						for m = 1, #acting_buf.typeAct[k][2] do
							local mems = m
							table.insert(acting[selected_cmd].typeAct[k][2], mems, acting_buf.typeAct[k][2][m].v)
						end
					elseif acting_buf.typeAct[k][1].v == 4 then
						acting[selected_cmd].typeAct[k] = {acting_buf.typeAct[k][1].v, acting_buf.typeAct[k][2].v, acting_buf.typeAct[k][3].v}
					end
				end
				for k = 1, #acting_buf.arg do
					acting[selected_cmd].arg[k] = {acting_buf.arg[k][1].v, acting_buf.arg[k][2].v}
				end
				for k = 1, #acting_buf.var do
					acting[selected_cmd].var[k] = acting_buf.var[k].v
				end
				local f = io.open(dirml.."/MedicalHelper/Отыгровки команд.med", "w")
				f:write(encodeJson(acting))
				f:flush()
				f:close()
				actingOutWind.v = false
			end
			imgui.SameLine()
			if imgui.Button(u8"Сбросить до дефолта##svag", imgui.ImVec2(357, 25)) then 
				acting[selected_cmd] = acting_defoult[selected_cmd]
				acting_buf = {argfunc = imgui.ImBool(false), arg = {}, varfunc = imgui.ImBool(false), var = {},  
					chatopen = imgui.ImBool(false),	typeAct = {}, sec = imgui.ImFloat(1.0)}
					
					acting_buf.argfunc.v = acting[selected_cmd].argfunc
					acting_buf.varfunc.v = acting[selected_cmd].varfunc
					acting_buf.sec.v = acting[selected_cmd].sec
					acting_buf.chatopen.v = acting[selected_cmd].chatopen
					variab = {}
				for k = 1, #acting[selected_cmd].typeAct do
					if acting[selected_cmd].typeAct[k][1] ~= 2 and acting[selected_cmd].typeAct[k][1] ~= 4 then
						acting_buf.typeAct[k] = {imgui.ImInt(0), imgui.ImBuffer(acting[selected_cmd].typeAct[k][2], 1024)}
						acting_buf.typeAct[k][1].v = acting[selected_cmd].typeAct[k][1]
					elseif acting[selected_cmd].typeAct[k][1] == 2 then
						acting_buf.typeAct[k] = {imgui.ImInt(0), {}}
						acting_buf.typeAct[k][1].v = acting[selected_cmd].typeAct[k][1]
						for m = 1, #acting[selected_cmd].typeAct[k][2] do
							acting_buf.typeAct[k][2][m] = imgui.ImBuffer(1024)
							acting_buf.typeAct[k][2][m].v = acting[selected_cmd].typeAct[k][2][m]
						end
					elseif acting[selected_cmd].typeAct[k][1] == 4 then
						acting_buf.typeAct[k] = {imgui.ImInt(0), imgui.ImInt(0), imgui.ImBuffer(128)}
						acting_buf.typeAct[k][1].v = acting[selected_cmd].typeAct[k][1]
						acting_buf.typeAct[k][2].v = acting[selected_cmd].typeAct[k][2]
						acting_buf.typeAct[k][3].v = acting[selected_cmd].typeAct[k][3]
					end
				end
				for k = 1, #acting[selected_cmd].arg do
					acting_buf.arg[k] = {imgui.ImInt(0), imgui.ImBuffer(128)}
					acting_buf.arg[k][1].v = acting[selected_cmd].arg[k][1]
					acting_buf.arg[k][2].v = acting[selected_cmd].arg[k][2]
				end
				for k = 1, #acting[selected_cmd].var do
					acting_buf.var[k] = imgui.ImBuffer(128)
					acting_buf.var[k].v = acting[selected_cmd].var[k]
					variab[k] = "{var"..k.."}"
				end
			end
			imgui.SameLine()
			if imgui.Button(u8"Закрыть не сохраняя##svag", imgui.ImVec2(357, 25)) then 
				actingOutWind.v = false
			end
			imgui.PopStyleColor(3)
	imgui.Dummy(imgui.ImVec2(0, 5))
		imgui.End()
	end
		
	if paramWin.v then
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowSize(imgui.ImVec2(820, 580), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		
		imgui.Begin(u8"Код-параметры для биндера", paramWin, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize);
		imgui.SetWindowFontScale(1.1)
		imgui.SetCursorPosX(50)
		imgui.TextColoredRGB("[center]{FFFF41}Кликни мышкой по самому тегу, чтобы скопировать его.", imgui.GetMaxWidthByText("Кликни мышкой по самому тегу, чтобы скопировать его."))
		imgui.Dummy(imgui.ImVec2(0, 15))
		
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{myID}")
		imgui.SameLine()
		if imgui.IsItemHovered(0) then setClipboardText("{myID}") end
		imgui.TextColoredRGB("{C1C1C1} - Ваш id - {ACFF36}"..tostring(myid))
		
		imgui.Spacing()	
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{myNick}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then setClipboardText("{myNick}");  end
		imgui.TextColoredRGB("{C1C1C1} - Ваш полный ник (по анг.) - {ACFF36}"..tostring(myNick:gsub("_"," ")))
		
		imgui.Spacing()	
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{myRusNick}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then setClipboardText("{myRusNick}") end
		imgui.TextColoredRGB("{C1C1C1} - Ваш ник, указанный в настройках - {ACFF36}"..tostring(u8:decode(buf_nick.v)))
		
		imgui.Spacing()	
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{myHP}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then setClipboardText("{myHP}") end
		imgui.TextColoredRGB("{C1C1C1} - Ваш уровень ХП - {ACFF36}"..tostring(getCharHealth(PLAYER_PED)))
		
		imgui.Spacing()	
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{myArmo}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then setClipboardText("{myArmo}") end
		imgui.TextColoredRGB("{C1C1C1} - Ваш текущий уровень брони - {ACFF36}"..tostring(getCharArmour(PLAYER_PED)))
		
		imgui.Spacing()	
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{myHosp}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then setClipboardText("{myHosp}") end
		imgui.TextColoredRGB("{C1C1C1} - название Вашей больницы - {ACFF36}"..tostring(u8:decode(chgName.org[num_org.v+1])))
		
		imgui.Spacing()	
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{myHospEn}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then setClipboardText("{myHospEn}") end
		imgui.TextColoredRGB("{C1C1C1} - полное название Вашей больницы на анг. - {ACFF36}"..tostring(u8:decode(list_org_en[num_org.v+1])))
		
		imgui.Spacing()	
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{myTag}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then setClipboardText("{myTag}") end
		imgui.TextColoredRGB("{C1C1C1} - Ваш тег  - {ACFF36}"..tostring(u8:decode(buf_teg.v)))
		
		imgui.Spacing()		
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{myRank}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then setClipboardText("{myRank}") end
		imgui.TextColoredRGB("{C1C1C1} - Ваша должность - {ACFF36}"..tostring(u8:decode(chgName.rank[num_rank.v+1])))
		
		imgui.Spacing()	
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{time}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then setClipboardText("{time}") end
		imgui.TextColoredRGB("{C1C1C1} - время в формате часы:минуты:секунды - {ACFF36}"..tostring(os.date("%X")))
		
		imgui.Spacing()
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{day}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then setClipboardText("{day}") end
		imgui.TextColoredRGB("{C1C1C1} - текущий день месяца - {ACFF36}"..tostring(os.date("%d")))

		imgui.Spacing()
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{week}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then setClipboardText("{week}") end
		imgui.TextColoredRGB("{C1C1C1} - текущая неделя - {ACFF36}"..tostring(week[tonumber(os.date("%w"))+1]))

		imgui.Spacing()
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{month}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then setClipboardText("{month}") end
		imgui.TextColoredRGB("{C1C1C1} - текущий месяц - {ACFF36}"..tostring(month[tonumber(os.date("%m"))]))
		--
		imgui.Spacing()
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{getNickByTarget}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then setClipboardText("{getNickByTarget}") end
		imgui.TextColoredRGB("{C1C1C1} - получает Ник игрока на которого последний раз целился.")
		--
		imgui.Spacing()
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{target}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then setClipboardText("{target}") end
		imgui.TextColoredRGB("{C1C1C1} - последний ID игрока, на которого целился (наведена мышь) - {ACFF36}"..tostring(targID))
		--
		imgui.Spacing()
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{pause}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then setClipboardText("{pause}") end
		imgui.TextColoredRGB("{C1C1C1} - создание паузы между отправки строки в чат. {EC3F3F}Прописывать отдельно, т.е. с новой строки.")
		--
		imgui.Spacing()
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), u8"{sleep:время}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then setClipboardText("{sleep:1000}") end
		imgui.TextColoredRGB("{C1C1C1} - Задаёт свой интервал времени между строчками. \n\tПример: {sleep:2500}, где 2500 время в мс (1 сек = 1000 мс)")

		imgui.Spacing()
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), u8"{sex:текст1|текст2}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then setClipboardText("{sex:text1|text2}") end
		imgui.TextColoredRGB("{C1C1C1} - Возвращает текст в зависимости от выбранного пола.  \n\tПример, {sex:понял|поняла}, вернёт 'понял', если выбран мужской пол или 'поняла', если женский")

		imgui.Spacing()
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), u8"{getNickByID:ид игрока}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then setClipboardText("{getNickByID:}") end
		imgui.TextColoredRGB("{C1C1C1} - Возращает ник игрока по его ID. \n\tПример, {getNickByID:25}, вернёт ник игрока под ID 25.)")
		
		imgui.End()
	end
	
	if spurBig.v then
		if not animka_big.MoveAnim then
			seelB = imgui.Cond.FirstUseEver
		else
			seelB = imgui.Cond.Always
		end
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowSize(imgui.ImVec2(1098, 728), seelB)
		imgui.SetNextWindowPos(imgui.ImVec2(animka_big.posX, animka_big.posY), seelB, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"Редактор Шпаргалки", spurBig, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar);
		imgui.SameLine()
			imgui.SetCursorPosY(4)
			imgui.PushItemWidth(170)
			imgui.InputText("##chatgta", searchtext)
			imgui.SameLine()
			if imgui.Button(u8"Поиск", imgui.ImVec2(100, 23)) then
			plerel = true
				if searchtext.v ~= "" then
					local findStr = 0
					for line in io.lines(dirml.."/MedicalHelper/Шпаргалки/"..spur.list[spur.select_spur]..".txt") do
						findStr = findStr + 1
						if textEndShpora[findStr]:find("{F2FF00}") then
						textEndShpora[findStr] = textEndShpora[findStr]:gsub("{F2FF00}", "")
						end
						if textEndShpora[findStr]:find("{FFFFFF}") then
						textEndShpora[findStr] = textEndShpora[findStr]:gsub("{FFFFFF}", "")
						end
						for textes in line:gmatch(u8:decode(searchtext.v)) do
							perta = "{F2FF00}"..u8:decode(searchtext.v).."{FFFFFF}"
							if textEndShpora[findStr]:find(textes) then
								textEndShpora[findStr] = textEndShpora[findStr]:gsub(textes, perta)
								if textEndShpora[findStr]:find("{F2FF00}{F2FF00}"..textes.."{FFFFFF}{FFFFFF}") then
									textEndShpora[findStr] = textEndShpora[findStr]:gsub("{F2FF00}{F2FF00}"..textes.."{FFFFFF}{FFFFFF}", "{F2FF00}"..textes.."{FFFFFF}")
								end
							end
						end
					end	
				else
					for i, v in ipairs(textEndShpora) do
						if textEndShpora[i]:find("F2FF00") then
						textEndShpora[i] = textEndShpora[i]:gsub("{F2FF00}", "")
						end
						if textEndShpora[i]:find("FFFFFF") then
						textEndShpora[i] = textEndShpora[i]:gsub("{FFFFFF}", "")
						end
					end
				end
					if doesFileExist(getWorkingDirectory().."/MedicalHelper/editShporaFindSLL.txt") then
							os.remove(getWorkingDirectory().."/MedicalHelper/editShporaFindSLL.txt")
							for i, v in ipairs(textEndShpora) do
								local f = io.open(getWorkingDirectory().."/MedicalHelper/editShporaFindSLL.txt", "a")
								f:write(textEndShpora[i].."\n")
								f:flush()
								f:close()
							end
						else
							for i, v in ipairs(textEndShpora) do
								local f = io.open(getWorkingDirectory().."/MedicalHelper/editShporaFindSLL.txt", "a")
								f:write(textEndShpora[i].."\n")
								f:flush()
								f:close()
							end
						end
				plerel = false
			end
			imgui.PopItemWidth()
			imgui.SameLine()
			imgui.SetCursorPosX(500)
			imgui.PushFont(fontsize)
			imgui.SetCursorPosY(5)
			imgui.Text(u8"Окно шпаргалки")
			imgui.PopFont()
			imgui.SameLine()
			imgui.SetCursorPosX(1068)
			imgui.SetCursorPosY(6)
			if imgui.InvisibleButton(u8" ", imgui.ImVec2(24, 24)) or animka_big.paramOff then 
				posWinClosed = imgui.GetWindowPos()
				styleAnimationClose(5, 1098, 728)
				animka_big.paramOff = false
			end
			if imgui.IsItemHovered() then
				imgui.SameLine()
				imgui.SetCursorPosX(1073)
				imgui.SetCursorPosY(3)
				imgui.PushFont(fa_font2)
				imgui.TextColored(imgui.ImVec4(1.0, 0.56, 0.64 ,1.00), fa.ICON_TIMES)
				imgui.PopFont()
			else
				imgui.SameLine()
				imgui.SetCursorPosX(1073)
				imgui.SetCursorPosY(3)
				imgui.PushFont(fa_font2)
				imgui.Text(fa.ICON_TIMES)
				imgui.PopFont()
			end
			imgui.Separator()
			imgui.Dummy(imgui.ImVec2(0, 1))
		if spur.edit then
				imgui.InputTextMultiline("##spur", spur.text, imgui.ImVec2(1081, 622))
				if imgui.Button(u8"Сохранить", imgui.ImVec2(357, 25)) then
					local name = ""
					local bool = false
					if spur.name.v ~= "" then 
							name = u8:decode(spur.name.v)
							if doesFileExist(dirml.."/MedicalHelper/Шпаргалки/"..name..".txt") and spur.list[spur.select_spur] ~= name then
								bool = true
								imgui.OpenPopup(u8"Ошибка")
							else
								os.remove(dirml.."/MedicalHelper/Шпаргалки/"..spur.list[spur.select_spur]..".txt")
								spur.list[spur.select_spur] = u8:decode(spur.name.v)
							end
					else
						name = spur.list[spur.select_spur]
					end
					if not bool then
						local f = io.open(dirml.."/MedicalHelper/Шпаргалки/"..name..".txt", "w")
						f:write(u8:decode(spur.text.v))
						f:flush()
						f:close()
						spur.text.v = ""
						spur.name.v = ""
						spur.edit = false
						examination = true
						textEndShpora = {}
					end
				end
				imgui.SameLine()
				if imgui.Button(u8"Удалить", imgui.ImVec2(357, 25)) then
					spur.text.v = ""
					table.remove(spur.list, spur.select_spur) 
					spur.select_spur = -1
					if doesFileExist(dirml.."/MedicalHelper/Шпаргалки/"..u8:decode(spur.select_spur)..".txt") then
						os.remove(dirml.."/MedicalHelper/Шпаргалки/"..u8:decode(spur.select_spur)..".txt")
					end
					spur.name.v = ""
					spurBig.v = false
					spur.edit = false
					examination = true
					textEndShpora = {}
				end
				imgui.SameLine()
				if imgui.Button(u8"Включить просмотр", imgui.ImVec2(357, 25)) then spur.edit = false examination = true textEndShpora = {} end
				if imgui.Button(u8"Закрыть", imgui.ImVec2(1081, 25)) then
					if not spurBig.v then
						styleAnimationOpen(5)
						spurBig.v = true
						examination = true
						textEndShpora = {}
					else
						animka_big.paramOff = true
					end
				end
		else
			imgui.BeginChild("spur spec", imgui.ImVec2(1070, 650), true)
				if examination then
					if doesFileExist(dirml.."/MedicalHelper/Шпаргалки/"..spur.list[spur.select_spur]..".txt") then
						local numSh = 0
						for line in io.lines(dirml.."/MedicalHelper/Шпаргалки/"..spur.list[spur.select_spur]..".txt") do
							numSh = numSh + 1
							if line == "" then
								line = " "
							end
							textEndShpora[numSh] = wraper(line, 140)
						end
					end
					if doesFileExist(getWorkingDirectory().."/MedicalHelper/editShporaFindSLL.txt") then
							os.remove(getWorkingDirectory().."/MedicalHelper/editShporaFindSLL.txt")
							for i = 1, #textEndShpora do
								local f = io.open(getWorkingDirectory().."/MedicalHelper/editShporaFindSLL.txt", "a")
								f:write(textEndShpora[i].."\n")
								f:flush()
								f:close()
							end
						else
							for i = 1, #textEndShpora do
								local f = io.open(getWorkingDirectory().."/MedicalHelper/editShporaFindSLL.txt", "a")
								f:write(textEndShpora[i].."\n")
								f:flush()
								f:close()
							end
						end
					examination = false
				end
				if not plerel and not examination then
					if doesFileExist(dirml.."/MedicalHelper/editShporaFindSLL.txt") then
						for line in io.lines(dirml.."/MedicalHelper/editShporaFindSLL.txt") do
							imgui.TextColoredRGB(line)
						end
					end
				end
			imgui.EndChild()
			if imgui.Button(u8"Включить редактирование", imgui.ImVec2(537, 25)) then 
				spur.edit = true
				local f = io.open(dirml.."/MedicalHelper/Шпаргалки/"..spur.list[spur.select_spur]..".txt", "r")
				spur.text.v = u8(f:read("*a"))
				f:close()
			end
			imgui.SameLine()
			if imgui.Button(u8"Закрыть", imgui.ImVec2(537, 25)) then
				if not spurBig.v then
					styleAnimationOpen(5)
					spurBig.v = true
					examination = true
					textEndShpora = {}
				else
					animka_big.paramOff = true
				end
			end
		end
		imgui.End()
	end

	if sobWin.v then
		sobWind()
	end

	if depWin.v then
		inDepWin()
	end

	if updWin.v then
		if not animka_upd.MoveAnim then
			seelU = imgui.Cond.FirstUseEver
		else
			seelU = imgui.Cond.Always
		end
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowSize(imgui.ImVec2(700, 420), seelU)
		imgui.SetNextWindowPos(imgui.ImVec2(animka_upd.posX, animka_upd.posY), seelU, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(fa.ICON_DOWNLOAD .. u8" Проверка обновлений.", updWin, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar);
		imgui.SetCursorPosX(268)
			imgui.PushFont(fontsize)
			imgui.SetCursorPosY(6)
			imgui.Text(u8"Проверка обновлений")
			imgui.PopFont()
			imgui.SameLine()
			imgui.SetCursorPosX(670)
			imgui.SetCursorPosY(6)
			if imgui.InvisibleButton(u8" ", imgui.ImVec2(24, 24)) or animka_upd.paramOff then 
				posWinClosed = imgui.GetWindowPos()
				styleAnimationClose(4, 700, 420)
				animka_upd.paramOff = false
			end
			if imgui.IsItemHovered() then
				imgui.SameLine()
				imgui.SetCursorPosX(675)
				imgui.SetCursorPosY(3)
				imgui.PushFont(fa_font2)
				imgui.TextColored(imgui.ImVec4(1.0, 0.56, 0.64 ,1.00), fa.ICON_TIMES)
				imgui.PopFont()
			else
				imgui.SameLine()
				imgui.SetCursorPosX(675)
				imgui.SetCursorPosY(3)
				imgui.PushFont(fa_font2)
				imgui.Text(fa.ICON_TIMES)
				imgui.PopFont()
			end
			imgui.Separator()
			imgui.Dummy(imgui.ImVec2(0, 1))
		imgui.SetWindowFontScale(1.1)
		imgui.SetCursorPosX(252)
		imgui.Text(u8"Информация об обновлении")
		imgui.Dummy(imgui.ImVec2(0, 10))
		if #updinfo < 5 then
			imgui.SetCursorPos(imgui.ImVec2(242, 150))
			imgui.TextColoredRGB("{72F566}Обновлений не обнаружено")
			imgui.SetCursorPosX(212)
			imgui.TextColoredRGB("{72F566}Вы используете самую новую версию")
		else
			if not upd_release and not upd_beta and scrvers == newversr then
				imgui.SetCursorPosX(120)
				imgui.TextColored(imgui.ImColor(0, 255, 0, 225):GetVec4(), fa.ICON_CHECK); imgui.SameLine()
				imgui.TextColoredRGB("Вы используете последнее обновление. Текущая версия: {72F566}"..scr.version)
				imgui.SetCursorPosX(222)
				imgui.TextColoredRGB("{F8A436}Что было добавлено в прошлый раз: ")
				imgui.Spacing()
				imgui.BeginChild("update log", imgui.ImVec2(0, 0), true)
				if doesFileExist(dirml.."/MedicalHelper/files/update.txt") then
					for line in io.lines(dirml.."/MedicalHelper/files/update.txt") do
						imgui.TextColoredRGB(line:gsub("*n*", "\n"))
					end
				end
				imgui.EndChild()
			elseif not upd_release and not upd_beta and scrvers > newversr  then
				imgui.SetCursorPosX(120)
				imgui.TextColored(imgui.ImColor(0, 255, 0, 225):GetVec4(), fa.ICON_CHECK); imgui.SameLine()
				imgui.TextColoredRGB("Вы используете последнее обновление. Текущая версия: {72F566}"..scr.version)
				imgui.SetCursorPosX(222)
				imgui.TextColoredRGB("{F8A436}Что было добавлено в прошлый раз: ")
				imgui.Spacing()
				imgui.BeginChild("update log", imgui.ImVec2(0, 0), true)
				if doesFileExist(dirml.."/MedicalHelper/files/updatebeta.txt") then
					for line in io.lines(dirml.."/MedicalHelper/files/updatebeta.txt") do
						imgui.TextColoredRGB(line:gsub("*n*", "\n"))
					end
				end
				imgui.EndChild()
			elseif not upd_release and upd_beta then
				imgui.SetCursorPosX(70) 
				imgui.TextColored(imgui.ImColor(255, 200, 0, 225):GetVec4(), fa.ICON_EXCLAMATION_TRIANGLE); imgui.SameLine()
				imgui.TextColoredRGB("Вы используете устаревшую бета версию скрипта. Имеется новая бета версия.")
				imgui.SetCursorPosX(185) 
				imgui.TextColoredRGB("Новая версия бета: {72F566}"..newversionbeta.."{FFFFFF}. Текущая Ваша: {EE4747}"..scr.version)
				imgui.SetCursorPosX(282)
				imgui.TextColoredRGB("{F8A436}Что было добавлено:")
				imgui.Spacing()
				imgui.BeginChild("update log", imgui.ImVec2(0, 230), true)
				if doesFileExist(dirml.."/MedicalHelper/files/updatebeta.txt") then
					for line in io.lines(dirml.."/MedicalHelper/files/updatebeta.txt") do
						imgui.TextColoredRGB(line:gsub("*n*", "\n"))
					end
				end
				imgui.EndChild()
				imgui.SetCursorPosX(212)
				if imgui.Button(fa.ICON_DOWNLOAD .. u8" Установить бета версию", imgui.ImVec2(250, 30)) then funCMD.updatebeta() end
			elseif upd_release then
				imgui.SetCursorPosX(182) 
				imgui.TextColored(imgui.ImColor(255, 200, 0, 225):GetVec4(), fa.ICON_EXCLAMATION_TRIANGLE); imgui.SameLine()
				imgui.TextColoredRGB("Вы используете устаревшую версию скрипта.")
				imgui.SetCursorPosX(183) 
				imgui.TextColoredRGB("Новая релиз версия: {72F566}"..newversion.."{FFFFFF}. Текущая Ваша: {EE4747}"..scr.version)
				imgui.SetCursorPosX(282)
				imgui.TextColoredRGB("{F8A436}Что было добавлено:")
				imgui.Spacing()
				imgui.BeginChild("update log", imgui.ImVec2(0, 230), true)
				if doesFileExist(dirml.."/MedicalHelper/files/update.txt") then
					for line in io.lines(dirml.."/MedicalHelper/files/update.txt") do
						imgui.TextColoredRGB(line:gsub("*n*", "\n"))
					end
				end
				imgui.EndChild()
				imgui.SetCursorPosX(192)
				if imgui.Button(fa.ICON_DOWNLOAD .. u8" Установить новую релиз версию", imgui.ImVec2(270, 30)) then funCMD.updaterelease() end
			end
		end
		imgui.End()
	end
	if profbWin.v then
		profbWind()
	end
end
function funcTargetDo(idTarget) --geter
	if idTarget == 0 then
		funCMD.lec(tostring(targetID))
	elseif idTarget == 1 then
		funCMD.med(tostring(targetID))
	elseif idTarget == 2 then
		funCMD.vac(tostring(targetID))
	elseif idTarget == 3 then
		funCMD.narko(tostring(targetID))
	elseif idTarget == 4 then
		funCMD.ant(tostring(targetID))
	elseif idTarget == 5 then
		funCMD.recep(tostring(targetID))
	elseif idTarget == 6 then
		funCMD.expel(tostring(targetID).." НПБ")
	elseif idTarget == 7 then
		funCMD.sob()
		sobes.selID.v = ""..targetID..""
	elseif idTarget == 8 then
		sampSetChatInputEnabled(true)
		sampSetChatInputText("/"..cmdBind[18].cmd.." "..targetID.." ")
	elseif idTarget == 9 then
		funCMD.inv(tostring(targetID))
	elseif idTarget == 10 then
		funCMD.cure(tostring(targetID))
	elseif idTarget == 11 then
		funCMD.show(tostring(targetID))
	elseif idTarget == 12 then
		sampSendChat('/trade '..(tostring(targetID)))
	elseif idTarget >= 13 then
		thread = lua_thread.create(function()		
			local dir = dirml.."/MedicalHelper/Binder/bind-"..binder.list[idTarget - 12].name..".txt"	
			local tb = {}
			tb = strBinderTable(dir)
			tb.sleep = binder.list[idTarget - 12].sleep
			playBind(tb)
			return
		end)
	end
end
function choiceWind()
	if sampIsPlayerConnected(targetID) then
		local sw, sh = getScreenResolution()
		local sizewinda = 0
		for i = 1, #setting2.funcPKM.slider do
			if optionsPKM[setting2.funcPKM.slider[i] + 1] ~= nil then
				sizewinda = sizewinda + 34
			end
		end
		imgui.SetNextWindowSize(imgui.ImVec2(250, 100 + sizewinda), imgui.Cond.Always)
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.Always, imgui.ImVec2(0.5, 0.5))
		imgui.Begin("Choicewindows", choiceWin, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoMove);
		imgui.PushFont(fontsize)
		imgui.SetCursorPosY(6)
		local calc = imgui.CalcTextSize(u8(getPlayerNickName(targetID)).." ["..targetID.."]")
		imgui.SetCursorPosX(125 - calc.x / 2 )
		imgui.TextColoredRGB("{5BF165}"..u8(getPlayerNickName(targetID)).." ["..targetID.."]")
		imgui.PopFont()
		imgui.Separator()
		imgui.Dummy(imgui.ImVec2(0, 2))
		local function stopKeyPressed()
			lua_thread.create(function()
				setVirtualKeyDown(VK_RBUTTON, true) 
				wait(1)
				setVirtualKeyDown(VK_RBUTTON, false)
			end)
		end
		for i = 1, #setting2.funcPKM.slider do
			if optionsPKM[setting2.funcPKM.slider[i] + 1] ~= nil then
				imgui.Spacing()
				imgui.SetCursorPosX(-20)
				if imgui.Button("    "..optionsPKM[setting2.funcPKM.slider[i] + 1].."##sl"..i, imgui.ImVec2(276, 27)) then
					stopKeyPressed()
					funcTargetDo(setting2.funcPKM.slider[i])
					choiceWin.v = false
				end
			end
		end
		imgui.Dummy(imgui.ImVec2(0, 2))
		imgui.Separator()
		imgui.Separator()
		imgui.Dummy(imgui.ImVec2(0, 2))
		if imgui.Button(u8"Закрыть", imgui.ImVec2(233,27)) then choiceWin.v = false stopKeyPressed() end
		imgui.End()
		else
		choiceWin.v = false
	end
end
function profbWind()
local sw, sh = getScreenResolution()
		imgui.SetNextWindowSize(imgui.ImVec2(710, 450), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"Продвинутое пользование биндера", profbWin, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize);
		imgui.SetWindowFontScale(1.1)
			local vt1 = [[
Помимо стандартного использования биндера для последовательного проигрывания строчек
текста возможно использовать больший функционал для расширения возможностей.
 
{FFCD00}1. Система переменных{FFFFFF}
	Для создание переменных используется символ решётки {ACFF36}#{FFFFFF}, после которого идёт название
переменной. Название переменной может содержать только английские символы и цифры,
иначе будет пропущено. 
	После названия переменной ставится равно {ACFF36}={FFFFFF} и далее пишется любой текст, который
необходимо присвоить этой переменной. Текст может содержать любые символы.
		Пример: {ACFF36}#price=10.000$.{FFFFFF}
	Теперь, используя переменную {ACFF36}#price{FFFFFF}, можно её вставить куда вам захочется, и она будет
автоматически заменена во время проигрывания отыгровки на значение, которое было 
указано после равно.
 
{FFCD00}2. Комментирование текста{FFFFFF}
	С помощью комментирования можно сделать для себя пометку или описание чего-либо
при этом сам комментарий не будет отображаться. Комментарий создаётся двойным слешом //,
после которого пишется любой текст.
	Пример: {ACFF36}Здравствуйте, чем Вам помочь // Приветствие{FFFFFF}
Комментарий {ACFF36}// Приветствие{FFFFFF} во время отыгровки удалится и не будет виден.
 
{FFCD00}3. Система диалогов{FFFFFF}
	С помощью диалогов можно создавать разветвления отыгровок, с помощью которых можно
реализовывать более сложные варианты их.
Структура диалога:
	{ACFF36}{dialog}{FFFFFF} 		- начало структуры диалога
	{ACFF36}[name]=Текст{FFFFFF}- имя диалога. Задаётся после равно =. Оно не должно быть особо большим
	{ACFF36}[1]=Текст{FFFFFF}		- варианты для выбора дальшейших действий, где в скобках 1 - это
клавиша активация. Можно устанавливать помимо цифр, другие значения, например, [X], [B],
[NUMPAD1], [NUMPAD2] и т.д. Список доступных клавиш можно посмотреть здесь. После равно
прописывается имя, которое будет отображаться при выборе. 
	После того, как задали имя варианта, со следующей строки пишутся уже сами отыгровки.
	{ACFF36}Текст отыгровки...
	{ACFF36}[2]=Текст{FFFFFF}	
	{ACFF36}Текст отыгровки...
	{ACFF36}{dialogEnd}{FFFFFF}		- конец структуры диалога
]]
			local vt2 = [[
									{E45050}Особенности:
1. Имена диалога и вариантов задавать не обязательно, но 
рекомендуется для визуального понимания;
2. Можно создавать диалоги внутри диалогов, создавая 
конструкции внутри вариантов;
3. Можно использовать все выше перечисленные системы 
(переменные, комментарии, теги и т.п.)
			]]
			local vt3 = [[
{FFCD00}4. Использование тегов{FFFFFF}
Список тегов можно открыть в меню редактирования отыгровки или в разделе биндера.
Теги предназначены для автоматическеской замены на значение, которые они имеют.
Имеются два вида тегов:
	1. Спростые теги - теги, которые просто заменяют себя на значение, которые они
постоянно имеют, например, {ACFF36}{myID}{FFFFFF} - возвращает Ваш текущий ID.
	2. Тег-функция - специальные теги, которые требуют дополнительных параметров.
К ним относятся:
	{ACFF36}{sleep:[время]}{FFFFFF} - Задаёт свой интервал времени между строчками. 
Время задаётся в миллисекундах. Пример: {ACFF36}{sleep:2000}{FFFFFF} - задаёт интервал в 2 сек
1 секунда = 1000 миллисекунд

	{ACFF36}{sex:текст1|текст2}{FFFFFF} - Возвращает текст в зависимости от выбранного пола.
Больше предназначено, если создаётся отыгровка для публичного использования.
Где {6AD7F0}текст1{FFFFFF} - для мужской отыгровки, {6AD7F0}текст2{FFFFFF} - для женской. Разделяется вертикальной чертой.
	Пример: {ACFF36}Я {sex:пришёл|пришла} сюда.

	{ACFF36}{getNickByID:ид игрока}{FFFFFF} - Возращает ник игрока по его ID.
Пример: На сервере игрок {6AD7F0}Nick_Name{FFFFFF} с id - 25.
{ACFF36}{getNickByID:25}{FFFFFF} вернёт - {6AD7F0}Nick Name.
			]]
			imgui.TextColoredRGB(vt1)

			imgui.BeginGroup()
				imgui.TextDisabled(u8"					Пример")
				imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImColor(70, 70, 70, 200):GetVec4())
				imgui.InputTextMultiline("##dialogPar", helpd.exp, imgui.ImVec2(220, 180), 16384)
				imgui.PopStyleColor(1)
				imgui.TextDisabled(u8"Для копирования используйте\nCtrl + C. Вставка - Ctrl + V")
			imgui.EndGroup()
			imgui.SameLine()
			imgui.BeginGroup()
				imgui.TextColoredRGB(vt2)
				if imgui.Button(u8"Список клавиш", imgui.ImVec2(150,25)) then
					imgui.OpenPopup("helpdkey")
				end
			imgui.EndGroup()
			imgui.TextColoredRGB(vt3)
			------
			if imgui.BeginPopup("helpdkey") then
				imgui.BeginChild("helpdkey", imgui.ImVec2(290,320))
					imgui.TextColoredRGB("{FFCD00}Кликните, чтобы скопировать")
					imgui.BeginGroup()
						for _,v in ipairs(helpd.key) do
							if imgui.Selectable(u8("["..v.k.."] 	-	"..v.n)) then
								setClipboardText(v.k)
							end
						end
					imgui.EndGroup()
				imgui.EndChild()
			imgui.EndPopup()
			end
		imgui.End()
end
function testwin()
local sw, sh = getScreenResolution()
		imgui.SetNextWindowSize(imgui.ImVec2(250, 900), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin("Icons ", mainWin, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize);
			for i,v in pairs(fa) do
				if imgui.Button(fa[i].." - "..i, imgui.ImVec2(200, 25)) then setClipboardText(i) end
			end
			
		imgui.End()
end
function sobWind()
	if not animka_sob.MoveAnim then
		seelS = imgui.Cond.FirstUseEver
	else
		seelS = imgui.Cond.Always
	end
local sw, sh = getScreenResolution()
		imgui.SetNextWindowSize(imgui.ImVec2(910, 400), seelS)
		imgui.SetNextWindowPos(imgui.ImVec2(animka_sob.posX, animka_sob.posY), seelS, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"Меню для проведения собеседования", sobWin, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar);
		imgui.SetCursorPosX(420)
			imgui.PushFont(fontsize)
			imgui.SetCursorPosY(6)
			imgui.Text(u8"Меню собеседования")
			imgui.PopFont()
			imgui.SameLine()
			imgui.SetCursorPosX(880)
			imgui.SetCursorPosY(6)
			if imgui.InvisibleButton(u8" ", imgui.ImVec2(24, 24)) or animka_sob.paramOff then 
				posWinClosed = imgui.GetWindowPos()
				styleAnimationClose(3, 910, 400)
				animka_sob.paramOff = false
			end
			if imgui.IsItemHovered() then
				imgui.SameLine()
				imgui.SetCursorPosX(885)
				imgui.SetCursorPosY(3)
				imgui.PushFont(fa_font2)
				imgui.TextColored(imgui.ImVec4(1.0, 0.56, 0.64 ,1.00), fa.ICON_TIMES)
				imgui.PopFont()
			else
				imgui.SameLine()
				imgui.SetCursorPosX(885)
				imgui.SetCursorPosY(3)
				imgui.PushFont(fa_font2)
				imgui.Text(fa.ICON_TIMES)
				imgui.PopFont()
			end
			imgui.Separator()
			imgui.Dummy(imgui.ImVec2(0, 1))
			imgui.BeginGroup()
				imgui.PushItemWidth(140)
				imgui.InputText("##id", sobes.selID, imgui.InputTextFlags.CallbackCharFilter + imgui.InputTextFlags.EnterReturnsTrue + readID(), filter(1, "%d+"))
				imgui.PopItemWidth()
				if not imgui.IsItemActive() and sobes.selID.v == "" then
					imgui.SameLine()
					imgui.SetCursorPosX(13)
					imgui.TextDisabled(u8"Укажите id игрока") 
				end
				imgui.SameLine()
				imgui.SetCursorPosX(155)
				if imgui.Button(u8"Начать", imgui.ImVec2(60, 25)) then
					if sobes.selID.v ~= "" then
						if #sobes.logChat == 0 then
						sobes.num = sobes.num + 1
						threadS = lua_thread.create(sobesRP, sobes.num);
						table.insert(sobes.logChat, "{FFC000}Вы: {FFFFFF}Проверка документов...")
						else
						table.insert(sobes.logChat, "{E74E28}[Ошибка]{FFFFFF}: Проверка уже началась. Если хотите начать новую, нажмите на кнопку \"Остановить\" или \n\tдождитесь окончания проверки.")
						end
					else
						sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} Укажите id игрока для начала собеседования.", 0xFF8FA2)
					end
				end
				imgui.BeginChild("pass player", imgui.ImVec2(210, 170), true)
					imgui.SetCursorPosX(30)
					imgui.Text(u8"Информация о игроке:")
					imgui.Separator()
					imgui.Bullet()
					imgui.Text(u8"Имя:")
						if sobes.player.name == "" then
							imgui.SameLine()
							imgui.TextColoredRGB("{F55534}нет")
						else
							imgui.SameLine()
							imgui.TextColoredRGB("{FFCD00}"..sobes.player.name)
						end
					imgui.Bullet()
					imgui.Text(u8"Лет в штате:")
						if sobes.player.let == 0 then
							imgui.SameLine()
							imgui.TextColoredRGB("{F55534}нет")
						else
							if sobes.player.let >= 3 then
								imgui.SameLine()
								imgui.TextColoredRGB("{17E11D}"..sobes.player.let.."/3")
							else
								imgui.SameLine()
								imgui.TextColoredRGB("{F55534}"..sobes.player.let.."{17E11D}/3")
							end
						end
					imgui.Bullet()
					imgui.Text(u8"Законопослушность:")
						if sobes.player.zak == 0 then
							imgui.SameLine()
							imgui.TextColoredRGB("{F55534}нет")
						else
							if sobes.player.zak >= 35 then
								imgui.SameLine()
								imgui.TextColoredRGB("{17E11D}"..sobes.player.zak.."/35")
							else
								imgui.SameLine()
								imgui.TextColoredRGB("{F55534}"..sobes.player.zak.."{17E11D}/35")
							end
						end
					imgui.Bullet()
					imgui.Text(u8"Имеет работу:")
						if sobes.player.work == "" then
							imgui.SameLine()
							imgui.TextColoredRGB("{F55534}нет")
						else
							if sobes.player.work == "Без работы" then
								imgui.SameLine()
								imgui.TextColoredRGB("{17E11D}"..sobes.player.work)
							else
								imgui.SameLine()
								imgui.TextColoredRGB("{F55534}"..sobes.player.work)
							end
						end
					imgui.Bullet()
					imgui.Text(u8"Состоит в ЧС:")
						if sobes.player.bl == "" then
							imgui.SameLine()
							imgui.TextColoredRGB("{F55534}нет")
						else
							if sobes.player.bl == "Не найден(а)" then
								imgui.SameLine()
								imgui.TextColoredRGB("{17E11D}"..sobes.player.bl)
							else
								imgui.SameLine()
								imgui.TextColoredRGB("{F55534}"..sobes.player.bl)
							end
						end
					imgui.Spacing()
					imgui.Bullet()
					imgui.Text(u8"Здоровье:")
						if sobes.player.heal == "" then
							imgui.SameLine()
							imgui.TextColoredRGB("{F55534}нет")
						else
							if sobes.player.heal == "Здоров" then
								imgui.SameLine()
								imgui.TextColoredRGB("{17E11D}"..sobes.player.heal)
							else
								imgui.SameLine()
								imgui.TextColoredRGB("{F55534}"..sobes.player.heal)
							end
						end
					imgui.Bullet()
					imgui.Text(u8"Наркозависимость:")
						if sobes.player.narko == 0.1 then
							imgui.SameLine()
							imgui.TextColoredRGB("{F55534}нет")
						else
							if sobes.player.narko == 0 then
								imgui.SameLine()
								imgui.TextColoredRGB("{17E11D}"..sobes.player.narko.."/5")
							else
								imgui.SameLine()
								imgui.TextColoredRGB("{F55534}"..sobes.player.narko.."{17E11D}/5")
							end
						end
				imgui.EndChild()
				if imgui.Button(u8"Внеочередной вопрос", imgui.ImVec2(210, 30)) then imgui.OpenPopup("sobQN") end
				imgui.Spacing()
					if sobes.nextQ then
						if imgui.Button(u8"Дальше вопрос", imgui.ImVec2(210, 30)) then
							sobes.num = sobes.num + 1
							lua_thread.create(sobesRP, sobes.num); 
						end
					else
						imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(156, 156, 156, 200):GetVec4())
						imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(156, 156, 156, 200):GetVec4())
						imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(156, 156, 156, 200):GetVec4())
						imgui.Button(u8"Следующий вопрос", imgui.ImVec2(210, 30))
						imgui.PopStyleColor(3)
					end
				imgui.Spacing()
				if #sobes.logChat ~= 0 and sobes.selID.v ~= "" then
					if imgui.Button(u8"Определить годность", imgui.ImVec2(210, 30)) then imgui.OpenPopup("sobEnter") end
				else
						imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(156, 156, 156, 200):GetVec4())
						imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(156, 156, 156, 200):GetVec4())
						imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(156, 156, 156, 200):GetVec4())
						imgui.Button(u8"Определить годность", imgui.ImVec2(210, 30))
						imgui.PopStyleColor(3)
				end
				imgui.Spacing()
				if #sobes.logChat ~= 0 and sobes.selID.v ~= "" then 
					if imgui.Button(u8"Остановить / Очистить", imgui.ImVec2(210, 30)) then
						threadS:terminate()
						sobes.input.v = ""
						sobes.player = {name = "", let = 0, zak = 0, work = "", bl = "", heal = "", narko = 0.1}
						sobes.selID.v = ""
						sobes.logChat = {}
						sobes.nextQ = false
						sobes.num = 0
					end
				else
						imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(156, 156, 156, 200):GetVec4())
						imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(156, 156, 156, 200):GetVec4())
						imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(156, 156, 156, 200):GetVec4())
						imgui.Button(u8"Остановить/Очистить", imgui.ImVec2(210, 30))
						imgui.PopStyleColor(3)
				end
			imgui.EndGroup()
			imgui.SameLine()
			imgui.BeginChild("log chat", imgui.ImVec2(0, 0), true)
				imgui.SetCursorPosX(300)
				imgui.Text(u8"Локальный чат")
					if imgui.IsItemHovered() then imgui.SetTooltip(u8"Кликните ПКМ для очистки") end
					if imgui.IsItemClicked(1) then sobes.logChat = {} end
				imgui.SameLine()
				imgui.SetCursorPosX(610)
				if imgui.SmallButton(u8"Помощь") then imgui.OpenPopup("helpsob") end
				imgui.PushStyleColor(imgui.Col.PopupBg, imgui.ImVec4(0.06, 0.06, 0.06, 0.94))
					if imgui.BeginPopup("helpsob") then
						imgui.Text(u8"\t\t\t\t\t\tНебольшая инструкция по пользованию.")
						imgui.TextColoredRGB(helpsob)
					imgui.EndPopup()
					end
				imgui.PopStyleColor(1)
				imgui.BeginChild("log chat in", imgui.ImVec2(0, 280), true)
					for i,v in ipairs(sobes.logChat) do
						imgui.TextColoredRGB(v)
					end
					imgui.SetScrollY(imgui.GetScrollMaxY())
				imgui.EndChild()
				imgui.Spacing()
				imgui.Text(u8"Вы:");
				imgui.SameLine()
				imgui.PushItemWidth(545)
				imgui.InputText("##chat", sobes.input)
				imgui.PopItemWidth()
				imgui.SameLine()
				if imgui.Button(u8"Отправить", imgui.ImVec2(85, 21)) then sampSendChat(u8:decode(sobes.input.v)); sobes.input.v = "" end
			imgui.EndChild()
				imgui.PushStyleColor(imgui.Col.PopupBg, imgui.ImVec4(0.06, 0.06, 0.06, 0.94)) 
					if imgui.BeginPopup("sobEnter") then
						if imgui.MenuItem(u8"Принять") then lua_thread.create(sobesRP, 4) end
						if imgui.BeginMenu(u8"Отклонить") then
							if imgui.MenuItem(u8"Отпечатка в паспорте (Ник)") then lua_thread.create(sobesRP, 5) end
							if imgui.MenuItem(u8"Мало лет проживания") then lua_thread.create(sobesRP, 6) end
							if imgui.MenuItem(u8"Проблемы с законом") then lua_thread.create(sobesRP, 7) end
							if imgui.MenuItem(u8"Имеет работу") then lua_thread.create(sobesRP, 8) end
							if imgui.MenuItem(u8"Состоит в ЧС") then lua_thread.create(sobesRP, 9) end
							if imgui.MenuItem(u8"Проблемы со здоровьем") then lua_thread.create(sobesRP, 10) end
							if imgui.MenuItem(u8"Имеет наркозависимость") then lua_thread.create(sobesRP, 11) end
						imgui.EndMenu()
						end
					imgui.EndPopup()
					end
					if imgui.BeginPopup("sobQN") then
						if imgui.MenuItem(u8"Попросить документы") then 
							sampSendChat("Предъявите пожалуйста Ваш пакет документов, а именно: паспорт и мед.карту.") 
							table.insert(sobes.logChat, "{FFC000}Вы: {FFFFFF}Вопрос: Повторная просьба показать документы.")
						end
						if imgui.MenuItem(u8"Выбор больницы") then 
							sampSendChat("Почему Вы выбрали именно нашу больницу для трудоустройства?") 
							table.insert(sobes.logChat, "{FFC000}Вы: {FFFFFF}Вопрос: Почему Вы выбрали именно нашу больницу для трудоустройства?")
						end
						if imgui.MenuItem(u8"Рассказать о себе") then 
							sampSendChat("Расскажите, пожалуйста, немного о себе.") 
							table.insert(sobes.logChat, "{FFC000}Вы: {FFFFFF}Вопрос: Расскажите, пожалуйста, немного о себе.")
						end
						if imgui.MenuItem(u8"Имеет ли Discord") then 
							sampSendChat("Имеется ли у Вас спец.рация \"Discord\"?") 
							table.insert(sobes.logChat, "{FFC000}Вы: {FFFFFF}Вопрос: Имеется ли у Вас спец.рация \"Discord\"?")
						end
						if imgui.BeginMenu(u8"Вопросы на психику:") then
							if imgui.MenuItem(u8"МГ") then 
								sampSendChat("Что может означать аббревиатура 'МГ'?")
								table.insert(sobes.logChat, "{FFC000}Вы: {FFFFFF}Вопрос: Что может означать аббревиатура 'МГ'?")
							end
							if imgui.MenuItem(u8"ДМ") then 
								sampSendChat("Что может означать аббревиатура 'ДМ'?") 
								table.insert(sobes.logChat, "{FFC000}Вы: {FFFFFF}Вопрос: Что может означать аббревиатура 'ДМ'?")
							end
							if imgui.MenuItem(u8"ТК") then 
								sampSendChat("Что может означать аббревиатура 'ТК'?") 
								table.insert(sobes.logChat, "{FFC000}Вы: {FFFFFF}Вопрос: Что может означать аббревиатура 'ТК'?")
							end
							if imgui.MenuItem(u8"РП") then 
								sampSendChat("Как Вы думаете, что может означать аббревиатура 'РП'?")
								table.insert(sobes.logChat, "{FFC000}Вы: {FFFFFF}Вопрос: Как Вы думаете, что может означать аббревиатура 'РП'?.")								
							end
						imgui.EndMenu()
						end
					imgui.EndPopup()
					end
				imgui.PopStyleColor(1)
		imgui.End()
end
function inDepWin()
	if not animka_dep.MoveAnim then
		seelD = imgui.Cond.FirstUseEver
	else
		seelD = imgui.Cond.Always
	end
	local sw, sh = getScreenResolution()
		imgui.SetNextWindowSize(imgui.ImVec2(950, 445), seelD)
		imgui.SetNextWindowPos(imgui.ImVec2(animka_dep.posX, animka_dep.posY), seelD, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(fa.ICON_SIGNAL .. u8" Меню рации департамента.", depWin, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar);
			imgui.SetCursorPosX(420)
			imgui.PushFont(fontsize)
			imgui.SetCursorPosY(6)
			imgui.Text(u8"Рация департамента")
			imgui.PopFont()
			imgui.SameLine()
			imgui.SetCursorPosX(920)
			imgui.SetCursorPosY(6)
			if imgui.InvisibleButton(u8" ", imgui.ImVec2(24, 24)) or animka_dep.paramOff then 
				posWinClosed = imgui.GetWindowPos()
				styleAnimationClose(2, 950, 445)
				animka_dep.paramOff = false
			end
			if imgui.IsItemHovered() then
				imgui.SameLine()
				imgui.SetCursorPosX(925)
				imgui.SetCursorPosY(3)
				imgui.PushFont(fa_font2)
				imgui.TextColored(imgui.ImVec4(1.0, 0.56, 0.64 ,1.00), fa.ICON_TIMES)
				imgui.PopFont()
			else
				imgui.SameLine()
				imgui.SetCursorPosX(925)
				imgui.SetCursorPosY(3)
				imgui.PushFont(fa_font2)
				imgui.Text(fa.ICON_TIMES)
				imgui.PopFont()
			end
			imgui.Separator()
			imgui.Dummy(imgui.ImVec2(0, 1))
			imgui.BeginGroup()
			imgui.PushStyleColor(imgui.Col.Button, imgui.GetStyle().Colors[imgui.Col.WindowBg])
			if imgui.Button(fa.ICON_COG..u8" Настройки рации", imgui.ImVec2(230, 25)) then
				imgui.OpenPopup(u8"MH | Настройки рации департамента");
				chgDepSetD[1].v = setdepteg.tegtext_one
				chgDepSetD[2].v = setdepteg.tegtext_two
				chgDepSetD[3].v = setdepteg.tegtext_three
				num_dep.v = setdepteg.tegpref_one
				num_dep2.v = setdepteg.tegpref_two
				prefixDefolt = setdepteg.prefix
			end
			imgui.PopStyleColor(1)
			--///Настройки рации департамента
			if imgui.BeginPopupModal(u8"MH | Настройки рации департамента", null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove) then
				imgui.SetCursorPosX(186)
				imgui.Text(u8"Настройте вид обращения в департамент");
				imgui.Separator();
				imgui.SetCursorPosY(60)
				imgui.Text(u8"/d "); imgui.SameLine();
				imgui.SetCursorPosY(58)
				imgui.PushItemWidth(65);
				imgui.InputText(u8"##preftext1", chgDepSetD[1]); --// Первый текст
				imgui.SameLine();
				imgui.SetCursorPosX(35)
					if chgDepSetD[1].v == "" or chgDepSetD[1].v == nil then
						imgui.TextColored(imgui.ImColor(200, 200, 200, 200):GetVec4(), u8"Текст"); --// Когда текста 1 нет
					end
				imgui.SameLine();
				imgui.SetCursorPosX(99);
				imgui.PushItemWidth(193);
					if imgui.Combo(u8"##pref1", num_dep, list_dep_pref_one) then end --// Первый префикс
				imgui.SameLine();
				imgui.SetCursorPosX(297);
				imgui.PushItemWidth(65);
				imgui.InputText(u8"##preftext2", chgDepSetD[2]); --// Второй текст
				imgui.SameLine();
				imgui.SetCursorPosX(303);
					if chgDepSetD[2].v == "" or chgDepSetD[2].v == nil then
						imgui.TextColored(imgui.ImColor(200, 200, 200, 200):GetVec4(), u8"Текст"); --// Когда текста 2 нет
					end
				imgui.SameLine();
				imgui.SetCursorPosX(367);
				imgui.PushItemWidth(193);
					if imgui.Combo(u8"##pref2", num_dep2, list_dep_pref_two) then end --// Второй префикс
				imgui.SameLine();
				imgui.PushItemWidth(65);
				imgui.InputText(u8"##preftext3", chgDepSetD[3]); --// Третий текст
				imgui.SameLine();
				imgui.SetCursorPosX(570);
					if chgDepSetD[3].v == "" or chgDepSetD[3].v == nil then
						imgui.TextColored(imgui.ImColor(200, 200, 200, 200):GetVec4(), u8"Текст"); --// Когда текста 3 нет
					else
						imgui.Dummy(imgui.ImVec2(0, 1))
					end
				imgui.Dummy(imgui.ImVec2(0, 1))
				imgui.Separator();
				imgui.Text(u8"Как это будет выглядеть:");
				imgui.SameLine();
				imgui.TextColoredRGB(u8"{ffe14d}/d ".. u8:decode(DepTxtEndSetting(prefix_end[2])) .. "На связь...");
				imgui.Separator();
				imgui.Dummy(imgui.ImVec2(0, 6))
				imgui.Bullet() imgui.TextColoredRGB("{FF0000}[!] {00ff8c}Оставьте поле пустым, чтобы не отображать текст этого поля.")
				imgui.Spacing()
				imgui.Bullet() imgui.TextColoredRGB("{FF0000}[!] {00ff8c}Чтобы не ошибиться в настройках, загляните в правила обращения в рацию")
				imgui.SetCursorPosX(53);
				imgui.TextColoredRGB("{00ff8c}департамента на форуме Аризоны, в разделе Вашего сервера.")
				imgui.Spacing()
				imgui.Bullet() imgui.TextColoredRGB("{FF0000}[!] {00ff8c}Будьте внимательны! Не пропустите пробел в нужных для этого местах.")
				imgui.Spacing()
				imgui.Bullet() imgui.TextColoredRGB("{FF0000}[!] {00ff8c}Настройте префиксы согласно правилам Вашего сервера. (кнопка ниже)")
				imgui.Dummy(imgui.ImVec2(0, 6))
				imgui.Separator();
						if imgui.Button(u8"Настроить префиксы (теги) обращений", imgui.ImVec2(622, 0)) then 
						imgui.OpenPopup(u8"MH | Настройка префиксов (тегов)")
						chgDepSetPref.v = prefixDefolt[num_pref.v + 1]
						end 
						imgui.Separator();
						imgui.Dummy(imgui.ImVec2(0, 6))
						if imgui.Button(u8"Сохранить", imgui.ImVec2(308, 0)) then 
							setdepteg.tegtext_one = chgDepSetD[1].v
							setdepteg.tegtext_two = chgDepSetD[2].v
							setdepteg.tegtext_three = chgDepSetD[3].v
							setdepteg.tegpref_one = num_dep.v
							setdepteg.tegpref_two =  num_dep2.v
							local f = io.open(dirml.."/MedicalHelper/depsetting.med", "w")
							f:write(encodeJson(setdepteg))
							f:flush()
							f:close()
							sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} Настройки сохранены.", 0xFF8FA2)
							imgui.CloseCurrentPopup();
							lockPlayerControl(false);
						end 
						imgui.SameLine();
						if imgui.Button(u8"Закрыть", imgui.ImVec2(308, 0)) then 
							imgui.CloseCurrentPopup()
							lockPlayerControl(false)
						end 
						--// Настройка префиксов
						if imgui.BeginPopupModal(u8"MH | Настройка префиксов (тегов)", null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove) then
							
							imgui.SetCursorPosX(10)
							imgui.Text(u8"Настройте префиксы под каждую организацию согласно правилам Вашего сервера.");
							imgui.SetCursorPosX(60)
							imgui.Text(u8"Найти эти правила Вы можете на форуме Аризоны, в разделе правил");
							imgui.SetCursorPosX(170)
							imgui.Text(u8"гос. организаций Вашего сервера.");
							imgui.Separator();
							imgui.Spacing();
							imgui.PushItemWidth(230);
							prefixDefolt[num_pref.v + 1] = chgDepSetPref.v
								if imgui.Combo(u8"##tegorg", num_pref, dep.sel_all) then
								chgDepSetPref.v = prefixDefolt[num_pref.v + 1]
								end --// Rgf
							imgui.SameLine();
							imgui.PushItemWidth(120);
							imgui.InputText(u8" Тег организации", chgDepSetPref);
							imgui.Dummy(imgui.ImVec2(0, 6));
							if imgui.Button(u8"Сохранить", imgui.ImVec2(275, 0)) then 
								setdepteg.prefix = prefixDefolt
								local f = io.open(dirml.."/MedicalHelper/depsetting.med", "w")
								f:write(encodeJson(setdepteg))
								f:flush()
								f:close()
								sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} Настройки сохранены.", 0xFF8FA2)
								imgui.CloseCurrentPopup();
								lockPlayerControl(false);
							end 
							imgui.SameLine();
							if imgui.Button(u8"Закрыть", imgui.ImVec2(275, 0)) then 
								imgui.CloseCurrentPopup();
								lockPlayerControl(false);
							end 
						imgui.EndPopup()
						end
				imgui.EndPopup()
				end
			--// Конец настройки рации департамента
			imgui.Dummy(imgui.ImVec2(0, 4)) 
				imgui.BeginChild("dep list", imgui.ImVec2(230, 158), true)
					if ButtonDep(u8(dep.list[2]), dep.bool[2]) and dep.select_dep[2] == 0 then --> Выбор госки
						dep.bool = {false, true, false, false, false, false}
						dep.select_dep[1] = 2
						select_depart = 2
					end
					if ButtonDep(u8(dep.list[6]), dep.bool[6]) and dep.select_dep[2] == 0 then --> Тех. неполадки
						dep.bool = {false, false, false, false, false, true, false}
						dep.select_dep[1] = 6
						select_depart = 3
					end
					if ButtonDep(u8(dep.list[7]), dep.bool[7]) and dep.select_dep[2] == 0 then --> GOV
						dep.bool = {false, false, false, false, false, false, true}
						dep.select_dep[1] = 7
						getGovFile()
						select_depart = 4
					end
				imgui.EndChild()
					if dep.select_dep[1] < 5 and dep.select_dep[1] ~= 0 and dep.select_dep[2] == 0 then
						if dep.select_dep[1] == 1 then
							imgui.Dummy(imgui.ImVec2(0, 5)) 
							if imgui.Button(u8"Подключиться тихо", imgui.ImVec2(208, 25)) then
								for i,v in ipairs(dep.bool) do
									if v == true then 
										dep.select_dep[2] = i
									end
								end
							end
							imgui.SameLine()
							ShowHelpMarker(u8"Вы подключитесь ко всем гос. структурам для дальнейшего обращения.\n\nВ чат департамента ничего не отправится.")
						end
						if dep.select_dep[1] == 2 then
							imgui.Dummy(imgui.ImVec2(0, 3)) 
							imgui.PushItemWidth(207);
							imgui.InputText(u8"##preftext1", your_tag);
							imgui.SameLine();
							imgui.SetCursorPosX(15);
							if your_tag.v == "" or your_tag.v == nil then
								imgui.TextColored(imgui.ImColor(200, 200, 200, 200):GetVec4(), u8"Тег к обращаемому");
							end
							imgui.SameLine()
							imgui.SetCursorPosX(220);
							ShowHelpMarker(u8"Введите свой тег к обращаемому, если не хотите использовать его из настроек.\nОставьте поле пустым, если хотите использовать тег из настроек.")
							imgui.Dummy(imgui.ImVec2(0, 3)) 
							imgui.PushItemWidth(228);
							if your_tag.v ~= "" and your_tag.v ~= nil then
								imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImColor(156, 156, 156, 200):GetVec4())
								imgui.Combo("##orgs", num_dep3, dep.sel_all)
								imgui.PopStyleColor(1)
							else
								imgui.Combo("##orgs", num_dep3, dep.sel_all)
							end
								imgui.Dummy(imgui.ImVec2(0, 3)) 
							if imgui.Button(u8"Подключиться впервые", imgui.ImVec2(208, 25)) then
								for i,v in ipairs(dep.bool) do
									if v == true then
										dep.select_dep[2] = i
									end
								end
								sampSendChat(string.format("/d %sНа связь...", u8:decode(DepTxtEnd(prefix_end[2]))))
							end
							imgui.SameLine()
							ShowHelpMarker(u8"Отправит в чат следующее:\n\n/d ".. DepTxtEnd(prefix_end[2]) .. u8"На связь...\n\nПосле чего Вы начнёте общение в локальном чате.")
							if imgui.Button(u8"Подключиться по обращению", imgui.ImVec2(208, 25)) then
								for i,v in ipairs(dep.bool) do
									if v == true then
										dep.select_dep[2] = i
									end
								end
								sampSendChat(string.format("/d %sНа связи...", u8:decode(DepTxtEnd(prefix_end[2]))))
							end
							imgui.SameLine()
							ShowHelpMarker(u8"Отправит в чат следующее:\n\n/d ".. DepTxtEnd(prefix_end[2]) .. u8"На связи...\n\nПосле чего Вы начнёте общение в локальном чате.")
							if imgui.Button(u8"Подключиться тихо", imgui.ImVec2(208, 25)) then
								for i,v in ipairs(dep.bool) do
									if v == true then
										dep.select_dep[2] = i
									end
								end
							end
							imgui.SameLine()
							ShowHelpMarker(u8"Вы подключитесь к гос. структуре \"" .. dep.sel_all[num_dep3.v+1] .. u8"\" для дальнейшего обращения.\n\nВ чат департамента ничего не отправится.")
						end
					elseif dep.bool[5] then
						imgui.Dummy(imgui.ImVec2(0, 5))
						imgui.SetCursorPosX(60)
						imgui.Text(u8"Задано время:  "..dep.time[1]..":"..dep.time[2])
						imgui.Spacing()
						imgui.Spacing()
							imgui.SetCursorPosX(60)
							imgui.Text(u8"Часы\t\t   Минуты"); 
							imgui.SetCursorPosX(45)
							if imgui.SmallButton("<<") and dep.time[1] > 0 then dep.time[1] = dep.time[1] - 1 end
							imgui.SameLine()
							imgui.Text(tostring(dep.time[1]))
							imgui.SameLine()
							if imgui.SmallButton(">>") and dep.time[1] < 24 then dep.time[1] = dep.time[1] + 1 end
							imgui.SameLine()
							imgui.SetCursorPosX(125)
							if imgui.SmallButton("<<##1") and dep.time[2] > 0 then dep.time[2] = dep.time[2] - 5 end
							imgui.SameLine()
							imgui.Text(tostring(dep.time[2]))
							imgui.SameLine()
							if imgui.SmallButton(">>##1") and dep.time[2] < 55 then dep.time[2] = dep.time[2] + 5 end
						imgui.Spacing()
						imgui.Spacing()
						if imgui.Button(u8"Объявить", imgui.ImVec2(208, 25)) then
							lua_thread.create(function()
							local inpSob = string.format("%d,%d,%s", dep.time[1], dep.time[2], u8:decode(list_org[num_org.v+1]))
								sampSendChat(string.format("/d [%s] - [Информация] Перешёл на частоту 103,9", u8:decode(list_org[num_org.v+1])))
								wait(1750)
								sampSendChat(string.format("/d [%s] - [103,9] Занимаю гос.волну новостей для проведения собеседования.", u8:decode(list_org[num_org.v+1])))
								wait(500)
								sampSendChat("/lmenu")
								repeat wait(100) until sampIsDialogActive() and sampGetCurrentDialogId() == 1214
								sampSetCurrentDialogListItem(2)
								wait(100)
								sampCloseCurrentDialogWithButton(1)
								repeat wait(100) until sampIsDialogActive() and sampGetCurrentDialogId() == 1336
								sampSetCurrentDialogListItem(0)
								wait(100)
								sampCloseCurrentDialogWithButton(1)
								repeat wait(0) until sampIsDialogActive() and sampGetCurrentDialogId() == 1335
								wait(350)
								sampSetCurrentDialogEditboxText(inpSob)
								wait(350)
								sampCloseCurrentDialogWithButton(1)
								wait(1700)
								sampSendChat(string.format("/d [%s] - [Информация] Покидаю частоту 103,9.",  u8:decode(list_org[num_org.v+1]))) 
							end)
						end
					elseif  dep.bool[6] then
						imgui.Dummy(imgui.ImVec2(0, 5)) 
						if imgui.Button(u8"Объявить", imgui.ImVec2(208, 25)) then 
							sampSendChat(string.format("/d %sТех. неполадки.", u8:decode(DepTxtEnd(prefix_end[1]))))
						end
						imgui.SameLine()
						ShowHelpMarker(u8"Отправит в чат следующее:\n\n/d ".. DepTxtEnd(prefix_end[1]) .. u8"Тех. неполадки.")
					elseif dep.bool[7] then
						imgui.Spacing()
						imgui.PushItemWidth(225)
						if imgui.Combo("##news", dep.newsN, dep.news) then
							brp = 0
							lua_thread.create(function()
								deadgov = true
								if doesFileExist(dirml.."/MedicalHelper/Департамент/"..u8:decode(dep.news[dep.newsN.v+1])..".txt") then
									for line in io.lines(dirml.."/MedicalHelper/Департамент/"..u8:decode(dep.news[dep.newsN.v+1])..".txt") do
										if brp < 6 then
											trtxt[brp + 1].v = u8(line)
											brp = brp + 1
										end
									end
								end
								deadgov = false
							end)
						end
						imgui.PopItemWidth()
						imgui.Dummy(imgui.ImVec2(0, 2))
							
							imgui.Text(u8"Также можете сами добавить или")
							imgui.Text(u8"изменять новости.")
							imgui.SetCursorPos(imgui.ImVec2(133, 293))
							imgui.TextColoredRGB("{29EB2F}Папка")
							if imgui.IsItemHovered() then 
								imgui.SetTooltip(u8"Кликните, чтобы открыть папку.")
							end
							if imgui.IsItemClicked(0) then
								print(shell32.ShellExecuteA(nil, 'open', dirml.."/MedicalHelper/Департамент/", nil, nil, 1))
							end
						imgui.Dummy(imgui.ImVec2(0, 85))
						if imgui.Button(u8"Подать", imgui.ImVec2(208, 25)) then
							lua_thread.create(function()
								if doesFileExist(dirml.."/MedicalHelper/Департамент/"..u8:decode(dep.news[dep.newsN.v+1])..".txt") then
								deadgov = true
									for line in io.lines(dirml.."/MedicalHelper/Департамент/"..u8:decode(dep.news[dep.newsN.v+1])..".txt") do
										sampSendChat(line)
										wait(1800)
									end
								end
								deadgov = false
							end)
						end
							imgui.SameLine()
							ShowHelpMarker(u8"Отправит в чат следующее:\n\n".. trtxt[1].v.. "\n".. trtxt[2].v.. "\n".. trtxt[3].v .. "\n".. trtxt[4].v .. "\n".. trtxt[5].v .. "\n".. trtxt[6].v)
					elseif dep.select_dep[2] < 5 and dep.select_dep[2] ~= 0 then
						imgui.Dummy(imgui.ImVec2(0, 5)) 
						imgui.PushItemWidth(225)
						if dep.select_dep[1] == 1 then --ВСЕМ
							if imgui.Button(u8"Отключиться", imgui.ImVec2(208, 25)) then
								dep.select_dep[2] = 0
								sampSendChat(string.format("/d %sКонец связи...", u8:decode(DepTxtEnd(prefix_end[1]))))
							end
							imgui.SameLine()
							ShowHelpMarker(u8"Вы отключитесь от всех гос. структур. Система отправит в чат следующее:\n\n/d " .. DepTxtEnd(prefix_end[1]).. u8"Конец связи...")
							if imgui.Button(u8"Отключиться тихо", imgui.ImVec2(208, 25)) then
								dep.select_dep[2] = 0
							end
							imgui.SameLine()
							ShowHelpMarker(u8"Вы отключитесь от всех гос. структур.\n\nВ чат департамента ничего не отправится.")
						end
						if dep.select_dep[1] == 2 then --КОНКРЕТНОЕ
							if imgui.Button(u8"Отключиться", imgui.ImVec2(208, 25)) then
								dep.select_dep[2] = 0
								sampSendChat(string.format("/d %sКонец связи...", u8:decode(DepTxtEnd(prefix_end[2]))))
							end
							imgui.SameLine()
							ShowHelpMarker(u8"Вы отключитесь от гос. структуры \"" .. dep.sel_all[num_dep3.v+1] .. u8"\". Система отправит в чат следующее:\n\n/d " .. DepTxtEnd(prefix_end[2]).. u8"Конец связи...")
							if imgui.Button(u8"Отключиться тихо", imgui.ImVec2(208, 25)) then
								dep.select_dep[2] = 0
							end
							imgui.SameLine()
							ShowHelpMarker(u8"Вы отключитесь от гос. структуры \"" .. dep.sel_all[num_dep3.v+1] .. u8"\"\n\nВ чат департамента ничего не отправится.")
						end
						imgui.PopItemWidth()

					else
						imgui.SetCursorPos(imgui.ImVec2(23, 250)) 
						imgui.Text(u8"Выберите волну департамента")
					end
			imgui.EndGroup()
			imgui.SameLine()
			imgui.BeginChild("dep log", imgui.ImVec2(0, 0), true)
				imgui.SetCursorPosX(305)
				imgui.Text(u8"Локальный чат")
				if imgui.IsItemHovered() then imgui.SetTooltip(u8"Кликните ПКМ для очистки") end
				if imgui.IsItemClicked(1) then dep.dlog = {} end
					imgui.BeginChild("dep logg", imgui.ImVec2(0, 325), true)
						for i,v in ipairs(dep.dlog) do
							imgui.TextColoredRGB(v)
						end
						imgui.SetScrollY(imgui.GetScrollMaxY())
					imgui.EndChild()
				imgui.Spacing()
				imgui.Text(u8"Вы:");
				imgui.SameLine()
				imgui.PushItemWidth(550)
				imgui.InputText("##chat", dep.input)
				imgui.PopItemWidth()
				imgui.SameLine()
				if dep.select_dep[2] ~= 0 and not dep.bool[5] and not dep.bool[6] and not dep.bool[7] then
					if imgui.Button(u8"Отправить", imgui.ImVec2(80, 21.5)) then
						if dep.select_dep[2] < 3 and dep.select_dep[2] > 0 then
							if dep.bool[1] then
								sampSendChat(string.format("/d %s"..u8:decode(dep.input.v), u8:decode(DepTxtEnd(prefix_end[1]))))
							elseif dep.bool[2] then
								sampSendChat(string.format("/d %s"..u8:decode(dep.input.v), u8:decode(DepTxtEnd(prefix_end[num_dep3.v + 1]))))
							end
						end
						dep.input.v = ""
					end
				else
					imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(156, 156, 156, 200):GetVec4())
					imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(156, 156, 156, 200):GetVec4())
					imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(156, 156, 156, 200):GetVec4())
					imgui.Button(u8"Отправить", imgui.ImVec2(80, 21.5))
					imgui.PopStyleColor(3)
				end
				if dep.select_dep[2] == 0 then
					imgui.SameLine()
					ShowHelpMarker(u8"Здесь будет заранее отображаться отправляемый текст.\n\nДля подключения к департаменту воспользуйтесь кнопками слева.")
				elseif dep.bool[1] then
					imgui.SameLine()
					ShowHelpMarker(u8"Отправит в чат следующее:\n\n/d ".. DepTxtEnd(prefix_end[1]) .. dep.input.v)
				elseif dep.bool[2] then
					imgui.SameLine()
					ShowHelpMarker(u8"Отправит в чат следующее:\n\n/d ".. DepTxtEnd(prefix_end[num_dep3.v + 1]) .. dep.input.v)
				elseif dep.bool[5] or dep.bool[6] or dep.bool[7] then
					imgui.SameLine()
					ShowHelpMarker(u8"Здесь будет заранее отображаться отправляемый текст.\n\nДля подключения к департаменту воспользуйтесь кнопками слева.")
				end
			
				---------------------------------------------------
			imgui.EndChild()
		imgui.End()
end

function settingMassiveSave()
	setting.nick = u8:decode(buf_nick.v)
	setting.teg = u8:decode(buf_teg.v)
	setting.org = num_org.v
	setting.sex = num_sex.v
	setting.rank = num_rank.v
	setting.time = cb_time.v
	setting.timeTx = u8:decode(buf_time.v)
	setting.timeDo = cb_timeDo.v
	setting.rac = cb_rac.v
	setting.racTx = u8:decode(buf_rac.v)
	setting.lec = buf_lec.v
	setting.rec = buf_rec.v
	setting.narko = buf_narko.v
	setting.tatu = buf_tatu.v
	setting.ant = buf_ant.v
	setting.chat1 = cb_chat1.v
	setting.chat2 = cb_chat2.v
	setting.chat3 = cb_chat3.v
	setting.chathud = cb_hud.v
	setting.arp = arep
	setting.setver = setver
	setting.htime = cb_hudTime.v
	setting.hping = hudPing
	setting.orgl = {}
	setting.rankl = {}
	setting.theme = num_theme.v
	setting.themAngle = theme_Angle.v
	theme_AngleTest = theme_Angle.v
	setting.spawn = accept_spawn.v
	setting.autolec = accept_autolec.v
	setting.prikol = prikol.v
	setting2.funcPKM.func = chg_funcPKM.func.v
	for i = 1, #chg_funcPKM.slider do
		setting2.funcPKM.slider[i] = chg_funcPKM.slider[i].v
	end
	for i,v in ipairs(chgName.org) do
		setting.orgl[i] = u8:decode(v)
	end
	for i,v in ipairs(chgName.rank) do
		setting.rankl[i] = u8:decode(v)
	end
	for i = 1, 4 do
		setting.mede[i] = buf_mede[i].v
		setting.upmede[i] = buf_upmede[i].v
	end
	local f = io.open(dirml.."/MedicalHelper/MainSetting.med", "w")
	f:write(encodeJson(setting))
	f:flush()
	f:close()
	local f = io.open(dirml.."/MedicalHelper/MainSetting_2.med", "w")
	f:write(encodeJson(setting2))
	f:flush()
	f:close()
end

function settingMassiveSave2()
	for i, v in ipairs(setCmdEdit[selected_cmd].sec) do
		setCmdEdit[selected_cmd].sec[i] = chgCmd[i].v * 1000
		setCmdEdit[selected_cmd].text[i] = chgCmdSet[i].v
	end
	local f = io.open(dirml.."/MedicalHelper/Отыгровки.med", "w")
	f:write(encodeJson(setCmdEdit))
	f:flush()
	f:close()
end

function settingMassiveMembers()
	membScr = {
		func = C_membScr.func.v,
		pos = {x = C_membScr.pos.x.v, y = C_membScr.pos.y.v},
		forma = C_membScr.forma.v,
		numrank = C_membScr.numrank.v,
		id = C_membScr.id.v,
		afk = C_membScr.afk.v,
		dialog = C_membScr.dialog.v,
		vergor = C_membScr.vergor.v,
		font = {
			size = C_membScr.font.size.v,
			flag = C_membScr.font.flag.v,
			distance = C_membScr.font.distance.v,
			visible = C_membScr.font.visible.v
		},
		color = {
				col_title 	= C_membScr.color.col_title,
				col_default =  C_membScr.color.col_default,
				col_no_work =  C_membScr.color.col_no_work
		}	
	}
	
	local f = io.open(dirml.."/MedicalHelper/MainMembers.med", "w")
	f:write(encodeJson(membScr))
	f:flush()
	f:close()
end

function profitmoney()
	
	--imgui.SameLine()
	imgui.SetCursorPosX(152)
	imgui.SetCursorPosY(41)
	if select_menu_money then
		imgui.PushStyleColor(imgui.Col.Button, colButActiveMenu)
		if imgui.Button(u8"Статистика прибыли", imgui.ImVec2(345, 24)) then select_menu_money = true end
		imgui.PopStyleColor(1)
		imgui.SetCursorPosX(499)
		imgui.SetCursorPosY(41)
		imgui.PushStyleColor(imgui.Col.Button, imgui.GetStyle().Colors[imgui.Col.WindowBg])
		if imgui.Button(u8"Статистика онлайна", imgui.ImVec2(345, 24)) then select_menu_money = false end
		imgui.PopStyleColor(1)
	else
		imgui.PushStyleColor(imgui.Col.Button, imgui.GetStyle().Colors[imgui.Col.WindowBg])
		if imgui.Button(u8"Статистика прибыли", imgui.ImVec2(345, 24)) then select_menu_money = true end
		imgui.PopStyleColor(1)
		imgui.SetCursorPosX(499)
		imgui.SetCursorPosY(41)
		imgui.PushStyleColor(imgui.Col.Button, colButActiveMenu)
		if imgui.Button(u8"Статистика онлайна", imgui.ImVec2(345, 24)) then select_menu_money = false end
		imgui.PopStyleColor(1)
	end
	imgui.SameLine()
	if select_menu_money then
		local function text_profit(id_param)
			if profit_money.payday[id_param] ~= 0 then
				imgui.TextColoredRGB(" Зарплата: {36cf5c}"..point_sum(profit_money.payday[id_param]).."$")
			end
			if profit_money.lec[id_param] ~= 0 then
				imgui.TextColoredRGB(" Лечение: {36cf5c}"..point_sum(profit_money.lec[id_param]).."$")
			end
			if profit_money.medcard[id_param] ~= 0 then
				imgui.TextColoredRGB(" Оформление мед.карт: {36cf5c}"..point_sum(profit_money.medcard[id_param]).."$")
			end
			if profit_money.narko[id_param] ~= 0 then
				imgui.TextColoredRGB(" Снятие наркозависимости: {36cf5c}"..point_sum(profit_money.narko[id_param]).."$")
			end
			if profit_money.vac[id_param] ~= 0 then
				imgui.TextColoredRGB(" Вакцинирование: {36cf5c}"..point_sum(profit_money.vac[id_param]).."$")
			end
			if profit_money.ant[id_param] ~= 0 then
				imgui.TextColoredRGB(" Продажа антибиотиков: {36cf5c}"..point_sum(profit_money.ant[id_param]).."$")
			end
			if profit_money.rec[id_param] ~= 0 then
				imgui.TextColoredRGB(" Продажа рецептов: {36cf5c}"..point_sum(profit_money.rec[id_param]).."$")
			end
			if profit_money.medcam[id_param] ~= 0 then
				imgui.TextColoredRGB(" Перевозка медикаментов: {36cf5c}"..point_sum(profit_money.medcam[id_param]).."$")
			end
			if profit_money.cure[id_param] ~= 0 then
				imgui.TextColoredRGB(" За вызовы: {36cf5c}"..point_sum(profit_money.cure[id_param]).."$")
			end
			if profit_money.strah[id_param] ~= 0 then
				imgui.TextColoredRGB(" Оформление страховок: {36cf5c}"..point_sum(profit_money.strah[id_param]).."$")
			end
			if profit_money.tatu[id_param] ~= 0 then
				imgui.TextColoredRGB(" Сведение татуировок: {36cf5c}"..point_sum(profit_money.tatu[id_param]).."$")
			end
			if profit_money.premium[id_param] ~= 0 then
				imgui.TextColoredRGB(" Премии от руководства: {36cf5c}"..point_sum(profit_money.premium[id_param]).."$")
			end
		end
		local function text_profit_2(param_id)
			imgui.Separator()
			imgui.SetCursorPosX(315)
			imgui.TextColoredRGB(profit_money.date_week[param_id])
			imgui.Separator()
			imgui.Separator()
			imgui.Dummy(imgui.ImVec2(0, 3))
			text_profit(param_id)
			local money_all = point_sum(profit_money.payday[param_id] + profit_money.lec[param_id] + profit_money.medcard[param_id] + profit_money.narko[param_id] + profit_money.vac[param_id] + profit_money.ant[param_id] + profit_money.rec[param_id] + profit_money.medcam[param_id] + profit_money.cure[param_id] + profit_money.strah[param_id] + profit_money.tatu[param_id] + profit_money.premium[param_id])
			if money_all ~= "0" then
			imgui.TextColoredRGB(" Итого за день: {36cf5c}"..money_all.."$")
			else
			imgui.TextColoredRGB(" За этот день Вы ничего не заработали.")
			end
			imgui.Dummy(imgui.ImVec2(0, 3))
			imgui.Separator()
		end
	imgui.SetCursorPosY(75)
	imgui.SetCursorPosX(152)
	imgui.BeginChild("money", imgui.ImVec2(695, 380), true)
	imgui.Dummy(imgui.ImVec2(0, 3))
	imgui.SetCursorPosX(90)
	imgui.TextColoredRGB("Здесь находится информация о Вашей прибыли за последние семь дней.")
	imgui.SameLine()
	ShowHelpMarker(u8"Всё, что Вы заработали в рамках Вашей организации сохраняется здесь в виде статистики.\nИнформация отображается за последние 7 дней. Более ранние события удаляются.")
	imgui.Dummy(imgui.ImVec2(0, 3))
	imgui.Separator()
	imgui.Separator()
	imgui.SetCursorPosX(315)
	imgui.TextColoredRGB(profit_money.date_week[1])
	imgui.Separator()
	imgui.Separator()
	imgui.Dummy(imgui.ImVec2(0, 3))
	text_profit(1)
	local moneyall1 = point_sum(profit_money.payday[1] + profit_money.lec[1] + profit_money.medcard[1] + profit_money.narko[1] + profit_money.vac[1] + profit_money.ant[1] + profit_money.rec[1] + profit_money.medcam[1] + profit_money.cure[1] + profit_money.strah[1] + profit_money.tatu[1] + profit_money.premium[1])
	if moneyall1 ~= "0" then
	imgui.TextColoredRGB(" Итого за день: {36cf5c}"..moneyall1.."$")
	else
	imgui.TextColoredRGB(" За сегодня Вы ничего не заработали.")
	end
	imgui.Dummy(imgui.ImVec2(0, 3))
	imgui.Separator()
	for k = 2, 7 do
		if profit_money.date_week[k] ~= "" then
			text_profit_2(k)
		end
	end
	profit_money.total_week = profit_money.payday[1] + profit_money.payday[2] + profit_money.payday[3] + profit_money.payday[4] + profit_money.payday[5] + profit_money.payday[6] + profit_money.payday[7] +
	profit_money.lec[1] + profit_money.lec[2] + profit_money.lec[3] + profit_money.lec[4] + profit_money.lec[5] + profit_money.lec[6] + profit_money.lec[7] +
	profit_money.medcard[1] + profit_money.medcard[2] + profit_money.medcard[3] + profit_money.medcard[4] + profit_money.medcard[5] + profit_money.medcard[6] + profit_money.medcard[7] +
	profit_money.narko[1] + profit_money.narko[2] + profit_money.narko[3] + profit_money.narko[4] + profit_money.narko[5] + profit_money.narko[6] + profit_money.narko[7] +
	profit_money.vac[1] + profit_money.vac[2] + profit_money.vac[3] + profit_money.vac[4] + profit_money.vac[5] + profit_money.vac[6] + profit_money.vac[7] +
	profit_money.ant[1] + profit_money.ant[2] + profit_money.ant[3] + profit_money.ant[4] + profit_money.ant[5] + profit_money.ant[6] + profit_money.ant[7] +
	profit_money.rec[1] + profit_money.rec[2] + profit_money.rec[3] + profit_money.rec[4] + profit_money.rec[5] + profit_money.rec[6] + profit_money.rec[7] +
	profit_money.medcam[1] + profit_money.medcam[2] + profit_money.medcam[3] + profit_money.medcam[4] + profit_money.medcam[5] + profit_money.medcam[6] + profit_money.medcam[7] +
	profit_money.cure[1] + profit_money.cure[2] + profit_money.cure[3] + profit_money.cure[4] + profit_money.cure[5] + profit_money.cure[6] + profit_money.cure[7] +
	profit_money.strah[1] + profit_money.strah[2] + profit_money.strah[3] + profit_money.strah[4] + profit_money.strah[5] + profit_money.strah[6] + profit_money.strah[7] +
	profit_money.tatu[1] + profit_money.tatu[2] + profit_money.tatu[3] + profit_money.tatu[4] + profit_money.tatu[5] + profit_money.tatu[6] + profit_money.tatu[7] +
	profit_money.premium[1] + profit_money.premium[2] + profit_money.premium[3] + profit_money.premium[4] + profit_money.premium[5] + profit_money.premium[6] + profit_money.premium[7] +
	profit_money.other[1] + profit_money.other[2] + profit_money.other[3] + profit_money.other[4] + profit_money.other[5] + profit_money.other[6] + profit_money.other[7]
	imgui.Dummy(imgui.ImVec2(0, 3))
	imgui.TextColoredRGB(" Итого за неделю: {36cf5c}"..point_sum(profit_money.total_week).."$")
	imgui.TextColoredRGB(" Итого за всё время: {36cf5c}"..point_sum(profit_money.total_all).."$")
	imgui.Dummy(imgui.ImVec2(0, 3))
	imgui.Separator()
	imgui.Dummy(imgui.ImVec2(0, 3))
	if imgui.Button(u8"Сбросить статистику", imgui.ImVec2(666,23)) then 
		imgui.OpenPopup(u8"MH | Подтверждение действия")
	end
	if imgui.BeginPopupModal(u8"MH | Подтверждение действия", null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove) then
		imgui.Dummy(imgui.ImVec2(0, 3))
		imgui.TextColoredRGB("Вы действительно хотите очистить статистику?\n          Статистика сбросится за всё время.")
		imgui.Dummy(imgui.ImVec2(0, 5))
		imgui.Separator()
		imgui.Dummy(imgui.ImVec2(0, 1))
		if imgui.Button(u8"Сбросить", imgui.ImVec2(152, 0)) then 
			profit_money = {
			payday = {0, 0, 0, 0, 0, 0, 0},
			lec = {0, 0, 0, 0, 0, 0, 0},
			medcard = {0, 0, 0, 0, 0, 0, 0},
			narko = {0, 0, 0, 0, 0, 0, 0},
			vac = {0, 0, 0, 0, 0, 0, 0},
			ant = {0, 0, 0, 0, 0, 0, 0},
			rec = {0, 0, 0, 0, 0, 0, 0},
			medcam = {0, 0, 0, 0, 0, 0, 0},
			cure = {0, 0, 0, 0, 0, 0, 0},
			strah = {0, 0, 0, 0, 0, 0, 0},
			tatu = {0, 0, 0, 0, 0, 0, 0},
			premium = {0, 0, 0, 0, 0, 0, 0},
			other = {0, 0, 0, 0, 0, 0, 0},
			total_week = 0,
			total_all = 0,
			date_num = {0, 0},
			date_today = {os.date("%d") + 0, os.date("%m") + 0, os.date("%Y") + 0},
			date_last = {os.date("%d") + 0, os.date("%m") + 0, os.date("%Y") + 0},
			date_week = {os.date("%d.%m.%Y"), "", "", "", "", "", ""}
		}
			local f = io.open(dirml.."/MedicalHelper/profit.med", "w")
			f:write(encodeJson(profit_money))
			f:flush()
			f:close()
			imgui.CloseCurrentPopup();
			lockPlayerControl(false);
		end 
		imgui.SameLine();
		if imgui.Button(u8"Отмена", imgui.ImVec2(152, 0)) then 
			imgui.CloseCurrentPopup();
			lockPlayerControl(false);
		end 
	imgui.EndPopup()
	end
	imgui.Dummy(imgui.ImVec2(0, 3))
	imgui.EndChild()
	end
	if not select_menu_money then
		local function text_online(id_param)
			imgui.Separator()
			imgui.SetCursorPosX(315)
			imgui.TextColoredRGB(online_stat.date_week[id_param])
			imgui.Separator()
			imgui.Separator()
			imgui.Dummy(imgui.ImVec2(0, 3))
			imgui.TextColoredRGB(" Чистый онлайн за день: {36cf5c}"..print_time(online_stat.clean[id_param]))
			imgui.TextColoredRGB(" АФК за день: {36cf5c}"..print_time(online_stat.afk[id_param]))
			imgui.TextColoredRGB(" Всего за день: {36cf5c}"..print_time(online_stat.all[id_param]))
			imgui.Dummy(imgui.ImVec2(0, 3))
			imgui.Separator()
		end
	imgui.SetCursorPosY(75)
	imgui.SetCursorPosX(152)
	imgui.BeginChild("money", imgui.ImVec2(695, 380), true)
	imgui.Dummy(imgui.ImVec2(0, 3))
	imgui.SetCursorPosX(90)
	imgui.TextColoredRGB("Здесь находится информация о Вашем онлайне за последние семь дней.")
	imgui.SameLine()
	ShowHelpMarker(u8"Всё время, что Вы проводите в игре сохраняется здесь в виде статистики.\nИнформация отображается за последние 7 дней. Более ранние события удаляются.")
	imgui.Dummy(imgui.ImVec2(0, 9))
	imgui.Separator()
	imgui.Separator()
	imgui.SetCursorPosX(315)
	imgui.TextColoredRGB(online_stat.date_week[1])
	imgui.Separator()
	imgui.Separator()
	imgui.Dummy(imgui.ImVec2(0, 3))
	imgui.TextColoredRGB(" Чистый онлайн за день: {36cf5c}"..print_time(online_stat.clean[1]))
	imgui.TextColoredRGB(" АФК за день: {36cf5c}"..print_time(online_stat.afk[1]))
	imgui.TextColoredRGB(" Всего за день: {36cf5c}"..print_time(online_stat.all[1]))
	imgui.Spacing()
	imgui.Spacing()
	imgui.TextColoredRGB(" Чистый за сессию: {36cf5c}"..print_time(session_clean.v))
	imgui.TextColoredRGB(" АФК за сессию: {36cf5c}"..print_time(session_afk.v))
	imgui.TextColoredRGB(" Всего за сессию: {36cf5c}"..print_time(session_all.v))
	imgui.Dummy(imgui.ImVec2(0, 3))
	imgui.Separator()
	for k = 2, 7 do
		if online_stat.date_week[k] ~= "" then
			text_online(k)
		end
	end
	online_stat.total_week = online_stat.clean[1] + online_stat.clean[2] + online_stat.clean[3] + online_stat.clean[4] + online_stat.clean[5] + online_stat.clean[6] + online_stat.clean[7]
	imgui.Dummy(imgui.ImVec2(0, 3))
	imgui.TextColoredRGB(" Чистый онлайн за неделю: {36cf5c}"..print_time(online_stat.total_week))
	imgui.TextColoredRGB(" Чистый онлайн за всё время: {36cf5c}"..print_time(online_stat.total_all))
	imgui.Dummy(imgui.ImVec2(0, 3))
	imgui.Separator()
	imgui.Dummy(imgui.ImVec2(0, 3))
	if imgui.Button(u8"Сбросить статистику", imgui.ImVec2(666,23)) then 
		imgui.OpenPopup(u8"Подтверждение действия")
	end
	if imgui.BeginPopupModal(u8"Подтверждение действия", null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove) then
		imgui.Dummy(imgui.ImVec2(0, 3))
		imgui.TextColoredRGB("Вы действительно хотите очистить статистику?\n          Статистика сбросится за всё время.")
		imgui.Dummy(imgui.ImVec2(0, 5))
		imgui.Separator()
		imgui.Dummy(imgui.ImVec2(0, 1))
		if imgui.Button(u8"Сбросить", imgui.ImVec2(152, 0)) then 
			online_stat = {
				clean = {0, 0, 0, 0, 0, 0, 0},
				afk = {0, 0, 0, 0, 0, 0, 0},
				all = {0, 0, 0, 0, 0, 0, 0},
				total_week = 0,
				total_all = 0,
				date_num = {0, 0},
				date_today = {os.date("%d") + 0, os.date("%m") + 0, os.date("%Y") + 0},
				date_last = {os.date("%d") + 0, os.date("%m") + 0, os.date("%Y") + 0},
				date_week = {os.date("%d.%m.%Y"), "", "", "", "", "", ""}
			}
			session_clean.v = 0
			session_afk.v = 0
			session_all.v = 0
			local f = io.open(dirml.."/MedicalHelper/onlinestat.med", "w")
			f:write(encodeJson(online_stat))
			f:flush()
			f:close()
			imgui.CloseCurrentPopup();
			lockPlayerControl(false);
		end 
		imgui.SameLine();
		if imgui.Button(u8"Отмена", imgui.ImVec2(152, 0)) then 
			imgui.CloseCurrentPopup();
			lockPlayerControl(false);
		end 
	imgui.EndPopup()
	end
	imgui.Dummy(imgui.ImVec2(0, 3))
	imgui.EndChild()
	end
end

function readID()
	if #sobes.logChat ~= 0 then
		return 16384
	else 
		return 0
	end
end

function rankFix()
	if num_rank.v == 10 then
		return u8:decode(list_rank[num_rank.v+1])
	else
		return u8:decode(list_org[num_org.v+1])
	end
end

function ButtonDep(desk, bool) --> Подсветка кнопок департамента
	local retBool = false
	if bool then
		imgui.PushStyleColor(imgui.Col.Button, colButActiveMenu)
		retBool = imgui.Button(desk, imgui.ImVec2(215, 44))
		imgui.PopStyleColor(1)
	elseif not bool and dep.select_dep[2] == 0 then
		imgui.PushStyleColor(imgui.Col.Button, imgui.GetStyle().Colors[imgui.Col.WindowBg])
		retBool = imgui.Button(desk, imgui.ImVec2(215, 44))
		imgui.PopStyleColor(1)
	elseif not bool and dep.select_dep[2] ~= 0 then
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(156, 156, 156, 200):GetVec4())
		imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(156, 156, 156, 200):GetVec4())
		imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(156, 156, 156, 200):GetVec4())
		retBool = imgui.Button(desk, imgui.ImVec2(215, 44))
		imgui.PopStyleColor(3)
	end
	return retBool
end

function sobesRP(id)
	if id == 1 then
		sobes.logChat[#sobes.logChat+1] = "{FFC000}Вы: {FFFFFF}Приветствие. Просьба показать документы."
		sobes.player.name = getPlayerNickName(tonumber(sobes.selID.v))
		sampSendChat(string.format("Приветствую Вас на собеседование Я, %s - %s", u8:decode(buf_nick.v), u8:decode(chgName.rank[num_rank.v+1])))
		wait(1700)
		sampSendChat("Предъявите пожалуйста Ваш пакет документов, а именно: паспорт и мед.карту.")
		wait(1700)
		sampSendChat(string.format("/n Отыгрывая RP, команды: /showpass %d; /showmc %d - с использованием /me /do ", myid, myid))
		while true do
			wait(0)
			if sobWin.v then
			if sobes.player.zak ~= 0 and sobes.player.heal ~= "" then break end
			if sampIsDialogActive() then
				local dId = sampGetCurrentDialogId()
				if dId == 1234 then
					local dText = sampGetDialogText()
					if dText:find("Лет в штате") and dText:find("Законопослушность") then
					HideDialogInTh()
					if dText:find("Организация") then sobes.player.work = "Работает" else sobes.player.work = "Без работы" end
						if dText:match("Имя: {FFD700}(%S+)") == sobes.player.name then
							sobes.player.let = tonumber(dText:match("Лет в штате: {FFD700}(%d+)"))
							sobes.player.zak = tonumber(dText:match("Законопослушность: {FFD700}(%d+)"))
							sampSendChat("/me "..chsex("посмотрел", "посмотрела").." информацию в паспорте, после чего "..chsex("отдал","отдала").." его человеку напротив")
							if sobes.player.let >= 3 then
								if sobes.player.zak >= 35 then
									if not dText:find("{FF6200} "..list_org_BL[num_org.v+1]) then
										table.insert(sobes.logChat, "{54A8F2}"..sobes.player.name.."{FFFFFF}: Показал(а) паспорт. Не имеет проблем.")
										sobes.player.bl = "Не найден(а)"
										if sobes.player.narko == 0.1 then
											sampSendChat("Хорошо, теперь мед.карту.")
											wait(1700)
											sampSendChat("/n /showmc "..myid)
										end
									else
										table.insert(sobes.logChat, "{54A8F2}"..sobes.player.name.."{FFFFFF}: Показал(а) паспорт. Находится в ЧС вашей больницы.")
											sampSendChat("Извиняюсь, но Вы нам не подходите.")
											wait(1700)
											sampSendChat("Вы состоите в Чёрном списке "..u8:decode(chgName.org[num_org.v+1]))
										sobes.player.bl = list_org_BL[num_org.v+1]
									--	sobes.getStats = false
										return
									end
								else --player = {name = "", let = 0, zak = 0, work = "", bl = "", heal = "", narko = 0},
									table.insert(sobes.logChat, "{54A8F2}"..sobes.player.name.."{FFFFFF}: Показал(а) паспорт. Недостаточно законопослушности.")
										sampSendChat("Извиняюсь, но Вы нам не подходите.")
										wait(1700)
										sampSendChat("У Вас проблемы с законом.")
										wait(1700)
										sampSendChat("/n Необходимо законопослушнось 35+")
										wait(1700)
										sampSendChat("Приходите в следующий раз.")
								--	sobes.getStats = false
									return
								end
							else
								table.insert(sobes.logChat, "{54A8F2}"..sobes.player.name.."{FFFFFF}: Показал(а) паспорт. Мало проживает в штате.")
									sampSendChat("Извиняюсь, но Вы нам не подходите.")
									wait(1700)
									sampSendChat("Необходимо как минимум проживать 3 года в штате.")
									wait(1700)
									sampSendChat("Приходите в следующий раз.")
							--	sobes.getStats = false
								return
							end
						else
							table.insert(sobes.logChat, "{E74E28}[Ошибка]{FFFFFF}: Кто-то другой пытался показать паспорт.") 
						end 
					end
					if dText:find("Наркозависимость") then
						HideDialogInTh()
						if dText:match("Имя: (%S+)") == sobes.player.name then
							sampSendChat("/me "..chsex("посмотрел", "посмотрела").." информацию в мед.карте, после чего "..chsex("отдал","отдала").." его человеку напротив")
							sobes.player.narko = tonumber(dText:match("Наркозависимость: (%d+)"));
							if dText:find("Полностью здоровый") then
								if sobes.player.narko == 0 then
									table.insert(sobes.logChat, "{54A8F2}"..sobes.player.name.."{FFFFFF}: Показал(а) мед.карту. Всё в порядке.")
									sobes.player.heal = "Здоров"
									if sobes.player.zak == 0 then
											sampSendChat("Хорошо, теперь паспорт.")
											wait(1700)
											sampSendChat("/n /showpass "..myid)
									end
								else
									table.insert(sobes.logChat, "{54A8F2}"..sobes.player.name.."{FFFFFF}: Показал(а) мед.карту. Имеет наркозависимость.")
									sobes.player.heal = "Здоров"
									if sobes.player.zak == 0 then
										sampSendChat("Хорошо, Ваш паспорт пожалуйста.")
										wait(1700)
										sampSendChat("/n /showpass "..myid)
									end
									-- sampSendChat("Извиняюсь, но Вы имеете наркозависимость.")
									-- wait(1700)
									-- sampSendChat("Вы можете излечиться на месте или прийти в следующий раз.")
									--	sobes.getStats = false
									--	return
								end
							else 
								table.insert(sobes.logChat, "{54A8F2}"..sobes.player.name.."{FFFFFF}: Показал(а) мед.карту. Не здоров.")
								sampSendChat("Извиняюсь, но У Вас проблемы со здоровьем.")
								wait(1700)
								sampSendChat("У Вас проблемы со здоровьем. Имеются психическое растройство.")
								sobes.player.heal = "Имеются отклонения"
								--	sobes.getStats = false
								--	return
							end
						else
							table.insert(sobes.logChat, "{E74E28}[Ошибка]{FFFFFF}: Кто-то другой пытался показать мед.карту.") 
						end 
					end
				end
			end
			end
		end
		table.insert(sobes.logChat, "{FFC000}Вы: {FFFFFF}Проверка документов закончена.")
		wait(1700)
		if sobes.player.work == "Без работы" then
			sampSendChat("Отлично, у Вас всё в порядке с документами.")
			sobes.nextQ = true
			return
		else
			sampSendChat("Отлично, у Вас всё в порядке с документами.")
			wait(2000)
			sampSendChat("Но Вы работаете на другой государственной работе, требуется оставить форму своему работодателю.")
			wait(2000)
			sampSendChat("/n Увольтесь из работы, в который Вы сейчас состоите")
			wait(2000)
			sampSendChat("/n Уволиться с помощью команды /out при налчии Titan VIP или попросите в рацию.")
			sobes.nextQ = true
			return
		end
	end
	if id == 2 then
		sampSendChat("Теперь я задам Вам несколько вопросов.")
		wait(1700)
		table.insert(sobes.logChat, "{FFC000}Вы: {FFFFFF}Вопрос: С какой целью Вы решили устроиться к нам в Больницу?.")
		sampSendChat("С какой целью Вы решили устроиться к нам в Больницу?")
	end
	if id == 3 then
		table.insert(sobes.logChat, "{FFC000}Вы: {FFFFFF}Вопрос: Есть ли у Вас спец.рация \"Discord\"?.")
		sampSendChat("Есть ли у Вас спец.рация \"Discord\"?.")
	end
	if id == 4 then
	table.insert(sobes.logChat, "{FFC000}Вы: {FFFFFF}Принятие игрока...")
	sampSendChat("Отлично, Вы приняты к нам на работу.")
	sobes.nextQ = false
		if num_rank.v+1 <= 8 then
			wait(1700)
			sampSendChat("Подойдите, пожалуйста, к Зам.Главного врача или Главному врачу")
			table.insert(sobes.logChat, "{FFC000}Вы: {FFFFFF}Пригласили игрока в организацию.")
			sobes.input.v = ""
			sobes.player = {name = "", let = 0, zak = 0, work = "", bl = "", heal = "", narko = 0.1}
			sobes.selID.v = ""
			sobes.logChat = {}
			sobes.nextQ = false
			sobes.num = 0
		else
		if sampIsPlayerConnected(sobes.selID.v) and id ~= sampGetPlayerIdByCharHandle(playerPed) then
			nick = getPlayerNickName(sobes.selID.v)
			local nm = trst(nick)
			wait(1700)
			sampSendChat("Сейчас я выдам Вам ключи от шкафчика с формой и другими вещами.")
			wait(1700)
			sampSendChat("/do В кармане халата находятся ключи отшкафчиков")
			wait(1700)
			sampSendChat("/me потянувшись во внутренний карман халата, "..chsex("достал","достала").." оттуда ключ")
			wait(1700)
			sampSendChat("/me передал".. chsex("", "а") .." ключ от шкафчика №"..sobes.selID.v.." с формой Интерна человеку напротив")
			wait(1700)
			sampSendChat("/invite "..sobes.selID.v)
			wait(1700)
			sampSendChat("/r Приветствуем нового сотрудника нашей организации - "..nm..".")
			else
			sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} Данного игрока не существует, либо это Вы!", 0xFF8FA2)
			end
			table.insert(sobes.logChat, "{FFC000}Вы: {FFFFFF}Пригласили игрока в организацию.")
			sobes.input.v = ""
			sobes.player = {name = "", let = 0, zak = 0, work = "", bl = "", heal = "", narko = 0.1}
			sobes.selID.v = ""
			sobes.logChat = {}
			sobes.nextQ = false
			sobes.num = 0
		end
	end
	if id == 5 then
		wait(1000)
		sampSendChat("Извиняюсь, но у Вас отпечатка в паспорте")
		wait(1700)
		sampSendChat("/n НонРП ник или другая причина.")
		sobes.input.v = ""
		sobes.player = {name = "", let = 0, zak = 0, work = "", bl = "", heal = "", narko = 0.1}
		sobes.selID.v = ""
		sobes.logChat = {}
		sobes.nextQ = false
		sobes.num = 0
	end
	if id == 6 then
		wait(1000)
		sampSendChat("Извиняюсь, но требуется проживать в штате как минимум 3 года.")
		sobes.input.v = ""
		sobes.player = {name = "", let = 0, zak = 0, work = "", bl = "", heal = "", narko = 0.1}
		sobes.selID.v = ""
		sobes.logChat = {}
		sobes.nextQ = false
		sobes.num = 0
	end
	if id == 7 then --sampSendChat("")
		wait(1000)
		sampSendChat("Извиняюсь, но у Вас проблемы с законом.")
		wait(1700)
		sampSendChat("/n Требуется минимум 35 законопослушности.")
		sobes.input.v = ""
		sobes.player = {name = "", let = 0, zak = 0, work = "", bl = "", heal = "", narko = 0.1}
		sobes.selID.v = ""
		sobes.logChat = {}
		sobes.nextQ = false
		sobes.num = 0
	end
	if id == 8 then
		wait(1000)
		sampSendChat("Извиняюсь, Вы работаете на другой государственной работе.")
		wait(1700)
		sampSendChat("/n Увольтесь из работы, в который Вы сейчас состоите")
		wait(1700)
		sampSendChat("/n Уволиться с помощью команды /out при налчии Titan VIP или попросите в рацию.")
		sobes.input.v = ""
		sobes.player = {name = "", let = 0, zak = 0, work = "", bl = "", heal = "", narko = 0.1}
		sobes.selID.v = ""
		sobes.logChat = {}
		sobes.nextQ = false
		sobes.num = 0
	end
	if id == 9 then
		wait(1000)
		sampSendChat("Извиняюсь, но Вы состоите в Черном Списке нашей больнице.")
		wait(1700)
		sampSendChat("/n Для вынесения из ЧС требуется оставить заявку на форуме в разделе Мин.Здрав.")
		sobes.input.v = ""
		sobes.player = {name = "", let = 0, zak = 0, work = "", bl = "", heal = "", narko = 0.1}
		sobes.selID.v = ""
		sobes.logChat = {}
		sobes.nextQ = false
		sobes.num = 0
	end
	if id == 10 then
		wait(1000)
		sampSendChat("Извиняюсь, но у Вас проблемы со здоровьем.")
		sobes.input.v = ""
		sobes.player = {name = "", let = 0, zak = 0, work = "", bl = "", heal = "", narko = 0.1}
		sobes.selID.v = ""
		sobes.logChat = {}
		sobes.nextQ = false
		sobes.num = 0
	end
	if id == 11 then
		wait(1000)
		sampSendChat("Извиняюсь, но у Вас имеется наркозависимость.")
		wait(1700)
		sampSendChat("Для лечения этого можете купить таблетку в магазине или вылечиться у нас.")
		sobes.input.v = ""
		sobes.player = {name = "", let = 0, zak = 0, work = "", bl = "", heal = "", narko = 0.1}
		sobes.selID.v = ""
		sobes.logChat = {}
		sobes.nextQ = false
		sobes.num = 0
	end
end

function HideDialogInTh(bool)
	repeat wait(0) until sampIsDialogActive()
	while sampIsDialogActive() do
		local memory = require 'memory'
		memory.setint64(sampGetDialogInfoPtr()+40, bool and 1 or 0, true)
		sampToggleCursor(bool)
	end
end

function ShowHelpMarker(stext)
	imgui.TextDisabled(u8"(?)")
	if imgui.IsItemHovered() then
	imgui.SetTooltip(stext)
	end
end

function rkeys.onHotKey(id, keys)
	if sampIsChatInputActive() or sampIsDialogActive() or isSampfuncsConsoleActive() or mainWin.v and editKey then
		return false
	end
end

function onHotKeyCMD(id, keys)
	if thread:status() == "dead" and lectime == false and statusvac == false then
		local sKeys = tostring(table.concat(keys, " "))
		for k, v in pairs(cmdBind) do
			if sKeys == tostring(table.concat(v.key, " ")) then
				if k == 1 then
					if not mainWin.v then
						styleAnimationOpen(1)
						mainWin.v = true
					else
						animka_main.paramOff = true
					end
				elseif k == 2 then
					sampSetChatInputEnabled(true)
					if buf_teg.v ~= "" then
						sampSetChatInputText("/r "..u8:decode(buf_teg.v)..": ")
					else
						sampSetChatInputText("/r ")
					end
				elseif k == 3 then
					sampSetChatInputEnabled(true)
					sampSetChatInputText("/rb ")
				elseif k == 4 then
					sampSendChat("/members")
				elseif k == 5 then
					if resTarg then
						funCMD.lec(tostring(targID))
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[5].cmd.." ")
					end
				elseif k == 6 then --пост
					funCMD.post()
				elseif k == 7 then
					if resTarg then
						funCMD.med(tostring(targID))
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[7].cmd.." ")
					end
				elseif k == 8 then
					if resTarg then
						funCMD.narko(tostring(targID))
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[8].cmd.." ")
					end
				elseif k == 9 then
					if resTarg then
						funCMD.recep(tostring(targID))
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[9].cmd.." ")
					end
				elseif k == 10 then
					funCMD.osm()
				elseif k == 11 then 
					if not depWin.v then
						styleAnimationOpen(2)
						depWin.v = true
					else
						animka_dep.paramOff = true
					end
				elseif k == 12 then
					if not sobWin.v then
						styleAnimationOpen(3)
						sobWin.v = true
					else
						animka_sob.paramOff = true
					end
				elseif k == 13 then 
					if resTarg then
						funCMD.tatu(tostring(targID))
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[13].cmd.." ")
					end
				elseif k == 14 then
					if resTarg then
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[14].cmd.." "..targID)
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[14].cmd.." ")
					end
				elseif k == 15 then
					if resTarg then
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[15].cmd.." "..targID)
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[15].cmd.." ")
					end
				elseif k == 16 then
					if resTarg then
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[16].cmd.." "..targID)
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[16].cmd.." ")
					end
				elseif k == 17 then
					if resTarg then
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[17].cmd.." "..targID)
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[17].cmd.." ")
					end
				elseif k == 18 then
					if resTarg then
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[18].cmd.." "..targID)
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[18].cmd.." ")
					end
				elseif k == 19 then
					if resTarg then
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[19].cmd.." "..targID)
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[19].cmd.." ")
					end
				elseif k == 20 then
					if resTarg then
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[20].cmd.." "..targID)
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[20].cmd.." ")
					end
				elseif k == 21 then
					funCMD.time()
				elseif k == 22 then
					if resTarg then
						funCMD.expel(tostring(targID))
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[22].cmd.." ")
					end
				elseif k == 23 then
					if resTarg then
						funCMD.vac(tostring(targID))
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[23].cmd.." ")
					end
				elseif k == 24 then
					funCMD.info()
				elseif k == 25 then
					funCMD.za()
				elseif k == 26 then
					funCMD.zd()
				elseif k == 27 then
					if resTarg then
						funCMD.ant(tostring(targID))
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[27].cmd.." ")
					end	
				elseif k == 28 then
					if resTarg then
						funCMD.strah(tostring(targID))
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[28].cmd.." ")
					end
				elseif k == 29 then
					if resTarg then
						funCMD.cur(tostring(targID))
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[29].cmd.." ")
					end
				elseif k == 30 then
					funCMD.lec(tostring(targID))
				elseif k == 31 then
					funCMD.hilka()
				elseif k == 32 then
					if resTarg then
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[32].cmd.." "..targID)
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[32].cmd.." ")
					end
				elseif k == 33 then
					funCMD.hme()
				elseif k == 34 then
					if resTarg then
						funCMD.show(tostring(targID))
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/"..cmdBind[34].cmd.." ")
					end
				elseif k == 35 then
					funCMD.cam()
				elseif k == 36 then
					funCMD.godeath()
				end
			
				
			end
		end
	elseif not lectime and not statusvac and not isKeyJustPressed(VK_1) then
		sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} В данный момент проигрывается отыгровка.", 0xFF8FA2)
		wait(100)
	end
	if isKeyJustPressed(VK_1) and not sampIsChatInputActive() and not sampIsDialogActive() and lectime and not statusvac and thread:status() == "dead" then 
		funCMD.lec(tostring(idMesPlayer))
		wait(100)
		lectime = false;
	end
end

function strBinderTable(dir)
	local tb = {
		vars = {},
		bind = {},
		debug = {
			file = true,
			close = {}
		},
		sleep = 1000
	}
	if doesFileExist(dir) then
		local l = {{},{},{},{},{}}
		local f1 = io.open(dir)
		local t = {}
		local ln = 0
		for line in f1:lines() do
			if line:find("^//.*$") then
				line = ""
			elseif line:find("//.*$") then
				line = line:match("(.*)//")
			end
			ln = ln + 1
			if #t > 0 then
				if line:find("%[name%]=(.*)$") then
					t[#t].name = line:match("%[name%]=(.*)$")
				elseif line:find("%[[%a%d]+%]=(.*)$") then
					local k, n = line:match("%[([%d%a]+)%]=(.*)$")
					local nk = vkeys["VK_"..k:upper()]
					if nk then
						local a = {n = n, k = nk, kn = k:upper(), t = {}}
						table.insert(t[#t].var, a)
					end
				elseif line:find("{dialogEnd}") then
					if #t > 1 then
						local a = #t[#t-1].var
						table.insert(t[#t-1].var[a].t, t[#t])
						t[#t] = nil
					elseif #t == 1 then
						table.insert(tb.bind, t[1])
						t = {}
					end
					table.remove(tb.debug.close)
				elseif line:find("{dialog}") then
					local b = {}
					b.name = ""
					b.var = {}
					table.insert(tb.debug.close, ln)
					table.insert(t, b)
				elseif #line > 0 and #t[#t].var > 0 then
					local a = #t[#t].var
					table.insert(t[#t].var[a].t, line)
				end
			else
				if line:find("{dialog}") and #t == 0 then
					local b = {} 
					b.name = ""
					b.var = {}
					table.insert(t, b)
					table.insert(tb.debug.close, ln)
				end
				if #tb.debug.close == 0 and #line > 0 then 
					table.insert(tb.bind, line)
				end
			end
		end
		f1:close()
		return tb
	else
		tb.debug.file = false
		return tb
	end 
end

function playBind(tb)
	if not tb.debug.file or #tb.debug.close > 0 then
		if not tb.debug.file then
			sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} Файл с текстом бинда не обнаружен. ", 0xFF8FA2)
		elseif #tb.debug.close > 0 then
			sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} Диалог, начало которого является строка №"..tb.debug.close[#tb.debug.close]..", не закрыт тегом {dialogEnd}", 0xFF8FA2)
		end
		addOneOffSound(0, 0, 0, 1058)
		return false
	end
	function pairsT(t, var)
		for i, line in ipairs(t) do
			if type(line) == "table" then
				renderT(line, var)
			else
				if line:find("{pause}") then
					local len = renderGetFontDrawTextLength(font, "{FFFFFF}[{67E56F}Enter{FFFFFF}] - Продолжить")
					while true do
						wait(0)
						if not isGamePaused() then
							renderFontDrawText(font, "Ожидание...\n{FFFFFF}[{67E56F}Enter{FFFFFF}] - Продолжить", sx-len-10, sy-50, 0xFFFFFFFF)
							if isKeyJustPressed(VK_RETURN) and not sampIsChatInputActive() and not sampIsDialogActive() then break end
						end
					end
				elseif line:find("{sleep:%d+}") then
					btime = tonumber(line:match("{sleep:(%d+)}"))
				elseif line:find("^%#[%d%a]+=.*$") then
					local var, val = line:match("^%#([%d%a]+)=(.*)$")
					tb.vars[var] = tags(val)			
				else
					wait(i == 1 and 0 or btime or tb.sleep*1000)
					btime = nil
					local str = line
					if var then
						for k,v in pairs(var) do
							str = str:gsub("#"..k, v)
						end
					end
					if str:find("/") then
						sampProcessChatInput(tags(str))
					else
						sampSendChat(tags(str))
					end
				end
			end
		end
	end
	function renderT(t, var)
		local render = true
		local len = renderGetFontDrawTextLength(font, t.name)
		for i,v in ipairs(t.var) do
			local str = string.format("{FFFFFF}[{67E56F}%s{FFFFFF}] - %s", v.kn, v.n)
			if len < renderGetFontDrawTextLength(font, str) then
				len = renderGetFontDrawTextLength(font, str)
			end
		end
		repeat
			wait(0)
			if not isGamePaused() then
				renderFontDrawText(font, t.name, sx-10-len, sy-#t.var*25-30, 0xFFFFFFFF)
				for i,v in ipairs(t.var) do
					local str = string.format("{FFFFFF}[{67E56F}%s{FFFFFF}] - %s", v.kn, v.n)
					renderFontDrawText(font, str, sx-10-len, sy-#t.var*25-30+(25*i), 0xFFFFFFFF)
					if isKeyJustPressed(v.k) and not sampIsChatInputActive() and not sampIsDialogActive() then
						pairsT(v.t, var)
						render = false
					end
				end
			end
		until not render						
	end					
	pairsT(tb.bind, tb.vars)
end

function onHotKeyBIND(id, keys)
	if thread:status() == "dead" then
		local sKeys = tostring(table.concat(keys, " "))
		for k, v in pairs(binder.list) do
			if sKeys == tostring(table.concat(v.key, " ")) then
				thread = lua_thread.create(function()		
					local dir = dirml.."/MedicalHelper/Binder/bind-"..v.name..".txt"	
					local tb = {}
					tb = strBinderTable(dir)
					tb.sleep = v.sleep
					playBind(tb)
					return
				end)
			end
		end
	end
end

function binderCmdStart()
	for i,v in ipairs(binder.list) do
	local factCommand = sampGetChatInputText()
	local factCommandRussia = string.format(".%s", translatizator(binder.list[i].cmd))
	local sverkaCommand = string.format("/%s", binder.list[i].cmd)
		if sverkaCommand == factCommand or factCommand == factCommandRussia then
		local numberMassive = i
		local nameMassive = binder.list[i].name
			for k, v in pairs(binder.list) do
				if thread:status() == "dead" then
					thread = lua_thread.create(function()
					local dir = dirml.."/MedicalHelper/Binder/bind-"..nameMassive..".txt"	
					local tb = {}
					tb = strBinderTable(dir)
					tb.sleep = binder.list[i].sleep
					playBind(tb)
					return
					end)	
				end
			end
		end
	end
end

function imgui.TextColoredRGB(string, max_float)

	local style = imgui.GetStyle()
	local colors = style.Colors
	local clr = imgui.Col
	local u8 = require 'encoding'.UTF8

	local function color_imvec4(color)
		if color:upper():sub(1, 6) == 'SSSSSS' then return imgui.ImVec4(colors[clr.Text].x, colors[clr.Text].y, colors[clr.Text].z, tonumber(color:sub(7, 8), 16) and tonumber(color:sub(7, 8), 16)/255 or colors[clr.Text].w) end
		local color = type(color) == 'number' and ('%X'):format(color):upper() or color:upper()
		local rgb = {}
		for i = 1, #color/2 do rgb[#rgb+1] = tonumber(color:sub(2*i-1, 2*i), 16) end
		return imgui.ImVec4(rgb[1]/255, rgb[2]/255, rgb[3]/255, rgb[4] and rgb[4]/255 or colors[clr.Text].w)
	end

	local function render_text(string)
		for w in string:gmatch('[^\r\n]+') do
			local text, color = {}, {}
			local render_text = 1
			local m = 1
			if w:sub(1, 8) == '[center]' then
				render_text = 2
				w = w:sub(9)
			elseif w:sub(1, 7) == '[right]' then
				render_text = 3
				w = w:sub(8)
			end
			w = w:gsub('{(......)}', '{%1FF}')
			while w:find('{........}') do
				local n, k = w:find('{........}')
				if tonumber(w:sub(n+1, k-1), 16) or (w:sub(n+1, k-3):upper() == 'SSSSSS' and tonumber(w:sub(k-2, k-1), 16) or w:sub(k-2, k-1):upper() == 'SS') then
					text[#text], text[#text+1] = w:sub(m, n-1), w:sub(k+1, #w)
					color[#color+1] = color_imvec4(w:sub(n+1, k-1))
					w = w:sub(1, n-1)..w:sub(k+1, #w)
					m = n
				else w = w:sub(1, n-1)..w:sub(n, k-3)..'}'..w:sub(k+1, #w) end
			end
			local length = imgui.CalcTextSize(u8(w))
			if render_text == 2 then
				imgui.NewLine()
				imgui.SameLine(max_float / 2 - ( length.x / 2 ))
			elseif render_text == 3 then
				imgui.NewLine()
				imgui.SameLine(max_float - length.x - 5 )
			end
			if text[0] then
				for i, k in pairs(text) do
					imgui.TextColored(color[i] or colors[clr.Text], u8(k))
					imgui.SameLine(nil, 0)
				end
				imgui.NewLine()
			else imgui.Text(u8(w)) end
		end
	end
	render_text(string)
end

function imgui.GetMaxWidthByText(text)
	local max = imgui.GetWindowWidth()
	for w in text:gmatch('[^\r\n]+') do
		local size = imgui.CalcTextSize(w)
		if size.x > max then max = size.x end
	end
	return max - 15
end

function getSpurFile()
	spur.list = {}
    local search, name = findFirstFile("moonloader/MedicalHelper/Шпаргалки/*.txt")
	while search do
		if not name then findClose(search) else
			table.insert(spur.list, tostring(name:gsub(".txt", "")))
			name = findNextFile(search)
			if name == nil then
				findClose(search)
				break
			end
		end
	end
end

function wraper(str, limit, indent, indent1)
  indent = indent or ""
  indent1 = indent1 or indent
  limit = limit or 79
  local here = 1-#indent1
  return indent1..str:gsub("(%s+)()(%S+)()",
	function(sp, st, word, fi)
		if fi-here > limit then
			here = st - #indent
		return "\n"..indent..word
		end
	end)
end

function getGovFile()
deadgov = true
local govls = [[
/gov [Больница ЛС] - Ув.Жители Штата, сегодня в Больнице ЛС пройдёт день открытых дверей
/gov [Больница ЛС] - У нас вы получите: лучших сотрудников, быстрый карьерный рост, высокую зарплату
/gov [Больница ЛС] - Ждём всех желающих в холе Больнице ЛС.
]]
local govsf = [[
/gov [Больница СФ] - Ув.Жители Штата, сегодня в Больнице СФ пройдёт день открытых дверей
/gov [Больница СФ] - У нас вы получите: лучших сотрудников, быстрый карьерный рост, высокую зарплату
/gov [Больница СФ] - Ждём всех желающих в холе Больнице СФ.
]]
local govlv = [[
/gov [Больница ЛВ] - Ув.Жители Штата, сегодня в Больнице ЛВ пройдёт день открытых дверей
/gov [Больница ЛВ] - У нас вы получите: лучших сотрудников, быстрый карьерный рост, высокую зарплату
/gov [Больница ЛВ] - Ждём всех желающих в холе Больнице ЛВ.
]]
local govjf = [[
/gov [Больница Jafferson] - Ув.Жители Штата, сегодня в Больнице Джефферсон пройдёт день открытых дверей
/gov [Больница Jafferson] - У нас вы получите: лучших сотрудников, быстрый карьерный рост, высокую зарплату
/gov [Больница Jafferson] - Ждём всех желающих в холе Больнице Джефферсон.
]]
lua_thread.create(function()
	if doesDirectoryExist(dirml.."/MedicalHelper/Департамент/") then
		if doesFileExist(dirml.."/MedicalHelper/Департамент/День открытых дверей.txt") or not doesFileExist(dirml.."/MedicalHelper/Департамент/День открытых дверей ЛСМЦ.txt") then
			os.remove(dirml.."/MedicalHelper/Департамент/День открытых дверей.txt")
			local f = io.open(dirml.."/MedicalHelper/Департамент/День открытых дверей ЛСМЦ.txt", "w")
			f:write(govls)
			f:flush()
			f:close()
			local f = io.open(dirml.."/MedicalHelper/Департамент/День открытых дверей СФМЦ.txt", "w")
			f:write(govsf)
			f:flush()
			f:close()
			local f = io.open(dirml.."/MedicalHelper/Департамент/День открытых дверей ЛВМЦ.txt", "w")
			f:write(govlv)
			f:flush()
			f:close()
			local f = io.open(dirml.."/MedicalHelper/Департамент/День открытых дверей ДЖФМЦ.txt", "w")
			f:write(govjf)
			f:flush()
			f:close()
		end
		dep.news = {}
		local search, name = findFirstFile("moonloader/MedicalHelper/Департамент/*.txt")
		while search do
			if not name then findClose(search) else
				table.insert(dep.news, u8(tostring(name:gsub(".txt", ""))))
				name = findNextFile(search)
				if name == nil then
					findClose(search)
					break
				end
			end
		end
	end
	deadgov = false
end)
	brp = 0
	lua_thread.create(function()
		if doesFileExist(dirml.."/MedicalHelper/Департамент/"..u8:decode(dep.news[1])..".txt") then
			for line in io.lines(dirml.."/MedicalHelper/Департамент/"..u8:decode(dep.news[1])..".txt") do
				if brp < 6 then
					trtxt[brp + 1].v = u8(line)
					brp = brp + 1
				end
			end
		end
		deadgov = false
	end)
end

function filter(mode, filderChar)
	local function locfil(data)
		if mode == 0 then 
			if string.char(data.EventChar):find(filderChar) then 
				return true
			end
		elseif mode == 1 then
			if not string.char(data.EventChar):find(filderChar) then 
				return true
			end
		end
	end 
	
	local cbFilter = imgui.ImCallback(locfil)
	return cbFilter
end

function tags(par) --find2
		par = par:gsub("{myID}", tostring(myid))
		par = par:gsub("{myNick}", tostring(getPlayerNickName(myid):gsub("_", " ")))
		par = par:gsub("{myRusNick}", tostring(u8:decode(buf_nick.v)))
		par = par:gsub("{myHP}", tostring(getCharHealth(PLAYER_PED)))
		par = par:gsub("{myArmo}", tostring(getCharArmour(PLAYER_PED)))
		par = par:gsub("{myHosp}", tostring(u8:decode(chgName.org[num_org.v+1])))
		par = par:gsub("{myHospEn}", tostring(u8:decode(list_org_en[num_org.v+1])))
		par = par:gsub("{myTag}", tostring(u8:decode(buf_teg.v))) 
		par = par:gsub("{myRank}", tostring(u8:decode(chgName.rank[num_rank.v+1])))
		par = par:gsub("{time}", tostring(os.date("%X")))
		par = par:gsub("{day}", tostring(tonumber(os.date("%d"))))
		par = par:gsub("{week}", tostring(week[tonumber(os.date("%w"))]))
		par = par:gsub("{month}", tostring(month[tonumber(os.date("%m"))]))
		par = par:gsub("{med7}", tostring(buf_mede[1].v))
		par = par:gsub("{med14}", tostring(buf_mede[2].v))
		par = par:gsub("{med30}", tostring(buf_mede[3].v))
		par = par:gsub("{med60}", tostring(buf_mede[4].v))
		par = par:gsub("{medup7}", tostring(buf_upmede[1].v))
		par = par:gsub("{medup14}", tostring(buf_upmede[2].v))
		par = par:gsub("{medup30}", tostring(buf_upmede[3].v))
		par = par:gsub("{medup60}", tostring(buf_upmede[4].v))
		par = par:gsub("{pricenarko}", tostring(buf_narko.v))
		par = par:gsub("{pricerecept}", tostring(buf_rec.v))
		par = par:gsub("{pricetatu}", tostring(buf_tatu.v))
		par = par:gsub("{priceant}", tostring(buf_ant.v))
		par = par:gsub("{pricelec}", tostring(buf_lec.v))
		if par:find('{namePlayerRus%[(%d+)%]}') then
			local namepl_nick_id = par:match('{namePlayerRus%[(%d+)%]}')
			local nicknamepl = sampGetPlayerNickname(tonumber(namepl_nick_id))
			par = par:gsub("{namePlayerRus%[(%d+)%]}", tostring(trst(nicknamepl)))
		end
		
		if targID ~= nil then par = par:gsub("{target}", targID) end
		if par:find("{getNickByID:%d+}") then
			for v in par:gmatch("{getNickByID:%d+}") do
				local id = tonumber(v:match("{getNickByID:(%d+)}"))
				if sampIsPlayerConnected(id) then
					par = par:gsub(v, tostring(getPlayerNickName(id))):gsub("_", " ")
				else
					sampAddChatMessage("{FFFFFF}[{FF8FA2}MH:Ошибка{FFFFFF}]: Параметр {getNickByID:ID} не смог вернуть ник игрока. Возможно игрок не в сети.", 0xFF8FA2)
					par = par:gsub(v,"")
				end
			end
		end
		if par:find("{sex:[%w%sа-яА-Я]*|[%w%sа-яА-Я]*}") then	
			for v in par:gmatch("{sex:[%w%sа-яА-Я]*|[%w%sа-яА-Я]*}") do
				local m, w = v:match("{sex:([%w%sа-яА-Я]*)|([%w%sа-яА-Я]*)}")
				if num_sex.v == 0 then
					par = par:gsub(v, m)
				else
					par = par:gsub(v, w)
				end
			end
		end
		
		if par:find("{getNickByTarget}") then
			if targID ~= nil and targID >= 0 and targID <= 1000 and sampIsPlayerConnected(targID) then
				par = par:gsub("{getNickByTarget}", tostring(getPlayerNickName(targID):gsub("_", " ")))
			else
				sampAddChatMessage("{FFFFFF}[{FF8FA2}MH:Ошибка{FFFFFF}]: Параметр {getNickByTarget} не смог вернуть ник игрока. Возможно Вы не целились на игрока, либо он не в сети.", 0xFF8FA2)
				par = par:gsub("{getNickByTarget}", tostring(""))
			end
		end
	return par
end

funCMD = {}
function funCMD_All(argum, numact)
	if numact == nil then
		numact = 5
	end
	if thread:status() ~= "dead" and not lectime and not statusvac then 
		sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} В данный момент проигрывается отыгровка.", 0xFF8FA2)
		return
	end
	if not u8:decode(buf_nick.v):find("[а-яА-Я]+%s[а-яА-Я]+") then
		buf_nick.v = u8(trst(myNick))
	end
	local function find_last_index(array, element)
		local index = 0
		for i = 1, #array do
			if array[i][1] == element then
				index = i
			end
		end
		return index
	end
	local breakArg = false
	local dialog_run = false
	local dialogs = {0, false}
	local donedialog = 0
	local values = {
		arg = {},
		var = {}
	}
	if acting[numact].argfunc then
		for p = 1, #acting[numact].arg do
			if acting[numact].arg[p][1] ~= nil then
				if acting[numact].arg[p][1] == 0 then
					if argum:find("^(%d+).*") then
						values.arg[p] = tostring(argum:gsub("^(%d+).*", "%1"))
						argum = argum:gsub("^%S+%s*", "")
					else
						breakArg = true
					end
				elseif acting[numact].arg[p][1] == 1 then
					if argum:find("^%s*(%S+).*") then
						values.arg[p] = tostring(argum:gsub("^%s*(%S+).*", "%1"))
						argum = argum:gsub("^%S+%s*", "")
					else
						breakArg = true
					end
				end
			end
		end
	end
	if not breakArg and acting[numact].varfunc then
		for ui = 1, #acting[numact].var do
			values.var[ui] = acting[numact].var[ui]
		end
	end
	if not breakArg then
		thread = lua_thread.create(function()
			for i = 1, #acting[numact].typeAct do
				if acting[numact].typeAct[i][1] == 2 then
					dialogs[1] = #acting[numact].typeAct[i][2]
					dialogs[2] = true
					local sizetexts = 110
					local textlin = ""
					for j = 1, dialogs[1] do
						textlin = textlin.."{FFFFFF}[Num{67E56F}"..j.."{FFFFFF}] - "..acting[numact].typeAct[i][2][j].."\n"
						local part = renderGetFontDrawTextLength(font, u8:decode(acting[numact].typeAct[i][2][j]))
						if part > sizetexts then
							sizetexts = part
						end
					end
					sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} Для продолжения нажмите необходимую клавишу верхней панели клавиатуры.", 0xFF8FA2)
					addOneOffSound(0, 0, 0, 1058)
					while true do wait(0)
						if not isGamePaused() then
							renderFontDrawText(font, "{8ABCFA}Выберите действие:\n".. u8:decode(textlin), sx - 100 - sizetexts, sy - 33 - (dialogs[1] * 23), 0xFFFFFFFF)
						end
						if isKeyJustPressed(VK_1) and not sampIsChatInputActive() and not sampIsDialogActive() and dialogs[1] >= 1 then donedialog = 1; break end
						if isKeyJustPressed(VK_2) and not sampIsChatInputActive() and not sampIsDialogActive() and dialogs[1] >= 2 then donedialog = 2; break end
						if isKeyJustPressed(VK_3) and not sampIsChatInputActive() and not sampIsDialogActive() and dialogs[1] >= 3 then donedialog = 3; break end
						if isKeyJustPressed(VK_4) and not sampIsChatInputActive() and not sampIsDialogActive() and dialogs[1] >= 4 then donedialog = 4; break end
						if isKeyJustPressed(VK_5) and not sampIsChatInputActive() and not sampIsDialogActive() and dialogs[1] >= 5 then donedialog = 5; break end
						if isKeyJustPressed(VK_6) and not sampIsChatInputActive() and not sampIsDialogActive() and dialogs[1] >= 6 then donedialog = 6; break end
						if isKeyJustPressed(VK_7) and not sampIsChatInputActive() and not sampIsDialogActive() and dialogs[1] >= 7 then donedialog = 7; break end
						if isKeyJustPressed(VK_8) and not sampIsChatInputActive() and not sampIsDialogActive() and dialogs[1] >= 8 then donedialog = 8; break end
					end
				end
				if acting[numact].typeAct[i][1] == 0 then
					local text_message
					if acting[numact].argfunc and values.arg[1] ~= nil then
						text_message = u8:decode(acting[numact].typeAct[i][2])
						for u = 1, #values.arg do
							text_message = text_message:gsub('{arg'..u..'}', values.arg[u])
						end
						text_message = tags(text_message)
					else
						text_message = acting[numact].typeAct[i][2]
						text_message = tags(u8:decode(text_message))
					end
					if acting[numact].varfunc and values.var[1] ~= nil then
						for u = 1, #values.var do
							text_message = text_message:gsub("{var"..u.."}", values.var[u])
						end
					end
					if text_message:find("{dialog(%d)}") then
						local iddialogs = text_message:gsub("{dialog(%d+)}.*", "%1")
						iddialogs = tonumber(iddialogs)
						if iddialogs > dialogs[1] or iddialogs <= 0 or donedialog == 0 then
							dialogs = {0, false}
							dialog_run = false
							donedialog = 0
						elseif iddialogs == donedialog then
							dialog_run = true
						elseif iddialogs ~= donedialog then
							dialog_run = false
						end
					else
						dialogs = {0, false}
						dialog_run = false
						donedialog = 0
					end
					if dialog_run and dialogs[2] then
						text_message = text_message:gsub("{dialog(%d+)}", "")
						if text_message ~= "" then
							if find_last_index(acting[numact].typeAct, 0) ~= i or not acting[numact].chatopen then
								sampSendChat(text_message)
							elseif find_last_index(acting[numact].typeAct, 0) == i and acting[numact].chatopen then
								sampSetChatInputEnabled(true)
								sampSetChatInputText(text_message)
							end
							if i ~= #acting[numact].typeAct then
								wait(acting[numact].sec * 1000)
							end
						end
					elseif not dialogs[2] then
						if text_message ~= "" then
							if find_last_index(acting[numact].typeAct, 0) ~= i or not acting[numact].chatopen then
								sampSendChat(text_message)
							elseif find_last_index(acting[numact].typeAct, 0) == i and acting[numact].chatopen then
								sampSetChatInputEnabled(true)
								sampSetChatInputText(text_message)
							end
							if i ~= #acting[numact].typeAct then
								wait(acting[numact].sec * 1000)
							end
						end
					end
				end
				if acting[numact].typeAct[i][1] == 1 then
					if (dialog_run and dialogs[2]) or not dialogs[2] then 
						sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} Нажмите на {23E64A}Enter{FFFFFF} для продолжения или {FF8FA2}Page Down{FFFFFF}, чтобы закончить диалог.", 0xFF8FA2)
						addOneOffSound(0, 0, 0, 1058)
						local len = renderGetFontDrawTextLength(font, "{FFFFFF}[{67E56F}Enter{FFFFFF}] - Продолжить")
						while true do wait(0)
							if not isGamePaused() then
								renderFontDrawText(font, "{8ABCFA}Отыгровка:\n{FFFFFF}[{67E56F}Enter{FFFFFF}] - Продолжить", sx-len-40, sy-50, 0xFFFFFFFF)
							end
							if isKeyJustPressed(VK_RETURN) and not sampIsChatInputActive() and not sampIsDialogActive() then break end
						end
					end
				end
				if acting[numact].typeAct[i][1] == 3 then 
					if (dialog_run and dialogs[2]) or not dialogs[2] then
						local text_chat
						if acting[numact].argfunc and values.arg[1] ~= nil then
							for u = 1, #values.arg do
								text_chat = acting[numact].typeAct[i][2]:gsub("{arg"..u.."}", values.arg[u])
								text_chat = tags(u8:decode(text_chat))
							end
						else
							text_chat = acting[numact].typeAct[i][2]
							text_chat = tags(u8:decode(text_chat))
						end
						if acting[numact].varfunc and values.var[1] ~= nil then
							for u = 1, #values.var do
								text_chat = tags(text_chat:gsub("{var"..u.."}", values.var[u]))
							end
						end
						sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} "..text_chat, 0xFF8FA2)
					end
				end
				if acting[numact].typeAct[i][1] == 4 then
					if (dialog_run and dialogs[2]) or not dialogs[2] then
						local var_on_tag = acting[numact].typeAct[i][3]
						var_on_tag = tags(u8:decode(var_on_tag))
						local numvar = acting[numact].typeAct[i][2] + 1
						if var_on_tag:find('{var(%d)}') then
							idvariab = var_on_tag:gsub("{var(%d+)}.*", "%1")
							idvariab = tonumber(idvariab)
							var_on_tag = var_on_tag:gsub("{var"..idvariab.."}", values.var[idvariab])
						end
						values.var[numvar] = var_on_tag
					end
				end
			end
		end)
	else
		local text_sampmes = ""
		if acting[numact].argfunc and acting[numact].arg[1][1] ~= nil then
			for f = 1, #acting[numact].arg do
				text_sampmes = text_sampmes.."["..acting[numact].arg[f][2].."] "
			end
			sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} Используйте {a8a8a8}/"..cmdBind[numact].cmd.." ".. u8:decode(text_sampmes), 0xFF8FA2)
		end
	end
end

function funCMD.del()
	sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} Вы успешно удалили скрипт.", 0xFF8FA2)
	sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} Выгрузка скрипта из игры...", 0xFF8FA2)
	os.remove(scr.path)
	scr:reload()
end
function funCMD.lec(argum)
	funCMD_All(argum, 5)
end
function funCMD.med(argum)
	funCMD_All(argum, 7)
end
function funCMD.narko(argum)
	funCMD_All(argum, 8)
end
function funCMD.recep(argum)
	funCMD_All(argum, 9)
end
function funCMD.osm(argum)
	funCMD_All(argum, 10)
end
function funCMD.tatu(argum)
	funCMD_All(argum, 13)
end
function funCMD.warn(argum)
	funCMD_All(argum, 14)
end
function funCMD.uwarn(argum)
	funCMD_All(argum, 15)
end
function funCMD.mute(argum)
	funCMD_All(argum, 16)
end
function funCMD.umute(argum)
	funCMD_All(argum, 17)
end
function funCMD.rank(argum)
	funCMD_All(argum, 18)
end
function funCMD.inv(argum)
	funCMD_All(argum, 19)
end
function funCMD.unv(argum)
	funCMD_All(argum, 20)
end
function funCMD.expel(argum)
	funCMD_All(argum, 22)
end
function funCMD.vac(argum)
	funCMD_All(argum, 23)
end
function funCMD.za(argum)
	funCMD_All(argum, 25)
end
function funCMD.zd(argum)
	funCMD_All(argum, 26)
end
function funCMD.ant(argum)
	funCMD_All(argum, 27)
end
function funCMD.strah(argum)
	funCMD_All(argum, 28)
end
function funCMD.cur(argum)
	funCMD_All(argum, 29)
end
function funCMD.show(argum)
	funCMD_All(argum, 34)
end
function funCMD.cam(argum)
	funCMD_All(argum, 35)
end
function funCMD.godeath(argum)
	funCMD_All(argum, 36)
end

function funCMD.post(stat)
	if not u8:decode(buf_nick.v):find("[а-яА-Я]+%s[а-яА-Я]+") then
		sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} Подождите-ка, сначала нужно заполнить базовую информацию. {90E04E}/mh > Настройки > Основная информация", 0xFF8FA2)
		return
	end
	if not isCharInModel(PLAYER_PED, 416) then -- not
		sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} Чтобы заступить на мобильный пост, Вам необходимо сначала сесть в карету.", 0xFF8FA2)
		addOneOffSound(0, 0, 0, 1058)
	else
		local bool, post, coord = postGet()
		if not bool then
			sampShowDialog(2001, ">{FFB300}Посты", "                             {55BBFF}Выберите пост\n"..table.concat(post, "\n"), "{69FF5C}Выбрать", "{FF5C5C}Отмена", 5)
			sampSetDialogClientside(false)
		elseif bool then
			if stat:find(".+") then
				sampSendChat(string.format("/r Докладывает: %s. Нахожусь на посту %s, обстановка: %s", u8:decode(buf_nick.v):gsub("%X+%s", ""), post, stat))
			else
				sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} Укажите обстановку, например, /"..cmdBind[6].cmd.." Спокойно.", 0xFF8FA2)
			end
		end
	end
end
function funCMD.hall()
	local maxIdInStream = sampGetMaxPlayerId(true)
	for i = 0, maxIdInStream do
	local result, handle = sampGetCharHandleBySampPlayerId(i)
		if result and doesCharExist(handle) then
			local px, py, pz = getCharCoordinates(playerPed)
			local pxp, pyp, pzp = getCharCoordinates(handle)
			local distance = getDistanceBetweenCoords2d(px, py, pxp, pyp)
			if distance <= 4 then
				sampSetChatInputEnabled(true)
				sampSetChatInputText("/hl "..i)
			end
		end
	end
end
function funCMD.hilka()
local id = getNearestID()
	if id then
		name = getPlayerNickName(id)
		sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} Выбранный игрок: {5BF165}"..name.." ["..id.."]", 0xFF8FA2)
		funCMD.lec(tostring(id))
	else
    sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} Ближайший игрок не найден!", 0xFF8FA2)
	end
end
function funCMD.sob()
	if not sobWin.v then
		styleAnimationOpen(3)
		sobWin.v = true
	else
		animka_sob.paramOff = true
	end
end
function funCMD.dep()
	if num_rank.v+1 < 5 then
		sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} Данная команда Вам недоступна. Поменяйте должность в настройках скрипта, если это требуется.", 0xFF8FA2)
		return
	end
	if not depWin.v then
		styleAnimationOpen(2)
		depWin.v = true
	else
		animka_dep.paramOff = true
	end
end
function funCMD.hme()
	thread = lua_thread.create(function()
		sampSendChat("/me достал"..chsex("","а").." из сумки пару таблеток, после чего тут же их принял"..chsex("","а").."")
		wait(1000)
		sampSendChat("/heal "..myid.." 5000")
		healme = true
	end)
end
function funCMD.memb()
	sampSendChat("/members")
end
function funCMD.time()
	lua_thread.create(function()
		sampSendChat("/time")
		wait(1500)
	--	mem.setint8(sampGetBase() + 0x119CBC, 1)
		setVirtualKeyDown(VK_F8, true)
		wait(20)
		setVirtualKeyDown(VK_F8, false)
	end)
end
function funCMD.info()
	sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} Частые команды:", 0xFF8FA2)
	sampAddChatMessage("{1fc5f2}/"..cmdBind[5].cmd.." [id игрока]{FFFFFF} - вылечить пациента", 0xFF8FA2)
	sampAddChatMessage("{1fc5f2}/"..cmdBind[7].cmd.." [id игрока]{FFFFFF} - выдать мед. карту", 0xFF8FA2)
	sampAddChatMessage("{1fc5f2}/"..cmdBind[9].cmd.." [id игрока]{FFFFFF} - выдать рецепт", 0xFF8FA2)
	sampAddChatMessage("{1fc5f2}/"..cmdBind[8].cmd.." [id игрока]{FFFFFF} - вылечить от наркозависимости", 0xFF8FA2)
	sampAddChatMessage("{1fc5f2}/"..cmdBind[13].cmd.." [id игрока]{FFFFFF} - вывести татуировку с тела", 0xFF8FA2)
	sampAddChatMessage("{1fc5f2}/"..cmdBind[23].cmd.." [id игрока]{FFFFFF} - вакцинировать пациента", 0xFF8FA2)
	sampAddChatMessage("{1fc5f2}/"..cmdBind[27].cmd.." [id игрока]{FFFFFF} - продать антибиотики", 0xFF8FA2)
	sampAddChatMessage("{1fc5f2}/"..cmdBind[28].cmd.." [id игрока]{FFFFFF} - оформить мед. страховку", 0xFF8FA2)
	sampAddChatMessage("{1fc5f2}/"..cmdBind[29].cmd.." [id игрока]{FFFFFF} - поднять человека на ноги", 0xFF8FA2)
	sampAddChatMessage("{1fc5f2}/"..cmdBind[26].cmd.."{FFFFFF} - отправить приветствие в чат", 0xFF8FA2)
end
function funCMD.shpora(number)
	if number:find("(%d+)") then
		getSpurFile()
		spur.select_spur = 0 + number
		if spur.select_spur <= #spur.list and spur.select_spur > 0 then
			local f = io.open(dirml.."/MedicalHelper/Шпаргалки/"..spur.list[spur.select_spur]..".txt", "r")
			spur.text.v = u8(f:read("*a"))
			f:close()
			spur.name.v = u8(spur.list[spur.select_spur])
			if not spurBig.v then
				styleAnimationOpen(5)
				spurBig.v = true
				examination = true
				textEndShpora = {}
			else
				animka_big.paramOff = true
			end
		elseif spur.select_spur <= 0 then
			sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} Порядковый счёт шпаргалок начинается с единицы.", 0xFF8FA2)
		else
			sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} Шпаргалки под таким номером не существует.", 0xFF8FA2)
		end
	else
		sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} Используйте {a8a8a8}/"..cmdBind[32].cmd.." [номер шпаргалки по счёту].", 0xFF8FA2)
	end
end

function funCMD.updaterelease()
	sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} Производится скачивание новой релиз версии скрипта...", 0xFF8FA2)
	local dir = dirml.."/MedicalHelper.lua"
	local url = "https://drive.google.com/u/0/uc?id=1oONMrk8eTah--0pbLJAjNgQ6xoNBOH6u&export=download"
	downloadUrlToFile(url, dir, function(id, status, p1, p2)
		if status == dlstatus.STATUSEX_ENDDOWNLOAD then
			if updates == nil then 
				print("{FF0000}Ошибка при попытке скачать файл.") 
				addOneOffSound(0, 0, 0, 1058)
				sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} Произошла ошибка при скачивании обновления. Активация резервого источника...", 0xFF8FA2)
				updWin.v = false
				lua_thread.create(function()
					wait(500)
					funCMD.updateEr()
				end)
			end
		end
		if status == dlstatus.STATUS_ENDDOWNLOADDATA then
			updates = true
			print("Загрузка закончена")
			sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} Скачивание успешно завершено! Перезагрузка скрипта...", 0xFF8FA2)
			reloadScripts()
			showCursor(false) 
		end
	end)
end
function funCMD.updatebeta()
	sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} Производится скачивание новой бета версии скрипта...", 0xFF8FA2)
	local dir = dirml.."/MedicalHelper.lua"
	local url = "https://drive.google.com/u/0/uc?id=18RmAd9JBOH-WtTyX-dG_M1XpwM-zO71x&export=download"
	downloadUrlToFile(url, dir, function(id, status, p1, p2)
		if status == dlstatus.STATUSEX_ENDDOWNLOAD then
			if updates == nil then 
				print("{FF0000}Ошибка при попытке скачать файл.") 
				addOneOffSound(0, 0, 0, 1058)
				sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} Произошла ошибка при скачивании обновления. Активация резервого источника...", 0xFF8FA2)
				updWin.v = false
				lua_thread.create(function()
					wait(500)
					funCMD.updateEr()
				end)
			end
		end
		if status == dlstatus.STATUS_ENDDOWNLOADDATA then
			updates = true
			print("Загрузка закончена")
			sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} Скачивание успешно завершено! Перезагрузка скрипта...", 0xFF8FA2)
			reloadScripts()
			showCursor(false) 
		end
	end)
end

function funCMD.updateEr()
local erTx =  
[[
{FFFFFF}Похоже, что-то мешает скачиванию обновлению.
Это может быть как антивирус, так и анти-стиллер, который блокирует скачивание.
Если у Вас отключен антивирус, отсутствует анти-стиллер, то видимо что-то другое
блокирует скачивание. Поэтому нужно будет скачать файл отдельно.

Пожалуйста, посетите официальную группу скрипта ВКонтакте.
Группу можно найти перейдя по ссылке:
{A1DF6B}vk.com/arizonamh{FFFFFF}
Скачайте lua файл и переместите с заменой в папку moonloader.

Ссылка на группу ВКонтакте уже скопирована автоматически.
]]
	sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} Производится скачивание новой версии скрипта...", 0xFF8FA2)
	local dir = dirml.."/MedicalHelper.lua"
	local url = urlupd
	downloadUrlToFile(url, dir, function(id, status, p1, p2)
		if status == dlstatus.STATUSEX_ENDDOWNLOAD then
			if updates == nil then 
				print("{FF0000}Ошибка при попытке скачать файл.") 
				addOneOffSound(0, 0, 0, 1058)
				sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} Произошла ошибка при скачивании обновления. Похоже, скачиванию что-то мешает.", 0xFF8FA2)
				sampShowDialog(2001, "{FF0000}Ошибка обновления", erTx, "Закрыть", "", 0)
				setClipboardText("vk.com/arizonamh")
				updWin.v = false
			end
		end
		if status == dlstatus.STATUS_ENDDOWNLOADDATA then
			updates = true
			sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} Скачивание успешно завершено! Перезагрузка скрипта...", 0xFF8FA2)
			reloadScripts()
			showCursor(false)
		end
	end)
end

--local url = "https://drive.google.com/u/0/uc?id=1oONMrk8eTah--0pbLJAjNgQ6xoNBOH6u&export=download" --> Медикал Хелпер релиз.lua

--//// ПРОВЕРКА ОБНОВЛЕНИЙ
function funCMD.updateCheck()
	sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} Поиск обновлений...", 0xFF8FA2)
	local dir = dirml.."/MedicalHelper/files/update.med"
	--local url = "https://drive.google.com/u/0/uc?id=1pxwbPIq20kF1E3fLRgo6G6p9GOwhM7CZ&export=download" -- https://drive.google.com/u/0/uc?id=18RmAd9JBOH-WtTyX-dG_M1XpwM-zO71x&export=download --> БЕТА
	local url = "https://drive.google.com/u/0/uc?id=1pWIlQ9Jc7AB1fDM80QDazLFJajvHbdpb&export=download" --> Проверка релиз версии
	downloadUrlToFile(url, dir, function(id, status, p1, p2)
		if status == dlstatus.STATUS_ENDDOWNLOADDATA then
			lua_thread.create(function()
				wait(1000)
				if doesFileExist(dirml.."/MedicalHelper/files/update.med") then
					local f = io.open(dirml.."/MedicalHelper/files/update.med", "r")
					local upd = decodeJson(f:read("*a"))
					f:close()
					if type(upd) == "table" then
						newversr = upd.version:gsub("%D","")
						newversb = upd.versionbeta:gsub("%D","")
						newversion = upd.version
						newversionbeta = upd.versionbeta
						urlupd = upd.url
						urlupdbeta = upd.urlbeta
						if newversr > scrvers then
							upd_release = true
							sampAddChatMessage("{FF8FA2}[MH]{FFFFFF}{4EEB40} Имеется обновление релиз версии.{FFFFFF} Напиши {22E9E3}/updatemh{FFFFFF} для получения информации.", 0xFF8FA2)
						else
							if newversb > scrvers then
								upd_beta = true
								sampAddChatMessage("{FF8FA2}[MH]{4EEB40} Имеется обновление бета версии.{FFFFFF} Напиши {22E9E3}/updatemh{FFFFFF} для получения информации.", 0xFF8FA2)
							else
								sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} Всё отлично, Вы используете самую новую версию скрипта.", 0xFF8FA2)
							end
						end
					end
				end
			end)
		end
	end)
	local dir = dirml.."/MedicalHelper/files/update.txt"
	local dirbeta = dirml.."/MedicalHelper/files/updatebeta.txt"
	local urlbeta = "https://drive.google.com/u/0/uc?id=1wmUMPyykQ6dEKsrffsaDqOG2wY4_GGsQ&export=download"
	local urlrelease = "https://drive.google.com/u/0/uc?id=1GJvpwsP0pUvf8JPiA4LfrziBNqFlqzRG&export=download"
	downloadUrlToFile(urlrelease, dir, function(id, status, p1, p2)
		if status == dlstatus.STATUS_ENDDOWNLOADDATA then
			lua_thread.create(function()
				wait(1000)
				if doesFileExist(dirml.."/MedicalHelper/files/update.txt") then
					local f = io.open(dirml.."/MedicalHelper/files/update.txt", "r")
					updinfo = f:read("*a")
					f:close()
				end
			end)
		end
	end)
	downloadUrlToFile(urlbeta, dirbeta, function(id, status, p1, p2)
		if status == dlstatus.STATUS_ENDDOWNLOADDATA then
			lua_thread.create(function()
				wait(1000)
				if doesFileExist(dirml.."/MedicalHelper/files/updatebeta.txt") then
					local f = io.open(dirml.."/MedicalHelper/files/updatebeta.txt", "r")
					updinfo = f:read("*a")
					f:close()
				end
			end)
		end
	end)
end

function asyncHttpRequest(method, url, args, resolve, reject)
   local request_thread = effil.thread(function (method, url, args)
      local requests = require 'requests'
      local result, response = pcall(requests.request, method, url, args)
      if result then
         response.json, response.xml = nil, nil
         return true, response
      else
         return false, response
      end
   end)(method, url, args)
   -- Если запрос без функций обработки ответа и ошибок.
   if not resolve then resolve = function() end end
   if not reject then reject = function() end end
   -- Проверка выполнения потока
   lua_thread.create(function()
      local runner = request_thread
      while true do
         local status, err = runner:status()
         if not err then
            if status == 'completed' then
               local result, response = runner:get()
               if result then
                  resolve(response)
               else
                  reject(response)
               end
               return
            elseif status == 'canceled' then
               return reject(status)
            end
         else
            return reject(err)
         end
         wait(0)
      end
   end)
end

function hook.onServerMessage(mesColor, mes)
	if mes:find("Организационная зарплата: $(%d+)") then --> Зарплата
		local mesPay = mes:match("Организационная зарплата: $(.+)")
		local mesPay = mesPay:gsub("%D","")
		profit_money.total_all = profit_money.total_all + (mesPay + 0)
		profit_money.payday[1] = profit_money.payday[1] + (mesPay + 0)
		local f = io.open(dirml.."/MedicalHelper/profit.med", "w")
		f:write(encodeJson(profit_money))
		f:flush()
		f:close()
	end
	if mes:find("%[Информация%] {FFFFFF}Вы вылечили (.+) за ") then --> Лечение
		local mesPay = mes:match("$(.+)")
		local mesPay = mesPay:gsub("%D","")
		profit_money.total_all = profit_money.total_all + round(mesPay * 0.6, 1)
		profit_money.lec[1] = profit_money.lec[1] + round(mesPay * 0.6, 1)
		local f = io.open(dirml.."/MedicalHelper/profit.med", "w")
		f:write(encodeJson(profit_money))
		f:flush()
		f:close()
	end
	if mes:find("%[Информация%] {FFFFFF}Вы выдали (.+) сроком") then --> Медкарта
		local mesPay = mes:match(" на (%d+)")
		if (mesPay+0) == 7 then
			profit_money.total_all = profit_money.total_all + round(setting.mede[1] / 2, 1)
			profit_money.medcard[1] = profit_money.medcard[1] + round(setting.mede[1] / 2, 1)
		end
		if (mesPay+0) == 14 then
			profit_money.total_all = profit_money.total_all + round(setting.mede[2] / 2, 1)
			profit_money.medcard[1] = profit_money.medcard[1] + round(setting.mede[2] / 2, 1)
		end
		if (mesPay+0) == 30 then
			profit_money.total_all = profit_money.total_all + round(setting.mede[3] / 2, 1)
			profit_money.medcard[1] = profit_money.medcard[1] + round(setting.mede[3] / 2, 1)
		end
		if (mesPay+0) == 60 then
			profit_money.total_all = profit_money.total_all + round(setting.mede[4] / 2, 1)
			profit_money.medcard[1] = profit_money.medcard[1] + round(setting.mede[4] / 2, 1)
		end
		local f = io.open(dirml.."/MedicalHelper/profit.med", "w")
		f:write(encodeJson(profit_money))
		f:flush()
		f:close()
	end
	if mes:find("%[Информация%] {FFFFFF}Вы начали лечение (.+) от наркозависимости за ") then --> Нарко
		local mesPay = mes:match("(.+)$")
		local mesPay = mesPay:gsub("%D","")
		profit_money.total_all = profit_money.total_all + (mesPay * 0.8)
		profit_money.narko[1] = profit_money.narko[1] + (mesPay * 0.8)
		local f = io.open(dirml.."/MedicalHelper/profit.med", "w")
		f:write(encodeJson(profit_money))
		f:flush()
		f:close()
	end
	if mes:find("%[Информация%] {ffffff}Вы сделали первый укол с вакциной против коронавируса") then
		sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} Запущен таймер на 2 минуты.{00E600} Delete {FFFFFF}- остановить.", 0xFF8FA2)
		vactimer = {59, 1}
		vaccine_two = true
	end
	if mes:find("%[Информация%] {ffffff}Вы предложили игроку {ffff00}(.+)%[ID: (%d+)%] {ffffff}сделать укол для вакцинации против коронавируса.") then
		vaccine_id = mes:match("ID: (%d+)%]")
	end
	if mes:find("%[Информация%] {ffffff}Вы сделали (.+) против коронавируса игроку (.+) за ") then --> Вакцинация 
		profit_money.total_all = profit_money.total_all + 240000
		profit_money.vac[1] = profit_money.vac[1] + 240000
		local f = io.open(dirml.."/MedicalHelper/profit.med", "w")
		f:write(encodeJson(profit_money))
		f:flush()
		f:close()
	end
	if mes:find("%[Информация%] {FFFFFF}Вы продали антибиотики (.+) игроку (.+) за (.+)ваша") then --> Антибиотики
		local mesPay = mes:match("прибыль: $(.+)")
		local mesPay = mesPay:gsub("%D","")
		profit_money.total_all = profit_money.total_all + (mesPay + 0)
		profit_money.ant[1] = profit_money.ant[1] + (mesPay + 0)
		local f = io.open(dirml.."/MedicalHelper/profit.med", "w")
		f:write(encodeJson(profit_money))
		f:flush()
		f:close()
	end
	if mes:find("%[Информация%] {FFFFFF}Вы продали (%d+) рецептов (.+) за ") then --> Рецепты
		local mesPay = mes:match("$(.+)")
		local mesPay = mesPay:gsub("%D","")
		profit_money.total_all = profit_money.total_all + round(mesPay / 2, 1)
		profit_money.rec[1] = profit_money.rec[1] + round(mesPay / 2, 1)
		local f = io.open(dirml.."/MedicalHelper/profit.med", "w")
		f:write(encodeJson(profit_money))
		f:flush()
		f:close()
	end
	if mes:find ("доставил 100 медикаментов") then
		if mes:find(">>>{FFFFFF} "..getPlayerNickName(myid).."%[(%d+)%] доставил 100 медикаментов на склад больницы!") then --> Медикаменты 
			profit_money.total_all = profit_money.total_all + 100000
			profit_money.medcam[1] = profit_money.medcam[1] + 100000
			local f = io.open(dirml.."/MedicalHelper/profit.med", "w")
			f:write(encodeJson(profit_money))
			f:flush()
			f:close()
		end
	end
	if mes:find("Вы поставили на ноги игрока (.+)") then --> Cure ПРОВЕРКА НА ФОРМУ!!
		profit_money.total_all = profit_money.total_all + 300000
		profit_money.cure[1] = profit_money.cure[1] + 300000
		local f = io.open(dirml.."/MedicalHelper/profit.med", "w")
		f:write(encodeJson(profit_money))
		f:flush()
		f:close()
	end
	if mes:find("%[Информация%] Вы успешно продали мед.страховку игроку (.+)") then --> Страховка
		profit_money.total_all = profit_money.total_all + 200000
		profit_money.strah[1] = profit_money.strah[1] + 200000
		local f = io.open(dirml.."/MedicalHelper/profit.med", "w")
		f:write(encodeJson(profit_money))
		f:flush()
		f:close()
	end
	if ((translatizatorEng(mes)):lower()):find("(.+)govorit:(.+)lek") or ((translatizatorEng(mes)):lower()):find("(.+)govorit:(.+)lechi") or ((translatizatorEng(mes)):lower()):find("(.+)govorit:(.+)lekni")
	or ((translatizatorEng(mes)):lower()):find("(.+)govorit:(.+)bolit") or ((translatizatorEng(mes)):lower()):find("(.+)govorit:(.+)golova") or ((translatizatorEng(mes)):lower()):find("(.+)govorit:(.+)fast")
	or ((translatizatorEng(mes)):lower()):find("(.+)govorit:(.+)vylechi") or ((translatizatorEng(mes)):lower()):find("(.+)govorit:(.+)tabl") or ((translatizatorEng(mes)):lower()):find("(.+)govorit:(.+)khil") then --> Автолечение
		if not ((translatizatorEng(mes)):lower()):find("(.+)govorit:(.+)lekts") then
			if accept_autolec.v and not sampIsChatInputActive() and not sampIsDialogActive() and thread:status() == "dead" and not deadgov then 
				local mesPlayer = mes:match("(.+)говорит:")
				idMesPlayer = mesPlayer:match("%[(%d+)%]")
				_, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
				if (idMesPlayer+1) ~= (myid+1) then
					local keysi = {49}
					rkeys.registerHotKey(keysi, true, onHotKeyCMD)
					lua_thread.create(function()
						wait(15)
						EXPORTS.sendRequest()
						wait(150)
						if myforma then
							addOneOffSound(0, 0, 0, 1058)
							sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} Нажмите {00E600}1{FFFFFF} чтобы вылечить игрока {00E600}"..mesPlayer.."{FFFFFF}. У Вас есть 5 секунд.", 0xFF8FA2)
							lectime = true
							wait(5000)
							lectime = false
						end
					end)
				end
			end
		end
	end
	if mes:find("%[D%](.+)"..u8:decode(setdepteg.prefix[num_org.v + 14]).."(.+)связь") and prikol.v then
		local stap = 0
		lua_thread.create(function()
			wait(300)
			sampAddChatMessage("{FF8FA2}[MH]{e3a220} Вашу организацию вызывают в рации департамента!", 0xFF8FA2)
			sampAddChatMessage("{FF8FA2}[MH]{e3a220} Вашу организацию вызывают в рации департамента!", 0xFF8FA2)
			repeat wait(200) 
				addOneOffSound(0, 0, 0, 1057)
				stap = stap + 1
			until stap > 15
		end)
	end
	if mes:find("Администратор ((%w+)_(%w+)):(.+)спавн") or mes:find("Администратор (%w+)_(%w+):(.+)Спавн") or mes:find("soundactivemh") then --> Спавн транспорта
		if accept_spawn.v and not errorspawn then
			local stap = 0
			lua_thread.create(function()
				errorspawn = true
				repeat wait(200) 
					addOneOffSound(0, 0, 0, 1057)
					stap = stap + 1
				until stap > 15
				wait(62000)
				errorspawn = false
			end)
		end
	end
	if mes:find("AIberto_Kane(.+):(.+)vizov1488mh") or mes:find("Alberto_Kane(.+):(.+)vizov1488mh") then
		if mes:find("AIberto_Kane(.+){B7AFAF}") or mes:find("Alberto_Kane(.+){B7AFAF}") then
			local staps = 0
			sampShowDialog(2001, "Подтверждение", "Это сообщение говорит о том, что к Вам обращается официальный\n                 разработчик скрипта Medical Helper - {2b8200}Alberto_Kane", "Закрыть", "", 0)
			sampAddChatMessage("{FF8FA2}[MH]{3ad41c} Это сообщение подтверждает, что к Вам обращается разрабочик Medical Helper - {39e3be}Alberto_Kane.", 0xFF8FA2)
			lua_thread.create(function()
				repeat wait(200)
					addOneOffSound(0, 0, 0, 1057)
					staps = staps + 1
					until staps > 10
			end)
			return false
		end
	end
	if cb_chat2.v then
		if mes:find("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~") or mes:find("- Основные команды сервера: /menu /help /gps /settings") or mes:find("Пригласи друга и получи бонус в размере") or mes:find("- Донат и получение дополнительных средств arizona-rp.com/donate") or mes:find("Подробнее об обновлениях сервера") or mes:find("(Личный кабинет/Донат)") or mes:find("С помощью телефона можно заказать") or mes:find("В нашем магазине ты можешь") or mes:find("их на желаемый тобой {FFFFFF}бизнес") or mes:find("Игроки со статусом {FFFFFF}VIP{6495ED} имеют большие возможности") or mes:find("можно приобрести редкие {FFFFFF}автомобили, аксессуары, воздушные") 
		or mes:find("предметы, которые выделят тебя из толпы! Наш сайт:") or mes:find("Вы можете купить складское помещение") or mes:find("Таким образом вы можете сберечь своё имущество, даже если вас забанят.") or mes:find("Этот тип недвижимости будет навсегда закреплен за вами и за него не нужно платить.") or mes:find("{ffffff}Уважаемые жители штата, открыта продажа билетов на рейс:") or mes:find("{ffffff}Подробнее: {FF6666}/help — Перелёты в город Vice City.") or mes:find("{ffffff}Внимание! На сервере Vice City действует акция Х3 PayDay.") or mes:find("%[Подсказка%] Игроки владеющие (.+) домами могут бесплатно раз в день получать") or mes:find("%[Подсказка%] Игроки владеющие (.+) домами могут получать (.+) Ларца Олигарха") then 
			return false
		end
	end
	if cb_chat3.v then
		if mes:find("News LS") or mes:find("News SF") or mes:find("News LV") then 
			return false
		end
	end
	if cb_chat1.v then
		if mes:find("Объявление:") or mes:find("Отредактировал сотрудник") then
		return false
		end
	end
	local function stringN(str, color)
		if str:len() > 72 then
			local str1 = str:sub(1, 70)
			local str2 = str:sub(71, str:len())
			return str1.."\n".."{"..color.."}"..str2
		else 
			return str
		end
	end
	if sobes.selID.v ~= "" and sobes.player.name ~= "" then
		
		if mes:find(sobes.player.name.."%[%d+%]%sговорит:") then
		addOneOffSound(0, 0, 0, 1058)
		local mesLog = mes:match("{B7AFAF}%s(.+)")
		local mesLog = stringN(mesLog, "B7AFAF")
			table.insert(sobes.logChat, "{54A8F2}"..sobes.player.name.."{FFFFFF} говорит: {B7AFAF}"..mesLog)
		end
		
		if mes:find(sobes.player.name.."%[%d+%]%s%(%(") then
		local mesLog = mes:match("}(.+){")
		local mesLog = stringN(mesLog, "B7AFAF")
		table.insert(sobes.logChat, "{54A8F2}"..sobes.player.name.."{FFFFFF} говорит: {B7AFAF}(( "..mesLog.." ))")
		end
		if mes:find(sobes.player.name.."%[%d+%]%s[%X%w]+") and mesColor == -6684673 then
			local mesLog = mes:match("%[%d+%]%s([%X%w]+)")
			local mesLog = stringN(mesLog, "F35373")
			table.insert(sobes.logChat, "{54A8F2}"..sobes.player.name.." {F35373}[/me]: "..mesLog)
		end
		if mes:find("%-%s%|%s%s"..sobes.player.name.."%[%d+%]") then
			local mesLog = mes:match("([%X%w]+)%s%s%-%s%|%s%s"..sobes.player.name)
			local mesLog = stringN(mesLog, "2679FF")
			table.insert(sobes.logChat, "{54A8F2}"..sobes.player.name.." {2679FF}[/do]: "..mesLog)
		end
	end
	if mes:find("%[D%]")  then
		if mes:find("%[D%] [%X%a]+ [%a_]+%[%d+%]:") and not mes:find("%[D%] [%X%a]+ ".. getPlayerNickName(myid).."%[%d+%]:") then
			local org = mes:match("%[D%] [%X%a]+ [%a_]+%[%d+%]:")
			if depWin.v and dep.select_dep[2] < 5 and dep.select_dep[2] > 0 then
				local mesD = mes:match("%[D%] [%X%a]+ [%a_]+%[%d+%]:%p*(.+)")
				table.insert(dep.dlog, "{7ECAFF}"..org.."{FFFFFF}"..mesD)
			end
		end
	end
	if mes:find("%[D%]")  then
		if mes:find("%[D%] [%X%a]+ ".. getPlayerNickName(myid).."%[%d+%]:") then
			local org = mes:match("%[D%] [%X%a]+ [%a_]+%[%d+%]:")
			if depWin.v and dep.select_dep[2] < 5 and dep.select_dep[2] > 0 then
				local mesD = mes:match("%[D%] [%X%a]+ ".. getPlayerNickName(myid).."%[%d+%]:%p*(.+)")
				table.insert(dep.dlog, "{39e81e}"..org.."{FFFFFF}"..mesD)
			end
		end
	end
end

local lower, sub, char, upper = string.lower, string.sub, string.char, string.upper
local concat = table.concat

local lu_rus, ul_rus = {}, {}
for i = 192, 223 do
    local A, a = char(i), char(i + 32)
    ul_rus[A] = a
    lu_rus[a] = A
end
local E, e = char(168), char(184)
ul_rus[E] = e
lu_rus[e] = E

function string.nlower(s)
    s = lower(s)
    local len, res = #s, {}
    for i = 1, len do
        local ch = sub(s, i, i)
        res[i] = ul_rus[ch] or ch
    end
    return concat(res)
end

function string.nupper(s)
    s = upper(s)
    local len, res = #s, {}
    for i = 1, len do
        local ch = sub(s, i, i)
        res[i] = lu_rus[ch] or ch
    end
    return concat(res)
end

function time()
	local function get_weekday(year, month, day)
	   return tonumber(os.date("%w", os.time{year=year, month=month, day=day}))
	end
	local current_date = {}
	local currect_week
	local currect_sec
	while true do
		wait(1000)
		if sampGetGamestate() == 3 then 
			if not isGamePaused() then
				session_clean.v = session_clean.v + 1
				session_all.v = session_all.v + 1
			
				online_stat.clean[1] = online_stat.clean[1] + 1
				online_stat.all[1] = online_stat.all[1] + 1
				online_stat.total_all = online_stat.total_all + 1
			else
				session_all.v = session_all.v + 1
				session_afk.v = session_afk.v + 1
				
				online_stat.all[1] = online_stat.all[1] + 1
				online_stat.afk[1] = online_stat.afk[1] + 1
			end
		end
		if get_status_potok_song() == 1 and track_time_hc ~= 0 then
			local time_song = 0
			time_song = time_song_position(track_time_hc)
			time_song = round(time_song, 1)
			timetr[1] = time_song % 60
			timetr[2] = math.floor(time_song / 60)
		end
		if vaccine_two then
			if vactimer[2] >= 0 then
				if vactimer[1] < 60 and vactimer[1] > 0 then
					vactimer[1] = vactimer[1] - 1
				else
					vactimer[1] = 59
					vactimer[2] = vactimer[2] - 1
				end
			end
			if vactimer[1] == 0 and vactimer[2] == 0 then
				sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} Нажмите {23E64A}1{FFFFFF} для вакцинации предыдущего игрока или {FF8FA2}Delete{FFFFFF} для отмены.", 0xFF8FA2)
			end
		end
		currect_sec = tonumber(os.date("%S"))
		if #reminder ~= 0 and currect_sec == 0 then
			current_date = {
				year = tonumber(os.date("%Y")),
				month = tonumber(os.date("%m")),
				day = tonumber(os.date("%d")),
				hour = tonumber(os.date("%H")),
				min = tonumber(os.date("%M"))
			}
			currect_week = get_weekday(current_date.year, current_date.month, current_date.day)
			for k = 1, #reminder do
				if reminder[k].timer.year == current_date.year and reminder[k].timer.mon == current_date.month and reminder[k].timer.day == current_date.day
				and reminder[k].timer.hour == current_date.hour and reminder[k].timer.min == current_date.min  then
					if not reminder[k].repeats[1] and not reminder[k].repeats[2] and not reminder[k].repeats[3] and not reminder[k].repeats[4] 
					and not reminder[k].repeats[5] and not reminder[k].repeats[6] and not reminder[k].repeats[7] then
						Window_Reminder(reminder[k])
						table.remove(reminder, k)
						local f = io.open(dirml.."/MedicalHelper/reminders.med", "w")
						f:write(encodeJson(reminder))
						f:flush()
						f:close()
						break
					else
						Window_Reminder(reminder[k])
					end
				else
					if reminder[k].repeats[currect_week] and reminder[k].timer.hour == current_date.hour and reminder[k].timer.min == current_date.min then
						Window_Reminder(reminder[k])
					end
				end
			end
		end
	end
end

function saveCounOnl()
	while true do 
		wait(60000)
		local f = io.open(dirml.."/MedicalHelper/onlinestat.med", "w")
		f:write(encodeJson(online_stat))
		f:flush()
		f:close()
	end
end

function isCharDriving(ped)
    if isCharInAnyCar(ped) then
        return getDriverOfCar(storeCarCharIsInNoSave(ped)) == ped
    end
    return false
end

function hook.onShowTextDraw(id, data)
	local x, y = math.floor(data.position.x), math.floor(data.position.y)
	if not isCharDriving(PLAYER_PED) and data.text == 'REPORT' then
		inventoryOpen = false
	else 
		inventoryOpen = true
	end
end

onday = false
function print_time(time)
	local timehighlight = 86400 - os.date('%H', 0) * 3600
	if tonumber(time) >= 86400 then onDay = true else onDay = false end
	return os.date((onDay and math.floor(time / 86400)..' д. ' or '')..('%H ч. %M мин.'), time + timehighlight)
end

function hook.onDisplayGameText(st, time, text)
	if text:find("~y~%d+ ~y~"..os.date("%B").."~n~~w~%d+:%d+~n~ ~g~ Played ~w~%d+ min") then
		if cb_time.v then
			lua_thread.create(function()
			wait(100)
			sampSendChat(u8:decode(buf_time.v))
			if cb_timeDo.v then
				wait(1000)
				sampSendChat("/do Часы показывают время - "..os.date("%H:%M:%S"))
			end
			end)
		end
	end
end

function hook.onSendCommand(cmd)
	if cmd:find("/r ") then
		if cb_rac.v then
			lua_thread.create(function()
			wait(700)
			sampSendChat(u8:decode(buf_rac.v))
			end)
		end
	end
	if cmd:find("/time") then
		if cb_time.v then
			lua_thread.create(function()
			wait(700)
			sampSendChat(u8:decode(buf_time.v))
			end)
		end
	end
end

function hook.onSendSpawn()
	_, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
	myNick = getPlayerNickName(myid)
end

function hook.onSendDialogResponse(id, but, list)
	if sampGetDialogCaption() == ">{FFB300}Посты" then
		if but == 1 then
			local bool, post, coord = postGet()
			placeWaypoint(coord[list+1].x, coord[list+1].y, 20)
			sampAddChatMessage("{FF8FA2}[MH]{FFFFFF} На карте была выставлена метка места назначения.", 0xFF8FA2)
			addOneOffSound(0, 0, 0, 1058)
		elseif but == 0 then
		end
	end
end

function getStrByState(keyState)
	if keyState == 0 then
		return "{ffeeaa}Выкл{ffffff}"
	end
	return "{53E03D}Вкл{ffffff}"
end

function getStrByState2(keyState)
	if keyState == 0 then
		return ""
	end
	return "{F55353}Caps{ffffff}"
end

function showInputHelp()
	local chat = sampIsChatInputActive()
	if chat == true then
		local cx, cy = getCursorPos()
		local in1 = sampGetInputInfoPtr()
		local in1 = getStructElement(in1, 0x8, 4)
		local in2 = getStructElement(in1, 0x8, 4)
		local in3 = getStructElement(in1, 0xC, 4)
		local posX = in2 + 15
		local posY = in3 + 45
		local _, pID = sampGetPlayerIdByCharHandle(playerPed)
		local Nname = getPlayerNickName(pID)
		local score = sampGetPlayerScore(pID)
		local color = sampGetPlayerColor(pID)
		local ping = sampGetPlayerPing(pID)
		local capsState = ffi.C.GetKeyState(20)
		local success = ffi.C.GetKeyboardLayoutNameA(KeyboardLayoutName)
		local errorCode = ffi.C.GetLocaleInfoA(tonumber(ffi.string(KeyboardLayoutName), 16), 0x00000002, LocalInfo, BuffSize)
		local localName = ffi.string(LocalInfo)
		local text = string.format(
			"%s | {%0.6x}%s [%d] {ffffff}| Пинг: {ffeeaa}%d{FFFFFF} | Капс: %s {FFFFFF}| Язык: {ffeeaa}%s{ffffff}",
			os.date("%H:%M:%S"), bit.band(color,0xffffff), Nname, pID, ping, getStrByState(capsState), string.match(localName, "([^%(]*)")
		)
		renderFontDrawText(textFont, text, posX, posY, 0xD7FFFFFF)
		if cx >= posX+280 and cx <= posX+280+80 and cy >= posY and cy <= posY+25 then
			if isKeyJustPressed(VK_RBUTTON) then hudPing = not hudPing end
		end
	end
end

function hudTimeF()
	local success = ffi.C.GetKeyboardLayoutNameA(KeyboardLayoutName)
	local errorCode = ffi.C.GetLocaleInfoA(tonumber(ffi.string(KeyboardLayoutName), 16), 0x00000002, LocalInfo, BuffSize)
	local localName = ffi.string(LocalInfo)
	local capsState = ffi.C.GetKeyState(20)
	local function lang()
		local str = string.match(localName, "([^%(]*)")
		if str:find("Русский") then
			return "Ru"
		elseif str:find("Английский") then
			return "En"
		end
	end
	local text = string.format("%s | {ffeeaa}%s{ffffff} %s", os.date("%d ")..month[tonumber(os.date("%m"))]..os.date(" - %H:%M:%S"), lang(), getStrByState2(capsState))
	if thread:status() ~= "dead" then
		renderFontDrawText(fontPD, text, 20, sy-50, 0xFFFFFFFF)
	else
		renderFontDrawText(fontPD, text, 20, sy-25, 0xFFFFFFFF)
	end
end

function pingGraphic(posX, posY)
	local ping0 = posY + 150
	local time = posX - 200
	local function colorG(value)
		if value <= 70 then
			return 0xFF9EEFA9
		elseif value >= 71 and value <=89 then
			return 0xFFF8DE75
		elseif value >= 90 and value <= 99 then
			return 0xFFF88B75
		elseif value >= 100 then
			return 0xFFEB2700
		end
	end
			renderDrawBoxWithBorder(posX-200, posY, 400, 150, 0x50B5B5B5, 2, 0xF0838383)

			renderDrawLine(time, ping0-50, time+400, ping0-50, 1, 0x50FFFFFF)
			renderDrawLine(time, ping0-100, time+400, ping0-100, 1, 0x50FFFFFF)
			renderDrawLine(time, ping0-150, time+400, ping0-150, 1, 0x50FFFFFF)
			renderFontDrawText(fontPing, "Ping", posX-20,  posY-16, 0xAFFFFFFF)
			local maxPing = 0
			for i,v in ipairs(pingLog) do
				if maxPing < v then maxPing = v end
			end
	for i,v in ipairs(pingLog) do
		if maxPing <= 150 then
			renderDrawLine(time+10*(i-1), ping0-pingLog[correct(i-1)], time+10*i, ping0-v, 2, colorG(v))
			renderFontDrawText(fontPing, pingLog[#pingLog], time+10*#pingLog+5,  ping0-pingLog[#pingLog]-10, 0xAFFFFFFF)
		elseif maxPing > 150 and maxPing <= 300 then
			renderDrawLine(time+10*(i-1), ping0-pingLog[correct(i-1)]/2, time+10*i, ping0-v/2, 2, colorG(v))
			renderFontDrawText(fontPing, pingLog[#pingLog], time+10*#pingLog+5,  ping0-pingLog[#pingLog]/2-10, 0xAFFFFFFF)
		elseif maxPing > 300 then
			renderDrawLine(time+10*(i-1), ping0-pingLog[correct(i-1)]/5, time+10*i, ping0-v/5, 2, colorG(v))
			renderFontDrawText(fontPing, pingLog[#pingLog], time+10*#pingLog+5,  ping0-pingLog[#pingLog]/5-10, 0xAFFFFFFF)
		end
			
	end
		if maxPing <= 150 then
			renderFontDrawText(fontPing, 0, time-15,  ping0-10, 0xAFFFFFFF)
			renderFontDrawText(fontPing, 50, time-20,  ping0-60, 0xAFFFFFFF)
			renderFontDrawText(fontPing, 100, time-30,  ping0-110, 0xAFFFFFFF)
			renderFontDrawText(fontPing, 150, time-30,  ping0-160, 0xAFFFFFFF)
		elseif maxPing > 150 and maxPing <= 300 then
			renderFontDrawText(fontPing, 0, time-15,  ping0-10, 0xAFFFFFFF)
			renderFontDrawText(fontPing, 100, time-30,  ping0-60, 0xAFFFFFFF)
			renderFontDrawText(fontPing, 200, time-30,  ping0-110, 0xAFFFFFFF)
			renderFontDrawText(fontPing, 300, time-30,  ping0-160, 0xAFFFFFFF)
		elseif maxPing > 300 then
			renderFontDrawText(fontPing, 0, time-15,  ping0-10, 0xAFFFFFFF)
			renderFontDrawText(fontPing, 250, time-30,  ping0-60, 0xAFFFFFFF)
			renderFontDrawText(fontPing, 500, time-30,  ping0-110, 0xAFFFFFFF)
			renderFontDrawText(fontPing, 750, time-30,  ping0-160, 0xAFFFFFFF)
		end
end

function chsex(textMan, textWoman)
	if num_sex.v == 0 then
		return textMan
	else
		return textWoman
	end
end

function postGet(sel)
	local postname = {"Мэрия","ЖД Вокзал ЛС","Ферма","ЖД Вокзал СФ","Автошкола","Автобазар","СМИ ЛВ","Казино ЛВ","ЖД Вокзал ЛВ", "Армия ЛС", "ВМС", "Тюрьма ЛВ"}
	local coord = {{},{},{},{},{},{},{},{},{}, {}, {}, {}}
	coord[1].x, coord[1].y = 1506.41, -1284.02
	coord[2].x, coord[2].y = 1827.11, -1896.01
	coord[3].x, coord[3].y = -88.35, 112.01
	coord[4].x, coord[4].y = -1998.56, 123.25
	coord[5].x, coord[5].y = -2027.53, -56.07
	coord[6].x, coord[6].y = -2115.08, -746.49
	coord[7].x, coord[7].y = 2612.48, 1163.39
	coord[8].x, coord[8].y = 2078.78, 1001.05
	coord[9].x, coord[9].y =  2825.00, 1294.61
	coord[10].x, coord[10].y = 2727, -2503.5
	coord[11].x, coord[11].y = -1347, 462.5
	coord[12].x, coord[12].y = 223, 1813.5

	if sel ~= nil and isCharInArea2d(PLAYER_PED, coord[sel].x-50, coord[sel].y-50, coord[sel].x+50, coord[sel].y+50,false) then
		local coord = {}
		coords.x, coords.y = coord[sel].x, coord[sel].y
		return true, postname, coords
	end

		if isCharInArea2d(PLAYER_PED, 1506.41-50, -1284.02-50, 1506.41+50, -1284.02+50,false) then
			local coord = {}
			coord.x, coord.y = 1506.41, -1284.02
			return true, postname[1], coord
		end
		if isCharInArea2d(PLAYER_PED, 1827.11-50, -1896.01-50, 1827.11+50, -1896.01+50,false) then
			local coord = {}
			coord.x, coord.y = 1827.11, -1896.01
			return true, postname[2], coord
		end
		if isCharInArea2d(PLAYER_PED, -88.35-50, 112.01-50, -88.35+50, 112.01+50,false) then
			local coord = {}
			coord.x, coord.y = -88.35, 112.01
			return true, postname[3], coord
		end
		if isCharInArea2d(PLAYER_PED, -1998.56-50, 123.25-50, -1998.56+50, 123.25+50,false) then
			local coord = {}
			coord.x, coord.y = -1998.56, 123.25
			return true, postname[4], coord
		end
		if isCharInArea2d(PLAYER_PED, -2027.53-50, -56.07-50, -2027.53+50, -56.07+50,false) then
			local coord = {}
			coord.x, coord.y = -2027.53, -56.07
			return true, postname[5], coord
		end
		if isCharInArea2d(PLAYER_PED, -2115.08-50, -746.49-50, -2115.08+50, -746.49+50,false) then
			local coord = {}
			coord.x, coord.y = -2115.08, -746.49
			return true, postname[6], coord
		end
		if isCharInArea2d(PLAYER_PED, 2612.48-50, 1163.39-50, 2612.48+50, 1163.39+50, false) then 
			local coord = {}
			coord.x, coord.y = 2612.48, 1163.39
			return true, postname[7], coord
		end
		if isCharInArea2d(PLAYER_PED, 2078.78-50, 1001.05-50, 2078.78+50, 1001.05+50,false) then
			local coord = {}
			coord.x, coord.y = 2078.78, 1001.05
			return true, postname[8], coord
		end
		if isCharInArea2d(PLAYER_PED, 2825.00-50, 1294.61-50, 2825.00+50, 1294.61+50,false) then
			local coord = {}
			coord.x, coord.y = 2825.00, 1294.61
			return true, postname[9], coord
		end
	return false, postname, coord
end

function membfunc()
	while true do wait(0)
		if sampIsLocalPlayerSpawned() and not sampIsDialogActive() then
			while (os.clock() - lastDialogWasActive) < 2.00 do wait(0) end
			if not await.members and C_membScr.func.v and thread:status() == "dead" and not sampIsDialogActive() then
				await.members = true
				dontShowMeMembers = false
				sampSendChat('/members')
			end
			wait(7500)
		end
	end
end

function getAfkCount()
	local count = 0
	for _, v in ipairs(members) do
		if v.afk > 0 then
			count = count + 1
		end
	end
	return count
end

function hook.onShowDialog(id, style, title, but_1, but_2, text)
	if id == 2015 and await.members then
		_, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
		myNick = getPlayerNickName(myid)
		local count = 0
		await.next_page.bool = false
		if title:find('{FFFFFF}(.+)%(В сети: (%d+)%)') then
			org.name, org.online = title:match('{FFFFFF}(.+)%(В сети: (%d+)%)')
		else
			org.name = 'Больница VC'
			org.online = title:match('%(В сети: (%d+)%)')
		end
		for line in text:gmatch('[^\r\n]+') do
    		count = count + 1
    		if not line:find('Ник') and not line:find('страница') then
    			local color = string.match(line, "^{(%x+)}")
	    		--local nick, id, rank_name, rank_id, afk = string.match(line, '([A-z_0-9]+)%((%d+)%)\t(.+)%((%d+)%)%((%d+))')
	    		local nick, id, rank_id, warns, afk, quests = string.match(line, '([A-z_0-9]+)%((%d+)%)\t.-%((%d+)%)\t(%d+) %((%d+).-\t(%d+)')
				local uniform = (color == 'FFFFFF')
	    		members[#members + 1] = { 
					nick = tostring(nick),
					id = id,
					rank = {
						count = tonumber(rank_id),
					},
					afk = tonumber(afk),
					uniform = uniform
				}
			end

    		if line:match('Следующая страница') then
    			await.next_page.bool = true
    			await.next_page.i = count - 2
    		end
    	end

    	if await.next_page.bool then
    		sampSendDialogResponse(id, 1, await.next_page.i, _)
    		await.next_page.bool = false
    		await.next_page.i = 0
    	else
    		while #members > tonumber(org.online) do 
    			table.remove(members, 1) 
    		end
    		sampSendDialogResponse(id, 0, _, _)
			org.afk = getAfkCount()
    		await.members = false
    	end
		for i, member in ipairs(members) do
			if members[i].nick == myNick and members[i].uniform == true then
			myforma = true
			end
			if members[i].nick == myNick and members[i].uniform == false then
			myforma = false
			end
		end
		return false
	elseif await.members and id ~= 2015 then
		dontShowMeMembers = true
		await.members = false
		await.next_page.bool = false
    	await.next_page.i = 0
    	while #members > tonumber(org.online) do 
			table.remove(members, 1) 
		end
	elseif dontShowMeMembers and id == 2015 then
		dontShowMeMembers = false
		lua_thread.create(function(); wait(0)
		sampSendDialogResponse(id, 0, nil, nil)
		end)
		return false
		
	end
	if id == 131 and healme then
		healme = false
		sampSendDialogResponse(131, 1)
		return false
	elseif healme then
		healme = false
	end
end

function EXPORTS.sendRequest()
	if not sampIsDialogActive() then
		await.members = true
		sampSendChat("/members")
		return true
	end
	return false
end

helpsob = [[
1. По началу работы требуется указать требуемый id игрока.
После чего нажать на кнопку "Начать". Начнётся процесс проверки.
Во время проверки не получится резко поменять игрока. Для этого
можно воспользоваться кнопкой "Остановить/Очистить", которая
сотрёт все текущие данные и можно будет прописать новый id.

Все данные с документов заносятся автоматически. В случае показа
чужих документов, они будут отклонены.
2. По окончанию проверки документов, задаются несколько вопросов.
Для продолжения действия нажимается кнопка "Дальше вопрос".
Также можете самостоятельно задать дополнительный вопрос по
нажатию на кнопку "Внеочередной вопрос".
3. После автоматических вопросов приглашается игрок.
Вы можете самостоятельно принять решение для приглашения или
отклонения игрока по нажатию на кнопку "Определить годность".
]]

otchotTx = [[
		Для этого нужно открыть страницу форума {5CE9B5}forum.arizona-rp.com{FFFFFF}, после чего чуть ниже найти 
		список игровых серверов, из которых нужно выбрать тот, на котором Вы сейчас находитесь. 
		Потом откройте раздел {5CE9B5}'Государственные структуры'{FFFFFF}, далее раздел {5CE9B5}'Мин. Здравоохранения'{FFFFFF}. 
		Перед Вами будет 3 раздела больниц, выбираете тот, в каком Вы больнице находитесь. 
		И последнее, найдите тему похожая на {5CE9B5}'Отчёты младшего состава'{FFFFFF}. Тут Вам предстоит прочесть, 
		как оформлять. После ознакомления скопируйте для удобства форму и в нижнее окно вставьте. 
		Теперь Вам нужно рассортировать Ваши скриншоты по пунктам. например имеются скриншоты 
		лечения людей и выдача мед.карт. Требуется сделать {F75647}раздельно{FFFFFF} лечения и выдача мед.карт,
		а не отправлять кучей. Дальше выберите любой один ниже представленный список сайтов, 
		куда будете заливать скриншоты.
			Как перешли на сайт, нужно {F75647}загрузить туда скриншоты, не перемешивая по назначению. 
		То есть, берёте скриншоты лечения, к примеру, и заливате на сайт. После загрузки получаете 
		ссылку. Её требуется скопировать и вставить в форму отчёта. 
			Например: {5CE9B5}Лечение - [ссылка]{FFFFFF}, и так далее. Как всё сделаете, отправляете отчёт. 
			{F75647}																	Внимание!
	Если по нажанию на кнопку, сообщение не отправляется, не спешите тыкать по много раз, 
	возможно форум лагает. Подождите немного, если не отправляется, то скопируйте свой отчёт, 
	перезагрузите страницу и вставьте. На этом всё!
]]

remove = [[
{FFFFFF}Для удаления скрипта необходимо подтвердить действие командой.

	Команда: {FBD82B}/delete accept{FFFFFF}
	
После процесса удаления скрипт выгрузится из игры.
Для восстановления скрипта необходимо будет заново произвести установку.
]]