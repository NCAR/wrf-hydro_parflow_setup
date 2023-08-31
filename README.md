# WRF-Hydro and Parflow Coupling on Derecho
Instructions and files for building and running coupled WRF-Hydro and PARFLOW using NUOPC

## Prerequisites: setup using module files
Add the following `module use` statement to a `.bashrc` file to use `module load wrfhydro-parflow`
```
$ module use /glade/work/soren/derecho/local/lmod
```
Then load modules and set environment variables on Derecho.
```
$ module load wrfhydro-parflow
$ conda activate conda-yaml
```
NOTE: using `conda activate npl` will cause this build to fail because it adds extra NetCDF files that cause issues later on. A user will need to use `conda` or `pip` to obtain the Python package `PyYAML`.


## Derecho Build Instructions
```
$ make
or
$ ESMX_Builder -g esmxBuild.yaml -v --build-jobs=4
```
