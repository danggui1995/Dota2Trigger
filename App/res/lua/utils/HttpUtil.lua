
-- 正在请求中的url
local _requestingURLs = {}

local private = {}

function private.showTipMsg(msg, isShow)
	if isShow == nil then isShow = true end

	if msg and MsgManager and isShow then
		MsgManager.showRollTipsMsg(msg)
	else
		printWarning(msg)
	end
end

local function userData2Lua(dict)
	local tb = {}
	for k, v in pairs(dict) do
		tb[k] = v
	end
	return tb
end

function private.getFormatedURLData(params, key, signWord)
	if signWord == nil then signWord = "sign" end
	local md5ParamsT = {}
	local paramsT = {}
	for k, v in pairs(params) do
		local key = tostring(k)
		local value = tostring(v)
		if (key and key ~= "" and key ~= "0") and (value and value ~= "" and value ~= "0") then
			table.insert(md5ParamsT, key.."="..string.htmlspecialchars(string.trim(value)))
		end
		table.insert(paramsT, key.."="..value)
	end
	table.sort(md5ParamsT)
	table.sort(paramsT)
	local md5ParamsStr = table.concat(md5ParamsT, "&") .. key
	local paramsStr = table.concat(paramsT, "&")
	local sign = string.format("&%s=%s", signWord, string.lower(CSharp.XStringTools.StringToMD5(md5ParamsStr)))
	return paramsStr..sign
end

function private.onHttpResponse(dict, onSuccess, onFailed, url, showTips)
	_requestingURLs[url] = nil

	dict = userData2Lua(dict)

	if dict.status ~= 200 then
		private.showTipMsg(string.format("HTTP response error status=%s, error=%s", dict.status, tostring(dict.error)), showTips)
		if onFailed then
			onFailed({code = -1, reason = string.format("status = %s", dict.status), status = dict.status, rawData = dict})
		end
		return
	end

	local jsContent = json.decode(dict.data)
	if type(jsContent) == "table" then
		local code = tonumber(jsContent.code)
		if code == 1000 then
			if onSuccess then
				-- dump(5, jsContent, "jsContent")
				onSuccess(jsContent.data)
			end
		else
			local reason = jsContent.content or jsContent.data or ""
			private.showTipMsg(string.format("HTTP response error! %s(code=%d)", reason, code or 0), showTips)
			if onFailed then
				onFailed({code = code, reason = reason, rawData = dict})
			end
		end
	else
		private.showTipMsg("HTTP response error! data = -1", showTips)
		if onFailed then
			onFailed({code = -1, reason = "data = -1", rawData = dict })
		end
	end
end

function private.sendGet(params)
	local data = private.getFormatedURLData(params.params, params.key)
	local url = string.format("%s%s?%s", params.ip, params.action, data)

	local function callback(dict)
		private.onHttpResponse(dict, params.onSuccess, params.onFailed, url, params.showTips)
	end
	CSharp.HttpClient:Get(url, params.needUnZip, params.timeout, callback)
	log("HttpUtil: Get ", url)

	return true
end

function private.sendPost(params)
	local data = private.getFormatedURLData(params.params, params.key)
	local url = string.format("%s%s", params.ip, params.action)

	if _requestingURLs[url] then
		local errorStr = string.format("The url is requesting:%s", url)
		private.showTipMsg(errorStr, false)
		-- if params.onFailed then
		-- 	params.onFailed({code = -2, reason = errorStr})
		-- end
		return
	end

	local failedTimes = 0
	local function doSendPost()
		local function callback(dict)
			local function onFailed(data)
				failedTimes = failedTimes + 1
				if failedTimes >= params.retryTimes then
					dump(52, data, "doSendPost onFailed")
					if params.onFailed then
						params.onFailed(data)
					end
				else
					if params.retryDelay <= 0 then
						doSendPost()
					else
						Timer:scheduleOnce(params.retryDelay,doSendPost)
					end
				end
			end
			private.onHttpResponse(dict, params.onSuccess, onFailed, url, params.showTips)
		end

		CSharp.HttpClient:Post(url, data, params.needUnZip, params.timeout, callback)
		-- log("HttpUtil: Post ", url)
		_requestingURLs[url] = true
	end
	doSendPost()

	-- printTable(1, "HttpUtil.sendPost url:" .. url, data)
	return true
end

------以下为公共接口-------------------------
local M = {}

