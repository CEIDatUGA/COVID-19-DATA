This folder contains data on non-pharmaceutical interventions implemented at the state-wide level in the United States during the COVID-19 pandemic.

Google sheet is downloaded here to longFormStateInterventions.csv daily and converted into a time series of intervention intensity interventionTimeSeries.csv.

## interventionTimeSeries.csv
<b>Metadata:</b> 

- `NAME`: Name of state
- `DATE`: Date
- `prohibit_restaurants`: Is the state government prohibiting restaurants from opening? (0/1)
- `school_closure`: Has the government mandated that schools close or go online? (0/1)
- `state_of_emergency`: Has a state of emergency been declared? (0/1)
- `prohibit_gatherings`: Has the state government prohibited gatherings over a certain size? (0/1)
- `gathering_size`: Maximum legal gathering size in state (NA if no gathering size instituted)
- `Intervention Score`: Sum of first four metrics of intervention (0-4) 
 
 ## longFormStateInterventions.csv  
 <b>Metadata:</b>
- `NAME`: Name of state
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
