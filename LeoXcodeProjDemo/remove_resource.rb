#!/usr/bin/ruby -w
#created by leo

# 添加 resource_img smile@2x.png 对应的移除脚本：add_resource.rb

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
resource_img_file = project.main_group.find_subpath(File.join('LeoXcodeProjDemo', 'resource_img'), false)

# 找到图片索引
file_ref = resource_img_file.find_file_by_path("smile@2x.png")
# 移除索引
resource_img_file.remove_reference(file_ref)
# add to target
target.resources_build_phase.remove_file_reference(file_ref)

# 移除 resource_img 文件夹
father_file = project.main_group.find_subpath(File.join('LeoXcodeProjDemo'), false)
father_file.remove_reference(resource_img_file)

# 执行shell命令删除资源
system 'rm -rf ./LeoXcodeProjDemo/resource_img'

project.save

