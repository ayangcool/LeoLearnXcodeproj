#!/usr/bin/ruby -w
#created by leo

require 'xcodeproj'
$LOAD_PATH << '.'
require 'manage_project.rb'

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


ManageProject.add_framework("Test3.framework", sdk_framework_file, target)
# 如果framework是动态库，还需要把它添加到 Embed Frameworks 中：
# 先找到 Embed Frameworks 对应的group（新创建的项目可能没有这一项，需要先手动添加 Embed Frameworks 这个选项）
ManageProject.add_embed_framework("Test3.framework", sdk_framework_file, target)

project.save

