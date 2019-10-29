#!/usr/bin/ruby -w
#created by leo

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

def check_repeat_element(gcc_preprocess, repeat_ele)
	if gcc_preprocess
		gcc_preprocess.each do |gcc|
			if gcc.start_with?(repeat_ele)
				return true
			end
		end
	end
	return false
end

def delete_repeat_element(gcc_preprocess, repeat_ele)
	if gcc_preprocess
		gcc_preprocess.each do |gcc|
			if gcc.start_with?(repeat_ele)
				gcc_preprocess.delete(gcc)
			end
		end
	end
end

build_config_preprocess = ''

# 遍历配置
target.build_configurations.each do |config|
	gcc_preprocess = config.build_settings['GCC_PREPROCESSOR_DEFINITIONS']
		gcc_arr = Array.new()

		if gcc_preprocess.is_a? String
			gcc_arr.push(gcc_preprocess);
		elsif gcc_preprocess.is_a? Array
			gcc_arr = gcc_preprocess
		end

		if check_repeat_element(gcc_arr, 'USE_TENCENT_SDK')
		 	delete_repeat_element(gcc_arr, 'USE_TENCENT_SDK')
		end
		if check_repeat_element(gcc_arr, 'USE_NETEASE_SDK')
		 	delete_repeat_element(gcc_arr, 'USE_NETEASE_SDK')
		end
		if check_repeat_element(gcc_arr, 'USE_SHENGWANG_SDK')
		 	delete_repeat_element(gcc_arr, 'USE_SHENGWANG_SDK')
		end
		gcc_arr.push('USE_TENCENT_SDK=0')
		gcc_arr.push('USE_NETEASE_SDK=1')
		gcc_arr.push('USE_SHENGWANG_SDK=0')

		config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] = gcc_arr
		build_config_preprocess = gcc_arr
end

puts '修改编译配置完成 ' + build_config_preprocess.to_s

project.save


