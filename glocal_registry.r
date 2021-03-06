#######################################################################################
# Example Using R with DATASUS
#######################################################################################

#####################################################################################
#SETTING ENVIRONMENT
#####################################################################################
rm(list = ls())
ls()

library("ggplot2")
library("RMySQL")

#####################################################################################
#IMPORTING DATA AND RECODING
#####################################################################################

######### if you are using MYSQL DATA BASE

# Here, you can specify user authentication parameters through a MySQL default.file

strPath <- "/Users/Administrator/Documents/Projects/R/Pacemaker/"
strConf <- "susdb.cnf"

# Create a Connection

con <- dbConnect(MySQL(), group = "susdb" , default.file= paste( strPath , strConf , sep="") )


sql <- "select  N_AIH, ANO_CMPT , MES_CMPT , DT_INTER, DT_SAIDA, DIAS_PERM, MUNIC_RES , 
                tab.UF, tab.nm_municipio, CEP , NASC , IDADE, SEXO , PROC_REA , DIAG_PRINC, DIAG_SECUN , 
                VAL_SH, VAL_SP , VAL_TOT , US_TOT 
          from T2010 aih , censodb.tab_municipio tab 
         where proc_rea in ( '0406010650', '0406010684')  
           and aih.munic_res = substr(tab.cd_municipio,1,6);"

df <- dbGetQuery( con , sql)

head( df)

## Tips to use dbAply() -- > http://goo.gl/AXhSM

dbDisconnect(con)

## Summary by group UF

tapply(df$VAL_TOT, df$UF, summary)




#######################################################################################
#template_secondary_data_analysis.R is licensed under a Creative Commons Attribution - Non commercial 3.0 Unported License. see full license at the end of this file.
#######################################################################################

#####################################################################################
#SETTING ENVIRONMENT
#####################################################################################
rm(list = ls())
ls()
detach()

library(car)
library(ggplot2)
library(psych)
library(RCurl)
library(irr)
library(Hmisc)
library(gmodels)
library(qpcR)
library(plyr)
library(reshape)
library(catspec)
library(vcd)
library(Hmisc)
library(VIM)

#####################################################################################
#IMPORTING DATA AND RECODING
#####################################################################################


glocal.data <- read.csv("/Users/rpietro/Google Drive/R/nonpublicdata_publications/katia_registry/registry.csv")

#below is Katia's path, need to change to another directory once has a directory dedicated to R
safelv_pace <- read.csv("/Users/katiasilva/Documents/R Program/Safe_LVPace/safelv_pace.csv")

#below will view data in a spreadsheet format
View(safelv_pace)

#below will attach your data so that when you execute a command you don't have to write the name of your data object over and over again
attach(safelv_pace)

#list variable names so that they can be used later
names(safelv_pace)


#below will list variable names, classes (integer, factor, etc), alternative responses
str(safelv_pace)

