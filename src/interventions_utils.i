#include "interventions.h"
#include "individuals.h"


%inline %{

int intervention_quarantine_list(model *model, int indiv, int time)
{
        intervention_quarantine_until(model, model->population + indiv, time, TRUE, NULL, 0);
        assert(indiv = model->population[indiv].idx);
}

%}


/*
void intervention_quarantine_until(
	model *model,
	individual *indiv,
	int time,
	int maxof,
	trace_token *index_token,
	int contact_time
)
*/
