# Task 1 - Scripting test

The script `system_check.sh` had been created to check systems if they are meeting minimum requirements.

Each check is defined in a different function, prints the expected and set values and evaluates if the given criterias are fulfilled or not. The script also gives a final verdict in the end. The verdicts are also colored green/red based on the results.

## List of checks

### OS checks
The script checks if the given OS is Ubuntu and also checks the major version and fails if it's greater than 20.

Both values are read from `/etc/os-release`.

### CPU checks
The next 2 checks are for the CPUs. First it counts the number of cores, then checks if AVX is supported.

Number of cores are taken from `/proc/cpuinfo`, while the AVX support is checked using `lscpu`.

### RAM check
RAM value is taken from the command `free` and is rounded to 2 decimal places.

Since the value is not an integer, we use `bc` to compare the given and expected values.


### Disk check
The free disk space check expects the path the we want to use for installation/storage. It is set to `$HOME` by default.

Available value is taken from `df`.