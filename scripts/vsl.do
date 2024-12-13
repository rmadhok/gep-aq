********************************************************************************																			
* PROJECT: 	GEP					
* PURPOSE:  Calculate VSL
* AUTHOR:   Raahil Madhok 
*							
********************************************************************************
*-------------------------------------------------------------------------------
*SET ENVIRONMENT
*-------------------------------------------------------------------------------
// Settings
clear all
pause on
cap log close
set more off
set maxvar 10000

//Set Directory Paths
*local root "C:/Users/madho011/Dropbox/gep/"
local root "/Users/rmadhok/Dropbox/gep"

*-------------------------------------------------------------------------------
* PREPARE DATA
*-------------------------------------------------------------------------------

* 1. read life expectancy
import delimited "`root'/data/raw/life_expectancy.csv", clear
keep name slug years region
ren years life_expectancy
tempfile temp
save "`temp'"

* 2. read median age
import delimited "`root'/data/raw/median_age.csv", clear
keep slug years
ren years median_age
merge 1:1 slug using "`temp'", keep(3) nogen
save "`temp'", replace

* 3. read real gdp per capita
import delimited "`root'/data/raw/real_gdp_pc.csv", clear
keep slug value date_of_information
ren date_of_information gdp_base_year
g real_gdp_pc = subinstr(value, "$", "", .)
replace real_gdp_pc = subinstr(real_gdp_pc, ",", "", .)
destring real_gdp_pc, replace
merge 1:1 slug using "`temp'", keep(3) nogen

*-------------------------------------------------------------------------------
* CALCULATE VSL
*-------------------------------------------------------------------------------

**# USA components

* USA VSL
g vsl_usa = 9.9*1000000

* life years lost
g temp = life_expectancy - median_age if slug == "united-states"
egen lll_usa = mean(temp)
drop temp

* USA gdp
g temp = real_gdp_pc if slug == "united-states"
egen gdp_usa = mean(temp)
drop temp

* Other components
g vsl_lll_usa = vsl_usa / lll_usa // vsl-per-lifeyearlost
g vsl_lll_gdp_usa = vsl_lll_usa / gdp_usa // vsl-per-lll to GDP ratio

**# Calculate VSL
g lll = life_expectancy - median_age // life years lost
g vsl = vsl_lll_gdp_usa * real_gdp_pc * lll

* Save
keep name region vsl 
export delimited "`root'/data/clean/vsl.csv", replace

