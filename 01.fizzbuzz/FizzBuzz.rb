for i in 1..20
  if(i%3 == 0)
    print("Fizz")
  end
  if(i%5 == 0)
    print("Buzz")
  end
  if(i%3 != 0 && i%5 != 0)
    print(i)
  end
  print("\n")
end
