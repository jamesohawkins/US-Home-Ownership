# Analysis of Homeownership Rates in the United States

# About the project
This repository includes the necessary [Stata](https://www.stata.com/) code and instructions for replicating the results from [The Berkeley Institute for Young American's](http://youngamericans.berkeley.edu/) analysis of homeownership rates over age and time.

# Methodology
I use data from IPUMS-USA to visualize homeownership rates across time and the age distribution. I use the Census-defined homeownership variable ([OWNERSHP](https://usa.ipums.org/usa-action/variables/OWNERSHP#description_section)), which categorizes respondents as 1 if they reside in an owner-occupied (either owned outright or mortgaged) household or 0 if they're renting. I restrict the sample to households (non-group qarters), respondents age 21 or older, and the household's "householder" (otherwise known as "head of household" or "reference person"). I weight the analysis based on the Census-provided household weight variable ([HHWT](https://usa.ipums.org/usa-action/variables/HHWT#description_section)) to maintain the representativeness of the sample as it relates to the population of households in the U.S. In instances where I calculate standard errors, I use the [IPUMS-recommended](https://usa.ipums.org/usa/complex_survey_vars/userNotes_variance.shtml) survey specification in Stata based on the [CLUSTER](https://usa.ipums.org/usa-action/variables/CLUSTER#description_section), [STRATA](https://usa.ipums.org/usa-action/variables/STRATA#description_section), and [HHWT](https://usa.ipums.org/usa-action/variables/HHWT#description_section) variables. In summary, this analysis measures the weighted percentage of householders in each age group who own a home, and changes in this percentage across time.

A note on householders: The most consequential methodological choice is to restrict the sample to householders. [IPUMS notes](https://usa.ipums.org/usa-action/variables/RELATE#comparability_section) that:
>Beginning in 1980 the census questionnaire no longer referred to a "head of household", specifying instead the designation of "person one"--the first person listed on the census form. This reference person could be any household member in whose name the property was owned or rented. If no such person was present, any adult could be selected. Prior to 1970, enumerators were instructed to record the male as the head of household for all married couples, regardless of the couple's designation of a head.

Thus, my comparison between 1980 and 2021 is using a consistent definition of householders across time; however, based on Census' methodology for determining the householder in a household, it is possible that there are inconsistencies in who is being designated as a householder across time (for instance, if true the homeowner(s) are more likely to be absent from the household in recent years, this could bias our results, particularly when analyzing by age group). Still, I use Census' preferred methodology for measuring homeownership rates using the American Community Survey (for instance, see [Figure 2 at this link](https://www.census.gov/library/stories/2022/11/homeownership-by-young-households-below-pre-great-recession-levels.html)). As a quality control test, I benchmark my results against the Census Bureau's [publicly-reported results](https://www.census.gov/content/dam/Census/library/publications/2021/acs/acsbr-010.pdf) for 2005-2019 and replicate these results with a small margin of error.

### Benchmarks
| Year  | Estimates based on Census  | Estimates based on IPUMS-USA |
| ----------- | ----------- | ----------- |
| 2005 | .669 | .669 |
| 2006 | .673 | .673 |
| 2007 | .672 | .672 |
| 2008 | .666 | .666 |
| 2009 | .659 | .659 |
| 2010 | .654 | .654 |
| 2011 | .647 | .646 |
| 2012 | .64 | .639 |
| 2013 | .636 | .635 |
| 2014 | .632 | .631 |
| 2015 | .631 | .63 |
| 2016 | .632 | .631 |
| 2017 | .639 | .639 |
| 2018 | .64 | .639 |
| 2019 | .642 | .641 |

*Note: Census estimates are from page 11 of the following [link](https://www.census.gov/content/dam/Census/library/publications/2021/acs/acsbr-010.pdf).*

# Replicating the results

## Software
I use Stata Version 17. However, previous versions should work with some limits in visualization capability.

## Directory
The main directory of the repository should include folders for "Scripts", "Raw-data", "Derived-data", and "Output".

## Data
Source: *Steven Ruggles, Sarah Flood, Matthew Sobek, Danika Brockman, Grace Cooper,  Stephanie Richards, and Megan Schouweiler. IPUMS USA: Version 13.0 [dataset]. Minneapolis, MN: IPUMS, 2023. https://doi.org/10.18128/D010.V13.0*

The data for this project can be obtained from [IPUMS-USA](https://usa.ipums.org/usa/). Due to data use limitations on IPUMS data, I cannot provide the raw data used for this project directly. In the space below I include instructions for downloading your own copy of the data extracts from IPUMS.

To download data from IPUMS-USA, a user must register for an account at this [link](https://uma.pop.umn.edu/usa/user/new?return_url=https%3A%2F%2Fusa.ipums.org%2Fusa-action%2Fmenu).

After your account has been approved, the user will need to download the requisite [variables](https://usa.ipums.org/usa-action/variables/group) and [samples](https://usa.ipums.org/usa-action/samples) for this analysis. The following variables (other than the preselected variables in IPUMS) are necessary to complete the analysis:

### Variables:
| Required list |
| ----------- |
| [RELATE](https://usa.ipums.org/usa-action/variables/RELATE#description_section)      |
| [OWNERSHP](https://usa.ipums.org/usa-action/variables/OWNERSHP#description_section)    |
| [AGE](https://usa.ipums.org/usa-action/variables/AGE#description_section)         |

Technically, the main analysis only requires years 1980 and 2021; therefore, the extract from IPUMS can be significantly reduced by only including those two years. However, I have included additional years since I have used other years in extended analysis.

### Samples:

| Decennial Census      |
| ----------- |
| 1970 1% state fm1      |
| 1980 5% state      |
| 1990 5% state      |

| ACS |
| ----------- |
| 2000-2021 |

The extract should be downloaded as a .dta file, which is a setting in the IPUMS extract system. This extract should be downloaded and decompressed in the Raw-data folder of the repository.

For additional instructions on downloading data from IPUMS, please refer to this [guide](https://cps.ipums.org/cps/instructions.shtml). For instructions on opening an IPUMS extract, please refer to this [guide](https://usa.ipums.org/usa/extract_instructions.shtml).

## Code
The only user-required change to the scripts necessary to replicate the main analysis is the corresponding file name of the user's IPUMS extract. On line 44 of 0_script-control.do, within the quotes rename `global usa_file1 = "[INSERT EXTRACT NAME HERE]"` to your corresponding extract name. For instance, this could be `global usa_file1 = "usa_00001"`. See below:

![image](https://user-images.githubusercontent.com/51392605/229632997-80d0d6c3-d5ae-48dc-96b0-11d5cbf9d7de.png)

## Runtime
On a PC with an Intel i7-11700, 64GB ram, and running 64-bit Windows 11 the code executed in approximately 46 minutes. The longest chunk of the code is to produce the results for the second figure, which is based on the `svyset` and `svy` commands in Stata to produce accurate standard errors.

## Ackowledgments
I am grateful to Sarah Swanbeck for reviewing and providing feedback on all stages of the analysis, and [Jesús Guzmán](https://github.com/jesus-guzman) and [Nicholas Adams-Cohen](https://github.com/njadamscohen) for helpful suggestions to improve the readability of the visualizations. 