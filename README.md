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
from github.


```r
install.github("unbrother/candmR")
```

It's also useful to install **candmR** with vignettes, which are help files that
describe the package functionality. This can be done by adding the build_vignettes
argument.

```r
install.github("unbrother/candmR", build_vignettes = TRUE)
```

## Usage

### MS2Soft Webscraping

The `ms2` group of functions from **canmR** are used to download traffic data from
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
