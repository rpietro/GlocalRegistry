#######################################################################################
#template_secondary_data_analysis.R is licensed under a Creative Commons Attribution - Non commercial 3.0 Unported License. see full license at the end of this file.
#######################################################################################

#####################################################################################
#SETTING ENVIRONMENT
#####################################################################################
rm(list = ls())
ls()
detach()

library("ggplot2")
library("car")
#####################################################################################
#IMPORTING DATA AND RECODING
#####################################################################################


glocal.data <- read.csv("/Users/rpietro/Google Drive/R/nonpublicdata_publications/katia_registry/registry.csv")

View(glocal.data)

#below will list variable names, classes (integer, factor, etc), alternative responses
str(templateData)
#list variable names so that they can be used later
names(templateData)
#below will attach your data so that when you execute a command you don't have to write the name of your data object over and over again
attach(templateData)

#function below is used to recode variables. things to notice: replace old.var with the variable you are recoding, replace new.var with the variable you want to create. the whole recoding happens within " ". all character and factor variables will be within '', numbers will be displayed with digits (not inside '') or NA (also without ''). see video at http://goo.gl/aDgo4 for more details

new.var  <- car::recode(old.var, " 1:2 = 'A'; 3 = 'C'; '' = NA; else = 'B' ")

###########################################################################################
#TABLE 1: DEMOGRAPHICS
###########################################################################################
#describes your entire dataset
describe(templateData)

summary(variable)
qplot(variable)

#t.test, where outcome is a continuous variable and predictor is a dichotomous variable
t.test(outcome~predictor)

#chi square test where both outcome and predictor are categorical variables
CrossTable(outcome, predictor, chisq=TRUE, missing.include=TRUE, format="SAS", prop.r=FALSE)


########################################################################################
# TABLE WITH MODELS
########################################################################################

logisticmodel1  <- glm(outcome ~ predictor + confounder,family=binomial(link="logit"))
summary(logisticmodel1) #gives you model results
coefficients(logisticmodel1) # model coefficients
confint(logisticmodel1, level=0.95) # CIs for model parameters 
fitted(logisticmodel1) # predicted values
residuals(logisticmodel1) # residuals
influence(logisticmodel1) # regression diagnostics
layout(matrix(c(1,2,3,4),2,2)) # creates the white space for 4 graphs/page 
plot(logisticmodel1) #generates 4 graphs/page

survivalmodel1 <- coxph(Surv(time_to_event, event_yes_no) ~ predictor + confounder1 + confounder2, ties="efron")
#below will test for proportional hazards assumption
prop.assump1 <- cox.zph(survivalmodel1) 
print(prop.assump1) #display results for assumption 
plot(prop.assump1)  #plot curves -- from the help page: "If the proportional hazards assumption is true, beta(t) will be a horizontal line. The printout gives a test for slope=0."
#summary results for the model
summary(survivalmodel1)

#######################################################################################
#template_secondary_data_analysis.R is licensed under a Creative Commons Attribution - Non commercial 3.0 Unported License. You are free: to Share — to copy, distribute and transmit the work to Remix — to adapt the work, under the following conditions: Attribution — You must attribute the work in the manner specified by the author or licensor (but not in any way that suggests that they endorse you or your use of the work). Noncommercial — You may not use this work for commercial purposes. With the understanding that: Waiver — Any of the above conditions can be waived if you get permission from the copyright holder. Public Domain — Where the work or any of its elements is in the public domain under applicable law, that status is in no way affected by the license. Other Rights — In no way are any of the following rights affected by the license: Your fair dealing or fair use rights, or other applicable copyright exceptions and limitations; The author's moral rights; Rights other persons may have either in the work itself or in how the work is used, such as publicity or privacy rights. Notice — For any reuse or distribution, you must make clear to others the license terms of this work. The best way to do this is with a link to this web page. For more details see http://creativecommons.org/licenses/by-nc/3.0/
#######################################################################################
