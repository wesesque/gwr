plot.gwselect = function(model, part='coef', var=NULL, type='fitted', locs=NULL, polygons=NULL, s=NULL, group='group', title='', borderlines=NULL, by.locs=NULL, by.polygons=NULL) {
    #Prepare something for plotting:
    name.var = var

    if (is.null(polygons)) {
        #Plot on a regular grid using locs
    } else {
        if (is.null(locs)) {
            locs = model[['coords']]
            locs = unique(locs)   
            output = sapply(1:nrow(locs), function(k) {model[['model']][['models']][[k]][[part]][name.var,]})
        } else {
            #Generate the output at the given locs
            locs = unique(locs)   
        }             

        #Merge the polygons with the locs:
        mergedata = data.frame()
        for (k in unique(polygons[,group])) {
            id = which(point.in.polygon(pol.x=polygons[polygons[,group]==k,1], pol.y=polygons[polygons[,group]==k,2], point.x=locs[,1], point.y=locs[,2])==1)
            if (length(id)==1) {
                shape = polygons[polygons[,group]==k,]
                shape = cbind(shape, id, output=output[id])
                mergedata = rbind(mergedata, shape)
            }
        }

        #Draw the map
        map <- ggplot(mergedata, aes(long,lat,group=group)) + geom_polygon(aes(fill=output))
        map <- map + scale_fill_gradient2(low = muted("blue"), mid = "white", high = "orange", limits=range(mergedata$output, na.rm=TRUE), name='coef') + coord_map(project='globular')   
        map <- map + opts(panel.background=theme_rect(fill='green', colour='red'))
        
        #Annotate the map with borderlines
        if (!is.null(borderlines)) {map <- map + geom_path(data=borderlines, colour='white', size=0.75)}

        #Plot the map
        map + opts(title=title) #+ guides(fill=guide_legend(reverse=TRUE))
    }
}