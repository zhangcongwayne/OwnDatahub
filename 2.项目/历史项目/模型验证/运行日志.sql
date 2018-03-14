--0.�鿴����������
SELECT *
  FROM compy_rating_list t
  JOIN rating_record s
    ON t.company_id = s.company_id
    AND s.updt_dt > TRUNC(SYSDATE);

--1.�鿴�ֶ��������������
SELECT b.company_nm, e.exposure, b.company_id, t.*
  FROM rating_record t
  JOIN compy_exposure s
    ON t.company_id = s.company_id
  JOIN exposure e
    ON s.exposure_sid = e.exposure_sid
--AND e.exposure = '����ƽ̨'
  JOIN compy_basicinfo b
    ON t.company_id = b.company_id
  JOIN compy_rating_list l
    ON t.company_id = l.company_id
 WHERE t.rating_type = 0
   AND t.user_id = 543
   AND t.updt_dt > trunc(SYSDATE)
 ORDER BY t.updt_dt DESC;

--2.�鿴ϵͳ�Զ������Ľ��
SELECT s.company_nm, t.*
  FROM rating_record t
  JOIN compy_basicinfo s
    ON t.company_id = s.company_id
  JOIN compy_rating_list l
    ON t.company_id = l.company_id
 WHERE t.rating_type = 0
   AND t.updt_dt > SYSDATE - 1 / 24
   AND t.user_id = -1
 ORDER BY t.updt_dt DESC;

--3.�鿴�����������־
SELECT s.exposure, t.error_desc, t.*
  FROM rating_record_log t
  LEFT JOIN compy_exposure ce
    ON t.company_id = ce.company_id
  JOIN exposure s
    ON ce.exposure_sid = s.exposure_sid
   AND s.exposure LIKE '%&exposure%'
  JOIN compy_rating_list l
  ON t.company_id = l.company_id
 WHERE t.isfailed = 1
   AND t.updt_dt > SYSDATE - 1
 ORDER BY t.updt_dt DESC;
 
 SELECT * FROM factor_option;

--4.�鿴��ʷ�������ȵ���־
SELECT process_nm,
       task_nm,
       task_typ_id,
       isfailed,
       error_desc,
       start_dt,
       end_dt,
       task_start_dt,
       remark,
       client_id,
       updt_by,
       updt_dt
  FROM process_log t
 WHERE t.task_start_dt > trunc(SYSDATE)
   AND t.task_nm = 'AutoRating'
   AND (t.remark <> 'û����Ҫ�����������¼' OR t.start_dt > SYSDATE - 1 / 24 / 60 * 10)
   AND t.remark IS NOT NULL
   AND t.task_start_dt < SYSDATE + 1
 ORDER BY t.updt_dt DESC;
