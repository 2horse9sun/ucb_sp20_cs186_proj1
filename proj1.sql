DROP VIEW IF EXISTS q0, q1i, q1ii, q1iii, q1iv, q2i, q2ii, q2iii, q3i, q3ii, q3iii, q4i, q4ii, q4iii, q4iv, q4v;

-- Question 0
CREATE VIEW q0(era) 
AS
  SELECT MAX(era) AS era FROM pitching
;

-- Question 1i
CREATE VIEW q1i(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear
  FROM people
  WHERE weight > 300
;

-- Question 1ii
CREATE VIEW q1ii(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear
  FROM people
  WHERE namefirst LIKE '% %'
;

-- Question 1iii
CREATE VIEW q1iii(birthyear, avgheight, count)
AS
  SELECT birthyear, AVG(height) AS avgheight, COUNT(*)
  FROM people
  GROUP BY birthyear
  ORDER BY birthyear
;

-- Question 1iv
CREATE VIEW q1iv(birthyear, avgheight, count)
AS
  SELECT birthyear, AVG(height) AS avgheight, COUNT(*)
  FROM people
  GROUP BY birthyear
  HAVING AVG(height) > 70
  ORDER BY birthyear
;

-- Question 2i
CREATE VIEW q2i(namefirst, namelast, playerid, yearid)
AS
  SELECT p.namefirst, p.namelast, p.playerid, h.yearid
  FROM people p LEFT OUTER JOIN HallofFame h
  ON p.playerid = h.playerid 
  WHERE h.inducted = 'Y'
  ORDER BY h.yearid DESC
;

-- Question 2ii
CREATE VIEW q2ii(namefirst, namelast, playerid, schoolid, yearid)
AS
  SELECT q2i.namefirst, q2i.namelast, q2i.playerid, schools_in_ca.schoolid, q2i.yearid
  FROM q2i,(
    SELECT c.playerid, s.schoolid FROM Collegeplaying c,Schools s
    WHERE c.schoolid = s.schoolid AND s.schoolstate = 'CA'
  ) AS schools_in_ca
  WHERE q2i.playerid = schools_in_ca.playerid
  ORDER BY q2i.yearid DESC,schools_in_ca.schoolid, q2i.playerid
;

-- Question 2iii
CREATE VIEW q2iii(playerid, namefirst, namelast, schoolid)
AS
  SELECT q2i.playerid, q2i.namefirst, q2i.namelast, tb.schoolid
  FROM q2i LEFT OUTER JOIN (
    SELECT c.playerid, s.schoolid FROM Collegeplaying c, Schools s
    WHERE c.schoolid = s.schoolid
  ) AS tb
  ON q2i.playerid = tb.playerid
  
  ORDER BY q2i.playerid DESC,tb.schoolid
;

-- Question 3i
CREATE VIEW q3i(playerid, namefirst, namelast, yearid, slg)
AS
  SELECT p.playerid, p.namefirst, p.namelast, b.yearid, CAST(CAST(1.0*((h-h2b-h3b-hr)+2*h2b+3*h3b+4*hr)/ab AS DECIMAL(32,16)) AS FLOAT) AS slg
  FROM people p, batting b
  WHERE p.playerid = b.playerid
  AND ab > 50
  ORDER BY slg DESC, b.yearid, p.playerid
  LIMIT 10
;

-- Question 3ii
CREATE VIEW q3ii(playerid, namefirst, namelast, lslg)
AS
  SELECT p.playerid, namefirst, namelast,
  tb.lslg
  FROM people p, (
    SELECT b.playerid, CAST(CAST(1.0*((SUM(h)-SUM(h2b)-SUM(h3b)-SUM(hr))+2*SUM(h2b)+3*SUM(h3b)+4*SUM(hr))/SUM(ab) AS DECIMAL(32,16)) AS FLOAT) AS lslg
    FROM batting b, (
      SELECT playerid, SUM(ab) AS lab 
      FROM batting
      GROUP BY playerid
    ) AS tb
    WHERE b.playerid = tb.playerid AND tb.lab > 50
    GROUP BY b.playerid
  ) AS tb
  WHERE p.playerid = tb.playerid
  ORDER BY lslg DESC, p.playerid
  LIMIT 10
;

-- Question 3iii
CREATE VIEW q3iii(namefirst, namelast, lslg)
AS
  SELECT namefirst, namelast, lslg
  FROM (
      SELECT p.playerid, namefirst, namelast,
    tb.lslg
      FROM people p, (
      SELECT b.playerid, CAST(CAST(1.0*((SUM(h)-SUM(h2b)-SUM(h3b)-SUM(hr))+2*SUM(h2b)+3*SUM(h3b)+4*SUM(hr))/SUM(ab) AS DECIMAL(32,16)) AS FLOAT) AS lslg
      FROM batting b, (
        SELECT playerid, SUM(ab) AS lab 
        FROM batting
        GROUP BY playerid
      ) AS tb
      WHERE b.playerid = tb.playerid AND tb.lab > 50
      GROUP BY b.playerid
    ) AS tb
      WHERE p.playerid = tb.playerid
  ) AS q1
  WHERE lslg > ALL(
    SELECT lslg FROM (
      SELECT p.playerid, namefirst, namelast,
    tb.lslg
      FROM people p, (
      SELECT b.playerid, CAST(CAST(1.0*((SUM(h)-SUM(h2b)-SUM(h3b)-SUM(hr))+2*SUM(h2b)+3*SUM(h3b)+4*SUM(hr))/SUM(ab) AS DECIMAL(32,16)) AS FLOAT) AS lslg
      FROM batting b, (
        SELECT playerid, SUM(ab) AS lab 
        FROM batting
        GROUP BY playerid
      ) AS tb
      WHERE b.playerid = tb.playerid AND tb.lab > 50
      GROUP BY b.playerid
    ) AS tb
      WHERE p.playerid = tb.playerid
  ) AS q2
    WHERE playerid = 'mayswi01'
  )
;

-- Question 4i
CREATE VIEW q4i(yearid, min, max, avg, stddev)
AS
  SELECT yearid, MIN(salary) AS min, MAX(salary) AS max, AVG(salary) AS avg, STDDEV(salary) AS stddev
  FROM Salaries
  GROUP BY yearid
  ORDER BY yearid
;

-- Question 4ii
CREATE VIEW q4ii(binid, low, high, count)
AS

  SELECT binid, low, high, COUNT(*)+(CASE WHEN binid=9 THEN 1 ELSE 0 END) AS count
  FROM Salaries,(
    SELECT generate_series AS binid, generate_series*(max-min)/10+min AS low,(generate_series+1)*(max-min)/10+min AS high
    FROM generate_series(0,9),(
        SELECT MIN(salary) AS min, MAX(salary) AS max
        FROM Salaries
        WHERE yearid = 2016
      ) AS tb2
  ) AS tb1
  WHERE salary >= low AND salary < high AND yearid = 2016
  GROUP BY binid, low, high
  ORDER BY binid
;

-- Question 4iii
CREATE VIEW q4iii(yearid, mindiff, maxdiff, avgdiff)
AS
  SELECT tb2.yearid, tb2.min-tb1.min AS mindiff, tb2.max-tb1.max AS maxdiff, tb2.avg-tb1.avg AS avgdiff
  FROM q4i AS tb1, q4i AS tb2
  WHERE tb2.yearid-tb1.yearid = 1
;

-- Question 4iv
CREATE VIEW q4iv(playerid, namefirst, namelast, salary, yearid)
AS
  SELECT p.playerid, namefirst, namelast, salary, s.yearid
  FROM people p, Salaries s
  WHERE p.playerid = s.playerid
  AND s.salary = ALL(
    SELECT MAX(salary) FROM Salaries
    WHERE yearid = 2000
  )
  AND s.yearid = 2000

  UNION

  SELECT p.playerid, namefirst, namelast, salary, s.yearid
  FROM people p, Salaries s
  WHERE p.playerid = s.playerid
  AND s.salary = ALL(
    SELECT MAX(salary) FROM Salaries
    WHERE yearid = 2001
  )
  AND s.yearid = 2001
;
-- Question 4v
CREATE VIEW q4v(team, diffAvg) 
  AS
    SELECT a.teamid AS team, MAX(salary)-MIN(salary) AS diffAvg
    FROM AllStarFull a, Salaries s
    WHERE a.playerid = s.playerid AND s.yearid = 2016 AND a.yearid = 2016
    GROUP BY a.teamid
    ORDER BY a.teamid
;

