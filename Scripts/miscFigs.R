require(ggplot2)

# Figure to show relationship between density and PPS
# Requires PPS transformed to df called means, as in PAMPwrProject.Rmd
mod <- glm(log(Total) ~ log(DENSITY), data = total)
pred.grid <- data.frame("DENSITY"=seq(0.0004, 3.06, by=0.0001))
p.vals <- predict(mod, pred.grid, se.fit=TRUE)
pred.grid$PPS <- p.vals$fit
pred.grid$LCI <- pred.grid$PPS - (1.96*as.numeric(p.vals$se.fit))
pred.grid$UCI <- pred.grid$PPS + (1.96*as.numeric(p.vals$se.fit))

ggsave("./Figures/DensityVsPPS.pdf",
ggplot()+
  geom_point(data=total, aes(x=DENSITY, y=log(Total)))+
  geom_line(data=pred.grid, aes(x=DENSITY, y=PPS))+
  geom_ribbon(data=pred.grid, aes(x=DENSITY, ymin = LCI, ymax=UCI), alpha=0.1)+
 # xlim(c(0,3.1))+
#  ylim(c(4, 12.5))+
  xlab("Mean Predicted Porpoise Density")+
  ylab("Log Total PPS Observed")+
  theme_bw(),
 height=4, width=4, units="in")

# Figure to show the impact of decline on moorings
ggsave("./Figures/PPSReduction.pdf", 
ggplot()+
  geom_point(data=subset(df, MOORING==1), aes(x=as.factor(YEAR), y=PPSorig))+
  geom_point(data=subset(df, MOORING==1), aes(x=as.factor(YEAR), y=PPS), 
             color="red", fill="red", shape=25)+
  ylim(c(0, 600))+
  xlab("YEAR")+
  ylab("Simulated PPS")+
  theme_bw(),
height=4, width=4, units="in")

# Figure to show simulated non-uniform decline
r.df <- data.frame("YEAR"=1:10, "P"=cum.r)
ggsave("./Figures/NonunifDecline.pdf",
ggplot(r.df, aes(x=as.factor(YEAR), y=P))+
  geom_point()+
  ylim(c(0,1))+
  xlab("Year")+
  ylab("Proportion of Original Population")+
  theme_bw(),
height=4, width=4, units="in")

# GIF of decline towards core habitat with full coverage of sensors
source("./Scripts/simSpatial.R")
new.data <- simSpatial(n = nrow(gridOut), y = 10, r = -.5, b = 0)
load("./Data/coastXY.RData")
require(animation)
saveGIF(
for (i in 1:y){
p <- ggplot()+
  ggtitle(paste("Year", i, sep=" "))+
  geom_point(data=subset(new.data, YEAR==i), 
             aes(x=X/1000, y=Y/1000, color=PPS, alpha=PPS), size=1.25, stroke=0)+
  geom_point(data=subset(new.data, YEAR==i & PPS>2000), 
             aes(x=X/1000, y=Y/1000, color=PPS), size =1.5, alpha=1, stroke=0)+
  geom_polygon(data=coast, aes(x=X/1000, y=Y/1000), fill="gray")+
  scale_size_continuous(range=c(0.5, 2), limits=c(0, max(new.data$PPS)), guide="none")+
  scale_alpha_continuous(range=0.75, 1, limits=c(0, max(new.data$PPS)), guide="none")+
  scale_color_gradient2(low="dodgerblue2", mid="yellow", high="red",
                        midpoint=(max(new.data$PPS)/2), 
                        limits=c(0, max(new.data$PPS)))+
  theme_bw()+
  coord_equal(xlim=c(-50, 50), ylim=c(-50, 50))+
  xlab("X (km)")+
  ylab("Y (km)")+
  theme(panel.grid.major=element_blank(), 
        panel.grid.minor=element_blank(),
        legend.key=element_blank(),
        legend.title=element_text(face="bold", size=10),
        
        strip.background=element_blank(),
        panel.margin=unit(1.25, "lines"),
        legend.key.height=unit(c(1.25), "lines"),
        plot.margin=unit(c(2, 0, 0, 0), "lines"),
        legend.position=c(0.1, 0.2))+
  theme(plot.title = element_text(face="bold"))
print(p)
}, movie.name="./Figures/PPS.gif")

depth <- c(93,93, 93, 247, 247, 247, 98, 98, 63, 63, 
           68, 68, 68, 155, 155,155, 105, 105, 80, 80, 80, 
           223, 223, 223, 200, 200, 200, 95, 95, 95)/3.28
total$D <- depth*-1

par(mfrow=c(2,1))
plot(total$D, total$Total, xlab="Water Depth (m)", ylab="Total PPS", pch=19, xlim=c(-150,0))
hist(si.data$Depth, xlim=c(-150,0), col="gray", main=NA,
     xlab="Water Depth (m)", ylab="No. Sightings", breaks=seq(0,-1000, by=-10))
