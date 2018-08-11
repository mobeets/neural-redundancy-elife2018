# Analysis code for "Constraints on neural redundancy"

__Paper__: Jay A. Hennig, Matthew D. Golub, Peter J. Lund, Patrick T. Sadtler, Emily R. Oby, Kristin M. Quick, Stephen I. Ryu, Elizabeth C. Tyler-Kabara, Aaron P. Batista*, Byron M. Yu*, and Steven M. Chase*. "Constraints on neural redundancy". _eLife_ (2018)

__Code author:__ Jay Hennig (jhennig@cmu.edu)

## Getting started

This codepack applies the analyses in the paper to the example experiment found in `data/sessions`. To generate all hypotheses' fits and the resulting figures, run the following:

```
>> fitAndPlotAll
```

By default, all figures will be written to `data/plots/example`. Note that in the paper, Figures 5 and 6 (and corresponding supplemental figures) are based on data from 42 experiments. We provide the code here to illustrate our analyses, and to facilitate those who wish to apply the same analyses to their own experiments.

## Requirements

This code should work on any version of Matlab from 2013a onwards. (Tested on Matlab 2015a, 2016a, 2017b, and 2018a on Mac, Matlab 2015a and 2018a on Linux, and Matlab 2013a on Windows.)

To generate figures as pdfs, you may need to install [ghostscript](https://ghostscript.com/).
