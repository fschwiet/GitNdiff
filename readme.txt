﻿
GitNdiff.ps1 - 
  A diff'ing tool
  Opens up all files at once in diff tool of choice (which is DiffMerge.
  
GitNDiff <left-ref> <right-ref>
  
Without any parameters, the current head is compared with the working tree.
For either left or right references, the current working tree can be indicated by a period.

Examples: 
    GitNDiff
    GitNDiff head .
    -> compares current head to the current working tree (default comparison)

    GitNDiff master~1
    -> compares master one checkin back to the current working tree (default target is current working tree

    GitNDiff master~1 master
    -> allows comparison of the last checkin to the master branch

    GitNDiff . .
    -> compares the working tree to the working tree (not useful, but demonstrates .)
    (there is probably a more git way to indicate the working tree)

    GitNDiff 011b6c4fa9b59e4f282c9b1eb27d0ec4bf660920 ddabb5091aaec9640f5dc1cc42e018d47f4713e7
    -> I hope you get the picture
  
This is accomplished by creating a copy of everything in your repository, twice.  It can take awhile.
If you start from a subdirectory of your repository, only that will be copied.
  
DiffMerge can be downloaded from http://www.sourcegear.com/diffmerge/

