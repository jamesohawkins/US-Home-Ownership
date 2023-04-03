// = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
// Do File: 0_script-control.do
// Stata Version: 17
// Author: 		James Hawkins
// Datasets: 	ACS extracts from IPUMS-USA.
// Description: This do file controls the primary settings and scripts for the 
// 				analysis of homeownership rates in the U.S. 
// 
// Code is separated into four sections:
//		0 - Random Seeds
//		1 - Clean Statefip Crosswalk
//		2 - Harmonizing ACS data with CPS data
//		3 - Cleaning and Harmonizing CPS File
// = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

// Install packages
// =============================================================================
ssc install fre, replace
ssc install labutil, replace
ssc install gtools, replace
ssc install coefplot, replace
ssc install blindschemes, replace
ssc install palettes, replace

// Visualization settings
// =============================================================================
set scheme plotplain
graph set window fontface "Lato Bold"

// Set directories
// =============================================================================
/* User: Set primary directory below. */
global directory "G:\My Drive\BIFYA\US-Home-Ownership"
global scripts "${directory}/Scripts"
global raw_data "${directory}/Raw-Data"
global derived_data "${directory}/Derived-Data"
global output "${directory}/Output"

// Set ACS file extract
// =============================================================================
/* User: Set ACS file extract number from IPUMS to the number saved in your
   repository. Due to file size restrictions by IPUMS, I download two separate
   extracts. For additional instructions see the Github repository. */
global usa_file1 = "usa_00097" // NOTE: CHANGE TO YOUR EXTRACT NAME
**global usa_file2 = "usa_00093" // split extract for extended analysis

// Set seed
// =============================================================================
set seed 52602
set sortseed 41851

// Scripts
// =============================================================================
* initiate timer
timer on 1
* execute scripts
cd "$scripts"
do 1_munging.do
cd "$scripts"
do 2_analysis.do
* end timer
timer off 1
timer list 1
noi display as text "Scripts took " as result %3.2f `=r(t1)/60' " minutes"