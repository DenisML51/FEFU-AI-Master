####### “очный тест ‘ишера #######################
fisher.test(cbind(c(1,3),c(3,1))) #  alternative = "two.sided"
fisher.test(cbind(c(1,3),c(3,1)), alternative = "less") 

###### “ест ћак-Ќемара \\ точный тест #################################
#install.packages("exact2x2")
library(exact2x2)

(d.exm<-read.table("clipboard", head=T, dec = ','))
(rez <- table( d.exm[,c("pre","post")] ))
mcnemar.test(rez) # тест ћак-Ќемара с поправкой Ёдвардса
mcnemar.test(rez, correct = FALSE)
mcnemar.exact(rez) # точный 

limf<-rbind(c(41,44),c(33,52))
(test<-chisq.test(limf))
mcnemar.test(rbind(c(37,7),c(15,26)))
mcnemar.exact(rbind(c(37,7),c(15,26)))

library(HSAUR2)
data(weightgain) 
#измерени€ прироста массы лабораторных крыс (weightgain) в четырех группах с
#разным характером питани€.  орма имели разное содержание белка (фактор type с двум€
#уровн€ми: низкое содержание Ц Low, и высокое содержание Ц High) и разное
#происхождение (фактор source с двум€ уровн€ми: beef Ц гов€дина, и cereal Ц злаки).
str(weightgain)
summary(weightgain)

library(ggplot2)
ggplot(data = weightgain, aes(x = type, y = weightgain)) +
  geom_boxplot(aes(fill = source))

aggregate(weightgain ~ type + source , weightgain, mean)
aggregate(weightgain ~ type + source , weightgain, sd)


# плана эксперимента
plot.design(weightgain) # 

with(weightgain, interaction.plot(x.factor = type,
                                  trace.factor = source,
                                  response = weightgain))
M1 <- aov(weightgain ~ source + type + source:type,
          data = weightgain)
summary(M1)

#### проверка адекватности применени€ ANOVA ###########################################

library(car) # qqPlot()
library(sm) # sm.density()

w<-rbind(weightgain[1:10,3],weightgain[11:20,3],weightgain[21:30,3],weightgain[31:40,3])
gr.s<-weightgain$source[c(1,11,21,31)]
gr.t<-weightgain$type[c(1,11,21,31)]
 
par(mfrow=c(2,4)) 
for(i in 1:4){
  qqPlot(w[i,], dist= "norm", pch=18, main=paste(gr.s[i], gr.t[i]))
  sm.density(w[i,], model = "Normal")
  print(paste(gr.s[i], gr.t[i], shapiro.test(w[i,])$p.value))
}
par(mfrow=c(1,1)) 

library(car)
st<-c(rep('BL',10), rep('BH',10), rep('CL',10), rep('CH',10))
weightgain<-cbind(weightgain,st)

bartlett.test(weightgain ~ st, data = weightgain)
leveneTest(weightgain ~ st, data = weightgain)
fligner.test(weightgain ~ st, data = weightgain)



