local matGroup = [[
							{
								from = "%s.vmat"
								to = "%s"
							},
]]

local aniGroup = [[
					{
						_class = "AnimFile"
						name = "%s"
						activity_name = ""
						activity_weight = 1
						weight_list_name = ""
						fade_in_time = 0.2
						fade_out_time = 0.2
						looping = false
						delta = false
						worldSpace = false
						hidden = false
						anim_markup_ordered = false
						disable_compression = false
						animgraph_additive = false
						source_filename = "%s"
						import_bone_scales = true
						start_frame = 0
						end_frame = -1
						framerate = -1.0
						reverse = false
					},
]]

local pattern = [[
<!-- kv3 encoding:text:version{e21c7f3c-8a33-41c5-9977-a76d3a32aa0d} format:modeldoc31:version{165d48dd-8adc-4f1d-abf7-4992e04ad577} -->
{
	rootNode = 
	{
		_class = "RootNode"
		children = 
		[
			{
				_class = "MaterialGroupList"
				children = 
				[
					{
						_class = "DefaultMaterialGroup"
						remaps = 
						[
%s
						]
						use_global_default = false
						global_default_material = ""
					},
				]
			},
			{
				_class = "RenderMeshList"
				note = "Type note..."
				children = 
				[
					{
						_class = "RenderMeshFile"
						name = "%s"
						filename = "%s"
						import_scale = 1
						import_filter = 
						{
							exclude_by_default = false
							exception_list = [  ]
						}
					},
				]
			},
			{
				_class = "BoneMarkupList"
				children = 
				[
					{
						_class = "BoneMarkup"
						target_bone = ""
						ignore_Translation = false
						ignore_rotation = false
						ignore_scale = false
						do_not_discard = true
					},
				]
				bone_cull_type = "None"
				primary_root_bone = ""
			},
			{
				_class = "AnimationList"
				children = 
				[
%s
				]
				default_root_bone_name = ""
			},
			{
				_class = "ModelModifierList"
				children = 
				[
					{
						_class = "ModelModifier_ScaleAndMirror"
						scale = 100.0
						mirror_x = false
						mirror_y = false
						mirror_z = false
						flip_bone_forward = false
						swap_left_and_right_bones = false
					},
				]
			},
		]
		model_archetype = ""
		primary_associated_entity = ""
		anim_graph_name = ""
		importer_notes = """
Imported from VMDL
"""
	}
}
]]

--[[
    批量自动生成Vmdl
    注意：每个项目都有自己的规范，这里只是作为一种思路，并不能通用
]]
local function testGenVmdl(str1, str2, btn)
	local fbxpath = str1
	if fbxpath == "" then
		fbxpath = "D:/gitee/metalmax/content/models/monsters"
	end
	local animMap = {}
	local matMap = {}
	local skinMap = {}
	local totalCnt = 0

	UIManager.openView("waitview")

    XFolderTools.TraverseFiles(fbxpath, function(fullpath)
        local ext = IO.Path.GetExtension(fullpath)
		local filename = IO.Path.GetFileNameWithoutExtension(fullpath)
		local dirname = FileUtil.getShortDirName(fullpath)
		if not animMap[dirname] then
			animMap[dirname] = {}
			matMap[dirname] = {}
			totalCnt = totalCnt + 1
		end
		
        if ext == ".fbx" then
			if dirname ~= filename then
            	table.insert(animMap[dirname], fullpath)
			else
				skinMap[dirname] = fullpath
			end
		elseif ext == ".vmat" then
			table.insert(matMap[dirname], fullpath)
        end
    end, true)

	local cnt = 1
	for fbxname, list in pairs(animMap) do
		local matdatalist = {}
		local animdatalist = {}
		for _, animpath in ipairs(list) do
			local filename = IO.Path.GetFileNameWithoutExtension(animpath)
			local animdata = string.format(aniGroup, filename, FileUtil.getRelativePath(animpath))

			table.insert(animdatalist, animdata)
		end

		local matlist = matMap[fbxname]
		if matlist and #matlist > 0 then
			for _, matpath in ipairs(matlist) do
				local filename = IO.Path.GetFileNameWithoutExtension(matpath)
				local matdata = string.format(matGroup, filename, FileUtil.getRelativePath(matpath))
	
				table.insert(matdatalist, matdata)
			end
		end
		
		local matdata = table.concat(matdatalist, "")
		local animdata = table.concat(animdatalist, "")
		local vmdldata = string.format(pattern, matdata, fbxname, FileUtil.getRelativePath(skinMap[fbxname]), animdata)

		local writepath = skinMap[fbxname]:gsub(".fbx", ".vmdl")
		XFileTools.WriteAllText(writepath, vmdldata)
		print("gen vmdl at ", writepath)

		Dispatcher.dispatchEvent(EventType.Progress_Change_Wait, cnt / totalCnt * 100, "自动生成vmdl")
        cnt = cnt + 1
	end

	print("gen vmdl finished")
end

local function testGenDmx(str1, str2, btn)
	
end

local M = {
	-- {"fbx转dmx", "需要处理的目录", "", testGenDmx, "test_gen_dmx"},
	{"自动生成vmdl", "需要处理的目录", "", testGenVmdl, "test_gen_vmdl"},
}

return M