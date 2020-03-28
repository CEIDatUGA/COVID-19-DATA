## Epi_characteristics

Table of epidemological characteristics of COVID-19 and other zoonotic outbreaks. Data was manually entered from research articles with a PubMed publication identification number. The data set was built to capture the most about of data, so many of the cases are incomplete. The same research article could be used for multiple lines if different outbreaks or statistics were reported. 

This is a static data set.

<b>Metadata:</b> 
 Column name: Description, [Allowed Values] 
 - pathogenName:	Name of pathogen	[2019-nCoV, SARS-CoV, MERS-CoV, H1N1 virus, H5N1 virus, Ebola virus]
 - outbreak:	Specify disease outbreak	[e.g. 2003 global SARS outbreak, 2014-2016 West Africa Ebola virus disease outbreak]
 - parameter:	the quantity reported.[ one of several allowed values. see "Parameter Explanations" below for details.]	
 - estimate:	value of the main reported estimate in the provided source. If more than one estimate is reported, add it as separate line item.	[numeric]
 - censored:	indicate if a value is left- or right- censored or not. E.g. if a paper reports "at least >20 days"/"less than 10" it would be right/left censored. Instead of writing >20 in the estimate column, write 20 into estimate and indicate that it's right censored.[	L, R, N]
- estimateUnit:	unit of the value reported in the estimate column [text]
- estimateType:	type of estimate, if reported.	[mean, median, mode]
- lowerBound:	if reported, lower bound of uncertainty interval	[numeric]
- upperBound:	if reported, upper bound of uncertainty interval	[numeric]
- intervalKind:	type of uncertainty interval, if reported.	[95% confidence interval, 90% credible interval, interquartile range, range]
- ageMean:	mean age of population in question (if reported)	[numeric]
- ageMedian:	median age of population in question (if reported)	[numeric]
- ageMin:	min age of population in question (if reported)	[numeric]
- ageMax:	max age of population in question (if reported)	[numeric]
- proportionMale:	proportion of males of population in question (if reported)	[0-1]
- country:	country where data came from	[text]
- continent:	continent where data came from. Not needed if country is provided.	[text]
- entryAuthor:	person who added the entry to the spreadsheet	[text]
- checkedby:	name of person who checked a given entry	[text]
- publicationFirstAuthor:	last name of 1st author of publication	[text]
- publicationYear:	year the paper was published. NOT year of data collection.	[numeric]
- PMID:	Pubmed ID	[valid PMID]
- URL: URL to paper	[URL (ideally DOI)]
- title:	title of reference/paper	[text]
- notes:	any comments worth being aware of	[text]