# patient_id                            : int  1 2 3 4 5 6 7 8 9 10
 # screening_date                        : Factor w/ 10 levels "6/11/12","6/25/12",..: 1 2 8 3 4 5 6 7 10 9
 # patient_initials                      : Factor w/ 10 levels "CCB","EBO","ESS",..: 7 4 2 5 6 8 10 1 3 9
 # inclusion_criteria___1                : int  1 1 1 1 1 1 1 1 1 1
 # inclusion_criteria___2                : int  1 1 1 1 1 1 1 1 1 1
 # inclusion_criteria___3                : int  1 1 1 1 1 1 1 0 1 1
 # inclusion_criteria___4                : int  0 0 0 0 0 0 0 1 0 0
 # inclusion_criteria___5                : int  1 1 1 1 1 1 1 1 1 1
 # inclusion_criteria___6                : int  1 1 1 1 1 1 1 1 1 1
 # exclusion_criteria___1                : int  0 0 0 0 0 0 0 0 0 0
 # exclusion_criteria___2                : int  0 0 0 0 0 0 0 0 0 0
 # exclusion_criteria___3                : int  0 0 0 0 0 0 0 0 0 0
 # exclusion_criteria___4                : int  0 0 0 0 0 0 0 0 0 0
 # exclusion_criteria___5                : int  0 0 0 0 0 0 0 0 0 0
 # exclusion_criteria___6                : int  0 0 0 0 0 0 0 0 0 0
 # exclusion_criteria___7                : int  0 0 0 0 0 0 0 0 0 0
 # exclusion_criteria___8                : int  0 0 0 0 0 0 0 0 0 0
 # exclusion_criteria___9                : int  0 0 0 0 0 0 0 0 0 0
 # exclusion_criteria___10               : int  1 1 1 1 1 1 1 1 1 1
 # creatinine                            : num  1.68 1.18 1.21 1.17 1.09 1.42 0.81 0.82 0.77 0.83
 # date_enrolled                         : Factor w/ 10 levels "6/11/12","6/25/12",..: 1 2 8 3 4 5 6 7 10 9
 # patient_med_record                    : Factor w/ 10 levels "13789157/F","2192344/F",..: 3 6 7 1 10 4 2 9 8 5
 # health_insurance_payor                : int  1 1 1 1 1 1 1 1 1 1
 # adress_city                           : Factor w/ 4 levels "Cotia","Itobe",..: 3 3 1 4 2 3 3 3 3 3
 # adress_state                          : Factor w/ 1 level "Sao Paulo": 1 1 1 1 1 1 1 1 1 1
 # zip_code                              : Factor w/ 10 levels "","01046-001",..: 6 3 7 8 10 9 4 2 5 1
 # sex                                   : int  0 1 1 1 0 0 1 1 0 0
 # dob                                   : Factor w/ 10 levels "1/27/45","10/27/70",..: 10 3 1 6 7 4 2 8 9 5
 # age_enrollment                        : int  85 70 67 67 65 56 41 79 66 75
 # marital_status                        : int  3 2 2 2 2 2 1 1 1 1
 # have_children                         : int  1 NA NA 1 NA NA 0 0 1 0
 # num_children                          : int  NA NA NA 3 NA NA NA NA 2 NA
 # race                                  : int  0 0 0 0 0 2 0 0 0 0
 # ethnicity                             : int  0 0 0 0 0 0 0 0 0 0
 # professional_category                 : int  14 21 21 21 14 NA 15 21 14 13
 # occupation                            : Factor w/ 10 levels "","Cuidadora",..: 10 8 9 5 4 1 7 3 6 2
 # level_education___1                   : int  0 0 0 0 1 0 0 0 1 0
 # level_education___2                   : int  0 0 0 0 0 0 0 0 0 0
 # level_education___3                   : int  1 0 1 0 0 0 1 0 0 1
 # level_education___4                   : int  0 0 0 1 0 1 0 0 0 0
 # level_education___5                   : int  0 1 0 0 0 0 0 0 0 0
 # level_education___6                   : int  0 0 0 0 0 0 0 1 0 0
 # level_education___7                   : int  0 0 0 0 0 0 0 0 0 0
 # level_education___8                   : int  0 0 0 0 0 0 0 0 0 0
 # level_education___9                   : int  0 0 0 0 0 0 0 0 0 0
 # level_education___10                  : int  0 0 0 0 0 0 0 0 0 0
 # level_education___11                  : int  0 0 0 0 0 0 0 0 0 0
 # date_baseline_evaluation              : Factor w/ 10 levels "6/11/12","6/25/12",..: 1 2 8 3 4 5 6 7 10 9
 # functional_class_basal                : int  1 1 2 3 2 2 2 2 1 2
 # clinical_presentation___1             : int  0 0 0 1 1 0 0 0 0 1
 # clinical_presentation___2             : int  0 0 0 0 0 0 0 0 0 0
 # clinical_presentation___3             : int  0 1 1 0 0 0 1 0 0 1
 # clinical_presentation___4             : int  0 0 0 0 0 1 0 1 0 0
 # clinical_presentation___5             : int  0 0 0 0 0 0 0 0 0 0
 # clinical_presentation___6             : int  0 0 0 0 0 0 0 0 0 0
 # clinical_presentation___7             : int  0 0 0 1 0 0 0 0 0 0
 # clinical_presentation___8             : int  0 0 0 0 0 0 0 0 0 0
 # clinical_presentation___9             : int  1 0 0 0 0 0 0 0 0 0
 # clinical_presentation___10            : int  0 0 0 0 0 0 0 0 1 0
 # clinical_presentation___11            : int  0 0 0 0 0 0 0 0 0 0
 # clinical_presentation___12            : int  0 0 0 0 0 0 0 0 0 0
 # presentation_health_care              : int  3 1 9 1 8 8 8 8 8 1
 # etiology                              : int  1 1 1 1 1 NA 12 1 1 12
 # underlying_heart_disease              : int  11 11 11 NA 5 NA 3 NA NA 3
 # ecg_basal___1                         : int  0 0 0 0 0 0 0 0 0 0
 # ecg_basal___2                         : int  0 0 0 0 0 0 0 0 0 0
 # ecg_basal___3                         : int  0 0 0 0 0 0 0 0 0 0
 # ecg_basal___4                         : int  0 0 0 0 0 0 0 0 0 0
 # ecg_basal___5                         : int  0 0 0 0 0 0 0 0 0 0
 # ecg_basal___6                         : int  0 0 0 0 0 0 0 0 0 0
 # ecg_basal___7                         : int  0 0 0 0 1 0 0 0 0 0
 # ecg_basal___8                         : int  0 1 0 0 0 0 0 0 0 1
 # ecg_basal___9                         : int  1 0 1 0 0 1 1 0 1 0
 # ecg_basal___10                        : int  0 0 0 1 0 0 0 0 0 0
 # ecg_basal___11                        : int  0 0 0 0 0 0 0 0 0 0
 # ecg_basal___12                        : int  0 0 0 0 0 0 0 0 0 0
 # ecg_basal___13                        : int  0 0 0 0 0 0 0 0 0 0
 # ecg_basal___14                        : int  0 0 0 0 0 0 0 0 0 0
 # ecg_basal___15                        : int  0 0 0 0 0 0 0 0 0 0
 # ecg_basal___16                        : int  0 0 0 0 0 0 0 0 0 0
 # ecg_basal___17                        : int  0 0 0 0 0 0 0 0 0 0
 # ecg_basal___18                        : int  0 0 0 0 0 0 0 1 0 0
 # comorbid                              : int  1 1 0 1 1 1 1 1 1 1
 # history_cardiovascular___1            : int  0 0 0 0 0 0 0 0 0 0
 # history_cardiovascular___2            : int  0 0 0 0 0 0 0 0 0 0
 # history_cardiovascular___3            : int  0 0 0 0 0 0 0 0 0 0
 # history_cardiovascular___4            : int  0 0 0 0 0 0 0 0 0 0
 # history_cardiovascular___5            : int  0 0 0 0 0 0 1 0 0 1
 # history_cardiovascular___6            : int  0 0 0 0 0 0 0 0 0 0
 # history_cardiovascular___7            : int  0 0 0 0 0 0 0 0 0 0
 # history_cardiovascular___8            : int  0 0 0 0 0 0 0 0 0 0
 # history_cardiovascular___9            : int  0 1 0 1 1 1 0 1 1 0
 # history_cardiovascular___10           : int  0 0 0 0 0 0 0 0 0 0
 # history_cardiovascular___11           : int  0 0 0 0 0 0 0 0 0 0
 # history_cardiovascular___12           : int  0 0 0 0 0 0 0 0 0 0
 # history_cardiovascular___13           : int  0 0 0 0 0 0 0 0 0 0
 # history_cardiovascular___14           : int  0 0 0 0 0 0 0 0 0 0
 # history_cardiovascular___15           : int  0 0 0 0 0 0 0 0 0 0
 # history_cardiovascular___16           : int  0 0 0 0 0 0 0 0 0 0



