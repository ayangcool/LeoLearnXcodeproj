#!/usr/bin/ruby -w
#created by leo

# 添加 resource_img smile@2x.png 对应的移除脚本：remove_resource.rb

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

# 执行shell命令复制resource_img文件夹到 LeoXcodeProjDemo文件夹内
system 'cp -rf ../testFile/resource_img ./LeoXcodeProjDemo/resource_img'

# 找到要操作的文件夹（此文件夹已存在且添加到项目中）
sdk_a_file = project.main_group.find_subpath(File.join('LeoXcodeProjDemo', 'resource_img'), true)
sdk_a_file.set_source_tree('<group>')
sdk_a_file.set_path('resource_img')

# 添加 smile@2x.png 索引到 resource_img 目录
file_ref = sdk_a_file.new_reference("smile@2x.png")
# add to target
target.resources_build_phase.add_file_reference(file_ref)

project.save

