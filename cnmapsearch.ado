program cnmapsearch
version 14.0
syntax,baidukey(string) [addr(string) addr_lat(string) addr_lng(string) singleaddr(string) singlecoord(string) keyword(string) number(string) radius(string) filter(string) seeradius seefilter seexml]

quietly{

if `"`number'"'==""{
	local number 10
}

if `"`radius'"'==""{
	local radius 2000
}


tempvar baidumap work
gen `baidumap'=""

local lng     longitude
local lat      latitude
if (`"`addr_lat'"'=="" & `"`addr'"'=="" & `"`singlecoord'"'=="" & `"`singleaddr'"'==""){
	di in red "error: You must specify either coordinates or an string address"
	exit
}


if (`"`addr_lat'"'=="" & `"`addr'"'==""){
 	if `number'<7{
 	 	set obs 7
 	}
 	else{
 		set obs `number'
 	}
 	gen objectinfo=""
 	if "`singleaddr'"!=""{
 		replace objectinfo=fileread(`"http://api.map.baidu.com/geocoder/v2/?output=json&ak=`baidukey'&address=`singleaddr'"') in 1
		if index(objectinfo[1],"AK有误请检查再重试") {
			di in red "error: please check your baidukey"
			exit
		}
		replace objectinfo=ustrregexs(1) if ustrregexm(objectinfo[1],`""lng":(.*?),"') in 2
		replace objectinfo=ustrregexs(1) if ustrregexm(objectinfo[1],`""lat":(.*?)\}"') in 3
		replace objectinfo=`"`singleaddr'"' in 1
	}
	else if "`singlecoord'"!=""{
		replace objectinfo=ustrregexs(1) if ustrregexm(`"`singlecoord'"',"(\d*\.\d*)\D(\d*\.\d*)") in 3
		replace objectinfo=ustrregexs(2) if ustrregexm(`"`singlecoord'"',"(\d*\.\d*)\D(\d*\.\d*)") in 2
		replace objectinfo=`"`singlecoord'"' in 1
	}

	if `"`filter'"'==""{
	}
	else{
		replace objectinfo=ustrregexs(1) if ustrregexm(`"`filter'"',"^(.*?)-") in 5
		replace objectinfo=ustrregexs(2) if ustrregexm(`"`filter'"',"^(.*?)-(.*?)$") in 6

		if (`"`=objectinfo[5]'"'!=`"life"')&(`"`=objectinfo[5]'"'!=`"cater"')&(`"`=objectinfo[5]'"'!=`"hotel"'){
 		di  "The filter is error,now the filter is the default"
  		local filter ""
 		}
 		else {
 			if (`"`=objectinfo[6]'"'!=`"price"')&(`"`=objectinfo[6]'"'!=`"total_score"')&(`"`=objectinfo[6]'"'!=`"level"')&(`"`=objectinfo[6]'"'!=`"health_score"')&(`"`=objectinfo[6]'"'!=`"distance"')&(`"`=objectinfo[6]'"'!=`"taste_rating"')&(`"`=objectinfo[6]'"'!=`"overall_rating"')&(`"`=objectinfo[6]'"'!=`"comment_num"'){
				di "The industry_type is right,but the sort_name is wrong"
				replace objectinfo="" in 6
				local filter &filter=industry_type:`=objectinfo[5]'
 			}
 			else {
 				local filter &filter=industry_type:`=objectinfo[5]'|sort_name:`=objectinfo[6]'
			}

		}
	}
	replace objectinfo=fileread(`"http://api.map.baidu.com/place/v2/search?query=`keyword'&page_size=`number'&page_num=0&scope=2&location=`=objectinfo[3]',`=objectinfo[2]'&radius=`radius'`filter'&output=xml&ak=`baidukey'"') in 4
	if index(objectinfo[4],"AK有误请检查再重试") {
		di in red "error: please check your baidukey"
		exit
	}
	replace objectinfo =ustrregexra(objectinfo[4],"\n|\s*","") in 4
	gen name=""
	gen latitude=""
	gen longitude=""
	gen address=""
	gen telephone=""
	gen overall_rating=""
	gen distance=""

	local j 1
	while ustrregexm(objectinfo[4],"<name>"){
		replace objectinfo=ustrregexs(1) if ustrregexm(objectinfo[4],"(.*?)</result>") in 7
		replace name=ustrregexs(1) if ustrregexm(objectinfo[7],"<name>(.*?)<") in `j'
    	replace latitude= ustrregexs(1) if ustrregexm(objectinfo[7],"<lat>(.*?)<") in `j'
    	replace longitude= ustrregexs(1) if ustrregexm(objectinfo[7],"<lng>(.*?)<") in `j'
    	replace address= ustrregexs(1) if ustrregexm(objectinfo[7],"<address>(.*?)<") in `j'
    	replace telephone= ustrregexs(1) if ustrregexm(objectinfo[7],"<telephone>(.*?)<") in `j'
    	replace overall_rating= ustrregexs(1) if ustrregexm(objectinfo[7],"<overall_rating>(.*?)<") in `j'
    	replace distance= ustrregexs(1) if ustrregexm(objectinfo[7],"<distance>(.*?)<")   in `j'  
    	replace objectinfo=ustrregexrf(objectinfo[4],".*?</result>","") in 4
		local j=`j'+1
	}
    replace objectinfo="lat&lng:`=objectinfo[3]',`=objectinfo[2]'" in 2
    replace objectinfo="industry_type: `=objectinfo[5]'" in 3
    replace objectinfo="sort_name:`=objectinfo[6]'" in 4
    replace objectinfo="radius:`radius'" in 5
    replace objectinfo="" in 6
    replace objectinfo="" in 7
    drop if objectinfo==""&address==""
	exit

}


