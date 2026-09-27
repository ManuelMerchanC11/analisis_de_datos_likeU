-- PRUEBA TÉCNICA: Punto 2
-- Tabla utilizada: prueba_procesado
-- Motor: PostgreSQL


-- Parte 1: Funnel de Entrega
WITH funnel AS (
    SELECT 
        COUNT(*) AS total_msg_salientes,
        SUM(CASE WHEN status = 'read' THEN 1 ELSE 0 END) AS total_read,
        SUM(CASE WHEN status = 'delivered' THEN 1 ELSE 0 END) AS total_delivered,
        SUM(case when status = 'failed' then 1 else 0 END) as total_failed
    FROM prueba_procesado
    WHERE message_type = 'outgoing'
)
SELECT 
    total_msg_salientes,
    ROUND((total_read * 100.0) / total_msg_salientes, 2) AS rate_read,
    ROUND((total_delivered * 100.0) / total_msg_salientes, 2) AS rate_delivered,
    ROUND((total_failed * 100.0) / total_msg_salientes, 2) as rate_failed
FROM funnel;

-- Parte 2: SLA de Respuesta Operativa
WITH respuesta_operativa AS (
    SELECT 
        conversation_id,
        message_type,
        created_at,
        LEAD(message_type) OVER (PARTITION BY conversation_id ORDER BY created_at) AS siguiente_msg_tipo,
        LEAD(created_at) OVER (PARTITION BY conversation_id ORDER BY created_at) AS siguiente_fecha
    FROM prueba_procesado
)
SELECT 
    -- Agregamos ::timestamp a ambas columnas para que SQL sepa que son fechas y permita restarlas
	-- EPOCH trasnforma el intervalo en segundos
    ROUND(AVG(EXTRACT(EPOCH FROM (siguiente_fecha::timestamp - created_at::timestamp)) / 60), 2) AS sla_promedio_minutos
FROM respuesta_operativa
WHERE message_type = 'incoming' 
  AND siguiente_msg_tipo IN ('outgoing', 'activity');

-- Parte 3: Curva de Calor Horaria
SELECT 
    EXTRACT(HOUR FROM created_at::timestamp) AS hora_del_dia,
    COUNT(account_id) AS volumen_entrante
FROM prueba_procesado
WHERE message_type = 'incoming'
GROUP BY EXTRACT(HOUR FROM created_at::timestamp)
ORDER BY hora_del_dia ASC;