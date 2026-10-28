-- VUE 1 : PERFORMANCE FINANCIÈRE ET ANALYSE DU CHURN GLOBALE
CREATE OR REPLACE VIEW vue_performance_financiere AS
SELECT 
    "Contract" AS type_contrat,
    "InternetService" AS type_internet,
    COUNT(*) AS total_clients,
    SUM(CASE WHEN "Churn" = 'Yes' THEN 1 ELSE 0 END) AS clients_partis,
    ROUND(
        (SUM(CASE WHEN "Churn" = 'Yes' THEN 1 ELSE 0 END)::NUMERIC / COUNT(*)) * 100, 
        2
    ) AS taux_churn_pourcent,
    ROUND(SUM(CASE WHEN "Churn" = 'No' THEN "MonthlyCharges_FCFA" ELSE 0 END)::NUMERIC, 0) AS ca_mensuel_actif_fcfa,
    ROUND(SUM(CASE WHEN "Churn" = 'Yes' THEN "MonthlyCharges_FCFA" ELSE 0 END)::NUMERIC, 0) AS manque_a_gagner_mensuel_fcfa
FROM teleco_client
GROUP BY "Contract", "InternetService"
ORDER BY manque_a_gagner_mensuel_fcfa DESC;



-- VUE 2 : CIBLAGE ALERTE "CLIENTS VIP À HAUT RISQUE DE CHURN"
CREATE OR REPLACE VIEW vue_alerte_churn_vip AS
SELECT 
    "customerID" AS id_client,
    "Contract" AS type_contrat,
    "PaymentMethod" AS mode_paiement,
    "tenure" AS anciennete_mois,
    ROUND("MonthlyCharges_FCFA"::NUMERIC, 0) AS facture_mensuelle_fcfa,
    "OnlineSecurity" AS securite_en_ligne,
    "TechSupport" AS assistance_technique
FROM teleco_client
WHERE 
    "Churn" = 'No'
    AND "Contract" = 'Month-to-month'
    AND "MonthlyCharges_FCFA" > (SELECT AVG("MonthlyCharges_FCFA") FROM teleco_client)
ORDER BY "MonthlyCharges_FCFA" DESC;
