#!/usr/bin/ruby -w
#created by leo

# 添加 libTest1.a Test1.h 静态库 对应的移除脚本：remove_sdk_a.rb

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

# 执行shell命令复制sdk_a文件夹到 LeoXcodeProjDemo文件夹内
system 'cp -rf ../testFile/sdk_a ./LeoXcodeProjDemo/sdk_a'

# 找到要操作的文件夹（此文件夹已存在且添加到项目中）
sdk_a_file = project.main_group.find_subpath(File.join('LeoXcodeProjDemo', 'sdk_a'), true)
sdk_a_file.set_source_tree('<group>')
sdk_a_file.set_path('sdk_a')

# 添加 libTest1.a 索引到 sdk_a 目录
file_ref = sdk_a_file.new_reference("libTest1.a")
# add to target
target.frameworks_build_phases.add_file_reference(file_ref)

# 添加 Test1.h 索引到 sdk_a 目录
sdk_a_file.new_reference("Test1.h")

project.save

