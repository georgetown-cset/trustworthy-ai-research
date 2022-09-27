CREATE OR REPLACE FUNCTION trusted_ml_research.trustedML_en_0927 (str STRING) AS(
REGEXP_CONTAINS(LOWER(str), r"(?i)((artificial intelligence)|(machine learning))") AND
REGEXP_CONTAINS(LOWER(str), r"(?i)((trust)|(trustworthy)|(explainable)|(explainability)|(robustness)|(reliable)|(reliability)|(security)|(resilience)|(interpretable)|(interpretability)|(privacy)|(security)|(safety)|(bias)|(fairness)|(accountability)|(transparency))"))
