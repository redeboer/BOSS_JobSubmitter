# BOSS Job Submitter

This repository provides a few utilities that allow you to create multiple job option files based on [certain templates](https://github.com/redeboer/BOSS_JobSubmitter/tree/master/templates). This is helpful if you want to split your analysis into an arbitrary jobs so that the IHEP queue can handle them. The Job Submitter can create job option files for simulation, reconstruction, analysis jobs, ahd the corresponding shell scripts that you use when submitting the jobs through `hep_sub`.

## How to install?

This repository needs to be placed in your _local BOSS install_ (see [here](https://besiii.gitbook.io/boss/tutorials/getting-started/setup) for the usual setup of your BOSS environment).

If you make use of the [BOSS StarterKit](https://github.com/redeboer/BOSS_StarterKit), you can [use the fact that this repository has been added as a submodule](https://github.com/redeboer/BOSS_StarterKit#1-real-submodules) there.

If you want to implement this repository as a submodule in your own repository (which contains a `workarea` and `cmthome` folder), navigate to that repository and do:

```bash
git submodule add git@github.com:redeboer/BOSS_JobSubmitter.git jobs
```

This creates a submodule to a folder called `jobs`. For more information on submodules, see [here](https://git-scm.com/book/en/Git-Tools-Submodules). **Note, however, that the `bash` functions provided by this repository rely on functions provided by the BOSS Starter kit.**

If you do not work with Git, just clone this repository and make it compatible with your own setup:

```bash
git clone https://github.com/redeboer/BOSS_JobSubmitter.git <optional: name of the target folder>
```

It is not garuanteed that this module still work properly, as it depends on the setup of your own BOSS environment.

## How to use?

On the `lxslc` terminal, just use either of the following commands:

```bash
CreateAnaJobFiles # to create analysis job files
CreateSimJobFiles # to create simulation+reconstruction job files
```

The functions guide you through the process through some questions. The answers you give will be stored to a file located under `$BOSS_JobSubmitter/CreateAnaJobFiles.txt` resp. `$BOSS_JobSubmitter/CreateSimJobFiles.txt`, which means you can rerun it without having to answer again using:

```bash
CreateAnaJobFiles < $BOSS_JobSubmitter/CreateAnaJobFiles.txt
CreateSimJobFiles < $BOSS_JobSubmitter/CreateSimJobFiles.txt
```

**WARNING**: Both commands ask whether the jobs should be submitted to `hep_sub`, so keep this in mind when automising your input in this way.