#function below is used to recode variables. things to notice: replace old.var with the variable you are recoding, replace new.var with the variable you want to create. the whole recoding happens within " ". all character and factor variables will be within '', numbers will be displayed with digits (not inside '') or NA (also without ''). see video at http://goo.gl/aDgo4 for more details

new.var  <- car::recode(old.var, " 1:2 = 'A'; 3 = 'C'; '' = NA; else = 'B' ")


###############################################################################################
#To recode a continuous variable into a categorical one
###############################################################################################

#Examples

age_cat  <- car::recode(Age_PM_implantation, " 0:8 = 1; 8:22 = 2 ")
tabulate(age_cat)

time_cat <- car::recode(Time_under_pacing, " 0:12 = 1; 12:31 = 2 ")
tabulate(time_cat)

qrs_cat <- car::recode(Paced_QRS_duration, " 92:150 = 1; 150:260 = 2 ")
tabulate(qrs_cat)

feve_cat <- car::recode(Ejection_Fraction, " 29:61 = 1; 61:79 = 2 ")
tabulate(feve_cat)

nyha_cat <- car::recode(FC_NYHA_before._PM, " I = 1; II= 2 ")
tabulate(nyha_cat)


###################################################################################
#To recode a categorical variable into a numerical
###################################################################################

#Example
nyha_pre  <- car::recode(FC_NYHA_before._PM, " 'I' = 1; 'II' = 2; 'III'= 2; NA = NA; else = 3 ")
tabulate(nyha_pre)


