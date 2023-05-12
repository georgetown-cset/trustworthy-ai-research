CREATE OR REPLACE FUNCTION
  `gcp-cset-projects.trusted_ml_research.trustworthy_keywords`(str STRING) AS(REGEXP_CONTAINS(LOWER(str), r"(?i)((trust)|(trustworthy)|(explainable)|(explainability)|(robustness)|(reliable)|(reliability)|(security)|(resilience)|(interpretable)|(interpretability)|(privacy)|(security)|(safety)|(bias)|(fairness)|(accountability)|(accountable)|(transparency))"))
