-- ============================================================
-- KAN-14: Unity Catalog Governance
-- Lineage, Access Control, and Table Tagging
-- ============================================================

-- ------------------------------------------------------------
-- Access Control: Grant SELECT on Gold tables to all users
-- ------------------------------------------------------------
GRANT SELECT ON TABLE workspace.retailpulse_gold.daily_sales TO `account users`;
GRANT SELECT ON TABLE workspace.retailpulse_gold.revenue_by_category TO `account users`;
GRANT SELECT ON TABLE workspace.retailpulse_gold.orders_by_country TO `account users`;
GRANT SELECT ON TABLE workspace.retailpulse_gold.top_customers TO `account users`;

-- Restrict access on Silver layer
REVOKE SELECT ON TABLE workspace.retailpulse_silver.orders FROM `account users`;
REVOKE SELECT ON TABLE workspace.retailpulse_silver.customers FROM `account users`;
REVOKE SELECT ON TABLE workspace.retailpulse_silver.products FROM `account users`;

-- ------------------------------------------------------------
-- Table Tagging
-- ------------------------------------------------------------
ALTER TABLE workspace.retailpulse_silver.customers
SET TAGS ('pii' = 'true');

ALTER TABLE workspace.retailpulse_silver.orders
SET TAGS ('financial' = 'true');

ALTER TABLE workspace.retailpulse_gold.daily_sales
SET TAGS ('financial' = 'true');

ALTER TABLE workspace.retailpulse_gold.top_customers
SET TAGS ('pii' = 'true', 'financial' = 'true');

ALTER TABLE workspace.retailpulse_gold.revenue_by_category
SET TAGS ('financial' = 'true');

ALTER TABLE workspace.retailpulse_gold.orders_by_country
SET TAGS ('public' = 'true');

-- ------------------------------------------------------------
-- Verify Tags
-- ------------------------------------------------------------
SELECT table_name, tag_name, tag_value
FROM system.information_schema.table_tags
WHERE schema_name IN ('retailpulse_silver', 'retailpulse_gold')
ORDER BY table_name;