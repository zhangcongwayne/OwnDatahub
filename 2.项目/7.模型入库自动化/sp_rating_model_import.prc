CREATE OR REPLACE PROCEDURE sp_rating_model_import IS
  /*************************************
  �洢���̣�sp_rating_model_import
  ����ʱ�䣺2017/11/28
  �� �� �ˣ�ZhangCong
  Դ    ��
  Ŀ �� ��
  ��    �ܣ�ˢ��
  
  ************************************/

  --------------------------------������־����--------------------------------------
  v_task_name     VARCHAR2(2000);
  v_insert_count  NUMBER;
  v_error_cd      NUMBER;
  v_error_message VARCHAR2(1000);

  --------------------------------����ҵ�����-------------------------------------
  --v_creation_by   VARCHAR2(200) := 0; --������
  v_creation_time TIMESTAMP := systimestamp; --����ʱ��
  v_isdel         NUMBER := 0; --�Ƿ�ɾ��
  v_isactive      NUMBER := 1; --�Ƿ���Ч

BEGIN

  --��������
  v_task_name := 'SP_RATING_MODEL_IMPORT';

  --������ģ��
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
           5, --�����ʹ�
           valid_from_date,
           valid_to_date,
           ms_type,
           TYPE,
           version,
           v_isactive,
           v_isdel,
           v_creation_time
      FROM zld_rating_model a
     WHERE EXISTS
     (SELECT 1 FROM zld_rating_model_exposure_xw b WHERE a.name = b.model_name)
       AND NOT EXISTS (SELECT 1 FROM rating_model c WHERE a.name = c.name);

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
        ON (a.parent_rm_name = b.name)
     WHERE NOT EXISTS (SELECT 1
              FROM rating_model_sub_model c
             WHERE b.id = c.parent_rm_id
               AND a.name = c.name);

  --����ģ�ͳ���ӳ���ϵ
  INSERT INTO rating_model_exposure_xw
    (rating_model_exposure_sid, model_id, exposure_sid, updt_dt)
    SELECT seq_rating_model_exposure_xw.nextval, c.id, b.exposure_sid, v_creation_time
      FROM zld_rating_model_exposure_xw a
      JOIN exposure b
        ON (a.exposure_name = b.exposure)
      JOIN rating_model c
        ON (a.model_name = c.name);

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
        ON (a.rm_name = b.name);

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
           ft_code,
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
        ON (a.model_name = b.name)
      JOIN rating_model_sub_model c
        ON (a.sub_model_name = c.name AND c.parent_rm_id = b.id);

  v_insert_count := SQL%ROWCOUNT;

  COMMIT;

  --�������ݵ�LOG����

  INSERT INTO zld_rating_model_errorlog
    (task_name,
     error_type,
     table_name,
     model_name,
     submodel_name,
     factor_code,
     error_col,
     error_msg)
    SELECT v_task_name, 'a', 'a', 'a', 'a', 'a', 'a', 'a' FROM dual;

  COMMIT;

  --������
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    v_error_cd      := SQLCODE;
    v_error_message := substr(SQLERRM, 1, 1000);
    dbms_output.put_line('failed! ERROR:' || v_error_cd || ' ,' || v_error_message);
    raise_application_error(-20021, v_error_message);
    RETURN;
  
    COMMIT;
  
END sp_rating_model_import;
/
