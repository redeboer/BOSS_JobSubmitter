#include "TError.h"
#include "TFile.h"
#include "TKey.h"
#include "TList.h"
#include "TTree.h"
#include <fstream>
#include <iostream>
using namespace std;

/// @return
/// `-1` File does not exist.
/// `0` Is a ROOT file with `TTree`s.
/// `1` File is a zombie.
/// `2` Contains an empty `TTree`.
/// `3` One of the `TTree`s contains a damaged branch.
/// `4` Valid ROOT file, but no valid `TTree`s.
int IsBossFile(const char *filename)
{
  gErrorIgnoreLevel = 6000;

  TFile *file = new TFile(filename);
  if (!file || file->IsZombie()) return 1;

  TIter treeIter(file->GetListOfKeys());
  Int_t ntrees = 0;
  while (TObject *treeObj = treeIter()) {
    TKey *key = dynamic_cast<TKey *>(treeObj);
    if (!treeObj) continue;
    TTree *tree = dynamic_cast<TTree *>(key->ReadObj());
    if (!tree) continue;
    if(tree->LoadTree(0)) return 2;
    ++ntrees;
    TIter branchIter(tree->GetListOfBranches());
    Bool_t ok = true;
    while (TObject *branchObj = branchIter())
      ok = ok && tree->GetBranchStatus(branchObj->GetName());
    if (!ok) return 3;
  }
  if (ntrees) return 0;
  return 4;
}

int main(int argc, char *argv[])
{
  if(argc < 2)
  {
    cerr << "ERROR [IsBossFile]: at least one argument required" << endl;
    return -1;
  }
  return IsBossFile(argv[1]);
}