(*  Tyrel Hiebert *)
(*  V00898825     *)
(*  Assignment #1 *)

type DATE = (int * int * int)
exception InvalidParameter

(* 1 *)
fun is_older(d1: DATE, d2: DATE): bool =
    if (#1 d1) < (#1 d2)
    then true
    else
        if (#1 d1) > (#1 d2)
        then false
        else
            if (#2 d1) < (#2 d2)
            then true
            else
                if (#2 d1) > (#2 d2)
                then false
                else
                    if (#3 d1) < (#3 d2)
                    then true
                    else false

(* 2 *)
fun number_in_month(dates: DATE list, month: int): int =
    if null dates 
    then 0 
    else
        if #2(hd dates) = month
        then 1 + number_in_month(tl(dates), month)
        else 0 + number_in_month(tl(dates), month)

(* 3 *)
fun number_in_months(dates: DATE list, months: int list): int =
    if null dates
    then 0
    else
        if null months
        then 0
        else
            number_in_month(dates, hd months) + number_in_months(dates, tl months)

(* 4 *)
fun dates_in_month(dates: DATE list, month: int): DATE list =
    if null dates
    then []
    else
        if #2(hd dates) = month
        then hd dates :: dates_in_month(tl dates, month)
        else dates_in_month(tl dates, month)

(* 5 *)
fun dates_in_months(dates: DATE list, months: int list): DATE list =
    if null months
    then []
    else
        dates_in_month(dates, (hd months)) @ dates_in_months(dates, (tl months))

(* 6 *)
fun get_nth(strings: string list, n: int): string =
    if n <= 0 orelse n > length strings
    then raise InvalidParameter
    else if n = 1
    then hd strings
    else get_nth((tl strings), (n - 1))

(* 7 *)
fun date_to_string(date: DATE): string =
    (* Style:  January 20, 2013 *)
    let
        val months = [
            "January",
            "February",
            "March",
            "April",
            "May",
            "June",
            "July",
            "August",
            "September",
            "October",
            "November",
            "December"]
    in
      get_nth(months, #2 date) ^ " " ^ Int.toString(#3 date) ^ ", " ^ Int.toString(#1 date)
    end

(* 8 *)
(*Write a function number_before_reaching_sum that takes an int called sum, which you can
assume is positive, and an int list, which you can assume contains all positive numbers, and
returns an int. You should return an int n such that the first n elements of the list add to less than
sum, but the first n + 1 elements of the list add to sum or more. Assume the entire list sums to more
than the passed in value; it is okay for an exception to occur if this is not the case.*)
fun number_before_reaching_sum(sum: int, values: int list): int =
    if null values
    then 0
    else
        if sum - (hd values) > 0
        then 1 + number_before_reaching_sum(sum - (hd values), (tl values))
        else 0

(* 9 *)
(* Write a function what_month that takes a day of year (i.e., an int between 1 and 365) and returns
what month that day is in (1 for January, 2 for February, etc.). Use a list holding 12 integers and your
answer to the previous problem. *)
fun what_month(day: int): int =
    let
        val days = [31,28,31,30,31,30,31,31,30,31,30,31]
    in
        1 + number_before_reaching_sum(day, days)
    end

(* 10 *)
(* Write a function month_range that takes two days of the year day1 and day2 and returns an int
list [m1,m2,...,mn] where m1 is the month of day1, m2 is the month of day1+1, ..., and mn is
the month of day day2. Note the result will have length day2 − day1 + 1 or length 0 if day1 > day2. *)
fun month_range(day1: int, day2: int): int list = 
    if day1 > day2
    then []
    else what_month(day1) :: month_range((day1 + 1), day2)

(* 11 *)
(* Write a function oldest that takes a list of dates and evaluates to a DATE option. It evaluates to
NONE if the list has no dates and SOME d if the date d is the oldest date in the list. *)
fun oldest(dates: DATE list): DATE option = 
    if null dates
    then NONE
    else
        let
            val max = oldest(tl dates)
        in
            if isSome max
            then 
                if is_older(hd dates, valOf(max))
                then SOME(hd dates)
                else max
            else SOME(hd dates)
        end

(* 12 *)
(* Write a function reasonable_date that takes a date and determines if it describes a real date in
the common era. A “real date” has a positive year (year 0 did not exist), a month between 1 and 12,
and a day appropriate for the month. Solutions should properly handle leap years. Leap years are
years that are either divisible by 400 or divisible by 4 but not divisible by 100. (Do not worry about
days possibly lost in the conversion to the Gregorian calendar in the Late 1500s.) *)
fun reasonable_date(date: DATE): bool =
    if (#1 date) <= 0
    then false
    else
        if ((#2 date) <= 0) orelse ((#2 date) > 12)
        then false
        else
            let
                fun get_nth(ints: int list, n: int): int =
                    if n = 0 orelse n > length ints
                    then raise InvalidParameter
                    else
                        if n = 1
                        then hd ints
                        else get_nth((tl ints), (n - 1))
                fun check_leapyear(year: int): bool =
                    if year mod 400 = 0
                    then true
                    else if year mod 4 = 0 andalso year mod 100 <> 0
                    then true
                    else false
                val days = 
                    if check_leapyear(#1 date)
                    then [31,29,31,30,31,30,31,31,30,31,30,31]
                    else [31,28,31,30,31,30,31,31,30,31,30,31]
                val days_in_month = get_nth(days, (#2 date))
            in
                if (#3 date) <= days_in_month andalso (#3 date) > 0
                then true
                else false
            end