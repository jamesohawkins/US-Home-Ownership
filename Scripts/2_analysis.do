// = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
// Do File: 2_analysis.do
// Stata Version: 17
// Author: 		James Hawkins
// Datasets: 	dataset_munged.dta
// Description: This do file runs benchmarks of IPUMS-USA-derived estimates of
//				homeownership rates relative to Census-reported results and 
//				conducts the main analysis as well as outputs the main 
//				visualizations.
// 
// Code is separated into four sections:
//		1 - Benchmark results against Census-reported homeownership rate
//		2 - Main Results
//			2a - 1980 and 2021
//			2b - 1980 vs 2021
// = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

// =============================================================================
// 1b. Benchmark results against Census-reported homeownership rate
// =============================================================================

/*
// Append data
cd "$raw_data"
use "${usa_file1}.dta", clear
**append using "${usa_file2}.dta" // split extract for extended analysis

// Restrict sample
keep if year >= 2005 & year <= 2019
keep if inlist(gq, 1, 2, 5)
keep if relate == 1 // primary unit of analysis for homeownership rates

// Home ownership definition (dummy variable)
gen ownd = 1 if ownershp == 1
replace ownd = 0 if ownershp == 2

// Homeownership rates
collapse (mean) ownd_ipums = ownd [pw = hhwt], by(year)

// Benchmarks
* 2005-2019
/* Source for Census results: Page 11 https://www.census.gov/content/dam/Census/library/publications/2021/acs/acsbr-010.pdf */
gen ownd_census = .
replace ownd_census = .669 if year == 2005
replace ownd_census = .673 if year == 2006
replace ownd_census = .672 if year == 2007
replace ownd_census = .666 if year == 2008
replace ownd_census = .659 if year == 2009
replace ownd_census = .654 if year == 2010
replace ownd_census = .646 if year == 2011
replace ownd_census = .639 if year == 2012
replace ownd_census = .635 if year == 2013
replace ownd_census = .631 if year == 2014
replace ownd_census = .630 if year == 2015
replace ownd_census = .631 if year == 2016
replace ownd_census = .639 if year == 2017
replace ownd_census = .639 if year == 2018
replace ownd_census = .641 if year == 2019

// Ratio of ownership in ipums to ownership in census
gen benchmark = ownd_ipums / ownd_census
replace ownd_ipums = round(ownd_ipums, .001)
*/


// =============================================================================
// 2. Main Results
// =============================================================================

// 2a. 1980 and 2021
// =============================================================================
cd "$derived_data"
use dataset_munged.dta, clear

// Homeownership rate analysis
* restrict to comparison years
**keep if inlist(year, 1980, 2021)
* means in each year
collapse (mean) ownd [pw = hhwt], by(year age)
* reshape estimates
reshape wide ownd, i(age) j(year)

// Format estimates
label drop AGE
lab def age_lbl ///
	90 "90+"
lab val age age_lbl

