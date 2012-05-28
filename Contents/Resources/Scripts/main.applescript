property name : "SortEngine"
property version : "2.1.1"
property XList : module

-- compmarator scripts
script BaseComparator
	on do(a_first, a_second)
		if (a_first > a_second) then
			(*
			log ("first " & a_first)
			log ("second " & a_second)
			log "large"
			*)
			return 1
		else if (a_first < a_second) then
			return -1
		else
			return 0
		end if
	end do
end script

(*!@glossary
XList || help:openbook='XList Help'
*)

(*!@title SortEngine Reference
* Version : 2.1.1
* Author : Tetsuro KURITA ((<tkurita@mac.com>))
*)

(*!@group Constructor Methods *)

(*!@abstruct
<!-- begin locale ja -->
デフォルトの設定の instance を生成します。
<!-- begin locale en -->
Make a new instance of default settings.
<!-- end locale -->
@result script object :
<!-- begin locale ja -->SortEngine の 新しい instance
<!-- begin locale en -->A new instance of SortEngine<!-- end locale -->
*)
on make
	script SortEngine
		property _comparator : my _comparator
		property _sort_direction : my _sort_direction
		property _sort_handler : my _sort_handler
	end script
	
	return SortEngine
end make

(*!@abstruct
<!-- begin locale ja -->
record を引数に与えることにより、オプションを設定して、新しい instance を生成します。
<!-- begin locale en -->
Make a new instance with passing a record which describes options.
<!-- end locale -->
@description
<!-- begin locale ja -->
引数に与えるレコードのラベルは以下の種類があります。
* ascending (boolean) : ソート順序。昇順: true, 降順 :false。省略すると昇順になります。
* sorter (string) : 使用するソートのアルゴリズムを指定します。クイックソート を使用するときは "quick"、バブルソートを使用する "bubble" を与えます。省略すると、クイックソート。
* comparator (script object): AppleScript の比較演算子で扱えない値をソートする時に、大小関係を定義する script object。
<!-- begin locale en -->
The record to pass as an argument can have following labels.
* ascending (boolean) : Set sorting order. For descending order, false must be given. If omitted, sort in ascending order.
* sorter (string) : Sorting algorithm. "quick" indicates the quick sort. "bubble" indicates the bubble sort. The quick sort is used in the default.
* comparator (script object): A script object to define magnitude relation of values which can not deal with comparison operators of AppleScript.
<!-- end locale -->
@param a_record (record):
<!-- begin locale ja -->インスタンスのオプション
<!-- begin locale en -->Options for a new instance
<!-- end locale -->
@result script object :
<!-- begin locale ja -->SortEngine の 新しい instance
<!-- begin locale en -->A new instance of SortEngine<!-- end locale -->
*)
on make_with(a_record)
	set a_sorter to make
	try
		set a_name to a_record's sorter
		if a_name starts with "quick" then
			a_sorter's use_quicksort()
		else if a_name starts with "bubble" then
			a_sorter's use_bubblesort()
		else
			error (a_name & " is unknown sorter specification.") number 930
		end if
	end try
	
	try
		a_sorter's set_comparator(a_record's comparator)
	end try
	
	try
		a_sorter's set_ascending(a_record's ascending)
	end try
	return a_sorter
end make_with

(*!@group Class method *)

(*!@abstruct
<!-- begin locale ja -->
SortEngine に内蔵されている comparator script を取得します。
<!-- begin locale en -->
Obtain default comparator script in embedded in SortEngine.
<!-- end locale -->
@description
<!-- begin locale ja -->
AppleScript の比較演算子で扱える値をソートする時に使います。デフォルトの comparator script です。

カスタムな comparator script を作ると時に、継承すると都合がいいでしょう。
<!-- begin locale en -->
This script object is default comparator script. This is used to sort values which can be deal with AppleScript's comparison operators.

The inheriting this script object is useful to make a custom comparator script.
<!-- end locale -->
@result script object
*)
on base_comparator()
	return BaseComparator
end base_comparator

(*!@group Do Sort *)

(*!@abstruct
<!-- begin locale ja -->
リストをソートします。
<!-- begin locale en -->
Sort a list.
<!-- end locale -->
@param a_list (list) :
<!-- begin locale ja -->ソートするリスト
<!-- begin locale en -->a list to sort
<!-- end locale -->
@result list : 
<!-- begin locale ja -->ソートされたリスト。返り値と引数は同じリストです。
<!-- begin locale en -->A sorted list. The return list is identical to the list passed as an argument.<!-- end locale -->
*)
on sort_list(a_list)
	set a_xlist to XList's make_with(a_list)
	return sort_xlist(a_xlist)'s list_ref()
end sort_list

(*!@abstruct
<!-- begin locale ja -->
((<XList>)) をソートします。
<!-- begin locale en -->
Sort a XList.
<!-- end locale -->
@param a_xlist (XList) :
<!-- begin locale ja -->ソートする ((<XList>)) のインスタンス
<!-- begin locale en -->an instance of ((<XList>)) to sort
<!-- end locale -->
@result list : XList
<!-- begin locale ja -->ソートされた ((<XList>))。返り値と引数は同じ XList のインスタンスです。
<!-- begin locale en -->A sorted ((<XList>)) instance. The return XList is identical to the XList passed as an argument.<!-- end locale -->
*)
on sort_xlist(a_xlist)
	set a_xlist to XList's make_with({a_xlist})
	return my _sort_handler(a_xlist, 1)'s item_at(1)
