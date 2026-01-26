############################ Лекция - 8 ##########################
##### ANOVA повторных измерений ##################################
### вручную пример лечение // n=4,m=3 #######################################
(x<-read.table("clipboard", dec=",", h=T))
(xi<-rowMeans(x))
(Ti<-colMeans(x))
(X<-mean(xi))
Sw<-sum((x[1,]-xi[1])^2)
for (j in 2:4) Sw<-c(Sw,sum((x[j,]-xi[j])^2))
Sw
(ST<-sum((x-X)^2))
(SW<-sum(Sw))
(SB<-3*sum((xi-X)^2))
ST==(SB+SW)
(Sf<-4*sum((Ti-X)^2))
(Se<-SW-Sf)
(se<-Se/6) 
(sf<-Sf/2)
sf/se
qf(0.95, 2, 6) # F-распределения при этих степенях свободы и при alpha = 0.05.
qf(0.99, 2, 6)
pf(sf/se, 2, 6, lower=FALSE)


(Ti[1]-Ti[2])/sqrt(2*se/4)
(Ti[1]-Ti[3])/sqrt(2*se/4)
(Ti[3]-Ti[2])/sqrt(2*se/4)

qt(.992, df=6)
t.test(x$m1, x$m2, paired = TRUE)
wilcox.test(x$m1, x$m2, paired = TRUE)
####### Дисперсионный анализ по Краскелу-Уоллису ###############
#каждый участник эксперимента (M - мужчины (13 чел.), F0 - небеременные женщины (9 чел.), 
# F1 - беременные женщины (9 чел.)) принимал 250 мг кофеина, что соответствует примерно
#3 чашкам кофе, после чего дважды определяли концентрацию кофеина в крови и 
#рассчитывали T_1/2(период полувыведения). Результаты представлены в таблице:
(d.cofein<-read.table("clipboard", head=T, dec=","))
(N<-13+9*2)
(R<-(N+1)/2) # Общий средний ранг
attach(d.cofein)
(R1<-sum(RM)/13) # средний ранг по группе M
(R2<-sum(RF0, na.rm = T)/9) # средний ранг по группе F0
(R3<-sum(RF1, na.rm = T)/9) # средний ранг по группе F1
(D<-13*(R1-R)^2+9*(R2-R)^2+9*(R3-R)^2)
(H<-D*12/(N*(N+1)))
qchisq(p = 0.95, df = 2) # табличное значение критерия хи-квадрат

coffein<-c(M,F0[1:9],F1[1:9])
category <-c(rep("M",13),rep("F0",9),rep("F1",9))
cat.f<-as.factor(category)
plot(cat.f,coffein)
kruskal.test(coffein ~ cat.f)

#### Множественные попарные сравнения ######################## 
### Критерий Данна: #install.packages("FSA")

d.MF<-sqrt((1/13+1/9)*N*(N+1)/12)
d.FF<-sqrt((1/9+1/9)*N*(N+1)/12)
Q12<- (R2-R1)/d.MF # M vs F0
Q13<- (R3-R1)/d.MF # M vs F1
Q23<- (R3-R2)/d.FF # F0 vs F1


#perform Dunn's Test with Holm correction for p-values
library(FSA)
dunnTest(coffein ~ cat.f, method="holm")

(p3<-wilcox.test(coffein[1:22] ~ cat.f[1:22], paired = FALSE)$p.value )# M vs F0
(p2<-wilcox.test(coffein[14:31] ~ cat.f[14:31], paired = FALSE)$p.value  )# F1 vs F0
(p1<-wilcox.test(coffein[c(1:13,23:31)] ~ cat.f[c(1:13,23:31)], paired = FALSE)$p.value )# M vs F1

p.adjust(c(p1,p2,p3), method = "bonferroni")
p.adjust(c(p1,p2,p3), method = "holm")

#########  ТЕСТ Фридмана  ######################################################
# на данных из примера про Лсс (эксель)
data <- data.frame(person = rep(1:4, each=3),
                   times = rep(c(1, 2, 3), times=4),
                   press = c(22.2,5.4,10.6,17,6.3,6.2,14.1,8.5,9.3,17,10.7,12.3))
friedman.test(y=data$press, groups=data$times, blocks=data$person)

pairwise.wilcox.test(data$press, data$times, p.adj = "holm")

#набор данных, показывающий время реакции пяти пациентов на четыре разных препарата. 
#Поскольку каждый пациент измеряется на каждом из четырех препаратов, 
#нужно использовать тест Фридмана, чтобы определить, различается ли 
#среднее время реакции между препаратами.
data1 <- data.frame(person = rep(1:5, each=4),
                    drug = rep(c(1, 2, 3, 4), times=5),
                    score = c(30, 28, 16, 34, 14, 18, 10, 22, 24, 20,
                              18, 30, 38, 34, 20, 44, 26, 28, 14, 30))

#используем score в качестве переменной отклика, лекарство в качестве группирующей переменной
# и человека в качестве блокирующей переменной
friedman.test(y=data1$score, groups=data1$drug, blocks=data1$person)

#Для теста Фридмана подходящим апостериорным тестом является попарный критерий 
#суммы рангов Уилкоксона с поправкой Холма
# p.adj: метод корректировки p-значений; варианты включают holm, hochberg, hommel, bonferroni, BH, BY, fdr и ни один
pairwise.wilcox.test(data1$score, data1$drug, p.adj = "holm")




