CREATE OR REPLACE VIEW VW_RATING_RULE_FACTOR AS
WITH tmp_creditrating_cmb AS --��������
 (SELECT company_id, final_rating, updt_dt
    FROM (SELECT company_id,
                 final_rating,
                 nvl(updt_dt, SYSDATE - 365) AS updt_dt,
                 row_number() over(PARTITION BY company_id ORDER BY effect_end_dt DESC, rating_no DESC) AS rn
            FROM compy_creditrating_cmb
           WHERE isdel = 0)
   WHERE rn = 1),
tmp_creditrating AS --��������
 (SELECT company_id, rating, nvl(updt_dt, SYSDATE - 365) AS updt_dt
    FROM (SELECT company_id,
                 rating,
                 updt_dt,
                 row_number() over(PARTITION BY company_id ORDER BY rating_dt DESC, notice_dt DESC, compy_creditrating_sid DESC) AS rn
            FROM compy_creditrating
           WHERE nvl(credit_org_id, 0) NOT IN
                 (SELECT company_id
                    FROM compy_basicinfo
                   WHERE company_nm IN ('��ծ���������������ι�˾', '�й�֤���')))
   WHERE rn = 1),
tmp_constant AS
 (SELECT constant_cd, constant_nm, constant_type
    FROM lkp_constant
   WHERE isdel = 0
   GROUP BY constant_cd, constant_nm, constant_type),
tmp_rating_record AS
 (SELECT company_id,
         scaled_rating,
         nvl(updt_dt, SYSDATE - 365) AS updt_dt,
         row_number() over(PARTITION BY company_id ORDER BY updt_dt DESC) AS rnk
    FROM rating_record
   WHERE rating_type = 0),
tmp_rulefactor AS
 (SELECT company_id,
         nvl(updt_dt, SYSDATE - 365) AS updt_dt,
         rulerating_factor6,
         rulerating_factor7,
         rulerating_factor8,
         rulerating_factor9,
         rulerating_factor10,
         rulerating_factor11,
         rulerating_factor12
    FROM (SELECT company_id,
                 factor_cd,
                 factor_value,
                 MAX(updt_dt) over(PARTITION BY company_id) AS updt_dt
            FROM compy_rulefactor_cmb
           WHERE isdel = 0)
  pivot(MAX(factor_value)
     FOR factor_cd IN('RULERATING_FACTOR6' AS rulerating_factor6,
                     'RULERATING_FACTOR7' AS rulerating_factor7,
                     'RULERATING_FACTOR8' AS rulerating_factor8,
                     'RULERATING_FACTOR9' AS rulerating_factor9,
                     'RULERATING_FACTOR10' AS rulerating_factor10,
                     'RULERATING_FACTOR11' AS rulerating_factor11,
                     'RULERATING_FACTOR12' AS rulerating_factor12)))
SELECT cust.company_id          AS company_id, --��ҵ��ʶ��
       cust.risk_status_cd      AS rulerating_factor1, --�ͻ����շֲ�
       cust.class_grade_cd      AS rulerating_factor2, --���ʮ������
       cust.group_warnstatus_cd AS rulerating_factor3, --�������ſͻ����շֲ�
       --tmp_creditrating_cmb.final_rating AS rulerating_factor4, --�ͻ������������
       kp.constant_nm AS rulerating_factor4, --�ͻ������������
       CASE
         WHEN cust.is_high_risk = 1 THEN
          '��'
         WHEN cust.is_high_risk = 0 THEN
          '��'
         ELSE
          NULL
       END AS rulerating_factor5, --�Ƿ�߷���������
       tmp_rulefactor.rulerating_factor6 AS rulerating_factor6, --��ȳ��ڽ��/������Ȩ��
       CASE
         WHEN tmp_rulefactor.rulerating_factor7 = 1 THEN
          '��'
         WHEN tmp_rulefactor.rulerating_factor7 = 0 THEN
          '��'
         ELSE
          NULL
       END AS rulerating_factor7, --���Ŷ�������������½�
       CASE
         WHEN tmp_rulefactor.rulerating_factor8 = 1 THEN
          '��'
         WHEN tmp_rulefactor.rulerating_factor8 = 0 THEN
          '��'
         ELSE
          NULL
       END AS rulerating_factor8, --��ȥ���������Ƿ����������������
       tmp_rulefactor.rulerating_factor9 AS rulerating_factor9, --���ⵣ�����/������Ȩ��
       tmp_rulefactor.rulerating_factor10 AS rulerating_factor10, --����������ⵣ�����/������Ȩ��
       CASE
         WHEN tmp_rulefactor.rulerating_factor11 = 1 THEN
          '��'
         WHEN tmp_rulefactor.rulerating_factor11 = 0 THEN
          '��'
         ELSE
          NULL
       END AS rulerating_factor11, --��ȥ1���Ƿ������������еĲ�����¼
       CASE
         WHEN tmp_rulefactor.rulerating_factor12 = 1 THEN
          '��'
         WHEN tmp_rulefactor.rulerating_factor12 = 0 THEN
          '��'
         ELSE
          NULL
       END AS rulerating_factor12, --��ȥ1���Ƿ������������еĹ�ע���¼
       ortb.loan_deposit_ratio AS rulerating_factor13, --�����
       ortb.gur_group AS rulerating_factor14, --����Ȧ
       ortb.balance_sixmon AS rulerating_factor15, --�����˻���6�����¾����
       ortb.bal_1y_uptimes AS rulerating_factor16, --�ͻ���ȥһ����ĩ�������������ӵĴ���
       ortb.bal_1y_uptimes_group AS rulerating_factor17, --�ͻ���ȥһ����ĩ�������������ӵĴ�������
       decode(ortb.overdue_12m, 'Y', '��', 'N', '��', NULL) AS rulerating_factor18, --��ȥһ���������ڼ�¼Y������N������
       tmp_creditrating.rating AS rulerating_factor19, --�ⲿ����
       rtr.scaled_rating AS rulerating_factor20, --��������
       greatest(nvl(cust.updt_dt, SYSDATE - 365),
                tmp_creditrating_cmb.updt_dt,
                tmp_creditrating.updt_dt,
                nvl(rtr.updt_dt, SYSDATE - 365),
                nvl(ortb.updt_dt, SYSDATE - 365),
                tmp_rulefactor.updt_dt) AS updt_dt --����ָ������¸���ʱ�� max(updt_dt)
  FROM customer_cmb cust
  LEFT JOIN tmp_creditrating_cmb
    ON (cust.company_id = tmp_creditrating_cmb.company_id)
  LEFT JOIN tmp_creditrating
    ON (cust.company_id = tmp_creditrating.company_id)
  LEFT JOIN tmp_rating_record rtr
    ON (cust.company_id = rtr.company_id AND rtr.rnk = 1)
  LEFT JOIN compy_operationclear_cmb ortb
    ON (cust.company_id = ortb.company_id AND ortb.isdel = 0)
  LEFT JOIN tmp_constant kp
    ON (to_char(tmp_creditrating_cmb.final_rating) = kp.constant_cd AND
       kp.constant_type = 28)
  LEFT JOIN tmp_rulefactor
    ON (cust.company_id = tmp_rulefactor.company_id)
    ORDER BY cust.company_id
