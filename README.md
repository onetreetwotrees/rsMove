## rsMove
Bridging Remote Sensing and Movement Ecology with R.

<br>

### 1. Why Develop rsMove?

<p align="justify">
In the scope of movement ecology, Global Positioning Systems (GPS) have evolved significantely offering an unique insight into the animal behavior. But understanding this behavior is dependent on our ability to compreeend the underlying environmental conditions that guides it. In this context, remote sensing becomes a fundamental tool. It provides information on the spatial and temporal variability of the landscape and provides us the means to understand the impact of environmental change over animal behavior. However, linking remote sensing and animal movement can be troublesome due to the differences in the spatial and temporal scales at which they are acquired (Figure 1). As a consequence, methods that are sensitive to the constraints imposed by remote sensing in the analysis of animal movement are required. <i>rsMove</i> Answers to this issue providing tools to query and analyze movement data using remote sensing.
</p>

<br>

<p align="center">
  <img width="566" height="291" src="http://media.springernature.com/full/springer-static/image/art%3A10.1186%2Fs40462-015-0036-7/MediaObjects/40462_2015_36_Fig1_HTML.gif">
</p>

<p align="center">
   Figure 1 - Scale differences between animal movement and remotely-sensed data (<a href="https://movementecologyjournal.biomedcentral.com/articles/10.1186/s40462-015-0036-7">Neuman et al, 2015</a>)  
</p>

<br>

### 2. Instalation
This gitHub is used as a basis for the improvement of *rsMove*. A stable release is avalible on CRAN and can installed with

```R
install.packages('rsMove')
```


#### 3. Example - Finding hotspots to find test sites
<p align="justify">
Within this section, we provide an example on the combine use of the functions  <i>sampleMove()</i> and  <i>hotMove()</i> for the identification of areas of interest that can serve as test sites. For this purpose, we rely on White Stork movement data (DOI: <a href="10.5441/001/1.78152p3q">10.5441/001/1.78152p3q</a>) which was colected by the Max Planck Institute for Ornithologie (MPIo) and is accessible through <a href="https://www.movebank.org/">MoveBank</a>.

</p>

#### 2.2. Example - Sampling in space time
<p align="justify">
This example describes the 
</p>

```R
moveData <- shapefile(system.file('extdata', 'konstanz_20130805-20130811.shp', package="rsMove"))
rsStack <- stack(list.files(system.file('extdata', '', package="rsMove"), 'tc.*tif', full.names=T))
rsQuery <- dataQuery(xy=moveData,img=rsStack)
```
<p align="justify">
Independently of our ability to select temporal information, remote sensing suffers from an old and inescapable evil: cloud cover.

NOTE: TALK ABOUT INTERPOLATION

</p>

### 3. Example - Sampling on the move




