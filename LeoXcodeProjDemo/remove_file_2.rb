#!/usr/bin/ruby -w
#created by leo

# 移除 PersonFile Person.h Person.m 对应的添加脚本为：add_file_2.rb

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
preson_file = project.main_group.find_subpath(File.join('LeoXcodeProjDemo', 'PersonFile'), false)

# 移除 .h索引
person_h_ref = preson_file.find_file_by_path("Person.h")
preson_file.remove_reference(person_h_ref)

# 移除 .m索引和Compile Sources引用
person_m_ref = preson_file.find_file_by_path("Person.m")
target.source_build_phase.remove_file_reference(person_m_ref)
preson_file.remove_reference(person_m_ref)

# 移除 PersonFile 文件夹
father_file = project.main_group.find_subpath(File.join('LeoXcodeProjDemo'), false)
father_file.remove_reference(preson_file)

# 删除源文件
system 'rm -r ./LeoXcodeProjDemo/PersonFile'

project.save

