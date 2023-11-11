require 'optparse'
require 'date'

WEEK_NUM = 7
MONTH_NUM = 12

def createCal(year, month)
  week_list = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
  f_cal = Date.new(year, month, 1)
  l_cal = Date.new(year, month, -1)
  date_num = (l_cal-f_cal).to_i
  space_cont = week_list.index(f_cal.strftime("%a"))+1

  date_list = Array.new(date_num+space_cont)
  date_list.each_with_index{|value, date|
    if space_cont > date+1
      date_list[date] = nil
      next
    end
    date_list[date] = (date+2)-(space_cont)
  }
  return [[f_cal.year, f_cal.month], date_list]

end

def showCal(cal_list)
  cal = Date.new(cal_list[0][0], cal_list[0][1], 1)
  date_list = cal_list[1]
  puts("\s\s\s"+cal.strftime('%B')+"\s"+cal.strftime("%Y"))
  puts("Su Mo Tu We Th Fr Sa")
  date_list.each_with_index{|date, index|
    if(date==nil)
      print("\s\s\s")
      next
    end
    if(date<10)
      print("\s")
    end
    printf("%d\s", date)
    if((index+1)%WEEK_NUM == 0)
      print("\n")
    end
  }
  print("\n")
end

params = ARGV.getopts("m:", "y:")
year = params["y"]
month = params["m"]
if(year == nil)
  year = Date.today.year
end
if(month == nil)
  month = Date.today.month
end
year = year.to_i
month = month.to_i
cal = createCal(year, month)
showCal(cal)