gen `lat'=""
gen `lng'=""
	forvalues i = 1/`=_N' {
		if(`"`addr_lat'"'==""& `"`addr_lng'"'=="" & `"`addr'"'!=""){
			replace `baidumap' = fileread(`"http://api.map.baidu.com/geocoder/v2/?output=json&ak=`baidukey'&address=`=`addr'[`i']'"') in `i'
			replace `lng' = ustrregexs(1) if ustrregexm(`"`=`baidumap'[`i']'"',`""lng":(\d{2,3}\.\d{5}).*?,"')  in `i'
 			replace `lat'  = ustrregexs(1) if ustrregexm(`"`=`baidumap'[`i']'"',`""lat":(\d{2}\.\d{5}).*?\}"')  in `i'
			if index(`baidumap'[`i'],"AK有误请检查再重试") {
				di in red "error: please check your baidukey"
				continue,break
			}
		}	
		else if(`"`addr_lat'"'!=""& `"`addr_lng'"'!="" & `"`addr'"'==""){
			tostring `addr_lng',replace
			tostring `addr_lat',replace
			replace `lng' = `"`=`addr_lng'[`i']'"'   in `i'
 			replace `lat' = `"`=`addr_lat'[`i']'"' in `i'
 			destring `addr_lat',replace
 			destring `addr_lng',replace
		}
	}

	if `"`filter'"'==""{
		gen industry_type=""
		gen sort_name=""
	}
	else{
		if ustrregexm(`"`filter'"',"-"){
			gen industry_type=ustrregexs(1) if ustrregexm(`"`filter'"',"^(.*?)-")
		}
		else{ 	
			gen industry_type=ustrregexs(1) if ustrregexm(`"`filter'"',"^(.*)$")
		}
		gen sort_name=ustrregexs(2) if ustrregexm(`"`filter'"',"^(.*?)-(.*?)$")
		if (`"`=industry_type[1]'"'!="life")&(`"`=industry_type[1]'"'!="cater")&(`"`=industry_type[1]'"'!="hotel"){
 		di  "The filter is wrong,now the filter is the default"
	  	local filter ""
 		}
 		else {
 			if (`"`=sort_name[1]'"'!="price")&(`"`=sort_name[1]'"'!="total_score")&(`"`=sort_name[1]'"'!="level")&(`"`=sort_name[1]'"'!="health_score")&(`"`=sort_name[1]'"'!="distance")&(`"`=sort_name[1]'"'!="taste_rating")&(`"`=sort_name[1]'"'!="overall_rating")&(`"`=sort_name[1]'"'!="comment_num"){
				di  "The industry_type is right,but the sort_name is wrong"
				local filter &filter=industry_type:`=industry_type[1]'
				replace sort_name="error"
 			}
 			else {
 				local filter &filter=industry_type:`=industry_type[1]'|sort_name:`=sort_name[1]'
 			}
		}

	}
	gen radius="`radius'"
	gen xmlcode=""
	forvalues i = 1/`=_N' {
		replace `baidumap' = fileread(`"http://api.map.baidu.com/place/v2/search?query=`keyword'&page_size=`number'&page_num=0&scope=2&location=`=`lat'[`i']',`=`lng'[`i']'&radius=`radius'`filter'&output=xml&ak=`baidukey'"') in `i'			
		replace xmlcode=ustrregexra(`"`=`baidumap'[`i']'"',"\n|\s*","") in `i'
		if index(`baidumap'[`i'],"AK有误请检查再重试") {
			di in red "error: please check your baidukey"
			continue
		}
		if index(`baidumap'[`i'],"<status>2</status>") {
			di in red "error: please check your address in observation[`i']"
			continue
		}
	}
	gen text =ustrregexra(`baidumap',"\n|\s*","")

	local j 1
	forvalues j=1/`number'{
		gen item`j'=""
	}

	forvalues i = 1/`=_N' {
		local j 1
		while ustrregexm(`"`=text[`i']'"',"<name>")&"`j'"!="`number'"{
    		replace item`j' =ustrregexs(1) if ustrregexm(`"`=text[`i']'"',"<name>(.*?)<") in `i'
    		replace item`j'=item`j'+"|lat:"+ustrregexs(1) if ustrregexm(`"`=text[`i']'"',"<lat>(.*?)<") in `i'
    		replace item`j'=item`j'+"|lng"+ustrregexs(1) if ustrregexm(`"`=text[`i']'"',"<lng>(.*?)<") in `i'
    		replace item`j'=item`j'+"|address:"+ustrregexs(1) if ustrregexm(`"`=text[`i']'"',"<address>(.*?)<")	in `i'
    		replace item`j'=item`j'+"|distance:"+ustrregexs(1) if ustrregexm(`"`=text[`i']'"',"<distance>(.*?)<")	in `i'
    		replace item`j'=item`j'+"|"+ustrregexs(1) if ustrregexm(`"`=text[`i']'"',"<overall_rating>(.*?)<")	in `i'
    		replace item`j'=item`j'+"|"+ustrregexs(1) if ustrregexm(`"`=text[`i']'"',"<service_rating>(.*?)<")	in `i'
    		replace item`j'=item`j'+"|"+ustrregexs(1) if ustrregexm(`"`=text[`i']'"',"<environment_rating>(.*?)<")    in `i'
    		replace text=ustrregexrf(`"`=text[`i']'"',".*?</result>","") 	in `i'
			local j=`j'+1
		}
	}
	if "`addr_lat'"!=""{
		drop latitude longitude
	}
	if "`seexml'"!="seexml"{
		drop xmlcode
	}
	if "`seeradius'"==""{
		drop radius
	}
	if "`seefilter'"==""{
		drop industry_type
		drop sort_name
	}
	drop text
}

end