-- 常规http请求，该接口不适合用于下载文件
-- ip			#string		地址，参考AgentReader.centerURL
-- action		#string		要执行的操作，一般使用HttpActionType枚举中的值
-- key			#string		加密用key，一般使用AgentReader.phpKey
-- params		#table		执行该条http请求的参数
-- isGet		#boolean	是否使用get，默认使用post
-- timeout		#number		超时时间(s)，TimeoutForRead等于该值，TimeoutForConnect等于该值的一半，默认值30s
-- showTips		#boolean	是否显示异常飘字，默认值为false
-- retryTimes	#boolean	请求失败时尝试的次数，默认为1次
-- retryDelay	#number		请求失败再次尝试的延时(s)，为0或者nil时立马再次请求
-- onSuccess	#function	请求成功的回调，如：local function onSuccess(data) end
-- onFailed		#function	请求失败的回调，如：local function onFailed(data) end
function M.send(params)
	params = params or {}
	assert(type(params.ip) == "string", type(params.ip).." ip must be a string")
	assert(type(params.action) == "string", type(params.action).." action must be a string")
	assert(type(params.key) == "string", type(params.key).." key must be a string")
	assert(type(params.params) == "table", type(params.params).." params must be a table")

	if params.needUnZip == nil then
		params.needUnZip = true
	end

	if not params.timeout then
		params.timeout = 30
	end

	if not params.retryTimes then
		params.retryTimes = 1
	end

	if not params.retryDelay then
		params.retryDelay = 0
	end

	if params.isGet then
		return private.sendGet(params)
	else
		return private.sendPost(params)
	end
end

--上传文件
function M.uploadFile(params)
	params = params or {}
	local needUnZip = true
	if params.needUnZip ~= nil then
		needUnZip = params.needUnZip
	end
	assert(type(params.url) == "string", type(params.url).." url must be a string")
	assert(type(params.fileFullPath) == "string", type(params.fileFullPath).." fileFullPath must be a string")

	local url = params.url
	if type(params.params) == "table" then
		local paramStr = private.getFormatedURLData(params.params, params.key)
		url = string.format("%s?%s", url, paramStr)
	end

	if not params.timeout then
		params.timeout = 30
	end

	-- params.showTips = false

	local function callback(dict)
		dict = userData2Lua(dict)

		if dict.status ~= 200 then
			private.showTipMsg(string.format("HTTP response error status=%s, error=%s", dict.status, tostring(dict.error)), params.showTips)
			if params.onFailed then
				params.onFailed(dict)
			end
			return
		end

		if type(dict.data) == "string" and string.find(dict.data, "{") == 1 then
			local jsContent = json.decode(dict.data)
			if type(jsContent) == "table" then
				local code = tonumber(jsContent.code)
				if code == 1000 then
					if params.onSuccess then
						params.onSuccess(dict)
					end
				else
					local reason = jsContent.content or jsContent.data or ""
					private.showTipMsg(string.format("HTTP response error! %s(code=%d)", reason, code or 0), params.showTips)
					if params.onFailed then
						params.onFailed(dict)
					end
				end
			else
				private.showTipMsg("HTTP response error! data = -1", params.showTips)
				if params.onFailed then
					params.onFailed(dict)
				end
			end
		else
			if params.onSuccess then
				params.onSuccess(dict)
			end
		end
	end
	CSharp.HttpClient:UploadFile(url, params.fileFullPath, needUnZip, params.timeout, callback)
end

--下载语音、头像文件
function M.downloadFile(params)
	params = params or {}
	assert(type(params.url) == "string", type(params.url).." url must be a string")
	assert(type(params.fileFullPath) == "string", type(params.fileFullPath).." fileFullPath must be a string")

	local url = params.url
	if type(params.params) == "table" then
		local paramStr = private.getFormatedURLData(params.params, params.key)
		url = string.format("%s?%s", url, paramStr)
	end
	log(url)

	params.needUnZip = false

	if not params.timeout then
		params.timeout = 30
	end

	params.showTips = false

	local function callback(dict)
		dict = userData2Lua(dict)

		dict.filePath = params.fileFullPath

		if dict.status ~= 200 then
			private.showTipMsg(string.format("HTTP response error status=%s, error=%s", dict.status, tostring(dict.error)), params.showTips)
			if params.onFailed then
				params.onFailed(dict.data)
			end
			return
		end

		--if dict.data then
			-- dump(1, dict, "~~~~~~~~~~~~~")
			-- local jsContent = json.decode(dict.data)
			-- if jsContent.code and jsContent.code ~= 1000 then
			-- 	if params.onFailed then
			-- 		params.onFailed(dict,jsContent.msg)
			-- 	end
			-- 	return 
			-- end
		--end 
		if params.onSuccess then
			params.onSuccess(dict)
		end
	end

	if params.inBackground then
		return CSharp.HttpClient:DownloadFileInBackground(url, params.fileFullPath, params.needUnZip, params.timeout, callback, false, params.md5)
	else
		return CSharp.HttpClient:DownloadFile(url, params.fileFullPath, params.needUnZip, params.timeout, callback, false, params.md5)
	end
end

function M.clear()
	CSharp.HttpClient:ClearAllTask()
end

--格式化URL数据
function M.getFormatedURLData(params, key, signWord)
	return private.getFormatedURLData(params, key, signWord)
end

rawset(_G, "HttpUtil", M)
