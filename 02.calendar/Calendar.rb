#!/usr/bin/env ruby

require 'optparse'
require 'date'

WEEK_NUM = 7

def create_cal(year, month)
  first_day = Date.new(year, month, 1)
  last_day = Date.new(year, month, -1)
  day_num = (last_day - first_day).to_i
  space_count = (first_day.wday + 1).to_i
  days = Array.new(day_num + space_count)
  days.each_with_index do |value, day|
    if space_count > day+1
      next
    end
    days[day] = (day + 2) - space_count
  end
  return {year: first_day.year, month: first_day.month, days: days}
end

def show_cal(cal, today)
  days = cal[:days]
  year = cal[:year]
  month = cal[:month]
  first_day = Date.new(year, month, 1)
  week_count = 0
  entire_week = "Su Mo Tu We Th Fr Sa"
  header = first_day.strftime('%B') + "\s" + first_day.strftime("%Y")

  puts header.center(entire_week.length)
  puts entire_week
  days.each_with_index do |day, index|
    if (day == nil)
      print "\s\s\s"
      next
    end
    if (day < 10)
      print "\s"
    end
    if (day == today.day && year == today.year && month == today.month)
      print("\e[7m#{day}\e[0m\s")
    else
      printf("%d\s", day)
    end
    if ((index + 1) % WEEK_NUM == 0)
      week_count += 1
      print "\n"
    end
  end
  if (week_count < 5)
    print "\n"
  end
  print "\n"
end

today = Date.today
params = ARGV.getopts("m:", "y:")
year = ((params["y"]==nil) ? today.year : params["y"]).to_i
month = ((params["m"]==nil) ? today.month : params["m"]).to_i
cal = create_cal(year, month)
show_cal(cal, today)
