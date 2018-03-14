CREATE OR REPLACE VIEW VW_ZMD_CMP_FANGDICHAN AS
SELECT key,
       company_id,
       company_nm,
       rpt_date,
       modelscore,
       qnmodelscore,
       qlmodelscore,
       qlmodelscoreorig,
       structure3_val,
       structure019_val,
       leverage17_val,
       operation3_val,
       size2_val,
       specific7_val,
       structure3_score,
       structure019_score,
       leverage17_score,
       operation3_score,
       size2_score,
       specific7_score,

       factor_015_val,
       factor_001_val,
       factor_192_val,
       factor_190_val,
       factor_006_val,
       factor_020_val,
       factor_015_score,
       factor_001_score,
       factor_192_score,
       factor_190_score,
       factor_006_score,
       factor_020_score
  FROM (WITH factor_score_val AS (SELECT *
                                    FROM (SELECT t.rating_record_id,
                                                 rmf.ft_code,
                                                 t.score,
                                                 CASE
                                                   WHEN f.factor_type = '规模'
                                                   AND f.factor_property_cd=0
                                                    AND lower(f.factor_cd) like'%size%'
                                                    THEN
                                                    exp(t.factor_val)
                                                   ELSE
                                                    t.factor_val
                                                 END AS factor_val
                                            FROM rating_factor t
                                            JOIN rating_model_factor rmf
                                              ON t.rm_factor_id = rmf.id
                                            JOIN factor f
                                              ON rmf.ft_code = f.factor_cd) mid
                                  pivot(MAX(factor_val) AS val, MAX(score) AS score
                                     FOR ft_code IN(

                                                   'Structure3' AS structure3,
                                                   'Structure019' AS structure019,
                                                   'Leverage17' AS leverage17,
                                                   'Operation3' AS operation3,
                                                   'Size2' AS size2,
                                                   'Specific7' AS specific7,

                                                   'factor_015' AS factor_015,
                                                   'factor_001' AS factor_001,
                                                   'factor_192' AS factor_192,
                                                   'factor_190' AS factor_190,
                                                   'factor_006' AS factor_006,
                                                   'factor_020' AS factor_020

                                                   ))), model_score AS (SELECT rating_record_id,
                                                                               qn_score,
                                                                               qn_orig_score,
                                                                               qi_score,
                                                                               qi_orig_score
                                                                          FROM (SELECT t.rating_record_id,
                                                                                       NAME,
                                                                                       score,
                                                                                       new_score
                                                                                  FROM rating_detail t
                                                                                  JOIN rating_model_sub_model rms
                                                                                    ON t.rating_model_sub_model_id =
                                                                                       rms.id) mid
                                                                        pivot(MAX(score) AS orig_score, MAX(new_score) AS score
                                                                           FOR NAME IN('财务分析' AS qn,
                                                                                      '非财务分析' AS qi)))
         SELECT cbf.company_nm AS key,
                r.company_id,
                cbf.company_nm,
                r.factor_dt    AS rpt_date,
                --r.rating_record_id,
                r.total_score             AS modelscore,
                model_score.qn_score      AS qnmodelscore,
                model_score.qi_score      AS qlmodelscore,
                model_score.qi_orig_score AS qlmodelscoreorig,
                structure3_val,
                structure019_val,
                leverage17_val,
                operation3_val,
                size2_val,
                specific7_val,
                structure3_score,
                structure019_score,
                leverage17_score,
                operation3_score,
                size2_score,
                specific7_score,

                factor_015_val,
                factor_001_val,
                factor_192_val,
                factor_190_val,
                factor_006_val,
                factor_020_val,
                factor_015_score,
                factor_001_score,
                factor_192_score,
                factor_190_score,
                factor_006_score,
                factor_020_score,
                row_number() over(PARTITION BY cbf.company_id ORDER BY r.updt_dt DESC) AS rn
           FROM rating_record r
           JOIN compy_basicinfo cbf
             ON r.company_id = cbf.company_id
            AND cbf.is_del = 0
         --AND cbf.company_nm = '中国石油天然气股份有限公司'
           JOIN compy_exposure ce
             ON cbf.company_id = ce.company_id
            AND ce.is_new = 1
            AND ce.isdel = 0
           JOIN exposure e
             ON ce.exposure_sid = e.exposure_sid
            AND e.isdel = 0
            AND e.exposure = '房地产'
           JOIN factor_score_val
             ON r.rating_record_id = factor_score_val.rating_record_id
           JOIN model_score
             ON r.rating_record_id = model_score.rating_record_id)
          WHERE rn = 1
;
