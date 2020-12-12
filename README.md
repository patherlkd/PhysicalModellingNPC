# PhysicalModellingNPC
Open source code for 'Physical modelling of multivalent interactions in thenuclear pore complex':  https://doi.org/10.1101/2020.10.01.322156

## Running MD LAMMPS simulations

Ensure you have the LAMMPS 2016 (or above) version when running these simulations.

The code included in this repository is for an F6A chain (with six cohesive blocks, in the 4 amino acids per bead (4apb) coarse graining) and a patchy-particle (NTF2) with two cohesive binding sites. 

### example_config.txt

This is a file containing the initial condition for the simulations.

### in.start_up_4apb

This performs an initial simulation to check the initial conditions. It outputs a restart file to be used for the production simulation.

### in.resume_4apb

This performs a much longer production simulation where the 'xyz' file contains the time trajectory of the all the bead coordinates.

### do_kD.pl

This calculates the single-molecule kD.

What you should run on the command line:

```
perl do_kD.pl simulation_trajectory.xyz 2 5 1.4 25 4 2
```

The arguments are (1) xyz file name (2) particle type for the polymer cohesive block (3) particle type for the particle cohesive patch (4) cutoff (r_0) between a particle patch of diameter 0.38 nm and a polymer bead of diameter 1.02 (5) The box length L = 25 nm (6) the coarse graining of the polymer (4 = 4apb) (7) the number of patches on the patchy-particle = 2 in this case.

### do_koff.pl

This calculates the single-molecule koff.


What you should run on the command line:

```
perl do_koff.pl simulation_trajectory.xyz 2 5 1.4 25 4 2
```
with the same parameters as for do_kD.pl.

