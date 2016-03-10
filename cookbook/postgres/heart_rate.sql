-- --------------------------------------------------------
-- Title: Create a histogram of heart rates for adult patients
-- MIMIC version: MIMIC-III v1.3
-- Notes: this query does not specify a schema. To run it on your local
-- MIMIC schema, run the following command:
--  SET SEARCH_PATH TO mimiciii;
-- Where "mimiciii" is the name of your schema, and may be different.
-- --------------------------------------------------------

WITH agetbl AS
(
  SELECT ad.subject_id
  FROM admissions ad
  INNER JOIN patients p
  ON ad.subject_id = p.subject_id
  WHERE
  -- filter to only adults
  EXTRACT(EPOCH FROM (ad.admittime - p.dob))/60.0/60.0/24.0/365.242 > 15
  -- group by subject_id to ensure there is only 1 subject_id per row
  group by ad.subject_id
)

SELECT bucket, count(*)
FROM (SELECT width_bucket(valuenum, 0, 300, 301) AS bucket
      FROM chartevents ce
      INNER JOIN agetbl
      ON ce.subject_id = agetbl.subject_id
      WHERE itemid in (211,220045)) AS heart_rate
GROUP BY bucket
ORDER BY bucket;
