# PyGMET
PyGMET is a python-based tool for generating gridded analyses of time-varying geophysical variables based on merging point/in-situ and spatially-distributed (i.e., gridded) observations and predictor variables. It was developed to expand on and advance the capabilities of the Gridded Meteorological Ensemble Tool (GMET: https://github.com/NCAR/GMET), which is written in FORTRAN. PyGMET reproduces the baseline GMET capabilities (see Bunn et al, 2022) that were developed largely for meteorological dataset generation in climate and water resources applications, including creating inputs for hydrologic simulation and prediction. PyGMET has a more flexible structure and provides a much broader array of methods than GMET, which relied solely on locally-weighted spatial linear and logistic regression methods. PyGMET also has certain technical differences which were either unavoidable or pragmatic due to the conversion from FORTRAN to Python (including a different approach to cross-validation). 

<p align="center">
  <img src="https://github.com/NCAR/PyGMET/docs/california2017_ensemble_prcp.gif" alt="ensemble precipitation" />
</p>

## Functionality
PyGMET can perform the following tasks: 
-   Generate deterministic estimates of any input variable defined in the configuration file using various regression methods, including machine learning methods supported by scikit-learn.
-   Generate cross-validation outputs with evaluation results at station points.
-   Generate probabilistic estimates of any number of ensemble members.
-   Provide intermediate outputs, such as spatiotemporally correlated random fields, spatial correlation, temporal autocorrelation (lag 1), nearby station index/weights, and more.

## Installation
PyGMET attempts to rely on common library dependencies in Python (version 3 or greater) environment. It can be run as long as the packages listed in environment.yml or requirements.txt are installed. Users can also create virtual environments following below instructions. 
- Pip
```  
cd /your/path/of/PyGMET  
virtualenv PyGMET-env  
source PyGMET-env/bin/activate  
pip install -r requirements.txt  
```  
- Conda
```  
conda env create -f environment.yml  
conda activate PyGMET-env  
```

## Usage

To run PyGMET, follow these steps:

1.  Prepare the configuration file.  
Use configuration files in the `./test_cases` folder as templates. Refer to `How_to_create_config_files.md` for more details.
2.  Run PyGMET  
`python main.py /your/path/config_filename.toml`.
3. Batch run / operational run  
When producing a dataset in a target domain or testing different method choices, PyGMET can be run in many batches (e.g., month by month). We recommend users run PyGMET in two steps to improve efficiency:
    -   **Test run**: Run PyGMET on a test period or the first batch. Basic outputs (e.g., nearby station information, weights, and spatial correlation structures) will be generated and saved, which can be used by following batch runs.
    -   **Batch run**: Run PyGMET without changing `outpath_parent` so that PyGMET can find the outputs generated in the test run.

## Test Case(s) for PyGMET

A test case for PyGMET is provided, leveraging the test case currently in use for GMET v2.0. The below codes show how to get the test case and how to run the test case.
```  
cd ../src  
python main.py ../test_cases/testcase.config.static.toml  
```
Jupyter Notebooks in the `./docs` folder can be used to visualize PyGMET test case outputs.

## Notes
This code is a work in progress and is provided without guarantee of fitness for any particular application.  
The PyGMET develop branch is the most recent. Branch structure may be changed during the development.  

## PyGMET (prototype) Datasets
Prior to formal PyGMET development at NCAR, a python code including some of the GMET functionality was developed by G. Tang.  This code was a precursor to the current PyGMET development effort at NCAR, and was used to generate the following ensemble meteorological datasets.  
EMDNA: Ensemble Meteorological Dataset for North America, https://doi.org/10.20383/101.0275  
EM-Earth: The Ensemble Meteorological Dataset for Planet Earth, https://doi.org/10.20383/102.0547

## Sponsorship
- US Army Corps of Engineers -- Climate Preparedness and Resilience Program (NCAR)
- US Bureau of Reclamation -- Snow Water Supply Forecasting Program (NCAR)
- Global Water Futures (U. Saskatchewan)

## References
### FORTRAN-based GMET
__GMET v2.0__:  Bunn, PTW, AW Wood, AJ Newman, H Chang, CL Castro, MP Clark and JR Arnold, 2022, Improving station-based ensemble surface meteorological analyses using numerical weather prediction:  A case study of the Oroville Dam crisis precipitation event. J. Hydromet. 23(7), 1155-1169. https://doi-org.cuucar.idm.oclc.org/10.1175/JHM-D-21-0193.1
Liu, Hongli, AW Wood, AJ Newman and MP Clark, 2021, Ensemble dressing of meteorological fields: using spatial regression to estimate uncertainty in deterministic gridded meteorological datasets, AMS J. Hydromet., https://doi.org/10.1175/JHM-D-21-0176.1
Newman, A. J. et al. (2020) ‘Probabilistic Spatial Meteorological Estimates for Alaska and the Yukon’, Journal of Geophysical Research: Atmospheres, 125(22), pp. 1–21. doi: 10.1029/2020JD032696.   
Newman, A. J. et al. (2019) ‘Use of daily station observations to produce high-resolution gridded probabilistic precipitation and temperature time series for the Hawaiian Islands’, Journal of Hydrometeorology, 20(3), pp. 509–529. doi: 10.1175/JHM-D-18-0113.1.    
Newman, AJ, MP Clark, J Craig, B Nijssen, AW Wood, E Gutmann, N Mizukami, L Brekke, and JR Arnold, 2015, Gridded Ensemble Precipitation and Temperature Estimates for the Contiguous United States, J. Hydromet., doi: http://dx.doi.org/10.1175/JHM-D-15-0026.1  
Clark, M. P. and Slater, A. G. (2006) ‘Probabilistic Quantitative Precipitation Estimation in Complex Terrain’, Hydrometeorology, Journal O F, (2000), pp. 3–22.

### PyGMET prototype
Tang, G., Clark, M. P., & Papalexiou, S. M. (2022). EM-Earth: The Ensemble Meteorological Dataset for Planet Earth. Bulletin of the American Meteorological Society, 103(4), E996–E1018. https://doi.org/10.1175/BAMS-D-21-0106.1  
Tang, G., Clark, M. P., Papalexiou, S. M., Newman, A. J., Wood, A. W., Brunet, D., & Whitfield, P. H. (2021). EMDNA: an Ensemble Meteorological Dataset for North America. Earth System Science Data, 13(7), 3337–3362. https://doi.org/10.5194/essd-13-3337-2021

### PyGMET
A journal article is currently under development.
