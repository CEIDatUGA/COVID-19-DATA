This folder contains data on non-pharmaceutical interventions implemented at the county-wide level in the US state of Georgia during the COVID-19 pandemic.

These data are scraped manually from State Executive Orders, Departments of Education, and other news sources (housed on [this google sheet](https://docs.google.com/spreadsheets/d/1UZMWpbebhI3HS2BwzK0PCUxAbypYnM9oA9t9jP6zNXE/edit#gid=1772124213)).



Google sheet is downloaded here to longFormStateInterventions.csv daily and converted into a time series of intervention intensity interventionTimeSeries.csv.

## GA_county_intervention_time_series.csv
<b>Metadata:</b> 



`NAME`: County name
`DATE`: Date
 - `social_distancing`:	recommendations to distance from other individuals outside your household (0/1)
- `close_public_spaces`:	such as parks, plazas, and public use area (0/1)
- `personal_hygiene`:	use of face masks, washing hands(0/1)
- `environmental_hygiene`:	maintence of indoor air circulation; disinfection of surfaces (0/1)
- `monitoring`:	encouragement to monitor health of those/family around you (0/1)
- `well_being`:	maintain healthy diet (0/1)
- `animal_distancing`:	avoid animals, ban consumption of animals (wild); avoiding animal markets (0/1)
- `non_contact_infrastructure`:	deployment on non-contact machines, infrastructure to curb contact (0/1)
- `state_of_emergency`:	declaration of state of emergency. Will only list if occurs before State policies (0/1)
- `no_contact_school`:	policies that close school, often include recommendations on online/residential schools (0/1)
- `prohibit_business`:	policies that limit gatherings inside restaurants and other public-use spaces (eg. movie theaters, gyms, bars).. This can still include roadside or take-out only service (0/1)
- `travel_screening`:	can include temperature checks at railways, airports, and other travel epicenters (0/1)
- `prohibit_travel`:	car, bus, or air travel limited in some capactiy (0/1)
- `international_travel_quarantine`:	international travelers must implement 14 day travel score (0/1)
- `gathering_size_limited`:	public gatherings are limited to a maximum number of individuals (0/1)
- `mandatory_traveler_quarantine`:	all travelers that arrive in adm are quarantined for 14 days (0/1)
- `protect_high_risk_populations`:	mandates in place to prohibit travel or contact with high risk populations (such as older or imunocompromised individuals) (0/1)
- `shelter_in_place`:	residents requested to stay home except for essential services/business (0/1)
- `gathering_size`: Maximum gathering size allowed (continuous) 
- `Intervention Score`: Sum of measures taken scaled by impact (see metadata on google sheet)

 ## GA_raw_county_interventions.csv  
 <b>Metadata:</b>
- `NAME`: Name of county
- `source_type`: type of source (government, news, etc.)
- `ADM_scale`: Administrative level at which it the intervention is implemented (ADM1 = state)
- `Source_URL`: link to webpage with information
- `announcement_type`: one of four options: state of emergency, non-contact school (either online or school cancelled), prohibit restaurants (can still allow roadside or take-out), gathering size limited (public gatherings limited to a maximum number of individuals)
- `announcement_date`: date intervention measure is announced
- `start_date`: date measure takes effect, if different from announcement date
- `end_date`: date measure is supposed to end
- `access_date`: date Source_URL was accessed
- `who_by`: initials of person who sourced data
- `last checked`: if state has not announced an action, dates are left blank; this date provides information on when the intervention was last confirmed to not be in place
