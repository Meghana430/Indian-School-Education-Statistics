#1 What is the average percentage of primary-only schools with electricity across all
#states and union territories?
SELECT AVG(Primary_Only) 
FROM dropout_ratio.`percentage-of-schools-with-electricity-2013-2016`;

#2 Display the highest percentage of upper primary schools with secondary
#education facilities for each state or union territory for the year 2013(
SELECT `State/UT`, `Year`, MAX(`U_Primary_With_Sec`)  
FROM `dropout_ratio`.`percentage-of-schools-with-water-facility-2013-2016` 
WHERE `Year` LIKE '2013%'
GROUP BY `State/UT`, `Year`;

#3What was the growth rate(in percentage) of schools with secondary education
#facilities in each state/union territory from 2013 to 2016?
SELECT 
  `State_UT`, 
  `Year`, 
  `Sec_Only`,
  (
    (`Sec_Only` - LAG(`Sec_Only`, 1) OVER (PARTITION BY `State_UT` ORDER BY `Year`)) 
    / LAG(`Sec_Only`, 1) OVER (PARTITION BY `State_UT` ORDER BY `Year`)
  ) * 100 AS `Growth_Rate`
FROM 
  `dropout_ratio`.`percentage-of-schools-with-comps-2013-2016`;
  
#4  What percentage of schools in each state/union territory had girls' toilets in the
#year 2015?
SELECT `State_UT`, 
       AVG(`HrSec_Only` / `All Schools`) * 100 AS `AVG_HrSec_Only_Percentage` 
FROM `dropout_ratio`.`schools-with-girls-toilet-2013-2016`
WHERE `year` LIKE '2015%'
GROUP BY `State_UT`;


#5 What is the percentage of primary-only schools with electricity and computers for
#each state/union territory in the years 2013-2016?
SELECT 
  elec.`State_UT`,
  elec.`Year`,
  elec.`Primary_Only` AS PercentOfPrimaryOnlySchoolsWithElectricity,
  comps.`Primary_Only` AS PercentOfPrimaryOnlySchoolsWithComputers
FROM 
  `dropout_ratio`.`percentage-of-schools-with-electricity-2013-2016` elec
JOIN 
  `dropout_ratio`.`percentage-of-schools-with-comps-2013-2016` comps
ON 
  elec.`State_UT` = comps.`State_UT` AND elec.`Year` = comps.`Year`
ORDER BY 
  elec.`State_UT`, elec.`Year`;


#6What are the states/union territories and years where the Gross Enrollment Ratio (GER) for
#secondary education shows distinct gender patterns? How do the enrollment figures for boys
#(Boys_GER_Secondary) and girls (Girls_GER_Secondary) compare?
WITH RankedStates AS (
  SELECT
    `State_UT`,
    `Year`,
    `Secondary_Boys`,
    `Secondary_Girls`,
    ROW_NUMBER() OVER (PARTITION BY `State_UT`, `Year` ORDER BY `Secondary_Boys` DESC) AS Boys_Rank,
    ROW_NUMBER() OVER (PARTITION BY `State_UT`, `Year` ORDER BY `Secondary_Girls` DESC) AS Girls_Rank
  FROM
    `dropout_ratio`.`gross-enrollment-ratio-2013-2016`
)
SELECT
  `State_UT`,
  `Year`,
  `Secondary_Boys` AS `Boys_GER_Secondary`,
  `Secondary_Girls` AS `Girls_GER_Secondary`
FROM
  RankedStates
WHERE
  (Boys_Rank = 1 AND Girls_Rank = 1)
  OR (Boys_Rank = 1 AND Girls_Rank = 2)
  OR (Boys_Rank = 2 AND Girls_Rank = 1);


#7 What is the enrollment status of primary-only schools in terms of electricity access, and how has it
#changed over the years? Specifically, which states or union territories have seen an increase, decrease, or no
#change in the percentage of primary-only schools with electricity access compared to the previous year?
WITH EnrollmentChanges AS (
  SELECT
    `State_UT`,
    `Year`,
    `Primary_Only`,
    LAG(`Primary_Only`) OVER (PARTITION BY `State_UT` ORDER BY `Year`) AS Previous_Year_Primary_Only
  FROM
    `dropout_ratio`.`percentage-of-schools-with-electricity-2013-2016`
)
SELECT
  `State_UT`,
  `Year`,
  `Primary_Only`,
  CASE
    WHEN `Primary_Only` > Previous_Year_Primary_Only THEN 'Increase'
    WHEN `Primary_Only` < Previous_Year_Primary_Only THEN 'Decrease'
    ELSE 'No Change'
  END AS `Enrollment_Status`
FROM
  EnrollmentChanges;


#8 How has the availability of electricity and computers in Secondary-Only and Sec with Higher sec
# schools changed over the years 2014 to 2016?
SELECT 
  sub.`State_UT`,
  sub.`Year`,
  AVG(sub.`Sec_Only_Elec`) AS AvgSecOnlySchoolsWithElectricity,
  AVG(sub.`Sec_Only_Comps`) AS AvgSecOnlySchoolsWithComputers,
  AVG(sub.`Sec_with_HrSec_Elec`) AS AvgSecWithHrSecSchoolsWithElectricity,
  AVG(sub.`Sec_with_HrSec_Comps`) AS AvgSecWithHrSecSchoolsWithComputers
FROM 
  (SELECT
    elec.`State_UT`,
    elec.`Year`,
    elec.`Sec_Only` AS `Sec_Only_Elec`,
    comps.`Sec_Only` AS `Sec_Only_Comps`,
    elec.`Sec_with_HrSec.` AS `Sec_with_HrSec_Elec`,
    comps.`Sec_with_HrSec.` AS `Sec_with_HrSec_Comps`
  FROM 
    `dropout_ratio`.`percentage-of-schools-with-electricity-2013-2016` elec
  JOIN 
    `dropout_ratio`.`percentage-of-schools-with-comps-2013-2016` comps
  ON 
    elec.`State_UT` = comps.`State_UT` AND elec.`Year` = comps.`Year`
  WHERE 
    elec.`Year` BETWEEN '2014' AND '2016') AS sub
GROUP BY 
  sub.`State_UT`, sub.`Year`;

