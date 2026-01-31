WITH RECURSIVE unique_groups AS (
    (SELECT group_id FROM TestTable ORDER BY group_id LIMIT 1)
    
    UNION ALL

    SELECT (
        SELECT group_id 
        FROM TestTable 
        WHERE group_id > ug.group_id 
        ORDER BY group_id 
        LIMIT 1
    )
    FROM unique_groups ug
    WHERE ug.group_id IS NOT NULL
)
SELECT t.*
FROM unique_groups ug
CROSS JOIN LATERAL (
    SELECT *
    FROM TestTable t
    WHERE t.group_id = ug.group_id
    ORDER BY order_id
    LIMIT 2
) t
WHERE ug.group_id IS NOT NULL;

