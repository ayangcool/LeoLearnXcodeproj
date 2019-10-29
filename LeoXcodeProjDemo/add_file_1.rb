#!/usr/bin/ruby -w
#created by leo

# 添加 Person.h Person.m 到项目中  对应的删除脚本为：remove_file_1.rb

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

# 执行shell命令，把 Person.h Person.m 复制到 LeoXcodeProjDemo 文件夹里
system 'cp ../testFile/PersonFile/Person.h ./LeoXcodeProjDemo/Person.h'
system 'cp ../testFile/PersonFile/Person.m ./LeoXcodeProjDemo/Person.m'

# 找到要添加的文件夹（此文件夹已存在且添加到项目中）
preson_file = project.main_group.find_subpath(File.join('LeoXcodeProjDemo'), false)

# 添加文件  .m到Compile Sources  .h只是索引
file_ref_mark = false
file_ref_list = target.source_build_phase.files_references

file_ref_list.each do |file_ref_temp| 
	puts file_ref_temp.to_s
	if file_ref_temp.path.to_s.end_with?("Person.m") then
		file_ref_mark = true
	end
end

file_h = "Person.h"
if !file_ref_mark 
    file_ref = preson_file.new_reference(file_h)
else
    puts "#{file_h} 文件引用已存在"
end

file_m = "Person.m"
if !file_ref_mark 
    file_ref = preson_file.new_reference(file_m)
    target.source_build_phase.add_file_reference(file_ref)
    # 也可以使用这个
    # target.add_file_references([file_ref])
else
    puts file_m + " 文件引用已存在"
end

project.save

