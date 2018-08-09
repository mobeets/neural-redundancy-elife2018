# Code for "Constraints on neural redundancy"
_Jay A. Hennig, Matthew D. Golub, Peter J. Lund, Patrick T. Sadtler, Emily R. Oby, Kristin M. Quick, Stephen I. Ryu, Elizabeth C. Tyler-Kabara, Aaron P. Batista*, Byron M. Yu*, Steven M. Chase*_

## Getting started

Add all experimental sessions (link to data coming soon) to the folder `data/sessions/`.

Now, to fit all sessions and generate figures, run the following:

```
>> fitAndPlotAll
```

By default, all figures will be written to `data/plots/example`.

## Requirements

Tested on Matlab 2015a and 2018a on both Mac and Linux. Will likely (hopefully!) work for any Matlab version after around 2011a.

To generate figures as pdfs, you will need to install [ghostscript](https://ghostscript.com/).