end sort_xlist

(*!@abstruct
<!-- begin locale ja -->
指定したインデックスのリストを基準にして、２次元リストのそれぞれのリストをソートします。
<!-- begin locale en -->
Sort each list in two dimensional list according to the order of the list of the specified index.
<!-- end locale -->
@param　a_list2d (list of lists) :
<!-- begin locale ja -->ソートするリストのリスト
<!-- begin locale en --> a list of to sort each list in it.
<!-- end locale -->
@param key_index (integer) :
<!-- begin locale ja -->ソート順序を決定するリストのインデックス
<!-- begin locale en -->An index of a list which determine the sorting order.
<!-- end locale -->
@result list of lists :
<!-- begin locale ja -->ソートされた2次元リスト。返り値と引数は同じリストです。
<!-- begin locale en -->A sorted two dimensional list. The returned list is identical to the list passed as an argument.<!-- end locale -->
*)
on sort_table(a_list2d, key_index)
	set a_xlist2d to XList's make_with(a_list2d)
	script XListConverter
		on do(a_ref)
			return XList's make_with(contents of a_ref)
		end do
	end script
	set a_xlist2d to a_xlist2d's map(XListConverter)
	my _sort_handler(a_xlist2d, key_index)
	return a_list2d
end sort_table

(*!@abstruct
<!-- begin locale ja -->
2次元の ((<XList>)) をソートします。指定したインデックスの XList を基準にして、それぞれの XList をソートします。
<!-- begin locale en -->
Sort each ((<XList>)) in two dimensional XList according to the order of the sub XList of the specified index.
<!-- end locale -->
@description
<!-- begin locale ja -->
2次元の XList とは、すべての要素が XList である XList です。
<!-- begin locale en -->
A two dimensional XList means an XList instance of which all elements are XList instances.
<!-- end locale -->
@param　a_list2d (list of lists) :
<!-- begin locale ja -->ソートする ((<XList>)) を要素とした ((<XList>))
<!-- begin locale en --> a XList instance of to sort each XList instance in it.
<!-- end locale -->
@param key_index (integer) :
<!-- begin locale ja -->ソート順序を決定する XLIst のインデックス
<!-- begin locale en -->An index of a XList instance which determine the sorting order.
<!-- end locale -->
@result list of lists :
<!-- begin locale ja -->ソートされた2次元 XList。返り値と引数は同じ XList のインスタンスです。
<!-- begin locale en -->A sorted two deimensional XList instance. The returned XList instance is identical to the XList instance passed as an argument.<!-- end locale -->
*)
on sort_xtable(a_xlist2d, key_index)
	return my _sort_handler(a_xlist2d, key_index)
end sort_xtable

(*!@group Accessor Methods *)

(*!@abstruct
<!-- begin locale ja -->
設定されているソート順序が昇順なら true を返します。
<!-- begin locale en -->
Return true when sorting order of the instance is ascending.
<!-- end locale -->
@result boolean : 
<!-- begin locale ja --> true　: 昇順, false : 降順
<!-- begin locale en -->true : ascending, false : descending <!-- end locale -->
*)
on is_ascending()
	return my _sort_direction is 1
end is_ascending

(*!@abstruct
<!-- begin locale ja -->
ソート順序を設定します。
<!-- begin locale en -->
Set sorting order.
<!-- end locale -->
@param a_flag (boolean) :
<!-- begin locale ja -->true : 昇順, false : 降順
<!-- begin locale en -->true : ascending, false : descending
<!-- end locale -->
@result script object : me
*)
on set_ascending(a_flag)
	if a_flag then
		set my _sort_direction to 1
	else
		set my _sort_direction to -1
	end if
	return me
end set_ascending

on bubblesort_list2d(a_xlist2d, key_index) -- must be placed before use_bubblesort
	--set keylist to XList's make_with(item key_index of a_list2d)
	set keylist to a_xlist2d's item_at(key_index)
	set list_len to keylist's count_items()
	
	if list_len is less than or equal to 1 then
		return a_xlist2d
	end if
	
	--do sort
	repeat
		set sorted_count to 0
		repeat with i from 1 to (list_len - 1)
			set a_first to keylist's item_at(i)
			set a_secont to keylist's item_at(i + 1)
			(*
			copy item i of keylist to a_first
			copy item (i + 1) of keylist to a_second
			*)
			set a_result to do(a_first, a_secont) of my _comparator
			-- 1,firstItem > secondItem
			-- 0, firstItem = secondItem
			-- -1 firstItem < secondItem
			
			if a_result is my _sort_direction then
				exchange_item(i, i + 1, a_xlist2d)
			else
				set sorted_count to sorted_count + 1
			end if
		end repeat
		if sorted_count is (list_len - 1) then exit repeat
	end repeat
	return a_xlist2d
end bubblesort_list2d

