#!/bin/env R

library('XML')

# read the arguments
args <- commandArgs(trailingOnly = TRUE)
weather_url = args[1]
outfile = args[2]
outfile_dim_x = 264
outfile_dim_y = 176

weather_url = "http://www.yr.no/sted/Sverige/Uppsala/Uppsala/forecast_hour_by_hour.xml"
outfile = "current_weather.png"

# get the forecast
data = xmlParse(weather_url)
# data = xmlParse("http://www.yr.no/sted/Sverige/Uppsala/Uppsala/forecast_hour_by_hour.xml")
# data = xmlParse("http://www.yr.no/sted/Norge/S%C3%B8r-Tr%C3%B8ndelag/Trondheim/Trondheim/forecast_hour_by_hour.xml")
data = xmlToList(data)

# init
date = list()
temperature = list()
precipitation = list()

# convert it to a data.frame (how stupid is this?!)
for(i in 1:26){
	date = cbind(date, data$forecast$tabular[[i]]$.attrs[[1]])
	temperature = cbind(temperature, as.numeric(data$forecast$tabular[[i]]$temperature[2]))
	precipitation = cbind(precipitation, as.numeric(data$forecast$tabular[[i]]$precipitation[1]))
}
date = strptime(date, "%Y-%m-%dT%H:%M:%s")
temperature = unlist(temperature)
precipitation = unlist(precipitation)

### plot the data

# plot to png
png(file=outfile, width=outfile_dim_x, height=outfile_dim_y)

# init surface
par(mar=c(1.5,1.7,1.3,1))

# plot the precipitation
barplot(precipitation, xlab='', ylab='', bty='n', ylim=c(0, 3), axes=F, border=FALSE)

# plot the line on top of the boxes
par(new=TRUE)

# init plot surface
plot(1:length(date$hour),temperature, type='n', xlab='', ylab='', bty='n', ylim=c(min(temperature)-(max(temperature)-min(temperature))*0.2, max(temperature)), axes=F)

# plot the temperature line
lines(1:length(date$hour),temperature, col='black', lwd=3)


# plot the X axis
xlabels = c("", sprintf("%02d", date$hour[date$hour%%6==0]), "")
xat = c(0, which(date$hour%%6==0), length(temperature))
axis(side=1, at=xat, labels=xlabels, lwd=3, lend=1, cex.axis=1, padj=-0.8)


# plot the Y axis
yat = c(min(temperature)-(max(temperature)-min(temperature))*0.248, as.integer(seq(min(temperature), max(temperature), length.out=3)), max(temperature))
ylabels = c("", as.integer(seq(min(temperature), max(temperature), length.out=3)), "")
axis(side=2, at=yat, labels=ylabels, lwd=3, lend=1, cex.axis=1, padj=0.5, las=1, hadj=0.63)



# add axis text
mtext("24h Forecast of Uppsala", 3, font=2, cex=1, padj=0, adj=0.3)
mtext(strftime(Sys.time(), "%y%m%d"), 3, font=2, cex=1, padj=0, adj=1.03)
mtext("t", 1, padj=0, adj=1.04)
mtext(expression(~degree~C), 2, padj=-8, adj=1.1, las=1, cex=1.05)

# box(lwd=3)


dev.off()


