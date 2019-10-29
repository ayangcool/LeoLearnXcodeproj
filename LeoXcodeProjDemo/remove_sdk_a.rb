#!/usr/bin/ruby -w
#created by leo

# 移除 libTest1.a Test1.h 静态库 对应的添加脚本为：add_sdk_a.rb

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
sdk_a_file = project.main_group.find_subpath(File.join('LeoXcodeProjDemo', 'sdk_a'), false)

# 找到索引
file_a_ref = sdk_a_file.find_file_by_path("libTest1.a")
# 移除索引
sdk_a_file.remove_reference(file_a_ref)# 或者使用这个
# file_ref.remove_from_project

# 从 Link Binary With Libraries 中移除
target.frameworks_build_phases.remove_file_reference(file_a_ref)

# 移除 Test1.h
file_h_ref = sdk_a_file.find_file_by_path("Test1.h")
sdk_a_file.remove_reference(file_h_ref)

# 移除 sdk_a 文件夹
father_file = project.main_group.find_subpath(File.join('LeoXcodeProjDemo'), false)
father_file.remove_reference(sdk_a_file)

# 执行shell命令移除文件
system 'rm -rf ./LeoXcodeProjDemo/sdk_a'

project.save