###########################################################################################
#TABLE 1: DEMOGRAPHICS
###########################################################################################
#describes your entire dataset
describe(safelv_pace)

summary(variable)
qplot(variable)

#t.test, where outcome is a continuous variable and predictor is a dichotomous variable
t.test(outcome~predictor)

#chi square test where both outcome and predictor are categorical variables
CrossTable(outcome, predictor, chisq=TRUE, missing.include=TRUE, format="SAS", prop.r=FALSE)


#######################################################################################
#FIGURE - CARDIAC PACING MODE VS AGE AT FIRST PACEMAKER IMPLANTATION
#######################################################################################

#Examples
qplot(Type_PM, Age_PM_implantation, geom="boxplot", na.rm = TRUE)

#other option (with more details)
qplot(Type_PM, Age_PM_implantation, geom=c("boxplot", "jitter"), na.rm = TRUE)


##################################################################################
#DESCRIPTIVE ANALYSIS - QOL - SF-36
##################################################################################

#Use the same model for others QOL Questionnaires

summary(physical_functioning)
sd(physical_functioning, na.rm = TRUE)

summary(role_physical)
sd(role_physical, na.rm = TRUE)

summary(bodily_pain)
sd(bodily_pain, na.rm = TRUE)

summary(general_health)
sd(general_health, na.rm = TRUE)

summary(vitality)
sd(vitality, na.rm = TRUE)

summary(social_functioning)
sd(social_functioning, na.rm = TRUE)

summary(role_emotional)
sd(role_emotional, na.rm = TRUE)

summary(mental_health)
sd(mental_health, na.rm = TRUE)

summary(summary_physical_health)
sd(summary_physical_health, na.rm = TRUE)

summary(summary_mental_health)
sd(summary_mental_health, na.rm = TRUE)



###################################################################################
#FIGURE - QOL SCORES
###################################################################################

#Use the same model for others QOL Questionnaires

#SF36 Domains

#Examples
graphics.frame1 <- data.frame(physical_functioning, role_physical,bodily_pain, general_health, vitality, social_functioning, role_emotional, mental_health, summary_physical_health, summary_mental_health)
VALUE=rnorm(66) )

ggplot(melt(graphics.frame1), aes(x = variable, y = value)) + geom_boxplot() + xlab("SF-36 Domains") + ylab("Scores") + opts(axis.title.x = theme_text(size=12), axis.text.x  = theme_text(angle=10, hjust=0.8, size=10))                                                                     

#below will plot a continuous vs. a categorical variable
qplot(Type_PM, summary_physical_health, geom = "boxplot")

