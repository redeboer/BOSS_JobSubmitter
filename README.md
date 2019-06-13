# BOSS Job Submitter

This repository needs to be placed in your _local BOSS install_ (see [here](https://besiii.gitbook.io/boss/tutorials/getting-started/setup) for the usual setup of your BOSS environment). If you make use of the [BOSS StarterKit](https://github.com/redeboer/BOSS_StarterKit), or work in another repository reflects the BOSS environment, you should add this repository as a [submodule](https://git-scm.com/book/en/Git-Tools-Submodules). For this, navigate to local install (which contains the `workarea` and `cmthome` folders) and do:

```bash
git submodule add git@github.com:redeboer/BOSS_JobSubmitter.git jobs
```

This creates a submodule to a folder called `Tutorials` (we want to omit the `BOSS_`).

Altenatively, you can directly `clone` the repository to some other directory. It is not garuanteed that all modules still work properly, as it depends on the setup of your own BOSS environment. In this case, do:

```bash
git clone git@github.com:redeboer/BOSS_JobSubmitter.git <some name for the target folder>
```
