require 'xcodeproj'

# 打开项目工程
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

# 找到需要操作的target
targetIndex = 0
project.targets.each_with_index do |target, index|
	if target.name == "LeoXcodeProjDemo"
		targetIndex = index
		puts targetIndex
	end
end
target = project.targets[targetIndex]

# 移除framework
def remove_framework(name, group, target ,isDeleteGroup)
	puts "移除framework：" + name.display_name
	framework_ref = group.find_file_by_path(name.display_name)
	if framework_ref
		# 移除framework引用（Build Phases --> Link Binary With Libraries）
		target.frameworks_build_phases.remove_file_reference(framework_ref)
		if !isDeleteGroup
			# 移除framework索引 如果同时也移除当前framework文件夹时不要调用这个方法，有bug
			framework_ref.remove_from_project
		end
	end
end

# 移除.m文件
def remove_point_m(name, group, target)
	puts "移除.m：" + name.display_name
	point_m_ref = group.find_file_by_path(name.display_name)
	if point_m_ref
		target.source_build_phase.remove_file_reference(point_m_ref)
		group.remove_reference(point_m_ref)
	end
end

# 移除.h文件
def remove_point_h(name, group, target)
	puts "移除.h：" + name.display_name
	point_h_ref = group.find_file_by_path(name.display_name)
	if point_h_ref
		group.remove_reference(point_h_ref)
	end
end

# 移除资源文件（图片，bundle，xib，storyboard等）
def remove_resource(name, group, target)
	puts "移除资源文件：" + name.display_name
	file_ref = group.find_file_by_path(name.display_name)
	group.remove_reference(file_ref)
	target.resources_build_phase.remove_file_reference(file_ref)
end

# 移除 文件夹
def remove_group(group)
	puts "移除文件夹：" + group.display_name
	group.set_source_tree("SOURCE_ROOT")
	group.clear
	group.remove_from_project
end

# 递归移除文件夹下所有文件
def recursive_remove_all(source_group, target)
	puts "存在文件夹：" + source_group.display_name
	source_group_files = Array.new
	# 暂存需要移除的framework，因为xcodeproj这里有个bug，
	# 直接遍历source_group.files时remove_file_reference只会调用一次就break了
	source_group.files.each do |children|
		source_group_files << children
	end

	source_group_files.each do |children|
		if children.display_name.end_with?("framework")
			remove_framework(children, source_group, target, true)
		elsif children.display_name.end_with?(".h")
			remove_point_h(children, source_group, target)
		elsif children.display_name.end_with?(".m")
			remove_point_m(children, source_group, target)
		elsif children.display_name.end_with?("bundle")
			remove_resource(children, source_group, target)
		end
	end

	source_group.groups.each do |sub_group|
		recursive_remove_all(sub_group, target)
	end
	remove_group(source_group)
end

source_group = project.main_group.find_subpath(File.join('LeoXcodeProjDemo', 'add_Folder'), false)

if source_group
	recursive_remove_all(source_group, target)
end

project.save

system 'rm -rf ./LeoXcodeProjDemo/add_Folder'











