// = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
// Do File: 1_munging.do
// Stata Version: 17
// Author: 		James Hawkins
// Datasets: 	${usa_file1}.dta and ${usa_file2}.dta. See:
//				0_script-control.do for location input globals for these 
//				files.
// Description: This do file imports the primary ACS extracts and restricts the 
//				sample to our analysis group of interest, namely: householders
//				in the U.S. 21+. I also code for covariates tha
// 
// Code is separated into four sections:
//		1 - Append separate IPUMS extracts
//		2 - Restrict to relevant sample
//		3 - Generate variables for model
//		4 - Restrict to householders
//		5 - Save munged data set
// = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =


// =============================================================================
// 1. Append separate IPUMS extracts
// =============================================================================
/* In this section, I append two separate extracts from IPUMS USA for the 
   American Community Survey. The extracts were separated in two due to size 
   limitations for extract downloads from IPUMS. */

// Append data
local varlist year serial pernum relate gq ownershp age hhwt perwt cluster strata
cd "$raw_data"
use `varlist' using "${usa_file1}.dta", clear
**append using "${usa_file2}.dta", keep(`varlist') // split extract for extended analysis


// =============================================================================
// 2. Restrict to relevant sample
// =============================================================================
/* In this section, I restrict the sample to relevant years, group quarters,
   and respondents who are heads of household, in addition to offering brief
   explanations for the rationale of the sample choices. */

// Analysis period
keep if year >= 1970
	/* It is unclear whether the difference in the 'head of household' is a
	substantial distinction between 1970 and 1980. IPUMS states that "Beginning 
	in 1980 the census questionnaire no longer referred to a "head of 
	household", specifying instead the designation of "person one"--the first 
	person listed on the census form. This reference person could be any 
	household member in whose name the property was owned or rented. If no such 
	person was present, any adult could be selected. Prior to 1970, enumerators 
	were instructed to record the male as the head of household for all married 
	couples, regardless of the couple's designation of a head." For simplicity,
	we restrict analysis to all years from 1980 and later."
	See: https://usa.ipums.org/usa-action/variables/RELATE#comparability_section
	*/
	
// Group quarter definition
keep if inlist(gq, 1, 2, 5)
	/* IPUMS states that "In most cases, a working definition of "household" as 
	GQ = 1 or 2 is appropriate. Categories are not completely comparable across 
	all years." See: 
	https://usa.ipums.org/usa-action/variables/GQ#comparability_section
	I also include GQ = 5, which is a small segment of the sample since 2000, 
	since these respondents have non-missing responses for home-ownership.
	*/

// =============================================================================
// 3. Generate variables for model
// =============================================================================
/* In this section, I code the main dependent (indicator) variable for home 
   ownership (ownd), the main explanatory variable for age, and various 
   economic, demographic, and geographic covariates, which are commented out
   for now since they are not used in the present analysis. */

// Home ownership definition (dummy variable)
gen ownd = 1 if ownershp == 1
replace ownd = 0 if ownershp == 2

// Householder age
replace age = 90 if age > 90 // Top-coding at 90 years old for comparability across years
keep if age >= 21 // Restricting analysis to those 21 years or older

// Householder age groups
gen agegroup = 1 if age >= 21 & age <= 29
replace agegroup = 2 if age >= 30 & age <= 39
replace agegroup = 3 if age >= 40 & age <= 49
replace agegroup = 4 if age >= 50 & age <= 59
replace agegroup = 5 if age >= 60 & age <= 69
replace agegroup = 6 if age >= 70 & age <= 79
replace agegroup = 7 if age >= 80
lab var agegroup "Age groups (top-coded 80)"
lab def agegroup_lbl ///
	1 "21-29" ///
	2 "30-39" ///
	3 "40-49" ///
	4 "50-59" ///
	5 "60-69" ///
	6 "70-79" ///
	7 "90+"
lab val agegroup agegroup_lbl

