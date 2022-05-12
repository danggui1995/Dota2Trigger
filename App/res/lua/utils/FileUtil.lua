local M = {}

function M.combinePath(str1, str2)
	if str1 == nil or str2 == nil then
		printTraceback("combinePath参数不可为空，请检查设置中是否配置相关路径或者代码是否写错")
	else
		return Path.Combine(str1, str2)
	end
end

FileUtil = M
