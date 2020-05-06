#include "interventions.h"
#include "individuals.h"



%inline %{

int intervention_quarantine_list(model *model, PyObject * to_quarantine, int time_to)
{
        int n, i;
        long idx;
        PyObject * o;
        n = PyList_Size(to_quarantine);
        for (i = 0; i < n; i++) {
                o = PyList_GetItem(to_quarantine, i);
                idx = PyInt_AsLong(o);
                if (idx >= 0 && idx < model->params->n_total)
                        intervention_quarantine_until(model, model->population + idx, time_to, TRUE, NULL, 0);
                else {
                        PySys_WriteStdout("ERROR: %li out of range!", idx);
                        return 1;
                }
        }
        return 0;
}

PyObject * get_state(model *model)
{
        int pdx;
        struct individual *indiv;
        PyObject *out;
        out = PyList_New(model->params->n_total);
        for (pdx = 0; pdx < model->params->n_total; pdx++) {
                indiv = &(model->population[pdx]);
                PyList_SetItem(out, pdx, PyInt_FromLong(indiv->status));
        }
        return out;
}

PyObject * get_contacts(model * model)
{
        int day, pdx, idx; // k, ktot;
        struct individual *indiv;
	struct interaction *inter;
        PyObject *it, *out;
        out = PyList_New(0);
        for (day = 0; day < model->params->end_time; day++) {
                for (pdx = 0; pdx < model->params->n_total; pdx++) {
                        indiv = &(model->population[pdx]);
                        if (indiv->n_interactions[day] > 0) {
                                inter = indiv->interactions[day];
                                for( idx = 0; idx < indiv->n_interactions[day]; idx++) {
                                        it = PyList_New(4);
                                        PyList_SetItem(it, 0, PyInt_FromLong(day));
                                        PyList_SetItem(it, 1, PyInt_FromLong(indiv->idx));
                                        PyList_SetItem(it, 2, PyInt_FromLong(inter->individual->idx));
                                        PyList_SetItem(it, 3, PyInt_FromLong(inter->type));
                                        PyList_Append(out, it);
                                        inter = inter->next;
                                }
                        }
                }
        }

        return out;
}


%}


