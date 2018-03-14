--2.��ճ�ʼ��
SELECT * FROM exposure WHERE exposure = '����';
TRUNCATE TABLE compy_rating_list;

--3.�������������company��exposure
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
           AND b.exposure IN ('�����Ե���')
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

--4.�鿴��¼
SELECT COUNT(*) FROM compy_rating_list t;
SELECT * FROM compy_rating_list ORDER BY company_id;

--5.���Ƿ��й�����
SELECT COUNT(*) over(PARTITION BY NULL) AS total, s.*
  FROM compy_rating_list t
--WHERE t.company_id IN (SELECT company_id FROM rating_record);
  JOIN rating_record s
    ON t.company_id = s.company_id
   AND s.rating_type = 0 --1.�ο����� 2.�˹��϶�   ��������+�������� = ��������
AND s.updt_dt > to_date('20180202 08:56:00','yyyymmdd hh24:mi:ss')
;

--6.�Ƿ����¼��������ָ���¼
--��������
SELECT MAX(t.updt_dt)
  FROM compy_factor_finance t
  JOIN compy_rating_list r
    ON t.company_id = r.company_id
   WHERE t.updt_dt > SYSDATE - 1/24;
--��Ӫ����;
SELECT t.*
  FROM compy_factor_operation t
  JOIN compy_rating_list r
    ON t.company_id = r.company_id
 WHERE t.updt_dt > SYSDATE - 1/24;

--7.�鿴�����������־
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
