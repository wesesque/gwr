## You should run poverty.r to generate the plots for this script.

#Import the county polygons
require(ggplot2)
require(gridExtra)
require(mapproj)

#If the 'brooks' package isnt loaded then import it from github:
if (!'package:brooks' %in% search()) {
    install_github('wesesque/brooks')
    require(brooks)
}

coef.map = list(pindpov='Proportion of individuals in poverty', 
    logitindpov='logit of proportion of individuals in poverty',
    pag='Coefficient of\nagricultural employment',
    pex='Coefficient of\nmining employment',
    pman='Coefficient of\nmanufacturing employment',
    pserve='Coefficient of\nservices employment',
    potprof='Coefficient of\nemployment in other professions',
    pwh='Coefficient of\nproportion white',
    pblk='Coefficient of\nproportion white',
    pind='Coefficient of\nproportion indigenous',
    phisp='Coefficient of\nproportion hispanic',
    metro='Coefficient of\nmetro area indicator',
    pfampov='Proportion of families in poverty',
    logitfampov='logit of proportion of families in poverty',
    pfire='Coefficient of employment in \nfinance, insurance, or real estate'
)


upper_midwest = c('illinois', 'indiana', 'iowa', 'michigan', 'minnesota', 'wisconsin')
county = map_data('county')
county = county[county$region %in% upper_midwest,]

#Establish lists to hold the plots:
plots = list()
plots[['GWEN']] = list()
plots[['GWAL']] = list()
plots[['GWR']] = list()

years = c(1970)
print(years)
for (yr in years) {
    ####Plot a choropleth of the results:    
    #Correct the locations of some small counties (only affect plotting)
	cluster_id = which(df$COUNTY=="WI_CLUSTER")
	n.counties = nrow(df)
    year = as.character(yr)

    for (select in c("GWAL", "GWEN", "GWR")) {
        #copy the model we will be plotting so we can alter it without affecting the original:
        mm = model[[select]][[year]]

        #Pepin county:
        mm[['coords']][df$STATE=='Wisconsin' & df$COUNTY=='PEPIN',] = c(-92.1048, 44.5823)

        #Shawano county:
        mm[['model']][['models']][[n.counties+1]] = mm[['model']][['models']][[cluster_id]]
        mm[['coords']] = rbind(mm[['coords']], c(-88.707733, 44.788658))

        #Oconto county:
        mm[['model']][['models']][[n.counties+2]] = mm[['model']][['models']][[cluster_id]]
        mm[['coords']] = rbind(mm[['coords']], c(-88.014221, 44.877282)) 
    
        plots[[select]][[year]] = list()
        if (select == 'GWR') {
            plotpart='coef'
        } else { 
            plotpart='coef.unshrunk'
        }
        for (v in predictors) {
            plots[[select]][[year]][[v]] = plot.gwselect(mm,
                part=plotpart,
                var=v,
                polygons=county,
                title=coef.map[[v]],
                legend.name="",
                col.bg='gray85') +
                scale_x_continuous('') +
                scale_y_continuous('') +
                theme(plot.margin=unit(c(0,0,0,0),'cm'), legend.margin=unit(0,'cm')) +
                theme(title=element_text(vjust=1))
        }

        #For the prelim slides
        pdf(paste('~/git/gwr/figures/practice-talk/', yr, '-', select, '-coefficients.pdf', sep=''), width=11, height=6)
        brooks::multiplot(plotlist=plots[[select]][[year]], cols=3)
        dev.off()

        #For the prelim paper
        pdf(paste('~/git/gwr/figures/poverty/', yr, '-', select, '-coefficients.pdf', sep=''), width=8, height=11)
        brooks::multiplot(plotlist=plots[[select]][[year]], cols=2)
        dev.off()
    }
}