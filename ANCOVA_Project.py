# -*- coding: utf-8 -*-
"""
Created on Tue Apr 26 09:37:25 2016

@author: obrien
"""

#import numpy as np
import pandas
#import matplotlib.pyplot as plt
from statsmodels.formula.api import ols
#from statsmodels.graphics.api import interaction_plot, abline_plot
from statsmodels.stats.anova import anova_lm

#Pull extracted IMDB movie data from the working directory or GitHub repo
try:
    ratings = pandas.read_csv('./Project_Data.csv')
except:
    print "fetching from Github"
    url = 'https://raw.githubusercontent.com/cdo03c/Movie-Genre_ANCOVA/master/Project_Data.csv'
    ratings = pandas.read_table(url)
    
#The data set contains the following variables:
#Movie is the title of the movie
#Year is the year that the movie was released in the US
#Rating is the average IMDB user rating
#Genre is the genre category for the movie
#EstBudgetUSD is the estimated budget for producing the movie
#GrossUSD is the gross US theater ticket sales in USD
    
#Rescaling GrossUSD and EstBudgetUSD to millions of dollars
ratings.GrossUSD = ratings.GrossUSD/1000000
ratings.EstBudgetUSD = ratings.EstBudgetUSD/1000000

#Feature engineering for profitability
ratings['ProfitUSD'] = ratings.GrossUSD-ratings.EstBudgetUSD
print ratings.ProfitUSD

##ANCOVA Regression Tests for Differences in Genre

#Regression tests for Rating vs. GrossUSD, ProfitUSD, and Year
#NOTE: I have not learned how to properly plot these effects so that part
#of the analysis has been omitted for now
for genre in set(ratings.Genre):
    print "Regression test for Average IMDB User Rating and GrossUSD for " + genre
    sub = ratings[ratings.Genre == genre]
    formula = 'Rating ~ GrossUSD'
    lm = ols(formula, sub).fit()
    print lm.summary()
    print
    print "Regression test for Average IMDB User Rating and ProfitUSD for " + genre
    formula = 'Rating ~ ProfitUSD'
    lm = ols(formula, sub).fit()
    print lm.summary()
    print    
    print "Regression test for Average IMDB User Rating and Year for " + genre
    formula = 'Rating ~ Year'
    lm = ols(formula, sub).fit()
    print lm.summary()
    print

#The results for profitUSD are similiar to GrossUSD and profitUSD so we tested
#for correlation and decided to drop profitUSD because it was 83% correlated to 
#GrossUSD.
#cor.test(df$GrossUSD, df$profitUSD)

#Due to the significant positive slope for Action movies and GrossUSD we test
#if all the slopes are equal with a significant interaction variable
formula = 'Rating ~ Genre * GrossUSD'
lm_interact = ols(formula, ratings).fit()
print lm_interact.summary()

formula = 'Rating ~ Genre + GrossUSD'
lm_nointer = ols(formula, ratings).fit()
print lm_nointer.summary()

#The interaction effect is significant for Genre and GrossUSD, which leads 
#to an unequal slopes ANCOVA model
table1 = anova_lm(lm_nointer, lm_interact)
print table1

#Here is the final linear model for the ANCOVA
formula = 'Rating ~ Genre * GrossUSD - 1'
lm = ols(formula, ratings).fit()
print lm.summary()

#NOTE: This test does not account for outliers because that was not part of the
#course project

