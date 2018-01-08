CREATE OR REPLACE PROCEDURE sp_zld_rating_model_import(iv_date      IN DATE DEFAULT SYSDATE,
                                                       iv_running   IN VARCHAR2 DEFAULT 'N',
                                                       ov_error_msg OUT SYS_REFCURSOR) IS
  /*************************************
  �洢���̣�sp_zld_rating_model_import
  ����ʱ�䣺2017/11/28
  �� �� �ˣ�ZhangCong
  Դ    ��
  Ŀ �� ��
  ��    �ܣ��������ģ������,���뵽��Ӧ��ģ�ͱ�
  
  ************************************/

  --------------------------------������־����--------------------------------------
  v_task_name     VARCHAR2(2000);
  v_error_cd      NUMBER;
  v_error_message VARCHAR2(1000);

  --------------------------------����ҵ�����-------------------------------------
  --v_creation_by   VARCHAR2(200) := 0; --������
  v_creation_time TIMESTAMP := iv_date; --����ʱ��
  v_isdel         NUMBER := 0; --�Ƿ�ɾ��
  v_isactive      NUMBER := 1; --�Ƿ���Ч
  v_model_name    VARCHAR2(200);
  v_error_cnt     NUMBER := 0; --��������

BEGIN

  --��������
  v_task_name := 'SP_ZLD_RATING_MODEL_IMPORT';

  --���������Ϣ��LOG����

  --ģ���ظ�����
  INSERT INTO zld_rating_model_errorlog
    (task_name, error_type, model_name, error_msg, create_time)
    SELECT v_task_name,
           '�����ظ�',
           NAME,
           CASE
             WHEN COUNT(*) > 1 THEN
              'ģ��ҳ�� ' || NAME || ' �����ظ�,������ ' || NAME || ' ģ��'
           END AS error_msg,
           v_creation_time
      FROM zld_rating_model
     GROUP BY NAME
    HAVING COUNT(*) > 1;

  --��ģ���ظ�����
  INSERT INTO zld_rating_model_errorlog
    (task_name, error_type, model_name, error_msg, create_time)
    SELECT v_task_name,
           '�����ظ�',
           parent_rm_name,
           CASE
             WHEN COUNT(*) > 1 THEN
              '��ģ��ҳ�� ' || parent_rm_name || '-' || NAME || ' �����ظ�,������' || parent_rm_name || 'ģ��'
           END AS error_msg,
           v_creation_time
      FROM zld_rating_model_sub_model
     GROUP BY parent_rm_name, NAME
    HAVING COUNT(*) > 1;

  --���ڶ�Ӧ��ģ������
  INSERT INTO zld_rating_model_errorlog
    (task_name, error_type, exposure_name, error_msg, create_time)
    SELECT v_task_name,
           '�����ظ�',
           exposure_name,
           CASE
             WHEN COUNT(*) > 1 THEN
              'ģ�ͳ���ҳ�� ' || exposure_name || '���ڲ�Ӧ�ô��ڶ�����¼,������' || exposure_name || '���ڼ���ģ��'
           END AS error_msg,
           v_creation_time
      FROM zld_rating_model_exposure_xw
     GROUP BY exposure_name
    HAVING COUNT(*) > 1;

  --У׼�����ظ�����
  INSERT INTO zld_rating_model_errorlog
    (task_name, error_type, model_name, error_msg, create_time)
    SELECT v_task_name,
           '�����ظ�',
           d.rm_name,
           CASE
             WHEN COUNT(*) > 1 THEN
              'У׼����ҳ ' || rm_name || '(formular=''' || formular || ''')' || '�����ظ���������' ||
              rm_name || 'ģ��'
           END AS error_msg,
           v_creation_time
      FROM zld_rating_calc_pd_ref d
     GROUP BY d.rm_name, d.formular
    HAVING COUNT(*) > 1;

  --ģ��ָ���ظ�����
  INSERT INTO zld_rating_model_errorlog
    (task_name, error_type, model_name, error_msg, create_time)
    SELECT v_task_name,
           '�����ظ�',
           model_name,
           CASE
             WHEN COUNT(*) > 1 THEN
              'ģ��ָ��ҳ�� ģ��:' || model_name || ' ��ģ��:' || sub_model_name || ' ָ��:' || ft_code ||
              '�������ظ���������' || model_name || 'ģ��'
           END AS error_msg,
           v_creation_time
      FROM zld_rating_model_factor
     GROUP BY model_name, sub_model_name, ft_code
    HAVING COUNT(*) > 1;

  --����ȱʧ����
  INSERT INTO zld_rating_model_errorlog
    (task_name, error_type, model_name, error_msg, create_time)
    SELECT v_task_name, '����ȱʧ', model_name, error_msg, v_creation_time
      FROM (SELECT model_name,
                   CASE
                     WHEN exposure_cnt = 0 THEN
                      'ģ�ͣ�' || model_name || ' ��exposure�����Ҳ�����Ӧ����'
                     WHEN model_cnt = 0 THEN
                      'ģ�ͣ�' || model_name || ' ��ģ��ҳ���Ҳ�����Ӧģ�Ͷ���'
                     WHEN client_cnt = 0 THEN
                      'ģ��:' || model_name || ' client_basicinfo���Ҳ����ͻ�id'
                     WHEN sub_model_cnt = 0 THEN
                      'ģ�ͣ�' || model_name || ' ����ģ��ҳ���Ҳ�����Ӧ��ģ�Ͷ���'
                     WHEN ref_cnt = 0 THEN
                      'ģ�ͣ�' || model_name || ' ��У׼����ҳ���Ҳ�����Ӧ��У׼����'
                     WHEN factor_cnt = 0 THEN
                      'ģ�ͣ�' || model_name || ' ��ģ��ָ��ҳ���Ҳ�����Ӧָ�궨��'
                     ELSE
                      NULL
                   END AS error_msg
              FROM (SELECT a.model_name,
                           COUNT(DISTINCT t.exposure) AS exposure_cnt,
                           COUNT(DISTINCT b.name) AS model_cnt,
                           COUNT(DISTINCT ct.client_id) AS client_cnt,
                           COUNT(DISTINCT c.name) AS sub_model_cnt,
                           COUNT(DISTINCT d.rm_name) AS ref_cnt,
                           COUNT(DISTINCT e.sub_model_name) AS factor_cnt
                      FROM zld_rating_model_exposure_xw a
                      LEFT JOIN exposure t
                        ON (t.exposure = a.exposure_name)
                      LEFT JOIN zld_rating_model b
                        ON (a.model_name = b.name)
                      LEFT JOIN client_basicinfo ct
                        ON (b.client_name = ct.client_nm)
                      LEFT JOIN zld_rating_model_sub_model c
                        ON (b.name = c.parent_rm_name)
                      LEFT JOIN zld_rating_calc_pd_ref d
                        ON (b.name = d.rm_name)
                      LEFT JOIN zld_rating_model_factor e
                        ON (c.parent_rm_name = e.model_name AND c.name = e.sub_model_name)
                     GROUP BY a.model_name) mid)
     WHERE error_msg IS NOT NULL;

  COMMIT;

  SELECT COUNT(*)
    INTO v_error_cnt
    FROM zld_rating_model_errorlog el
   WHERE el.create_time >= v_creation_time;

  IF iv_running = 'Y' AND v_error_cnt = 0
  THEN
    --������ģ��
    FOR i IN (SELECT DISTINCT b.name AS model_name, t.exposure_sid, ct.client_id
                FROM zld_rating_model_exposure_xw a
                JOIN exposure t
                  ON (t.exposure = a.exposure_name)
                JOIN zld_rating_model b
                  ON (a.model_name = b.name)
                JOIN client_basicinfo ct
                  ON (b.client_name = ct.client_nm)
                JOIN zld_rating_model_sub_model c
                  ON (b.name = c.parent_rm_name)
                JOIN zld_rating_calc_pd_ref d
                  ON (b.name = d.rm_name)
                JOIN zld_rating_model_factor e
                  ON (c.parent_rm_name = e.model_name AND c.name = e.sub_model_name)
               WHERE NOT EXISTS (SELECT 1
                        FROM zld_rating_model_errorlog lg --���˱����д�����Ϣ��ģ��
                       WHERE (a.model_name = lg.model_name OR
                             a.exposure_name = lg.exposure_name)
                         AND lg.create_time >= v_creation_time)) LOOP
    
      v_model_name := i.model_name;
    
      --����ģ���ҵ���ģ��ID��Ȼ��ɾ����Ӧ��ģ��ָ��
      DELETE FROM rating_model_factor rmf
       WHERE rmf.sub_model_id IN (SELECT rms.id
                                    FROM rating_model_sub_model rms, rating_model rm
                                   WHERE rm.id = rms.parent_rm_id
                                     AND rm.name = i.model_name);
      --����ģ��ɾ����Ӧ��ģ��
      DELETE FROM rating_model_sub_model rms
       WHERE rms.parent_rm_id =
             (SELECT rm.id FROM rating_model rm WHERE rm.name = i.model_name);
    
      --����ģ��ɾ����Ӧ�����
      DELETE FROM rating_calc_pd_ref rpf
       WHERE rpf.rm_id = (SELECT id FROM rating_model WHERE NAME = i.model_name);
    
      --���ݳ���ɾ����Ӧ����ģ��ӳ��
      DELETE FROM rating_model_exposure_xw xw
       WHERE xw.exposure_sid = i.exposure_sid;
    
      --����ģ��ɾ����Ӧģ�ͱ�
      DELETE FROM rating_model rm WHERE rm.name = i.model_name;
    
      --����ģ�Ͷ���
      INSERT INTO rating_model
        (id,
         code,
         NAME,
         client_id,
         valid_from_date,
         valid_to_date,
         ms_type,
         TYPE,
         version,
         is_active,
         isdel,
         creation_time)
        SELECT seq_rating_model.nextval,
               code,
               NAME,
               i.client_id, --�����ʹ�
               valid_from_date,
               valid_to_date,
               ms_type,
               TYPE,
               version,
               v_isactive,
               v_isdel,
               v_creation_time
          FROM zld_rating_model a
          JOIN client_basicinfo b
            ON (a.client_name = b.client_nm)
         WHERE a.name = i.model_name;
    
      --������ģ��
      INSERT INTO rating_model_sub_model
        (id,
         NAME,
         TYPE,
         parent_rm_id,
         ratio,
         intercept,
         parameter1,
         parameter2,
         parameter3,
         parameter4,
         parameter5,
         parameter6,
         parameter7,
         parameter8,
         parameter9,
         parameter10,
         is_base,
         mean_value,
         sd_value,
         creation_time,
         priority)
        SELECT seq_rating_model_sub_model.nextval,
               a.name,
               a.type,
               b.id,
               a.ratio,
               a.intercept,
               a.parameter1,
               a.parameter2,
               a.parameter3,
               a.parameter4,
               a.parameter5,
               a.parameter6,
               a.parameter7,
               a.parameter8,
               a.parameter9,
               a.parameter10,
               a.is_base,
               a.mean_value,
               a.sd_value,
               v_creation_time,
               a.priority
          FROM zld_rating_model_sub_model a
          JOIN rating_model b
            ON (a.parent_rm_name = b.name AND b.name = i.model_name);
    
      --����ģ�ͳ���ӳ���ϵ
      INSERT INTO rating_model_exposure_xw
        (rating_model_exposure_sid, model_id, exposure_sid, updt_dt)
        SELECT seq_rating_model_exposure_xw.nextval,
               c.id,
               b.exposure_sid,
               v_creation_time
          FROM zld_rating_model_exposure_xw a
          JOIN exposure b
            ON (a.exposure_name = b.exposure)
          JOIN rating_model c
            ON (a.model_name = c.name AND c.name = i.model_name);
    
      --����ģ��У׼����
      INSERT INTO rating_calc_pd_ref
        (id, rm_id, formular, parameter_a, parameter_b, row_num, rms_id, creation_time)
        SELECT seq_rating_calc_pd_ref.nextval,
               b.id,
               a.formular,
               a.parameter_a,
               a.parameter_b,
               a.row_num,
               a.rms_id,
               v_creation_time
          FROM zld_rating_calc_pd_ref a
          JOIN rating_model b
            ON (a.rm_name = b.name AND b.name = i.model_name);
    
      --����ģ��ָ��
      INSERT INTO rating_model_factor
        (id,
         sub_model_id,
         ft_code,
         ratio,
         calc_param_1,
         calc_param_2,
         calc_param_3,
         calc_param_4,
         calc_param_5,
         calc_param_6,
         calc_param_7,
         calc_param_8,
         calc_param_9,
         calc_param_10,
         method_type,
         creation_time)
        SELECT seq_rating_model_factor.nextval,
               c.id,
               a.ft_code,
               a.ratio,
               a.calc_param_1,
               a.calc_param_2,
               a.calc_param_3,
               a.calc_param_4,
               a.calc_param_5,
               a.calc_param_6,
               a.calc_param_7,
               a.calc_param_8,
               a.calc_param_9,
               a.calc_param_10,
               a.method_type,
               v_creation_time
          FROM zld_rating_model_factor a
          JOIN rating_model b
            ON (a.model_name = b.name AND b.name = i.model_name)
          JOIN rating_model_sub_model c
            ON (a.sub_model_name = c.name AND c.parent_rm_id = b.id);
    
      COMMIT;
    
    END LOOP;
  END IF;

  COMMIT;

  OPEN ov_error_msg FOR
    SELECT t.error_type, t.error_msg
      FROM zld_rating_model_errorlog t
     WHERE t.create_time >= iv_date;

  --������
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    v_error_cd      := SQLCODE;
    v_error_message := substr(SQLERRM, 1, 1000);
    dbms_output.put_line('failed! ERROR:' || v_error_cd || ' ,' || v_error_message);
  
    INSERT INTO zld_rating_model_errorlog
      (task_name, error_type, model_name, error_msg, create_time)
    VALUES
      (v_task_name,
       'Exception',
       v_model_name,
       'ERROR:' || v_error_cd || ' ,' || v_error_message,
       SYSDATE);
  
    COMMIT;
  
    raise_application_error(-20021, v_error_message);
    RETURN;
  
    COMMIT;
  
END sp_zld_rating_model_import;
/
