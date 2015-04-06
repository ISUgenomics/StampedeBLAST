# StampedeBLAST
## Running BLAST on local file system: XSEDE-Stampede  

Use this method to run `BLAST` on local file system of Stampede. This approach requires that the input needs to be split into several files. The number of files will be the number of nodes required by the job. This means that if the input file is split into 20 files, 20 nodes will be required by the job. Since having all the nodes accessing the filesystem will create a very high IO load, the database needs to be moved to the local disk of each node. It is also important here to remember that the folder in the parallel filesystem where the database is located needs to have a stripe of at least 60 (see previous section).

Lets say we want to use 10 nodes (10 nodes, 16 cores per node, equals 160 cores). 
First, split the input file to desired number of splits:
```
fasta-splitter.pl --n-parts 10 --measure count input.fasta
```
Now, have 10 files with names: `input.0`, `input.1`, `input.2`,…, `input.9`. Now, the rank `0` will work on `input.0`, rank `1` will work on `input.1`, and so on. We are going to need an auxiliary executable file that will do this (file `task.sh`), with all the `BLAST` settings (output format, database etc.,) pre-configured. An example pre-configured script (`task.sh`) is provided here.

Next, each task (remember, in our example we have 10 of these) gets its rank. It creates a folder in its own local disk and copies the original database to the local disk. Once the file has been copied, it runs `blastp` using as input the file `input.$rank`. It will also write the output in `blast_results.$rank`. Since rank starts at 0 and ends at 9 (in this example), we need the input files to be name exactly like that: `input.0`,…, `input.9`. Be careful not to use: `input.00`, `input.01`,…, `input.09`, as that will fail. It is important to notice how we are indicating `blastp` to use `16` threads.

Now, all we need is to run this script using ibrun (using the batch script), as:
```
time ibrun tacc_affinity sh ./task.sh
```
We are requesting `10` nodes (`-N` option) and `10` processes (`-n`). Then, each of these 10 processes will use `16` threads as previously stated. It is also important to pay attention to how the environment variables are now defined, pointing to `/tmp/DATABASE` which is the local disk of each node. Once all the 10 tasks have finished, the individual output files of each execution are put together into `blast_results_out_10.txt`.
