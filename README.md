# Monitoring trends and differences in COVID-19 case fatality rates using decomposition methods: A demographic perspective

Christian Dudel, Tim Riffe

Max Planck Institute for Demographic Research, Rostock, Germany

Contact: dudel@demogr.mpg.de

## Summary

COVID-19 has been spreading rapidly across the world. The case fatality rates (CFRs) associated with COVID-19 outbreaks in different countries, however, vary considerably. Moreover, the CFR is often based on cumulative case counts and death counts, and thus changes over time as the disease spreads. What is driving differences between countries and changes over time in the CFR is currently not well understood. 

We use demographic decomposition methods to disentangle two potential drivers of differences and trends: (1) the age structure of cases and (2) age specific case fatality rates. We provide numerous applications of this approach, covering Italy, Germany, South Korea, Spain, and Belgium. Among other things, we show that 50 percent of the difference between the CFR in Germany and in Italy can be explained with differences in the age structure of cases. Moreover, we show that increases in the Italian CFR over time are solely due to increasing age-specific CFRs and thus worsening health outcomes of those infected with COVID-19.   

## Introduction

The novel severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2), or Coronavirus disease 2019 (COVID-19) for short, has been spreading rapidly across the world, and on March 11 2020 was recognised as a pandemic by the World Health Organization.  

COVID-19 outbreaks went along with mostly regular patterns of logarithmic increase of case counts, with a few notable execptions. The number of deaths associated with COVID-19, however, have evolved considerably less regularly. 
For instance, as of March 24 2020, Germany had a total of around 27 thousand confirmed infections and 114 deaths, resulting in a case fatality rate (CFR) of around 0.4 percent [source]. Italy, on the other hand, up to the same day, had close to 64 thousand cases, around 6 thousand deaths, and a CFR of 9.5 percent. On March 16, Italy had roughly the same number of cases as Germany on March 24, and a CFR of 7.7 percent. Thus, the outbreak in Italy is going along with a much higher CFR, and Italys CFR increased over time. 

What is driving differences and trends such as these is currently not well understood. On the one hand, a higher CFR could mean that the risk of dying of COVID-19 differs between countries or changes over time. On the other hand, demographers have argued that age structure matters [1,2]. The age structure of infected cases will matter if the risk of dying varies with age, which is well documented for COVID-19 [reference]. If, for instance, in one country the disease mostly spreads among the young and in another country spreads among older individuals, and at the same time older individuals have a higher risk of dying, then CFRs will differ, even if age-specific fatality rates are the same in both countries. So far, there have been no assessments of the impact of the age structure of cases of infections, and the literature only provided qualitative assessments of the age structure of different populations to judge the potential severity of COVID-19 outbreaks.

In this paper, we use a demographic decomposition technique to disentangle two potential drivers of differences and trends: (1) the age structure of cases and (2) age-specific CFRs. The approach allows to specifically quantify what proportion of a difference of two CFRs can be attributed to age structure and what proportion can be attributed to age-specific CFRs. All data that is required are case counts and death counts by age groups. We provide numerous applications of this approach, covering data from Italy, Germany, South Korea, Spain, and Belgium. Our findings show, among other things, that differences between countries with low CFRs (Germany, South Korea) and countries with high CFRs (Italy, Spain) are driven up to 50% by differences in the age structure of cases.

To facilitate the application of the approach described in this paper, we provide code and reproducibility materials for the open source statistical software R.

## Methods

### Case fatality rates

The COVID-19 case fatality rate (CFR) is defined as the ratio of deaths associated with COVID-19 divided by the number of detected COVID-19 cases. Formally, if we denote with $D$ the total number of deaths associated with COVID-19 and with $N$ the total number of cases, then $$\textrm{CFR}=\frac{D}{C}.$$ 

If case counts and death counts are available by age, the CFR can also be written as a sum of age-specific CFRs weighted by the proportion of cases in a certain age group. We use $a$ as an index to denote different age groups, and $A$ to denote the total number of age groups. We define age-specific CFRs as $C_a=D_a/N_a$; i.e., the number of deaths in age group $a$ divided by the number of cases in the same age group. The proportion of cases in age group $a$ is given by $P_a=N_a/N$. Using this notation, the CFR can be written as a weighted average of age-specific CFRs: $$\textrm{CFR}=\sum P_a C_a.$$ 

### Decomposing CFRs

What we are ultimatively interested in is to decompose or "explain" the difference between two CFRs, irrespective of whether they are for two different countries, or for the same country at two different points in time, or for different groups within a country, e.g., socio-economic groups. We will use $\textrm{CFR}_i$ and $\textrm{CFR}_j$ to distinguish the two CFRs, e.g., country $i$ and country $j$. Moreover, we write $P_{ia}$, $C_{ia}$, $P_{ja}$, and $C_{ja}$ for the underlying age compositions and age-specific CFRs.  

Using a decomposition approach introduced by Kitagawa [3] we separate the difference between to CFRs into two distinct parts, $$\textrm{CFR}_i-\textrm{CFR}_j=\alpha + \delta,$$ where $\alpha$ captures the part of the difference between CFRs which is due to differences in the age composition of cases, and $\delta$ is due to differences in mortality. $\alpha$ is given by $$\alpha=0.5 \left(\textrm{CFR}_i-\sum P_{ja} C_{ia}+\sum P_{ia} C_{ja}-\textrm{CFR}_j \right),$$ while $\delta$ can be calculated as $$\delta=0.5 \left(\textrm{CFR}_i-\sum P_{ia} C_{ja}+\sum P_{ja} C_{ia}-\textrm{CFR}_j \right).$$


