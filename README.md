# WRF-Hydro and Parflow Coupling on Derecho
Instructions and files for building and running coupled WRF-Hydro and PARFLOW using NUOPC

## Build Instructions
Build environments for Cheyenne and Derecho are preconfigured and loaded using
`--env-auto`. For more information use `./compile.sh -h`
```
$ ./compile.sh --env-auto
```

## Use Case Instructions
Preconfigured use cases are available in `usecase` directory. `RUN_DIRECTORY`
defaults to run/USE_CASE_NAME but can be manually configured using
`setuprun.sh`. For more information use `setuprun.sh -h`.
```
$ ./setuprun.sh PATH_TO_USE_CASE_CONFIG
$ cd RUN_DIRECTORY
$ BATCH_SUBMIT run.sh
```
