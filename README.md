# BOSS Job Submitter

This repository needs to be placed in your _local BOSS install_ (see [here](https://besiii.gitbook.io/boss/tutorials/getting-started/setup) for the usual setup of your BOSS environment).

If you make use of the [BOSS StarterKit](https://github.com/redeboer/BOSS_StarterKit), you can [use the fact that this repository has been added as a submodule](https://github.com/redeboer/BOSS_StarterKit#1-real-submodules) there.

If you want to implement this repository as a submodule in your own repository (which contains a `workarea` and `cmthome` folder), navigate to that repository and do:

```bash
git submodule add git@github.com:redeboer/BOSS_JobSubmitter.git jobs
```

This creates a submodule to a folder called `jobs`. For more information on submodules, see [here](https://git-scm.com/book/en/Git-Tools-Submodules).

If you do not work with Git, just clone this repository and make it compatible with your own setup:

```bash
git clone https://github.com/redeboer/BOSS_JobSubmitter.git <optional: name of the target folder>
```

It is not garuanteed that all modules still work properly, as it depends on the setup of your own BOSS environment.
