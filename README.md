OpenABM-Covid19: Agent-based model for modelling the Covid-19 + Intervention API
========================================================================

This fork containts a minimal [Intervention API](#intervention-api) that allows interaction with the original C++ code via the python interface. Risk assessment and tracing techniques can be easily integrated with the agent-based model in order to test containment strategies for epidemic spreading.

Description
-----------

OpenABM-Covid19 is an agent-based model (ABM) developed to simulate the spread of Covid-19 in a city and to analyse the effect of both passive and active intervention strategies.
Interactions between individuals are modelled on networks representing households, work-places and random contacts.
The infection is transmitted between these contacts and the progression of the disease in individuals is modelled.
Instantaneous contract-tracing and quarantining of contacts is modelled allowing the
evaluation of the design and configuration of digital contract-tracing mobile phone apps.

A full description of the model can be found [here](https://github.com/BDI-pathogens/OpenABM-Covid19/blob/master/documentation/covid19_model.pdf).
A report evaluating the efficacy of various configurations of digital contract-tracing mobile phone apps can be found [here](https://github.com/BDI-pathogens/covid-19_instant_tracing/blob/master/Report%20-%20Effective%20Configurations%20of%20a%20Digital%20Contact%20Tracing%20App.pdf). 
The model was developed by the Pathogen Dynamics group, at the [Big Data Institute](https://www.bdi.ox.ac.uk/) at the University of Oxford, in conjunction with IBM UK and [Faculty](https://faculty.ai).
More details about our work can be found at [www.coronavirus-fraser-group.org ](https://045.medsci.ox.ac.uk/).


Compilation
-----------

OpenABM-Covid19 requires a C compiler (such as gcc) and the [GSL](https://www.gnu.org/software/gsl/) libraries installed.
Python installation requires Python 3.7+

```bash
cd OpenABM-Covid19/src
make all
```

To install the Python interface, first install [SWIG](http://www.swig.org/), then:

```bash
make swig-all
```

Usage
-----

```bash
cd OpenABM-Covid19/src
./covid19ibm.exe <input_param_file> <param_line_number> <output_file_dir> <household_demographics_file>
```

where:
* `input_param_file` : is a csv file of parameter values (see [params.h](src/params.h) for description of parameters)
* `param_line_number` : the line number of the parameter file for which to use for the simulation
* `output_file_dir` : path to output directory (this directory must already exist)
* `household_demographics_file` : a csv file from which samples are taken to represent household demographics in the model

We recommend running the model via the Python interface (see Examples section with scripts and notebooks below). Alternatively

```python
from COVID19.model import Model, Parameters
import COVID19.simulation as simulation

params = Parameters(
    input_param_file="./tests/data/baseline_parameters.csv",
    param_line_number=1,
    output_file_dir="./data_test",
    input_households="./tests/data/baseline_household_demographics.csv"
)
params.set_param( "n_total", 10000)

model = simulation.COVID19IBM(model = Model(params))
sim   = simulation.Simulation(env = model, end_time = 10 )
sim.steps( 10 )
print( sim.results )     

```

Examples
-----

The `examples/` directory contains some very simple Python scripts and Jupyter notebooks for running the model. The examples must be run from the example directory. In particular

1. `examples/example_101.py` - the simplest Python script for running the model
2. `examples/example_101.ipynb` - the simplest notebook of running the model and plotting some output
3. `examples/example_102.ipynb` - introduces a lock-down based upon the number of infected people and then after the lock-down turns on digital contact-tracing
4. `examples/example_extended_output.ipynb` - a detailed notebook analysing many aspect of the model and infection transmission.
5. `examples/multi_run_simulator.py` - an example of running the model multi-threaded

_____

Tests
-----

A full description of the tests run on the model can be found [here](https://github.com/BDI-pathogens/OpenABM-Covid19/blob/master/documentation/covid19_tests.pdf).
Tests are written using [pytest](https://docs.pytest.org/en/latest/getting-started.html) and can be run from the main project directory by calling `pytest`.  Tests require Python 3.6 or later.  Individual tests can be run using, for instance, `pytest tests/test_ibm.py::TestClass::test_hospitalised_zero`.  Tests have been run against modules listed in [tests/requirements.txt](tests/requirements) in case they are to be run within a virtual environment.

## Intervention API

The following procedures are available:

* `get_contacts_daily(model * model, int day)`: returns the full list of contacts for a given day
* `intervention_quarantine_list(model *model, PyObject * to_quarantine, int time_to)`: quarantines a list of individuals for `time_to` days
* `get_age(model *model)`: returns the list of ages for all individuals in the network
* `get_app_users(model *model)`: returns a list of boolean values indicating app adoption for all individuals
* `PyObject * get_house(model *model)`: returns the househould ID for all individuals
* `PyObject * get_state(model *model)`: returns the current state of all individuals

### Usage

Once a `model` object is instantiated, a typical run in the presence of external intervention would consists of the following steps:

```python
    
    import covid19
    
    # retrieve demographics
    house = covid19.get_house(model.model.c_model)
    ages = covid19.get_house(model.model.c_model)
    
    # store list of individuals using the tracing app
    has_app = covid19.get_app_users(model.model.c_model)

    for t in range(end_time):
        # update model state
        sim.steps(1)
        # get status of nodes in the networks
        status = np.array(covid19.get_state(model.model.c_model))
        # get daily contacts
        daily_contacts = covid19.get_contacts_daily(model.model.c_model, t)
        
        # use your favourite method to perform risk assessment
        to_quarantine = ...
        
        # quarantine a list of individuals for days_of_quarantine days
        covid19.intervention_quarantine_list(model.model.c_model, to_quarantine, days_of_quarantine)
```
