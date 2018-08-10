# Analysis code for "Constraints on neural redundancy"

__Paper__: Jay A. Hennig, Matthew D. Golub, Peter J. Lund, Patrick T. Sadtler, Emily R. Oby, Kristin M. Quick, Stephen I. Ryu, Elizabeth C. Tyler-Kabara, Aaron P. Batista*, Byron M. Yu*, and Steven M. Chase*. "Constraints on neural redundancy". _eLife_ (2018)

__Code author:__ Jay Hennig (jhennig@cmu.edu)

## Getting started

Add all experimental sessions (link to data coming soon) to the folder `data/sessions/`.

Now, to fit all sessions and generate figures, run the following:

```
>> fitAndPlotAll
```

By default, all figures will be written to `data/plots/example`.

## Requirements

Should work on any version of Matlab from 2013a onwards. (Tested on Matlab 2015a, 2016a, 2017b, and 2018a on Mac, Matlab 2015a and 2018a on Linux, and Matlab 2013a on Windows.)

To generate figures as pdfs, you will need to install [ghostscript](https://ghostscript.com/).
