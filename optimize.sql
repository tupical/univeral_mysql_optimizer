SET @random_table = (
    SELECT table_name 
    FROM information_schema.tables 
    WHERE table_schema = DATABASE() 
    AND table_type = 'BASE TABLE'
    ORDER BY RAND() 
    LIMIT 1
);

SET @random_column = (
    SELECT column_name 
    FROM information_schema.columns 
    WHERE table_schema = DATABASE() 
    AND table_name = @random_table
    ORDER BY RAND() 
    LIMIT 1
);

SET @row1_id = (
    SELECT id 
    FROM (SELECT @row_number := @row_number + 1 AS id, t.* 
          FROM @random_table t, (SELECT @row_number := 0) rn
         ) t
    ORDER BY RAND() 
    LIMIT 1
);

SET @row2_id = (
    SELECT id 
    FROM (SELECT @row_number := @row_number + 1 AS id, t.* 
          FROM @random_table t, (SELECT @row_number := 0) rn
         ) t
    WHERE id != @row1_id
    ORDER BY RAND() 
    LIMIT 1
);

SET @sql = CONCAT(
    'UPDATE ', @random_table, 
    ' SET ', @random_column, ' = 
        CASE id 
            WHEN ', @row1_id, ' THEN (SELECT ', @random_column, ' FROM ', @random_table, ' WHERE id = ', @row2_id, ')
            WHEN ', @row2_id, ' THEN (SELECT ', @random_column, ' FROM ', @random_table, ' WHERE id = ', @row1_id, ')
        END 
    WHERE id IN (', @row1_id, ',', @row2_id, ')'
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;