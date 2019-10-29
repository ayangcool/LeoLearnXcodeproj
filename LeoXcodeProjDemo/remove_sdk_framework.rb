#!/usr/bin/ruby -w
#created by leo

# 移除 Test3.framework 对应的添加脚本为：add_sdk_framework.rb

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

# 找到要操作的文件夹（此文件夹已存在且添加到项目中）
sdk_framework_file = project.main_group.find_subpath(File.join('LeoXcodeProjDemo', 'sdk_framework'), false)

# 找到 Test3.framework 索引
sdk_framework_ref = sdk_framework_file.find_file_by_path("Test3.framework")
# 移除索引
sdk_framework_file.remove_reference(sdk_framework_ref)
# 从 Link Binary With Libraries 中移除
target.frameworks_build_phases.remove_file_reference(sdk_framework_ref)

# 如果framework是动态库，且添加到了 Embed Frameworks 中，还需要把它从 Embed Frameworks 中移除：
embed_frameworks_group = nil
target.copy_files_build_phases.each do |e|
	puts e.to_s
	if e.display_name.end_with?("Embed Frameworks")
		embed_frameworks_group = e
		break
	end
end

# 如果找到 Embed Frameworks ，移除索引
if embed_frameworks_group
	embed_frameworks_group.remove_file_reference(sdk_framework_ref)
end

# 移除 sdk_framework 文件夹
father_file = project.main_group.find_subpath(File.join('LeoXcodeProjDemo'), false)
father_file.remove_reference(sdk_framework_file)

# 执行shell命令移除文件
system 'rm -rf ./LeoXcodeProjDemo/sdk_framework'

project.save