// Visualization
* location for labels
sum ownd1980 if age == 90
local text1 = r(mean)
sum ownd2021 if age == 90
local text2 = r(mean)
sum ownd1980 if age == 37
local point_37_1980 = r(mean) - .01
sum ownd1980 if age == 77
local point_77_1980 = r(mean) + .01
sum ownd2021 if age == 37
local point_37_2021 = r(mean) + .01
sum ownd2021 if age == 77
local point_77_2021 = r(mean) - .01
local text_37 = r(mean) - .16
local text_77 = `point_77_1980' + .01
* graph notes
linewrap, maxlength(140) name("notes") stack longstring("Since 1980 the 'head of household' or 'householder' is  the individual in whose name the property was owned or rented. If that individual was not present, any household member could be listed as the householder. Homeowners include householders who either owned outright or mortgaged their property. All other householders are renters.")
local notes = `" "Notes: {fontface Lato:`r(notes1)'}""'
local y = r(nlines_notes)
forvalues i = 2/`y' {
	local notes = `"`notes' "{fontface Lato:`r(notes`i')'}""'
}
if `y' < 5 {
	local notes = `"`notes' """'
}
twoway (line ownd1980 age, lpattern(longdash) lcolor("217 117 31")) ///
(line ownd2021 age, lpattern(solid) lcolor("59 126 161")) ///
(pcarrowi `point_37_1980' 37 `point_37_2021' 37, lcolor("238 31 96") lwidth(thin) barbsize(0) msize(1) mcolor("238 31 96")) ///
(pcarrowi `point_77_1980' 77 `point_77_2021' 77, lcolor("0 165 152") lwidth(thin) barbsize(0) msize(1) mcolor("0 165 152")) ///
, ///
title("The age distribution of U.S. homeownership over time", color("0 50 98") size(large) pos(11) justification(left)) ///
subtitle("Homeownership rates in 1980 and 2021", color("59 126 161") size(small) pos(11) justification(left)) ///
xtitle("Age", color(gs6) margin(b-1 t-1)) xscale(lstyle(none)) ///
xlabel(21 "21" 30 "30" 40 "40" 50 "50" 60 "60" 70 "70" 80 "80" 90 "90+", glcolor(gs9%0) labcolor(gs6) tlength(1.25) tlcolor(gs6%30)) xmtick(21(1)90, tlength(.75) tlcolor(gs9%30)) ///
ytitle("") ///
yscale(lstyle(none)) ///
ylabel(.1 "10%" .2 "20%" .3 "30%" .4 "40%" .5 "50%" .6 "60%" .7 "70%" .8 "80%", angle(0) gmax gmin glpattern(solid) glcolor(gs9%15) glwidth(vthin) labcolor("59 126 161") labsize(2.5) tlength(0) tlcolor(gs9%15)) ///
legend(off) ///
note("Source: {fontface Lato:Author's analysis of IPUMS-USA.} Sample: {fontface Lato:U.S. householders age 21 or older.}" `notes', margin(l+1.5) color(gs7) span size(vsmall) position(7)) ///
caption("@jamesohawkins {fontface Lato:on behalf of} youngamericans.berkeley.edu", margin(l+1.5 t-1) color(gs7%50) span size(vsmall) position(7)) ///
text(`text1' 93 "1980", color("217 117 31") size(vsmall) placement(w) justification(right) orient(horizontal)) ///
text(`text2' 93 "2021", color("59 126 161") size(vsmall) placement(w) justification(right) orient(horizontal)) ///
text(`text_37' 37.25 "Decreases in home-" "ownership rates" "since 1980", color("238 31 96") size(vsmall) placement(ne) justification(left) orient(horizontal)) ///
text(`text_77' 77.25 "Increases in" "homeownership" "rates since 1980", color("0 165 152") size(vsmall) placement(ne) justification(left) orient(horizontal)) ///
graphregion(margin(0 0 0 0) fcolor(white) lcolor(white) lwidth(medium) ifcolor(white) ilcolor(white) ilwidth(medium)) ///
plotregion(margin(0 0 0 0) fcolor(white) lcolor(white) lwidth(medium) ifcolor(white) ilcolor(white) ilwidth(medium)) ///
graphregion(margin(r+8))
cd "$output"
graph export main_1980and2021.png, replace height(2500) width(3700)
export delimited main_1980and2021.csv, replace


// 2b. 1980 vs 2021
// =============================================================================
cd "$derived_data"
use dataset_munged.dta, clear

// Homeownership rate analysis
* restrict to comparison years
keep if inlist(year, 1980, 2021)
* set survey analysis specifications
svyset cluster [pw = hhwt], strata(strata)
* regression
svy: reg ownd i.age##ib1980.year
* margins analysis and save estimates
margins, dydx(year) over(age) post vce(unconditional) saving(estimates_main, replace)

// Format estimates
cd "$derived_data"
use estimates_main.dta, clear
rename _margin estimates
rename _ci_lb estimates_lb
rename _ci_ub estimates_ub
rename _by1 age
label drop AGE
lab def age_lbl ///
	90 "90+"
lab val age age_lbl

// Additional formatting for graph
gen asterisk = "*" if _pvalue < .05
gen asterisk_pos = estimates - .0027

// Visualization
* graph notes
linewrap, maxlength(135) name("notes") stack longstring("Visualization shows the change in home ownership rates between 1980 and 2021 (positive percentage point changes show gains for a given age group and negative changes show losses). Vertical error bars show 95% confidence interval. Statistically significant changes in homeownership rates between 1980 and 2021 at a .05 alpha level are indicated with an asterisk within the point estimates.")
local notes = `" "Notes: {fontface Lato:`r(notes1)'}""'
local y = r(nlines_notes)
forvalues i = 2/`y' {
	local notes = `"`notes' "{fontface Lato:`r(notes`i')'}""'
}
if `y' < 5 {
	local notes = `"`notes' """'
}
* graph
twoway (line estimates age, lcolor("0 176 218") lpattern(none) lwidth(thin) lcolor(white)) ///
(rspike estimates_lb estimates_ub age, lcolor("0 176 218") lpattern(solid) lwidth(medthin)) ///
(scatter estimates age, msize(small) msymbol(circle) mcolor("0 176 218")) ///
(pcarrowi .005 18 .145 18, lcolor("0 165 152") lwidth(thin) barbsize(0) msize(1) mcolor("0 165 152")) ///
(pcarrowi -.005 18 -.145 18, lcolor("238 31 96") lwidth(thin) barbsize(0) msize(1) mcolor("238 31 96")) ///
(pcarrowi -.096 53.5 -.096 49, lcolor(gs10) lwidth(thin) barbsize(0) msize(1) mcolor(gs10)) ///
(scatter asterisk_pos age if asterisk == "*", mlabel(asterisk) mlabcolor(white) mlabsize(small) mlabposition(0) msymbol(none)) ///
, ///
title("How much have homeownership rates changed since 1980?", color("0 50 98") size(large) pos(11) justification(left)) ///
subtitle("Percentage point (ppt) changes in homeownership rates between 1980 and 2021", color("59 126 161") size(small) pos(11) justification(left)) ///
yline(0, lcolor("70 87 94") lpattern(dash)) ///
xtitle("Age", color(gs6) margin(b-1 t-1)) xscale(lstyle(none)) ///
xlabel(21 "21" 30 "30" 40 "40" 50 "50" 60 "60" 70 "70" 80 "80" 90 "90+", glcolor(gs9%0) labcolor(gs6) tlength(1.25) tlcolor(gs6%30)) xmtick(21(1)90, tlength(.75) tlcolor(gs9%30)) ///
ytitle("") ///
yscale(lstyle(none)) ///
ylabel(-.15 "-15ppt" -.1 "-10ppt" -.05 "-5ppt" 0 "No change" .05 "+5ppt" .1 "+10ppt" .15 "+15ppt", angle(0) gmax gmin glpattern(solid) glcolor(gs9%15) glwidth(vthin) labcolor("59 126 161") labsize(2.5) tlength(0) tlcolor(gs9%15)) ///
legend(off) ///
note("Source: {fontface Lato:Author's analysis of IPUMS-USA.} Sample: {fontface Lato:U.S. householders age 21 or older.}" `notes', margin(l+1.5) color(gs7) span size(vsmall) position(7)) ///
caption("@jamesohawkins {fontface Lato:on behalf of} youngamericans.berkeley.edu", margin(l+1.5 t-1) color(gs7%50) span size(vsmall) position(7)) ///
text(.008 19.15 "Increases in homeownership" "rates since 1980", color("0 165 152") size(vsmall) placement(n) justification(center) orient(vertical)) ///
text(-.008 19.15 "Decreases in homeownership" "rates since 1980", color("238 31 96") size(vsmall) placement(s) justification(center) orient(vertical)) ///
text(-.096 54 "{it:Asterisk (*) denotes statistically significant change since 1980}", color(gs10) size(vsmall) placement(e) justification(left) orient(horizontal)) ///
graphregion(margin(0 0 0 0) fcolor(white) lcolor(white) lwidth(medium) ifcolor(white) ilcolor(white) ilwidth(medium)) ///
plotregion(margin(0 0 0 0) fcolor(white) lcolor(white) lwidth(medium) ifcolor(white) ilcolor(white) ilwidth(medium)) ///
graphregion(margin(r+3))
cd "$output"
graph export main_1980vs2021.png, replace height(2500) width(3700)

keep estimates* age
export delimited main_1980vs2021.csv, replace