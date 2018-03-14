--����
CREATE TABLE zhc2_bond_rating_record AS 
SELECT * from bond_rating_record;
CREATE TABLE zhc2_bond_rating_detail AS 
SELECT * from bond_rating_detail;
CREATE TABLE zhc2_bond_rating_factor AS 
SELECT * from bond_rating_factor;
CREATE TABLE zhc2_bond_rating_xw AS 
SELECT * from bond_rating_xw;
CREATE TABLE zhc2_bond_rating_approv AS 
SELECT * from bond_rating_approv;
CREATE TABLE zhc2_bond_rating_display AS 
SELECT * from bond_rating_display;
CREATE TABLE zhc2_rating_record AS 
SELECT * from rating_record;
CREATE TABLE zhc2_rating_detail AS 
SELECT * from rating_detail;
CREATE TABLE zhc2_rating_display AS 
SELECT * from rating_display;
CREATE TABLE zhc2_rating_factor AS 
SELECT * from rating_factor;
CREATE TABLE zhc2_rating_approv AS 
SELECT * from rating_approv;
CREATE TABLE zhc2_rating_adjustment_reason AS 
SELECT * from rating_adjustment_reason;
CREATE TABLE zhc2_rating_record_log AS 
SELECT * from rating_record_log;
--���ϵͳ���������ı�
DELETE FROM bond_rating_record;
DELETE FROM bond_rating_detail;
DELETE FROM bond_rating_factor;
DELETE FROM bond_rating_xw;
DELETE FROM bond_rating_approv;
DELETE FROM bond_rating_display;
DELETE FROM rating_record;
DELETE FROM rating_detail;
DELETE FROM rating_display;
DELETE FROM rating_factor;
DELETE FROM rating_approv;
DELETE FROM rating_adjustment_reason;
DELETE FROM rating_record_log;

--1.����list��
CREATE TABLE zhc_compy_rating_list AS
SELECT * FROM compy_rating_list t WHERE t.compy_rating_list_sid > 36574;
-----------------------------------------------------

SELECT a.company_id,
       b.company_nm,
       c.exposure_sid,
       NULL,
       c.rpt_dt
  FROM (SELECT DISTINCT a.company_id, a.exposure_sid
          FROM compy_exposure a
          JOIN exposure b
            ON a.exposure_sid = b.exposure_sid
           AND b.exposure IN ('����ƽ̨')
         WHERE a.is_new = 1
           AND a.isdel = 0) a
  JOIN compy_basicinfo b
    ON (a.company_id = b.company_id)
  JOIN (SELECT DISTINCT company_id, rpt_dt, exposure_sid
          FROM compy_factor_operation) c
    ON (a.exposure_sid = c.exposure_sid AND a.company_id = c.company_id)
  JOIN compy_rating_list l ON a.company_id = l.company_id
 WHERE c.rpt_dt = DATE '2016-12-31'
   AND NOT EXISTS (SELECT 1
          FROM rating_record rd
         WHERE a.company_id = rd.company_id
           AND a.exposure_sid = rd.exposure_sid);


--3.�������������company��exposure
--2.��ճ�ʼ��
SELECT * FROM exposure;
TRUNCATE TABLE compy_rating_list;

INSERT INTO compy_rating_list
SELECT seq_compy_rating_list.nextval,
       a.company_id,
       b.company_nm,
       c.exposure_sid,
       NULL,
       c.rpt_dt
  FROM (SELECT DISTINCT a.company_id, a.exposure_sid
          FROM compy_exposure a
          JOIN exposure b
            ON a.exposure_sid = b.exposure_sid
           AND b.exposure IN ('���ز�')
         WHERE a.is_new = 1
           AND a.isdel = 0) a
  JOIN compy_basicinfo b
    ON (a.company_id = b.company_id)
  JOIN (SELECT DISTINCT company_id, rpt_dt, exposure_sid
          FROM compy_factor_operation) c
    ON (a.exposure_sid = c.exposure_sid AND a.company_id = c.company_id)
 WHERE c.rpt_dt = DATE '2016-12-31'
   AND NOT EXISTS (SELECT 1
          FROM rating_record rd
         WHERE a.company_id = rd.company_id
           AND a.exposure_sid = rd.exposure_sid);
 

SELECT COUNT(*)
  FROM compy_rating_list t;

--1.�鿴��¼
SELECT * FROM compy_rating_list;
DELETE FROM compy_rating_list t WHERE t.compy_rating_list_sid = -1;

--2.���Ƿ��й�����
SELECT t.company_nm,s.*
  FROM compy_rating_list t
  JOIN rating_record s
    ON t.company_id = s.company_id
    AND t.company_id <> 0
    AND s.updt_dt > TRUNC(SYSDATE);
    
SELECT * FROM rating_record t;
DELETE FROM rating_record t WHERE t.company_id = 0;

--3.�鿴�����������־
SELECT s.exposure, t.error_desc, t.*
  FROM rating_record_log t
  LEFT JOIN compy_exposure ce
    ON t.company_id = ce.company_id
    AND ce.is_new = 1 AND ce.isdel = 0 
  JOIN exposure s
    ON ce.exposure_sid = s.exposure_sid
 WHERE t.isfailed = 1
   AND t.updt_dt > SYSDATE - 1
   AND t.company_id IN (SELECT company_id FROM compy_rating_list )
 ORDER BY t.updt_dt DESC;
 
--4.�Ƿ����¼��������ָ���¼
--��Ӫ����;

SELECT t.*
  FROM compy_factor_operation t
  JOIN compy_rating_list r
    ON t.company_id = r.company_id
 WHERE t.updt_dt > SYSDATE - 1/24;
--��������
SELECT t.*
  FROM compy_factor_finance t
  JOIN compy_rating_list r
    ON t.company_id = r.company_id
   WHERE t.updt_dt > SYSDATE - 1/24
   AND t.factor_cd = 'Profitability3';
