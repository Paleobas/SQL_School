WITH RECURSIVE recursion AS(
	SELECT
		point1 AS tour,
		point1,
		point2,
		cost,
		cost AS summ
	FROM graph
	WHERE point1 = 'a'
	UNION ALL
	SELECT
			parrent.tour || ',' || child.point1 AS trace,
			child.point1,
			child.point2,
			child.cost,
			parrent.summ + child.cost AS summ
	FROM graph AS child
	JOIN recursion AS parrent ON child.point1 = parrent.point2
	WHERE tour NOT LIKE '%' || child.point1 || '%'
)

SELECT 
	summ AS total_cost,
	CONCAT('{', tour,',a}') AS tour
FROM recursion
WHERE (LENGTH(tour) = 7 
	AND point2 = 'a' 
	AND (summ = (SELECT MIN(summ) FROM recursion WHERE (LENGTH(tour) = 7 AND point2 = 'a'))
		OR summ = (SELECT MAX(summ) FROM recursion WHERE (LENGTH(tour) = 7 AND point2 = 'a'))))
ORDER BY total_cost, tour