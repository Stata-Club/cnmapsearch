{smcl}
{* 25Aug2017}{...}
{hi:help cnmapsearch}
{hline}

{title:Title}

{phang}
{bf:cnmapsearch} {hline 2} This Stata module helps to extract the specified information by keyword in a certain geographic range.


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:cnmapsearch}{cmd:,} baidukey(string) {addr_lat(varname) addr_lng(varname) | addr(varname) | singleaddr(string) | singlecoord(string)} [{it:options}]

Extracts the information that is searched by keyword in a certain circular range.


{marker description}{...}
{title:Description}

{pstd}
Baidu Map API is widely used in China.
{cmd:cnmapsearch} use Baidu Map API to extract the specified information by keyword around the specified location. 
The content of keyword and the size of range are specified by users.
Before using this command,a Baidu secret key from Baidu Map API is needed. 
A typical Baidu secret key is an alphanumeric string. 
The option baidukey(string) is actually not optional. 
If you have a Baidu key, which is, say CH8eakl6UTlEb1OakeWYvofh, the baidukey option must be specified as baidukey(CH8eakl6UTlEb1OakeWYvofh). 
You can get a secret key from Baidu Map open platform (http://lbsyun.baidu.com). 
The process normally will take 3-5 days after you submit your application online.
There are some information can be extracted when users using {cmd:cnmapsearch}.
(1) The name of the place in the searching range.
(2) The address and Latitude & Longitude of the place.
(3) The telephone number of the place if it has.
(4) If this place is a hotel or a restaurant,command can provide the score of service quality.{p_end}

{pstd}
{cmd:cnmapsearch} require Stata version 14 or higher. {p_end}

{marker options}{...}
{title:Options for cnmapsearch}

{dlgtab:Credentials(required)}

{phang}
{opt baidukey(string)} is required before using this command. 
You can get a secret key from Baidumap open platform(http://lbsyun.baidu.com). 
The process normally will take 3-5 days after you submit your application online. {p_end}

{phang}
{opt addr(varname)} is required when users using this command.
This option determines the center of searching circle and command searches the revelent information users specified within this circle.
There are other three options can be used and users can only choose one of them.
{p_end}

{phang}
{opt addr_lat(varname)} & {opt addr_lng(varname)} specify the longitude and latitude of the address.  
These cannot be used with other options of address.{p_end}

{phang}
{opt singleaddr(string)} specify a single address.
For example,singleaddr("湖北省武汉市洪山区中南财经政法大学").
These cannot be used with other options of address.{p_end}

{phang}
{opt singlecoord(string)} specify the longitude and latitude of a single address.
For example,singlecoord("30.506959132159595,114.38494520005379").
These cannot be used with other options of address.{p_end}

{dlgtab:Search options}

{phang}
{opt number(string)} determines that how many objects will be extract,the range of {opt number} is 1-20.
The default is 10.{p_end}

{phang} 
{opt radius(string)} can specify the radius of circle that is used in searching revelent objects.{p_end}

{phang} 
{opt filter(string)} can adjust the preference of searching so that users can extract more accurate information.
The syntax of this option is {opt filter(category-preference)}. 
There are three kinds of {opt category}:cater,hotal and life. 
Users can input different {opt preference} in different {opt category}.
The option of {opt category} narrow the range of searching so that it can improve the accuracy of searching.{p_end}
{phang}
{p_end}
{phang}
When the {opt category} is cater,there are five types of {opt preference} can be selected:{p_end}
{pmore}
{opt distance} :sorting by distance, from close to distant.{p_end}
{pmore}
{opt price} :sorting by price, from lowest to highest.{p_end}
{pmore}
{opt overall_rating} :sorting by the score that customers give from Internet.{p_end}
{pmore}
{opt taste_rating} :sorting by the score that taste of food.{p_end}
{pmore}
{opt service_rating} :sorting by the quality of service.{p_end}
{phang}
When the {opt category} is life,there are four types of {opt preference} can be selected:{p_end}
{pmore}
{opt distance} 、 {opt price} and {opt overall_rating} had been listed before.{p_end}
{pmore}
{opt comment_num} is equal to {opt service_rating}.{p_end}
{phang}
When the {opt category} is hotel,there are five types of {opt preference} can be selected:{p_end}
{pmore}
{opt distance} and {opt price}  had been listed before.{p_end}
{pmore}
{opt total_score} is equal to {opt overall_rating}.{p_end}
{pmore}
{opt level} sorting by the level of hotel.{p_end}
{pmore}
{opt health_score} sorting by the quality of hygienic condition.{p_end}

{dlgtab:Respondent preference}

{phang}
{opt seeradius:} If users want to extract the radius of searching automatically, option {opt seeradius} helps.
The dimension of this option is meter and the default is 2000.{p_end}

{phang}
{opt seefilter:} If users want to extract the filter used in this searching automatically, option {opt seefilter} helps.
The default is not to show this information.{p_end}

{marker example}{...}
{title:Example}

{pstd}
Input the address

{phang}
{stata `"clear"'}
{p_end}
{phang}
{stata `"input str100 address"'}
{p_end}
{phang}
{stata `""湖北省武汉市洪山区中南财经政法大学" "'}
{p_end}
{phang}
{stata `""湖北省武汉市武昌区政府" "'}
{p_end}
{phang}
{stata `""陕西省西安市雁塔区大雁塔" "'}
{p_end}
{phang}
{stata `"end"'} 
{p_end}

{pstd}
Extracts the information of object that is relevent to food within a circular range. 

{phang}
{stata `"cnmapsearch, baidukey(your secret key)  addr(address) keyword("食") filter(cater-)"'}
{p_end}
{phang}
{stata `"list  item1 longitude latitude"'}
{p_end}

{pstd}
Input the longitude and latitude of the address

{phang}
{stata `"clear"'}
{p_end}
{phang}
{stata `"input double lat double lng"'}
{p_end}
{phang}
{stata `"114.38494 30.50695"'}
{p_end}
{phang}
{stata `"30.54414 114.36921"'}
{p_end}
{phang}
{stata `"30.43655 114.42726"'}
{p_end}
{phang}
{stata `"end"'} 
{p_end}

{pstd}
Change the radius of searching range and extracts the information of object.


{phang}
{stata `"cnmapsearch, baidukey(your secret key)  addr_lat(lat) addr_lng(lng) keyword("酒") radius("4000") seeradius"'}
{p_end}
{phang}
{stata `"list  "'}
{p_end}

{pstd}
Extracts the information of object when the type of address is {opt singleaddr}.

{phang}
{stata `"clear"'}
{p_end}
{phang}
{stata `"cnmapsearch,baidukey(your secret key) singleaddr("湖北省武汉市洪山区中南财经政法大学") keyword("食")  filter(cater-price) "'}
{p_end}
{phang}
{stata `"list"'}
{p_end}


{pstd}
Extracts the information of object when the type of address is {opt singlecoord}.

{phang}
{stata `"clear"'}
{p_end}
{phang}
{stata `"cnmapsearch,baidukey("your secret key") singlecoord("30.506959,114.384945") keyword("医院") radius("9000") filter(cater) number("12")"'}
{p_end}
{phang}
{stata `"list  "'}
{p_end}





{title:Author}

{pstd}Chuntao LI{p_end}
{pstd}School of Finance, Zhongnan University of Economics and Law{p_end}
{pstd}Wuhan, China{p_end}
{pstd}chtl@zuel.edu.cn{p_end}

{pstd}Yuan Xue{p_end}
{pstd}School of Finance, Zhongnan University of Economics and Law{p_end}
{pstd}Wuhan, China{p_end}
{pstd}xueyuan19920310@163.com{p_end}

{pstd}Xueren Zhang{p_end}
{pstd}School of Finance, Zhongnan University of Economics and Law{p_end}
{pstd}Wuhan, China{p_end}
{pstd}zhijunzhang_hi@163.com{p_end}