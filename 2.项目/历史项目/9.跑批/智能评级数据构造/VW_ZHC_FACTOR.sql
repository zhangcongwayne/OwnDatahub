CREATE OR REPLACE VIEW VW_ZHC_FACTOR AS
WITH tmp_constant AS
 (SELECT constant_cd, constant_nm, constant_type
    FROM lkp_constant
   WHERE isdel = 0
   GROUP BY constant_cd, constant_nm, constant_type)
SELECT c.company_id AS company_id, --��ҵ��ʶ��
       --t.l AS rulerating_factor1, --�ͻ����շֲ�
       rf1.constant_nm AS rulerating_factor1, --�ͻ����շֲ�
       --t.m AS rulerating_factor2, --���ʮ������
       rf2.constant_nm AS rulerating_factor2, --���ʮ������
       --t.y
       rf3.constant_nm AS rulerating_factor3, --�������ſͻ����շֲ�
       rf4.constant_nm AS rulerating_factor4, --�ͻ������������
       CASE
         WHEN t.j = 1 THEN
          '��'
         WHEN t.j = 0 THEN
          '��'
         ELSE
          to_char(t.j)
       END AS rulerating_factor5, --�Ƿ�߷���������
       t.t AS rulerating_factor6, --��ȳ��ڽ��
       CASE
         WHEN t.k = 1 THEN
          '��'
         WHEN t.k = 0 THEN
          '��'
         ELSE
          to_char(t.k)
       END AS rulerating_factor7, --���Ŷ�������������½�
       CASE
         WHEN t.p = 1 THEN
          '��'
         WHEN t.p = 0 THEN
          '��'
         ELSE
          to_char(t.p)
       END AS rulerating_factor8, --��ȥ���������Ƿ����������������
       t.x AS rulerating_factor9, --���ⵣ�����/������Ȩ��
       t.y AS rulerating_factor10, --����������ⵣ�����/������Ȩ��
       CASE
         WHEN t.q = 1 THEN
          '��'
         WHEN t.q = 0 THEN
          '��'
         ELSE
          to_char(t.q)
       END AS rulerating_factor11, --��ȥ1���Ƿ������������еĲ�����¼
       CASE
         WHEN t.r = 1 THEN
          '��'
         WHEN t.r = 0 THEN
          '��'
         ELSE
          to_char(t.r)
       END AS rulerating_factor12, --��ȥ1���Ƿ������������еĹ�ע���¼
       t.u AS rulerating_factor13, --�����
       t.m AS rulerating_factor14, --����Ȧ
       t.v AS rulerating_factor15, --�����˻���6�����¾����
       t.w AS rulerating_factor16, --�ͻ���ȥһ����ĩ�������������ӵĴ���
       t.n AS rulerating_factor17, --�ͻ���ȥһ����ĩ�������������ӵĴ�������
       decode(t.o, 'Y', '��', 'N', '��', t.o) AS rulerating_factor18, --��ȥһ���������ڼ�¼Y������N������
       t.f AS rulerating_factor19, --�ⲿ����
       t.d AS rulerating_factor20, --��������
       t.s AS rulerating_factor21,  --��ͽ��׼۸���ֵ��
       t.updt_dt AS updt_dt --����ָ������¸���ʱ�� max(updt_dt)
  FROM zhc_rule_factor t
  JOIN customer_cmb c
    ON t.a = c.cust_no
  LEFT JOIN tmp_constant rf4
    ON (to_char(t.g) = rf4.constant_cd AND
       rf4.constant_type = 28)
  LEFT JOIN tmp_constant rf1
    ON (t.h  = rf1.constant_cd AND rf1.constant_type = 7)
  LEFT JOIN tmp_constant rf2
    ON (t.i = rf2.constant_cd AND rf2.constant_type = 8)
  LEFT JOIN tmp_constant rf3
    ON (t.l = rf3.constant_cd AND rf3.constant_type = 8)
;
