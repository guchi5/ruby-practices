#!/usr/bin/env ruby

require 'optparse'
require 'date'

WEEK_NUM = 7
MONTH_NUM = 12

def create_cal(year, month)
  week = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
  f_cal = Date.new(year, month, 1)
  l_cal = Date.new(year, month, -1)
  day_num = (l_cal - f_cal).to_i
  space_count = week.index(f_cal.strftime("%a"))+1
  sat_count = 0
  day_list = Array.new(day_num + space_count)
  day_list.each_with_index do |value, day|
    if space_count > day+1
      next
    end
    day_list[day] = (day + 2) - space_count
    if (f_cal + (day + 1) - (space_count)).strftime("%a") == week[6]
      sat_count += 1
    end
  end
  return [[f_cal.year, f_cal.month, sat_count], day_list]
end

def show_cal(cal_list)
  cal = Date.new(cal_list[0][0], cal_list[0][1], 1)
  sat_count = cal_list[0][2]
  today = Date.today
  day_list = cal_list[1]
  header = cal.strftime('%B') + "\s" + cal.strftime("%Y")

  for i in 0..(((20 - (header.length)) / 2) - 1)
    print("\s")
  end
  print(header)
  print("\n")
  puts("Su Mo Tu We Th Fr Sa")
  day_list.each_with_index do |day, index|
    if (day==nil)
      print("\s\s\s")
      next
    end
    if (day<10)
      print("\s")
    end
    if (day == today.day && cal_list[0][0] == today.year && cal_list[0][1] == today.month)
      print("\e[7m#{day}\e[0m\s")
    else
      printf("%d\s", day)
    end
    if ((index + 1) % WEEK_NUM == 0)
      print("\n")
    end
  end
  if (sat_count < 5)
    print("\n")
  end
  print("\n")
end

params = ARGV.getopts("m:", "y:")
year = params["y"]
month = params["m"]
if (year == nil)
  year = Date.today.year
end
if (month == nil)
  month = Date.today.month
end
year = year.to_i
month = month.to_i
cal = create_cal(year, month)
show_cal(cal)
