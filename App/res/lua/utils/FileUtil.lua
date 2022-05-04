---@class FileUtil
local M = {}

-- 获取本地玩家文件夹
function M.getLocalPlayerPath()
	local localPath = CSharp.ResourceFileBook:GetLocalCachePath()
	if localPath ~= "" then
		local dir = string.format("%s%s", localPath, "Player")
		CSharp.XFolderTools.CreateDirectory(dir)
		return dir
	end
end

-- 获取本地测试文件夹
function M.getLocalTestPath()
	local localPath = CSharp.ResourceFileBook:GetLocalCachePath()
	if localPath ~= "" then
		local dir = string.format("%s%s", localPath, "Test")
		CSharp.XFolderTools.CreateDirectory(dir)
		return dir
	end
end

function M.getLocalTestInvokePath()
	local localPath = CSharp.ResourceFileBook:GetLocalCachePath()
	if localPath ~= "" then
		local dir = string.format("%s%s", localPath, "TestInvoke")
		CSharp.XFolderTools.CreateDirectory(dir)
		return dir
	end
end

-- 获取本地玩家文件
function M.getPlayerFile(id)
	local playerPath = M.getLocalPlayerPath()
	if playerPath then
		local filePath = string.format("%s/%s", playerPath, id)
		if not CSharp.XFileTools.Exists(filePath) then
			M.writeFileText(filePath, [[{}]])
		end
		return filePath
	end
end




-- 写内容
function M.writeFileText(filePath, content)
	return CSharp.XFileTools.WriteAllText(filePath, content)
end
-- 追加内容
function M.appendFileText(filePath, content)
	return CSharp.XFileTools.AppendAllText(filePath, content)
end
-- 读内容
function M.readFileText(filePath)
	if CSharp.XFileTools.Exists(filePath) then
		return CSharp.XFileTools.ReadAllText(filePath)
	end
end


function M.getFullPath(fileName)
	local location, fullPath = CSharp.ResourceFileBook:GetAssetFullPath(fileName)
	if location == CSharp.EExistLocation.None then
		fullPath = nil
	end
	return fullPath, location
end 


--判断资源是否在游戏中，可能在客户端，也可能在服务端。
--游戏业务逻辑都应该用这个接口
--如果在服务器，现在的各种XXLoader都支持自动下载。
function M.existResourceInGame( fileName )
	return CSharp.ResourceFileBook:IsResourceExistGame(fileName)
end

--判断资源是否在客户端，缓存字典的形式判断，很快
function M.existResource( fileName )
	return CSharp.ResourceFileBook:IsResourceExist(fileName)
end

--不在客户端，但是又在游戏里，就只能在服务端了
function M.existResourceInServer( fileName )
	return not M.existResource(fileName) and M.existResourceInGame(fileName)
end

function M.existLocalAssetFile( fileName )
	return CSharp.ResourceLoader:IsLocalAssetExist(fileName)
end

--判断资源是否在磁盘里，io的形式判断，有就是有，没有就没，绝对正确. 非游戏资源才调用，游戏资源统一用 existResourceInGame()
function M.existFile( fileName )
	local location, fullPath = CSharp.ResourceFileBook:GetAssetFullPath(fileName)
	if location == CSharp.EExistLocation.None then
		return false
	end
	return true
end

function M.loadAssetStringFromZip(zipRelativePath, fileName)
	return CSharp.ResourceLoader:LoadAssetStringFromZip(zipRelativePath, fileName)
end

--直接在C#端判断
function M.compareMd5(fileName, md5)
	return CSharp.ResourceFileBook:CompareMd5(fileName, md5)
end

function M.getUpdatePath()
	return CSharp.ResourceFileBook:GetUpdateStorePath()
end

function M.getLocalStorePath()
	return CSharp.ResourceFileBook:GetLocalStorePath()
end

function M.getFileMd5( fullPath )
	if M.existFile(fullPath) then
		return CSharp.XFileTools.GetMD5(fullPath)
	end
	return ""
end

--检测某个路径下文件的md5是否与给定的一致
function M.checkFileMD5(fullFilePath, md5)
	if not M.existFile(fullFilePath) then
		return false
	else
		local fileMD5 = M.getFileMd5(fullFilePath)
		if fileMD5 ~= "" and fileMD5 == md5 then
			return true
		else
			return false
		end
	end
end

function M.move( src,tar )
	CSharp.XFileTools.MoveEx(src,tar,false)
end

function M.delete(fullPath)
	CSharp.XFileTools.Delete(fullPath)
end

function M.getRuntimeFile()
	local RuntimePlatform = CSharp.RuntimePlatform

	local platform = __PLATFORM__
	if platform == RuntimePlatform.OSXPlayer or platform == RuntimePlatform.OSXEditor then
		return CSharp.ResourceFileBook:GetProductPath() .. "Runtime/Mac/jz3d.app"
	elseif platform == RuntimePlatform.WindowsPlayer then
		return CSharp.ResourceFileBook:GetProductPath() .. "Runtime/Win/jz3d.exe"
	end
end

--
--获取路径
function M.getDirectoryName(filename)
	return string.match(filename, "(.+)/[^/]*%.%w+$") or "" --*nix system
end

--获取文件名
function M.getFileName(filename)
	local name = string.match(filename, ".+/([^/]*%.%w+)$")
	return name or filename
end

--去除扩展名
function M.getFileNameWithoutExtension(filename)
	local name = M.getFileName(filename)
	local idx = string.match(name,".+()%.%w+$")
	if(idx) then
		return  string.sub(name, 1, idx - 1)
	else
		return name
	end
end

--获取扩展名
function M.getExtension(filename)
	local ex = string.match(filename,".+%.(%w+)$")
	if ex then
		return string.format(".%s",ex)
	end
	return ""
end
rawset(_G, "FileUtil", M)
