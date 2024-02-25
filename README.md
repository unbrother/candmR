# candmR

The **candmR** package contains a set of functions that perform several sub processes
frequently used within C&M Associates. It should be constantly mantained to add
more functionality depending on new methodologies or processed developed 
internally. The initial functionality allows for two different data gathering
methodologies: 

- The MS2Soft webscraping process 
- Google Maps Platform Directions API queries

## Installation

Since **candmR** is not on CRAN, the best way to install it is to get it directly
from github. **Note that the devtools package should be previously installed**


```r
devtools::install_github("unbrother/candmR")
```

It's also useful to install **candmR** with vignettes, which are help files that
describe the package functionality. This can be done by adding the build_vignettes
argument.

**Installing vignettes is preferred because documentation is self-enclosed**
**whithin the package files**

```r
devtools::install_github("unbrother/candmR", build_vignettes = TRUE)
```

Finally, users can look into the *C&M - Documents* Teams channel, within the 
*Data Scrapping* folder, for the built source package with .tar.gz extension.
The command to install from source is shown below, consider to change the **"path"**
part with the correct path from your system.

```r
install.packages('/candmR_0.1.0.tar.gz', repos=NULL, type='source')
```

## Usage

**Read these instructions first, along with the specialized vignettes corresponding to each of the workflows**

As mentioned, currently the candmR package can handle two sets of algorithms related
to internal processing within C&M Associates. Each algorithm requires to follow
certain preparation requisites that ensure the best functionality. Prepping to work
with either usually requires to set up a folder structure within a working directory
and creating an R project within. An incorrect folder structure might work, as many
functions are able to internally take a folder path different than the project 
directory, but having the same structure among all projects ensures the easiest 
approach, as well as reproducibility.

Each algorithm has its own kind of input files, but the main directive for the 
folder structure would be that the naming should not be as the algorithm, but the
analysis to be performed. So instead of naming a project directory as **ms2 data download**
it should be named, for example, **external stations**. Check your project's
naming conventions related to the use of underscores, numbering, etc.

Next, the basic structure of a directory should contain an inputs folder, an outputs
folder and a code folder. The inputs and outputs folder must be named as that 
(inputs/, outputs/), while the code folder is usually named R/ or source/ or code/, 
but the naming of this last folder does not interfere with functionality.

- The inputs folder contains the files needed for each algorithm to work, those files
have a certain structure which has to be kept in terms of contents, column names
and formatting.

- The outputs folder will store all processed outputs produced by executing functions
and should be the folder used to write all user generated outputs within the 
analysis.

- The code folder should contain the file or files with the script where the 
algorithm is executed.

- Finally, all directories will (should) have an R project file, which is a self-contained
structure that allows for the working directory to function properly. 

This folder structure ensures that the analysis is shareable and reproducible.

In addition, each algorithm contains a specific set of instructions that describe
the functionality and usage of the code. These usage documentation is separated
into two "chapters" for each of the algorithms, a preparation document and a 
basic usage document. Advance usage is omitted but can be explored by looking at
the documentation for each function. When vignettes are installed, users can
check their contents by navigating to the help page of the package or by using
the *vignette()* function:

```r
vignette("ms2soft_prep", package = "candmR")
```

Currently, the available vignettes are:

- *ms2soft_prep*
- *ms2soft*
- *travel_time_prep*
- *travel_time*

### MS2Soft Webscraping

The `ms2` group of functions from **candmR** are used to download traffic data from
the MS2Soft platform. Three analysis types can be performed separately:

- Permanent Station Analysis
- Vehicle Classification Analysis
- Short Term Station Analysis

Each type of analysis requires a different set of attributes to be set, which are 
automated for the most part. The most basic workflow, requires to create an inputs 
folder containing two files in .xlsx (MS Excel) format, one containing the attributes
of the analysis, which include the US State where the analysis will be performed,
the type of analysis, and other values required for the program to function.
See the MS2 related vignettes for instructions on how to prepare the data and how
to use the functions.

### Google Maps Directions API

The `tt` (for travel time) group of functions allow to communicate with the Google
Maps Platform and its Directions API to gather travel time data for highway segments
using a set of waypoints. 
The process requires to generate a geographic file (preferrably Google Earth's .kml)
containing the named waypoints, as well as a reference file containing the routes
that those waypoints describe, as well as the order in which they have to be followed.

The functions included follow a step by step process that starts by defining the 
times of day (TOD), the waypoints, and then creates a query request to the Google Maps
Platform.

Results can be exported in different ways, as a matrix of TOD by road segment and route,
as a database containing the results for all segments, and as a shapefile containing
the geographic representation of the routes, as well as their corresponding attribute
table.
See the Travel Time vignettes for instructions on how to prepare the data and hor
to use the functions.

## Getting help

Since this package is not on CRAN, there are two ways of getting help (related to the package):

1. Consult with other C&M Associates colleagues

1. Check with the authors
