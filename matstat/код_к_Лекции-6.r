############################ Лекция - 6 ##########################
# задача о 3 группах испытуемых с различным образом жизни (по 26 человек)
x.g<-c(11.5, 10.1, 9.1) # средние значения признака по группам
x.s<-c(1.3,2.1,2.4) # выборочные стандартные отклонения по группам

(X<-mean(x.g))
(MSB<-sum((x.g-X)^2)*26/2)
(MSW<-sum(x.s^2)*25/75)
(dfB<-3-1)
(dfW<-78-3)
MSB/MSW
qf(0.95, 2, 75) # F-распределения при этих степенях свободы и при alpha = 0.05.
qf(0.99, 2, 75)
pf(9.56, 2, 75, lower=FALSE)

#попарные сравнения
t1<-x.g[1]-x.g[3]
t2<-x.g[2]-x.g[3]
t3<-x.g[1]-x.g[2]
Ss1<-sqrt((x.s[1]^2+x.s[3]^2)/26)
Ss2<-sqrt((x.s[2]^2+x.s[3]^2)/26)
Ss3<-sqrt((x.s[1]^2+x.s[2]^2)/26)
t1/Ss1
t2/Ss2
t3/Ss3
qt(.975, df=50)
qt(.983, df=50)
dt(c(t1/Ss1,t2/Ss2,t3/Ss3), df=50, log = FALSE)

#Пример: содержание стронция (мг/мл) в пяти водоемах США
waterbodies <- data.frame(Water = rep(c("Grayson", "Beaver",
                                        "Angler", "Appletree",
                                        "Rock"), each = 6),
                          Sr = c(28.2, 33.2, 36.4, 34.6, 29.1, 31.0,
                                 39.6, 40.8, 37.9, 37.1, 43.6, 42.4,
                                 46.3, 42.1, 43.5, 48.8, 43.7, 40.1,
                                 41.0, 44.1, 46.4, 40.2, 38.6, 36.3,
                                 56.3, 54.1, 59.4, 62.7, 60.0, 57.3)
)
M <- aov(Sr ~ Water, data = waterbodies)
summary(M)
TukeyHSD(M) # критерий Тьюки
plot(TukeyHSD(M), las = 1)

data <- data.frame(technique = rep (c("control", "new1", "new2"), each = 10 ),
                   score = c(76, 77, 77, 81, 82, 82, 83, 84, 85, 89,
                             81, 82, 83, 83, 83, 84, 87, 90, 92, 93,
                             77, 78, 79, 88, 89, 90, 91, 95, 95, 98))
boxplot(score ~ technique,
        data = data,
        main = "Экзаменационные баллы в зависимости от методики",
        xlab = "Методика обучения",
        ylab = "Экзаменационные баллы",
        col = c("green","blue","violet"),
        border = "black")

#fit the one-way ANOVA model
model <- aov(score ~ technique, data = data)
summary(model)
TukeyHSD(model) # критерий Тьюки
plot(TukeyHSD(model), las = 1)

library(DescTools) # реализован тест Даннета: множественные сравнения с контрольной группой

#fit the one-way ANOVA model
#model <- aov(score ~ technique, data = data)
#summary(model)
# тест Даннета, чтобы определить, какая методика обучения 
# дает средние экзаменационные баллы, отличные от 
# контрольной группы.

DunnettTest(x=data$score, g=data$technique)

?airquality
boxplot(Ozone  ~ Month, data = airquality)
DunnettTest(Ozone  ~ Month, data = airquality)
DunnettTest(Ozone  ~ Month, data = airquality, conf.level=0.99)
DunnettTest(Ozone ~ Month, data = airquality, control="8")

