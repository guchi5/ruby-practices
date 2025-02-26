#! /usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'

MAX_COL_SIZE = 3
COL_SIZE_FOR_DETAIL = 7

FILE_MODE_TABLE = {
  'file_type' => {
    1 => 'p',
    2 => 'c',
    4 => 'd',
    6 => 'b',
    10 => '-',
    12 => 'l',
    14 => 's'
  },
  'special_permission' => {
    sticky: 't',
    sgid: 's',
    suid: 's'
  },
  'permission' => {
    0 => '---',
    1 => '--x',
    2 => '-w-',
    3 => '-wx',
    4 => 'r--',
    5 => 'r-x',
    6 => 'rw-',
    7 => 'rwx'
  }
}.freeze

# 表示用行列を生成
def create_matrix(files, max_col_size)
  matrix = []
  row_size = files.length / max_col_size + 1
  files.each_slice(row_size) do |col|
    valid_col = col.compact
    max_size = valid_col.max_by(&:length).length
    matrix.push({ col: valid_col, size: max_size })
  end
  matrix
end

def create_matrix_for_long_option(files, max_col_size)
  matrix = []
  col_name = files[0].keys.map!(&:to_s)
  files_array = files.map(&:values)
  col_value = files_array.transpose.flatten
  row_size = col_value.length / max_col_size
  col_value.each_slice(row_size).with_index do |(*col), index|
    valid_col = col.compact
    max_size = valid_col.max_by(&:length).length
    matrix.push({ col: valid_col, name: col_name[index], size: max_size })
  end
  matrix
end

# ロングオプション用のファイル表示
def show_detail_files(matrix)
  matrix[0][:col].length.times do |i|
    matrix.each do |value|
      if value[:name] == 'user' || value[:name] == 'group' || value[:name] == 'file'
        print value[:col][i].ljust(value[:size]) if !value[:col][i].nil?
      elsif !value[:col][i].nil?
        print value[:col][i].rjust(value[:size])
      end
      print "\s"
    end
    puts
  end
end

# ファイルを表示
def show_files(matrix)
  matrix[0][:col].length.times do |i|
    matrix.each do |value|
      print value[:col][i].ljust(value[:size]) if !value[:col][i].nil?
      print "\s\s"
    end
    puts
  end
end

# ファイルモードの数値を記号表記に変換する
def convert_file_mode(status, file)
  show_status = FILE_MODE_TABLE['file_type'][status[0..1].to_i].to_s
  show_status += FILE_MODE_TABLE['permission'][status[3].to_i].to_s
  show_status += FILE_MODE_TABLE['permission'][status[4].to_i].to_s
  show_status += FILE_MODE_TABLE['permission'][status[5].to_i].to_s
  absolute_path = "#{File.expand_path(ARGV[0]&.to_s || '.', '.')}/#{file}"
  update_special_permission(show_status, absolute_path)
end

def update_special_permission(show_status, absolute_path)
  if File.setuid?(absolute_path)
    special_permission = FILE_MODE_TABLE['special_permission'][:suid]
    special_permission = special_permission.upcase if show_status[3] != 'x'
    show_status[3] = special_permission
  end
  if File.setgid?(absolute_path)
    special_permission = FILE_MODE_TABLE['special_permission'][:sgid]
    special_permission = special_permission.upcase if show_status[6] != 'x'
    show_status[6] = special_permission
  end
  if File.sticky?(absolute_path)
    special_permission = FILE_MODE_TABLE['special_permission'][:sticky]
    special_permission = special_permission.upcase if show_status[9] != 'x'
    show_status[9] = special_permission
  end
  show_status
end

opt = OptionParser.new

all_option = false
reverse_option = false
long_option = false

opt.on('-a') { |v| all_option = v }
opt.on('-r') { |v| reverse_option = v }
opt.on('-l') { |v| long_option = v }
opt.parse!(ARGV)

path = ARGV[0]&.to_s || '.'
files = Dir.entries(path).sort
files = files.reject { |file| file.start_with?('.') } if !all_option
files.reverse! if reverse_option
return if files.empty?

total_file_blocks = 0
if long_option
  file_attributes = files.map do |file|
    absolute_path = "#{File.expand_path(path, '.')}/#{file}"
    total_file_blocks += File.stat(absolute_path).blocks / 2
    status = format('%06d', File.stat(absolute_path).mode.to_s(8))
    show_status = convert_file_mode(status, file)
    hard_link_num = File.stat(absolute_path).nlink.to_s
    user_name = Etc.getpwuid(File.stat(absolute_path).uid).name
    group_name = Etc.getgrgid(File.stat(absolute_path).gid).name
    size = File.stat(absolute_path).size.to_s
    date = File.stat(absolute_path).mtime.strftime('%b %e %R')
    file += " -> #{File.readlink(absolute_path)}" if File.symlink?(absolute_path)
    { mode: show_status, link: hard_link_num, user: user_name, group: group_name, size:, date:, file: }
  end
  puts "total #{total_file_blocks}"
  show_detail_files(create_matrix_for_long_option(file_attributes, COL_SIZE_FOR_DETAIL))
  exit
end
matrix = create_matrix(files, MAX_COL_SIZE)
show_files(matrix)
