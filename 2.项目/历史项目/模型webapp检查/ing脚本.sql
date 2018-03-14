SELECT f.factor_nm,
       a.ft_code,
       a.id,
       chr(39) || a.ft_code || chr(39) || ' AS ' || a.ft_code || ',' AS ft_cd2
  FROM rating_model_factor a
  JOIN rating_model_sub_model b
    ON a.sub_model_id = b.id
  JOIN factor f
    ON a.ft_code = f.factor_cd
  JOIN rating_model c
    ON b.parent_rm_id = c.id
  JOIN rating_model_exposure_xw d
    ON c.id = d.model_id
  JOIN exposure e
    ON d.exposure_sid = e.exposure_sid
   AND e.exposure = '����ƽ̨'
 ORDER BY a.id;
 
SELECT e.exposure,e.exposure_sid,c.name,c.ms_type,c.type,
b.name,b.type,
a.ft_code,a.method_type,
f.factor_nm,f.factor_type,
f.factor_category_cd,--0:���� 1������
f.factor_property_cd,--1������ 0������
f.factor_appl_cd --0����ƽ̨  1��ƽ̨���
  FROM rating_model_factor a
  JOIN rating_model_sub_model b
    ON a.sub_model_id = b.id
  JOIN factor f
    ON a.ft_code = f.factor_cd
  JOIN rating_model c
    ON b.parent_rm_id = c.id
  JOIN rating_model_exposure_xw d
    ON c.id = d.model_id
  JOIN exposure e
    ON d.exposure_sid = e.exposure_sid
   --AND e.exposure IN ('����','��ȨͶ��')
  JOIN (SELECT ROWNUM AS rn FROM dual CONNECT BY LEVEL < 2)
    ON 1 = 1
    WHERE a.ft_code = 'factor_119'
 ORDER BY rn,a.id;

--continuous �����ģ������е�λ
--discrete   ����ģ�����ָ������е�λ
--ģ��
--STATISTICS ͳ��ģ��
--SCORECARD��ֿ�ģ��


--1.ģ������ΪSTATISTICS(ͳ��ģ��),��ģ������Ϊ�������������ΪCONTINUOUS(������)���޵�λ
SELECT * FROM factor_option t WHERE t.factor_cd IN ('zs_Bank_Size1','zs_Bank_Leverage3','zs_Bank_Liquidity4');
--2.ģ������ΪSTATISTICS(ͳ��ģ��),��ģ������Ϊ�ǲ������������ΪDISCRETE(�����)���е�λ
SELECT * FROM factor_option t WHERE t.factor_cd IN ('factor_617','factor_634','zs_Bank_Liquidity4');
--2.ģ������ΪSTATISTICS(��ֿ�ģ��),��ģ������ֻ��Ϊģ�ͷ���������ΪDISCRETE(�����)���е�λ
SELECT * FROM factor_option t WHERE t.factor_cd IN ('factor_119');



SELECT * FROM factor t WHERE t.factor_cd = 'factor_001';
SELECT * FROM compy_factor_finance t WHERE t.factor_cd = 'factor_001';
SELECT * FROM compy_factor_operation t WHERE t.factor_cd = 'factor_001';
SELECT * FROM factor_option t WHERE t.factor_cd = 'factor_001' AND t.exposure_sid = 6380;
