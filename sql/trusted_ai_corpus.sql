SELECT merged_id, title_english, abstract_english, title_foreign, abstract_foreign, year, doctype, source_title FROM gcp_cset_links_v2.corpus_merged
WHERE trusted_ml_research.trustedML_en_0927(LOWER(title_english)) OR trusted_ml_research.trustedML_en_0927(LOWER(abstract_english))
