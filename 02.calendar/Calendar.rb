#!/usr/bin/env ruby

require 'optparse'
require 'date'

WEEK_NUM = 7
CALENDAR_ROW = 6

def create_cal(year, month)
  first_day = Date.new(year, month, 1)
  last_day = Date.new(year, month, -1)
  day_num = (last_day - first_day).to_i
  space_count = (first_day.wday + 1).to_i
  days = Array.new(day_num + space_count)
  days.each_with_index do |value, day|
    next if space_count > (day + 1)
    days[day] = (day + 2) - space_count
  end
  days
end

def show_cal(days, year, month, today)
  first_day = Date.new(year, month, 1)
  week_count = 0
  entire_week = "Su Mo Tu We Th Fr Sa"
  header = first_day.strftime('%B') + "\s" + first_day.strftime("%Y")

  puts header.center(entire_week.length)
  puts entire_week
  days.each_with_index do |day, index|
    if (day.nil?)
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
  if (week_count < CALENDAR_ROW-1)
    print "\n"
  end
  print "\n"
end

today = Date.today
params = ARGV.getopts("m:", "y:")
year = params["y"]&.to_i || today.year
month = params["m"]&.to_i || today.month
days = create_cal(year, month)
show_cal(days, year, month, today)