<b>Parameter Explanations</b>
<table>
  <tr>
    <th>Name</th>
    <th>Technical definition</th>
    <th>Explanation</th>
    <th>allowed values</th>
    <th></th>
  </tr>
  <tr>
    <td>R0</td>
    <td>basic reproductive number</td>
    <td>the average number of new infections that are caused by one infectious person, assuming the whole population is susceptible. This value can differ based on setting, e.g. it is likely higher in more crowded places, or can vary between children and adults.</td>
    <td>numeric</td>
    <td></td>
  </tr>
  <tr>
    <td>R0-pre</td>
    <td>R0 before symptoms occur</td>
    <td></td>
    <td>numeric</td>
    <td></td>
  </tr>
  <tr>
    <td>R0-asym</td>
    <td>R0 of asymptomatic infected</td>
    <td></td>
    <td>numeric</td>
    <td></td>
  </tr>
  <tr>
    <td>days_presymptomatic</td>
    <td>time from exposure to onset of illness (incubation period)</td>
    <td>the number of days between pathogen exposure and the onset of symptoms.</td>
    <td>numeric</td>
    <td></td>
  </tr>
  <tr>
    <td>days_symptomatic</td>
    <td>duration of symptomatic period in days</td>
    <td></td>
    <td>numeric</td>
    <td></td>
  </tr>
  <tr>
    <td>days_infectious</td>
    <td>duration of infectious period. This might or might not be the same as the symptomatic period.</td>
    <td>the number of days over which an infected individual is able to transmit the virus. This might or might not be the same as the symptomatic period.</td>
    <td>numeric</td>
    <td></td>
  </tr>
  <tr>
    <td>generation_time</td>
    <td>average time from start of infection of 1st case to infection of subsequent case</td>
    <td></td>
    <td>numeric</td>
    <td></td>
  </tr>
  <tr>
    <td>serial_interval_sym</td>
    <td>average time from start of symptoms of 1st case to symptoms of subsequent case</td>
    <td>the number of days between the onset of symptoms in one case and the onset of symptoms in a subsequent case.</td>
    <td>numeric</td>
    <td></td>
  </tr>
  <tr>
    <td>prop_asymptomatic</td>
    <td>proportion of individuals who are asymptomatic</td>
    <td>the percent of individuals who are asymptomatic.</td>
    <td>0-1</td>
    <td></td>
  </tr>
  <tr>
    <td>prop_symptomatic</td>
    <td>proportion of individuals who are symptomatic</td>
    <td>the percent of individuals who are symptomatic.</td>
    <td>0-1</td>
    <td></td>
  </tr>
  <tr>
    <td>prop_inf_fever</td>
    <td>proportion infected individuals who had fever</td>
    <td>the percent of infected patients that present with a fever.</td>
    <td>0-1</td>
    <td></td>
  </tr>
  <tr>
    <td>prop_inf_cough</td>
    <td>proportion infected individuals who had cough</td>
    <td>the percent of infected patients that present with a cough.</td>
    <td>0-1</td>
    <td></td>
  </tr>
  <tr>
    <td>prop_sym_fever</td>
    <td>proportion symptomatic individuals who had fever</td>
    <td>the percent of symptomatic patients that present with a fever.</td>
    <td>0-1</td>
    <td></td>
  </tr>
  <tr>
    <td>prop_sym_cough</td>
    <td>proportion symptomatic individuals who had cough</td>
    <td>the percent of symptomatic patients that present with a cough.</td>
    <td>0-1</td>
    <td></td>
  </tr>
  <tr>
    <td>prop_inf_hospitalized</td>
    <td>proportion infected individuals who have a severe infection and require hospitalization</td>
    <td>the percent of infected patients that are hospitalized.</td>
    <td>0-1</td>
    <td></td>
  </tr>
  <tr>
    <td>prop_inf_death</td>
    <td>proportion of infected individuals who die</td>
    <td>the percent of infected patients that die from their illness.</td>
    <td>0-1</td>
    <td></td>
  </tr>
  <tr>
    <td>prop_hospitalized_death</td>
    <td>proportion of hospitalized cases that result in death</td>
    <td>the percent of individuals who are in severe/critical condition that die from their illness.</td>
    <td>0-1</td>
    <td></td>
  </tr>
  <tr>
    <td>prop_sym_hospitalized</td>
    <td>proportion symptomatic individuals who have a severe infection and require hospitalization</td>
    <td>the percent of symptomatic patients that are hospitalized.</td>
    <td>0-1</td>
    <td></td>
  </tr>
  <tr>
    <td>prop_sym_death</td>
    <td>proportion of symptomatic individuals who die</td>
    <td>the percent of symptomatic patients that die from their illness.</td>
    <td>0-1</td>
    <td></td>
  </tr>
  <tr>
    <td>prop_infection_reduction_masks</td>
    <td>proportion by which risk of infection is reduced in susceptible individuals wearing masks</td>
    <td></td>
    <td>0-1</td>
    <td></td>
  </tr>
  <tr>
    <td>prop_critical_death</td>
    <td>proportion of critical cases that result in death</td>
    <td>the percent of patients in critical condition that die from their illness.</td>
    <td>0-1</td>
    <td></td>
  </tr>
  <tr>
    <td>prop_inf_critical</td>
    <td>proportion of infected individuals in critical condition</td>
    <td>the percent of infected patients that are in critical condition.</td>
    <td>0-1</td>
    <td></td>
  </tr>
  <tr>
    <td>prop_sym_critical</td>
    <td>proportion of symptomatic individuals in critical condition</td>
    <td>the percent of symptomatic patients that are in critical condition.</td>
    <td>0-1</td>
    <td></td>
  </tr>
</table>
<b>Related subdirectory and/or files</b>

<b>Projects</b>

List/Link related projects
