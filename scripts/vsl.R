# PROJECT: GEP
# PURPOSE: GDP-adjusted VSL
# AUTHOR: Raahil Madhok

# ----------- SET-UP ----------------------------
# Directories
rm(list=ls())
ROOT <- '/Users/rmadhok/Dropbox/gep-aq/data'
setwd(ROOT)

# Load Packages
packages <- c('tidyverse')
pacman::p_load(packages, character.only = TRUE, install = FALSE)

#------------------------------------------------
# PREP DATA
#------------------------------------------------

# Read life expectancy
le <- read_csv('./raw/life_expectancy.csv') %>%
  select(slug, years) %>%
  rename(life_expectancy = years)

# Read median age
age <- read_csv('./raw/median_age.csv') %>%
  select(slug, years) %>%
  rename(median_age = years)

# Read real GDP
gdp <- read_csv('./raw/real_gdp_pc.csv') %>%
  select(slug, value, date_of_information) %>%
  rename(base_year = date_of_information,
         gdp_real = value) %>%
  mutate(gdp_real = as.numeric(gsub("[\\$,]", "", gdp_real)))

# Merge together
df <- inner_join(le, age, by='slug') %>%
  inner_join(gdp, by = 'slug')

#------------------------------------------------
# VSL CALCULATION
#------------------------------------------------

# Step 1: set USA vsl
vsl_usa <- 9900000

# Step 2: USA life years lost
lll_usa <- df$life_expectancy[df$slug == 'united-states'] - df$median_age[df$slug == 'united-states']

# Step 3: USA GDP
gdp_usa <- df$gdp_real[df$slug == 'united-states']

# Step 4: USA intermediates
vsl_lll_usa <- vsl_usa / lll_usa # vsl-per-life year lost
vsl_lll_gdp_usa <- vsl_lll_usa / gdp_usa # vsl-per-life year lost to GDP ratio

# Step 5: VSL for all countries
df$lll = df$life_expectancy - df$median_age
df$vsl = df$gdp_real * df$lll * vsl_lll_gdp_usa
  



