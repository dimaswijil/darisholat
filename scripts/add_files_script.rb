require 'xcodeproj'

project_path = 'DariSholat.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.first

def add_file_to_group(project, target, group_path, file_name)
  group = project.main_group.find_subpath(group_path, true)
  
  # Check if file already exists in the group
  existing_ref = group.files.find { |f| f.path == file_name || f.name == file_name }
  unless existing_ref
    file_ref = group.new_reference(file_name)
    target.source_build_phase.add_file_reference(file_ref)
    puts "Added #{file_name} to #{group_path}"
  else
    puts "#{file_name} already in #{group_path}"
  end
end

add_file_to_group(project, target, 'DariSholat/Utils', 'PrayerLog.swift')
add_file_to_group(project, target, 'DariSholat/Views', 'HabitsView.swift')
add_file_to_group(project, target, 'DariSholat/Views', 'PrayerAlertOverlay.swift')

project.save
puts "Project saved!"