/* Commented out for now since these are covariates not used in the current analysis
// Sex
recode  sex 2 = 0
lab drop SEX
lab def sex_lbl 0 "Female" 1 "Male"
lab val sex sex_lbl

// Race/ethnicity
gen 	race_ = .
replace race_ = 1 if race == 1 & hispan == 0 // white
replace race_ = 2 if race == 2 & hispan == 0 // black
replace race_ = 3 if inlist(race, 4, 5, 6) & hispan == 0 // asian/pacific islander
replace race_ = 4 if inlist(race, 3) & hispan == 0 // native american
replace race_ = 5 if inlist(race, 7, 8, 9) & hispan == 0 // other or multiracial
replace race_ = 6 if hispan != 0 // hispanic
lab var race_ "Race/ethnicity"
drop race
rename race_ race
lab def race_lbl ///
	1 "White" ///
	2 "Black" ///
	3 "Asian/Pac. Islander" ///
	4 "Native American" ///
	5 "Other/Mult." ///
	6 "Latino/Hispanic"
lab val race race_lbl

// Generate harmonized education var (educ_ha)
gen 	educgroup = .
replace educgroup = 1 if educd <= 61 // less than a high school degree
replace educgroup = 2 if inlist(educd, 62, 63, 64) // high school degree or equivalent
replace educgroup = 3 if inlist(educd, 65, 70, 71, 80, 90, 100, 110, 111, 112, 113) // some college, no degree
replace educgroup = 4 if inlist(educd, 81, 82, 83)  // associate's degree
replace educgroup = 5 if educd == 101 // bachelor's degree
replace educgroup = 6 if educd == 114 // master's degree
replace educgroup = 7 if educd == 115 // professional degree
replace educgroup = 8 if educd == 116 // doctoral degree
lab var educgroup "Education, harmonized"
lab def educgroup_lbl ///
	1 "Less than a HS degree" ///
	2 "HS degree or equivalent" ///
	3 "Some college, no degree" ///
	4 "Associate's degree" ///
	5 "Bachelor's degree" ///
	6 "Master's degree" ///
	7 "Professional degree" ///
	8 "Doctoral degree"
lab val educgroup educgroup_lbl

// Marital status
gen 	marst_ = 1 if marst == 1 | marst == 2 // married
replace marst_ = 2 if marst == 3 | marst == 4 | marst == 5 // separated, divorced, or widowed
replace marst_ = 3 if marst == 6 // never married/single
lab var marst_ "Marital status, harmonized"
drop marst
rename marst_ marst
lab def marst_lbl ///
	1 "Married (spouse present or absent)" ///
	2 "Separated, divorced, or widowed" ///
	3 "Never married/single"
lab val marst marst_lbl

// Indicator for residency in CA (dummy variable)
gen ca = (statefip == 6)
	/* Input variable for subpop analysis within svy commands. */

// Number in household
bysort year serial: egen house_count = count(pernum)
replace house_count = 10 if house_count > 10

// Number of adults
gen adult_count_ = (age >= 18)
bysort year serial: egen adult_count = total(adult_count_)
replace adult_count = 6 if adult_count > 6

// Number of children
gen child_count_ = (age < 18)
bysort year serial: egen child_count = total(child_count_)
replace child_count = 6 if child_count > 6

// Number of similar age adults
gen hh_age_ = age if relate == 1
bysort year serial: egen hh_age = total(hh_age_)
gen hh_age_diff = (hh_age - age < 10 & hh_age - age >= -10 & age >= 18)
bysort year serial: egen house_age_count = total(hh_age_diff)
replace house_age_count = 4 if house_age_count > 4

// Metro area
gen metro_group = 0 if metro == 0
replace metro_group = 1 if metro == 1
replace metro_group = 2 if metro >= 2 & metro <= 4

// Number of bedrooms
replace bedrooms = 5 if bedrooms > 5
*/


// =============================================================================
// 4. Restrict to householders
// =============================================================================
/* In this section, I restrict the sample to householders, which is the primary
   unit of analysis for the measurement of homeownership rates. Note: This step
   must come after generating the preceding covariates since some of those 
   variables rely on knowing the number of respondents in a household contingent
   on various characteristics (like age). */

// Restrict to householders
keep if relate == 1 // primary unit of analysis for homeownership rates


// =============================================================================
// 5. Save munged data set
// =============================================================================
cd "$derived_data"
compress
save dataset_munged.dta, replace