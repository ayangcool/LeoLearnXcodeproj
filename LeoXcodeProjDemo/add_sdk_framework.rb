#!/usr/bin/ruby -w
#created by leo

# 添加 Test3.framework 对应的移除脚本为：remove_sdk_framework.rb

require 'xcodeproj'

# 打开工程
project_path = './LeoXcodeProjDemo.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# 查询有多少个target
project.targets.each do |target|
	puts target.name
end

# 遍历配置
project.targets[0].build_configurations.each do |config|
	puts config.name
	build_settings = config.build_settings
	build_settings.each do |key, value|
		print key, " == ", value, "\n"
	end
end

# 找到需要操作的target，我这里只有一个target
target_index = 0
project.targets.each_with_index do |target, index|
	if target.name == "LeoXcodeProjDemo"
		target_index = index
		puts target_index
	end
end
target = project.targets[target_index]

# 执行shell命令复制sdk_framework文件夹到 LeoXcodeProjDemo文件夹内
system 'cp -rf ../testFile/sdk_framework ./LeoXcodeProjDemo/sdk_framework'

# 找到要操作的文件夹（此文件夹已存在且添加到项目中）
sdk_framework_file = project.main_group.find_subpath(File.join('LeoXcodeProjDemo', 'sdk_framework'), true)
sdk_framework_file.set_source_tree('<group>')
sdk_framework_file.set_path('sdk_framework')

# 添加 Test3.framework 索引到 sdk_framework 目录
sdk_framework_ref = sdk_framework_file.new_reference("Test3.framework")
# add to target
target.frameworks_build_phases.add_file_reference(sdk_framework_ref)

# 如果framework是动态库，还需要把它添加到 Embed Frameworks 中：
# 先找到 Embed Frameworks 对应的group（新创建的项目可能没有这一项，需要先手动添加 Embed Frameworks 这个选项）
embed_frameworks_group = nil
target.copy_files_build_phases.each do |e|
	puts e.to_s
	if e.display_name.end_with?("Embed Frameworks")
		embed_frameworks_group = e
		break
	end
end

# 如果找到 Embed Frameworks ，添加索引
if embed_frameworks_group
	embed_frameworks_group.add_file_reference(sdk_framework_ref)
end

# 添加的项目
if embed_frameworks_group
	embed_frameworks_group.files.each do |e|
		puts e.display_name
		if e.display_name.end_with?("Test3.framework")
			e.settings = Hash.new
			e.settings["ATTRIBUTES"] = ["CodeSignOnCopy", "RemoveHeadersOnCopy"]
		end
	end
end

project.save

