# -*- coding: utf-8 -*-
"""
Created on Tue Apr 26 09:37:25 2016

@author: obrien
"""

import numpy as np
import pandas
import matplotlib.pyplot as plt
from statsmodels.formula.api import ols
from statsmodels.graphics.api import interaction_plot, abline_plot
from statsmodels.stats.anova import anova_lm

#Pull the data from the working directory or from the GitHub repo
#try:
 #   ratings = pandas.read_csv('./Project_Data.csv')
#except:
print "pulling from GitHub"
url = 'https://github.com/cdo03c/Movie-Genre_ANCOVA/blob/master/Project_Data.csv'
ratings = pandas.read_table(url)
    
print ratings