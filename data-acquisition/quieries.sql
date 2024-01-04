-- 1 Create View of just Wgu Important Data, Also create AllHealthy and AllUnHealthy Features
CREATE VIEW wgu_view AS(
	SELECT
		patient.age,
		patient.gender,
		patient.hignblood AS highBlood,
		servicesaddon.overweight,
		servicesaddon.diabetes,
		CASE
			WHEN (servicesaddon.overweight = 'No')
			AND (servicesaddon.diabetes = 'No')
			AND (patient.hignblood = 'No')
			THEN 'Yes'
			ELSE 'No'
		END AS allHealthy,
		CASE
			WHEN (servicesaddon.overweight = 'Yes')
			AND (servicesaddon.diabetes = 'Yes')
			AND (patient.hignblood = 'Yes')
			THEN 'Yes'
			ELSE 'No'
		END AS allUnHealthy
	FROM patient
	NATURAL JOIN servicesaddon
);

-- 2 Create Table for DIA Data
CREATE TABLE IF NOT EXISTS dia (
	Id INTEGER PRIMARY KEY,
	Pregnancies INTEGER NOT NULL,
	Glucose INTEGER NOT NULL,
	BloodPressure INTEGER NOT NULL,
	SkinThickness INTEGER NOT NULL,
	Insulin INTEGER NOT NULL,
	BMI NUMERIC NOT NULL,
	DiabetesPedigreeFunction NUMERIC NOT NULL,
	Age INTEGER NOT NULL,
	Outcome INTEGER NOT NULL
);

-- 3 If the table exists set make us the owner
ALTER TABLE IF EXISTS dia OWNER to postgres;

-- 4 Import DIA Data from remote location
COPY dia(
	Id,
	Pregnancies,
	Glucose,
	BloodPressure,
	SkinThickness,
	Insulin,
	BMI,
	DiabetesPedigreeFunction,
	Age,
	Outcome
) FROM PROGRAM
'curl "https://docs.google.com/spreadsheets/d/1eoXsxpAGHLGDPXmbH5xhs1jmufM8XDfFqj4hxfh3cOU/gviz/tq?tqx=out:csv&sheet=Healthcare-Diabetes"'
WITH (
 FORMAT csv,
 HEADER true,
 ENCODING utf8
 );

-- 5 Create View of just DIA Important Data, Also create AllHealthy and AllUnHealthy Features
CREATE VIEW dia_view AS (
	SELECT
		age,
		gender,
		diabetes,
		overweight,
		highBlood,
		CASE
			WHEN (overweight = 'No')
			AND (diabetes = 'No')
			AND (highBlood = 'No')
			THEN 'Yes'
			ELSE 'No'
		END AS allHealthy,
		CASE
			WHEN (overweight = 'Yes')
			AND (diabetes = 'Yes')
			AND (highBlood = 'Yes')
			THEN 'Yes'
			ELSE 'No'
		END AS allUnHealthy
	FROM
		(
		-- Subquery converts features to match WGU features using industry standards
		SELECT
			age,
			'Female' AS gender,
			case when outcome = 1 then 'Yes' else 'No' end as diabetes,
			case when bmi > 24.9 then 'Yes' else 'No' end as overweight,
			case when bloodpressure > 80 then 'Yes' else 'No' end as highBlood
		FROM dia
	) AS subquery
);
