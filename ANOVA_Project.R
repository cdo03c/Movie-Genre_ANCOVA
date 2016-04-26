##Setup working directory, import packages, and ingest data
setwd("~/Dropbox/Cuyler School/Applied Stats/STAT502/Project")
library(ggplot2)
library(multcomp)
df <- read.csv("./Project_Data.csv")

#Rescaling GrossUSD and EstBudgetUSD to millions of dollars
df <- within(df, {
  GrossUSD <- GrossUSD/1000000
  EstBudgetUSD <- EstBudgetUSD/1000000
})

#Feature engineering for profitability
df$profitUSD <- df$GrossUSD-df$EstBudgetUSD

#ANCOVA Regression Tests for Differences in Genre

#Regression test for Rating vs. GrossUSD with plot
g <- ggplot(df, aes(y = Rating, x = GrossUSD, shape = Genre, color = Genre))
g <- g + geom_point() + geom_smooth(method="lm", fill=NA)
g <- g + xlab("Gross Domestic Ticket Sales in millions of USD")
g <- g + ylab("IMDB Average User Rating")
g <- g + ylim(5,9) + xlim(0, 550)
g

for(i in unique(df$Genre)){
  print(paste("Movie Genre", i, sep = " "))
  sub <- df[df$Genre == i,]
  fit1 <- lm(Rating ~ GrossUSD, sub)
  print(summary.lm(fit1))
}

#Due to the significant positive slope for Action movies and GrossUSD we test
#if all the slopes are equal with a significant interaction variable
df.anova1 <- aov(Rating ~ Genre * GrossUSD, df)
anova(df.anova1)

#Regression test for Rating vs. profitUSD with plot
g <- ggplot(df, aes(y = Rating, x = profitUSD, shape = Genre, color = Genre))
g <- g + geom_point() + geom_smooth(method="lm", fill=NA)
g <- g + xlab("Profit from Domestic Ticket Sales in USD")
g <- g + ylab("IMDB Average User Rating")
g <- g + ylim(5,9) + xlim(0, 400)
g

for(i in unique(df$Genre)){
  print(paste("Movie Genre", i, sep = " "))
  sub <- df[df$Genre == i,]
  fit1 <- lm(Rating ~ profitUSD, sub)
  print(summary.lm(fit1))
}

#The results for profitUSD are similiar to GrossUSD and profitUSD so we tested
#for correlation and decided to drop profitUSD because it was 83% correlated to 
#GrossUSD.
cor.test(df$GrossUSD, df$profitUSD)

#Regression test for Rating vs. Year with plot
g <- ggplot(df, aes(y = Rating, x = Year, shape = Genre, color = Genre))
g <- g + geom_point() + geom_smooth(method="lm", fill=NA)
g <- g + xlab("Year Movie was Released")
g <- g + ylab("IMDB Average User Rating")
g <- g + ylim(5,9) + xlim(1975, 2016)
g

for(i in unique(df$Genre)){
  print(paste("Movie Genre", i, sep = " "))
  sub <- df[df$Genre == i,]
  fit1 <- lm(Rating ~ Year, sub)
  print(summary.lm(fit1))
}

#There is one significant linear relationship between grossUSD and movie ratings
#and a significant interaction term so we proceed with an unequal slopes ANCOVA
#model

df.fit <- lm(Rating ~ Genre + Genre* GrossUSD-1, df)
summary(df.fit)

#The follwing section presents the lsmeans difference in ratings for the three
#genres at three different levels of GrossUSD: 50, 150, and 250 million USD
levels <- data.frame(GrossUSD = seq(50, 250, 100))
fit<- lm(Rating ~ GrossUSD, df[df$Genre == "Action",])
action.ratings <- predict.lm(fit.action, newdata = levels)

fit <- lm(Rating ~ GrossUSD, df[df$Genre == "Drama",])
drama.ratings <- predict.lm(fit, newdata = levels)

fit <- lm(Rating ~ GrossUSD, df[df$Genre == "Comedy",])
comedy.ratings <- predict.lm(fit, newdata = levels)

print("The differences in the predicted average user rating between drama and action at the three levels:")
print(drama.ratings-action.ratings)

print("The differences in the predicted average user rating between drama and comedy at the three levels:")
print(drama.ratings-comedy.ratings)

print("The differences in the predicted average user rating between action and comedy at the three levels:")
print(action.ratings-comedy.ratings)
