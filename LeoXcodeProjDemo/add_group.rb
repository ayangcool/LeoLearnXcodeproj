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

# 执行shell命令，把 Person.h Person.m 复制到 LeoXcodeProjDemo 文件夹里
system 'cp -rf ../testFile/add_Folder ./LeoXcodeProjDemo/add_Folder'

# 添加framework
def add_framework(name, group, target)
	puts "添加framework：" + name
	framework_ref = group.new_reference(name)
	target.frameworks_build_phases.add_file_reference(framework_ref)
end

# 添加.m文件
def add_point_m(name, group, target)
	puts "添加.m：" + name
	point_m_ref = group.new_reference(name)
	target.source_build_phase.add_file_reference(point_m_ref)
end

# 添加.h文件
def add_point_h(name, group, target)
	puts "添加.h：" + name
	point_h_ref = group.new_reference(name)
end

# 添加资源文件（图片，bundle，xib，storyboard等）
def add_resource(name, group, target)
	puts "添加资源文件：" + name
	file_ref = group.new_reference(name)
	target.resources_build_phase.add_file_reference(file_ref)
end

# 添加 文件夹
def add_group(name, project)
	puts "添加文件夹：" + name
	before_path = File.dirname(name)
	after_path = File.basename(name)
	group = project.main_group.find_subpath(File.join(before_path, after_path), true)
	group.set_source_tree('<group>')
	group.set_path(after_path)
	return group
end

# 递归添加文件夹下所有文件
def recursive_add_all(source_folder, target, project)
	souce_group = add_group(source_folder, project)
	Dir.entries(source_folder).each do |children|
		if children.end_with?("framework")
			add_framework(children, souce_group, target)
		elsif children.end_with?(".h")
			add_point_h(children, souce_group, target)
		elsif children.end_with?(".m")
			add_point_m(children, souce_group, target)
		elsif children.end_with?(".bundle")
			add_resource(children, souce_group, target)
		elsif children != "." && children != ".."
			# 文件夹需要递归遍历
			children_path = File.join(source_folder, children)
			if (File.extname(children_path) == "") && File.directory?(children_path)
				recursive_add_all(children_path, target, project)
			end
		end
	end
end

source_folder = File.join("LeoXcodeProjDemo", "add_Folder")
if File::exists?(source_folder) 
	recursive_add_all(source_folder, target, project)
else
	puts source_folder + " folder not exist"
end


project.save