As an artificial example, assume that the CFR in country A is equal to 2 percent, while it equals 4 percent in country B. Subtracting the CFR of country A from country B gives a difference of 2 percentage points. If a large part of this difference would be due to the age structure, then $\alpha$ could be $0.015$ and $\beta$ could be $0.005$, together being equal to $0.02$ or 2 percentage points. If, as another example, two countries have the same age structure of cases, then $\alpha$ will be zero. Similar holds for $\beta$ if age-specific CFRs are the same for both countries under conisderation.

To calculate the proportion $\alpha$ and $\delta$ contribute to the total difference one can use $$\frac{|\alpha|}{|\alpha|+|\delta|}$$ in case of $\alpha$ and $$\frac{|\delta|}{|\alpha|+|\delta|}$$ for the contribution of $\delta$. In the previous example above, $\alpha$ explains $75%$ of the difference between the two CFRs. 

Note that the total difference between two CFRs as well as both $\alpha$ and $\beta$ can be negative, and the formula for the relative contribution takes this into account by using absolute values. If the total difference is positive and either $\alpha$ or $\beta$ are negative, it means that the corresponding part of the difference actually reduces the difference between CFRs. For instance, when comparing the CFR for one country at two points in time, the total difference could be $0.03$; i.e., the CFR increased by three percentage points. If in this case $\alpha$ would be negative, say $-0.01$, it would mean that the age distribution of cases over time got more similar. $\beta$ would be $0.04$ in this scenario, and without changes in the age distribution of infections as captured through $\alpha$, the difference between CFRs would even have increased by four percentage points.

## Data

We use data for the following countries:

* Germany, cumulative infections and deaths as of March 23 2020
* Italy, cumulative data as of March 16 2020 and March 19
* Spain, cumulative data as of March 22
* South Korea, cumulative data up to March 17

All data is reported by the respective health authorities, except for the death data for Germany, which is based on press reports of age at death collected on Wikipedia. For a few cases this data does not report age. For these cases it is imputed as being 80 or older.

The data is provided using different age groups. The following age groups are used in the original data for both case counts and death counts:

* Germany: 0-4, 5-14, 15-34, 35-59, 60-79, 80+  
* Italy: 0-9, 10-19, 20-29, 30-39, 40-49, 50-59, 69-69, 70-79, 80-89, 90+
* Spain: 0-9, 10-19, 20-29, 30-39, 40-49, 50-59, 69-69, 70-79, 80+
* South Korea: 0-9, 10-19, 20-29, 30-39, 40-49, 50-59, 69-69, 70-79, 80+

For the decomposition, the age groups have to match. This means that for some country comparisons age groups have to be aggregated. For instance, when comparing Germany with Italy, the data of both countries has to be aggregated to three age groups: below 60, 60-79, 80 and older. In contrast, this is not necessary when comparing Spain and South Korea, and to a much lesser extent when comparing Italy with the latter two, as in that case only for Italy the two age categories 80-89 and 90+ have to be combined.

## Results

Results can be output using the provided R code. Some examples are provided here.

## Discussion

Summary. Lorem ipsum dolorem iset. Lorem ipsum dolorem iset. Lorem ipsum dolorem iset. Lorem ipsum dolorem iset. Lorem ipsum dolorem iset. Lorem ipsum dolorem iset. Lorem ipsum dolorem iset. Lorem ipsum dolorem iset. 

Limitations. Testing. Aggregation. Lorem ipsum dolorem iset. Lorem ipsum dolorem iset. Lorem ipsum dolorem iset. Lorem ipsum dolorem iset. Lorem ipsum dolorem iset. Lorem ipsum dolorem iset. Lorem ipsum dolorem iset. Lorem ipsum dolorem iset.

Outlook. Lorem ipsum dolorem iset. Lorem ipsum dolorem iset. Lorem ipsum dolorem iset. Lorem ipsum dolorem iset. Lorem ipsum dolorem iset. Lorem ipsum dolorem iset. Lorem ipsum dolorem iset. Lorem ipsum dolorem iset.

## References

[1] Dowd, J., Rotondi, V., Andriano, L., Brazel, D. M., Block, P., Ding, X.,  Liu, Y., Mills, M. (20220). Demographic science aids in understanding the spread and fatality rates of COVID-19. OSF Preprint. https://osf.io/se6wy/?view_only=c2f00dfe3677493faa421fc2ea38e295

[2] Kashnitsky, I. (2020). COVID-19 in unequally ageing European regions. OSF Preprint. https://doi.org/10.31219/osf.io/abx7s.

[3] Kitagawa, E. M. (1955). Components of a difference between two rates.Journal of theAmerican Statistical Association, 50:1168–1194.

## Data sources

https://www.cdc.go.kr/board/board.es?mid=a30402000000&bid=0030&act=view&list_no=366578

https://www.epicentro.iss.it/coronavirus/bollettino/Bollettino%20sorveglianza%20integrata%20COVID-19_16%20marzo%202020.pdf

https://www.epicentro.iss.it/coronavirus/bollettino/Bollettino%20sorveglianza%20integrata%20COVID-19_19-marzo%202020.pdf

https://experience.arcgis.com/experience/478220a4c454480e823b17327b2bf1d4 

https://de.wikipedia.org/wiki/COVID-19-Pandemie_in_Deutschland/Todesf%C3%A4lle_mit_Einzelangaben_laut_Medien

https://www.mscbs.gob.es/profesionales/saludPublica/ccayes/alertasActual/nCov-China/documentos/Actualizacion_52_COVID-19.pdf