(*!@abstruct
<!-- begin locale ja -->
ソートアルゴリズムをクイックソートに設定します。デフォルトです。
<!-- begin locale en -->
Set sorting algorithm to quick sort. This is the default.
<!-- end locale -->
@result script object : me
*)
on use_bubblesort()
	set my _sort_handler to bubblesort_list2d
	return me
end use_bubblesort

on quicksort_list2d(a_xlist2d, key_index) -- must be placed before use_quicksort
	set keylist to a_xlist2d's item_at(key_index)
	return quicksort(1, keylist's count_items(), a_xlist2d, keylist)
end quicksort_list2d

(*!@abstruct
<!-- begin locale ja -->
ソートアルゴリズムをバブルソートに設定します。
<!-- begin locale en -->
Set sorting algorithm to bubble sort.
<!-- end locale -->
@result script object : me
*)
on use_quicksort()
	set my _sort_handler to quicksort_list2d
	return me
end use_quicksort

(*!@abstruct
<!-- begin locale ja -->
設定されている comparator script を取得します。
<!-- begin locale en -->
Obtain current comparator script
<!-- end locale -->
@result script object
*)
on comparator()
	return my _comparator
end comparator

(*!@abstruct
<!-- begin locale ja -->
comparator script を設定します。
<!-- begin locale en -->
Set a custom comparator to the instance.
<!-- end locale -->
@description
<!-- begin locale ja -->
comparator script は以下の仕様を満たしている必要があります。
* 二つの positional parameter を持つ do handler を実装している。
* do handler は次の値を返す。
	* 1 : 第一引数 &gt; 第二引数
	* 0 : 第一引数 = 第二引数
	* -1 : 第一引数 &lt; 第二引数	
<!-- begin locale en -->
A custom comparator script must have following specification.
* do handler which have two positional parameters.
* do handler return following values
	* 1 : first argument &gt; second argument
	* 0 : first argument = second argument
	* -1 : first argument &lt; second argument
<!-- end locale -->
@param a_comparator (script object)
@result script object : me
*)
on set_comparator(a_comparator)
	set my _comparator to a_comparator
	return me
end set_comparator

on exchange_item(i, j, a_xlist2d)
	--log a_list2d
	script exchanger
		on do(a_xlist)
			a_xlist's exchange_items(i, j)
			return true
		end do
	end script
	
	a_xlist2d's each(exchanger)
end exchange_item

on do(a_list2d)
	return sort_list2d(a_list2d)
end do

on quicksort(beg_index, end_index, a_xlist2d, keylist)
	local left_index, right_index, pivot_val
	
	copy beg_index to left_index
	copy end_index to right_index
	--copy item ((beg_index + end_index) div 2) of keylist to pivot_val
	set pivot_val to keylist's item_at((beg_index + end_index) div 2)
	repeat until right_index is less than left_index
		--repeat while (left_index is less than or equal to end_index) and (my _comparator's do(item left_index of keylist, pivot_val) is (-1 * (my _sort_direction)))
		--repeat while (left_index < end_index) and (my _comparator's do(item left_index of keylist, pivot_val) is (-1 * (my _sort_direction)))
		repeat while (my _comparator's do(keylist's item_at(left_index), pivot_val) is (-1 * (my _sort_direction)))
			set left_index to left_index + 1
		end repeat
		
		--repeat while (beg_index is less than or equal to right_index) and (my _comparator's do(item right_index of keylist, pivot_val) is my _sort_direction)
		--repeat while (left_index is less than or equal to right_index) and (my _comparator's do(item right_index of keylist, pivot_val) is my _sort_direction)
		--repeat while (left_index < right_index) and (my _comparator's do(item right_index of keylist, pivot_val) is in {my _sort_direction, 0})
		repeat while (my _comparator's do(keylist's item_at(right_index), pivot_val) is my _sort_direction)
			--log item right_index of keylist
			set right_index to right_index - 1
		end repeat
		
		if left_index is less than right_index then
			if keylist's item_at(right_index) is not keylist's item_at(left_index) then
				exchange_item(left_index, right_index, a_xlist2d)
			end if
			set left_index to left_index + 1
			set right_index to right_index - 1
		else if left_index is right_index then
			set left_index to left_index + 1
			set right_index to right_index - 1
		end if
	end repeat
	
	--Do the two "subdivided" lists 
	if beg_index < right_index then tell me to quicksort(beg_index, right_index, a_xlist2d, keylist)
	if end_index > left_index then tell me to quicksort(left_index, end_index, a_xlist2d, keylist)
	return a_xlist2d
end quicksort


property _comparator : BaseComparator
property _sort_direction : 1
property _sort_handler : quicksort_list2d

on debug()
	boot (module loader) for me
	set a_list2d to {{1, 2, 1, 2}, {1, 1, 2, 2}}
	--set a_list2d to {{"c", "a", "b", "a", "c", "b", "a"}}
	use_bubblesort()
	sort_table(a_list2d, 1)
end debug

on run
	--return debug()
	try
		show helpbook (path to me) with recovering InfoPlist
	on error msg number errno
		display alert (msg & return & errno)
	end try
end run