#below will plot a continuous variable
qplot(summary_physical_health, summary_mental_health) + geom_smooth(method = "loess", size = 2)

#below will plot two or more categorical variable
mosaicplot(~ Type_PM + Gender + Type_lead, main = "Survival on the Titanic")

table1  <- table(Type_PM, Gender, Type_lead)
mosaic(table1, shade=TRUE, legend=TRUE)


#######################################################################################
#ASSOCIATION BETWEEN QOL VS PATIENT CHARACTERISTICS 
#######################################################################################

#Use this examples for others QOL Questionnaires

#to measure an association between two categorical variables
CrossTable(Type_PM, Gender, chisq=TRUE, missing.include=TRUE, format="SAS", prop.r=FALSE) 

#to measure an association between a numeric and a categorical variable
summary (physical_functioning ~ Gender)
t.test(physical_functioning ~ Gender)

###################################################################################
#FUNCTIONAL EXERCISE CAPACITY - DESCRIPTIVE TABLE
####################################################################################

#To describe the distances during the 6MWD test
      
qplot(Walked_distance_m, Predicted_walked_distance) + geom_smooth(method = "loess", size = 2)
model10 <- lm(Walked_distance_m ~ Predicted_walked_distance)
summary(model10)
      
summary(Walked_distance_m)
summary(Predicted_walked_distance)
#cor(Walked_distance_m, Predicted_walked_distance)
      
model21  <- glm(Walked_distance_m ~ Type_PM + Gender, family=gaussian())
summary(model21)
      
model21  <- glm(Walked_distance_m ~ Type_PM, family=gaussian())
summary(model21)
      
summary(Walked_distance_m)
sd(Walked_distance_m, na.rm = TRUE)
      
summary(Predicted_walked_distance)
sd(Predicted_walked_distance, na.rm = TRUE)
      
#Predicted distance means the adjusted distance (by an equation) according patients'characteristics (age, height, weight )
      
summary (Walked_distance_m ~ Predicted_walked_distance)
t.test(Walked_distance_m ~ Predicted_walked_distance)
      
         
####################################################################################
# ASSOCIATION BETWEEN FUNCTIONAL EXERCISE CAPACITY VS PATIENT CHARACTERISTICS 
####################################################################################
            
#To compare Patient Characteristics vs walked_distance_m

summary (Walked_distance_m ~ Gender)
t.test(Walked_distance_m ~ Gender)

summary (Walked_distance_m ~ Cardiovascular_drugs)
t.test(Walked_distance_m ~ Cardiovascular_drugs)
            
summary (Walked_distance_m ~ Type_PM)
t.test(Walked_distance_m ~ Type_PM)      
            
summary (Walked_distance_m ~ Ventricular_dysfunction)
t.test(Walked_distance_m ~ Ventricular_dysfunction)

feve_cat <- car::recode(Ejection_Fraction, " 29:61 = 1; 61:79 = 2 ")
summary (Walked_distance_m ~ feve_cat) 
t.test (Walked_distance_m ~ feve_cat)




#######################################################################################
#template_secondary_data_analysis.R is licensed under a Creative Commons Attribution - Non commercial 3.0 Unported License. You are free: to Share — to copy, distribute and transmit the work to Remix — to adapt the work, under the following conditions: Attribution — You must attribute the work in the manner specified by the author or licensor (but not in any way that suggests that they endorse you or your use of the work). Noncommercial — You may not use this work for commercial purposes. With the understanding that: Waiver — Any of the above conditions can be waived if you get permission from the copyright holder. Public Domain — Where the work or any of its elements is in the public domain under applicable law, that status is in no way affected by the license. Other Rights — In no way are any of the following rights affected by the license: Your fair dealing or fair use rights, or other applicable copyright exceptions and limitations; The author's moral rights; Rights other persons may have either in the work itself or in how the work is used, such as publicity or privacy rights. Notice — For any reuse or distribution, you must make clear to others the license terms of this work. The best way to do this is with a link to this web page. For more details see http://creativecommons.org/licenses/by-nc/3.0/
#######################################################################################
