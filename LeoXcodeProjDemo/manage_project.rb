#!/usr/bin/ruby -w
#created by leo

require 'xcodeproj'

module ManageProject
	# 移除framework
	def ManageProject.remove_framework(name, group, target ,isDeleteGroup)
		puts "移除framework：" + name
		framework_ref = group.find_file_by_path(name)
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
	def ManageProject.remove_point_m(name, group, target)
		puts "移除.m：" + name
		point_m_ref = group.find_file_by_path(name)
		if point_m_ref
			target.source_build_phase.remove_file_reference(point_m_ref)
			group.remove_reference(point_m_ref)
		end
	end

	# 移除.h文件
	def ManageProject.remove_point_h(name, group, target)
		puts "移除.h：" + name
		point_h_ref = group.find_file_by_path(name)
		if point_h_ref
			group.remove_reference(point_h_ref)
		end
	end

	# 移除资源文件（图片，bundle，xib，storyboard等）
	def ManageProject.remove_resource(name, group, target)
		puts "移除资源文件：" + name
		file_ref = group.find_file_by_path(name)
		group.remove_reference(file_ref)
		target.resources_build_phase.remove_file_reference(file_ref)
	end

	# 移除 文件夹
	def ManageProject.remove_group(group)
		puts "移除文件夹：" + group.display_name
		group.set_source_tree("SOURCE_ROOT")
		group.clear
		group.remove_from_project
	end

	def ManageProject.remove_embed_framework(name, group, target)
		embed_frameworks_group = nil
		target.copy_files_build_phases.each do |e|
			if e.display_name.end_with?("Embed Frameworks")
				embed_frameworks_group = e
				break
			end
		end

		# 添加的项目
		if embed_frameworks_group
			framework_ref = group.find_file_by_path(name)
			if framework_ref
				embed_frameworks_group.remove_file_reference(framework_ref)
			end
		end
	end

	# 递归移除文件夹下所有文件
	def ManageProject.recursive_remove_all(source_group, target)
		puts "存在文件夹：" + source_group.display_name
		source_group_files = Array.new
		# 暂存需要移除的framework，因为xcodeproj这里有个bug，
		# 直接遍历source_group.files时remove_file_reference只会调用一次就break了
		source_group.files.each do |children|
			source_group_files << children
		end

		source_group_files.each do |children|
			if children.display_name.end_with?("framework")
				remove_framework(children.display_name, source_group, target, true)
			elsif children.display_name.end_with?(".h")
				remove_point_h(children.display_name, source_group, target)
			elsif children.display_name.end_with?(".m")
				remove_point_m(children.display_name, source_group, target)
			elsif children.display_name.end_with?("bundle")
				remove_resource(children.display_name, source_group, target)
			end
		end

		source_group.groups.each do |sub_group|
			recursive_remove_all(sub_group, target)
		end
		remove_group(source_group)
	end

	# 添加framework
	def ManageProject.add_framework(name, group, target)
		puts "添加framework：" + name
		framework_ref = group.new_reference(name)
		target.frameworks_build_phases.add_file_reference(framework_ref)
	end

	# 添加.m文件
	def ManageProject.add_point_m(name, group, target)
		puts "添加.m：" + name
		point_m_ref = group.new_reference(name)
		target.source_build_phase.add_file_reference(point_m_ref)
	end

	# 添加.h文件
	def ManageProject.add_point_h(name, group, target)
		puts "添加.h：" + name
		point_h_ref = group.new_reference(name)
	end

	# 添加资源文件（图片，bundle，xib，storyboard等）
	def ManageProject.add_resource(name, group, target)
		puts "添加资源文件：" + name
		file_ref = group.new_reference(name)
		target.resources_build_phase.add_file_reference(file_ref)
	end

	# 添加 文件夹
	def ManageProject.add_group(name, project)
		puts "添加文件夹：" + name
		before_path = File.dirname(name)
		after_path = File.basename(name)
		group = project.main_group.find_subpath(File.join(before_path, after_path), true)
		group.set_source_tree('<group>')
		group.set_path(after_path)
		return group
	end

	def ManageProject.add_embed_framework(name, group, target)
		embed_frameworks_group = nil
		target.copy_files_build_phases.each do |e|
			if e.display_name.end_with?("Embed Frameworks")
				embed_frameworks_group = e
				break
			end
		end

		# 添加的项目
		if embed_frameworks_group
			framework_ref = group.find_file_by_path(name)
			if !framework_ref
				framework_ref = group.new_reference(name)
			end
			if framework_ref
				# 如果找到 Embed Frameworks ，添加索引
				embed_frameworks_group.add_file_reference(framework_ref)
				# 如果找到 Embed Frameworks ，添加引用
				embed_frameworks_group.files.each do |e|
					if e.display_name.end_with?(name)
						e.settings = Hash.new
						e.settings["ATTRIBUTES"] = ["CodeSignOnCopy", "RemoveHeadersOnCopy"]
					end
				end
			end
		end
	end

	# 递归添加文件夹下所有文件
	def ManageProject.recursive_add_all(source_folder, target, project)
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

	# 检查是否存在重复预编译宏
	def ManageProject.check_repeat_element(gcc_preprocess, repeat_ele)
		if gcc_preprocess
			gcc_preprocess.each do |gcc|
				if gcc.start_with?(repeat_ele)
					return true
				end
			end
		end
		return false
	end

	# 删除重复预编译宏
	def ManageProject.delete_repeat_element(gcc_preprocess, repeat_ele)
		if gcc_preprocess
			gcc_preprocess.each do |gcc|
				if gcc.start_with?(repeat_ele)
					gcc_preprocess.delete(gcc)
				end
			end
		end
	end
end

