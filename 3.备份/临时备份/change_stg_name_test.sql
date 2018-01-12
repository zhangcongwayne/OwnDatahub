prompt PL/SQL Developer Export User Objects for user CS_MASTER_TEST@CMB_DEV
prompt Created by zhangcong on 2018��1��11��
set define off
spool change_stg_name_test.log

prompt
prompt Creating procedure SP_BOND_POSITION_OUT
prompt =======================================
prompt
CREATE OR REPLACE PROCEDURE SP_BOND_POSITION_OUT IS
  /*
  �洢���̣�SP_BOND_POSITION_OUT
  ��    �ܣ�����-ί��ֲ�-������STG->TEMP->TGT��
            ��������ˮ��
            (�ͻ�+��Դ+�ͻ�����+�Ƿ���Ч)
  �� �� �ˣ�RAYLEE
  ����ʱ�䣺2017/11/9 10:25:27
  Դ    ��CS_MASTER_STG.STG_CMB_BOND_OUT
  �� �� ��TEMP_BOND_POSITION_OUT
  Ŀ �� ��BOND_POSITION_OUT
  --------------------------------------------------------------------
  �� �� �ˣ�RayLee
  �޸�ʱ�䣺2017-12-28 14:23:51
  �޸����ݣ���ͬҵ��������ȡupdt_dt�ϴ󣬶���ͬһ���Σ�updt_dt��ͬ����ȡrecord_sid����ļ�¼
  */

  V_ERROR_CD          VARCHAR2(100);
  V_ERROR_MESSAGE     VARCHAR2(1000);
  V_TASK_NAME         ETL_TGT_LOADLOG.PROCESS_NM%TYPE; --��������
  V_UPDT_DT           ETL_TGT_LOADLOG.END_DT%TYPE; --�ϴ�ͬ������ʱ��
  V_START_DT          ETL_TGT_LOADLOG.START_DT%TYPE; --��ʼʱ��
  V_END_DT            ETL_TGT_LOADLOG.END_DT%TYPE; --����ʱ��
  V_START_ROWID       ETL_TGT_LOADLOG.START_ROWID%TYPE; --��ʼ�к�
  V_END_ROWID         ETL_TGT_LOADLOG.END_ROWID%TYPE; --��ֹ�к�
  V_INSERT_COUNT      ETL_TGT_LOADLOG.INSERT_COUNT%TYPE; --�����¼��
  V_UPDT_COUNT        ETL_TGT_LOADLOG.UPDT_COUNT%TYPE; --���¼�¼��
  V_ORIG_RECORD_COUNT NUMBER(16); --ԭʼ�ļ�¼��
  V_DUP_RECORD_COUNT  NUMBER(16); --�ظ��ļ�¼��

  --
  --V_SRC_CD  TEMP_BOND_POSITION_OUT.SRC_CD%TYPE := UPPER(TRIM('CMB'));
  V_UPDT_BY TEMP_BOND_POSITION_OUT.UPDT_BY%TYPE := 0;
  V_ISDEL   TEMP_BOND_POSITION_OUT.ISDEL%TYPE := 0;

  V_EXEC_STEP VARCHAR2(100);

BEGIN

  --��������
  V_TASK_NAME := 'SP_BOND_POSITION_OUT';

  --��ʼʱ��
  V_START_DT := SYSDATE;

  --��ȡ�ϴ�ͬ�����ݵ�ʱ��,����ǵ�һ������û�м�¼�ᷢ��NO_DATA_FOUND�쳣
  V_EXEC_STEP := 'STEP1 ��ȡ�ϴ�ͬ��ʱ��';
  BEGIN
    SELECT NVL(MAX(END_DT), TO_DATE('1900-1-1', 'yyyy-mm-dd'))
      INTO V_UPDT_DT
      FROM ETL_TGT_LOADLOG
     WHERE PROCESS_NM = V_TASK_NAME;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      V_UPDT_DT := TO_DATE('1900-1-1', 'yyyy-mm-dd');
  END;

  --��ȡ�����������ݲ��뵽��ʱ��
  V_EXEC_STEP := 'STEP2 ��ȡ�����������ݲ��뵽��ʱ��';
  INSERT INTO TEMP_BOND_POSITION_OUT
    (BOND_POSITION_OUT_SID, --1.  �����ֲ���ˮ��
     SECINNER_ID, --2.  ծȯ��ʶ��
     SECURITY_CD, --3.  ծȯ����
     SECURITY_NM, --4.  ծȯȫ��
     TRADE_MARKET_ID, --5.  �����г�
     TRUSTEE_NM, --6.  ί���������
     PORTFOLIO_CD, --7.  ��ϴ���
     PORTFOLIO_NM, --8.  �������
     END_DT, --9.  �ֲ�����
     CURRENCY, --10. ����
     AMT_COST, --11. �ֲ����-�ɱ���
     AMT_MARKETVALUE, --12. �ֲ����-��ֵ��
     POSITION_NUM, --13. �ֲ�����
     STRATEGY_L1, --14. ����1������
     STRATEGY_L2, --15. ����2������
     STRATEGY_L3, --16. ����3������
     IS_VALID, --17. �Ƿ���Ч
     TSID, --18. Ψһ��ʶ
     SRC_UPDT_DT, --19. Դ����ʱ��
     ISDEL, --20. �Ƿ�ɾ��
     UPDT_BY, --21. ������
     UPDT_DT, --22. ����ʱ��
     RECORD_SID, --23.
     LOADLOG_SID, --24.
     RNK --25.
     )
    SELECT SEQ_BOND_POSITION_OUT.NEXTVAL AS BOND_POSITION_OUT_SID, --1.  �����ֲ���ˮ��
           T1.SECINNER_ID AS SECINNER_ID, --2.  ծȯ��ʶ��
           T.SECURITY_CD AS SECURITY_CD, --3.  ծȯ����
           T1.SECURITY_NM AS SECURITY_NM, --4.  ծȯȫ��
           T1.TRADE_MARKET_ID AS TRADE_MARKET_ID, --5.  �����г�
           T.TRUSTEE_NM AS TRUSTEE_NM, --6.  ί���������
           T.PORTFOLIO_CD AS PORFOLIO_CD, --7.  ��ϴ���
           T.PORTFOLIO_NM AS PORTFOLIO_NM, --8.  �������
           TO_DATE(T.POSITION_DT, 'YYYY-MM-DD') AS END_DT, --9.  �ֲ�����
           T.CURRENCY AS CURRENCY, --10. ����
           T.AMT_COST AS AMT_COST, --11. �ֲ����-�ɱ���
           T.AMT_MARKETVALUE AS AMT_MARKETVALUE, --12. �ֲ����-��ֵ��
           T.POSITION_NUM AS POSITION_NUM, --13. �ֲ�����
           T.CLS_01 AS STRATEGY_L1, --14. ����1������
           T.CLS_02 AS STRATEGY_L2, --15. ����2������
           T.CLS_03 AS STRATEGY_L3, --16. ����3������
           T.IS_VALID AS IS_VALID, --17. �Ƿ���Ч
           T.TSID AS TSID, --18. Ψһ��ʶ
           TO_TIMESTAMP(T.SRC_UPDT_DT,'YYYY-MM-DD HH24:MI:SS') AS SRC_UPDT_DT, --19. Դ����ʱ��
           V_ISDEL AS ISDEL, --20. �Ƿ�ɾ��
           V_UPDT_BY AS UPDT_BY, --21. ������
           SYSTIMESTAMP AS UPDT_DT, --22. ����ʱ��
           T.RECORD_SID AS RECORD_SID, --23.
           T.LOADLOG_SID AS LOADLOG_SID, --24.
           ROW_NUMBER() OVER(PARTITION BY T.TSID ORDER BY T.UPDT_DT DESC, T.RECORD_SID DESC) AS RNK --25.
      FROM CS_MASTER_STG.STG_CMB_BOND_OUT T
      LEFT JOIN (SELECT A.SECINNER_ID,
                        A.TRADE_MARKET_ID,
                        A.SECURITY_NM,
                        SUBSTR(C.MARKET_ABBR || A.SECURITY_CD, 2) AS SECURITY_CD
                   FROM BOND_BASICINFO A
                   LEFT JOIN LKP_CHARCODE B
                     ON A.TRADE_MARKET_ID = B.CONSTANT_ID
                    AND B.CONSTANT_TYPE = 206
                   LEFT JOIN LKP_MARKET_ABBR C
                     ON C.MARKET_CD = B.CONSTANT_CD
                 UNION ALL
                 SELECT A.SECINNER_ID,
                        A.TRADE_MARKET_ID,
                        A.SECURITY_NM,
                        'BK' || A.SECURITY_CD AS SECURITY_CD
                   FROM BOND_BASICINFO A
                   LEFT JOIN LKP_CHARCODE B
                     ON A.TRADE_MARKET_ID = B.CONSTANT_ID
                    AND B.CONSTANT_TYPE = 206
                   LEFT JOIN LKP_MARKET_ABBR C
                     ON C.MARKET_CD = B.CONSTANT_CD
                  WHERE C.MARKET_ABBR = '.IB') T1
        ON T1.SECURITY_CD = T.SECURITY_CD
     WHERE T.IS_VALID = '1'
       AND T.UPDT_DT > V_UPDT_DT;

  --����ʱ��
  V_END_DT := SYSDATE;

  --��ȡ��־����
  V_EXEC_STEP := 'STEP3 ��ȡ��־����';
  SELECT COUNT(1) AS ORIG_RECORD_COUNT, --ԭʼ�ļ�¼��
         NVL(SUM(CASE
                   WHEN RNK > 1 THEN
                    1
                   ELSE
                    0
                 END),
             0) AS DUP_RECORD_COUNT, --�ظ��ļ�¼��
         MIN(RECORD_SID) AS START_ROWID, --��ʼ�к�
         MAX(RECORD_SID) AS END_ROWID --��ֹ�к�
    INTO V_ORIG_RECORD_COUNT,
         V_DUP_RECORD_COUNT,
         V_START_ROWID,
         V_END_ROWID
    FROM TEMP_BOND_POSITION_OUT T;

  --ɾ���Ѿ����ڵ���������
  V_EXEC_STEP := 'STEP4 ɾ���Ѿ����ڵ���������';

  DELETE FROM BOND_POSITION_OUT T
   WHERE EXISTS
   (SELECT * FROM TEMP_BOND_POSITION_OUT A WHERE A.TSID = T.TSID);

  V_EXEC_STEP := 'STEP5 �������ݵ�Ŀ���';
  INSERT INTO BOND_POSITION_OUT
    (BOND_POSITION_OUT_SID, --1.  �����ֲ���ˮ��
     SECINNER_ID, --2.  ծȯ��ʶ��
     SECURITY_CD, --3.  ծȯ����
     SECURITY_NM, --4.  ծȯȫ��
     TRADE_MARKET_ID, --5.  �����г�
     TRUSTEE_NM, --6.  ί���������
     PORTFOLIO_CD, --7.  ��ϴ���
     PORTFOLIO_NM, --8.  �������
     END_DT, --9.  �ֲ�����
     CURRENCY, --10. ����
     AMT_COST, --11. �ֲ����-�ɱ���
     AMT_MARKETVALUE, --12. �ֲ����-��ֵ��
     POSITION_NUM, --13. �ֲ�����
     STRATEGY_L1, --14. ����1������
     STRATEGY_L2, --15. ����2������
     STRATEGY_L3, --16. ����3������
     IS_VALID, --17. �Ƿ���Ч
     TSID, --18. Ψһ��ʶ
     SRC_UPDT_DT, --19. Դ����ʱ��
     ISDEL, --20. �Ƿ�ɾ��
     UPDT_BY, --21. ������
     UPDT_DT --22. ����ʱ��
     )
    SELECT BOND_POSITION_OUT_SID, --1.  �����ֲ���ˮ��
           SECINNER_ID, --2.  ծȯ��ʶ��
           SECURITY_CD, --3.  ծȯ����
           SECURITY_NM, --4.  ծȯȫ��
           TRADE_MARKET_ID, --5.  �����г�
           TRUSTEE_NM, --6.  ί���������
           PORTFOLIO_CD, --7.  ��ϴ���
           PORTFOLIO_NM, --8.  �������
           END_DT, --9.  �ֲ�����
           CURRENCY, --10. ����
           AMT_COST, --11. �ֲ����-�ɱ���
           AMT_MARKETVALUE, --12. �ֲ����-��ֵ��
           POSITION_NUM, --13. �ֲ�����
           STRATEGY_L1, --14. ����1������
           STRATEGY_L2, --15. ����2������
           STRATEGY_L3, --16. ����3������
           IS_VALID, --17. �Ƿ���Ч
           TSID, --18. Ψһ��ʶ
           SRC_UPDT_DT, --19. Դ����ʱ��
           ISDEL, --20. �Ƿ�ɾ��
           UPDT_BY, --21. ������
           UPDT_DT --22. ����ʱ��
      FROM TEMP_BOND_POSITION_OUT T
     WHERE RNK = '1';

  V_INSERT_COUNT := SQL%ROWCOUNT;
  COMMIT;

  --�������ݵ�LOG����
  V_EXEC_STEP := 'STEP6 �������ݵ�LOG����';
  INSERT INTO ETL_TGT_LOADLOG
    (LOADLOG_SID,
     BATCH_SID,
     PROCESS_NM,
     ORIG_RECORD_COUNT,
     DUP_RECORD_COUNT,
     INSERT_COUNT,
     UPDT_COUNT,
     START_DT,
     END_DT,
     START_ROWID,
     END_ROWID)
  VALUES
    (SEQ_ETL_TGT_LOADLOG.NEXTVAL,
     0,
     V_TASK_NAME,
     V_ORIG_RECORD_COUNT,
     V_DUP_RECORD_COUNT,
     V_INSERT_COUNT,
     NVL(V_UPDT_COUNT, 0),
     V_START_DT,
     V_END_DT,
     V_START_ROWID,
     V_END_ROWID);
  COMMIT;

  --������
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    V_ERROR_CD      := SQLCODE;
    V_ERROR_MESSAGE := V_EXEC_STEP || SUBSTR(SQLERRM, 1, 900);
    DBMS_OUTPUT.PUT_LINE('failed! ERROR:' || V_ERROR_CD || ' ,' ||
                         V_ERROR_MESSAGE);
    RAISE_APPLICATION_ERROR(-20021, V_ERROR_MESSAGE);
    RETURN;

    COMMIT;

END SP_BOND_POSITION_OUT;
/

prompt
prompt Creating procedure SP_BOND_POSITION_OWN
prompt =======================================
prompt
CREATE OR REPLACE PROCEDURE SP_BOND_POSITION_OWN IS
  /*
  �洢���̣�SP_BOND_POSITION_OWN
  ��    �ܣ�����-�����ֲ�-������STG->TEMP->TGT��
            ��������ˮ��
            (�ͻ�+��Դ+�ͻ�����+�Ƿ���Ч)
  �� �� �ˣ�RayLee
  ����ʱ�䣺2017/11/9 10:25:27
  Դ    ��CS_MASTER_STG.STG_CMB_BOND_POSITIONOWN
  �� �� ��TEMP_BOND_POSITION_OWN
  Ŀ �� ��BOND_POSITION_OWN
  --------------------------------------------------------------------
  �� �� �ˣ�RayLee
  �޸�ʱ�䣺2017-12-28 14:27:05
  �޸����ݣ���ͬҵ��������ȡupdt_dt�ϴ󣬶���ͬһ���Σ�updt_dt��ͬ����ȡrecord_sid����ļ�¼
  */

  V_ERROR_CD          VARCHAR2(100);
  V_ERROR_MESSAGE     VARCHAR2(1000);
  V_TASK_NAME         ETL_TGT_LOADLOG.PROCESS_NM%TYPE; --��������
  V_UPDT_DT           ETL_TGT_LOADLOG.END_DT%TYPE; --�ϴ�ͬ������ʱ��
  V_START_DT          ETL_TGT_LOADLOG.START_DT%TYPE; --��ʼʱ��
  V_END_DT            ETL_TGT_LOADLOG.END_DT%TYPE; --����ʱ��
  V_START_ROWID       ETL_TGT_LOADLOG.START_ROWID%TYPE; --��ʼ�к�
  V_END_ROWID         ETL_TGT_LOADLOG.END_ROWID%TYPE; --��ֹ�к�
  V_INSERT_COUNT      ETL_TGT_LOADLOG.INSERT_COUNT%TYPE; --�����¼��
  V_UPDT_COUNT        ETL_TGT_LOADLOG.UPDT_COUNT%TYPE; --���¼�¼��
  V_ORIG_RECORD_COUNT NUMBER(16); --ԭʼ�ļ�¼��
  V_DUP_RECORD_COUNT  NUMBER(16); --�ظ��ļ�¼��

  --
  --V_SRC_CD  TEMP_BOND_POSITION_OWN.SRC_CD%TYPE := UPPER(TRIM('CMB'));
  V_UPDT_BY TEMP_BOND_POSITION_OWN.UPDT_BY%TYPE := 0;
  V_ISDEL   TEMP_BOND_POSITION_OWN.ISDEL%TYPE := 0;

  V_EXEC_STEP VARCHAR2(100);

BEGIN

  --��������
  V_TASK_NAME := 'SP_BOND_POSITION_OWN';

  --��ʼʱ��
  V_START_DT := SYSDATE;

  --��ȡ�ϴ�ͬ�����ݵ�ʱ��,����ǵ�һ������û�м�¼�ᷢ��NO_DATA_FOUND�쳣
  V_EXEC_STEP := 'STEP1 ��ȡ�ϴ�ͬ��ʱ��';
  BEGIN
    SELECT NVL(MAX(END_DT), TO_DATE('1900-1-1', 'yyyy-mm-dd'))
      INTO V_UPDT_DT
      FROM ETL_TGT_LOADLOG
     WHERE PROCESS_NM = V_TASK_NAME;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      V_UPDT_DT := TO_DATE('1900-1-1', 'yyyy-mm-dd');
  END;

  --��ȡ�����������ݲ��뵽��ʱ��
  V_EXEC_STEP := 'STEP2 ��ȡ�����������ݲ��뵽��ʱ��';
  INSERT INTO TEMP_BOND_POSITION_OWN
    (BOND_POSITION_OWN_SID, --1. �����ֲ���ˮ��
     SECINNER_ID, --2. ծȯ��ʶ��
     SECURITY_CD, --ծȯ���� 
     SECURITY_NM, --ծȯȫ��
     TRADE_MARKET_ID, --�����г�
     SECURITY_SNM, --ծȯ��� 
     PORTFOLIO_CD, --3. ��ϴ���
     PORTFOLIO_NM, --4. �������
     END_DT, --5. �ֲ�����
     CURRENCY, --6. ����
     AMT_COST, --7. �ֲ����-�ɱ���
     AMT_MARKETVALUE, --8. �ֲ����-��ֵ��
     POSITION_NUM, --9. �ֲ�����
     SRC_UPDT_DT, --10.  Դ����ʱ��
     ISDEL, --11.  �Ƿ�ɾ��
     UPDT_BY, --12.  ������
     RECORD_SID, --13.  ��ˮ��
     LOADLOG_SID, --14.  ��־��
     UPDT_DT, --15.  ����ʱ��
     RNK --16.  ��¼����
     )
    SELECT SEQ_BOND_POSITION_OWN.NEXTVAL AS BOND_POSITION_OWN_SID, --1. �����ֲ���ˮ��
           T1.SECINNER_ID AS SECINNER_ID, --2. ծȯ��ʶ��
           T.SECURITY_CD,--ծȯ���� 
           T.SECURITY_NM,--ծȯȫ��
           T1.TRADE_MARKET_ID,--�����г�
           T.SECURITY_SNM,--ծȯ��� 
           T.PORTFOLIO_CD AS PORTFOLIO_CD, --3. ��ϴ���
           T.PORTFOLIO_NM AS PORTFOLIO_NM, --4. �������
           TO_DATE(T.DATA_DT, 'YYYY-MM-DD') AS END_DT, --5. �ֲ�����
           T.CURRENCY AS CURRENCY, --6. ����
           T.AMT_COST AS AMT_COST, --7. �ֲ����-�ɱ���
           T.AMT_MARKETVALUE AS AMT_MARKETVALUE, --8. �ֲ����-��ֵ��
           T.POSITION_NUM AS POSITION_NUM, --9. �ֲ�����
           TO_DATE(T.SRC_UPDT_DT, 'YYYY-MM-DD') AS SRC_UPDT_DT, --10.  Դ����ʱ��
           V_ISDEL AS ISDEL, --11.  �Ƿ�ɾ��
           V_UPDT_BY AS UPDT_BY, --12.  ������
           T.RECORD_SID AS RECORD_SID, --13.  ��ˮ��
           T.LOADLOG_SID AS LOADLOG_SID, --14.  ��־��
           SYSTIMESTAMP AS UPDT_DT, --15.  ����ʱ��
           ROW_NUMBER() OVER(PARTITION BY T.SECURITY_CD, T.DATA_DT, T.PORTFOLIO_CD ORDER BY T.UPDT_DT DESC,T.RECORD_SID DESC) AS RNK --16.  ��¼����
      FROM CS_MASTER_STG.STG_CMB_BOND_POSITIONOWN T
      INNER JOIN (SELECT A.SECINNER_ID,
                        A.TRADE_MARKET_ID,
                        A.SECURITY_NM,
                        SUBSTR(C.MARKET_ABBR || A.SECURITY_CD, 2) AS SECURITY_CD
                   FROM BOND_BASICINFO A
                   LEFT JOIN LKP_CHARCODE B
                     ON A.TRADE_MARKET_ID = B.CONSTANT_ID
                    AND B.CONSTANT_TYPE = 206
                   LEFT JOIN LKP_MARKET_ABBR C
                     ON C.MARKET_CD = B.CONSTANT_CD
                 UNION ALL
                 SELECT A.SECINNER_ID,
                        A.TRADE_MARKET_ID,
                        A.SECURITY_NM,
                        'BK' || A.SECURITY_CD AS SECURITY_CD
                   FROM BOND_BASICINFO A
                   LEFT JOIN LKP_CHARCODE B
                     ON A.TRADE_MARKET_ID = B.CONSTANT_ID
                    AND B.CONSTANT_TYPE = 206
                   LEFT JOIN LKP_MARKET_ABBR C
                     ON C.MARKET_CD = B.CONSTANT_CD
                  WHERE C.MARKET_ABBR = '.IB') T1
        ON T1.SECURITY_CD = T.SECURITY_CD
     WHERE T.UPDT_DT > V_UPDT_DT;

  --����ʱ��
  V_END_DT := SYSDATE;

  --��ȡ��־����
  V_EXEC_STEP := 'STEP3 ��ȡ��־����';
  SELECT COUNT(1) AS ORIG_RECORD_COUNT, --ԭʼ�ļ�¼��
         NVL(SUM(CASE
                   WHEN RNK > 1 THEN
                    1
                   ELSE
                    0
                 END),
             0) AS DUP_RECORD_COUNT, --�ظ��ļ�¼��
         MIN(RECORD_SID) AS START_ROWID, --��ʼ�к�
         MAX(RECORD_SID) AS END_ROWID --��ֹ�к�
    INTO V_ORIG_RECORD_COUNT,
         V_DUP_RECORD_COUNT,
         V_START_ROWID,
         V_END_ROWID
    FROM TEMP_BOND_POSITION_OWN T;

  --ɾ���Ѿ����ڵ���������
  V_EXEC_STEP := 'STEP4 ɾ���Ѿ����ڵ���������';

  DELETE FROM BOND_POSITION_OWN T
   WHERE EXISTS (SELECT *
            FROM TEMP_BOND_POSITION_OWN A
           WHERE A.SECINNER_ID = T.SECINNER_ID
             AND A.END_DT = T.END_DT);

  V_EXEC_STEP := 'STEP5 �������ݵ�Ŀ���';
  INSERT INTO BOND_POSITION_OWN
    (BOND_POSITION_OWN_SID, --1. �����ֲ���ˮ��
     SECINNER_ID, --2. ծȯ��ʶ��
     SECURITY_CD, --ծȯ���� 
     SECURITY_NM, --ծȯȫ��
     TRADE_MARKET_ID, --�����г�
     SECURITY_SNM, --ծȯ��� 
     PORTFOLIO_CD, --3. ��ϴ���
     PORTFOLIO_NM, --4. �������
     END_DT, --5. �ֲ�����
     CURRENCY, --6. ����
     AMT_COST, --7. �ֲ����-�ɱ���
     AMT_MARKETVALUE, --8. �ֲ����-��ֵ��
     POSITION_NUM, --9. �ֲ�����
     SRC_UPDT_DT, --10.  Դ����ʱ��
     ISDEL, --11.  �Ƿ�ɾ��
     UPDT_BY, --12.  ������
     UPDT_DT --13.  ����ʱ��
     
     )
    SELECT BOND_POSITION_OWN_SID, --1. �����ֲ���ˮ��
           SECINNER_ID, --2. ծȯ��ʶ��
           SECURITY_CD, --ծȯ���� 
           SECURITY_NM, --ծȯȫ��
           TRADE_MARKET_ID, --�����г�
           SECURITY_SNM, --ծȯ��� 
           PORTFOLIO_CD, --3. ��ϴ���
           PORTFOLIO_NM, --4. �������
           END_DT, --5. �ֲ�����
           CURRENCY, --6. ����
           AMT_COST, --7. �ֲ����-�ɱ���
           AMT_MARKETVALUE, --8. �ֲ����-��ֵ��
           POSITION_NUM, --9. �ֲ�����
           SRC_UPDT_DT, --10.  Դ����ʱ��
           ISDEL, --11.  �Ƿ�ɾ��
           UPDT_BY, --12.  ������
           UPDT_DT --13.  ����ʱ��
      FROM TEMP_BOND_POSITION_OWN T
     WHERE RNK = '1';

  V_INSERT_COUNT := SQL%ROWCOUNT;
  COMMIT;

  --�������ݵ�LOG����
  V_EXEC_STEP := 'STEP6 �������ݵ�LOG����';
  INSERT INTO ETL_TGT_LOADLOG
    (LOADLOG_SID,
     BATCH_SID,
     PROCESS_NM,
     ORIG_RECORD_COUNT,
     DUP_RECORD_COUNT,
     INSERT_COUNT,
     UPDT_COUNT,
     START_DT,
     END_DT,
     START_ROWID,
     END_ROWID)
  VALUES
    (SEQ_ETL_TGT_LOADLOG.NEXTVAL,
     0,
     V_TASK_NAME,
     V_ORIG_RECORD_COUNT,
     V_DUP_RECORD_COUNT,
     V_INSERT_COUNT,
     NVL(V_UPDT_COUNT, 0),
     V_START_DT,
     V_END_DT,
     V_START_ROWID,
     V_END_ROWID);
  COMMIT;

  --������
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    V_ERROR_CD      := SQLCODE;
    V_ERROR_MESSAGE := V_EXEC_STEP || SUBSTR(SQLERRM, 1, 900);
    DBMS_OUTPUT.PUT_LINE('failed! ERROR:' || V_ERROR_CD || ' ,' ||
                         V_ERROR_MESSAGE);
    RAISE_APPLICATION_ERROR(-20021, V_ERROR_MESSAGE);
    RETURN;
  
    COMMIT;
  
END SP_BOND_POSITION_OWN;
/

prompt
prompt Creating procedure SP_BOND_POSITION_STRUCTURED
prompt ==============================================
prompt
CREATE OR REPLACE PROCEDURE SP_BOND_POSITION_STRUCTURED IS
  /*
  �洢���̣�SP_BOND_POSITION_STRUCTURED
  ��    �ܣ�����-�ṹ���ֲ�-������STG->TEMP->TGT��
            ��������ˮ��
            (�ͻ�+��Դ+�ͻ�����+�Ƿ���Ч)
  �� �� �ˣ�RayLee
  ����ʱ�䣺2017/11/9 10:25:27
  Դ    ��CS_MASTER_STG.STG_CMB_BOND_STRUCTURED
  �� �� ��TEMP_BOND_POSITION_STRUCTURED
  Ŀ �� ��BOND_POSITION_STRUCTURED
  --------------------------------------------------------------------
  �� �� �ˣ�RayLee
  �޸�ʱ�䣺2017-12-28 14:29:08
  �޸����ݣ���ͬҵ��������ȡupdt_dt�ϴ󣬶���ͬһ���Σ�updt_dt��ͬ����ȡrecord_sid����ļ�¼
  �� �� �ˣ�RayLee
  �޸�ʱ�䣺2018-01-02 15:34:34
  �޸����ݣ��޸ĳֲ����ڵ�ȡ���߼����޸�ҵ������ȥ�ص��߼�
  */

  V_ERROR_CD          VARCHAR2(100);
  V_ERROR_MESSAGE     VARCHAR2(1000);
  V_TASK_NAME         ETL_TGT_LOADLOG.PROCESS_NM%TYPE; --��������
  V_UPDT_DT           ETL_TGT_LOADLOG.END_DT%TYPE; --�ϴ�ͬ������ʱ��
  V_START_DT          ETL_TGT_LOADLOG.START_DT%TYPE; --��ʼʱ��
  V_END_DT            ETL_TGT_LOADLOG.END_DT%TYPE; --����ʱ��
  V_START_ROWID       ETL_TGT_LOADLOG.START_ROWID%TYPE; --��ʼ�к�
  V_END_ROWID         ETL_TGT_LOADLOG.END_ROWID%TYPE; --��ֹ�к�
  V_INSERT_COUNT      ETL_TGT_LOADLOG.INSERT_COUNT%TYPE; --�����¼��
  V_UPDT_COUNT        ETL_TGT_LOADLOG.UPDT_COUNT%TYPE; --���¼�¼��
  V_ORIG_RECORD_COUNT NUMBER(16); --ԭʼ�ļ�¼��
  V_DUP_RECORD_COUNT  NUMBER(16); --�ظ��ļ�¼��

  --
  --V_SRC_CD  TEMP_BOND_POSITION_STRUCTURED.SRC_CD%TYPE := UPPER(TRIM('CMB'));
  V_UPDT_BY   TEMP_BOND_POSITION_STRUCTURED.UPDT_BY%TYPE := 0;
  V_ISDEL     TEMP_BOND_POSITION_STRUCTURED.ISDEL%TYPE := 0;
  V_EXEC_STEP VARCHAR2(100);

BEGIN

  --��������
  V_TASK_NAME := 'SP_BOND_POSITION_STRUCTURED';

  --��ʼʱ��
  V_START_DT := SYSDATE;

  --��ȡ�ϴ�ͬ�����ݵ�ʱ��,����ǵ�һ������û�м�¼�ᷢ��NO_DATA_FOUND�쳣
  V_EXEC_STEP := 'STEP1 ��ȡ�ϴ�ͬ��ʱ��';
  BEGIN
    SELECT NVL(MAX(END_DT),TO_DATE('1900-1-1', 'yyyy-mm-dd'))
      INTO V_UPDT_DT
      FROM ETL_TGT_LOADLOG
     WHERE PROCESS_NM = V_TASK_NAME;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      V_UPDT_DT := TO_DATE('1900-1-1', 'yyyy-mm-dd');
  END;

  --��ȡ�����������ݲ��뵽��ʱ��
  V_EXEC_STEP := 'STEP2 ��ȡ�����������ݲ��뵽��ʱ��';
  INSERT INTO TEMP_BOND_POSITION_STRUCTURED
    (BOND_POSITION_STRUCTURED_SID, --1. �����ֲ���ˮ��
     SECINNER_ID, --2. ծȯ��ʶ��
     SECURITY_CD, --ծȯ����
     SECURITY_NM, --ծȯȫ��
     TRADE_MARKET_ID, --�����г�
     PORTFOLIO_CD, --3. ��ϴ���
     PORTFOLIO_NM, --4. �������
     END_DT, --5. �ֲ�����
     CURRENCY, --6. ����
     AMT_COST, --7. �ֲ����-�ɱ���
     AMT_MARKETVALUE, --8. �ֲ����-��ֵ��
     POSITION_NUM, --9. �ֲ�����
     STRATEGY_L1, --����1������
     STRATEGY_L2, --����2������
     STRATEGY_L3, --����3������
     IS_VALID, --�Ƿ���Ч
     TSID, --Ψһ��ʶ
     SRC_UPDT_DT, --10.  Դ����ʱ��
     ISDEL, --11.  �Ƿ�ɾ��
     UPDT_BY, --12.  ������
     UPDT_DT, --13.  ����ʱ��
     RECORD_SID, --14.  ��ˮ��
     LOADLOG_SID, --15.  ��־��
     RNK --16.
     )
    SELECT SEQ_BOND_POSITION_STRUCTURED.NEXTVAL AS BOND_POSITION_STRUCTURED_SID, --1. �����ֲ���ˮ��
           T1.SECINNER_ID AS SECINNER_ID, --2. ծȯ��ʶ��
           T.SECURITY_CD, --ծȯ����
           T1.SECURITY_NM, --ծȯȫ��
           T1.TRADE_MARKET_ID, --�����г�
           T.PORTFOLIO_CD AS PORTFOLIO_CD, --3. ��ϴ���
           T.PORTFOLIO_NM AS PORTFOLIO_NM, --4. �������
           TO_DATE(T.POSITION_DT, 'YYYY-MM-DD') AS END_DT, --5. �ֲ�����
           T.CURRENCY AS CURRENCY, --6. ����
           T.AMT_COST AS AMT_COST, --7. �ֲ����-�ɱ���
           T.AMT_MARKETVALUE AS AMT_MARKETVALUE, --8. �ֲ����-��ֵ��
           T.POSITION_NUM AS POSITION_NUM, --9. �ֲ�����
           T.CLS_01, --����1������
           T.CLS_02, --����2������
           T.CLS_03, --����3������
           TO_NUMBER(T.IS_VALID), --�Ƿ���Ч
           T.TSID, --Ψһ��ʶ
           to_timestamp(T.SRC_UPDT_DT, 'YYYY-MM-DD HH24:MI:SS.FF6') AS SRC_UPDT_DT, --10.  Դ����ʱ��
           V_ISDEL AS ISDEL, --11.  �Ƿ�ɾ��
           V_UPDT_BY AS UPDT_BY, --12.  ������
           SYSTIMESTAMP AS UPDT_DT, --13.  ����ʱ��
           T.RECORD_SID AS RECORD_SID, --14.  ��ˮ��
           T.LOADLOG_SID AS LOADLOG_SID, --15.  ��־��
           --ROW_NUMBER() OVER(PARTITION BY T.SECURITY_CD, T.PORFOLIO_CD, T.DATA_DT ORDER BY T.UPDT_DT DESC,T.RECORD_SID DESC) AS RNK --16.
           ROW_NUMBER()OVER(PARTITION BY T.TSID ORDER BY T.UPDT_DT DESC,T.RECORD_SID DESC) AS RNK
      FROM CS_MASTER_STG.STG_CMB_BOND_STRUCTURED T
     INNER JOIN (SELECT A.SECINNER_ID,
                        A.TRADE_MARKET_ID,
                        A.SECURITY_NM,
                        SUBSTR(C.MARKET_ABBR || A.SECURITY_CD, 2) AS SECURITY_CD
                   FROM BOND_BASICINFO A
                   LEFT JOIN LKP_CHARCODE B
                     ON A.TRADE_MARKET_ID = B.CONSTANT_ID
                    AND B.CONSTANT_TYPE = 206
                   LEFT JOIN LKP_MARKET_ABBR C
                     ON C.MARKET_CD = B.CONSTANT_CD
                 UNION ALL
                 SELECT A.SECINNER_ID,
                        A.TRADE_MARKET_ID,
                        A.SECURITY_NM,
                        'BK' || A.SECURITY_CD AS SECURITY_CD
                   FROM BOND_BASICINFO A
                   LEFT JOIN LKP_CHARCODE B
                     ON A.TRADE_MARKET_ID = B.CONSTANT_ID
                    AND B.CONSTANT_TYPE = 206
                   LEFT JOIN LKP_MARKET_ABBR C
                     ON C.MARKET_CD = B.CONSTANT_CD
                  WHERE C.MARKET_ABBR = '.IB') T1
        ON T1.SECURITY_CD = T.SECURITY_CD
     WHERE T.IS_VALID = '1'
       AND T.UPDT_DT > V_UPDT_DT;

  --����ʱ��
  V_END_DT := SYSDATE;

  --��ȡ��־����
  V_EXEC_STEP := 'STEP3 ��ȡ��־����';
  SELECT COUNT(1) AS ORIG_RECORD_COUNT, --ԭʼ�ļ�¼��
         NVL(SUM(CASE
                   WHEN RNK > 1 THEN
                    1
                   ELSE
                    0
                 END),
             0) AS DUP_RECORD_COUNT, --�ظ��ļ�¼��
         MIN(RECORD_SID) AS START_ROWID, --��ʼ�к�
         MAX(RECORD_SID) AS END_ROWID --��ֹ�к�
    INTO V_ORIG_RECORD_COUNT,
         V_DUP_RECORD_COUNT,
         V_START_ROWID,
         V_END_ROWID
    FROM TEMP_BOND_POSITION_STRUCTURED;

  --ɾ���Ѿ����ڵ���������
  V_EXEC_STEP := 'STEP4 ɾ���Ѿ����ڵ���������';

  DELETE FROM BOND_POSITION_STRUCTURED T
   WHERE EXISTS (SELECT *
            FROM TEMP_BOND_POSITION_STRUCTURED A
           WHERE T.SECINNER_ID = A.SECINNER_ID
             AND T.PORTFOLIO_CD = A.PORTFOLIO_CD
             AND T.END_DT = A.END_DT);

  V_EXEC_STEP := 'STEP5 �������ݵ�Ŀ���';
  INSERT INTO BOND_POSITION_STRUCTURED
    (BOND_POSITION_STRUCTURED_SID, --1. �����ֲ���ˮ��
     SECINNER_ID, --2. ծȯ��ʶ��
     SECURITY_CD, --ծȯ����
     SECURITY_NM, --ծȯȫ��
     TRADE_MARKET_ID, --�����г�
     PORTFOLIO_CD, --3. ��ϴ���
     PORTFOLIO_NM, --4. �������
     END_DT, --5. �ֲ�����
     CURRENCY, --6. ����
     AMT_COST, --7. �ֲ����-�ɱ���
     AMT_MARKETVALUE, --8. �ֲ����-��ֵ��
     POSITION_NUM, --9. �ֲ�����
     STRATEGY_L1,--����1������
     STRATEGY_L2,--����2������
     STRATEGY_L3,--����3������
     IS_VALID, --�Ƿ���Ч
     TSID,--Ψһ��ʶ
     SRC_UPDT_DT, --10.  Դ����ʱ��
     ISDEL, --11.  �Ƿ�ɾ��
     UPDT_BY, --12.  ������
     UPDT_DT --13.  ����ʱ��

     )
    SELECT BOND_POSITION_STRUCTURED_SID, --1. �����ֲ���ˮ��
           SECINNER_ID, --2. ծȯ��ʶ��
           SECURITY_CD, --ծȯ����
           SECURITY_NM, --ծȯȫ��
           TRADE_MARKET_ID, --�����г�
           T.PORTFOLIO_CD AS PORFOLIO_CD, --3. ��ϴ���
           PORTFOLIO_NM, --4. �������
           END_DT, --5. �ֲ�����
           CURRENCY, --6. ����
           AMT_COST, --7. �ֲ����-�ɱ���
           AMT_MARKETVALUE, --8. �ֲ����-��ֵ��
           POSITION_NUM, --9. �ֲ�����
           STRATEGY_L1,--����1������
           STRATEGY_L2,--����2������
           STRATEGY_L3,--����3������
           IS_VALID, --�Ƿ���Ч
           TSID,--Ψһ��ʶ
           SRC_UPDT_DT, --10.  Դ����ʱ��
           ISDEL, --11.  �Ƿ�ɾ��
           UPDT_BY, --12.  ������
           UPDT_DT --13.  ����ʱ��
      FROM TEMP_BOND_POSITION_STRUCTURED T
     WHERE RNK = '1';

  V_INSERT_COUNT := SQL%ROWCOUNT;
  COMMIT;

  --�������ݵ�LOG����
  V_EXEC_STEP := 'STEP6 �������ݵ�LOG����';
  INSERT INTO ETL_TGT_LOADLOG
    (LOADLOG_SID,
     BATCH_SID,
     PROCESS_NM,
     ORIG_RECORD_COUNT,
     DUP_RECORD_COUNT,
     INSERT_COUNT,
     UPDT_COUNT,
     START_DT,
     END_DT,
     START_ROWID,
     END_ROWID)
  VALUES
    (SEQ_ETL_TGT_LOADLOG.NEXTVAL,
     0,
     V_TASK_NAME,
     V_ORIG_RECORD_COUNT,
     V_DUP_RECORD_COUNT,
     V_INSERT_COUNT,
     NVL(V_UPDT_COUNT, 0),
     V_START_DT,
     V_END_DT,
     V_START_ROWID,
     V_END_ROWID);
  COMMIT;

  --������
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    V_ERROR_CD      := SQLCODE;
    V_ERROR_MESSAGE := V_EXEC_STEP || SUBSTR(SQLERRM, 1, 900);
    DBMS_OUTPUT.PUT_LINE('failed! ERROR:' || V_ERROR_CD || ' ,' ||
                         V_ERROR_MESSAGE);
    RAISE_APPLICATION_ERROR(-20021, V_ERROR_MESSAGE);
    RETURN;

    COMMIT;

END SP_BOND_POSITION_STRUCTURED;
/

prompt
prompt Creating procedure SP_COMPY_CREDITAPPLY_CMB
prompt ===========================================
prompt
CREATE OR REPLACE PROCEDURE sp_compy_creditapply_cmb IS
  /************************************************
  �洢���̣�sp_compy_creditapply_cmb
  ����ʱ�䣺2017/11/10
  �� �� �ˣ�ZhangCong
  Դ    ��stg_cmb_compy_creditapply(��������)
  �� �� ��temp_compy_creditapply_cmb
  Ŀ �� ��compy_creditapply_cmb(��������)
  ��    �ܣ�����ͬ��stg�µ������������ݵ�tgt��
  �޸ļ�¼��2017/12/25 zhangcong ������SP�������²����߼�
  
  *************************************************/

  --------------------------------������־����------------------------------
  v_error_cd          VARCHAR2(100);
  v_error_message     VARCHAR2(1000);
  v_task_name         etl_tgt_loadlog.process_nm%TYPE; --��������
  v_updt_dt           etl_tgt_loadlog.end_dt%TYPE; --�ϴ�ͬ������ʱ��
  v_start_dt          etl_tgt_loadlog.start_dt%TYPE; --��ʼʱ��
  v_end_dt            etl_tgt_loadlog.end_dt%TYPE; --����ʱ��
  v_start_rowid       etl_tgt_loadlog.start_rowid%TYPE; --��ʼ�к�
  v_end_rowid         etl_tgt_loadlog.end_rowid%TYPE; --��ֹ�к�
  v_insert_count      etl_tgt_loadlog.insert_count%TYPE; --�����¼��
  v_updt_count        etl_tgt_loadlog.updt_count%TYPE; --���¼�¼��
  v_orig_record_count etl_tgt_loadlog.orig_record_count%TYPE; --ԭʼ�ļ�¼��
  v_dup_record_count  etl_tgt_loadlog.dup_record_count%TYPE; --�ظ��ļ�¼��
  v_batch_sid         etl_tgt_loadlog.batch_sid%TYPE := 0; --���κ�

  --------------------------------����ҵ�����-------------------------------
  v_updt_by compy_creditapply_cmb.updt_by%TYPE := 0; --������
  v_isdel   compy_creditapply_cmb.isdel%TYPE := 0; --�Ƿ�ɾ��
  v_src_cd  compy_creditapply_cmb.src_cd%TYPE := 'CMB'; --Դϵͳ

BEGIN

  --��������
  v_task_name := 'SP_COMPY_CREDITAPPLY_CMB';

  --��ȡ�ϴ�ͬ�����ݵ�ʱ��
  SELECT nvl(MAX(end_dt), to_date('1900-1-1', 'yyyy-mm-dd'))
    INTO v_updt_dt
    FROM etl_tgt_loadlog
   WHERE process_nm = v_task_name;

  --��ʼʱ��
  v_start_dt := SYSDATE;

  --��ȡ�����������ݲ��뵽��ʱ��
  INSERT INTO temp_compy_creditapply_cmb
    (creditapply_id,
     company_id,
     submit_dt,
     operate_orgid,
     operate_orgnm,
     term_month,
     exposure_amt,
     nominal_amt,
     is_lowrisk,
     apply_status,
     apply_comment,
     apply_final_cd,
     creditline_type_cd,
     business_cd,
     sub_business_cd,
     final_exposure_amt,
     final_nominal_amt,
     isdel,
     src_company_cd,
     src_cd,
     updt_by,
     updt_dt,
     rnk,
     record_sid,
     loadlog_sid)
    SELECT a.creditapply_id,
           b.company_id,
           to_date(a.submit_dt, 'yyyy-mm-dd hh24:mi;ss') AS submit_dt,
           to_number(a.operate_orgid) AS operate_orgid,
           operate_orgnm,
           to_number(term_month) AS term_month,
           CAST(a.exposure_amt AS NUMBER(38, 9)) AS exposure_amt,
           CAST(a.nominal_amt AS NUMBER(38, 9)) AS nominal_amt,
           to_number(a.is_lowrisk) AS is_lowrisk,
           apply_status,
           apply_comment,
           apply_final_cd,
           creditline_type_cd,
           business_cd,
           sub_business_cd,
           CAST(a.final_exposure_amt AS NUMBER(38, 9)) AS final_exposure_amt,
           CAST(a.final_nominal_amt AS NUMBER(38, 9)) AS final_nominal_amt,
           v_isdel AS isdel,
           a.cust_no AS src_company_cd,
           v_src_cd AS src_cd,
           v_updt_by AS updt_by,
           systimestamp AS updt_dt,
           row_number() over(PARTITION BY a.creditapply_id ORDER BY a.updt_dt DESC, a.record_sid DESC) rnk, --ȥ��
           a.record_sid,
           a.loadlog_sid
      FROM cs_master_stg.stg_cmb_compy_creditapply a
      JOIN customer_cmb b
        ON (a.cust_no = b.cust_no AND b.company_id IS NOT NULL)
     WHERE a.updt_dt > v_updt_dt;

  --����ʱ��
  v_end_dt := SYSDATE;

  --��ȡ��־����
  SELECT COUNT(1) AS orig_record_count, --ԭʼ�ļ�¼��
         nvl(SUM(CASE
                   WHEN rnk > 1 THEN
                    1
                   ELSE
                    0
                 END),
             0) AS dup_record_count, --�ظ��ļ�¼��
         MIN(record_sid) AS start_rowid, --��ʼ�к�
         MAX(record_sid) AS end_rowid --��ֹ�к�
    INTO v_orig_record_count, v_dup_record_count, v_start_rowid, v_end_rowid
    FROM temp_compy_creditapply_cmb;

  --ɾ�������µ�����
  DELETE FROM compy_creditapply_cmb a
   WHERE EXISTS (SELECT 1
            FROM temp_compy_creditapply_cmb cdm
           WHERE a.creditapply_id = cdm.creditapply_id);

  v_updt_count := SQL%ROWCOUNT;

  --������������
  INSERT INTO compy_creditapply_cmb
    (creditapply_id,
     company_id,
     submit_dt,
     operate_orgid,
     operate_orgnm,
     term_month,
     exposure_amt,
     nominal_amt,
     is_lowrisk,
     apply_status,
     apply_comment,
     apply_final_cd,
     creditline_type_cd,
     business_cd,
     sub_business_cd,
     final_exposure_amt,
     final_nominal_amt,
     isdel,
     src_company_cd,
     src_cd,
     updt_by,
     updt_dt)
    SELECT a.creditapply_id,
           a.company_id,
           a.submit_dt,
           a.operate_orgid,
           a.operate_orgnm,
           a.term_month,
           a.exposure_amt,
           a.nominal_amt,
           a.is_lowrisk,
           a.apply_status,
           a.apply_comment,
           a.apply_final_cd,
           a.creditline_type_cd,
           a.business_cd,
           a.sub_business_cd,
           a.final_exposure_amt,
           a.final_nominal_amt,
           a.isdel,
           a.src_company_cd,
           a.src_cd,
           a.updt_by,
           a.updt_dt
      FROM temp_compy_creditapply_cmb a
     WHERE a.company_id IS NOT NULL
       AND a.rnk = 1;

  v_insert_count := SQL%ROWCOUNT - v_updt_count;

  COMMIT;

  --�������ݵ�LOG����

  INSERT INTO etl_tgt_loadlog
    (loadlog_sid,
     batch_sid,
     process_nm,
     orig_record_count,
     dup_record_count,
     insert_count,
     updt_count,
     start_dt,
     end_dt,
     start_rowid,
     end_rowid)
    SELECT seq_etl_tgt_loadlog.nextval,
           v_batch_sid,
           v_task_name,
           v_orig_record_count,
           v_dup_record_count,
           v_insert_count,
           v_updt_count,
           v_start_dt,
           v_end_dt,
           v_start_rowid,
           v_end_rowid
      FROM dual;

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
  
END sp_compy_creditapply_cmb;
/

prompt
prompt Creating procedure SP_COMPY_CREDITINFO_CMB
prompt ==========================================
prompt
CREATE OR REPLACE PROCEDURE sp_compy_creditinfo_cmb IS
  /************************************************
  �洢���̣�sp_compy_creditinfo_cmb
  ����ʱ�䣺2017/11/10
  �� �� �ˣ�ZhangCong
  Դ    ��stg_cmb_compy_creditinfo(�������)
  �� �� ��temp_compy_creditinfo_cmb
  Ŀ �� ��compy_creditinfo_cmb(�������)
  ��    �ܣ�����ͬ��stg�µ�����������ݵ�tgt��
  �޸ļ�¼��2017/12/25 zhangcong ������SP�������²����߼�
  
  *************************************************/

  --------------------------------������־����-----------------------------
  v_error_cd          VARCHAR2(100);
  v_error_message     VARCHAR2(1000);
  v_task_name         etl_tgt_loadlog.process_nm%TYPE; --��������
  v_updt_dt           etl_tgt_loadlog.end_dt%TYPE; --�ϴ�ͬ������ʱ��
  v_start_dt          etl_tgt_loadlog.start_dt%TYPE; --��ʼʱ��
  v_end_dt            etl_tgt_loadlog.end_dt%TYPE; --����ʱ��
  v_start_rowid       etl_tgt_loadlog.start_rowid%TYPE; --��ʼ�к�
  v_end_rowid         etl_tgt_loadlog.end_rowid%TYPE; --��ֹ�к�
  v_insert_count      etl_tgt_loadlog.insert_count%TYPE; --�����¼��
  v_updt_count        etl_tgt_loadlog.updt_count%TYPE; --���¼�¼��
  v_orig_record_count etl_tgt_loadlog.orig_record_count%TYPE; --ԭʼ�ļ�¼��
  v_dup_record_count  etl_tgt_loadlog.dup_record_count%TYPE; --�ظ��ļ�¼��
  v_batch_sid         etl_tgt_loadlog.batch_sid%TYPE := 0; --���κ�

  --------------------------------����ҵ�����------------------------------
  v_updt_by compy_creditapply_cmb.updt_by%TYPE := 0; --������
  v_isdel   compy_creditapply_cmb.isdel%TYPE := 0; --�Ƿ�ɾ��
  v_src_cd  compy_creditapply_cmb.src_cd%TYPE := 'CMB'; --Դϵͳ

BEGIN

  --��������
  v_task_name := 'SP_COMPY_CREDITINFO_CMB';

  --��ȡ�ϴ�ͬ�����ݵ�ʱ��
  SELECT nvl(MAX(end_dt), to_date('1900-1-1', 'yyyy-mm-dd'))
    INTO v_updt_dt
    FROM etl_tgt_loadlog
   WHERE process_nm = v_task_name;

  --��ʼʱ��
  v_start_dt := SYSDATE;

  --��ȡ�����������ݲ��뵽��ʱ��
  INSERT INTO temp_compy_creditinfo_cmb
    (creditinfo_id,
     company_id,
     exposure_amt,
     nominal_amt,
     exposure_balance,
     exposure_remain,
     start_dt,
     end_dt,
     is_cmbrelatecust,
     creditline_type_cd,
     is_lowrisk,
     use_org_id,
     use_org_nm,
     loan_mode_cd,
     credit_status_cd,
     is_exposure,
     currency,
     total_loan_amt,
     business_balance,
     term_month,
     guaranty_type_cd,
     isdel,
     src_company_cd,
     src_cd,
     updt_by,
     updt_dt,
     rnk,
     record_sid,
     loadlog_sid)
    SELECT a.creditinfo_id,
           b.company_id,
           CAST(a.exposure_amt AS NUMBER(24, 4)) AS exposure_amt,
           CAST(a.nominal_amt AS NUMBER(24, 4)) AS nominal_amt,
           CAST(a.exposure_balance AS NUMBER(24, 4)) AS exposure_balance,
           CAST(a.exposure_remain AS NUMBER(24, 4)) AS exposure_remain,
           to_date(a.start_dt, 'yyyy-mm-dd hh24:mi;ss') AS start_dt,
           to_date(a.end_dt, 'yyyy-mm-dd hh24:mi;ss') AS end_dt,
           to_number(a.is_cmbrelatecust) AS is_cmbrelatecust,
           a.creditline_type_cd,
           to_number(a.is_lowrisk) AS is_lowrisk,
           to_number(a.use_org_id) AS use_org_id,
           a.use_org_nm,
           a.loan_mode_cd,
           a.credit_status_cd,
           to_number(a.is_exposure) AS is_exposure,
           a.currency,
           CAST(a.total_loan_amt AS NUMBER(24, 4)) AS total_loan_amt,
           CAST(a.business_balance AS NUMBER(24, 4)) AS business_balance,
           to_number(a.term_month) AS term_month,
           a.guaranty_type_cd,
           v_isdel AS isdel,
           a.cust_no AS src_company_cd,
           v_src_cd AS src_cd,
           v_updt_by AS updt_by,
           systimestamp AS updt_dt,
           row_number() over(PARTITION BY a.creditinfo_id ORDER BY a.updt_dt DESC, a.record_sid DESC) rnk, --ȥ��
           a.record_sid,
           a.loadlog_sid
      FROM cs_master_stg.stg_cmb_compy_creditinfo a
      JOIN customer_cmb b
        ON (a.cust_no = b.cust_no AND b.company_id IS NOT NULL)
     WHERE a.updt_dt > v_updt_dt;

  --����ʱ��
  v_end_dt := SYSDATE;

  --��ȡ��־����
  SELECT COUNT(1) AS orig_record_count, --ԭʼ�ļ�¼��
         nvl(SUM(CASE
                   WHEN rnk > 1 THEN
                    1
                   ELSE
                    0
                 END),
             0) AS dup_record_count, --�ظ��ļ�¼��
         MIN(record_sid) AS start_rowid, --��ʼ�к�
         MAX(record_sid) AS end_rowid --��ֹ�к�
    INTO v_orig_record_count, v_dup_record_count, v_start_rowid, v_end_rowid
    FROM temp_compy_creditinfo_cmb;

  --ɾ�������µ�����
  DELETE FROM compy_creditinfo_cmb a
   WHERE EXISTS (SELECT 1
            FROM temp_compy_creditinfo_cmb cdm
           WHERE a.creditinfo_id = cdm.creditinfo_id);

  v_updt_count := SQL%ROWCOUNT;

  --������������
  INSERT INTO compy_creditinfo_cmb
    (creditinfo_id,
     company_id,
     exposure_amt,
     nominal_amt,
     exposure_balance,
     exposure_remain,
     start_dt,
     end_dt,
     is_cmbrelatecust,
     creditline_type_cd,
     is_lowrisk,
     use_org_id,
     use_org_nm,
     loan_mode_cd,
     credit_status_cd,
     is_exposure,
     currency,
     total_loan_amt,
     business_balance,
     term_month,
     guaranty_type_cd,
     isdel,
     src_company_cd,
     src_cd,
     updt_by,
     updt_dt)
    SELECT a.creditinfo_id,
           a.company_id,
           a.exposure_amt,
           a.nominal_amt,
           a.exposure_balance,
           a.exposure_remain,
           a.start_dt,
           a.end_dt,
           a.is_cmbrelatecust,
           a.creditline_type_cd,
           a.is_lowrisk,
           a.use_org_id,
           a.use_org_nm,
           a.loan_mode_cd,
           a.credit_status_cd,
           a.is_exposure,
           a.currency,
           a.total_loan_amt,
           a.business_balance,
           a.term_month,
           a.guaranty_type_cd,
           a.isdel,
           a.src_company_cd,
           a.src_cd,
           a.updt_by,
           a.updt_dt
      FROM temp_compy_creditinfo_cmb a
     WHERE a.company_id IS NOT NULL
       AND a.rnk = 1;

  v_insert_count := SQL%ROWCOUNT - v_updt_count;

  COMMIT;

  --�������ݵ�LOG����

  INSERT INTO etl_tgt_loadlog
    (loadlog_sid,
     batch_sid,
     process_nm,
     orig_record_count,
     dup_record_count,
     insert_count,
     updt_count,
     start_dt,
     end_dt,
     start_rowid,
     end_rowid)
    SELECT seq_etl_tgt_loadlog.nextval,
           v_batch_sid,
           v_task_name,
           v_orig_record_count,
           v_dup_record_count,
           v_insert_count,
           v_updt_count,
           v_start_dt,
           v_end_dt,
           v_start_rowid,
           v_end_rowid
      FROM dual;

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
  
END sp_compy_creditinfo_cmb;
/

prompt
prompt Creating procedure SP_COMPY_CREDITRATING_CMB
prompt ============================================
prompt
CREATE OR REPLACE PROCEDURE sp_compy_creditrating_cmb IS
  /************************************************
  �洢���̣�sp_compy_creditrating_cmb
  ����ʱ�䣺2017/11/10
  �� �� �ˣ�ZhangCong
  Դ    ��stg_cmb_compy_creditrating(��������)
  �� �� ��temp_compy_creditrating_cmb
  Ŀ �� ��compy_creditrating_cmb(��������)
  ��    �ܣ�����ͬ��stg�µ������������ݵ�tgt��
  �޸ļ�¼��2017/12/25 zhangcong ������SP�������²����߼�
  
  *************************************************/

  --------------------------------������־����-----------------------------
  v_error_cd          VARCHAR2(100);
  v_error_message     VARCHAR2(1000);
  v_task_name         etl_tgt_loadlog.process_nm%TYPE; --��������
  v_updt_dt           etl_tgt_loadlog.end_dt%TYPE; --�ϴ�ͬ������ʱ��
  v_start_dt          etl_tgt_loadlog.start_dt%TYPE; --��ʼʱ��
  v_end_dt            etl_tgt_loadlog.end_dt%TYPE; --����ʱ��
  v_start_rowid       etl_tgt_loadlog.start_rowid%TYPE; --��ʼ�к�
  v_end_rowid         etl_tgt_loadlog.end_rowid%TYPE; --��ֹ�к�
  v_insert_count      etl_tgt_loadlog.insert_count%TYPE; --�����¼��
  v_updt_count        etl_tgt_loadlog.updt_count%TYPE; --���¼�¼��
  v_orig_record_count etl_tgt_loadlog.orig_record_count%TYPE; --ԭʼ�ļ�¼��
  v_dup_record_count  etl_tgt_loadlog.dup_record_count%TYPE; --�ظ��ļ�¼��
  v_batch_sid         etl_tgt_loadlog.batch_sid%TYPE := 0; --���κ�

  --------------------------------����ҵ�����------------------------------
  v_updt_by compy_creditapply_cmb.updt_by%TYPE := 0; --������
  v_isdel   compy_creditapply_cmb.isdel%TYPE := 0; --�Ƿ�ɾ��
  v_src_cd  compy_creditapply_cmb.src_cd%TYPE := 'CMB'; --Դϵͳ

BEGIN

  --��������
  v_task_name := 'SP_COMPY_CREDITRATING_CMB';

  --��ȡ�ϴ�ͬ�����ݵ�ʱ��
  SELECT nvl(MAX(end_dt), to_date('1900-1-1', 'yyyy-mm-dd'))
    INTO v_updt_dt
    FROM etl_tgt_loadlog
   WHERE process_nm = v_task_name;

  --��ʼʱ��
  v_start_dt := SYSDATE;

  --��ȡ�����������ݲ��뵽��ʱ��
  INSERT INTO temp_compy_creditrating_cmb
    (rating_no,
     company_id,
     auto_rating,
     final_rating,
     rating_period,
     rating_start_dt,
     effect_end_dt,
     autorating_avgpd,
     finalrating_avgpd,
     adjust_reasontype_cd,
     adjust_reason,
     isdel,
     src_company_cd,
     src_cd,
     updt_by,
     updt_dt,
     rnk,
     record_sid,
     loadlog_sid)
    SELECT substr(a.rating_no, 1, 30) AS rating_no,
           b.company_id,
           a.auto_rating,
           a.final_rating,
           to_date(a.rating_period, 'yyyy/mm') AS rating_period,
           to_timestamp(a.rating_start_dt, 'yyyy-mm-dd hh24:mi:ss.FF6') AS rating_start_dt,
           to_timestamp(a.effect_end_dt, 'yyyy-mm-dd hh24:mi:ss.FF6') AS rating_start_dt,
           CAST(a.autorating_avgpd AS NUMBER(24, 4)) AS autorating_avgpd,
           CAST(a.finalrating_avgpd AS NUMBER(24, 4)) AS finalrating_avgpd,
           a.adjust_reasontype_cd,
           a.adjust_reason,
           v_isdel AS isdel,
           a.cust_no AS src_company_cd,
           v_src_cd AS src_cd,
           v_updt_by AS updt_by,
           systimestamp AS updt_dt,
           row_number() over(PARTITION BY a.rating_no ORDER BY a.updt_dt DESC,a.record_sid DESC) rnk, --ȥ��
           a.record_sid,
           a.loadlog_sid
      FROM cs_master_stg.stg_cmb_compy_creditrating a
      JOIN customer_cmb b
        ON (a.cust_no = b.cust_no AND b.company_id IS NOT NULL)
     WHERE a.updt_dt > v_updt_dt;

  --����ʱ��
  v_end_dt := SYSDATE;

  --��ȡ��־����
  SELECT COUNT(1) AS orig_record_count, --ԭʼ�ļ�¼��
         nvl(SUM(CASE
                   WHEN rnk > 1 THEN
                    1
                   ELSE
                    0
                 END),
             0) AS dup_record_count, --�ظ��ļ�¼��
         MIN(record_sid) AS start_rowid, --��ʼ�к�
         MAX(record_sid) AS end_rowid --��ֹ�к�
    INTO v_orig_record_count, v_dup_record_count, v_start_rowid, v_end_rowid
    FROM temp_compy_creditrating_cmb;

  --ɾ�������µ�����
  DELETE FROM compy_creditrating_cmb a
   WHERE EXISTS
   (SELECT 1 FROM temp_compy_creditrating_cmb cdm WHERE a.rating_no = cdm.rating_no);

  v_updt_count := SQL%ROWCOUNT;

  --������������
  INSERT INTO compy_creditrating_cmb
    (rating_no,
     company_id,
     auto_rating,
     final_rating,
     rating_period,
     rating_start_dt,
     effect_end_dt,
     autorating_avgpd,
     finalrating_avgpd,
     adjust_reasontype_cd,
     adjust_reason,
     isdel,
     src_company_cd,
     src_cd,
     updt_by,
     updt_dt)
    SELECT a.rating_no,
           a.company_id,
           a.auto_rating,
           a.final_rating,
           a.rating_period,
           a.rating_start_dt,
           a.effect_end_dt,
           a.autorating_avgpd,
           a.finalrating_avgpd,
           a.adjust_reasontype_cd,
           a.adjust_reason,
           a.isdel,
           a.src_company_cd,
           a.src_cd,
           a.updt_by,
           a.updt_dt
      FROM temp_compy_creditrating_cmb a
     WHERE a.company_id IS NOT NULL
       AND a.rnk = 1;

  v_insert_count := SQL%ROWCOUNT - v_updt_count;

  COMMIT;

  --�������ݵ�LOG����

  INSERT INTO etl_tgt_loadlog
    (loadlog_sid,
     batch_sid,
     process_nm,
     orig_record_count,
     dup_record_count,
     insert_count,
     updt_count,
     start_dt,
     end_dt,
     start_rowid,
     end_rowid)
    SELECT seq_etl_tgt_loadlog.nextval,
           v_batch_sid,
           v_task_name,
           v_orig_record_count,
           v_dup_record_count,
           v_insert_count,
           v_updt_count,
           v_start_dt,
           v_end_dt,
           v_start_rowid,
           v_end_rowid
      FROM dual;

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
  
END sp_compy_creditrating_cmb;
/

prompt
prompt Creating procedure SP_COMPY_GROUPGRAPH_CMB
prompt ==========================================
prompt
CREATE OR REPLACE PROCEDURE SP_COMPY_GROUPGRAPH_CMB IS
  /*
  �洢���̣�SP_COMPY_GROUPGRAPH_CMB
  ��    �ܣ�����-��������ͼ��-������STG->TEMP->TGT��
            �������ֹɻ������ĺ�+���ֹɻ������ĺ�+��ϵ����
  �� �� �ˣ�RayLee
  ����ʱ�䣺2017/11/9 10:25:27
  Դ    ��CS_MASTER_STG.STG_CMB_COMPY_GROUPGRAPH
  �� �� ��TEMP_COMPY_GROUPGRAPH_CMB
  Ŀ �� ��COMPY_GROUPGRAPH_CMB
  --------------------------------------------------------------------
  �� �� �ˣ�RayLee
  �޸�ʱ�䣺2017-12-28 14:21:06
  �޸����ݣ���ͬҵ��������ȡupdt_dt�ϴ󣬶���ͬһ���Σ�updt_dt��ͬ����ȡrecord_sid����ļ�¼
  */

  V_ERROR_CD          VARCHAR2(100);
  V_ERROR_MESSAGE     VARCHAR2(1000);
  V_TASK_NAME         ETL_TGT_LOADLOG.PROCESS_NM%TYPE; --��������
  V_UPDT_DT           ETL_TGT_LOADLOG.END_DT%TYPE; --�ϴ�ͬ������ʱ��
  V_START_DT          ETL_TGT_LOADLOG.START_DT%TYPE; --��ʼʱ��
  V_END_DT            ETL_TGT_LOADLOG.END_DT%TYPE; --����ʱ��
  V_START_ROWID       ETL_TGT_LOADLOG.START_ROWID%TYPE; --��ʼ�к�
  V_END_ROWID         ETL_TGT_LOADLOG.END_ROWID%TYPE; --��ֹ�к�
  V_INSERT_COUNT      ETL_TGT_LOADLOG.INSERT_COUNT%TYPE; --�����¼��
  V_UPDT_COUNT        ETL_TGT_LOADLOG.UPDT_COUNT%TYPE; --���¼�¼��
  V_ORIG_RECORD_COUNT NUMBER(16); --ԭʼ�ļ�¼��
  V_DUP_RECORD_COUNT  NUMBER(16); --�ظ��ļ�¼��

  --
  V_SRC_CD  TEMP_COMPY_WARNLEVELCHG_CMB.SRC_CD%TYPE := UPPER(TRIM('CMB'));
  V_UPDT_BY TEMP_COMPY_WARNLEVELCHG_CMB.UPDT_BY%TYPE := 0;
  V_ISDEL TEMP_COMPY_GROUPGRAPH_CMB.ISDEL%TYPE := 0;

  V_EXEC_STEP VARCHAR2(100);

BEGIN

  --��������
  V_TASK_NAME := 'SP_COMPY_GROUPGRAPH_CMB';

  --��ʼʱ��
  V_START_DT := SYSDATE;

  --��ȡ�ϴ�ͬ�����ݵ�ʱ��,����ǵ�һ������û�м�¼�ᷢ��NO_DATA_FOUND�쳣
  V_EXEC_STEP := 'STEP1 ��ȡ�ϴ�ͬ��ʱ��';
  
  BEGIN
    SELECT NVL(MAX(END_DT),TO_DATE('1900-1-1', 'yyyy-mm-dd'))
      INTO V_UPDT_DT
      FROM ETL_TGT_LOADLOG
     WHERE PROCESS_NM = V_TASK_NAME;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      V_UPDT_DT := TO_DATE('1900-1-1', 'yyyy-mm-dd');
  END;

  --��ȡ�����������ݲ��뵽��ʱ��
  V_EXEC_STEP := 'STEP2 ��ȡ�����������ݲ��뵽��ʱ��';
  
  INSERT INTO TEMP_COMPY_GROUPGRAPH_CMB
    (COMPY_GROUPGRAPH_SID, --1. ����ҵ����
     --COMPANY_ID, --2. ��ҵ��ʶ��    
     FATHER_CUST_NO, --3. �ֹɻ������Ŀͻ���
     CHILD_CUST_NO, --4. ���ֹɻ���ҵ��
     RELATION_TYPE_CD, --5. ������ϵ
     DIRECT_SHRATIO, --6. ֱ�ӳֹɱ���
     REMARK, --7. ��ע
     ISDEL, --8. �Ƿ�ɾ��
     SRC_COMPANY_CD, --9. Դ��ҵ����
     SRC_CD, --10.  Դϵͳ
     UPDT_BY, --11.  ������
     UPDT_DT, --12.  ����ʱ��
     RNK ,--13.  ��¼����
     RECORD_SID,  --14.��ˮ��
     LOADLOG_SID  --15.��־��
     )
    SELECT SEQ_COMPY_GROUPGRAPH_CMB.NEXTVAL AS COMPY_GROUPGRAPH_SID, --1. ����ҵ����
           --T1.COMPANY_ID AS COMPANY_ID, --2. ��ҵ��ʶ��
           T.FATHER_CUST_NO AS FATHER_CUST_NO, --3. �ֹɻ������Ŀͻ���
           T.CHILD_CUST_NO AS CHILD_CUST_NO, --4. ���ֹɻ���ҵ��
           T.RELTYPE_CD AS RELATION_TYPE_CD, --5. ������ϵ
           T.SH_RATIO AS DIRECT_SHRATIO, --6. ֱ�ӳֹɱ���
           T.REMARK AS REMARK, --7. ��ע
           V_ISDEL AS ISDEL, --8. �Ƿ�ɾ��
           T.FATHER_CUST_NO AS SRC_COMPANY_CD, --9. Դ��ҵ����
           V_SRC_CD AS SRC_CD, --10.  Դϵͳ
           V_UPDT_BY AS UPDT_BY, --11.  ������
           SYSTIMESTAMP AS UPDT_DT, --12.  ����ʱ��
           ROW_NUMBER() OVER(PARTITION BY T.FATHER_CUST_NO, T.CHILD_CUST_NO, T.RELTYPE_CD ORDER BY T.UPDT_DT DESC, T.RECORD_SID DESC) AS RNK, --13.  ��¼����
           T.RECORD_SID AS RECORD_SID,  --14.��ˮ��
           T.LOADLOG_SID AS LOADLOG_SID  --15.��־��
      FROM CS_MASTER_STG.STG_CMB_COMPY_GROUPGRAPH T
     WHERE T.UPDT_DT > V_UPDT_DT;

  --����ʱ��
  V_END_DT := SYSDATE;

  --��ȡ��־����
  V_EXEC_STEP := 'STEP3 ��ȡ��־����';
  
  SELECT COUNT(1) AS ORIG_RECORD_COUNT, --ԭʼ�ļ�¼��
         NVL(SUM(CASE
                   WHEN RNK > 1 THEN
                    1
                   ELSE
                    0
                 END),
             0) AS DUP_RECORD_COUNT, --�ظ��ļ�¼��
         MIN(RECORD_SID) AS START_ROWID, --��ʼ�к�
         MAX(RECORD_SID) AS END_ROWID --��ֹ�к�
    INTO V_ORIG_RECORD_COUNT,
         V_DUP_RECORD_COUNT,
         V_START_ROWID,
         V_END_ROWID
    FROM TEMP_COMPY_GROUPGRAPH_CMB;

  --ɾ���Ѿ����ڵ���������
  V_EXEC_STEP := 'STEP4 ɾ���Ѿ����ڵ���������';
  --��������ҵ��ʶ��+�������ſͻ���+�϶�����+�϶�ʱ��

  DELETE FROM COMPY_GROUPGRAPH_CMB A
   WHERE EXISTS (SELECT 1
            FROM COMPY_GROUPGRAPH_CMB B
           WHERE A.FATHER_CUST_NO = B.FATHER_CUST_NO
             AND A.CHILD_CUST_NO = B.CHILD_CUST_NO
             AND A.RELATION_TYPE_CD = B.RELATION_TYPE_CD);

  V_EXEC_STEP := 'STEP5 �������ݵ�Ŀ���';
  
  INSERT INTO COMPY_GROUPGRAPH_CMB
    (COMPY_GROUPGRAPH_SID, --1. ����ҵ����
     --COMPANY_ID, --2. ��ҵ��ʶ��
     FATHER_CUST_NO, --3. �ֹɻ������Ŀͻ���
     CHILD_CUST_NO, --4. ���ֹɻ���ҵ��
     RELATION_TYPE_CD, --5. ������ϵ
     DIRECT_SHRATIO, --6. ֱ�ӳֹɱ���
     REMARK, --7. ��ע
     ISDEL, --8. �Ƿ�ɾ��
     SRC_COMPANY_CD, --9. Դ��ҵ����
     SRC_CD, --10.  Դϵͳ
     UPDT_BY, --11.  ������
     UPDT_DT --12.  ����ʱ��
     )
    SELECT COMPY_GROUPGRAPH_SID, --1. ����ҵ����
           --COMPANY_ID, --2. ��ҵ��ʶ��
           FATHER_CUST_NO, --3. �ֹɻ������Ŀͻ���
           CHILD_CUST_NO, --4. ���ֹɻ���ҵ��
           RELATION_TYPE_CD, --5. ������ϵ
           DIRECT_SHRATIO, --6. ֱ�ӳֹɱ���
           REMARK, --7. ��ע
           ISDEL, --8. �Ƿ�ɾ��
           SRC_COMPANY_CD, --9. Դ��ҵ����
           SRC_CD, --10.  Դϵͳ
           UPDT_BY, --11.  ������
           UPDT_DT --12.  ����ʱ��
      FROM TEMP_COMPY_GROUPGRAPH_CMB T
     WHERE RNK = '1';

  V_INSERT_COUNT := SQL%ROWCOUNT;
  COMMIT;

  --�������ݵ�LOG����
  V_EXEC_STEP := 'STEP6 �������ݵ�LOG����';
  
  INSERT INTO ETL_TGT_LOADLOG
    (LOADLOG_SID,
     BATCH_SID,
     PROCESS_NM,
     ORIG_RECORD_COUNT,
     DUP_RECORD_COUNT,
     INSERT_COUNT,
     UPDT_COUNT,
     START_DT,
     END_DT,
     START_ROWID,
     END_ROWID)
  VALUES
    (SEQ_ETL_TGT_LOADLOG.NEXTVAL,
     0,
     V_TASK_NAME,
     V_ORIG_RECORD_COUNT,
     V_DUP_RECORD_COUNT,
     V_INSERT_COUNT,
     NVL(V_UPDT_COUNT,0),
     V_START_DT,
     V_END_DT,
     V_START_ROWID,
     V_END_ROWID);
  COMMIT;

  --������
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    V_ERROR_CD      := SQLCODE;
    V_ERROR_MESSAGE := V_EXEC_STEP || SUBSTR(SQLERRM, 1, 900);
    DBMS_OUTPUT.PUT_LINE('failed! ERROR:' || V_ERROR_CD || ' ,' ||
                         V_ERROR_MESSAGE);
    RAISE_APPLICATION_ERROR(-20021, V_ERROR_MESSAGE);
    RETURN;
  
    COMMIT;
  
END SP_COMPY_GROUPGRAPH_CMB;
/

prompt
prompt Creating procedure SP_COMPY_GROUPWARNING_CMB
prompt ============================================
prompt
CREATE OR REPLACE PROCEDURE SP_COMPY_GROUPWARNING_CMB IS
  /*
  �洢���̣�SP_COMPY_GROUPWARNING_CMB
  ��    �ܣ�����-��������Ԥ��-������STG->TEMP->TGT��
  �� �� �ˣ�RayLee
  ����ʱ�䣺2017/11/9 14:00:32
  Դ    ��CS_MASTER_STG.STG_CMB_COMPY_GROUPWARNING
  �� �� ��TEMP_COMPY_GROUPWARNING_CMB
  Ŀ �� ��COMPY_GROUPWARNING_CMB
  -----------------------------------------------------------------
  �� �� �ˣ�RayLee
  �޸�ʱ�䣺2017-12-28 14:15:11
  �޸����ݣ���ͬҵ��������ȡupdt_dt�ϴ󣬶���ͬһ���Σ�updt_dt��ͬ����ȡrecord_sid����ļ�¼
  */

  V_ERROR_CD          VARCHAR2(100);
  V_ERROR_MESSAGE     VARCHAR2(1000);
  V_TASK_NAME         ETL_TGT_LOADLOG.PROCESS_NM%TYPE; --��������
  V_UPDT_DT           ETL_TGT_LOADLOG.END_DT%TYPE; --�ϴ�ͬ������ʱ��
  V_START_DT          ETL_TGT_LOADLOG.START_DT%TYPE; --��ʼʱ��
  V_END_DT            ETL_TGT_LOADLOG.END_DT%TYPE; --����ʱ��
  V_START_ROWID       ETL_TGT_LOADLOG.START_ROWID%TYPE; --��ʼ�к�
  V_END_ROWID         ETL_TGT_LOADLOG.END_ROWID%TYPE; --��ֹ�к�
  V_INSERT_COUNT      ETL_TGT_LOADLOG.INSERT_COUNT%TYPE; --�����¼��
  V_UPDT_COUNT        ETL_TGT_LOADLOG.UPDT_COUNT%TYPE; --���¼�¼��
  V_ORIG_RECORD_COUNT NUMBER(16); --ԭʼ�ļ�¼��
  V_DUP_RECORD_COUNT  NUMBER(16); --�ظ��ļ�¼��

  --
  V_SRC_CD  TEMP_COMPY_GROUPWARNING_CMB.SRC_CD%TYPE := UPPER(TRIM('CMB'));
  V_UPDT_BY TEMP_COMPY_GROUPWARNING_CMB.UPDT_BY%TYPE := 0;
  V_ISDEL TEMP_COMPY_GROUPWARNING_CMB.ISDEL%TYPE := 0;

  V_EXEC_STEP VARCHAR2(100);

BEGIN

  --��������
  V_TASK_NAME := 'SP_COMPY_GROUPWARNING_CMB';

  --��ʼʱ��
  V_START_DT := SYSDATE;

  --��ȡ�ϴ�ͬ�����ݵ�ʱ��,����ǵ�һ������û�м�¼�ᷢ��NO_DATA_FOUND�쳣
  V_EXEC_STEP := 'STEP1 ��ȡ�ϴ�ͬ��ʱ��';
  BEGIN
    SELECT NVL(MAX(END_DT),TO_DATE('1900-1-1', 'yyyy-mm-dd'))
      INTO V_UPDT_DT
      FROM ETL_TGT_LOADLOG
     WHERE PROCESS_NM = V_TASK_NAME;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      V_UPDT_DT := TO_DATE('1900-1-1', 'yyyy-mm-dd');
  END;

  --��ȡ�����������ݲ��뵽��ʱ��
  V_EXEC_STEP := 'STEP2 ��ȡ�����������ݲ��뵽��ʱ��';
  INSERT INTO TEMP_COMPY_GROUPWARNING_CMB
    (COMPY_GROUPWARNING_SID, --1. ��������Ԥ����ˮ��
     COMPANY_ID, --2. ��ҵ��ʶ��
     GROUP_ID, --3. �������ź��Ŀͻ���
     GROUP_NM, --4. ������������
     IS_PRIVATE_GROUP, --5. �Ƿ���Ӫ��ҵ
     RISK_STATUS_CD, --6. ���ſͻ����շֲ�
     CONFIRM_REASON, --7. �϶�ԭ��
     CTRL_MEASURES, --8. �ܿش�ʩ
     AFFIRM_DT, --9. �϶�ʱ��
     AFFIRM_ORGID, --10.  �϶�����
     AFFIRM_ORGNM, --11.  �϶���������
     ISDEL, --12.  �Ƿ�ɾ��
     SRC_COMPANY_CD, --13.  Դ��ҵ����
     SRC_CD, --14.  Դϵͳ
     UPDT_BY, --15.  ������
     UPDT_DT, --16.  ����ʱ��
     RNK, --17.  ��¼����
     RECORD_SID,  --18.��ˮ��
     LOADLOG_SID  --19.��־��
     )
    SELECT SEQ_COMPY_GROUPWARNING_CMB.NEXTVAL AS COMPY_GROUPWARNING_SID, --1. ��������Ԥ����ˮ��
           T1.COMPANY_ID AS COMPANY_ID, --2. ��ҵ��ʶ��
           T1.GROUP_CUST_NO AS GROUP_ID, --3. �������ź��Ŀͻ���
           T1.GROUP_NM AS GROUP_NM, --4. ������������
           T.IS_PRIVATE_GROUP AS IS_PRIVATE_GROUP, --5. �Ƿ���Ӫ��ҵ
           T.RISK_STATUS_CD AS RISK_STATUS_CD, --6. ���ſͻ����շֲ�
           T.CONFIRM_REASON AS CONFIRM_REASON, --7. �϶�ԭ��
           T.CTRL_MEASURES AS CTRL_MEASURES, --8. �ܿش�ʩ
           TO_DATE(T.AFFIRM_DT, 'YYYY-MM-DD') AS AFFIRM_DT, --9. �϶�ʱ��
           T.AFFIRM_ORGID AS AFFIRM_ORGID, --10.  �϶�����
           T.AFFIRM_ORGNM AS AFFIRM_ORGNM, --11.  �϶���������
           V_ISDEL AS ISDEL, --12.  �Ƿ�ɾ��
           T.CUST_NO AS SRC_COMPANY_CD, --13.  Դ��ҵ����
           V_SRC_CD AS SRC_CD, --14.  Դϵͳ
           V_UPDT_BY AS UPDT_BY, --15.  ������
           SYSTIMESTAMP AS UPDT_DT, --16.  ����ʱ��
           ROW_NUMBER() OVER(PARTITION BY T1.COMPANY_ID, T1.GROUP_CUST_NO, T.AFFIRM_ORGID, T.AFFIRM_DT ORDER BY T.UPDT_DT DESC, T.RECORD_SID DESC) AS RNK, --18.  ��¼����
           RECORD_SID,  --18.��ˮ��
           LOADLOG_SID  --19.��־��
      FROM CS_MASTER_STG.STG_CMB_COMPY_GROUPWARNING T
      LEFT JOIN CUSTOMER_CMB T1
        ON T1.CUST_NO = T.CUST_NO
     WHERE T.UPDT_DT > V_UPDT_DT
       and t1.company_id is not null;

  --����ʱ��
  V_END_DT := SYSDATE;

  --��ȡ��־����
  V_EXEC_STEP := 'STEP3 ��ȡ��־����';
  SELECT COUNT(1) AS ORIG_RECORD_COUNT, --ԭʼ�ļ�¼��
         NVL(SUM(CASE
                   WHEN RNK > 1 THEN
                    1
                   ELSE
                    0
                 END),
             0) AS DUP_RECORD_COUNT, --�ظ��ļ�¼��
         MIN(RECORD_SID) AS START_ROWID, --��ʼ�к�
         MAX(RECORD_SID) AS END_ROWID --��ֹ�к�
    INTO V_ORIG_RECORD_COUNT,
         V_DUP_RECORD_COUNT,
         V_START_ROWID,
         V_END_ROWID
    FROM TEMP_COMPY_GROUPWARNING_CMB;

  --ɾ���Ѿ����ڵ���������
  V_EXEC_STEP := 'STEP4 ɾ���Ѿ����ڵ���������';
  --��������ҵ��ʶ��+�������ſͻ���+�϶�����+�϶�ʱ��
  DELETE FROM COMPY_GROUPWARNING_CMB A
   WHERE EXISTS (SELECT 1
            FROM TEMP_COMPY_GROUPWARNING_CMB B
           WHERE A.COMPANY_ID = B.COMPANY_ID
             AND A.GROUP_ID = B.GROUP_ID
             AND A.AFFIRM_ORGID = B.AFFIRM_ORGID
             AND A.AFFIRM_DT = B.AFFIRM_DT);

  V_EXEC_STEP := 'STEP5 �������ݵ�Ŀ���';
  INSERT INTO COMPY_GROUPWARNING_CMB
    (COMPY_GROUPWARNING_SID, --1. ��������Ԥ����ˮ��
     COMPANY_ID, --2. ��ҵ��ʶ��
     GROUP_ID, --3. �������ź��Ŀͻ���
     GROUP_NM, --4. ������������
     IS_PRIVATE_GROUP, --5. �Ƿ���Ӫ��ҵ
     RISK_STATUS_CD, --6. ���ſͻ����շֲ�
     CONFIRM_REASON, --7. �϶�ԭ��
     CTRL_MEASURES, --8. �ܿش�ʩ
     AFFIRM_DT, --9. �϶�ʱ��
     AFFIRM_ORGID, --10.  �϶�����
     AFFIRM_ORGNM, --11.  �϶���������
     ISDEL, --12.  �Ƿ�ɾ��
     SRC_COMPANY_CD, --13.  Դ��ҵ����
     SRC_CD, --14.  Դϵͳ
     UPDT_BY, --15.  ������
     UPDT_DT --16.  ����ʱ��
     )
    SELECT COMPY_GROUPWARNING_SID, --1. ��������Ԥ����ˮ��
           COMPANY_ID, --2. ��ҵ��ʶ��
           GROUP_ID, --3. �������ź��Ŀͻ���
           GROUP_NM, --4. ������������
           IS_PRIVATE_GROUP, --5. �Ƿ���Ӫ��ҵ
           RISK_STATUS_CD, --6. ���ſͻ����շֲ�
           CONFIRM_REASON, --7. �϶�ԭ��
           CTRL_MEASURES, --8. �ܿش�ʩ
           AFFIRM_DT, --9. �϶�ʱ��
           AFFIRM_ORGID, --10.  �϶�����
           AFFIRM_ORGNM, --11.  �϶���������
           ISDEL, --12.  �Ƿ�ɾ��
           SRC_COMPANY_CD, --13.  Դ��ҵ����
           SRC_CD, --14.  Դϵͳ
           UPDT_BY, --15.  ������
           UPDT_DT --16.  ����ʱ��
      FROM TEMP_COMPY_GROUPWARNING_CMB T
     WHERE RNK = '1';

  V_INSERT_COUNT := SQL%ROWCOUNT;
  COMMIT;

  --�������ݵ�LOG����
  V_EXEC_STEP := 'STEP6 �������ݵ�LOG����';
  INSERT INTO ETL_TGT_LOADLOG
    (LOADLOG_SID,
     BATCH_SID,
     PROCESS_NM,
     ORIG_RECORD_COUNT,
     DUP_RECORD_COUNT,
     INSERT_COUNT,
     UPDT_COUNT,
     START_DT,
     END_DT,
     START_ROWID,
     END_ROWID)
  VALUES
    (SEQ_ETL_TGT_LOADLOG.NEXTVAL,
     0,
     V_TASK_NAME,
     V_ORIG_RECORD_COUNT,
     V_DUP_RECORD_COUNT,
     V_INSERT_COUNT,
     NVL(V_UPDT_COUNT,0),
     V_START_DT,
     V_END_DT,
     V_START_ROWID,
     V_END_ROWID);
  COMMIT;

  --������
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    V_ERROR_CD      := SQLCODE;
    V_ERROR_MESSAGE := V_EXEC_STEP || SUBSTR(SQLERRM, 1, 900);
    DBMS_OUTPUT.PUT_LINE('failed! ERROR:' || V_ERROR_CD || ' ,' ||
                         V_ERROR_MESSAGE);
    RAISE_APPLICATION_ERROR(-20021, V_ERROR_MESSAGE);
    RETURN;
  
    COMMIT;
  
END SP_COMPY_GROUPWARNING_CMB;
/

prompt
prompt Creating procedure SP_COMPY_HIGHRISKLIST_CMB
prompt ============================================
prompt
CREATE OR REPLACE PROCEDURE SP_COMPY_HIGHRISKLIST_CMB IS
  /*
  �洢���̣�SP_COMPY_HIGHRISKLIST_CMB
  ��    �ܣ�����-�߷���������-������STG->TEMP->TGT��
            ��������ˮ��
            (�ͻ�+��Դ+�ͻ�����+�Ƿ���Ч)
  �� �� �ˣ�RayLee
  ����ʱ�䣺2017/11/9 10:25:27
  Դ    ��CS_MASTER_STG.STG_CMB_COMPY_HIGHRISKLIST
  �� �� ��TEMP_CMB_COMPY_HIGHRISKLIST
  Ŀ �� ��COMPY_HIGHRISKLIST_CMB
  --------------------------------------------------------------------
  �� �� �ˣ�RayLee
  �޸�ʱ�䣺2017-12-28 14:28:06
  �޸����ݣ���ͬҵ��������ȡupdt_dt�ϴ󣬶���ͬһ���Σ�updt_dt��ͬ����ȡrecord_sid����ļ�¼
  �� �� �ˣ�RayLee
  �޸�ʱ�䣺2017-12-28 15:13:46
  �޸����ݣ��޸� ҵ������ȥ������blacklist_type_cd�ֶ�
  */

  V_ERROR_CD          VARCHAR2(100);
  V_ERROR_MESSAGE     VARCHAR2(1000);
  V_TASK_NAME         ETL_TGT_LOADLOG.PROCESS_NM%TYPE; --��������
  V_UPDT_DT           ETL_TGT_LOADLOG.END_DT%TYPE; --�ϴ�ͬ������ʱ��
  V_START_DT          ETL_TGT_LOADLOG.START_DT%TYPE; --��ʼʱ��
  V_END_DT            ETL_TGT_LOADLOG.END_DT%TYPE; --����ʱ��
  V_START_ROWID       ETL_TGT_LOADLOG.START_ROWID%TYPE; --��ʼ�к�
  V_END_ROWID         ETL_TGT_LOADLOG.END_ROWID%TYPE; --��ֹ�к�
  V_INSERT_COUNT      ETL_TGT_LOADLOG.INSERT_COUNT%TYPE; --�����¼��
  V_UPDT_COUNT        ETL_TGT_LOADLOG.UPDT_COUNT%TYPE; --���¼�¼��
  V_ORIG_RECORD_COUNT NUMBER(16); --ԭʼ�ļ�¼��
  V_DUP_RECORD_COUNT  NUMBER(16); --�ظ��ļ�¼��

  --
  V_SRC_CD  TEMP_COMPY_HIGHRISKLIST_CMB.SRC_CD%TYPE := UPPER(TRIM('CMB'));
  V_UPDT_BY TEMP_COMPY_HIGHRISKLIST_CMB.UPDT_BY%TYPE := 0;
  V_ISDEL TEMP_COMPY_HIGHRISKLIST_CMB.ISDEL%TYPE := 0;

  V_EXEC_STEP VARCHAR2(100);

BEGIN

  --��������
  V_TASK_NAME := 'SP_COMPY_HIGHRISKLIST_CMB';

  --��ʼʱ��
  V_START_DT := SYSDATE;

  --��ȡ�ϴ�ͬ�����ݵ�ʱ��,����ǵ�һ������û�м�¼�ᷢ��NO_DATA_FOUND�쳣
  V_EXEC_STEP := 'STEP1 ��ȡ�ϴ�ͬ��ʱ��';
  BEGIN
    SELECT NVL(MAX(END_DT),TO_DATE('1900-1-1', 'yyyy-mm-dd'))
      INTO V_UPDT_DT
      FROM ETL_TGT_LOADLOG
     WHERE PROCESS_NM = V_TASK_NAME;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      V_UPDT_DT := TO_DATE('1900-1-1', 'yyyy-mm-dd');
  END;

  --��ȡ�����������ݲ��뵽��ʱ��
  V_EXEC_STEP := 'STEP2 ��ȡ�����������ݲ��뵽��ʱ��';
  INSERT INTO TEMP_COMPY_HIGHRISKLIST_CMB
    (HISHGRISKLIST_ID, --1. ��ˮ��
     COMPANY_ID, --2. ��ҵ��ʶ��
     LIST_TYPE_CD, --3. ��������
     BLACKLIST_SRCCD, --4. ��������Դ
     BLACKLIST_TYPE_CD, --5. �������ͻ�����
     EFF_DT, --6. ��Ч����
     CONFIRM_REASON, --7. �϶�ԭ��
     CTL_MEASURE, --8. �ܿش�ʩ
     EFF_FLAG, --9. �Ƿ���Ч
     ISDEL, --10.  �Ƿ�ɾ��
     SRC_COMPANY_CD, --11.  Դ��ҵ����
     SRC_CD, --12.  Դϵͳ
     UPDT_BY, --13.  ������
     UPDT_DT, --14.  ����ʱ��
     RNK ,--15.  ��¼����
     RECORD_SID,  --16.��ˮ��
     LOADLOG_SID  --17.��־��

     )
    SELECT T.HISHGRISKLIST_ID AS HISHGRISKLIST_ID, --1. ��ˮ��
           T1.COMPANY_ID AS COMPANY_ID, --2. ��ҵ��ʶ��
           T.LIST_TYPE_CD AS LIST_TYPE_CD, --3. ��������
           T.BLACKLIST_SRCCD AS BLACKLIST_SRCCD, --4. ��������Դ
           T.BLACKLIST_TYPE_CD AS BLACKLIST_TYPE_CD, --5. �������ͻ�����
           TO_DATE(T.EFF_DT, 'YYYY-MM-DD') AS EFF_DT, --6. ��Ч����
           T.CONFIRM_REASON AS CONFIRM_REASON, --7. �϶�ԭ��
           T.CTL_MEASURE AS CTL_MEASURE, --8. �ܿش�ʩ
           T.EFF_FLAG AS EFF_FLAG, --9. �Ƿ���Ч
           V_ISDEL AS ISDEL, --10.  �Ƿ�ɾ��
           T.CUST_NO AS SRC_COMPANY_CD, --11.  Դ��ҵ����
           V_SRC_CD AS SRC_CD, --12.  Դϵͳ
           V_UPDT_BY AS UPDT_BY, --13.  ������
           SYSTIMESTAMP AS UPDT_DT, --14.  ����ʱ��
           ROW_NUMBER() OVER(PARTITION BY T.CUST_NO, T.BLACKLIST_SRCCD, T.EFF_FLAG, T.BLACKLIST_TYPE_CD ORDER BY T.UPDT_DT DESC, T.RECORD_SID DESC) RNK, --15.  ��¼����
           T.RECORD_SID AS RECORD_SID,  --16.��ˮ��
           T.LOADLOG_SID AS LOADLOG_SID  --17.��־��
      FROM CS_MASTER_STG.STG_CMB_COMPY_HIGHRISKLIST T
      LEFT JOIN CUSTOMER_CMB T1
        ON T1.CUST_NO = T.CUST_NO
     WHERE T.UPDT_DT > V_UPDT_DT
       AND T1.COMPANY_ID IS NOT NULL;

  --����ʱ��
  V_END_DT := SYSDATE;

  --��ȡ��־����
  V_EXEC_STEP := 'STEP3 ��ȡ��־����';
  SELECT COUNT(1) AS ORIG_RECORD_COUNT, --ԭʼ�ļ�¼��
         NVL(SUM(CASE
                   WHEN RNK > 1 THEN
                    1
                   ELSE
                    0
                 END),
             0) AS DUP_RECORD_COUNT, --�ظ��ļ�¼��
         MIN(RECORD_SID) AS START_ROWID, --��ʼ�к�
         MAX(RECORD_SID) AS END_ROWID --��ֹ�к�
    INTO V_ORIG_RECORD_COUNT,
         V_DUP_RECORD_COUNT,
         V_START_ROWID,
         V_END_ROWID
    FROM TEMP_COMPY_HIGHRISKLIST_CMB;

  --ɾ���Ѿ����ڵ���������
  V_EXEC_STEP := 'STEP4 ɾ���Ѿ����ڵ���������';

  DELETE FROM COMPY_HIGHRISKLIST_CMB
   WHERE (COMPANY_ID, BLACKLIST_SRCCD, EFF_FLAG, BLACKLIST_TYPE_CD) IN
         (SELECT COMPANY_ID, BLACKLIST_SRCCD, EFF_FLAG, BLACKLIST_TYPE_CD
            FROM TEMP_COMPY_HIGHRISKLIST_CMB);

  V_EXEC_STEP := 'STEP5 �������ݵ�Ŀ���';
  INSERT INTO COMPY_HIGHRISKLIST_CMB
    (HISHGRISKLIST_ID, --1. ��ˮ��
     COMPANY_ID, --2. ��ҵ��ʶ��
     LIST_TYPE_CD, --3. ��������
     BLACKLIST_SRCCD, --4. ��������Դ
     BLACKLIST_TYPE_CD, --5. �������ͻ�����
     EFF_DT, --6. ��Ч����
     CONFIRM_REASON, --7. �϶�ԭ��
     CTL_MEASURE, --8. �ܿش�ʩ
     EFF_FLAG, --9. �Ƿ���Ч
     ISDEL, --10.  �Ƿ�ɾ��
     SRC_COMPANY_CD, --11.  Դ��ҵ����
     SRC_CD, --12.  Դϵͳ
     UPDT_BY, --13.  ������
     UPDT_DT --14.  ����ʱ��
     )
    SELECT HISHGRISKLIST_ID, --1. ��ˮ��
           COMPANY_ID, --2. ��ҵ��ʶ��
           LIST_TYPE_CD, --3. ��������
           BLACKLIST_SRCCD, --4. ��������Դ
           BLACKLIST_TYPE_CD, --5. �������ͻ�����
           EFF_DT, --6. ��Ч����
           CONFIRM_REASON, --7. �϶�ԭ��
           CTL_MEASURE, --8. �ܿش�ʩ
           EFF_FLAG, --9. �Ƿ���Ч
           ISDEL, --10.  �Ƿ�ɾ��
           SRC_COMPANY_CD, --11.  Դ��ҵ����
           SRC_CD, --12.  Դϵͳ
           UPDT_BY, --13.  ������
           UPDT_DT --14.  ����ʱ��
      FROM TEMP_COMPY_HIGHRISKLIST_CMB T
     WHERE RNK = '1';

  V_INSERT_COUNT := SQL%ROWCOUNT;
  COMMIT;

  --�������ݵ�LOG����
  V_EXEC_STEP := 'STEP6 �������ݵ�LOG����';
  INSERT INTO ETL_TGT_LOADLOG
    (LOADLOG_SID,
     BATCH_SID,
     PROCESS_NM,
     ORIG_RECORD_COUNT,
     DUP_RECORD_COUNT,
     INSERT_COUNT,
     UPDT_COUNT,
     START_DT,
     END_DT,
     START_ROWID,
     END_ROWID)
  VALUES
    (SEQ_ETL_TGT_LOADLOG.NEXTVAL,
     0,
     V_TASK_NAME,
     V_ORIG_RECORD_COUNT,
     V_DUP_RECORD_COUNT,
     V_INSERT_COUNT,
     NVL(V_UPDT_COUNT,0),
     V_START_DT,
     V_END_DT,
     V_START_ROWID,
     V_END_ROWID);
  COMMIT;

  --������
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    V_ERROR_CD      := SQLCODE;
    V_ERROR_MESSAGE := V_EXEC_STEP || SUBSTR(SQLERRM, 1, 900);
    DBMS_OUTPUT.PUT_LINE('failed! ERROR:' || V_ERROR_CD || ' ,' ||
                         V_ERROR_MESSAGE);
    RAISE_APPLICATION_ERROR(-20021, V_ERROR_MESSAGE);
    RETURN;

    COMMIT;

END SP_COMPY_HIGHRISKLIST_CMB;
/

prompt
prompt Creating procedure SP_COMPY_LIMIT_CMB
prompt =====================================
prompt
CREATE OR REPLACE PROCEDURE sp_compy_limit_cmb IS
  /************************************************
  �洢���̣�sp_compy_limit_cmb
  ����ʱ�䣺2017/11/10
  �� �� �ˣ�ZhangCong
  Դ    ��stg_cmb_compy_limit(�ܿ��޶�)
  �� �� ��temp_compy_limit_cmb
  Ŀ �� ��compy_limit_cmb(�ܿ��޶�)
  ��    �ܣ�����ͬ��stg�µ��ܿ��޶����ݵ�tgt��
  �޸ļ�¼��2017/12/25 zhangcong ������SP�������²����߼�
  
  *************************************************/

  --------------------------------������־����-----------------------------
  v_error_cd          VARCHAR2(100);
  v_error_message     VARCHAR2(1000);
  v_task_name         etl_tgt_loadlog.process_nm%TYPE; --��������
  v_updt_dt           etl_tgt_loadlog.end_dt%TYPE; --�ϴ�ͬ������ʱ��
  v_start_dt          etl_tgt_loadlog.start_dt%TYPE; --��ʼʱ��
  v_end_dt            etl_tgt_loadlog.end_dt%TYPE; --����ʱ��
  v_start_rowid       etl_tgt_loadlog.start_rowid%TYPE; --��ʼ�к�
  v_end_rowid         etl_tgt_loadlog.end_rowid%TYPE; --��ֹ�к�
  v_insert_count      etl_tgt_loadlog.insert_count%TYPE; --�����¼��
  v_updt_count        etl_tgt_loadlog.updt_count%TYPE; --���¼�¼��
  v_orig_record_count etl_tgt_loadlog.orig_record_count%TYPE; --ԭʼ�ļ�¼��
  v_dup_record_count  etl_tgt_loadlog.dup_record_count%TYPE; --�ظ��ļ�¼��
  v_batch_sid         etl_tgt_loadlog.batch_sid%TYPE := 0; --���κ�

  --------------------------------����ҵ�����------------------------------
  v_updt_by compy_creditapply_cmb.updt_by%TYPE := 0; --������
  v_isdel   compy_creditapply_cmb.isdel%TYPE := 0; --�Ƿ�ɾ��
  v_src_cd  compy_creditapply_cmb.src_cd%TYPE := 'CMB'; --Դϵͳ

BEGIN

  --��������
  v_task_name := 'SP_COMPY_LIMIT_CMB';

  --��ȡ�ϴ�ͬ�����ݵ�ʱ��
  SELECT nvl(MAX(end_dt), to_date('1900-1-1', 'yyyy-mm-dd'))
    INTO v_updt_dt
    FROM etl_tgt_loadlog
   WHERE process_nm = v_task_name;

  --��ʼʱ��
  v_start_dt := SYSDATE;

  --��ȡ�����������ݲ��뵽��ʱ��
  INSERT INTO temp_compy_limit_cmb
    (company_id,
     limit_type_cd,
     limit_status_cd,
     is_frozen,
     org_id,
     org_nm,
     currency,
     apply_limit,
     apply_valid_months,
     apply_detail,
     cust_limit,
     limit_usageratio,
     limit_used,
     limit_notused,
     limit_tmpover_amt,
     limit_tmpover_dt,
     eff_dt,
     due_dt,
     isdel,
     src_company_cd,
     src_cd,
     updt_by,
     updt_dt,
     rnk,
     record_sid,
     loadlog_sid)
    SELECT b.company_id,
           a.limit_type_cd,
           a.limit_status_cd,
           to_number(a.is_frozen) AS is_frozen,
           to_number(a.org_id) AS org_id,
           a.org_nm,
           a.currency,
           CAST(a.apply_limit AS NUMBER(24, 4)) AS apply_limit,
           to_number(a.apply_valid_months) AS apply_valid_months,
           a.apply_detail,
           CAST(a.cust_limit AS NUMBER(24, 4)) AS cust_limit,
           CAST(a.limit_usageratio AS NUMBER(24, 4)) AS limit_usageratio,
           CAST(a.limit_used AS NUMBER(24, 4)) AS limit_used,
           CAST(a.limit_notused AS NUMBER(24, 4)) AS limit_notused,
           CAST(a.limit_tmpover_amt AS NUMBER(24, 4)) AS limit_tmpover_amt,
           to_date(a.limit_tmpover_dt, 'yyyy-mm-dd hh24:mi;ss') AS limit_tmpover_dt,
           to_date(a.eff_dt, 'yyyy-mm-dd hh24:mi;ss') AS eff_dt,
           to_date(a.due_dt, 'yyyy-mm-dd hh24:mi;ss') AS due_dt,
           v_isdel AS isdel,
           a.cust_no AS src_company_cd,
           v_src_cd AS src_cd,
           v_updt_by AS updt_by,
           systimestamp AS updt_dt,
           row_number() over(PARTITION BY a.cust_no, a.limit_type_cd ORDER BY a.updt_dt DESC, a.record_sid DESC) rnk, --ȥ��
           a.record_sid,
           a.loadlog_sid
      FROM cs_master_stg.stg_cmb_compy_limit a
      JOIN customer_cmb b
        ON (a.cust_no = b.cust_no AND b.company_id IS NOT NULL)
     WHERE a.updt_dt > v_updt_dt;

  --����ʱ��
  v_end_dt := SYSDATE;

  --��ȡ��־����
  SELECT COUNT(1) AS orig_record_count, --ԭʼ�ļ�¼��
         nvl(SUM(CASE
                   WHEN rnk > 1 THEN
                    1
                   ELSE
                    0
                 END),
             0) AS dup_record_count, --�ظ��ļ�¼��
         MIN(record_sid) AS start_rowid, --��ʼ�к�
         MAX(record_sid) AS end_rowid --��ֹ�к�
    INTO v_orig_record_count, v_dup_record_count, v_start_rowid, v_end_rowid
    FROM temp_compy_limit_cmb;

  --ɾ�������µ�����
  DELETE FROM compy_limit_cmb a
   WHERE EXISTS (SELECT 1
            FROM temp_compy_limit_cmb cdm
           WHERE a.company_id = cdm.company_id
             AND a.limit_type_cd = cdm.limit_type_cd);

  v_updt_count := SQL%ROWCOUNT;

  --������������
  INSERT INTO compy_limit_cmb
    (compy_limit_sid,
     company_id,
     limit_type_cd,
     limit_status_cd,
     is_frozen,
     org_id,
     org_nm,
     currency,
     apply_limit,
     apply_valid_months,
     apply_detail,
     cust_limit,
     limit_usageratio,
     limit_used,
     limit_notused,
     limit_tmpover_amt,
     limit_tmpover_dt,
     eff_dt,
     due_dt,
     isdel,
     src_company_cd,
     src_cd,
     updt_by,
     updt_dt)
    SELECT seq_compy_limit_cmb.nextval,
           a.company_id,
           a.limit_type_cd,
           a.limit_status_cd,
           a.is_frozen,
           a.org_id,
           a.org_nm,
           a.currency,
           a.apply_limit,
           a.apply_valid_months,
           a.apply_detail,
           a.cust_limit,
           a.limit_usageratio,
           a.limit_used,
           a.limit_notused,
           a.limit_tmpover_amt,
           a.limit_tmpover_dt,
           a.eff_dt,
           a.due_dt,
           a.isdel,
           a.src_company_cd,
           a.src_cd,
           a.updt_by,
           a.updt_dt
      FROM temp_compy_limit_cmb a
     WHERE a.company_id IS NOT NULL
       AND a.rnk = 1;

  v_insert_count := SQL%ROWCOUNT - v_updt_count;

  COMMIT;

  --�������ݵ�LOG����

  INSERT INTO etl_tgt_loadlog
    (loadlog_sid,
     batch_sid,
     process_nm,
     orig_record_count,
     dup_record_count,
     insert_count,
     updt_count,
     start_dt,
     end_dt,
     start_rowid,
     end_rowid)
    SELECT seq_etl_tgt_loadlog.nextval,
           v_batch_sid,
           v_task_name,
           v_orig_record_count,
           v_dup_record_count,
           v_insert_count,
           v_updt_count,
           v_start_dt,
           v_end_dt,
           v_start_rowid,
           v_end_rowid
      FROM dual;

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
  
END sp_compy_limit_cmb;
/

prompt
prompt Creating procedure SP_COMPY_OPERATIONCLEAR_CMB
prompt ==============================================
prompt
CREATE OR REPLACE PROCEDURE SP_COMPY_OPERATIONCLEAR_CMB IS
  /*
  �洢���̣�SP_COMPY_OPERATIONCLEAR_CMB
  ��    �ܣ�����-��Ӫָ�꼰������ܱ�-������STG->TEMP->TGT��
            ��������ˮ��
            (�ͻ�+��Դ+�ͻ�����+�Ƿ���Ч)
  �� �� �ˣ�RayLee
  ����ʱ�䣺2017/11/9 10:25:27
  Դ    ��CS_MASTER_STG.STG_CMB_COMPY_OPERATIONCLEAR
  �� �� ��TEMP_COMPY_OPERATIONCLEAR_CMB
  Ŀ �� ��COMPY_OPERATIONCLEAR_CMB
  --------------------------------------------------------------------
  �� �� �ˣ�RayLee
  �޸�ʱ�䣺2017-12-19 09:51
  �޸����ݣ�ת�����ִ���
  �� �� �ˣ�RayLee
  �޸�ʱ�䣺2017-12-28 14:22:54
  �޸����ݣ���ͬҵ��������ȡupdt_dt�ϴ󣬶���ͬһ���Σ�updt_dt��ͬ����ȡrecord_sid����ļ�¼
  */

  V_ERROR_CD          VARCHAR2(100);
  V_ERROR_MESSAGE     VARCHAR2(1000);
  V_TASK_NAME         ETL_TGT_LOADLOG.PROCESS_NM%TYPE; --��������
  V_UPDT_DT           ETL_TGT_LOADLOG.END_DT%TYPE; --�ϴ�ͬ������ʱ��
  V_START_DT          ETL_TGT_LOADLOG.START_DT%TYPE; --��ʼʱ��
  V_END_DT            ETL_TGT_LOADLOG.END_DT%TYPE; --����ʱ��
  V_START_ROWID       ETL_TGT_LOADLOG.START_ROWID%TYPE; --��ʼ�к�
  V_END_ROWID         ETL_TGT_LOADLOG.END_ROWID%TYPE; --��ֹ�к�
  V_INSERT_COUNT      ETL_TGT_LOADLOG.INSERT_COUNT%TYPE; --�����¼��
  V_UPDT_COUNT        ETL_TGT_LOADLOG.UPDT_COUNT%TYPE; --���¼�¼��
  V_ORIG_RECORD_COUNT NUMBER(16); --ԭʼ�ļ�¼��
  V_DUP_RECORD_COUNT  NUMBER(16); --�ظ��ļ�¼��

  --
  V_SRC_CD  TEMP_COMPY_OPERATIONCLEAR_CMB.SRC_CD%TYPE := UPPER(TRIM('CMB'));
  V_UPDT_BY TEMP_COMPY_OPERATIONCLEAR_CMB.UPDT_BY%TYPE := 0;
  V_ISDEL   TEMP_COMPY_OPERATIONCLEAR_CMB.ISDEL%TYPE := 0;

  V_EXEC_STEP VARCHAR2(100);

BEGIN

  --��������
  V_TASK_NAME := 'SP_COMPY_OPERATIONCLEAR_CMB';

  --��ʼʱ��
  V_START_DT := SYSDATE;

  --��ȡ�ϴ�ͬ�����ݵ�ʱ��,����ǵ�һ������û�м�¼�ᷢ��NO_DATA_FOUND�쳣
  V_EXEC_STEP := 'STEP1 ��ȡ�ϴ�ͬ��ʱ��';
  BEGIN
    SELECT NVL(MAX(END_DT),TO_DATE('1900-1-1', 'yyyy-mm-dd'))
      INTO V_UPDT_DT
      FROM ETL_TGT_LOADLOG
     WHERE PROCESS_NM = V_TASK_NAME;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      V_UPDT_DT := TO_DATE('1900-1-1', 'yyyy-mm-dd');
  END;

  --��ȡ�����������ݲ��뵽��ʱ��
  V_EXEC_STEP := 'STEP2 ��ȡ�����������ݲ��뵽��ʱ��';
  INSERT INTO TEMP_COMPY_OPERATIONCLEAR_CMB
    (COMPY_OPERATIONCLEAR_SID, --1. ��Ӫָ�꼰������ܱ��
     COMPANY_ID, --2. ��ҵ��ʶ��
     RPT_DT, --3. ����
     CURRENCY, --4. ���ִ���
     ALL_AMT_IN, --5. �ϼ��ʽ�ת��
     ALL_AMT_OUT, --6. �ϼ��ʽ�ת��
     AVG_BALANCE_CURY, --7. �������վ����
     AVG_GRTBALANCE_CURY, --8. ���걣֤���վ����
     AVG_LOANBALANCE_CURY, --9. ��������վ����
     LOAN_DEPOSIT_RATIO, --10.  �����
     GUR_GROUP, --11.  ����Ȧ
     BALANCE_SIXMON, --12.  �����˻���6�����¾����
     BAL_1Y_UPTIMES, --13.  �ͻ���ȥһ����ĩ�������������ӵĴ���_U��
     BAL_1Y_UPTIMES_GROUP, --14.  �ͻ���ȥһ����ĩ�������������ӵĴ�������_U��
     BBK_NM, --15.  �����������
     CUST_CNT, --16.  ʮ������ǰor����ǰ�ͻ�����
     PD_CUST_CNT, --17.  ʮ�����º�or���º�ΥԼ�ͻ�����
     PD_INF, --18.  ΥԼ����
     GROUP_NM, --19.  ��������
     ISDEL, --20.  �Ƿ�ɾ��
     SRC_COMPANY_CD, --21.  Դ��ҵ����
     SRC_CD, --22.  Դϵͳ
     UPDT_BY, --23.  ������
     UPDT_DT, --24.  ����ʱ��
     RECORD_SID, --25.  ��ˮ��
     LOADLOG_SID, --26.  ��־��
     RNK --27.  ��¼����
     )
    SELECT SEQ_CMB_COMPY_OPERATIONCLEAR.NEXTVAL AS COMPY_OPERATIONCLEAR_SID, --1. ��Ӫָ�꼰������ܱ��
           T1.COMPANY_ID AS COMPANY_ID, --2. ��ҵ��ʶ��
           TO_DATE(T.DATA_DT, 'YYYY-MM-DD') AS RPT_DT, --3. ����
           T.CURRENCY AS CURRENCY, --4. ���ִ���
           T.ALL_AMT_IN AS ALL_AMT_IN, --5. �ϼ��ʽ�ת��
           T.ALL_AMT_OUT AS ALL_AMT_OUT, --6. �ϼ��ʽ�ת��
           T.AVG_BALANCE_CURY AS AVG_BALANCE_CURY, --7. �������վ����
           T.AVG_GRTBALANCE_CURY AS AVG_GRTBALANCE_CURY, --8. ���걣֤���վ����
           T.AVG_LOANBALANCE_CURY AS AVG_LOANBALANCE_CURY, --9. ��������վ����
           T.LOAN_DEPOSIT_RATIO AS LOAN_DEPOSIT_RATIO, --10.  �����
           T.GUR_GROUP AS GUR_GROUP, --11.  ����Ȧ
           T.BALANCE_SIXMON AS BALANCE_SIXMON, --12.  �����˻���6�����¾����
           T.BAL_1Y_UPTIMES AS BAL_1Y_UPTIMES, --13.  �ͻ���ȥһ����ĩ�������������ӵĴ���_U��
           T.BAL_1Y_UPTIMES_GROUP AS BAL_1Y_UPTIMES_GROUP, --14.  �ͻ���ȥһ����ĩ�������������ӵĴ�������_U��
           T.BBK_NM AS BBK_NM, --15.  �����������
           T.CUST_CNT AS CUST_CNT, --16.  ʮ������ǰor����ǰ�ͻ�����
           T.PD_CUST_CNT AS PD_CUST_CNT, --17.  ʮ�����º�or���º�ΥԼ�ͻ�����
           T.PD_INF AS PD_INF, --18.  ΥԼ����
           T.GROUP_NM AS GROUP_NM, --19.  ��������
           V_ISDEL AS ISDEL, --20.  �Ƿ�ɾ��
           T.CUST_NO AS SRC_COMPANY_CD, --21.  Դ��ҵ����
           V_SRC_CD AS SRC_CD, --22.  Դϵͳ
           V_UPDT_BY AS UPDT_BY, --23.  ������
           SYSTIMESTAMP AS UPDT_DT, --24.  ����ʱ��
           T.RECORD_SID AS RECORD_SID, --25.  ��ˮ��
           T.LOADLOG_SID AS LOADLOG_SID, --26.  ��־��
           ROW_NUMBER()OVER(PARTITION BY T.DATA_DT, T.CUST_NO ORDER BY T.UPDT_DT DESC, T.RECORD_SID DESC) AS RNK --27.  ��¼����
      FROM CS_MASTER_STG.STG_CMB_COMPY_OPERATIONCLEAR T
      LEFT JOIN CUSTOMER_CMB T1
        ON T1.CUST_NO = T.CUST_NO
     WHERE T.UPDT_DT > V_UPDT_DT
       AND T1.COMPANY_ID IS NOT NULL;

  --����ʱ��
  V_END_DT := SYSDATE;

  --��ȡ��־����
  V_EXEC_STEP := 'STEP3 ��ȡ��־����';
  SELECT COUNT(1) AS ORIG_RECORD_COUNT, --ԭʼ�ļ�¼��
         NVL(SUM(CASE
                   WHEN RNK > 1 THEN
                    1
                   ELSE
                    0
                 END),
             0) AS DUP_RECORD_COUNT, --�ظ��ļ�¼��
         MIN(RECORD_SID) AS START_ROWID, --��ʼ�к�
         MAX(RECORD_SID) AS END_ROWID --��ֹ�к�
    INTO V_ORIG_RECORD_COUNT,
         V_DUP_RECORD_COUNT,
         V_START_ROWID,
         V_END_ROWID
    FROM TEMP_BOND_POSITION_STRUCTURED;

  --ɾ���Ѿ����ڵ���������
  V_EXEC_STEP := 'STEP4 ɾ���Ѿ����ڵ���������';

  DELETE FROM COMPY_OPERATIONCLEAR_CMB T
   WHERE EXISTS (SELECT *
            FROM TEMP_COMPY_OPERATIONCLEAR_CMB A
           WHERE T.COMPANY_ID = A.COMPANY_ID
             AND T.RPT_DT = A.RPT_DT);

  V_EXEC_STEP := 'STEP5 �������ݵ�Ŀ���';
  INSERT INTO COMPY_OPERATIONCLEAR_CMB
    (COMPY_OPERATIONCLEAR_SID, --1. ��Ӫָ�꼰������ܱ��
     COMPANY_ID, --2. ��ҵ��ʶ��
     RPT_DT, --3. ����
     CURRENCY, --4. ���ִ���
     ALL_AMT_IN, --5. �ϼ��ʽ�ת��
     ALL_AMT_OUT, --6. �ϼ��ʽ�ת��
     AVG_BALANCE_CURY, --7. �������վ����
     AVG_GRTBALANCE_CURY, --8. ���걣֤���վ����
     AVG_LOANBALANCE_CURY, --9. ��������վ����
     LOAN_DEPOSIT_RATIO, --10.  �����
     GUR_GROUP, --11.  ����Ȧ
     BALANCE_SIXMON, --12.  �����˻���6�����¾����
     BAL_1Y_UPTIMES, --13.  �ͻ���ȥһ����ĩ�������������ӵĴ���_U��
     BAL_1Y_UPTIMES_GROUP, --14.  �ͻ���ȥһ����ĩ�������������ӵĴ�������_U��
     BBK_NM, --15.  �����������
     CUST_CNT, --16.  ʮ������ǰor����ǰ�ͻ�����
     PD_CUST_CNT, --17.  ʮ�����º�or���º�ΥԼ�ͻ�����
     PD_INF, --18.  ΥԼ����
     GROUP_NM, --19.  ��������
     ISDEL, --20.  �Ƿ�ɾ��
     SRC_COMPANY_CD, --21.  Դ��ҵ����
     SRC_CD, --22.  Դϵͳ
     UPDT_BY, --23.  ������
     UPDT_DT --24.  ����ʱ��
     )
    SELECT COMPY_OPERATIONCLEAR_SID, --1. ��Ӫָ�꼰������ܱ��
           COMPANY_ID, --2. ��ҵ��ʶ��
           RPT_DT, --3. ����
           CASE WHEN NVL(CURRENCY,'10') = '10' THEN 'CNY' ELSE CURRENCY END AS CURRENCY, --4. ���ִ���
           ALL_AMT_IN, --5. �ϼ��ʽ�ת��
           ALL_AMT_OUT, --6. �ϼ��ʽ�ת��
           AVG_BALANCE_CURY, --7. �������վ����
           AVG_GRTBALANCE_CURY, --8. ���걣֤���վ����
           AVG_LOANBALANCE_CURY, --9. ��������վ����
           LOAN_DEPOSIT_RATIO, --10.  �����
           GUR_GROUP, --11.  ����Ȧ
           BALANCE_SIXMON, --12.  �����˻���6�����¾����
           BAL_1Y_UPTIMES, --13.  �ͻ���ȥһ����ĩ�������������ӵĴ���_U��
           BAL_1Y_UPTIMES_GROUP, --14.  �ͻ���ȥһ����ĩ�������������ӵĴ�������_U��
           BBK_NM, --15.  �����������
           CUST_CNT, --16.  ʮ������ǰor����ǰ�ͻ�����
           PD_CUST_CNT, --17.  ʮ�����º�or���º�ΥԼ�ͻ�����
           PD_INF, --18.  ΥԼ����
           GROUP_NM, --19.  ��������
           ISDEL, --20.  �Ƿ�ɾ��
           SRC_COMPANY_CD, --21.  Դ��ҵ����
           SRC_CD, --22.  Դϵͳ
           UPDT_BY, --23.  ������
           UPDT_DT --24.  ����ʱ��
      FROM TEMP_COMPY_OPERATIONCLEAR_CMB T
     WHERE RNK = '1';

  V_INSERT_COUNT := SQL%ROWCOUNT;
  COMMIT;

  --�������ݵ�LOG����
  V_EXEC_STEP := 'STEP6 �������ݵ�LOG����';
  INSERT INTO ETL_TGT_LOADLOG
    (LOADLOG_SID,
     BATCH_SID,
     PROCESS_NM,
     ORIG_RECORD_COUNT,
     DUP_RECORD_COUNT,
     INSERT_COUNT,
     UPDT_COUNT,
     START_DT,
     END_DT,
     START_ROWID,
     END_ROWID)
  VALUES
    (SEQ_ETL_TGT_LOADLOG.NEXTVAL,
     0,
     V_TASK_NAME,
     V_ORIG_RECORD_COUNT,
     V_DUP_RECORD_COUNT,
     V_INSERT_COUNT,
     NVL(V_UPDT_COUNT, 0),
     V_START_DT,
     V_END_DT,
     V_START_ROWID,
     V_END_ROWID);
  COMMIT;

  --������
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    V_ERROR_CD      := SQLCODE;
    V_ERROR_MESSAGE := V_EXEC_STEP || SUBSTR(SQLERRM, 1, 900);
    DBMS_OUTPUT.PUT_LINE('failed! ERROR:' || V_ERROR_CD || ' ,' ||
                         V_ERROR_MESSAGE);
    RAISE_APPLICATION_ERROR(-20021, V_ERROR_MESSAGE);
    RETURN;

    COMMIT;

END SP_COMPY_OPERATIONCLEAR_CMB;
/

prompt
prompt Creating procedure SP_COMPY_OVERDUEINTEREST_CMB
prompt ===============================================
prompt
CREATE OR REPLACE PROCEDURE sp_compy_overdueinterest_cmb IS
  /************************************************
  �洢���̣�sp_compy_overdueinterest_cmb
  ����ʱ�䣺2017/11/10
  �� �� �ˣ�ZhangCong
  Դ    ��stg_cmb_compy_overdueinterest(����ǷϢ)
  �� �� ��temp_compy_overdueinterest_cmb
  Ŀ �� ��compy_overdueinterest_cmb(����ǷϢ)
  ��    �ܣ�����ͬ��stg�µ�����ǷϢ���ݵ�tgt��
  �޸ļ�¼��2017/12/25 zhangcong ������SP�������²����߼�
  
  *************************************************/

  --------------------------------������־����-----------------------------
  v_error_cd          VARCHAR2(100);
  v_error_message     VARCHAR2(1000);
  v_task_name         etl_tgt_loadlog.process_nm%TYPE; --��������
  v_updt_dt           etl_tgt_loadlog.end_dt%TYPE; --�ϴ�ͬ������ʱ��
  v_start_dt          etl_tgt_loadlog.start_dt%TYPE; --��ʼʱ��
  v_end_dt            etl_tgt_loadlog.end_dt%TYPE; --����ʱ��
  v_start_rowid       etl_tgt_loadlog.start_rowid%TYPE; --��ʼ�к�
  v_end_rowid         etl_tgt_loadlog.end_rowid%TYPE; --��ֹ�к�
  v_insert_count      etl_tgt_loadlog.insert_count%TYPE; --�����¼��
  v_updt_count        etl_tgt_loadlog.updt_count%TYPE; --���¼�¼��
  v_orig_record_count etl_tgt_loadlog.orig_record_count%TYPE; --ԭʼ�ļ�¼��
  v_dup_record_count  etl_tgt_loadlog.dup_record_count%TYPE; --�ظ��ļ�¼��
  v_batch_sid         etl_tgt_loadlog.batch_sid%TYPE := 0; --���κ�

  --------------------------------����ҵ�����------------------------------
  v_updt_by compy_creditapply_cmb.updt_by%TYPE := 0; --������
  v_isdel   compy_creditapply_cmb.isdel%TYPE := 0; --�Ƿ�ɾ��
  v_src_cd  compy_creditapply_cmb.src_cd%TYPE := 'CMB'; --Դϵͳ

BEGIN

  --��������
  v_task_name := 'SP_COMPY_OVERDUEINTEREST_CMB';

  --��ȡ�ϴ�ͬ�����ݵ�ʱ��
  SELECT nvl(MAX(end_dt), to_date('1900-1-1', 'yyyy-mm-dd'))
    INTO v_updt_dt
    FROM etl_tgt_loadlog
   WHERE process_nm = v_task_name;

  --��ʼʱ��
  v_start_dt := SYSDATE;

  --��ȡ�����������ݲ��뵽��ʱ��
  INSERT INTO temp_compy_overdueinterest_cmb
    (company_id,
     data_dt,
     overdue_amt,
     innerdebt_amt,
     outerdebt_amt,
     earliest_overdue_dt,
     longest_overdue_days,
     isdel,
     src_company_cd,
     src_cd,
     updt_by,
     updt_dt,
     rnk,
     record_sid,
     loadlog_sid)
    SELECT b.company_id,
           to_date(a.data_dt, 'yyyy-mm-dd hh24:mi:ss') AS data_dt,
           CAST(a.overdue_amt AS NUMBER(24, 4)) AS overdue_amt,
           CAST(a.innerdebt_amt AS NUMBER(24, 4)) AS innerdebt_amt,
           CAST(a.outerdebt_amt AS NUMBER(24, 4)) AS outerdebt_amt,
           to_date(a.earliest_overdue_dt, 'yyyy-mm-dd hh24:mi:ss') AS earliest_overdue_dt,
           to_number(a.longest_overdue_days) AS longest_overdue_days,
           v_isdel AS isdel,
           a.cust_no AS src_company_cd,
           v_src_cd AS src_cd,
           v_updt_by AS updt_by,
           systimestamp AS updt_dt,
           row_number() over(PARTITION BY a.cust_no, a.data_dt ORDER BY a.updt_dt DESC, a.record_sid DESC) rnk, --ȥ��
           a.record_sid,
           a.loadlog_sid
      FROM cs_master_stg.stg_cmb_compy_overdueinterest a
      JOIN customer_cmb b
        ON (a.cust_no = b.cust_no AND b.company_id IS NOT NULL)
     WHERE a.updt_dt > v_updt_dt;

  --����ʱ��
  v_end_dt := SYSDATE;

  --��ȡ��־����
  SELECT COUNT(1) AS orig_record_count, --ԭʼ�ļ�¼��
         nvl(SUM(CASE
                   WHEN rnk > 1 THEN
                    1
                   ELSE
                    0
                 END),
             0) AS dup_record_count, --�ظ��ļ�¼��
         MIN(record_sid) AS start_rowid, --��ʼ�к�
         MAX(record_sid) AS end_rowid --��ֹ�к�
    INTO v_orig_record_count, v_dup_record_count, v_start_rowid, v_end_rowid
    FROM temp_compy_overdueinterest_cmb;

  --ɾ�������µ�����
  DELETE FROM compy_overdueinterest_cmb a
   WHERE EXISTS (SELECT 1
            FROM temp_compy_overdueinterest_cmb cdm
           WHERE a.company_id = cdm.company_id
             AND a.data_dt = cdm.data_dt);

  v_updt_count := SQL%ROWCOUNT;

  --������������
  INSERT INTO compy_overdueinterest_cmb
    (compy_overdueinterest_sid,
     company_id,
     data_dt,
     overdue_amt,
     innerdebt_amt,
     outerdebt_amt,
     earliest_overdue_dt,
     longest_overdue_days,
     isdel,
     src_company_cd,
     src_cd,
     updt_by,
     updt_dt)
    SELECT seq_compy_overdueinterest_cmb.nextval,
           a.company_id,
           a.data_dt,
           a.overdue_amt,
           a.innerdebt_amt,
           a.outerdebt_amt,
           a.earliest_overdue_dt,
           a.longest_overdue_days,
           a.isdel,
           a.src_company_cd,
           a.src_cd,
           a.updt_by,
           a.updt_dt
      FROM temp_compy_overdueinterest_cmb a
     WHERE a.company_id IS NOT NULL
       AND a.rnk = 1;

  v_insert_count := SQL%ROWCOUNT - v_updt_count;

  COMMIT;

  --�������ݵ�LOG����

  INSERT INTO etl_tgt_loadlog
    (loadlog_sid,
     batch_sid,
     process_nm,
     orig_record_count,
     dup_record_count,
     insert_count,
     updt_count,
     start_dt,
     end_dt,
     start_rowid,
     end_rowid)
    SELECT seq_etl_tgt_loadlog.nextval,
           v_batch_sid,
           v_task_name,
           v_orig_record_count,
           v_dup_record_count,
           v_insert_count,
           v_updt_count,
           v_start_dt,
           v_end_dt,
           v_start_rowid,
           v_end_rowid
      FROM dual;

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
  
END sp_compy_overdueinterest_cmb;
/

prompt
prompt Creating procedure SP_COMPY_PBCCREDIT_CMB
prompt =========================================
prompt
CREATE OR REPLACE PROCEDURE sp_compy_pbccredit_cmb IS
  /************************************************
  �洢���̣�sp_compy_pbccredit_cmb
  ����ʱ�䣺2017/11/10
  �� �� �ˣ�ZhangCong
  Դ    ��stg_cmb_compy_pbccredit(��������)
  �� �� ��temp_compy_pbccredit_cmb
  Ŀ �� ��compy_pbccredit_cmb(��������)
  ��    �ܣ�����ͬ��stg�µ������������ݵ�tgt��
  �޸ļ�¼��2017/12/25 zhangcong ������SP�������²����߼�
  
  *************************************************/

  --------------------------------������־����-----------------------------
  v_error_cd          VARCHAR2(100);
  v_error_message     VARCHAR2(1000);
  v_task_name         etl_tgt_loadlog.process_nm%TYPE; --��������
  v_updt_dt           etl_tgt_loadlog.end_dt%TYPE; --�ϴ�ͬ������ʱ��
  v_start_dt          etl_tgt_loadlog.start_dt%TYPE; --��ʼʱ��
  v_end_dt            etl_tgt_loadlog.end_dt%TYPE; --����ʱ��
  v_start_rowid       etl_tgt_loadlog.start_rowid%TYPE; --��ʼ�к�
  v_end_rowid         etl_tgt_loadlog.end_rowid%TYPE; --��ֹ�к�
  v_insert_count      etl_tgt_loadlog.insert_count%TYPE; --�����¼��
  v_updt_count        etl_tgt_loadlog.updt_count%TYPE; --���¼�¼��
  v_orig_record_count etl_tgt_loadlog.orig_record_count%TYPE; --ԭʼ�ļ�¼��
  v_dup_record_count  etl_tgt_loadlog.dup_record_count%TYPE; --�ظ��ļ�¼��
  v_batch_sid         etl_tgt_loadlog.batch_sid%TYPE := 0; --���κ�

  --------------------------------����ҵ�����------------------------------
  v_updt_by compy_creditapply_cmb.updt_by%TYPE := 0; --������
  v_isdel   compy_creditapply_cmb.isdel%TYPE := 0; --�Ƿ�ɾ��
  v_src_cd  compy_creditapply_cmb.src_cd%TYPE := 'CMB'; --Դϵͳ

BEGIN

  --��������
  v_task_name := 'SP_COMPY_PBCCREDIT_CMB';

  --��ȡ�ϴ�ͬ�����ݵ�ʱ��
  SELECT nvl(MAX(end_dt), to_date('1900-1-1', 'yyyy-mm-dd'))
    INTO v_updt_dt
    FROM etl_tgt_loadlog
   WHERE process_nm = v_task_name;

  --��ʼʱ��
  v_start_dt := SYSDATE;

  --��ȡ�����������ݲ��뵽��ʱ��
  INSERT INTO temp_compy_pbccredit_cmb
    (company_id,
     rpt_dt,
     normal_no,
     normal_balance,
     concerned_no,
     concerned_balance,
     bad_no,
     bad_balance,
     total_no,
     total_balance,
     isdel,
     src_company_cd,
     src_cd,
     updt_by,
     updt_dt,
     rnk,
     record_sid,
     loadlog_sid)
    SELECT b.company_id,
           to_date(a.rpt_dt, 'yyyy-mm-dd hh24:mi;ss') AS rpt_dt,
           to_number(a.normal_no) AS normal_no,
           CAST(a.normal_balance AS NUMBER(24, 4)) AS normal_balance,
           to_number(a.concerned_no) AS concerned_no,
           CAST(a.concerned_balance AS NUMBER(24, 4)) AS concerned_balance,
           to_number(a.bad_no) AS bad_no,
           CAST(a.bad_balance AS NUMBER(24, 4)) AS bad_balance,
           to_number(a.total_no) AS total_no,
           CAST(a.total_balance AS NUMBER(24, 4)) AS total_balance,
           v_isdel AS isdel,
           a.cust_no AS src_company_cd,
           v_src_cd AS src_cd,
           v_updt_by AS updt_by,
           systimestamp AS updt_dt,
           row_number() over(PARTITION BY a.cust_no, a.rpt_dt ORDER BY a.updt_dt DESC, a.record_sid DESC) rnk, --ȥ��
           a.record_sid,
           a.loadlog_sid
      FROM cs_master_stg.stg_cmb_compy_pbccredit a
      JOIN customer_cmb b
        ON (a.cust_no = b.cust_no AND b.company_id IS NOT NULL)
     WHERE a.updt_dt > v_updt_dt;

  --����ʱ��
  v_end_dt := SYSDATE;

  --��ȡ��־����
  SELECT COUNT(1) AS orig_record_count, --ԭʼ�ļ�¼��
         nvl(SUM(CASE
                   WHEN rnk > 1 THEN
                    1
                   ELSE
                    0
                 END),
             0) AS dup_record_count, --�ظ��ļ�¼��
         MIN(record_sid) AS start_rowid, --��ʼ�к�
         MAX(record_sid) AS end_rowid --��ֹ�к�
    INTO v_orig_record_count, v_dup_record_count, v_start_rowid, v_end_rowid
    FROM temp_compy_pbccredit_cmb;

  --ɾ�������µ�����
  DELETE FROM compy_pbccredit_cmb a
   WHERE EXISTS (SELECT 1
            FROM temp_compy_pbccredit_cmb cdm
           WHERE a.company_id = cdm.company_id
             AND a.rpt_dt = cdm.rpt_dt);

  v_updt_count := SQL%ROWCOUNT;

  --������������
  INSERT INTO compy_pbccredit_cmb
    (compy_pbccredit_sid,
     company_id,
     rpt_dt,
     normal_no,
     normal_balance,
     concerned_no,
     concerned_balance,
     bad_no,
     bad_balance,
     total_no,
     total_balance,
     isdel,
     src_company_cd,
     src_cd,
     updt_by,
     updt_dt)
    SELECT seq_compy_pbccredit_cmb.nextval,
           a.company_id,
           a.rpt_dt,
           a.normal_no,
           a.normal_balance,
           a.concerned_no,
           a.concerned_balance,
           a.bad_no,
           a.bad_balance,
           a.total_no,
           a.total_balance,
           a.isdel,
           a.src_company_cd,
           a.src_cd,
           a.updt_by,
           a.updt_dt
      FROM temp_compy_pbccredit_cmb a
     WHERE a.company_id IS NOT NULL
       AND a.rnk = 1;

  v_insert_count := SQL%ROWCOUNT - v_updt_count;

  COMMIT;

  --�������ݵ�LOG����

  INSERT INTO etl_tgt_loadlog
    (loadlog_sid,
     batch_sid,
     process_nm,
     orig_record_count,
     dup_record_count,
     insert_count,
     updt_count,
     start_dt,
     end_dt,
     start_rowid,
     end_rowid)
    SELECT seq_etl_tgt_loadlog.nextval,
           v_batch_sid,
           v_task_name,
           v_orig_record_count,
           v_dup_record_count,
           v_insert_count,
           v_updt_count,
           v_start_dt,
           v_end_dt,
           v_start_rowid,
           v_end_rowid
      FROM dual;

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
  
END sp_compy_pbccredit_cmb;
/

prompt
prompt Creating procedure SP_COMPY_PBCGUAR_CMB
prompt =======================================
prompt
CREATE OR REPLACE PROCEDURE SP_COMPY_PBCGUAR_CMB IS
  /*
  �洢���̣�SP_COMPY_PBCGUAR_CMB
  ��    �ܣ�����-������Ϣ-������STG->TEMP->TGT��
  �� �� �ˣ�RayLee
  ����ʱ�䣺2017/11/8 19:16:19
  Դ    ��CS_MASTER_STG.STG_COMPY_PBCGUAR_CMB
  �� �� ��TEMP_COMPY_PBCGUAR_CMB
  Ŀ �� ��COMPY_PBCGUAR_CMB
  --------------------------------------------------------------------
  �� �� �ˣ�RayLee
  �޸�ʱ�䣺2017-12-28 14:30:40
  �޸����ݣ���ͬҵ��������ȡupdt_dt�ϴ󣬶���ͬһ���Σ�updt_dt��ͬ����ȡrecord_sid����ļ�¼
  �� �� �ˣ�RayLee
  �޸�ʱ�䣺2018-01-08 16:14:35
  �޸����ݣ��������˺��Ŀͻ���   �����ͻ���ȡcompany_id
            �������˺��Ŀͻ���   �����ͻ���ȡcompany_nm
  */

  V_ERROR_CD          VARCHAR2(100);
  V_ERROR_MESSAGE     VARCHAR2(1000);
  V_TASK_NAME         ETL_TGT_LOADLOG.PROCESS_NM%TYPE; --��������
  V_UPDT_DT           ETL_TGT_LOADLOG.END_DT%TYPE; --�ϴ�ͬ������ʱ��
  V_START_DT          ETL_TGT_LOADLOG.START_DT%TYPE; --��ʼʱ��
  V_END_DT            ETL_TGT_LOADLOG.END_DT%TYPE; --����ʱ��
  V_START_ROWID       ETL_TGT_LOADLOG.START_ROWID%TYPE; --��ʼ�к�
  V_END_ROWID         ETL_TGT_LOADLOG.END_ROWID%TYPE; --��ֹ�к�
  V_INSERT_COUNT      ETL_TGT_LOADLOG.INSERT_COUNT%TYPE; --�����¼��
  V_UPDT_COUNT        ETL_TGT_LOADLOG.UPDT_COUNT%TYPE; --���¼�¼��
  V_ORIG_RECORD_COUNT NUMBER(16); --ԭʼ�ļ�¼��
  V_DUP_RECORD_COUNT  NUMBER(16); --�ظ��ļ�¼��

  --
  V_SRC_CD  TEMP_COMPY_PBCGUAR_CMB.SRC_CD%TYPE := UPPER(TRIM('CMB'));
  V_UPDT_BY TEMP_COMPY_PBCGUAR_CMB.UPDT_BY%TYPE := 0;
  V_ISDEL TEMP_COMPY_PBCGUAR_CMB.ISDEL%TYPE := 0;

  V_EXEC_STEP VARCHAR2(100);

BEGIN

  --��������
  V_TASK_NAME := 'SP_COMPY_PBCGUAR_CMB';

  --��ʼʱ��
  V_START_DT := SYSDATE;

  --��ȡ�ϴ�ͬ�����ݵ�ʱ��,����ǵ�һ������û�м�¼�ᷢ��NO_DATA_FOUND�쳣
  V_EXEC_STEP := 'STEP1 ��ȡ�ϴ�ͬ��ʱ��';
  BEGIN
    SELECT NVL(MAX(END_DT),TO_DATE('1900-1-1', 'yyyy-mm-dd'))
      INTO V_UPDT_DT
      FROM ETL_TGT_LOADLOG
     WHERE PROCESS_NM = V_TASK_NAME;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      V_UPDT_DT := TO_DATE('1900-1-1', 'yyyy-mm-dd');
  END;

  --��ȡ�����������ݲ��뵽��ʱ��
  V_EXEC_STEP := 'STEP2 ��ȡ�����������ݲ��뵽��ʱ��';
  INSERT INTO TEMP_COMPY_PBCGUAR_CMB
    (COMPY_PBCGUAR_SID, --1. ����ҵ����
     MSG_ID, --2. ���ı�ʶ��
     GRTSER_ID, --3. ������ͬ��ˮ��
     GRTBUSSER_ID, --4. ������ҵ����ˮ��
     COMPANY_ID, --5. ��ҵ��ʶ��
     RPT_DT, --6. ��������
     WARRANTEE_ID, --7. �������˺��Ŀͻ���
     WARRANTEE_NM, --8. ������������
     CURRENCY, --9. ��������
     GUAR_AMT, --10.  �������
     GUAR_TYPE_CD, --11.  ������ʽ
     BALANCE, --12.  ������ҵ�����
     END_DT, --13.  ������ҵ����壨���ڣ�����
     FIVE_CLASS_CD, --14.  ������ҵ���弶����
     WARRANTEE_CURRENCY, --15.  ������ҵ�����
     ISDEL, --16.  �Ƿ�ɾ��
     SRC_COMPANY_CD, --17.  Դ��ҵ����
     SRC_CD, --18.  Դϵͳ
     UPDT_BY, --19.  ������
     UPDT_DT, --20.  ����ʱ��
     RNK ,--13.  ��¼����
     RECORD_SID,  --14.��ˮ��
     LOADLOG_SID  --15.��־��

     )
    SELECT SEQ_COMPY_GROUPWARNING_CMB.NEXTVAL AS COMPY_PBCGUAR_SID, --1. ����ҵ����
           T.MSG_ID AS MSG_ID, --2. ���ı�ʶ��
           T.GRTSER_ID AS GRTSER_ID, --3. ������ͬ��ˮ��
           T.GRTBUSSER_ID AS GRTBUSSER_ID, --4. ������ҵ����ˮ��
           T.CUST_NO AS COMPANY_ID, --5. ��ҵ��ʶ��
           TO_DATE(T.RPT_DT, 'YYYY-MM-DD') AS RPT_DT, --6. ��������
           --T.WARRANTEE_CUST_NO AS WARRANTEE_ID, --7. �������˺��Ŀͻ���
           T2.COMPANY_ID AS WARRANTEE_ID, --7. �������˺��Ŀͻ���
           --T.WARRANTEE_CUST_NO AS WARRANTEE_NM, --8. ������������
           T2.CUSTOMER_NM AS WARRANTEE_NM, --8. ������������
           T.CURRENCY AS CURRENCY, --9. ��������
           T.GUAR_AMT AS GUAR_AMT, --10.  �������
           T.GUAR_TYPE AS GUAR_TYPE_CD, --11.  ������ʽ
           T.BALANCE AS BALANCE, --12.  ������ҵ�����
           TO_DATE(T.END_DT, 'YYYY-MM-DD') AS END_DT, --13.  ������ҵ����壨���ڣ�����
           T.FIVE_CLASS AS FIVE_CLASS_CD, --14.  ������ҵ���弶����
           T.WARRANTEE_CURRENCY AS WARRANTEE_CURRENCY, --15.  ������ҵ�����
           V_ISDEL AS ISDEL, --16.  �Ƿ�ɾ��
           T.CUST_NO AS SRC_COMPANY_CD, --17.  Դ��ҵ����
           V_SRC_CD AS SRC_CD, --18.  Դϵͳ
           V_UPDT_BY AS UPDT_BY, --19.  ������
           SYSTIMESTAMP AS UPDT_DT, --20.  ����ʱ��
           ROW_NUMBER() OVER(PARTITION BY T.MSG_ID, T.GRTSER_ID, T.GRTBUSSER_ID ORDER BY T.UPDT_DT DESC,T.RECORD_SID DESC) AS RNK, --13.  ��¼����
           T.RECORD_SID AS RECORD_SID,  --14.��ˮ��
           T.LOADLOG_SID AS LOADLOG_SID  --15.��־��
      FROM CS_MASTER_STG.STG_CMB_COMPY_PBCGUAR T
      LEFT JOIN CUSTOMER_CMB T1
        ON T1.CUST_NO = T.CUST_NO
      LEFT JOIN CUSTOMER_CMB T2
        ON T2.CUST_NO = T.WARRANTEE_CUST_NO
     WHERE T.UPDT_DT > V_UPDT_DT;

  --����ʱ��
  V_END_DT := SYSDATE;

  --��ȡ��־����
  V_EXEC_STEP := 'STEP3 ��ȡ��־����';
  SELECT COUNT(1) AS ORIG_RECORD_COUNT, --ԭʼ�ļ�¼��
         NVL(SUM(CASE
                   WHEN RNK > 1 THEN
                    1
                   ELSE
                    0
                 END),
             0) AS DUP_RECORD_COUNT, --�ظ��ļ�¼��
         MIN(RECORD_SID) AS START_ROWID, --��ʼ�к�
         MAX(RECORD_SID) AS END_ROWID --��ֹ�к�
    INTO V_ORIG_RECORD_COUNT,
         V_DUP_RECORD_COUNT,
         V_START_ROWID,
         V_END_ROWID
    FROM TEMP_COMPY_PBCGUAR_CMB;

  --ɾ���Ѿ����ڵ���������
  V_EXEC_STEP := 'STEP4 ɾ���Ѿ����ڵ���������';

  DELETE FROM COMPY_PBCGUAR_CMB A
   WHERE EXISTS (SELECT 1
            FROM TEMP_COMPY_PBCGUAR_CMB B
           WHERE A.MSG_ID = B.MSG_ID
             AND A.GRTSER_ID = B.GRTSER_ID
             AND A.GRTBUSSER_ID = B.GRTBUSSER_ID);

  V_EXEC_STEP := 'STEP5 �������ݵ�Ŀ���';
  INSERT INTO COMPY_PBCGUAR_CMB
    (COMPY_PBCGUAR_SID, --1. ����ҵ����
     MSG_ID, --2. ���ı�ʶ��
     GRTSER_ID, --3. ������ͬ��ˮ��
     GRTBUSSER_ID, --4. ������ҵ����ˮ��
     COMPANY_ID, --5. ��ҵ��ʶ��
     RPT_DT, --6. ��������
     WARRANTEE_ID, --7. �������˺��Ŀͻ���
     WARRANTEE_NM, --8. ������������
     CURRENCY, --9. ��������
     GUAR_AMT, --10.  �������
     GUAR_TYPE_CD, --11.  ������ʽ
     BALANCE, --12.  ������ҵ�����
     END_DT, --13.  ������ҵ����壨���ڣ�����
     FIVE_CLASS_CD, --14.  ������ҵ���弶����
     WARRANTEE_CURRENCY, --15.  ������ҵ�����
     ISDEL, --16.  �Ƿ�ɾ��
     SRC_COMPANY_CD, --17.  Դ��ҵ����
     SRC_CD, --18.  Դϵͳ
     UPDT_BY, --19.  ������
     UPDT_DT --20.  ����ʱ��

     )
    SELECT COMPY_PBCGUAR_SID, --1. ����ҵ����
           MSG_ID, --2. ���ı�ʶ��
           GRTSER_ID, --3. ������ͬ��ˮ��
           GRTBUSSER_ID, --4. ������ҵ����ˮ��
           COMPANY_ID, --5. ��ҵ��ʶ��
           RPT_DT, --6. ��������
           WARRANTEE_ID, --7. �������˺��Ŀͻ���
           WARRANTEE_NM, --8. ������������
           CURRENCY, --9. ��������
           GUAR_AMT, --10.  �������
           GUAR_TYPE_CD, --11.  ������ʽ
           BALANCE, --12.  ������ҵ�����
           END_DT, --13.  ������ҵ����壨���ڣ�����
           FIVE_CLASS_CD, --14.  ������ҵ���弶����
           WARRANTEE_CURRENCY, --15.  ������ҵ�����
           ISDEL, --16.  �Ƿ�ɾ��
           SRC_COMPANY_CD, --17.  Դ��ҵ����
           SRC_CD, --18.  Դϵͳ
           UPDT_BY, --19.  ������
           UPDT_DT --20.  ����ʱ��
      FROM TEMP_COMPY_PBCGUAR_CMB T
     WHERE RNK = '1';

  V_INSERT_COUNT := SQL%ROWCOUNT;
  COMMIT;

  --�������ݵ�LOG����
  V_EXEC_STEP := 'STEP6 �������ݵ�LOG����';
  INSERT INTO ETL_TGT_LOADLOG
    (LOADLOG_SID,
     BATCH_SID,
     PROCESS_NM,
     ORIG_RECORD_COUNT,
     DUP_RECORD_COUNT,
     INSERT_COUNT,
     UPDT_COUNT,
     START_DT,
     END_DT,
     START_ROWID,
     END_ROWID)
  VALUES
    (SEQ_ETL_TGT_LOADLOG.NEXTVAL,
     0,
     V_TASK_NAME,
     V_ORIG_RECORD_COUNT,
     V_DUP_RECORD_COUNT,
     V_INSERT_COUNT,
     NVL(V_UPDT_COUNT,0),
     V_START_DT,
     V_END_DT,
     V_START_ROWID,
     V_END_ROWID);
  COMMIT;

  --������
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    V_ERROR_CD      := SQLCODE;
    V_ERROR_MESSAGE := V_EXEC_STEP || SUBSTR(SQLERRM, 1, 900);
    DBMS_OUTPUT.PUT_LINE('failed! ERROR:' || V_ERROR_CD || ' ,' ||
                         V_ERROR_MESSAGE);
    RAISE_APPLICATION_ERROR(-20021, V_ERROR_MESSAGE);
    RETURN;

    COMMIT;

END SP_COMPY_PBCGUAR_CMB;
/

prompt
prompt Creating procedure SP_COMPY_RULEFACTOR_CMB
prompt ==========================================
prompt
CREATE OR REPLACE PROCEDURE sp_compy_rulefactor_cmb IS
  /*************************************
  �洢���̣�sp_compy_rulefactor_cmb
  ����ʱ�䣺2017/11/28
  �� �� �ˣ�ZhangCong
  Դ    ��stg_cmb_compy_rulefactor(������������ָ���)
  Ŀ �� ��compy_rulefactor_cmb(������������ָ���)
  ��    �ܣ���ʱͬ��������������������ָ�������

  ************************************/

  --------------------------------������־����--------------------------------------
  v_error_cd          VARCHAR2(100);
  v_error_message     VARCHAR2(1000);
  v_task_name         etl_tgt_loadlog.process_nm%TYPE; --��������
  v_updt_dt           etl_tgt_loadlog.end_dt%TYPE; --�ϴ�ͬ������ʱ��
  v_start_dt          etl_tgt_loadlog.start_dt%TYPE; --��ʼʱ��
  v_end_dt            etl_tgt_loadlog.end_dt%TYPE; --����ʱ��
  v_start_rowid       etl_tgt_loadlog.start_rowid%TYPE; --��ʼ�к�
  v_end_rowid         etl_tgt_loadlog.end_rowid%TYPE; --��ֹ�к�
  v_insert_count      etl_tgt_loadlog.insert_count%TYPE; --�����¼��
  v_updt_count        etl_tgt_loadlog.updt_count%TYPE; --���¼�¼��
  v_orig_record_count etl_tgt_loadlog.orig_record_count%TYPE; --ԭʼ�ļ�¼��
  v_dup_record_count  etl_tgt_loadlog.dup_record_count%TYPE; --�ظ��ļ�¼��
  v_batch_sid         etl_tgt_loadlog.batch_sid%TYPE := 0; --���κ�

  --------------------------------����ҵ�����-------------------------------------
  v_updt_by tmp_compy_rulefactor_cmb.updt_by%TYPE := 0; --������
  v_isdel   tmp_compy_rulefactor_cmb.isdel%TYPE := 0; --�Ƿ�ɾ��
  v_src_cd  tmp_compy_rulefactor_cmb.src_cd%TYPE := 'CMB';

BEGIN

  --��������
  v_task_name := 'SP_COMPY_RULEFACTOR_CMB';

  --��ʼʱ��
  v_start_dt := SYSDATE;

  --��ȡ�ϴ�ͬ�����ݵ�ʱ��
  SELECT nvl(MAX(end_dt), to_date('1900-1-1', 'yyyy-mm-dd'))
    INTO v_updt_dt
    FROM etl_tgt_loadlog
   WHERE process_nm = v_task_name;

  --��ȡ������������������ָ����¼
  INSERT INTO tmp_compy_rulefactor_cmb
    (company_id,
     factor_cd,
     factor_value,
     isdel,
     src_company_cd,
     src_cd,
     updt_by,
     updt_dt,
     rnk,
     record_sid,
     loadlog_sid)
    SELECT b.company_id,
           a.factor_cd,
           a.factor_value,
           v_isdel,
           a.cust_no,
           v_src_cd,
           v_updt_by,
           systimestamp,
           row_number() over(PARTITION BY b.company_id, a.factor_cd ORDER BY a.updt_dt DESC, a.record_sid DESC) rnk, --ȥ��
           a.record_sid,
           a.loadlog_sid
      FROM cmap_sync.stg_cmb_compy_rulefactor a
      JOIN customer_cmb b
        ON (a.cust_no = b.cust_no AND b.company_id IS NOT NULL)
     WHERE a.updt_dt > v_updt_dt;

  --����ʱ��
  v_end_dt := SYSDATE;

  --��ȡ��־����
  SELECT COUNT(1) AS orig_record_count, --ԭʼ�ļ�¼��
         nvl(SUM(CASE
                   WHEN rnk > 1 THEN
                    1
                   ELSE
                    0
                 END),
             0) AS dup_record_count, --�ظ��ļ�¼��
         MIN(record_sid) AS start_rowid, --��ʼ�к�
         MAX(record_sid) AS end_rowid --��ֹ�к�
    INTO v_orig_record_count, v_dup_record_count, v_start_rowid, v_end_rowid
    FROM tmp_compy_rulefactor_cmb;


  --ɾ�������µ�����
  DELETE FROM compy_rulefactor_cmb a
   WHERE EXISTS (SELECT 1
            FROM tmp_compy_rulefactor_cmb cdm
           WHERE a.company_id = cdm.company_id
             AND a.factor_cd = cdm.factor_cd);

  v_updt_count := SQL%ROWCOUNT;

  --����ͬ��,�����������
  INSERT INTO compy_rulefactor_cmb crc
    (compy_rulefactor_sid,
     company_id,
     factor_cd,
     factor_value,
     isdel,
     src_company_cd,
     src_cd,
     updt_by,
     updt_dt)
    SELECT seq_compy_rulefactor_cmb.nextval,
           company_id,
           factor_cd,
           factor_value,
           isdel,
           src_company_cd,
           src_cd,
           updt_by,
           updt_dt
      FROM tmp_compy_rulefactor_cmb a
     WHERE a.rnk = 1;

  v_insert_count := SQL%ROWCOUNT - v_updt_count;

  COMMIT;

  --�������ݵ�LOG����

  INSERT INTO etl_tgt_loadlog
    (loadlog_sid,
     batch_sid,
     process_nm,
     orig_record_count,
     dup_record_count,
     insert_count,
     updt_count,
     start_dt,
     end_dt,
     start_rowid,
     end_rowid)
    SELECT seq_etl_tgt_loadlog.nextval,
           v_batch_sid,
           v_task_name,
           v_orig_record_count,
           v_dup_record_count,
           v_insert_count,
           v_updt_count,
           v_start_dt,
           v_end_dt,
           v_start_rowid,
           v_end_rowid
      FROM dual;

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

END sp_compy_rulefactor_cmb;
/

prompt
prompt Creating procedure SP_COMPY_WARNINGS
prompt ====================================
prompt
CREATE OR REPLACE PROCEDURE sp_compy_warnings IS
  /*************************************
  �洢���̣�sp_compy_warnings
  ����ʱ�䣺2017/12/18
  �� �� �ˣ�ZhangCong
  Դ    ��tmp_compy_warnings(��ҵԤ���ź���ʱ��)
  Ŀ �� ��compy_warnings(��ҵԤ���ź��ܱ�)
  ��    �ܣ���ʱ(ÿ15����)ˢ�¸��µ�Ԥ����Ϣ������

  ************************************/

  --------------------------------������־����--------------------------------------
  v_error_cd          VARCHAR2(100);
  v_error_message     VARCHAR2(1000);
  v_task_name         etl_tgt_loadlog.process_nm%TYPE; --��������
  v_updt_dt           etl_tgt_loadlog.end_dt%TYPE; --�ϴ�ͬ������ʱ��
  v_start_dt          etl_tgt_loadlog.start_dt%TYPE; --��ʼʱ��
  v_end_dt            etl_tgt_loadlog.end_dt%TYPE; --����ʱ��
  v_start_rowid       etl_tgt_loadlog.start_rowid%TYPE; --��ʼ�к�
  v_end_rowid         etl_tgt_loadlog.end_rowid%TYPE; --��ֹ�к�
  v_insert_count      etl_tgt_loadlog.insert_count%TYPE; --�����¼��
  v_updt_count        etl_tgt_loadlog.updt_count%TYPE; --���¼�¼��
  v_orig_record_count etl_tgt_loadlog.orig_record_count%TYPE; --ԭʼ�ļ�¼��
  v_dup_record_count  etl_tgt_loadlog.dup_record_count%TYPE; --�ظ��ļ�¼��
  v_batch_sid         etl_tgt_loadlog.batch_sid%TYPE := 0; --���κ�
  v_his_day           NUMBER := 3; --��ʱ�����ݱ�������

BEGIN

  --��������
  v_task_name := 'SP_COMPY_WARNINGS';

  --��ȡ�ϴ�ͬ�����ݵ�ʱ��
  SELECT nvl(MAX(end_dt), to_date('1900-1-1', 'yyyy-mm-dd'))
    INTO v_updt_dt
    FROM etl_tgt_loadlog
   WHERE process_nm = v_task_name;

  --ɾ����ʷ��ͬ������,ֻ�������3�������
  DELETE FROM tmp_compy_warnings t WHERE t.updt_dt <= v_updt_dt - v_his_day;

  --������ʼ��
  v_start_dt := SYSDATE;

  --��ȡ��ʼ��¼��
  SELECT COUNT(*)
    INTO v_orig_record_count
    FROM tmp_compy_warnings t
   WHERE t.updt_dt > v_updt_dt
     AND t.isdel = 0;

  --���Ʊ�����������Ԥ���ܱ�
  INSERT ALL INTO compy_warnings
    (compy_warnings_sid, --1.��ˮ��
     subject_id, --2. Ԥ���������
     subject_type, --Ԥ����������
     notice_dt, --3. Ԥ���ź�ʱ��
     warning_type, --4. ������
     severity, --5. ���س̶�
     warning_score, --6. �źŷ�ֵ
     warning_title, --7. Ԥ������
     type_id, --8. �źŷ���
     status_flag, --9. ����״̬
     warning_result_cd, --10.��������
     adjust_severity, --11.���������س̶�
     adjust_score, --12.������÷�
     remark, --13.��ע
     process_by, --14.������
     process_dt, --15.����ʱ��
     isdel, --�Ƿ�ɾ��
     updt_by, --������
     src_cd, --Դϵͳ
     updt_dt --����ʱ��
     )
  VALUES
    (seq_compy_warnings.nextval, --1.��ˮ��
     subject_id, --2. Ԥ���������
     subject_type, --Ԥ����������
     notice_dt, --3. Ԥ���ź�ʱ��
     warning_type, --4. ������
     severity, --5. ���س̶�
     warning_score, --6. �źŷ�ֵ
     warning_title, --7. Ԥ������
     type_id, --8. �źŷ���
     status_flag, --9. ����״̬
     warning_result_cd, --10.��������
     adjust_severity, --11.���������س̶�
     adjust_score, --12.������÷�
     remark, --13.��ע
     process_by, --14.������
     process_dt, --15.����ʱ��
     isdel, --�Ƿ�ɾ��
     updt_by, --������
     src_cd, --Դϵͳ
     updt_dt --����ʱ��
     ) INTO compy_warnings_content
    (compy_warnings_sid, warning_content)
  VALUES
    (seq_compy_warnings.nextval, warning_content)
    SELECT subject_id, --2. Ԥ���������
           subject_type, --Ԥ����������
           notice_dt, --3. Ԥ���ź�ʱ��
           warning_type, --4. ������
           severity, --5. ���س̶�
           warning_score, --6. �źŷ�ֵ
           warning_title, --7. Ԥ������
           type_id, --8. �źŷ���
           status_flag, --9. ����״̬
           warning_result_cd, --10.��������
           adjust_severity, --11.���������س̶�
           adjust_score, --12.������÷�
           remark, --13.��ע
           process_by, --14.������
           process_dt, --15.����ʱ��
           warning_content, --16.Ԥ������
           isdel, --�Ƿ�ɾ��
           updt_by, --������
           src_cd, --Դϵͳ
           updt_dt --����ʱ��
      FROM (SELECT tmp.subject_id, --2. Ԥ���������
                   tmp.subject_type, --Ԥ����������
                   tmp.notice_dt, --3. Ԥ���ź�ʱ��
                   tmp.warning_type, --4. ������
                   severity, --5. ���س̶�
                   tmp.warning_score, --6. �źŷ�ֵ
                   tmp.warning_title, --7. Ԥ������
                   tmp.type_id, --8. �źŷ���
                   tmp.status_flag, --9. ����״̬
                   tmp.warning_result_cd, --10.��������
                   tmp.adjust_severity, --11.���������س̶�
                   tmp.adjust_score, --12.������÷�
                   tmp.remark, --13.��ע
                   tmp.process_by, --14.������
                   tmp.process_dt, --15.����ʱ��
                   tmp.warning_content, --16.Ԥ������
                   tmp.isdel, --�Ƿ�ɾ��
                   tmp.updt_by, --������
                   tmp.src_cd, --Դϵͳ
                   tmp.updt_dt, --����ʱ��
                   row_number() over(PARTITION BY tmp.subject_id, tmp.subject_type, trunc(tmp.notice_dt), tmp.warning_title ORDER BY tmp.updt_dt DESC) AS rnk
              FROM tmp_compy_warnings tmp
             WHERE tmp.updt_dt >= v_updt_dt
               AND tmp.isdel = 0)
     WHERE rnk = 1;

  v_insert_count     := SQL%ROWCOUNT / 2;
  v_updt_count       := 0;
  v_dup_record_count := v_orig_record_count - v_insert_count;

  --����ʱ��
  v_end_dt := SYSDATE;

  COMMIT;

  --�������ݵ�LOG����

  INSERT INTO etl_tgt_loadlog
    (loadlog_sid,
     batch_sid,
     process_nm,
     orig_record_count,
     dup_record_count,
     insert_count,
     updt_count,
     start_dt,
     end_dt,
     start_rowid,
     end_rowid)
    SELECT seq_etl_tgt_loadlog.nextval,
           v_batch_sid,
           v_task_name,
           v_orig_record_count,
           v_dup_record_count,
           v_insert_count,
           v_updt_count,
           v_start_dt,
           v_end_dt,
           v_start_rowid,
           v_end_rowid
      FROM dual;

  COMMIT;

  --������
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    v_error_cd      := SQLCODE;
    v_error_message := substr(SQLERRM, 1, 1000);
    dbms_output.put_line('failed! ERROR:' || v_error_cd || ' ,' ||
                         v_error_message);
    raise_application_error(-20021, v_error_message);
    RETURN;

    COMMIT;

END sp_compy_warnings;
/

prompt
prompt Creating procedure SP_DROP_IF_EXIST
prompt ===================================
prompt
CREATE OR REPLACE PROCEDURE sp_drop_if_exist(p_table in varchar2)
AS
  v_count number(10);
BEGIN
  SELECT COUNT(*)
    INTO V_COUNT
    FROM USER_TABLES
   WHERE TABLE_NAME = UPPER(p_table);

  IF V_COUNT > 0 THEN
    EXECUTE IMMEDIATE 'drop table ' || p_table || ' purge';
  END IF;
END;
/

prompt
prompt Creating procedure SP_COMPY_WARNINGS_BAK
prompt ========================================
prompt
CREATE OR REPLACE PROCEDURE SP_COMPY_WARNINGS_BAK
AS 
/*

2017-07-27 mark, convert to oracle
*/
vStart_dt timestamp;
vLast_dt timestamp;
vInsert_Count integer;
vUpdt_Count integer;
vOrig_Count integer;
vDup_Count integer;
vMessage varchar(1000) :='';
vSQL varchar(4000) :='';
vSQL1 varchar(4000) :='';
vSQL2 varchar(4000) :='';
vSQL3 varchar(4000) :='';
vSQL4 varchar(4000) :='';
vSQL5 varchar(4000) :='';

BEGIN

vStart_dt := systimestamp;
select max(start_dt) INTO vLast_dt from etl_dm_loadlog where upper(process_nm)='SP_COMPY_WARNINGS';

SP_DROP_IF_EXIST('tmp_compy_warnings');


	vMessage :='Start incremental refresh load..';

	vSQL1 :='create table tmp_compy_warnings
			 as
			select company_id,
				   company_name as company_nm,
				   notice_dt,
				   type_id,
				   importance as severity,
				   case_title as warning_title,
				   case_content as warning_content,
				   exposure_sid,
				   exposure,
				   region_cd,
				   region_nm,
				   rnk
			from 
				(select a.*,row_number()over(partition by company_id,notice_dt,type_id,importance,case_title order by 1) as rnk
				 from vw_compy_warnings a
				where notice_dt>=date'''||NVL(to_char(vLast_dt,'YYYY-MM-DD'),'1900-01-01')||'''
			    )a';

	vMessage :=vSQL1;	
	execute immediate  vSQL1;

	vSQL2 :='select count(*) from tmp_compy_warnings';	
	vMessage := vSQL2;
	execute immediate  vSQL2;
    vOrig_Count := SQL%ROWCOUNT;

	vSQL3 :='select count(*) from tmp_compy_warnings where rnk<>1';	
	vMessage :=vSQL3;
	execute immediate  vSQL3;
    vDup_Count := SQL%ROWCOUNT;


	vSQL4 :='select count(*)
			from tmp_compy_warnings a
			where rnk=1 and not exists (select compy_warnings_sid 
								from compy_warnings b 
								where a.company_id=b.company_id
									and a.notice_dt=b.notice_dt
									and a.type_id=b.type_id
									and a.severity=b.severity
									and a.warning_title=to_char(b.warning_title))';
                                    -- can't join with clob

	vMessage :=vSQL4;
	execute immediate  vSQL4;
    vInsert_Count := SQL%ROWCOUNT;


	vSQL5 :='insert into compy_warnings
			 select  seq_warnings.nextval,
				company_id,
				company_nm,
				notice_dt,
				type_id,
				severity,
				warning_title,
				warning_content,
				exposure_sid,
				exposure,
				region_cd,
				region_nm,
				null as severity_adjusted,
				0 as process_flag,
				sysdate as updt_dt
			from tmp_compy_warnings a
			where rnk=1 and not exists (select compy_warnings_sid 
								from compy_warnings b 
								where a.company_id=b.company_id
									and a.notice_dt=b.notice_dt
									and a.type_id=b.type_id
									and a.severity=b.severity
									and a.warning_title=to_char(b.warning_title)
									)';
	vMessage :=vSQL5;			 
	execute immediate  vSQL5;

	--ͳ�����ݼ������

	vUpdt_Count :=0;
    vMessage :='Incremental load completed, start inserting load log';

	insert into ETL_DM_LOADLOG
	(loadlog_sid,process_nm, orig_record_count, dup_record_count, insert_count, updt_count, start_dt, end_dt, start_rowid, end_rowid)
	select seq_etl_dm_loadlog.nextval,'SP_COMPY_WARNINGS',vOrig_Count,vDup_Count,vInsert_Count,vUpdt_Count,vStart_dt,systimestamp,null, null from dual;


EXCEPTION
	WHEN OTHERS THEN 
	RAISE_APPLICATION_ERROR( -20021, SQLERRM||' '||SQLCODE||' '||vmessage);
END;
/

prompt
prompt Creating procedure SP_COMPY_WARNINGTYPE_CMB
prompt ===========================================
prompt
CREATE OR REPLACE PROCEDURE sp_compy_warningtype_cmb IS
  /************************************************
  �洢���̣�sp_compy_warningtype_cmb
  ����ʱ�䣺2017/11/10
  �� �� �ˣ�ZhangCong
  Դ    ��stg_cmb_compy_warningtype(Ԥ������)
  �� �� ��temp_compy_warningtype_cmb
  Ŀ �� ��compy_warningtype_cmb(Ԥ������)
  ��    �ܣ�����ͬ��stg�µ�Ԥ���������ݵ�tgt��
  �޸ļ�¼��2017/12/25 zhangcong ������SP�������²����߼�
  
  *************************************************/

  --------------------------------������־����-----------------------------
  v_error_cd          VARCHAR2(100);
  v_error_message     VARCHAR2(1000);
  v_task_name         etl_tgt_loadlog.process_nm%TYPE; --��������
  v_updt_dt           etl_tgt_loadlog.end_dt%TYPE; --�ϴ�ͬ������ʱ��
  v_start_dt          etl_tgt_loadlog.start_dt%TYPE; --��ʼʱ��
  v_end_dt            etl_tgt_loadlog.end_dt%TYPE; --����ʱ��
  v_start_rowid       etl_tgt_loadlog.start_rowid%TYPE; --��ʼ�к�
  v_end_rowid         etl_tgt_loadlog.end_rowid%TYPE; --��ֹ�к�
  v_insert_count      etl_tgt_loadlog.insert_count%TYPE; --�����¼��
  v_updt_count        etl_tgt_loadlog.updt_count%TYPE; --���¼�¼��
  v_orig_record_count etl_tgt_loadlog.orig_record_count%TYPE; --ԭʼ�ļ�¼��
  v_dup_record_count  etl_tgt_loadlog.dup_record_count%TYPE; --�ظ��ļ�¼��
  v_batch_sid         etl_tgt_loadlog.batch_sid%TYPE := 0; --���κ�

  --------------------------------����ҵ�����------------------------------
  v_updt_by compy_creditapply_cmb.updt_by%TYPE := 0; --������
  v_isdel   compy_creditapply_cmb.isdel%TYPE := 0; --�Ƿ�ɾ��
  v_src_cd  compy_creditapply_cmb.src_cd%TYPE := 'CMB'; --Դϵͳ

BEGIN

  --��������
  v_task_name := 'SP_COMPY_WARNINGTYPE_CMB';

  --��ȡ�ϴ�ͬ�����ݵ�ʱ��
  SELECT nvl(MAX(end_dt), to_date('1900-1-1', 'yyyy-mm-dd'))
    INTO v_updt_dt
    FROM etl_tgt_loadlog
   WHERE process_nm = v_task_name;

  --��ʼʱ��
  v_start_dt := SYSDATE;

  --��ȡ�����������ݲ��뵽��ʱ��
  INSERT INTO temp_compy_warningtype_cmb
    (warning_cd,
     warning_nm,
     warning_type_cd,
     warning_type,
     is_single,
     is_emergent,
     score1,
     valid_flag1,
     score2,
     valid_flag2,
     index_type_cd,
     signal_type_cd,
     isdel,
     src_cd,
     updt_by,
     updt_dt,
     rnk,
     record_sid,
     loadlog_sid)
    SELECT a.warning_cd,
           a.warning_nm,
           a.warning_type_cd,
           a.warning_type,
           to_number(a.is_single) AS is_single,
           to_number(a.is_emergent) AS is_emergent,
           to_number(a.score1) AS score1,
           decode(a.valid_flag1, 'Y', 1, 'N', 0) AS valid_flag1,
           to_number(a.score2) AS score2,
           decode(a.valid_flag2, 'Y', 1, 'N', 0) AS valid_flag2,
           a.index_type_cd,
           a.signal_type_cd,
           v_isdel AS isdel,
           v_src_cd AS src_cd,
           v_updt_by AS updt_by,
           systimestamp AS updt_dt,
           row_number() over(PARTITION BY a.warning_cd ORDER BY a.updt_dt DESC, a.record_sid DESC) rnk, --ȥ��
           a.record_sid,
           a.loadlog_sid
      FROM cs_master_stg.stg_cmb_compy_warningtype a
     WHERE a.updt_dt > v_updt_dt;

  --����ʱ��
  v_end_dt := SYSDATE;

  --��ȡ��־����
  SELECT COUNT(1) AS orig_record_count, --ԭʼ�ļ�¼��
         nvl(SUM(CASE
                   WHEN rnk > 1 THEN
                    1
                   ELSE
                    0
                 END),
             0) AS dup_record_count, --�ظ��ļ�¼��
         MIN(record_sid) AS start_rowid, --��ʼ�к�
         MAX(record_sid) AS end_rowid --��ֹ�к�
    INTO v_orig_record_count, v_dup_record_count, v_start_rowid, v_end_rowid
    FROM temp_compy_warningtype_cmb;

  --ɾ�������µ�����
  DELETE compy_warningtype_cmb a
   WHERE EXISTS
   (SELECT 1 FROM temp_compy_warningtype_cmb cdm WHERE a.warning_cd = cdm.warning_cd);

  v_updt_count := SQL%ROWCOUNT;

  --������������
  INSERT INTO compy_warningtype_cmb
    (warning_cd,
     warning_nm,
     warning_type_cd,
     warning_type,
     is_single,
     is_emergent,
     score1,
     valid_flag1,
     score2,
     valid_flag2,
     index_type_cd,
     signal_type_cd,
     isdel,
     src_cd,
     updt_by,
     updt_dt)
    SELECT warning_cd,
           warning_nm,
           warning_type_cd,
           warning_type,
           is_single,
           is_emergent,
           score1,
           valid_flag1,
           score2,
           valid_flag2,
           index_type_cd,
           signal_type_cd,
           isdel,
           src_cd,
           updt_by,
           updt_dt
      FROM temp_compy_warningtype_cmb a
     WHERE a.rnk = 1;

  v_insert_count := SQL%ROWCOUNT - v_updt_count;

  COMMIT;

  --�������ݵ�LOG����

  INSERT INTO etl_tgt_loadlog
    (loadlog_sid,
     batch_sid,
     process_nm,
     orig_record_count,
     dup_record_count,
     insert_count,
     updt_count,
     start_dt,
     end_dt,
     start_rowid,
     end_rowid)
    SELECT seq_etl_tgt_loadlog.nextval,
           v_batch_sid,
           v_task_name,
           v_orig_record_count,
           v_dup_record_count,
           v_insert_count,
           v_updt_count,
           v_start_dt,
           v_end_dt,
           v_start_rowid,
           v_end_rowid
      FROM dual;

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
  
END sp_compy_warningtype_cmb;
/

prompt
prompt Creating procedure SP_COMPY_WARNING_CMB
prompt =======================================
prompt
CREATE OR REPLACE PROCEDURE sp_compy_warning_cmb IS
  /************************************************
  �洢���̣�sp_compy_warning_cmb
  ����ʱ�䣺2017/11/10
  �� �� �ˣ�ZhangCong
  Դ    ��stg_cmb_compy_warning(Ԥ���ź�)
  Ŀ �� ��compy_warning_cmb(Ԥ���ź�)
  ��    �ܣ�����ͬ��stg�µ�Ԥ���ź����ݵ�tgt��
  �޸ļ�¼��2017/12/25 zhangcong ������SP�������²����߼�
  
  *************************************************/

  --------------------------------������־����-----------------------------
  v_error_cd          VARCHAR2(100);
  v_error_message     VARCHAR2(1000);
  v_task_name         etl_tgt_loadlog.process_nm%TYPE; --��������
  v_updt_dt           etl_tgt_loadlog.end_dt%TYPE; --�ϴ�ͬ������ʱ��
  v_start_dt          etl_tgt_loadlog.start_dt%TYPE; --��ʼʱ��
  v_end_dt            etl_tgt_loadlog.end_dt%TYPE; --����ʱ��
  v_start_rowid       etl_tgt_loadlog.start_rowid%TYPE; --��ʼ�к�
  v_end_rowid         etl_tgt_loadlog.end_rowid%TYPE; --��ֹ�к�
  v_insert_count      etl_tgt_loadlog.insert_count%TYPE; --�����¼��
  v_updt_count        etl_tgt_loadlog.updt_count%TYPE; --���¼�¼��
  v_orig_record_count etl_tgt_loadlog.orig_record_count%TYPE; --ԭʼ�ļ�¼��
  v_dup_record_count  etl_tgt_loadlog.dup_record_count%TYPE; --�ظ��ļ�¼��
  v_batch_sid         etl_tgt_loadlog.batch_sid%TYPE := 0; --���κ�

  --------------------------------����ҵ�����------------------------------
  v_updt_by compy_creditapply_cmb.updt_by%TYPE := 0; --������
  v_isdel   compy_creditapply_cmb.isdel%TYPE := 0; --�Ƿ�ɾ��
  v_src_cd  compy_creditapply_cmb.src_cd%TYPE := 'CMB'; --Դϵͳ

BEGIN

  --��������
  v_task_name := 'SP_COMPY_WARNING_CMB';

  --��ȡ�ϴ�ͬ�����ݵ�ʱ��
  SELECT nvl(MAX(end_dt), to_date('1900-1-1', 'yyyy-mm-dd'))
    INTO v_updt_dt
    FROM etl_tgt_loadlog
   WHERE process_nm = v_task_name;

  --��ʼʱ��
  v_start_dt := SYSDATE;

  --��ȡ�����������ݲ��뵽��ʱ��
  INSERT INTO temp_compy_warning_cmb
    (warning_id,
     company_id,
     warning_cd,
     warn_title,
     warn_content,
     infosrc_dt,
     warnsrc_cd,
     warn_outer_src,
     attachment,
     status_cd,
     filter_status_cd,
     is_true,
     org_id,
     org_nm,
     lastmodify_dt,
     isdel,
     src_company_cd,
     src_cd,
     updt_by,
     updt_dt,
     rnk,
     record_sid,
     loadlog_sid)
    SELECT CAST(a.warning_id AS NUMBER(16)) AS warning_id,
           b.company_id,
           a.warning_cd,
           a.warn_title,
           a.warn_content,
           to_timestamp(a.infosrc_dt, 'yyyy-mm-dd hh24:mi:ss.FF6') AS infosrc_dt,
           a.warnsrc,
           a.warn_outer_src,
           a.attachment,
           a.status,
           a.filter_status_cd,
           decode(a.is_true, 'Y', 0, 1) AS is_true,
           a.org_id,
           a.org_nm,
           to_timestamp(a.lastmodify_dt, 'yyyy-mm-dd hh24:mi:ss.FF6') AS lastmodify_dt,
           v_isdel AS isdel,
           a.cust_no AS src_company_cd,
           v_src_cd AS src_cd,
           v_updt_by AS updt_by,
           systimestamp AS updt_dt,
           row_number() over(PARTITION BY a.warning_id ORDER BY a.updt_dt DESC, a.record_sid DESC) rnk, --ȥ��
           a.record_sid,
           a.loadlog_sid
      FROM cs_master_stg.stg_cmb_compy_warning a
      JOIN customer_cmb b
        ON (a.cust_no = b.cust_no AND b.company_id IS NOT NULL)
     WHERE a.updt_dt > v_updt_dt;

  --����ʱ��
  v_end_dt := SYSDATE;

  --��ȡ��־����
  SELECT COUNT(1) AS orig_record_count, --ԭʼ�ļ�¼��
         nvl(SUM(CASE
                   WHEN rnk > 1 THEN
                    1
                   ELSE
                    0
                 END),
             0) AS dup_record_count, --�ظ��ļ�¼��
         MIN(record_sid) AS start_rowid, --��ʼ�к�
         MAX(record_sid) AS end_rowid --��ֹ�к�
    INTO v_orig_record_count, v_dup_record_count, v_start_rowid, v_end_rowid
    FROM temp_compy_warning_cmb;

  --ɾ�������µ�����
  DELETE FROM compy_warning_cmb a
   WHERE EXISTS
   (SELECT 1 FROM temp_compy_warning_cmb cdm WHERE a.warning_id = cdm.warning_id);

  v_updt_count := SQL%ROWCOUNT;

  --������������
  INSERT INTO compy_warning_cmb
    (warning_id,
     company_id,
     warning_cd,
     warn_title,
     warn_content,
     infosrc_dt,
     warnsrc_cd,
     warn_outer_src,
     attachment,
     status_cd,
     filter_status_cd,
     is_true,
     org_id,
     org_nm,
     lastmodify_dt,
     isdel,
     src_company_cd,
     src_cd,
     updt_by,
     updt_dt)
    SELECT warning_id,
           company_id,
           warning_cd,
           warn_title,
           warn_content,
           infosrc_dt,
           warnsrc_cd,
           warn_outer_src,
           attachment,
           status_cd,
           filter_status_cd,
           is_true,
           org_id,
           org_nm,
           lastmodify_dt,
           isdel,
           src_company_cd,
           src_cd,
           updt_by,
           updt_dt
      FROM temp_compy_warning_cmb a
     WHERE a.company_id IS NOT NULL
       AND a.rnk = 1;

  v_insert_count := SQL%ROWCOUNT - v_updt_count;

  COMMIT;

  --�������ݵ�LOG����

  INSERT INTO etl_tgt_loadlog
    (loadlog_sid,
     batch_sid,
     process_nm,
     orig_record_count,
     dup_record_count,
     insert_count,
     updt_count,
     start_dt,
     end_dt,
     start_rowid,
     end_rowid)
    SELECT seq_etl_tgt_loadlog.nextval,
           v_batch_sid,
           v_task_name,
           v_orig_record_count,
           v_dup_record_count,
           v_insert_count,
           v_updt_count,
           v_start_dt,
           v_end_dt,
           v_start_rowid,
           v_end_rowid
      FROM dual;

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
  
END sp_compy_warning_cmb;
/

prompt
prompt Creating procedure SP_COMPY_WARNLEVELCHG_CMB
prompt ============================================
prompt
CREATE OR REPLACE PROCEDURE SP_COMPY_WARNLEVELCHG_CMB IS
  /*
  �洢���̣�SP_COMPY_WARNLEVELCHG_CMB
  ��    �ܣ�����-����Ԥ���ȼ��϶�-������STG->TEMP->TGT��
            ���������������
            ҵ���������ͻ���+����+����ʱ��
  �� �� �ˣ�RayLee
  ����ʱ�䣺2017/11/8 19:16:19
  Դ    ��CS_MASTER_STG.STG_COMPY_WARNLEVELCHG_CMB
  �� �� ��TEMP_COMPY_WARNLEVELCHG_CMB
  Ŀ �� ��COMPY_WARNLEVELCHG_CMB
  --------------------------------------------------------------------
  �� �� �ˣ�RAYLEE
  �޸�ʱ�䣺2017-12-28 14:20:16
  �޸����ݣ���ͬҵ��������ȡupdt_dt�ϴ󣬶���ͬһ���Σ�updt_dt��ͬ����ȡrecord_sid����ļ�¼
    --------------------------------------------------------------------
  �� �� �ˣ�RAYLEE
  �޸�ʱ�䣺2018-01-03 18:59:16
  �޸����ݣ���������Ž��з���
  */

  V_ERROR_CD          VARCHAR2(100);
  V_ERROR_MESSAGE     VARCHAR2(1000);
  V_TASK_NAME         ETL_TGT_LOADLOG.PROCESS_NM%TYPE; --��������
  V_UPDT_DT           ETL_TGT_LOADLOG.END_DT%TYPE; --�ϴ�ͬ������ʱ��
  V_START_DT          ETL_TGT_LOADLOG.START_DT%TYPE; --��ʼʱ��
  V_END_DT            ETL_TGT_LOADLOG.END_DT%TYPE; --����ʱ��
  V_START_ROWID       ETL_TGT_LOADLOG.START_ROWID%TYPE; --��ʼ�к�
  V_END_ROWID         ETL_TGT_LOADLOG.END_ROWID%TYPE; --��ֹ�к�
  V_INSERT_COUNT      ETL_TGT_LOADLOG.INSERT_COUNT%TYPE; --�����¼��
  V_UPDT_COUNT        ETL_TGT_LOADLOG.UPDT_COUNT%TYPE; --���¼�¼��
  V_ORIG_RECORD_COUNT NUMBER(16); --ԭʼ�ļ�¼��
  V_DUP_RECORD_COUNT  NUMBER(16); --�ظ��ļ�¼��

  --
  V_SRC_CD  TEMP_COMPY_WARNLEVELCHG_CMB.SRC_CD%TYPE := UPPER(TRIM('CMB'));
  V_UPDT_BY TEMP_COMPY_WARNLEVELCHG_CMB.UPDT_BY%TYPE := 0;
  V_ISDEL TEMP_COMPY_WARNLEVELCHG_CMB.ISDEL%TYPE := 0;

  V_EXEC_STEP VARCHAR2(100);

BEGIN

  --��������
  V_TASK_NAME := 'SP_COMPY_WARNLEVELCHG_CMB';

  --��ʼʱ��
  V_START_DT := SYSDATE;

  --��ȡ�ϴ�ͬ�����ݵ�ʱ��,����ǵ�һ������û�м�¼�ᷢ��NO_DATA_FOUND�쳣
  V_EXEC_STEP := 'STEP1 ��ȡ�ϴ�ͬ��ʱ��';
  BEGIN
    SELECT NVL(MAX(END_DT),TO_DATE('1900-1-1', 'yyyy-mm-dd'))
      INTO V_UPDT_DT
      FROM ETL_TGT_LOADLOG
     WHERE PROCESS_NM = V_TASK_NAME;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      V_UPDT_DT := TO_DATE('1900-1-1', 'yyyy-mm-dd');
  END;

  --��ȡ�����������ݲ��뵽��ʱ��
  V_EXEC_STEP := 'STEP2 ��ȡ�����������ݲ��뵽��ʱ��';
  INSERT INTO TEMP_COMPY_WARNLEVELCHG_CMB
    (WARNCHG_ID, --1. �����
     COMPANY_ID, --2. ��ҵ��ʶ��
     SUBMIT_DT, --3. ����ʱ��
     WARN_LEVEL, --4. ������ͻ����շֲ�
     PRE_WARN_LEVEL, --5. ����ǰ�ͻ����շֲ�
     OPERATE_MODULE, --6. �䶯��Դ
     OPERATE_DT, --7. ����ʱ��
     ISDEL, --8. �Ƿ�ɾ��
     SRC_COMPANY_CD, --9. Դ��ҵ����
     SRC_CD, --10.  Դϵͳ
     UPDT_BY, --11.  ������
     UPDT_DT, --12.  ����ʱ��
     RNK, --13.  ��¼����
     RECORD_SID,  --14.��ˮ��
     LOADLOG_SID  --15.��־��
     )
    SELECT T.WARNCHG_ID AS WARNCHG_ID, --1. �����
           T1.COMPANY_ID AS COMPANY_ID, --2. ��ҵ��ʶ��
           TO_TIMESTAMP(T.CREATE_DT, 'YYYY-MM-DD HH24:MI:SS') AS SUBMIT_DT, --3. ����ʱ��
           T.WARN_LEVEL AS WARN_LEVEL, --4. ������ͻ����շֲ�
           T.PRE_WARN_LEVEL AS PRE_WARN_LEVEL, --5. ����ǰ�ͻ����շֲ�
           T.OPERATE_MODULE AS OPERATE_MODULE, --6. �䶯��Դ
           TO_TIMESTAMP(T.OPERATE_DT, 'YYYY-MM-DD HH24:MI:SS') AS OPERATE_DT, --7. ����ʱ��
           V_ISDEL AS ISDEL, --8. �Ƿ�ɾ��
           T.CUST_NO AS SRC_COMPANY_CD, --9. Դ��ҵ����
           V_SRC_CD AS SRC_CD, --10.  Դϵͳ
           V_UPDT_BY AS UPDT_BY, --11.  ������
           SYSTIMESTAMP AS UPDT_DT, --12.  ����ʱ��
           ROW_NUMBER() OVER(PARTITION BY T.WARNCHG_ID ORDER BY T.UPDT_DT DESC, T.RECORD_SID DESC) AS RNK, --13.  ��¼����
           T.RECORD_SID AS RECORD_SID,  --14.��ˮ��
           T.LOADLOG_SID AS LOADLOG_SID --15.��־��
      FROM CS_MASTER_STG.STG_CMB_COMPY_WARNLEVELCHG T
      LEFT JOIN CUSTOMER_CMB T1
        ON T1.CUST_NO = T.CUST_NO
     WHERE T.UPDT_DT > V_UPDT_DT
       AND T1.COMPANY_ID IS NOT NULL;

  --����ʱ��
  V_END_DT := SYSDATE;

  --��ȡ��־����
  V_EXEC_STEP := 'STEP3 ��ȡ��־����';
  SELECT COUNT(1) AS ORIG_RECORD_COUNT, --ԭʼ�ļ�¼��
         NVL(SUM(CASE
                   WHEN RNK > 1 THEN
                    1
                   ELSE
                    0
                 END),
             0) AS DUP_RECORD_COUNT, --�ظ��ļ�¼��
         MIN(RECORD_SID) AS START_ROWID, --��ʼ�к�
         MAX(RECORD_SID) AS END_ROWID --��ֹ�к�
    INTO V_ORIG_RECORD_COUNT,
         V_DUP_RECORD_COUNT,
         V_START_ROWID,
         V_END_ROWID
    FROM TEMP_COMPY_WARNLEVELCHG_CMB;

  --ɾ���Ѿ����ڵ���������
  V_EXEC_STEP := 'STEP4 ɾ���Ѿ����ڵ���������';
  DELETE FROM COMPY_WARNLEVELCHG_CMB
   WHERE WARNCHG_ID IN (SELECT WARNCHG_ID FROM TEMP_COMPY_WARNLEVELCHG_CMB);


  V_EXEC_STEP := 'STEP5 �������ݵ�Ŀ���';
  INSERT INTO COMPY_WARNLEVELCHG_CMB
    (WARNCHG_ID, --1. �����
     COMPANY_ID, --2. ��ҵ��ʶ��
     SUBMIT_DT, --3. ����ʱ��
     WARN_LEVEL, --4. ������ͻ����շֲ�
     PRE_WARN_LEVEL, --5. ����ǰ�ͻ����շֲ�
     OPERATE_MODULE, --6. �䶯��Դ
     OPERATE_DT, --7. ����ʱ��
     ISDEL, --8. �Ƿ�ɾ��
     SRC_COMPANY_CD, --9. Դ��ҵ����
     SRC_CD, --10.  Դϵͳ
     UPDT_BY, --11.  ������
     UPDT_DT --12.  ����ʱ��
     )
    SELECT T.WARNCHG_ID     AS WARNCHG_ID, --1. �����
           T.COMPANY_ID     AS COMPANY_ID, --2. ��ҵ��ʶ��
           T.SUBMIT_DT      AS SUBMIT_DT, --3. ����ʱ��
           T.WARN_LEVEL     AS WARN_LEVEL, --4. ������ͻ����շֲ�
           T.PRE_WARN_LEVEL AS PRE_WARN_LEVEL, --5. ����ǰ�ͻ����շֲ�
           T.OPERATE_MODULE AS OPERATE_MODULE, --6. �䶯��Դ
           T.OPERATE_DT     AS OPERATE_DT, --7. ����ʱ��
           T.ISDEL          AS ISDEL, --8. �Ƿ�ɾ��
           T.SRC_COMPANY_CD AS SRC_COMPANY_CD, --9. Դ��ҵ����
           T.SRC_CD         AS SRC_CD, --10.  Դϵͳ
           T.UPDT_BY        AS UPDT_BY, --11.  ������
           SYSDATE          AS UPDT_DT --12.  ����ʱ��
      FROM TEMP_COMPY_WARNLEVELCHG_CMB T
     WHERE RNK = '1';

  V_INSERT_COUNT := SQL%ROWCOUNT;
  COMMIT;

  --�������ݵ�LOG����
  V_EXEC_STEP := 'STEP6 �������ݵ�LOG����';
  INSERT INTO ETL_TGT_LOADLOG
    (LOADLOG_SID,
     BATCH_SID,
     PROCESS_NM,
     ORIG_RECORD_COUNT,
     DUP_RECORD_COUNT,
     INSERT_COUNT,
     UPDT_COUNT,
     START_DT,
     END_DT,
     START_ROWID,
     END_ROWID)
  VALUES
    (SEQ_ETL_TGT_LOADLOG.NEXTVAL,
     0,
     V_TASK_NAME,
     V_ORIG_RECORD_COUNT,
     V_DUP_RECORD_COUNT,
     V_INSERT_COUNT,
     NVL(V_UPDT_COUNT,0),
     V_START_DT,
     V_END_DT,
     V_START_ROWID,
     V_END_ROWID);
  COMMIT;

  --������
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    V_ERROR_CD      := SQLCODE;
    V_ERROR_MESSAGE := V_EXEC_STEP || SUBSTR(SQLERRM, 1, 900);
    DBMS_OUTPUT.PUT_LINE('failed! ERROR:' || V_ERROR_CD || ' ,' ||
                         V_ERROR_MESSAGE);
    RAISE_APPLICATION_ERROR(-20021, V_ERROR_MESSAGE);
    RETURN;

    COMMIT;

END SP_COMPY_WARNLEVELCHG_CMB;
/

prompt
prompt Creating procedure SP_CUSTOMER_CMB
prompt ==================================
prompt
CREATE OR REPLACE PROCEDURE sp_customer_cmb IS
  /************************************************
  �洢���̣�sp_customer_cmb
  ����ʱ�䣺2017/11/10
  �� �� �ˣ�ZhangCong
  Դ    ��stg_cmb_customer(�ͻ���������)
  �� �� ��temp_customer_cmb
  Ŀ �� ��customer_cmb(�ͻ���������)
  ��    �ܣ�����ͬ��stg�µĿͻ������������ݵ�tgt��
  �޸ļ�¼��2017/12/25 zhangcong ������SP�������²����߼�

  *************************************************/

  --------------------------------������־����-----------------------------
  v_error_cd          VARCHAR2(100);
  v_error_message     VARCHAR2(1000);
  v_task_name         etl_tgt_loadlog.process_nm%TYPE; --��������
  v_updt_dt           etl_tgt_loadlog.end_dt%TYPE; --�ϴ�ͬ������ʱ��
  v_start_dt          etl_tgt_loadlog.start_dt%TYPE; --��ʼʱ��
  v_end_dt            etl_tgt_loadlog.end_dt%TYPE; --����ʱ��
  v_start_rowid       etl_tgt_loadlog.start_rowid%TYPE; --��ʼ�к�
  v_end_rowid         etl_tgt_loadlog.end_rowid%TYPE; --��ֹ�к�
  v_insert_count      etl_tgt_loadlog.insert_count%TYPE; --�����¼��
  v_updt_count        etl_tgt_loadlog.updt_count%TYPE; --���¼�¼��
  v_orig_record_count etl_tgt_loadlog.orig_record_count%TYPE; --ԭʼ�ļ�¼��
  v_dup_record_count  etl_tgt_loadlog.dup_record_count%TYPE; --�ظ��ļ�¼��
  v_batch_sid         etl_tgt_loadlog.batch_sid%TYPE := 0; --���κ�

  --------------------------------����ҵ�����------------------------------
  v_updt_by compy_creditapply_cmb.updt_by%TYPE := 0; --������
  v_isdel   compy_creditapply_cmb.isdel%TYPE := 0; --�Ƿ�ɾ��
  v_src_cd  compy_creditapply_cmb.src_cd%TYPE := 'CMB'; --Դϵͳ

BEGIN

  --��������
  v_task_name := 'SP_CUSTOMER_CMB';

  --��ȡ�ϴ�ͬ�����ݵ�ʱ��
  SELECT nvl(MAX(end_dt), to_date('1900-1-1', 'yyyy-mm-dd'))
    INTO v_updt_dt
    FROM etl_tgt_loadlog
   WHERE process_nm = v_task_name;

  --��ʼʱ��
  v_start_dt := SYSDATE;

  --��ȡ�����������ݲ��뵽��ʱ��
  INSERT INTO temp_customer_cmb
    (cust_no,
     company_id,
     customer_nm,
     org_num,
     bl_numb,
     risk_status_cd,
     class_grade_cd,
     is_yjhplatform,
     is_loan,
     is_cmbrelatecust,
     customer_grade_cd,
     is_high_risk,
     group_cust_no,
     group_nm,
     group_warnstatus_cd,
     is_guar,
     guargrp_risklevel_cd,
     rating_cd,
     isdel,
     src_company_cd,
     srcid,
     src_cd,
     updt_by,
     updt_dt,
     rnk,
     record_sid,
     loadlog_sid)
    SELECT a.cust_no,
           a.company_id,
           a.customer_nm,
           a.org_num,
           a.bl_numb,
           a.risk_status_cd,
           a.class_grade_cd,
           to_number(a.is_yjhplatform) AS is_yjhplatform,
           to_number(a.is_loan) AS is_loan,
           to_number(a.is_cmbrelatecust) AS is_cmbrelatecust,
           a.customer_grade_cd,
           to_number(a.is_high_risk) AS is_high_risk,
           a.group_cust_no,
           a.group_nm,
           a.group_warnstatus_cd,
           to_number(a.is_guar) AS is_guar,
           a.guargrp_risklevel_cd,
           a.rating_cd,
           v_isdel AS isdel,
           a.cust_no AS src_company_cd,
           -1 AS srcid,
           v_src_cd AS src_cd,
           v_updt_by AS updt_by,
           systimestamp AS updt_dt,
           row_number() over(PARTITION BY a.cust_no ORDER BY a.updt_dt DESC, a.record_sid DESC) rnk, --ȥ��
           a.record_sid,
           a.loadlog_sid
      FROM cs_master_stg.stg_cmb_customer a
     WHERE a.updt_dt > v_updt_dt;

  --����ʱ��
  v_end_dt := SYSDATE;

  --��ȡ��־����
  SELECT COUNT(1) AS orig_record_count, --ԭʼ�ļ�¼��
         nvl(SUM(CASE
                   WHEN rnk > 1 THEN
                    1
                   ELSE
                    0
                 END),
             0) AS dup_record_count, --�ظ��ļ�¼��
         MIN(record_sid) AS start_rowid, --��ʼ�к�
         MAX(record_sid) AS end_rowid --��ֹ�к�
    INTO v_orig_record_count, v_dup_record_count, v_start_rowid, v_end_rowid
    FROM temp_customer_cmb;

  --ɾ�������µ�����
  DELETE FROM customer_cmb a
   WHERE EXISTS (SELECT 1 FROM temp_customer_cmb cdm WHERE a.cust_no = cdm.cust_no);

  v_updt_count := SQL%ROWCOUNT;

  --������������
  INSERT INTO customer_cmb
    (cust_no,
     company_id,
     customer_nm,
     org_num,
     bl_numb,
     risk_status_cd,
     class_grade_cd,
     is_yjhplatform,
     is_loan,
     is_cmbrelatecust,
     customer_grade_cd,
     is_high_risk,
     group_cust_no,
     group_nm,
     group_warnstatus_cd,
     is_guar,
     guargrp_risklevel_cd,
     rating_cd,
     isdel,
     src_company_cd,
     srcid,
     src_cd,
     updt_by,
     updt_dt)
    SELECT cust_no,
           company_id,
           customer_nm,
           org_num,
           bl_numb,
           risk_status_cd,
           class_grade_cd,
           is_yjhplatform,
           is_loan,
           is_cmbrelatecust,
           customer_grade_cd,
           is_high_risk,
           group_cust_no,
           group_nm,
           group_warnstatus_cd,
           is_guar,
           guargrp_risklevel_cd,
           rating_cd,
           isdel,
           src_company_cd,
           srcid,
           src_cd,
           updt_by,
           updt_dt
      FROM temp_customer_cmb a
     WHERE a.rnk = 1;

  v_insert_count := SQL%ROWCOUNT - v_updt_count;

  COMMIT;

  --�������ݵ�LOG����

  INSERT INTO etl_tgt_loadlog
    (loadlog_sid,
     batch_sid,
     process_nm,
     orig_record_count,
     dup_record_count,
     insert_count,
     updt_count,
     start_dt,
     end_dt,
     start_rowid,
     end_rowid)
    SELECT seq_etl_tgt_loadlog.nextval,
           v_batch_sid,
           v_task_name,
           v_orig_record_count,
           v_dup_record_count,
           v_insert_count,
           v_updt_count,
           v_start_dt,
           v_end_dt,
           v_start_rowid,
           v_end_rowid
      FROM dual;

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

END sp_customer_cmb;
/

prompt
prompt Creating procedure SP_LKP_CONSTANT
prompt ==================================
prompt
CREATE OR REPLACE PROCEDURE sp_lkp_constant IS
  /************************************************
  �洢���̣�sp_lkp_constant
  ����ʱ�䣺2017/11/10
  �� �� �ˣ�ZhangCong
  Դ    ��stg_cmb_constant(������)
  Ŀ �� ��lkp_constant(������)
  ��    �ܣ�ȫ��ͬ��stg�µĳ��������ݵ�tgt��
  �޸ļ�¼��

  *************************************************/

  --------------------------------������־����-----------------------------
  v_error_cd          VARCHAR2(100);
  v_error_message     VARCHAR2(1000);
  v_task_name         etl_tgt_loadlog.process_nm%TYPE; --��������
  v_updt_dt           etl_tgt_loadlog.end_dt%TYPE; --�ϴ�ͬ������ʱ��
  v_start_dt          etl_tgt_loadlog.start_dt%TYPE; --��ʼʱ��
  v_end_dt            etl_tgt_loadlog.end_dt%TYPE; --����ʱ��
  v_start_rowid       etl_tgt_loadlog.start_rowid%TYPE; --��ʼ�к�
  v_end_rowid         etl_tgt_loadlog.end_rowid%TYPE; --��ֹ�к�
  v_insert_count      etl_tgt_loadlog.insert_count%TYPE; --�����¼��
  v_updt_count        etl_tgt_loadlog.updt_count%TYPE; --���¼�¼��
  v_orig_record_count etl_tgt_loadlog.orig_record_count%TYPE; --ԭʼ�ļ�¼��
  v_dup_record_count  etl_tgt_loadlog.dup_record_count%TYPE; --�ظ��ļ�¼��
  v_batch_sid         etl_tgt_loadlog.batch_sid%TYPE := 0; --���κ�

BEGIN

  --��������
  v_task_name := 'SP_LKP_CONSTANT';

  --��ȡ�ϴ�ͬ�����ݵ�ʱ��
  SELECT nvl(MAX(end_dt), to_date('1900-1-1', 'yyyy-mm-dd'))
    INTO v_updt_dt
    FROM etl_tgt_loadlog
   WHERE process_nm = v_task_name;

  --��ʼʱ��
  v_start_dt := SYSDATE;

  --ɾ�����������͵���������
  DELETE FROM lkp_constant b
   WHERE EXISTS (SELECT 1
            FROM cs_master_stg.stg_cmb_constant a
           WHERE to_char(b.constant_type) = a.root_constant_cd);

  v_updt_count := SQL%ROWCOUNT;

  --��ȡ�����������ݲ��뵽��ʱ��
  INSERT INTO lkp_constant
    (constant_cd,
     constant_nm,
     parent_cd,
     constant_type,
     src_constant_cd,
     remark,
     isdel,
     updt_dt)
    SELECT a.child_constant_cd,
           a.constant_nm,
           a.parent_constant_cd,
           to_number(a.root_constant_cd),
           NULL,
           NULL,
           decode(a.record_status, 'A', 0, 1),
           systimestamp
      FROM cs_master_stg.stg_cmb_constant a
     WHERE a.child_constant_cd IS NOT NULL
       AND a.constant_nm IS NOT NULL
       AND a.root_constant_cd IS NOT NULL
       AND a.record_status IS NOT NULL
       AND a.create_dt IS NOT NULL
       AND NOT (to_number(a.root_constant_cd) = 28 AND a.child_constant_cd LIKE 'L%');

  v_insert_count := SQL%ROWCOUNT - v_updt_count;

  --����ʱ��
  v_end_dt := SYSDATE;

  COMMIT;

  --�������ݵ�LOG����

  INSERT INTO etl_tgt_loadlog
    (loadlog_sid,
     batch_sid,
     process_nm,
     orig_record_count,
     dup_record_count,
     insert_count,
     updt_count,
     start_dt,
     end_dt,
     start_rowid,
     end_rowid)
    SELECT seq_etl_tgt_loadlog.nextval,
           v_batch_sid,
           v_task_name,
           v_orig_record_count,
           v_dup_record_count,
           v_insert_count,
           v_updt_count,
           v_start_dt,
           v_end_dt,
           v_start_rowid,
           v_end_rowid
      FROM dual;

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

END sp_lkp_constant;
/

prompt
prompt Creating procedure SP_REFRESH_MATVIEWS
prompt ======================================
prompt
CREATE OR REPLACE PROCEDURE SP_REFRESH_MATVIEWS
AS 
    v_matviewname USER_MVIEWS.mview_name%TYPE;
BEGIN
		FOR v_matviewname IN (SELECT mview_name FROM USER_MVIEWS)
		LOOP
			DBMS_MVIEW.REFRESH(v_matviewname.mview_name);
			DBMS_OUTPUT.PUT_LINE(systimestamp || ':   ' || v_matviewname.mview_name || ' successfully refreshed');
		END LOOP;
END;
/

prompt
prompt Creating procedure SP_REFRESH_MV
prompt ================================
prompt
CREATE OR REPLACE PROCEDURE "SP_REFRESH_MV"
is
begin
        for rec in (select MVIEW_NAME from user_mview_analysis)
        loop
                dbms_mview.refresh(rec.MVIEW_NAME, 'C');
        end loop;
 end;
/

prompt
prompt Creating procedure SP_SUBSCRIBE_TABLE
prompt =====================================
prompt
CREATE OR REPLACE PROCEDURE SP_SUBSCRIBE_TABLE(p_table IN varchar2)
AS 

/*
FUNCTION Name:		fn_subscribe_table
Paramter:			none
Description:		subscribe table from master data service to master
Example:			select fn_subscribe_table
Creation Date:		2017-01-10
Author:				Shawn zhang
*/

    vStart_dt TIMESTAMP;
    vLast_dt TIMESTAMP;
    vSubscribe_table VARCHAR(30) := '';
	vTgt_table VARCHAR(30) := '';
	vTgt_pk VARCHAR(100) := '';
	vSQL VARCHAR(30000)	:= '';
	vSQL1 VARCHAR(30000)	:= '';
	vSQL2 VARCHAR(30000)	:= '';
	vSQL3 VARCHAR(30000)	:= '';
    vClient_id VARCHAR(30) := '1';
    vUser_id VARCHAR(30) := '0';
    vFt_cs_master_ds VARCHAR(30) := 'ft_cs_master_ds';
    --v_record record;
    vMessage VARCHAR(30000);
	vOrig_record_count NUMERIC(19,0) := 0;
	vInsert_count NUMERIC(19,0) := 0;
	vUpdt_count NUMERIC(19,0) := 0;
	vEnd_dt  TIMESTAMP;
	vStart_rowid NUMERIC(19,0) := null;
	vEnd_rowid NUMERIC(19,0) := null;
    vProcess_type NUMERIC(19,0) := 0;

BEGIN
vMessage := 'Start...';
vStart_dt := systimestamp;
for v_record in (select * from LKP_SUBSCRIBE_TABLE where lower(subscribe_table) like p_table|| '%' order by subscribe_table_id)
loop

  vMessage := 'Start Loop';
  vSubscribe_table := v_record.subscribe_table;
  vTgt_table :=  v_record.tgt_table;
  vProcess_type := v_record.process_type;

  if vProcess_type = 2 or vProcess_type = 4 or vProcess_type = 5 then
		vTgt_pk := v_record.tgt_logic_pk1;
  else
		vTgt_pk := v_record.tgt_physical_pk;
  end if;

  select max(start_dt) into vLast_dt from ETL_DM_LOADLOG where process_nm = vTgt_table;
  vMessage := 'Will Subscribe';

  if vLast_dt is null THEN
    if vTgt_table = 'INDUSTRY' then
			vSQL := 'select max(update_time) from ' || vTgt_table || ' where client_id = '|| vClient_id;
    elsif lower(vTgt_table) = 'compy_creditrating_info' then 
			vSQL := 'select max(updt_dt) from ' || vTgt_table ;
    elsif v_record.tgt_field_list not like '%src_cd%' then 
			vSQL := 'select max(updt_dt) from ' || vTgt_table || ' where client_id = '|| vClient_id;
	  else 
			vSQL := 'select max(updt_dt) from ' || vTgt_table || ' where src_cd = ''CSCS''';
    end if;

    vMessage := vSQL;
    execute immediate  vSQL into vLast_dt;
    if vLast_dt is null THEN
       vLast_dt := '1900-01-01';
    END IF;
  end if;

  vSQL1 := replace(replace(replace(v_record.tgt_field_list, 'client_id', vClient_id), 'updt_by', vUser_id),'mitigation_value','null');

  if vTgt_table = 'INDUSTRY' then
		vSQL2 := ' where update_time >= ''' || vLast_dt || '''';
  else
		vSQL2 := ' where updt_dt >= ''' || vLast_dt || '''';
  end if;
  --get Orig_record_count
  vSQL := 'select count(*) from ' || vFt_cs_master_ds || '.' || vSubscribe_table || vSQL2;
  vMessage := vSQL;
  execute immediate  vSQL into vOrig_record_count;

  --get vUpdt_count
  vSQL := 'select count(*) from ' || vTgt_table || ' where ' || vTgt_pk || ' in ' ||
  '(select ' || vTgt_pk || ' from ' || vFt_cs_master_ds || '.' || vSubscribe_table || vSQL2 || ')';  
  vMessage := vSQL;
  execute immediate  vSQL into vUpdt_count;

  --keep existed records
  vSQL := 'create table tmp_deleted_pk as select ' || v_record.tgt_physical_pk || ' as pk, ' || v_record.tgt_logic_pk1 || ' as lpk '
  || ' from ' || vTgt_table || ' where ' || vTgt_pk || ' in ' ||
  '(select ' || vTgt_pk || ' from ' || vFt_cs_master_ds || '.' || vSubscribe_table || vSQL2 || ')';  
  vMessage := vSQL; 
  --return vMessage; 
  execute immediate  vSQL;


  --ɾ�����ڼ�¼
  --vSQL := ' delete from ' || vTgt_table || ' where ' || vTgt_pk || ' in ' ||
  --'(select ' || vTgt_pk || ' from ' || vFt_cs_master_ds || '.' || vSubscribe_table || vSQL2 || ')';
  --vMessage := vSQL;
  --execute vSQL;

  --�����µļ�¼
  if vProcess_type = 2 or vProcess_type = 4  then

		vSQL := ' delete from ' || vTgt_table || ' where ' || vTgt_pk || ' in ' ||
	 '(select lpk from tmp_deleted_pk) ';
    vMessage := vSQL;  
    execute immediate  vSQL;

		 vSQL := ' insert into ' || vTgt_table 
    || ' select ' || vSQL1 || ' from ' || vFt_cs_master_ds || '.' || vSubscribe_table 
	  || ' a inner join tmp_deleted_pk b '
	  || ' on '|| v_record.tgt_logic_pk1 || ' = b.lpk'
	  || vSQL2;
     vMessage := vSQL; 
     execute immediate  vSQL;

    --execute ' select replace('''||vSQL||''', ''' || v_record.tgt_physical_pk || ','','''')' ;
    vSQL3 := replace(v_record.tgt_field_list, lower(v_record.tgt_physical_pk)||',', '');
    vSQL1 := replace(vSQL1, lower(v_record.tgt_physical_pk)||',', '');

		if lower(vSQL1) like '%srcid%' then
			vSQL :=  'select replace('''||vSQL1||''', ''srcid'', '|| ''''|| v_record.tgt_physical_pk ||''')';
			vMessage := vSQL;
			execute immediate  vSQL into vSQL1;
		end if; 

   	--vSQL := ' insert into ' || vTgt_table || '('|| v_record.tgt_field_list || ')'||
    vSQL := ' insert into ' || vTgt_table || '('|| vSQL3 || ')'||
    ' select ' || vSQL1 || ' from ' || vFt_cs_master_ds || '.' || vSubscribe_table 
	  || ' a left join tmp_deleted_pk b '
	  || ' on '|| v_record.tgt_logic_pk1 || ' = b.lpk'
	  || vSQL2 || ' and b.pk is null';

    vMessage := vSQL;
    execute immediate  vSQL;

  else

		vSQL := ' delete from ' || vTgt_table || ' where ' || vTgt_pk || ' in ' ||
    '(select ' || vTgt_pk || ' from ' || vFt_cs_master_ds || '.' || vSubscribe_table || vSQL2 || ')';
    vMessage := vSQL;
    execute immediate  vSQL;

		if lower(vSQL1) like '%srcid%' then
			vSQL :=  'select replace('''||vSQL1||''', ''srcid'', '|| ''''|| v_record.tgt_physical_pk ||''')';
			vMessage := vSQL;
			execute immediate  vSQL into vSQL1;
		end if; 

		 vSQL := ' insert into ' || vTgt_table || 
    ' select ' || vSQL1 || ' from ' || vFt_cs_master_ds || '.' || vSubscribe_table || vSQL2;
    vMessage := vSQL;
    execute immediate  vSQL;

  end if;

  --Get insert count
  vInsert_count := vOrig_record_count - vUpdt_count;
  vSQL := 'drop table tmp_deleted_pk';
  EXECUTE IMMEDIATE vSQL;

  --insert log
  vSQL := ' insert into etl_dm_loadlog
	(process_nm, orig_record_count, dup_record_count, insert_count, updt_count, start_dt, end_dt, start_rowid, end_rowid)
	select ''' || vTgt_table || ''','|| vOrig_record_count||', 0, '|| vInsert_count||', '|| vUpdt_count||', '''||vStart_dt ||''', '''|| systimestamp ||''', null, null';
  vMessage := vSQL;
  execute immediate  vSQL;
end loop;
--vMessage := 'Success!';
DBMS_OUTPUT.PUT_LINE( 'Success!' );

EXCEPTION
	WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE( vMessage);
END;
/

prompt
prompt Creating procedure SP_WARNINGS_BONDMARKET
prompt =========================================
prompt
CREATE OR REPLACE PROCEDURE SP_WARNINGS_BONDMARKET IS
  /*
  �洢���̣�SP_WARNINGS_BONDMARKET
  ��    �ܣ�����-ծȯ��ֵ-�����ʱ䶯
  �� �� �ˣ�RAYLEE
  ����ʱ�䣺2017/11/28 13:40:55
  Դ    ��BOND_VALUATIONS
  �� �� ��
  Ŀ �� ��COMPY_WARNINGS
  ��    ע����ҵ����ծȯ��ծ��ֵ�����ʴ������������ǰһ�������չ�ֵx%������
            1. ��ֵ���� vs ��ֵ������ �� ���� 
            ��ҵ����ծȯ���������ʳ��ִ�������������ʸ���ǰһ����Ч������x%�����ϣ�
            2. ���������� vs ���������ʣ�ǰһ����Ч������������
            ��ҵ���콻����������ǰһ�����չ�ֵ������֮����xxBP-xxBP����
            3. ����������vs ��ֵ������: ���������� �� ǰһ��Ĺ�ֵ������
  --------------------------------------------------------------------
  �� �� �ˣ�RayLee
  �޸�ʱ�䣺2017-12-21 18:05:09
  �޸����ݣ�����������ֶη����˱仯��ͬ���޸��ֶ�
            WARNING_REGULATION_DETAIL �� COLUMN_NM �� CAL_KEY
            WARNING_REGULATION_DETAIL �� SYMBOL �� CAL_SIGN
            WARNING_REGULATION_DETAIL �� VALUE �� THRESHOLD
  �� �� �ˣ�RayLee
  �޸�ʱ�䣺2018-01-11 14:28:31.399000
  �޸����ݣ������������ݻ�ȡ��һ�������յ�����������߼�©��
  */

  V_ERROR_CD          VARCHAR2(100);
  V_ERROR_MESSAGE     VARCHAR2(1000);
  V_TASK_NAME         ETL_TGT_LOADLOG.PROCESS_NM%TYPE; --��������
  V_UPDT_DT           ETL_TGT_LOADLOG.END_DT%TYPE := SYSDATE; --�ϴ�ͬ������ʱ��
  V_START_DT          ETL_TGT_LOADLOG.START_DT%TYPE; --��ʼʱ��
  V_END_DT            ETL_TGT_LOADLOG.END_DT%TYPE; --����ʱ��
  V_START_ROWID       ETL_TGT_LOADLOG.START_ROWID%TYPE; --��ʼ�к�
  V_END_ROWID         ETL_TGT_LOADLOG.END_ROWID%TYPE; --��ֹ�к�
  V_INSERT_COUNT      ETL_TGT_LOADLOG.INSERT_COUNT%TYPE; --�����¼��
  V_UPDT_COUNT        ETL_TGT_LOADLOG.UPDT_COUNT%TYPE; --���¼�¼��
  V_ORIG_RECORD_COUNT NUMBER(16); --ԭʼ�ļ�¼��
  V_DUP_RECORD_COUNT  NUMBER(16); --�ظ��ļ�¼��

  --------------------------------����ͨ�õĳ���--------------------------------------
  --������
  V_UPDT_BY COMPY_WARNINGS.UPDT_BY%TYPE := 0;
  --�Ƿ�ɾ��
  V_ISDEL COMPY_WARNINGS.ISDEL%TYPE := 0;
  --Դϵͳ
  V_SRC_CD COMPY_WARNINGS.SRC_CD%TYPE := 'CSCS';
  --����״̬ (0-δ���� 1 -�Ѵ��� LKP_CONSTANT WHERE CONSTANT_TYPE=101)
  V_STATUS_FLAG COMPY_WARNINGS.STATUS_FLAG%TYPE := 0;
  --������ (1 ���棻-1���� )
  V_WARNING_TYPE COMPY_WARNINGS.WARNING_TYPE%TYPE := '-1';
  --�źŷ���  SELECT ID FROM COMPY_EVENT_TYPE
  --V_TYPE_ID COMPY_WARNINGS.TYPE_ID%TYPE := '2';
  
  V_OBJECT_NAME USER_TABLES.TABLE_NAME%TYPE;
  
  --0-��ҵ��1-ծȯ
  V_SUBJECT_TYPE COMPY_WARNINGS.SUBJECT_TYPE%TYPE := '0';

  V_EXEC_STEP VARCHAR2(100);
BEGIN

  --��������
  V_TASK_NAME := 'SP_WARNINGS_BONDMARKET';

  --��ʼʱ��
  V_START_DT := SYSDATE;

  --��ȡ�ϴ�ͬ�����ݵ�ʱ��,����ǵ�һ������û�м�¼�ᷢ��NO_DATA_FOUND�쳣
  V_EXEC_STEP := 'STEP0 ��ȡ�ϴ�ͬ��ʱ��';
  BEGIN
    SELECT NVL(MAX(END_DT), TO_DATE('1900-1-1', 'yyyy-mm-dd'))
      INTO V_UPDT_DT
      FROM ETL_TGT_LOADLOG
     WHERE PROCESS_NM = V_TASK_NAME;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      V_UPDT_DT := TO_DATE('1900-1-1', 'yyyy-mm-dd');
  END;

  V_EXEC_STEP := 'STEP1 �����������ñ�';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE TEMP_WARNING_REGULATION_DETAIL';
  INSERT INTO TEMP_WARNING_REGULATION_DETAIL
    (REGULATION_NM,
     REGULATION_TYPE,
     COLUMN_NM,
     WARNING_SCORE,
     L_SCORE,
     L_EQUAL_SCORE,
     G_SCORE,
     G_EQUAL_SCORE,
     FLAG)
    SELECT REGULATION_NM,
           REGULATION_TYPE,
           COLUMN_NM,
           WARNING_SCORE,
           "'<'_SCORE" AS L_SCORE,
           "'<='_SCORE" AS L_EQUAL_SCORE,
           "'>'_SCORE" AS G_SCORE,
           "'>='_SCORE" AS G_EQUAL_SCORE,
           CASE
             WHEN "'<'_SCORE" IS NOT NULL THEN
              1
             WHEN "'<='_SCORE" IS NOT NULL THEN
              2
             ELSE
              3
           END AS FLAG
      FROM (SELECT T.WARNING_REGULATION_SID,
                   T.REGULATION_NM,
                   T.REGULATION_TYPE,
                   T1.CAL_KEY AS COLUMN_NM,
                   T1.CAL_SIGN,
                   T1.THRESHOLD,
                   T.WARNING_SCORE
              FROM WARNING_REGULATION T
              LEFT JOIN WARNING_REGULATION_DETAIL T1
                ON T.WARNING_REGULATION_SID = T1.WARNING_REGULATION_SID
             WHERE T.REGULATION_TYPE = '�г�����')
    PIVOT(MAX(THRESHOLD) AS SCORE
       FOR CAL_SIGN IN('<', '<=', '>', '>='));
  COMMIT;
  
  EXECUTE IMMEDIATE 'TRUNCATE TABLE TEMP_BOND_VALUATIONS_CURR';
  INSERT INTO TEMP_BOND_VALUATIONS_CURR
  (BOND_VALUATIONS_SID,
   SECINNER_ID,
   TRADE_DT,
   VALUE,
   TYPE,
   SRC_CD,
   TRADE_DT_PRE)
  SELECT BOND_VALUATIONS_SID,
         SECINNER_ID,
         TRADE_DT,
         CLOSE_YTM,
         TYPE,
         SRC_CD,
         TRADE_DT_PRE
    FROM (SELECT BOND_VALUATIONS_SID,
                 SECINNER_ID,
                 TRADE_DT,
                 CLOSE_YTM,
                 TYPE,
                 SRC_CD,
                 UPDT_DT,
                 MIN(TRADE_DT) OVER(PARTITION BY SECINNER_ID ORDER BY TRADE_DT ROWS BETWEEN 1 PRECEDING AND CURRENT ROW) AS TRADE_DT_PRE
            FROM (SELECT BOND_VALUATIONS_SID,
                         SECINNER_ID,
                         TRADE_DT,
                         CLOSE_YTM,
                         SRC_CD,
                         TYPE,
                         UPDT_DT,
                         ROW_NUMBER() OVER(PARTITION BY SECINNER_ID, TRADE_DT ORDER BY TYPE ASC) AS RNK
                    FROM (SELECT T.BOND_DAILYTRADE_SID AS BOND_VALUATIONS_SID,
                                 T.SECINNER_ID,
                                 T.TRADE_DT,
                                 NVL(T.CLOSE_YTM, 0) AS CLOSE_YTM,
                                 T.TOTAL_VOL,
                                 T.ISDEL,
                                 T.SRC_CD,
                                 T.UPDT_DT,
                                 1 AS TYPE
                            FROM BOND_DAILYTRADE T
                           WHERE T.ISDEL = 0
                             AND T.TOTAL_VOL > 0
                             AND NVL(T.CLOSE_YTM, 0) <> 0
                          UNION ALL
                          SELECT T.BOND_DANALYSIS_SID AS BOND_VALUATIONS_SID,
                                 T.SECINNER_ID,
                                 T.TRADE_DT,
                                 NVL(T.CLOSE_YTM, 0) AS CLOSE_YTM,
                                 T.TOTAL_VOL,
                                 T.ISDEL,
                                 T.SRC_CD,
                                 T.UPDT_DT,
                                 2 AS TYPE
                            FROM BOND_DANALYSIS T
                           WHERE T.ISDEL = 0
                             AND T.TOTAL_VOL > 0
                             AND NVL(T.CLOSE_YTM, 0) <> 0))
           WHERE RNK = 1)
   WHERE UPDT_DT >= V_UPDT_DT
  UNION ALL
  SELECT BOND_VALUATIONS_SID,
         SECINNER_ID,
         TRADE_DT,
         VAL_YTM,
         TYPE,
         SRC_CD,
         TRADE_DT_PRE
  FROM (
  SELECT
   BOND_VALUATIONS_SID,
   SECINNER_ID,
   TRADE_DT,
   VAL_YTM,
   TYPE,
   SRC_CD,
   UPDT_DT,
   MIN(TRADE_DT) OVER(PARTITION BY SECINNER_ID ORDER BY TRADE_DT ROWS BETWEEN 1 PRECEDING AND CURRENT ROW) AS TRADE_DT_PRE
    FROM (SELECT T.BOND_VALUATIONS_SID,
                 T.SECINNER_ID,
                 T.TRADE_DT,
                 T.VAL_YTM,
                 SRC_CD,
                 3 AS TYPE,
                 T.IS_CALCULATEOPTION,
                 T.UPDT_DT,
                 ROW_NUMBER() OVER(PARTITION BY T.SECINNER_ID, T.TRADE_DT, T.SRC_CD ORDER BY  
           CASE WHEN T.IS_CALCULATEOPTION = '�Ƽ�' THEN 1 ELSE 0 END DESC) AS RNK
            FROM BOND_VALUATIONS T)
   WHERE RNK = 1)
    WHERE  UPDT_DT >= V_UPDT_DT;
  COMMIT;
  
  
  EXECUTE IMMEDIATE 'TRUNCATE TABLE TEMP_BOND_VALUATIONS_INDEX';
   INSERT INTO TEMP_BOND_VALUATIONS_INDEX
    (BOND_VALUATIONS_SID,
     SECINNER_ID,
     TRADE_DT,
     VALUE_CURR,
     TYPE,
     SRC_CD,
     TRADE_DT_PRE,
     VALUE_PRE,
     INDEX_VALUE,
     FLAG,
     KEY)
  SELECT T.BOND_VALUATIONS_SID,
         T.SECINNER_ID,
         T.TRADE_DT,
         T.VALUE AS VALUE_CURR,
         T.TYPE,
         T.SRC_CD,
         T.TRADE_DT_PRE,
         T1.VAL_YTM AS VALUE_PRE,
         (T.VALUE - T1.VAL_YTM) * 100 AS INDEX_VALUE,
         ROW_NUMBER()OVER(PARTITION BY T.SECINNER_ID, T.TRADE_DT, T1.TRADE_DT ORDER BY 
         CASE WHEN T1.IS_CALCULATEOPTION = '�Ƽ�' THEN 1 ELSE 0 END DESC) AS FLAG,
         'DIFF' AS KEY
    FROM TEMP_BOND_VALUATIONS_CURR T
    LEFT JOIN BOND_VALUATIONS T1
      ON T1.SECINNER_ID = T.SECINNER_ID
     AND T1.TRADE_DT = T.TRADE_DT_PRE
     AND T1.ISDEL = 0
   WHERE T.TYPE IN (1, 2)
     AND NVL(T1.VAL_YTM, 0) <> 0
     AND T.TRADE_DT <> T.TRADE_DT_PRE
  UNION ALL
  SELECT T.BOND_VALUATIONS_SID,
         T.SECINNER_ID,
         T.TRADE_DT,
         T.VALUE AS VALUE_CURR,
         T.TYPE,
         T.SRC_CD,
         T.TRADE_DT_PRE,
         COALESCE(T2.CLOSE_YTM, T3.CLOSE_YTM) AS VALUE_PRE,
         (T.VALUE - COALESCE(T2.CLOSE_YTM, T3.CLOSE_YTM)) /
         COALESCE(T2.CLOSE_YTM, T3.CLOSE_YTM) AS INDEX_VALUE,
         1 AS FLAG,
         'CLOSE_YTM_INCRE_RATE' AS KEY
    FROM TEMP_BOND_VALUATIONS_CURR T
    LEFT JOIN BOND_DAILYTRADE T2
      ON T2.SECINNER_ID = T.SECINNER_ID
     AND T2.TRADE_DT = T.TRADE_DT_PRE
     AND T2.TOTAL_VOL > 0
     AND T2.ISDEL = 0
    LEFT JOIN BOND_DANALYSIS T3
      ON T3.SECINNER_ID = T.SECINNER_ID
     AND T3.TRADE_DT = T.TRADE_DT_PRE
     AND T3.TOTAL_VOL > 0
     AND T3.ISDEL = 0
   WHERE T.TYPE IN (1, 2)
    AND T.TRADE_DT <> T.TRADE_DT_PRE
   UNION ALL
   SELECT T.BOND_VALUATIONS_SID,
         T.SECINNER_ID,
         T.TRADE_DT,
         T.VALUE AS VALUE_CURR,
         T.TYPE,
         T.SRC_CD,
         T.TRADE_DT_PRE,
          T4.VAL_YTM AS VALUE_PRE, (T.VALUE - T4.VAL_YTM)/T4.VAL_YTM AS INDEX_VALUE,
          ROW_NUMBER()OVER(PARTITION BY T.SECINNER_ID, T.TRADE_DT, T4.TRADE_DT ORDER BY 
         CASE WHEN T4.IS_CALCULATEOPTION = '�Ƽ�' THEN 1 ELSE 0 END DESC) AS FLAG,
           'VAL_YTM_INCRE_RATE' AS KEY
     FROM TEMP_BOND_VALUATIONS_CURR T
     LEFT JOIN BOND_VALUATIONS T4
       ON T4.SECINNER_ID = T.SECINNER_ID
      AND T4.TRADE_DT = T.TRADE_DT_PRE
      AND T4.ISDEL = 0
    WHERE T.TYPE = 3
      AND NVL(T4.VAL_YTM,0) <> 0
      AND T.TRADE_DT <> T.TRADE_DT_PRE;
    COMMIT;
    
    EXECUTE IMMEDIATE 'TRUNCATE TABLE TEMP_BOND_VALUATIONS_RET';
    INSERT INTO TEMP_BOND_VALUATIONS_RET
    (COMPY_WARNINGS_SID,
     COMPANY_ID,
     SECINNER_ID,
     NOTICE_DT,
     SCORE,
     SRC_CD,
     WARNING_CONTENT)
    SELECT T.BOND_VALUATIONS_SID,
           A.COMPANY_ID,
           T.SECINNER_ID,
           T.TRADE_DT,
           COALESCE(T1.WARNING_SCORE,
                    T2.WARNING_SCORE,
                    T3.WARNING_SCORE,
                    T4.WARNING_SCORE,
                    T5.WARNING_SCORE,
                    T6.WARNING_SCORE,
                    0) AS SCORE,
           T.SRC_CD,
           CASE
             WHEN KEY = 'DIFF' THEN
              '�м�֤ȯ����: ' || T7.SECURITY_CD || T9.MARKET_ABBR ||
              '�г����ս����չ�ֵ�����ʲ���' || T.INDEX_VALUE || 'BP'
             WHEN KEY = 'VAL_YTM_INCRE_RATE' THEN
              '�м�֤ȯ����: ' || T7.SECURITY_CD || T9.MARKET_ABBR ||
              '��ծ��ֵ��ֵ�����ʽ���һ�����ձ䶯' || ROUND(T.INDEX_VALUE * 100, 2) || '%'
             WHEN KEY = 'CLOSE_YTM_INCRE_RATE' THEN
              '�м�֤ȯ����: ' || T7.SECURITY_CD || T9.MARKET_ABBR ||
              '��ծ��ֵ���������ʽ���һ�����ձ䶯' || ROUND(T.INDEX_VALUE * 100, 2) || '%'
             ELSE
              NULL
           END AS WARNING_CONTENT
      FROM TEMP_BOND_VALUATIONS_INDEX T
      LEFT JOIN COMPY_SECURITY_XW A
        ON A.SECINNER_ID = T.SECINNER_ID
      LEFT JOIN TEMP_WARNING_REGULATION_DETAIL T1
        ON T1.FLAG = 1
       AND T1.COLUMN_NM = 'DIFF'
       AND T1.L_SCORE > T.INDEX_VALUE
       AND T1.G_EQUAL_SCORE <= T.INDEX_VALUE
       AND T1.COLUMN_NM = T.KEY
      LEFT JOIN TEMP_WARNING_REGULATION_DETAIL T2
        ON T2.FLAG = 2
       AND T2.L_EQUAL_SCORE >= T.INDEX_VALUE
       AND T1.G_SCORE < T.INDEX_VALUE
       AND T2.COLUMN_NM = 'DIFF'
       AND T2.COLUMN_NM = T.KEY
      LEFT JOIN TEMP_WARNING_REGULATION_DETAIL T3
        ON T3.FLAG = 1
       AND T3.COLUMN_NM = 'VAL_YTM_INCRE_RATE'
       AND T3.L_SCORE > T.INDEX_VALUE
       AND T3.G_EQUAL_SCORE <= T.INDEX_VALUE
       AND T3.COLUMN_NM = T.KEY
      LEFT JOIN TEMP_WARNING_REGULATION_DETAIL T4
        ON T4.FLAG = 2
       AND T4.L_EQUAL_SCORE >= T.INDEX_VALUE
       AND T4.G_SCORE < T.INDEX_VALUE
       AND T4.COLUMN_NM = 'VAL_YTM_INCRE_RATE'
       AND T4.COLUMN_NM = T.KEY
      LEFT JOIN TEMP_WARNING_REGULATION_DETAIL T5
        ON T5.FLAG = 1
       AND T5.COLUMN_NM = 'CLOSE_YTM_INCRE_RATE'
       AND T5.L_SCORE > T.INDEX_VALUE
       AND T5.G_EQUAL_SCORE <= T.INDEX_VALUE
       AND T5.COLUMN_NM = T.KEY
      LEFT JOIN TEMP_WARNING_REGULATION_DETAIL T6
        ON T6.FLAG = 2
       AND T6.L_EQUAL_SCORE >= T.INDEX_VALUE
       AND T6.G_SCORE < T.INDEX_VALUE
       AND T6.COLUMN_NM = 'CLOSE_YTM_INCRE_RATE'
       AND T6.COLUMN_NM = T.KEY
      LEFT JOIN BOND_BASICINFO T7
        ON T7.SECINNER_ID = T.SECINNER_ID
      LEFT JOIN LKP_CHARCODE T8
        ON T7.TRADE_MARKET_ID = T8.CONSTANT_ID
       AND T8.CONSTANT_TYPE = 206
      LEFT JOIN LKP_MARKET_ABBR T9
        ON T9.MARKET_CD = T8.CONSTANT_CD
     WHERE A.COMPANY_ID IS NOT NULL;
    COMMIT;

    V_EXEC_STEP := 'STEP7 ��ȡ��Ч����'; 
    EXECUTE IMMEDIATE 'TRUNCATE TABLE TEMP_BOND_VALUATIONS_MID';
    INSERT INTO TEMP_BOND_VALUATIONS_MID
      (COMPANY_ID, SECINNER_ID, NOTICE_DT, SCORE, SRC_CD, WARNING_CONTENT)
      SELECT COMPANY_ID,
         MAX(RNK_SECINNER_ID) AS SECINNER_ID,
         NOTICE_DT,
         MAX(SCORE),
         SRC_CD,
         WM_CONCAT(WARNING_CONTENT)
    FROM (SELECT COMPANY_ID,
                 SECINNER_ID,
                 NOTICE_DT,
                 SCORE,
                 SRC_CD,
                 WARNING_CONTENT,
                 RNK,
                 MAX(CASE
                       WHEN RNK = 1 THEN
                        SECINNER_ID
                       ELSE
                        NULL
                     END) OVER(PARTITION BY COMPANY_ID, NOTICE_DT) AS RNK_SECINNER_ID
            FROM (SELECT T.COMPANY_ID,
                         T.SECINNER_ID,
                         T.NOTICE_DT,
                         T.SCORE,
                         T.SRC_CD,
                         T.WARNING_CONTENT,
                         ROW_NUMBER() OVER(PARTITION BY T.COMPANY_ID, T.NOTICE_DT ORDER BY T.SECINNER_ID, T.SCORE) AS RNK
                    FROM TEMP_BOND_VALUATIONS_RET T
                   WHERE T.SCORE <> 0))
   WHERE RNK < 100
   GROUP BY COMPANY_ID, NOTICE_DT, SRC_CD;
    COMMIT; 

  --Ԥ���������ϴ���
  V_EXEC_STEP := 'STEP10 ����Ŀ���';
    INSERT INTO TMP_COMPY_WARNINGS
      (--COMPY_WARNINGS_SID, --1. ��ˮ��
       --COMPANY_ID, --2. Ԥ���������
       NOTICE_DT, --3. Ԥ���ź�ʱ��
       WARNING_TYPE, --4. ������
       SEVERITY, --5. ���س̶�
       WARNING_SCORE, --6. �źŷ�ֵ
       WARNING_TITLE, --7. Ԥ������
       TYPE_ID, --8. �źŷ���
       STATUS_FLAG, --9. ����״̬
       WARNING_RESULT_CD, --10.  ��������
       ADJUST_SEVERITY, --11.  ���������س̶�
       ADJUST_SCORE, --12.  ������÷�
       REMARK, --13.  ��ע
       PROCESS_BY, --14.  ������
       PROCESS_DT, --15.  ����ʱ��
       ISDEL, --16.  �Ƿ�ɾ��
       UPDT_BY, --17.  ������
       SRC_CD, --18.  Դϵͳ
       UPDT_DT, --19.  ����ʱ��
       SUBJECT_ID,   -- A1. Ԥ���������
       SUBJECT_TYPE,  -- A2. Ԥ����������
       WARNING_CONTENT
       )
  SELECT --COMPY_WARNINGS_SID, --1. ��ˮ��
                     --T.COMPANY_ID AS COMPANY_ID, --2. Ԥ���������
                     T.NOTICE_DT AS NOTICE_DT, --3. Ԥ���ź�ʱ��
                     V_WARNING_TYPE AS WARNING_TYPE, --4. ������
                     T2.IMPORTANCE AS SEVERITY, --5. ���س̶�
                     T.SCORE AS WARNING_SCORE, --6. �źŷ�ֵ
                     T4.COMPANY_NM || ' ' || T5.SECURITY_NM ||'�����ʴ��������' AS WARNING_TITLE, --7. Ԥ������
                     T3.ID AS TYPE_ID, --8. �źŷ���
                     V_STATUS_FLAG AS STATUS_FLAG, --9. ����״̬
                     NULL AS WARNING_RESULT_CD, --10.  ��������
                     NULL AS ADJUST_SEVERITY, --11.  ���������س̶�
                     NULL AS ADJUST_SCORE, --12.  ������÷�
                     NULL AS REMARK, --13.  ��ע
                     NULL AS PROCESS_BY, --14.  ������
                     NULL AS PROCESS_DT, --15.  ����ʱ��
                     V_ISDEL AS ISDEL, --16.  �Ƿ�ɾ��
                     V_UPDT_BY AS UPDT_BY, --17.  ������
                     T.SRC_CD AS SRC_CD, --18.  Դϵͳ
                     SYSDATE AS UPDT_DT, --19.  ����ʱ��
                     T.COMPANY_ID AS SUBJECT_ID, --A1. Ԥ���������
                     V_SUBJECT_TYPE AS SUBJECT_TYPE, --A2. Ԥ����������
                     T.WARNING_CONTENT AS WARNING_CONTENT 
                FROM TEMP_BOND_VALUATIONS_MID T
                LEFT JOIN LKP_WARNING_SCORE T2
                  ON T2.ISDEL = 0
                 AND T2.MIN_VAL <= T.SCORE
                 AND T2.MAX_VAL > T.SCORE
                LEFT JOIN COMPY_EVENT_TYPE T3
                  ON T3.TYPE_NAME = '�г�����'
                LEFT JOIN COMPY_BASICINFO T4
                  ON T4.COMPANY_ID = T.COMPANY_ID
                LEFT JOIN BOND_BASICINFO T5
                  ON T5.SECINNER_ID = T.SECINNER_ID;

  V_INSERT_COUNT := SQL%ROWCOUNT;
  COMMIT;
  --����ʱ��
  V_END_DT := SYSDATE;

  --�������ݵ�LOG����
  V_EXEC_STEP := 'STEP2 �������ݵ�LOG����';
  INSERT INTO ETL_TGT_LOADLOG
    (LOADLOG_SID,
     BATCH_SID,
     PROCESS_NM,
     ORIG_RECORD_COUNT,
     DUP_RECORD_COUNT,
     INSERT_COUNT,
     UPDT_COUNT,
     START_DT,
     END_DT,
     START_ROWID,
     END_ROWID)
  VALUES
    (SEQ_ETL_TGT_LOADLOG.NEXTVAL,
     0,
     V_TASK_NAME,
     V_ORIG_RECORD_COUNT,
     V_DUP_RECORD_COUNT,
     V_INSERT_COUNT,
     NVL(V_UPDT_COUNT, 0),
     V_START_DT,
     V_END_DT,
     V_START_ROWID,
     V_END_ROWID);
  COMMIT;

  --������
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    V_ERROR_CD      := SQLCODE;
    V_ERROR_MESSAGE := V_EXEC_STEP || SUBSTR(SQLERRM, 1, 900);
    DBMS_OUTPUT.PUT_LINE('failed! ERROR:' || V_ERROR_CD || ' ,' ||
                         V_ERROR_MESSAGE);
    RAISE_APPLICATION_ERROR(-20021, V_ERROR_MESSAGE);
    RETURN;
  
    COMMIT;
  
END SP_WARNINGS_BONDMARKET;
/

prompt
prompt Creating procedure SP_WARNINGS_CAIHUI
prompt =====================================
prompt
CREATE OR REPLACE PROCEDURE sp_warnings_caihui IS
  /*************************************
  �洢���̣�sp_warnings_caihui
  ����ʱ�䣺2017/11/28
  �� �� �ˣ�ZhangCong
  Դ    ��STG_T_NEWS_TEXT_FCDB(���������°渺��))
  Ŀ �� ��TMP_COMPY_WARNINGS(��ҵԤ���ź���ʱ��)
  ��    �ܣ�ÿ15����ˢ��ʵʱ�ƻ����ŷ���
  
  ************************************/

  --------------------------------������־����--------------------------------------
  v_error_cd          VARCHAR2(100);
  v_error_message     VARCHAR2(1000);
  v_task_name         etl_tgt_loadlog.process_nm%TYPE; --��������
  v_updt_dt           etl_tgt_loadlog.end_dt%TYPE; --�ϴ�ͬ������ʱ��
  v_start_dt          etl_tgt_loadlog.start_dt%TYPE; --��ʼʱ��
  v_end_dt            etl_tgt_loadlog.end_dt%TYPE; --����ʱ��
  v_start_rowid       etl_tgt_loadlog.start_rowid%TYPE; --��ʼ�к�
  v_end_rowid         etl_tgt_loadlog.end_rowid%TYPE; --��ֹ�к�
  v_insert_count      etl_tgt_loadlog.insert_count%TYPE; --�����¼��
  v_updt_count        etl_tgt_loadlog.updt_count%TYPE; --���¼�¼��
  v_orig_record_count etl_tgt_loadlog.orig_record_count%TYPE; --ԭʼ�ļ�¼��
  v_dup_record_count  etl_tgt_loadlog.dup_record_count%TYPE; --�ظ��ļ�¼��
  v_batch_sid         etl_tgt_loadlog.batch_sid%TYPE := 0; --���κ�

  --------------------------------����ҵ�����-------------------------------------
  v_warn_updt_by tmp_compy_warnings.updt_by%TYPE := 0; --������
  v_warn_updt_dt tmp_compy_warnings.updt_dt%TYPE := systimestamp; --����ʱ��
  v_isdel        tmp_compy_warnings.isdel%TYPE := 0; --�Ƿ�ɾ��
  v_status_flag  tmp_compy_warnings.status_flag%TYPE := 0; --����״̬ (0-δ���� 1 -�Ѵ��� LKP_CONSTANT WHERE CONSTANT_TYPE=101)
  v_warning_type tmp_compy_warnings.warning_type%TYPE := '-1'; --������ (1 ����; -1����)
  v_subject_type tmp_compy_warnings.subject_type%TYPE := 0; --Ԥ����������(0-��ҵ��1-ծȯ)
  v_news_link    VARCHAR2(200);

BEGIN

  --��������
  v_task_name := 'SP_WARNINGS_CAIHUI';

  --��ȡ�ϴ�ͬ�����ݵ�ʱ��
  SELECT nvl(MAX(end_dt), to_date('1900-1-1', 'yyyy-mm-dd'))
    INTO v_updt_dt
    FROM etl_tgt_loadlog
   WHERE process_nm = v_task_name;

  --������ʼ��
  v_start_dt  := SYSDATE;
  v_news_link := 'http://114.80.136.31/newsview/default.aspx?newscode=';

  --��ȡ��ʼ��¼��
  SELECT /*+ leading(news,nsm,cmp,bsf) */
   COUNT(*)
    INTO v_orig_record_count
    FROM cs_master_stg.t_news_text_fcdb news
    JOIN cs_master_stg.t_news_company_fcdb nsm
      ON (news.newscode = nsm.newscode)
    JOIN cs_master_stg.tq_comp_info cmp
      ON (nsm.compcode = cmp.compcode)
    JOIN compy_basicinfo bsf
      ON (cmp.compname = bsf.company_nm)
   WHERE news.isvalid = 1
     AND nsm.impscore <= 0
     AND nsm.isvalid = 1
     AND news.publishtime >= v_updt_dt;

  --���ƻ�����ݲ���Ԥ���ܱ�
  INSERT ALL INTO compy_warnings
    (compy_warnings_sid, --1.��ˮ��
     subject_id, --2. Ԥ���������
     subject_type, --Ԥ����������
     notice_dt, --3. Ԥ���ź�ʱ��
     warning_type, --4. ������
     severity, --5. ���س̶�
     warning_score, --6. �źŷ�ֵ
     warning_title, --7. Ԥ������
     type_id, --8. �źŷ���
     status_flag, --9. ����״̬
     isdel, --�Ƿ�ɾ��
     updt_by, --������
     src_cd, --Դϵͳ
     updt_dt) --����ʱ��
  VALUES
    (seq_compy_warnings.nextval, --1.��ˮ��
     subject_id, --2. Ԥ���������
     v_subject_type, --Ԥ����������
     notice_dt, --3. Ԥ���ź�ʱ��
     v_warning_type, --4. ������
     severity, --5. ���س̶�
     warning_score, --6. �źŷ�ֵ
     warning_title, --7. Ԥ������
     type_id, --8. �źŷ���
     v_status_flag, --9. ����״̬
     v_isdel, --�Ƿ�ɾ��
     v_warn_updt_by, --������
     src_cd, --Դϵͳ
     v_warn_updt_dt --����ʱ��
     ) INTO compy_warnings_content
    (compy_warnings_sid, warning_content)
  VALUES
    (seq_compy_warnings.nextval, --1.��ˮ��
     warning_content)
  
    WITH subtp AS --����CODE��ȡwarning_type
     (SELECT DISTINCT a.srcwarning_subtype_cd, b.warning_type
        FROM lkp_warningtype_xw a
        LEFT JOIN lkp_warning_type b
          ON (a.warning_subtype_cd = b.warning_subtype_cd AND b.isdel = 0)
       WHERE a.mapping_level = 2
         AND a.isdel = 0),
    tp AS --�����ȡwarning_type
     (SELECT DISTINCT a.srcwarning_type_cd, b.warning_type
        FROM lkp_warningtype_xw a
        LEFT JOIN (SELECT warning_type_cd, warning_type
                    FROM lkp_warning_type
                   WHERE isdel = 0
                   GROUP BY warning_type_cd, warning_type) b
          ON (a.warning_type_cd = b.warning_type_cd)
       WHERE a.mapping_level = 1
         AND a.isdel = 0)
    SELECT mid.company_id AS subject_id, --2. Ԥ���������
           mid.publishtime AS notice_dt, --3. Ԥ���ź�ʱ��
           scs.importance AS severity, --5. ���س̶�
           mid.warn_score AS warning_score, --6. �źŷ�ֵ
           mid.newstitle AS warning_title, --7. Ԥ������
           etp.id AS type_id, --8. �źŷ���
           v_news_link || mid.newscodehd AS warning_content, --10.Ԥ������,
           mid.src_cd --Դϵͳ
      FROM (SELECT /*+ leading(news,nsm,cmp,bsf) */
             bsf.company_id,
             bsf.company_nm,
             news.publishtime, --����ʱ��
             news.newstitle, --���ű���
             news.newscodehd, --��������code
             nsm.indexcode,
             nsm.indextype,
             CASE
               WHEN nsm.impscore = 0 THEN
                0
               WHEN nsm.impscore = -1 THEN
                2
               WHEN nsm.impscore = -2 THEN
                5
               WHEN nsm.impscore = -3 THEN
                10
               ELSE
                0
             END AS warn_score,
             'FCDB' AS src_cd,
             row_number() over(PARTITION BY bsf.company_id, trunc(news.publishtime), news.newstitle ORDER BY news.publishtime DESC) AS rn
              FROM cs_master_stg.t_news_text_fcdb news
              JOIN cs_master_stg.t_news_company_fcdb nsm
                ON (news.newscode = nsm.newscode)
              JOIN cs_master_stg.tq_comp_info cmp
                ON (nsm.compcode = cmp.compcode)
              JOIN compy_basicinfo bsf
                ON (cmp.compname = bsf.company_nm)
             WHERE news.isvalid = 1
               AND nsm.impscore IN (0, -1, -2, -3) --ȡ��������
               AND nsm.isvalid = 1
               AND news.publishtime >= v_updt_dt) mid
      LEFT JOIN subtp
        ON (mid.indexcode = subtp.srcwarning_subtype_cd)
      LEFT JOIN tp
        ON (mid.indextype = tp.srcwarning_type_cd)
      LEFT JOIN compy_event_type etp
        ON (nvl(subtp.warning_type, tp.warning_type) = etp.type_name)
      LEFT JOIN lkp_warning_score scs
        ON (mid.warn_score >= scs.min_val AND mid.warn_score < scs.max_val AND
           scs.isdel = 0)
     WHERE mid.rn = 1;

  v_insert_count := SQL%ROWCOUNT;
  v_updt_count   := 0;

  --����ʱ��
  v_end_dt := SYSDATE;

  COMMIT;

  --�������ݵ�LOG����

  INSERT INTO etl_tgt_loadlog
    (loadlog_sid,
     batch_sid,
     process_nm,
     orig_record_count,
     dup_record_count,
     insert_count,
     updt_count,
     start_dt,
     end_dt,
     start_rowid,
     end_rowid)
    SELECT seq_etl_tgt_loadlog.nextval,
           v_batch_sid,
           v_task_name,
           v_orig_record_count,
           v_dup_record_count,
           v_insert_count,
           v_updt_count,
           v_start_dt,
           v_end_dt,
           v_start_rowid,
           v_end_rowid
      FROM dual;

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
  
END sp_warnings_caihui;
/

prompt
prompt Creating procedure SP_WARNINGS_CMBPLATFORM
prompt ==========================================
prompt
CREATE OR REPLACE PROCEDURE SP_WARNINGS_CMBPLATFORM IS
  /*
  �洢���̣�SP_WARNINGS_CMBPLATFORM
  ��    �ܣ�����-Ԥ���������ϴ���-����
  �� �� �ˣ�RAYLEE
  ����ʱ�䣺2017/11/28 13:40:55
  Դ    ��COMPY_WARNING_CMB
  �� �� ��COMPY_WARNINGTYPE_CMB
            LKP_WARNING_SCORE
  Ŀ �� ��COMPY_WARNINGS
  --------------------------------------------------------------------
  �� �� �ˣ�RAYLEE
  �޸�ʱ�䣺2017/11/30 19:14:55
  �޸����ݣ��޸���ȡ�źŷ�����߼�����Ҫ�����̵��ź�����ת������֤���ź�����
            ͨ������ź����͵Ĵ��࣬�ҵ��ź����ʹ�������ƣ�ͨ���źŴ��������
            ��ȡ���źŴ����ID����Ϊ�źŷ����ID
  �� �� �ˣ�RAYLEE
  �޸�ʱ�䣺2018-01-02 17:15:54
  �޸����ݣ��޸��˵÷ֵ��߼���������÷ֲ�Ϊ��Ϊ0�����
  */

  V_ERROR_CD          VARCHAR2(100);
  V_ERROR_MESSAGE     VARCHAR2(1000);
  V_TASK_NAME         ETL_TGT_LOADLOG.PROCESS_NM%TYPE; --��������
  V_UPDT_DT           ETL_TGT_LOADLOG.END_DT%TYPE := SYSDATE; --�ϴ�ͬ������ʱ��
  V_START_DT          ETL_TGT_LOADLOG.START_DT%TYPE; --��ʼʱ��
  V_END_DT            ETL_TGT_LOADLOG.END_DT%TYPE; --����ʱ��
  V_START_ROWID       ETL_TGT_LOADLOG.START_ROWID%TYPE; --��ʼ�к�
  V_END_ROWID         ETL_TGT_LOADLOG.END_ROWID%TYPE; --��ֹ�к�
  V_INSERT_COUNT      ETL_TGT_LOADLOG.INSERT_COUNT%TYPE; --�����¼��
  V_UPDT_COUNT        ETL_TGT_LOADLOG.UPDT_COUNT%TYPE; --���¼�¼��
  V_ORIG_RECORD_COUNT NUMBER(16); --ԭʼ�ļ�¼��
  V_DUP_RECORD_COUNT  NUMBER(16); --�ظ��ļ�¼��

  --------------------------------����ͨ�õĳ���--------------------------------------
  --������
  V_UPDT_BY COMPY_WARNINGS.UPDT_BY%TYPE := 0;
  --�Ƿ�ɾ��
  V_ISDEL COMPY_WARNINGS.ISDEL%TYPE := 0;
  --Դϵͳ
  V_SRC_CD COMPY_WARNINGS.SRC_CD%TYPE := 'CSCS';
  --����״̬ (0-δ���� 1 -�Ѵ��� LKP_CONSTANT WHERE CONSTANT_TYPE=101)
  V_STATUS_FLAG COMPY_WARNINGS.STATUS_FLAG%TYPE := 0;
  --������ (1 ���棻-1���� )
  V_WARNING_TYPE COMPY_WARNINGS.WARNING_TYPE%TYPE := '-1';
  --�źŷ���  SELECT ID FROM COMPY_EVENT_TYPE
  --V_TYPE_ID COMPY_WARNINGS.TYPE_ID%TYPE := '2';

  V_SUBJECT_TYPE COMPY_WARNINGS.SUBJECT_TYPE%TYPE := '0';

  V_EXEC_STEP VARCHAR2(100);
BEGIN

  --��������
  V_TASK_NAME := 'SP_WARNINGS_CMBPLATFORM';

  --��ʼʱ��
  V_START_DT := SYSDATE;

  --��ȡ�ϴ�ͬ�����ݵ�ʱ��,����ǵ�һ������û�м�¼�ᷢ��NO_DATA_FOUND�쳣
  V_EXEC_STEP := 'STEP0 ��ȡ�ϴ�ͬ��ʱ��';
  BEGIN
    SELECT NVL(MAX(END_DT), TO_DATE('1900-1-1', 'yyyy-mm-dd'))
      INTO V_UPDT_DT
      FROM ETL_TGT_LOADLOG
     WHERE PROCESS_NM = V_TASK_NAME;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      V_UPDT_DT := TO_DATE('1900-1-1', 'yyyy-mm-dd');
  END;

  --Ԥ���������ϴ���
  V_EXEC_STEP := 'STEP1 Ԥ���������ϴ���';
  INSERT INTO TMP_COMPY_WARNINGS
    (--COMPY_WARNINGS_SID, --1. ��ˮ��
     --COMPANY_ID, --2. Ԥ���������
     NOTICE_DT, --3. Ԥ���ź�ʱ��
     WARNING_TYPE, --4. ������
     SEVERITY, --5. ���س̶�
     WARNING_SCORE, --6. �źŷ�ֵ
     WARNING_TITLE, --7. Ԥ������
     TYPE_ID, --8. �źŷ���
     STATUS_FLAG, --9. ����״̬
     WARNING_RESULT_CD, --10.  ��������
     ADJUST_SEVERITY, --11.  ���������س̶�
     ADJUST_SCORE, --12.  ������÷�
     REMARK, --13.  ��ע
     PROCESS_BY, --14.  ������
     PROCESS_DT, --15.  ����ʱ��
     ISDEL, --16.  �Ƿ�ɾ��
     UPDT_BY, --17.  ������
     SRC_CD, --18.  Դϵͳ
     UPDT_DT, --19.  ����ʱ��
     SUBJECT_ID, -- A1.Ԥ���������
     SUBJECT_TYPE, -- A2. Ԥ����������
     WARNING_CONTENT)
    SELECT --COMPY_WARNINGS_SID, --1. ��ˮ��
           --COMPANY_ID, --2. Ԥ���������
           NOTICE_DT, --3. Ԥ���ź�ʱ��
           WARNING_TYPE, --4. ������
           SEVERITY, --5. ���س̶�
           WARNING_SCORE, --6. �źŷ�ֵ
           WARNING_TITLE, --7. Ԥ������
           TYPE_ID, --8. �źŷ���
           STATUS_FLAG, --9. ����״̬
           WARNING_RESULT_CD, --10.  ��������
           ADJUST_SEVERITY, --11.  ���������س̶�
           ADJUST_SCORE, --12.  ������÷�
           REMARK, --13.  ��ע
           PROCESS_BY, --14.  ������
           PROCESS_DT, --15.  ����ʱ��
           ISDEL, --16.  �Ƿ�ɾ��
           UPDT_BY, --17.  ������
           SRC_CD, --18.  Դϵͳ
           sysdate as UPDT_DT, --19.  ����ʱ��
           COMPANY_ID AS SUBJECT_ID, -- A1.Ԥ���������
           V_SUBJECT_TYPE AS SUBJECT_TYPE, -- A2. Ԥ����������
           WARNING_CONTENT -- 20. Ԥ������
      FROM (SELECT T.WARNING_ID AS COMPY_WARNINGS_SID, --1. ��ˮ��
                   T.COMPANY_ID AS COMPANY_ID, --2. Ԥ���������
                   T.INFOSRC_DT AS NOTICE_DT, --3. Ԥ���ź�ʱ��
                   V_WARNING_TYPE AS WARNING_TYPE, --4. ������
                   T2.IMPORTANCE AS SEVERITY, --5. ���س̶�
                   NVL(T1.SCORE1,0) + NVL(T1.SCORE2,0) AS WARNING_SCORE, --6. �źŷ�ֵ
                   T1.WARNING_NM AS WARNING_TITLE, --7. Ԥ������
                   T5.ID AS TYPE_ID, --8. �źŷ���
                   V_STATUS_FLAG AS STATUS_FLAG, --9. ����״̬
                   NULL AS WARNING_RESULT_CD, --10.  ��������
                   NULL AS ADJUST_SEVERITY, --11.  ���������س̶�
                   NULL AS ADJUST_SCORE, --12.  ������÷�
                   NULL AS REMARK, --13.  ��ע
                   NULL AS PROCESS_BY, --14.  ������
                   NULL AS PROCESS_DT, --15.  ����ʱ��
                   NVL(T.ISDEL, V_ISDEL) AS ISDEL, --16.  �Ƿ�ɾ��
                   NVL(T.UPDT_BY, V_UPDT_BY) AS UPDT_BY, --17.  ������
                   NVL(T.SRC_CD, V_SRC_CD) AS SRC_CD, --18.  Դϵͳ
                   T.UPDT_DT AS UPDT_DT, --19.  ����ʱ��
                   T.WARN_CONTENT AS WARNING_CONTENT,
                   ROW_NUMBER() OVER(PARTITION BY T.WARNING_ID, T.COMPANY_ID ORDER BY T.UPDT_DT DESC) AS CNT
              FROM COMPY_WARNING_CMB T
              LEFT JOIN COMPY_WARNINGTYPE_CMB T1
                ON T1.ISDEL = 0
               AND T.WARNING_CD = T1.WARNING_CD
              LEFT JOIN LKP_WARNING_SCORE T2
                ON T2.ISDEL = 0
               AND T2.MIN_VAL <= (NVL(T1.SCORE1,0) + NVL(T1.SCORE2,0))
               AND T2.MAX_VAL > (NVL(T1.SCORE1,0) + NVL(T1.SCORE2,0))
              LEFT JOIN LKP_WARNINGTYPE_XW T3
                ON T3.MAPPING_SRC = 'CMB'
               AND T3.SRCWARNING_SUBTYPE_CD = T.WARNING_CD
               AND T3.ISDEL = 0
              LEFT JOIN LKP_WARNING_TYPE T4
                ON T4.WARNING_TYPE_CD = T3.WARNING_TYPE_CD
               AND T4.ISDEL = 0
              LEFT JOIN COMPY_EVENT_TYPE T5
                ON T5.TYPE_NAME = T4.WARNING_TYPE
             WHERE T.ISDEL = 0
               AND T.UPDT_DT > V_UPDT_DT
               AND NVL(T1.SCORE1,0) + NVL(T1.SCORE2,0) <> 0)
     WHERE CNT = 1;

  V_INSERT_COUNT := SQL%ROWCOUNT;
  COMMIT;
  --����ʱ��
  V_END_DT := SYSDATE;

  --�������ݵ�LOG����
  V_EXEC_STEP := 'STEP2 �������ݵ�LOG����';
  INSERT INTO ETL_TGT_LOADLOG
    (LOADLOG_SID,
     BATCH_SID,
     PROCESS_NM,
     ORIG_RECORD_COUNT,
     DUP_RECORD_COUNT,
     INSERT_COUNT,
     UPDT_COUNT,
     START_DT,
     END_DT,
     START_ROWID,
     END_ROWID)
  VALUES
    (SEQ_ETL_TGT_LOADLOG.NEXTVAL,
     0,
     V_TASK_NAME,
     V_ORIG_RECORD_COUNT,
     V_DUP_RECORD_COUNT,
     V_INSERT_COUNT,
     NVL(V_UPDT_COUNT, 0),
     V_START_DT,
     V_END_DT,
     V_START_ROWID,
     V_END_ROWID);
  COMMIT;

  --������
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    V_ERROR_CD      := SQLCODE;
    V_ERROR_MESSAGE := V_EXEC_STEP || SUBSTR(SQLERRM, 1, 900);
    DBMS_OUTPUT.PUT_LINE('failed! ERROR:' || V_ERROR_CD || ' ,' ||
                         V_ERROR_MESSAGE);
    RAISE_APPLICATION_ERROR(-20021, V_ERROR_MESSAGE);
    RETURN;

    COMMIT;

END SP_WARNINGS_CMBPLATFORM;
/

prompt
prompt Creating procedure SP_WARNINGS_CMBRISK
prompt ======================================
prompt
CREATE OR REPLACE PROCEDURE sp_warnings_cmbrisk IS
  /*************************************
  �洢���̣�sp_warnings_cmbrisk
  ����ʱ�䣺2017/11/28
  �� �� �ˣ�ZhangCong
  Դ    ��compy_creditrating_cmb(����������)
            compy_warnlevelchg_cmb(����Ԥ���ȼ��϶�)
  Ŀ �� ��tmp_compy_warnings(��ҵԤ���ź���ʱ��)
  ��    �ܣ�ˢ��ÿ�ո��µ�����Ԥ����Ϣ
            ����������
              1.�����������������������������½���������������������������5A����
            ����Ԥ���ȼ��϶���
              1.�����������б���Ϊ���������ѱ�¶
              2.��ҵ����Ϊ����������ɫԤ��
              3.��ҵ����Ϊ����������ɫԤ��
              4.��ҵ����Ϊ���������۲켶Ԥ��
  �޸ļ�¼��
  ************************************/

  --------------------------------������־����--------------------------------------
  v_error_cd          VARCHAR2(100);
  v_error_message     VARCHAR2(1000);
  v_task_name         etl_tgt_loadlog.process_nm%TYPE; --��������
  v_updt_dt           etl_tgt_loadlog.end_dt%TYPE; --�ϴ�ͬ������ʱ��
  v_start_dt          etl_tgt_loadlog.start_dt%TYPE; --��ʼʱ��
  v_end_dt            etl_tgt_loadlog.end_dt%TYPE; --����ʱ��
  v_start_rowid       etl_tgt_loadlog.start_rowid%TYPE; --��ʼ�к�
  v_end_rowid         etl_tgt_loadlog.end_rowid%TYPE; --��ֹ�к�
  v_insert_count      etl_tgt_loadlog.insert_count%TYPE; --�����¼��
  v_updt_count        etl_tgt_loadlog.updt_count%TYPE; --���¼�¼��
  v_orig_record_count etl_tgt_loadlog.orig_record_count%TYPE; --ԭʼ�ļ�¼��
  v_dup_record_count  etl_tgt_loadlog.dup_record_count%TYPE; --�ظ��ļ�¼��
  v_batch_sid         etl_tgt_loadlog.batch_sid%TYPE := 0; --���κ�

  --------------------------------����ҵ�����-------------------------------------
  v_warn_updt_by   tmp_compy_warnings.updt_by%TYPE := 0; --������
  v_warn_updt_dt   tmp_compy_warnings.updt_dt%TYPE := systimestamp; --����ʱ��
  v_isdel          tmp_compy_warnings.isdel%TYPE := 0; --�Ƿ�ɾ��
  v_status_flag    tmp_compy_warnings.status_flag%TYPE := 0; --����״̬ (0-δ���� 1 -�Ѵ��� LKP_CONSTANT WHERE CONSTANT_TYPE=101)
  v_warning_type   tmp_compy_warnings.warning_type%TYPE := '-1'; --������ (1 ����; -1����)
  v_warn_constant1 lkp_constant.constant_nm%TYPE; --���������Ԥ���ȼ�
  v_warn_constant2 lkp_constant.constant_nm%TYPE;
  v_warn_constant3 lkp_constant.constant_nm%TYPE;
  v_warn_constant4 lkp_constant.constant_nm%TYPE;
  v_regulation_nm  warning_regulation.regulation_nm%TYPE; --������ƥ��Ԥ���÷ֵ�Ԥ����
  v_regulation_nm1 warning_regulation.regulation_nm%TYPE;
  v_regulation_nm2 warning_regulation.regulation_nm%TYPE;
  v_regulation_nm3 warning_regulation.regulation_nm%TYPE;
  v_regulation_nm4 warning_regulation.regulation_nm%TYPE;
  v_limit_level    warning_regulation_detail.threshold%TYPE; --�����������ڴ˲���ֵ
  v_limit_code     VARCHAR2(100); --����ֵ��Ӧ����������5A
  v_change_level   warning_regulation_detail.threshold%TYPE; --���������½������˲���ֵ����
  v_subject_type   tmp_compy_warnings.subject_type%TYPE := 0; --Ԥ����������(0-��ҵ��1-ծȯ)
  v_title_content1 VARCHAR2(300); --Ԥ�����ֱ�������
  v_title_content2 VARCHAR2(300); --Ԥ�����ֱ�������

BEGIN

  --��������
  v_task_name := 'SP_WARNINGS_CMBRISK';

  --��ȡ�ϴ�ͬ�����ݵ�ʱ��
  SELECT nvl(MAX(end_dt), to_date('1900-1-1', 'yyyy-mm-dd'))
    INTO v_updt_dt
    FROM etl_tgt_loadlog
   WHERE process_nm = v_task_name;

  --������ʼ��
  v_start_dt := SYSDATE;
  --��lkp_constant��constant_type=7��constant_nm��ͬ
  v_warn_constant1 := '�����ѱ�¶';
  v_warn_constant2 := '��ɫԤ��';
  v_warn_constant3 := '��ɫԤ��';
  v_warn_constant4 := '�۲켶';
  --��warning_regulation�е�regulation_nm��ͬ
  v_regulation_nm  := '���������������½���������������һ������';
  v_regulation_nm1 := '�����������б���Ϊ���������ѱ�¶';
  v_regulation_nm2 := '��ҵ����Ϊ����������ɫԤ��';
  v_regulation_nm3 := '��ҵ����Ϊ����������ɫԤ��';
  v_regulation_nm4 := '��ҵ����Ϊ���������۲켶Ԥ��';

  --��ȡ���ñ����
  SELECT nvl(MAX(decode(b.cal_key, 'LIMIT_LEVEL', threshold, NULL)), 13), --Ĭ��5A
         nvl(MAX(decode(b.cal_key, 'CHANGE_LEVEL', threshold, NULL)), 2) --Ĭ��2��
    INTO v_limit_level, v_change_level
    FROM warning_regulation a
    LEFT JOIN warning_regulation_detail b
      ON (a.warning_regulation_sid = b.warning_regulation_sid)
   WHERE a.regulation_nm = v_regulation_nm;

  --��ȡ��������
  SELECT upper(MAX(lkp.constant_nm))
    INTO v_limit_code
    FROM lkp_constant lkp
   WHERE lkp.constant_type = 28
     AND lkp.constant_cd = to_char(v_limit_level);

  v_title_content1 := '������������������(';
  v_title_content2 := ')�����½�����' || v_change_level || '��������������������' || v_limit_code;

  --���������������½���������������������������5A��;����Ԥ���ܱ�
  INSERT INTO tmp_compy_warnings
    (subject_id, --2. Ԥ���������
     subject_type, -- Ԥ����������
     notice_dt, --3. Ԥ���ź�ʱ��
     warning_type, --4. ������
     severity, --5. ���س̶�
     warning_score, --6. �źŷ�ֵ
     warning_title, --7. Ԥ������
     type_id, --8. �źŷ���
     status_flag, --9. ����״̬
     warning_content, --10.Ԥ������
     isdel, --�Ƿ�ɾ��
     updt_by, --������
     src_cd, --Դϵͳ
     updt_dt) --����ʱ��
  
    SELECT c.company_id, --2. Ԥ���������
           v_subject_type, -- Ԥ����������
           --c.rating_period, --3. Ԥ���ź�ʱ��
           v_warn_updt_dt, --3. Ԥ���ź�ʱ��
           v_warning_type, --4. ������
           w.importance, --5. ���س̶�
           g.warning_score, --6. �źŷ�ֵ
           bas.company_nm || v_title_content1 || rating_period || v_title_content2 AS waring_title, --7. Ԥ������
           e.id, --8. �źŷ���
           v_status_flag, --9. ����״̬
           bas.company_nm || to_char(SYSDATE, 'yyyy"��"mm"��"dd"��"') || v_title_content1 ||
           rating_period || v_title_content2 AS warning_content, --10.Ԥ������
           v_isdel, --�Ƿ�ɾ��
           v_warn_updt_by, --������
           c.src_cd, --Դϵͳ
           v_warn_updt_dt --����ʱ��
    
      FROM (SELECT company_id, rating_period, src_cd, v_regulation_nm AS regulation_nm
              FROM (SELECT company_id,
                           src_cd,
                           to_char(rating_period, 'yyyy/mm/dd') AS rating_period,
                           final_rating AS current_rating,
                           lead(final_rating) over(PARTITION BY company_id ORDER BY rating_period DESC) AS last_rating,
                           updt_dt
                      FROM (SELECT cmb.company_id,
                                   nvl(cmb.final_rating, 0) AS final_rating,
                                   cmb.rating_period,
                                   lkp.constant_nm,
                                   cmb.src_cd,
                                   cmb.updt_dt,
                                   row_number() over(PARTITION BY cmb.company_id, trunc(cmb.rating_period) ORDER BY cmb.rating_start_dt DESC, cmb.updt_dt DESC) AS rn
                              FROM compy_creditrating_cmb cmb
                              JOIN lkp_constant lkp
                                ON (lkp.constant_type = 28 AND
                                   to_char(cmb.final_rating) = lkp.constant_cd)
                             WHERE EXISTS (SELECT 1
                                      FROM compy_creditrating_cmb pb
                                     WHERE cmb.company_id = pb.company_id
                                       AND cmb.rating_period <= pb.rating_period
                                       AND pb.updt_dt > v_updt_dt
                                       AND pb.isdel = 0)
                               AND cmb.isdel = 0
                               AND cmb.rating_period IS NOT NULL)
                     WHERE rn = 1)
             WHERE current_rating < v_limit_level
               AND nvl(last_rating, 0) - nvl(current_rating, 0) >= v_change_level
               AND updt_dt > v_updt_dt) c
      LEFT JOIN warning_regulation g
        ON (c.regulation_nm = g.regulation_nm)
      LEFT JOIN lkp_warning_score w
        ON (g.warning_score < w.max_val AND g.warning_score >= w.min_val AND w.isdel = 0)
      LEFT JOIN compy_event_type e
        ON (g.regulation_type = e.type_name)
      JOIN compy_basicinfo bas
        ON (c.company_id = bas.company_id);

  v_insert_count := SQL%ROWCOUNT;

  --�����������б���Ϊ���������ѱ�¶
  --��ҵ����Ϊ����������ɫԤ��
  --��ҵ����Ϊ����������ɫԤ��
  --��ҵ����Ϊ���������۲켶Ԥ��
  --���⣺XX��ҵ����Ϊ����������ɫԤ�������ݣ�XX��ҵ2017��12��15�ձ�����Ϊ����������ɫԤ����
  INSERT INTO tmp_compy_warnings
    (subject_id, --2. Ԥ���������
     subject_type, -- Ԥ����������
     notice_dt, --3. Ԥ���ź�ʱ��
     warning_type, --4. ������
     severity, --5. ���س̶�
     warning_score, --6. �źŷ�ֵ
     warning_title, --7. Ԥ������
     type_id, --8. �źŷ���
     status_flag, --9. ����״̬
     warning_content, --10.Ԥ������
     isdel, --�Ƿ�ɾ��
     updt_by, --������
     src_cd, --Դϵͳ
     updt_dt) --����ʱ��
  
    SELECT mid.company_id, --2. Ԥ���������
           v_subject_type, -- Ԥ����������
           --mid.submit_dt, --3. Ԥ���ź�ʱ��
           v_warn_updt_dt, --3. Ԥ���ź�ʱ��
           v_warning_type, --4. ������
           w.importance, --5. ���س̶�
           g.warning_score, --6. �źŷ�ֵ
           bas.company_nm || REPLACE(REPLACE(mid.regulation_nm, '��ҵ'), '������') AS warning_title, --7. Ԥ������
           e.id, --8. �źŷ���
           v_status_flag, --9. ����״̬
           bas.company_nm || to_char(mid.submit_dt, 'yyyy"��"mm"��"dd"��"') ||
           REPLACE(REPLACE(mid.regulation_nm, '��ҵ'), '������') AS warning_content, --10.Ԥ������
           v_isdel, --�Ƿ�ɾ��
           v_warn_updt_by, --������
           mid.src_cd, --Դϵͳ
           v_warn_updt_dt --����ʱ��
    
      FROM (SELECT company_id, submit_dt, src_cd, regulation_nm
              FROM (SELECT cb.company_id,
                           cb.submit_dt,
                           cb.src_cd,
                           CASE
                             WHEN kp1.constant_nm = v_warn_constant1 THEN
                              v_regulation_nm1
                             WHEN kp1.constant_nm = v_warn_constant2 THEN
                              v_regulation_nm2
                             WHEN kp1.constant_nm = v_warn_constant3 THEN
                              v_regulation_nm3
                             WHEN kp1.constant_nm = v_warn_constant4 THEN
                              v_regulation_nm4
                             ELSE
                              NULL
                           END AS regulation_nm,
                           row_number() over(PARTITION BY cb.company_id, trunc(cb.submit_dt), kp1.constant_nm ORDER BY cb.submit_dt DESC) AS rnd
                      FROM compy_warnlevelchg_cmb cb
                      JOIN lkp_constant kp1
                        ON (cb.warn_level = kp1.constant_cd AND kp1.constant_type = 7 AND
                           kp1.isdel = 0 AND
                           kp1.constant_nm IN (v_warn_constant1,
                                                v_warn_constant2,
                                                v_warn_constant3,
                                                v_warn_constant4))
                     WHERE cb.updt_dt > v_updt_dt
                       AND cb.isdel = 0
                       AND nvl(cb.warn_level, 'NUL') <> nvl(cb.pre_warn_level, 'NUL'))
             WHERE rnd = 1) mid
      LEFT JOIN warning_regulation g
        ON (mid.regulation_nm = g.regulation_nm)
      LEFT JOIN lkp_warning_score w
        ON (g.warning_score < w.max_val AND g.warning_score >= w.min_val AND w.isdel = 0)
      LEFT JOIN compy_event_type e
        ON (g.regulation_type = e.type_name)
      JOIN compy_basicinfo bas
        ON (mid.company_id = bas.company_id);

  v_insert_count      := v_insert_count + SQL%ROWCOUNT;
  v_orig_record_count := v_insert_count;
  v_updt_count        := 0;

  --����ʱ��
  v_end_dt := SYSDATE;

  COMMIT;

  --�������ݵ�LOG����

  INSERT INTO etl_tgt_loadlog
    (loadlog_sid,
     batch_sid,
     process_nm,
     orig_record_count,
     dup_record_count,
     insert_count,
     updt_count,
     start_dt,
     end_dt,
     start_rowid,
     end_rowid)
    SELECT seq_etl_tgt_loadlog.nextval,
           v_batch_sid,
           v_task_name,
           v_orig_record_count,
           v_dup_record_count,
           v_insert_count,
           v_updt_count,
           v_start_dt,
           v_end_dt,
           v_start_rowid,
           v_end_rowid
      FROM dual;

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
  
END sp_warnings_cmbrisk;
/

prompt
prompt Creating procedure SP_WARNINGS_CREDITRATING
prompt ===========================================
prompt
CREATE OR REPLACE PROCEDURE SP_WARNINGS_CREDITRATING IS
  /*
  �洢���̣�SP_WARNINGS_CREDITRATING
  ��    �ܣ�����-Ԥ���ź��ܱ�-����
  �� �� �ˣ�RAYLEE
  ����ʱ�䣺2017/11/28 13:40:55
  Դ    ��COMPY_CREDITRATING_INFO
  �� �� ��CS_MASTER_TGT.WARNING_REGULATION
            CS_MASTER_TGT.COMPY_WARNINGS
            CS_MASTER_TGT.LKP_NUMBCODE
            CS_MASTER_TGT.LKP_RATING_CODE_LIST
            CS_MASTER_TGT.LKP_WARNING_SCORE
            CS_MASTER_TGT.COMPY_BASICINFO
            CS_MASTER_TGT.COMPY_CREDITRATING
  Ŀ �� ��COMPY_WARNINGS
  --------------------------------------------------------------------
  �� �� �ˣ�RayLee
  �޸�ʱ�䣺20171221 10:23
  �޸����ݣ���ȷ�ⲿ�����µ�һ�����µ�һ����ʱ������Ϊ���꣬��һ��
  �� �� �ˣ�RayLee
  �޸�ʱ�䣺2017-12-21 17:59:36
  �޸����ݣ����������������ṹ�����仯���޸��ֶ�
            WARNING_REGULATION_DETAIL�� VALUE ��Ϊ THRESHOLD
            WARNING_REGULATION_DETAIL�� COLUMN_NM ��Ϊ CAL_KEY
  �� �� �ˣ�RayLee
  �޸�ʱ�䣺2017-12-22 10:14:53
  �޸����ݣ��޸�������ȡ���ݵ��߼�
  �� �� �ˣ�RayLee
  �޸�ʱ�䣺2017-12-25 16:43:43
  �޸����ݣ�ÿ��Ԥ��Ӧֻ�����������ݵ�Ԥ������Ӧչʾ��������
  �� �� �ˣ�RayLee
  �޸�ʱ�䣺2017-12-25 20:31:39
  �޸����ݣ������ֶμ��� updt_dt
  �� �� �ˣ�RayLee
  �޸�ʱ�䣺2017-12-27 14:35:52
  �޸����ݣ�ͬһ���ζ���Ԥ����ֻȡ���µ�һ��Ԥ����Ϣ
  */

  V_ERROR_CD          VARCHAR2(100);
  V_ERROR_MESSAGE     VARCHAR2(1000);
  V_TASK_NAME         ETL_TGT_LOADLOG.PROCESS_NM%TYPE; --��������
  V_UPDT_DT           ETL_TGT_LOADLOG.END_DT%TYPE; --�ϴ�ͬ������ʱ��
  V_START_DT          ETL_TGT_LOADLOG.START_DT%TYPE; --��ʼʱ��
  V_END_DT            ETL_TGT_LOADLOG.END_DT%TYPE; --����ʱ��
  V_START_ROWID       ETL_TGT_LOADLOG.START_ROWID%TYPE; --��ʼ�к�
  V_END_ROWID         ETL_TGT_LOADLOG.END_ROWID%TYPE; --��ֹ�к�
  V_INSERT_COUNT      ETL_TGT_LOADLOG.INSERT_COUNT%TYPE; --�����¼��
  V_UPDT_COUNT        ETL_TGT_LOADLOG.UPDT_COUNT%TYPE; --���¼�¼��
  V_ORIG_RECORD_COUNT NUMBER(16); --ԭʼ�ļ�¼��
  V_DUP_RECORD_COUNT  NUMBER(16); --�ظ��ļ�¼��

  --------------------------------����ͨ�õĳ���--------------------------------------
  --������
  V_UPDT_BY COMPY_WARNINGS.UPDT_BY%TYPE := 0;
  --�Ƿ�ɾ��
  V_ISDEL COMPY_WARNINGS.ISDEL%TYPE := 0;
  --Դϵͳ
  V_SRC_CD COMPY_WARNINGS.SRC_CD%TYPE := 'CSCS';
  --����״̬ (0-δ���� 1 -�Ѵ��� LKP_CONSTANT WHERE CONSTANT_TYPE=101)
  V_STATUS_FLAG COMPY_WARNINGS.STATUS_FLAG%TYPE := 0;
  --������ (1 ���棻-1���� )
  V_WARNING_TYPE COMPY_WARNINGS.WARNING_TYPE%TYPE := '-1';
  --�źŷ���  SELECT ID FROM COMPY_EVENT_TYPE
  V_TYPE_ID COMPY_WARNINGS.TYPE_ID%TYPE;

  --------------------------------��������--------------------------------------
  V_RATE_FWD_CURRENT_1 COMPY_CREDITRATING_INFO.RATE_FWD_CURRENT%TYPE := '����';
  V_RATE_FWD_PREV_1    COMPY_CREDITRATING_INFO.RATE_FWD_PREV%TYPE := '����';
  V_CREDITRATING_1     COMPY_CREDITRATING_INFO.CREDITRATING%TYPE := 'չ���µ�';
  V_CONSTANT_NM_2_1    LKP_NUMBCODE.CONSTANT_NM%TYPE := '���������۲�(���ܵ���)';
  V_CONSTANT_NM_2_2    LKP_NUMBCODE.CONSTANT_NM%TYPE := '���������۲�(���Ʋ���)';
  V_CREDITRATING_3     COMPY_CREDITRATING_INFO.CREDITRATING%TYPE := '�����µ�';
  V_CREDITRATING_4     COMPY_CREDITRATING_INFO.CREDITRATING%TYPE := '�����µ�';

  --------------------------------�÷�����--------------------------------------
  V_REGULATION_NM_1 WARNING_REGULATION.REGULATION_NM%TYPE := '�ⲿ����չ����Ϊ����';
  V_REGULATION_NM_2 WARNING_REGULATION.REGULATION_NM%TYPE := '�ⲿ��������۲�����';
  V_REGULATION_NM_3 WARNING_REGULATION.REGULATION_NM%TYPE := '�ⲿ�����µ����1';
  V_REGULATION_NM_4 WARNING_REGULATION.REGULATION_NM%TYPE := '�ⲿ�����µ����2';
  V_REGULATION_NM_5 WARNING_REGULATION.REGULATION_NM%TYPE := '�ⲿ�����µ����3';

  --------------------------------�������--------------------------------------
  V_WARNING_TITLE_1_1 COMPY_WARNINGS.WARNING_TITLE%TYPE := '��ҵ�ⲿ����ά��';
  V_WARNING_TITLE_1_2 COMPY_WARNINGS.WARNING_TITLE%TYPE := ', ��չ��ת����';
  V_WARNING_TITLE_2_1 COMPY_WARNINGS.WARNING_TITLE%TYPE := '��ҵ����չ��Ϊ';
  V_WARNING_TITLE_2_2 COMPY_WARNINGS.WARNING_TITLE%TYPE := ', ��������Ϊ';
  V_WARNING_TITLE_3_1 COMPY_WARNINGS.WARNING_TITLE%TYPE := '��ҵ�ⲿ������';
  V_WARNING_TITLE_3_2 COMPY_WARNINGS.WARNING_TITLE%TYPE := '�µ�Ϊ';
  V_WARNING_TITLE_3_3 COMPY_WARNINGS.WARNING_TITLE%TYPE := ',�µ�����Ϊ1��, ��������Ϊ';
  V_WARNING_TITLE_4_1 COMPY_WARNINGS.WARNING_TITLE%TYPE := '��ҵ�ⲿ�����µ�Ϊ';
  V_WARNING_TITLE_4_2 COMPY_WARNINGS.WARNING_TITLE%TYPE := '), �˴��µ�Ϊ�����ڵ�';
  V_WARNING_TITLE_4_3 COMPY_WARNINGS.WARNING_TITLE%TYPE := '���µ�, ��������Ϊ';

  --------------------------------�������--------------------------------------
  V_RATING_DT_CURRENT_1 WARNING_REGULATION_DETAIL.THRESHOLD%TYPE;
  V_RATING_DT_CURRENT_2 WARNING_REGULATION_DETAIL.THRESHOLD%TYPE;
  V_RATING_DT_CURRENT_3 WARNING_REGULATION_DETAIL.THRESHOLD%TYPE;
  V_CNT_3               WARNING_REGULATION_DETAIL.THRESHOLD%TYPE;
  V_DESC_LVL_3          WARNING_REGULATION_DETAIL.THRESHOLD%TYPE;
  V_RATING_DT_CURRENT_4 WARNING_REGULATION_DETAIL.THRESHOLD%TYPE;
  V_CNT_4               WARNING_REGULATION_DETAIL.THRESHOLD%TYPE;
  V_CNT_5               WARNING_REGULATION_DETAIL.THRESHOLD%TYPE;
  V_DESC_LVL_4          WARNING_REGULATION_DETAIL.THRESHOLD%TYPE;

  V_SUBJECT_TYPE COMPY_WARNINGS.SUBJECT_TYPE%TYPE := '0';

  V_EXEC_STEP VARCHAR2(100);
BEGIN

  --��������
  V_TASK_NAME := 'SP_WARNINGS_CREDITRATING';

  --��ʼʱ��
  V_START_DT := SYSDATE;

  --��ȡ�ϴ�ͬ�����ݵ�ʱ��,����ǵ�һ������û�м�¼�ᷢ��NO_DATA_FOUND�쳣
  V_EXEC_STEP := 'STEP0 ��ȡ�ϴ�ͬ��ʱ��';
  BEGIN
    SELECT NVL(MAX(END_DT), TO_DATE('1900-1-1', 'yyyy-mm-dd'))
      INTO V_UPDT_DT
      FROM ETL_TGT_LOADLOG
     WHERE PROCESS_NM = V_TASK_NAME;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      V_UPDT_DT := TO_DATE('1900-1-1', 'yyyy-mm-dd');
  END;

  BEGIN
    SELECT T.ID
      INTO V_TYPE_ID
      FROM COMPY_EVENT_TYPE T
     WHERE T.TYPE_NAME = '��������';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      V_TYPE_ID := '2';
  END;

  BEGIN
    SELECT NVL(MAX(CASE
                     WHEN T.REGULATION_NM = V_REGULATION_NM_1 AND
                          T1.CAL_KEY = 'RATING_DT_CURRENT' THEN
                      T1.THRESHOLD
                     ELSE
                      NULL
                   END),
               -12),
           NVL(MAX(CASE
                     WHEN T.REGULATION_NM = V_REGULATION_NM_2 AND
                          T1.CAL_KEY = 'RATING_DT' THEN
                      T1.THRESHOLD
                     ELSE
                      NULL
                   END),
               -12),
           NVL(MAX(CASE
                     WHEN T.REGULATION_NM = V_REGULATION_NM_3 AND
                          T1.CAL_KEY = 'RATING_DT_CURRENT' THEN
                      T1.THRESHOLD
                     ELSE
                      NULL
                   END),
               -12),
           NVL(MAX(CASE
                     WHEN T.REGULATION_NM = V_REGULATION_NM_3 AND
                          T1.CAL_KEY = 'CNT' THEN
                      T1.THRESHOLD
                     ELSE
                      NULL
                   END),
               2),
           NVL(MAX(CASE
                     WHEN T.REGULATION_NM = V_REGULATION_NM_3 AND
                          T1.CAL_KEY = 'DESC_LVL' THEN
                      T1.THRESHOLD
                     ELSE
                      NULL
                   END),
               2),
           NVL(MAX(CASE
                     WHEN T.REGULATION_NM = V_REGULATION_NM_4 AND
                          T1.CAL_KEY = 'RATING_DT_CURRENT' THEN
                      T1.THRESHOLD
                     ELSE
                      NULL
                   END),
               -6),
           NVL(MAX(CASE
                     WHEN T.REGULATION_NM = V_REGULATION_NM_4 AND
                          T1.CAL_KEY = 'CNT' THEN
                      T1.THRESHOLD
                     ELSE
                      NULL
                   END),
               2),
           NVL(MAX(CASE
                     WHEN T.REGULATION_NM = V_REGULATION_NM_4 AND
                          T1.CAL_KEY = 'DESC_LVL' THEN
                      T1.THRESHOLD
                     ELSE
                      NULL
                   END),
               2),
           NVL(MAX(CASE
                     WHEN T.REGULATION_NM = V_REGULATION_NM_5 AND
                          T1.CAL_KEY = 'CNT' THEN
                      T1.THRESHOLD
                     ELSE
                      NULL
                   END),
               2)
      INTO V_RATING_DT_CURRENT_1,
           V_RATING_DT_CURRENT_2,
           V_RATING_DT_CURRENT_3,
           V_CNT_3,
           V_DESC_LVL_3,
           V_RATING_DT_CURRENT_4,
           V_CNT_4,
           V_DESC_LVL_4,
           V_CNT_5
      FROM WARNING_REGULATION T
     INNER JOIN WARNING_REGULATION_DETAIL T1
        ON T1.WARNING_REGULATION_SID = T.WARNING_REGULATION_SID
     WHERE T.REGULATION_TYPE = '��������'
       AND T.REGULATION_NM IN (V_REGULATION_NM_1,
                               V_REGULATION_NM_2,
                               V_REGULATION_NM_3,
                               V_REGULATION_NM_4,
                               V_REGULATION_NM_5)
     GROUP BY T.REGULATION_TYPE;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      V_RATING_DT_CURRENT_1 := -12;
      V_RATING_DT_CURRENT_2 := -12;
      --V_RATING_DT_CURRENT_3 := -12;
      -- modify by raylee 20171221
      V_RATING_DT_CURRENT_3 := -6;
      V_CNT_3               := 2;
      V_DESC_LVL_3          := 2;
      V_RATING_DT_CURRENT_4 := -6;
      V_CNT_4               := 2;
      V_CNT_5               := 2;
      V_DESC_LVL_4          := 2;
  END;

  --����չ����Ϊ����
  V_EXEC_STEP := 'STEP1 ����չ����Ϊ����';
  INSERT ALL INTO TMP_COMPY_WARNINGS
    (--COMPY_WARNINGS_SID, --1. ��ˮ��
     --COMPANY_ID, --2. Ԥ���������
     NOTICE_DT, --3. Ԥ���ź�ʱ��
     WARNING_TYPE, --4. ������
     SEVERITY, --5. ���س̶�
     WARNING_SCORE, --6. �źŷ�ֵ
     WARNING_TITLE, --7. Ԥ������
     TYPE_ID, --8. �źŷ���
     STATUS_FLAG, --9. ����״̬
     WARNING_RESULT_CD, --10.  ��������
     ADJUST_SEVERITY, --11.  ���������س̶�
     ADJUST_SCORE, --12.  ������÷�
     REMARK, --13.  ��ע
     PROCESS_BY, --14.  ������
     PROCESS_DT, --15.  ����ʱ��
     ISDEL, --16.  �Ƿ�ɾ��
     UPDT_BY, --17.  ������
     SRC_CD, --18.  Դϵͳ
     UPDT_DT, --19.  ����ʱ��
     SUBJECT_ID, -- A1. Ԥ���������
     SUBJECT_TYPE, -- A2.Ԥ����������
     WARNING_CONTENT
     )
    SELECT --A.COMPY_CREDITRATING_INFO_SID AS COMPY_WARNINGS_SID, --1. ��ˮ��
           --A.COMPANY_ID AS COMPANY_ID, --2. Ԥ���������
           A.RATING_DT_CURRENT AS NOTICE_DT, --3. Ԥ���ź�ʱ��
           V_WARNING_TYPE AS WARNING_TYPE, --4. ������
           A2.IMPORTANCE AS SEVERITY, --5. ���س̶�
           A1.WARNING_SCORE AS WARNING_SCORE, --6. �źŷ�ֵ
           EXTRACT(YEAR FROM A.RATING_DT_CURRENT) || '��' ||
           EXTRACT(MONTH FROM A.RATING_DT_CURRENT) || '��' ||
           EXTRACT(DAY FROM A.RATING_DT_CURRENT) || '��' || ' ' ||
           V_WARNING_TITLE_1_1 || COALESCE(A.RATING_PREV, '') || '(' ||
           TO_CHAR(A.RATING_DT_PREV, 'YYYY/MM/DD') || ')' || ' ' ||
           COALESCE(A.RATING_PREV, '') || V_WARNING_TITLE_1_2 AS WARNING_TITLE, --7. Ԥ������
           V_TYPE_ID AS TYPE_ID, --8. �źŷ���
           V_STATUS_FLAG AS STATUS_FLAG, --9. ����״̬
           NULL AS WARNING_RESULT_CD, --10.  ��������
           NULL AS ADJUST_SEVERITY, --11.  ���������س̶�
           NULL AS ADJUST_SCORE, --12.  ������÷�
           NULL AS REMARK, --13.  ��ע
           NULL AS PROCESS_BY, --14.  ������
           NULL AS PROCESS_DT, --15.  ����ʱ��
           V_ISDEL AS ISDEL, --16.  �Ƿ�ɾ��
           V_UPDT_BY AS UPDT_BY, --17.  ������
           V_SRC_CD AS SRC_CD, --18.  Դϵͳ
           sysdate AS UPDT_DT, --19.  ����ʱ��
           A.COMPANY_ID AS SUBJECT_ID, -- A1. Ԥ���������
           V_SUBJECT_TYPE AS SUBJECT_TYPE, -- A2.Ԥ����������
           A.COMPANY_NM || EXTRACT(YEAR FROM A.RATING_DT_CURRENT) || '��' ||
           EXTRACT(MONTH FROM A.RATING_DT_CURRENT) || '��' ||
           EXTRACT(DAY FROM A.RATING_DT_CURRENT) || '��' || ' ' || CHR(10) ||
           V_WARNING_TITLE_1_1 || COALESCE(A.RATING_PREV, '') || '(' ||
           TO_CHAR(A.RATING_DT_PREV, 'YYYY/MM/DD') || ')' || ' ' ||
           COALESCE(A.RATING_PREV, '') || V_WARNING_TITLE_1_2 AS WARNING_CONTENT
      FROM COMPY_CREDITRATING_INFO A
      LEFT JOIN WARNING_REGULATION A1
        ON A1.REGULATION_NM = V_REGULATION_NM_1
      LEFT JOIN LKP_WARNING_SCORE A2
        ON A2.MIN_VAL <= A1.WARNING_SCORE
       AND A2.MAX_VAL > A1.WARNING_SCORE
       AND A2.ISDEL = 0
     WHERE RATING_DT_CURRENT >= ADD_MONTHS(SYSDATE, V_RATING_DT_CURRENT_1)
       AND RATE_FWD_CURRENT = V_RATE_FWD_CURRENT_1
       AND RATE_FWD_PREV <> V_RATE_FWD_PREV_1
       AND A.CREDITRATING = V_CREDITRATING_1
       AND A.UPDT_DT > V_UPDT_DT;

  V_INSERT_COUNT := SQL%ROWCOUNT;
  COMMIT;

  --����۲�����
  V_EXEC_STEP := 'STEP2 ����۲�����';
  INSERT INTO TMP_COMPY_WARNINGS
    (--COMPY_WARNINGS_SID, --1. ��ˮ��
     --COMPANY_ID, --2. Ԥ���������
     NOTICE_DT, --3. Ԥ���ź�ʱ��
     WARNING_TYPE, --4. ������
     SEVERITY, --5. ���س̶�
     WARNING_SCORE, --6. �źŷ�ֵ
     WARNING_TITLE, --7. Ԥ������
     TYPE_ID, --8. �źŷ���
     STATUS_FLAG, --9. ����״̬
     WARNING_RESULT_CD, --10.  ��������
     ADJUST_SEVERITY, --11.  ���������س̶�
     ADJUST_SCORE, --12.  ������÷�
     REMARK, --13.  ��ע
     PROCESS_BY, --14.  ������
     PROCESS_DT, --15.  ����ʱ��
     ISDEL, --16.  �Ƿ�ɾ��
     UPDT_BY, --17.  ������
     SRC_CD, --18.  Դϵͳ
     UPDT_DT, --19.  ����ʱ��
     SUBJECT_ID, -- A1. Ԥ���������
     SUBJECT_TYPE, -- A2.Ԥ����������
     WARNING_CONTENT)

    SELECT --F.COMPY_CREDITRATING_SID AS COMPY_WARNINGS_SID, --1. ��ˮ��
           --F.COMPANY_ID AS COMPANY_ID, --2. Ԥ���������
           F.NOTICE_DT AS NOTICE_DT, --3. Ԥ���ź�ʱ��
           V_WARNING_TYPE AS WARNING_TYPE, --4. ������
           A2.IMPORTANCE AS SEVERITY, --5. ���س̶�
           A1.WARNING_SCORE AS WARNING_SCORE, --6. �źŷ�ֵ
           EXTRACT(YEAR FROM F.NOTICE_DT) || '��' ||
           EXTRACT(MONTH FROM F.NOTICE_DT) || '��' ||
           EXTRACT(DAY FROM F.NOTICE_DT) || '��' || ' ' || CHR(10) ||
           V_WARNING_TITLE_2_1 || B.CONSTANT_NM || V_WARNING_TITLE_2_2 ||
           COALESCE(D.DATA_SRC, F.DATA_SRC, '') AS WARNING_TITLE, --7. Ԥ������
           V_TYPE_ID AS TYPE_ID, --8. �źŷ���
           V_STATUS_FLAG AS STATUS_FLAG, --9. ����״̬
           NULL AS WARNING_RESULT_CD, --10.  ��������
           NULL AS ADJUST_SEVERITY, --11.  ���������س̶�
           NULL AS ADJUST_SCORE, --12.  ������÷�
           NULL AS REMARK, --13.  ��ע
           NULL AS PROCESS_BY, --14.  ������
           NULL AS PROCESS_DT, --15.  ����ʱ��
           V_ISDEL AS ISDEL, --16.  �Ƿ�ɾ��
           V_UPDT_BY AS UPDT_BY, --17.  ������
           V_SRC_CD AS SRC_CD, --18.  Դϵͳ
           sysdate AS UPDT_DT, --19.  ����ʱ��
           F.COMPANY_ID AS SUBJECT_ID, -- A1. Ԥ���������
           V_SUBJECT_TYPE AS SUBJECT_TYPE, -- A2.Ԥ����������
           C.COMPANY_NM || EXTRACT(YEAR FROM F.NOTICE_DT) || '��' ||
           EXTRACT(MONTH FROM F.NOTICE_DT) || '��' ||
           EXTRACT(DAY FROM F.NOTICE_DT) || '��' || ' ' || CHR(10) ||
           V_WARNING_TITLE_2_1 || B.CONSTANT_NM || V_WARNING_TITLE_2_2 ||
           COALESCE(D.DATA_SRC, F.DATA_SRC, '') AS WARNING_CONTENT
      FROM COMPY_CREDITRATING F
      LEFT JOIN LKP_NUMBCODE B
        ON F.RATE_FWD_CD = B.CONSTANT_CD
       AND B.CONSTANT_TYPE = 14
      LEFT JOIN COMPY_BASICINFO C
        ON F.CREDIT_ORG_ID = C.COMPANY_ID
      LEFT JOIN COMPY_CREDITRATING_INFO D
        ON C.COMPANY_NM = D.CREDIT_ORG_NM
       AND F.COMPANY_ID = D.COMPANY_ID
       AND F.RATING_DT = D.RATING_DT_CURRENT
      LEFT JOIN WARNING_REGULATION A1
        ON A1.REGULATION_NM = V_REGULATION_NM_2
      LEFT JOIN LKP_WARNING_SCORE A2
        ON A2.MIN_VAL <= A1.WARNING_SCORE
       AND A2.MAX_VAL > A1.WARNING_SCORE
       AND A2.ISDEL = 0
     WHERE F.ISDEL = 0
       AND C.IS_DEL = F.ISDEL
       AND B.CONSTANT_NM IN (V_CONSTANT_NM_2_1, V_CONSTANT_NM_2_2)
       AND F.RATING_DT >= ADD_MONTHS(SYSDATE, V_RATING_DT_CURRENT_2)
       AND F.UPDT_DT > V_UPDT_DT;

  V_INSERT_COUNT := V_INSERT_COUNT + SQL%ROWCOUNT;
  COMMIT;

  V_EXEC_STEP := 'STEP3 �ⲿ�����µ�һ�����µ�һ��';
  INSERT INTO TMP_COMPY_WARNINGS
    (--COMPY_WARNINGS_SID, --1. ��ˮ��
     --COMPANY_ID, --2. Ԥ���������
     NOTICE_DT, --3. Ԥ���ź�ʱ��
     WARNING_TYPE, --4. ������
     SEVERITY, --5. ���س̶�
     WARNING_SCORE, --6. �źŷ�ֵ
     WARNING_TITLE, --7. Ԥ������
     TYPE_ID, --8. �źŷ���
     STATUS_FLAG, --9. ����״̬
     WARNING_RESULT_CD, --10.  ��������
     ADJUST_SEVERITY, --11.  ���������س̶�
     ADJUST_SCORE, --12.  ������÷�
     REMARK, --13.  ��ע
     PROCESS_BY, --14.  ������
     PROCESS_DT, --15.  ����ʱ��
     ISDEL, --16.  �Ƿ�ɾ��
     UPDT_BY, --17.  ������
     SRC_CD, --18.  Դϵͳ
     UPDT_DT, --19.  ����ʱ��
     SUBJECT_ID, -- A1. Ԥ���������
     SUBJECT_TYPE, -- A2.Ԥ����������
     WARNING_CONTENT
     )
    SELECT --RET.COMPY_WARNINGS_SID AS COMPY_WARNINGS_SID, --1. ��ˮ��
           --RET.COMPANY_ID         AS COMPANY_ID, --2. Ԥ���������
           RET.NOTICE_DT          AS NOTICE_DT, --3. Ԥ���ź�ʱ��
           V_WARNING_TYPE         AS WARNING_TYPE, --4. ������
           A2.IMPORTANCE          AS SEVERITY, --5. ���س̶�
           A1.WARNING_SCORE       AS WARNING_SCORE, --6. �źŷ�ֵ
           RET.WARNING_TITLE      AS WARNING_TITLE, --7. Ԥ������
           V_TYPE_ID              AS TYPE_ID, --8. �źŷ���
           V_STATUS_FLAG          AS STATUS_FLAG, --9. ����״̬
           NULL                   AS WARNING_RESULT_CD, --10.  ��������
           NULL                   AS ADJUST_SEVERITY, --11.  ���������س̶�
           NULL                   AS ADJUST_SCORE, --12.  ������÷�
           NULL                   AS REMARK, --13.  ��ע
           NULL                   AS PROCESS_BY, --14.  ������
           NULL                   AS PROCESS_DT, --15.  ����ʱ��
           V_ISDEL                AS ISDEL, --16.  �Ƿ�ɾ��
           V_UPDT_BY              AS UPDT_BY, --17.  ������
           V_SRC_CD               AS SRC_CD, --18.  Դϵͳ
           sysdate            AS UPDT_DT, --19.  ����ʱ��
           RET.COMPANY_ID         AS SUBJECT_ID, -- A1. Ԥ���������
           V_SUBJECT_TYPE         AS SUBJECT_TYPE, -- A2.Ԥ����������
           WARNING_CONTENT        AS WARNING_CONTENT
      FROM (SELECT A.COMPY_CREDITRATING_INFO_SID AS COMPY_WARNINGS_SID,
                   A.COMPANY_ID AS COMPANY_ID,
                   A.RATING_DT_CURRENT AS NOTICE_DT,
                   NVL(B.RATING_RNK, C.RATING_RNK) -
                   NVL(D.RATING_RNK, E.RATING_RNK) AS DESC_LVL,
                   COUNT(*) OVER(PARTITION BY A.COMPANY_ID) AS CNT,
                   A.UPDT_DT,
                   EXTRACT(YEAR FROM A.RATING_DT_CURRENT) || '��' ||
                   EXTRACT(MONTH FROM A.RATING_DT_CURRENT) || '��' ||
                   EXTRACT(DAY FROM A.RATING_DT_CURRENT) || '��' || ' ' ||
                   V_WARNING_TITLE_3_1 || COALESCE(A.RATING_PREV, '') || '(' ||
                   TO_CHAR(A.RATING_DT_PREV, 'YYYY/MM/DD') || ')' ||
                   V_WARNING_TITLE_3_2 || '' ||
                   COALESCE(A.RATING_CURRENT, '') || '(' ||
                   TO_CHAR(A.RATING_DT_CURRENT, 'YYYY/MM/DD') || ')' ||
                   V_WARNING_TITLE_3_3 || COALESCE(A.CREDIT_ORG_NM, '') AS WARNING_TITLE,

                   A.COMPANY_NM || EXTRACT(YEAR FROM A.RATING_DT_CURRENT) || '��' ||
                   EXTRACT(MONTH FROM A.RATING_DT_CURRENT) || '��' ||
                   EXTRACT(DAY FROM A.RATING_DT_CURRENT) || '��' || ' ' ||
                   CHR(10) || V_WARNING_TITLE_3_1 ||
                   COALESCE(A.RATING_PREV, '') || '(' ||
                   TO_CHAR(A.RATING_DT_PREV, 'YYYY/MM/DD') || ')' ||
                   V_WARNING_TITLE_3_2 || '' ||
                   COALESCE(A.RATING_CURRENT, '') || '(' ||
                   TO_CHAR(A.RATING_DT_CURRENT, 'YYYY/MM/DD') || ')' ||
                   V_WARNING_TITLE_3_3 || COALESCE(A.CREDIT_ORG_NM, '') AS WARNING_CONTENT
              FROM COMPY_CREDITRATING_INFO A
              LEFT JOIN LKP_RATING_CODE_LIST B
                ON B.RATING_CODE = A.RATING_CURRENT
              LEFT JOIN LKP_RATING_CODE_LIST C
                ON C.RATING_CODE_MOODY = A.RATING_CURRENT
              LEFT JOIN LKP_RATING_CODE_LIST D
                ON D.RATING_CODE = A.RATING_PREV
              LEFT JOIN LKP_RATING_CODE_LIST E
                ON E.RATING_CODE_MOODY = A.RATING_PREV
             WHERE A.RATING_DT_CURRENT >=
                   ADD_MONTHS(SYSDATE, V_RATING_DT_CURRENT_3)
               AND A.CREDITRATING = V_CREDITRATING_3
               -- AND A.UPDT_DT > V_UPDT_DT   modify by raylee 2017-12-22 10:14:53
               -- BELOW ADD BY RAYLEE 2017-12-22 10:14:5
               AND EXISTS(
               SELECT * FROM COMPY_CREDITRATING_INFO T
                 WHERE T.COMPANY_ID = A.COMPANY_ID
                   AND T.UPDT_DT > V_UPDT_DT)
               ) RET
      LEFT JOIN WARNING_REGULATION A1
        ON A1.REGULATION_NM = V_REGULATION_NM_3
      LEFT JOIN LKP_WARNING_SCORE A2
        ON A2.MIN_VAL <= A1.WARNING_SCORE
       AND A2.MAX_VAL > A1.WARNING_SCORE
       AND A2.ISDEL = 0
     WHERE CNT < V_CNT_3
       AND DESC_LVL < V_DESC_LVL_3
       AND RET.UPDT_DT > V_UPDT_DT -- ֻչʾȫ������������ 2017-12-25 16:43:43
       ;

  V_INSERT_COUNT := V_INSERT_COUNT + SQL%ROWCOUNT;
  COMMIT;

  V_EXEC_STEP := 'STEP4 �ⲿ������������µ����';
  INSERT INTO TMP_COMPY_WARNINGS
    (--COMPY_WARNINGS_SID, --1. ��ˮ��
     --COMPANY_ID, --2. Ԥ���������
     NOTICE_DT, --3. Ԥ���ź�ʱ��
     WARNING_TYPE, --4. ������
     SEVERITY, --5. ���س̶�
     WARNING_SCORE, --6. �źŷ�ֵ
     WARNING_TITLE, --7. Ԥ������
     TYPE_ID, --8. �źŷ���
     STATUS_FLAG, --9. ����״̬
     WARNING_RESULT_CD, --10.  ��������
     ADJUST_SEVERITY, --11.  ���������س̶�
     ADJUST_SCORE, --12.  ������÷�
     REMARK, --13.  ��ע
     PROCESS_BY, --14.  ������
     PROCESS_DT, --15.  ����ʱ��
     ISDEL, --16.  �Ƿ�ɾ��
     UPDT_BY, --17.  ������
     SRC_CD, --18.  Դϵͳ
     UPDT_DT, --19.  ����ʱ��
     SUBJECT_ID, -- A1. Ԥ���������
     SUBJECT_TYPE, -- A2.Ԥ����������
     WARNING_CONTENT
     )
    SELECT --RET.COMPY_WARNINGS_SID AS COMPY_WARNINGS_SID, --1. ��ˮ��
           --RET.COMPANY_ID         AS COMPANY_ID, --2. Ԥ���������
           RET.NOTICE_DT          AS NOTICE_DT, --3. Ԥ���ź�ʱ��
           V_WARNING_TYPE         AS WARNING_TYPE, --4. ������
           A2.IMPORTANCE          AS SEVERITY, --5. ���س̶�
           A1.WARNING_SCORE       AS WARNING_SCORE, --6. �źŷ�ֵ
           RET.WARNING_TITLE      AS WARNING_TITLE, --7. Ԥ������
           V_TYPE_ID              AS TYPE_ID, --8. �źŷ���
           V_STATUS_FLAG          AS STATUS_FLAG, --9. ����״̬
           NULL                   AS WARNING_RESULT_CD, --10.  ��������
           NULL                   AS ADJUST_SEVERITY, --11.  ���������س̶�
           NULL                   AS ADJUST_SCORE, --12.  ������÷�
           NULL                   AS REMARK, --13.  ��ע
           NULL                   AS PROCESS_BY, --14.  ������
           NULL                   AS PROCESS_DT, --15.  ����ʱ��
           V_ISDEL                AS ISDEL, --16.  �Ƿ�ɾ��
           V_UPDT_BY              AS UPDT_BY, --17.  ������
           V_SRC_CD               AS SRC_CD, --18.  Դϵͳ
           sysdate                AS UPDT_DT, --19.  ����ʱ��
           RET.COMPANY_ID         AS SUBJECT_ID, -- A1. Ԥ���������
           V_SUBJECT_TYPE         AS SUBJECT_TYPE, -- A2.Ԥ����������
           WARNING_CONTENT        AS WARNING_CONTENT
      FROM (SELECT A.COMPY_CREDITRATING_INFO_SID AS COMPY_WARNINGS_SID,
                   A.COMPANY_ID AS COMPANY_ID,
                   A.RATING_DT_CURRENT AS NOTICE_DT,
                   NVL(B.RATING_RNK, C.RATING_RNK) -
                   NVL(D.RATING_RNK, E.RATING_RNK) AS DESC_LVL,
                   COUNT(*) OVER(PARTITION BY A.COMPANY_ID) AS CNT,
                   A.UPDT_DT,
                   EXTRACT(YEAR FROM A.RATING_DT_CURRENT) || '��' ||
                   EXTRACT(MONTH FROM A.RATING_DT_CURRENT) || '��' ||
                   EXTRACT(DAY FROM A.RATING_DT_CURRENT) || '��' || ' ' ||
                   V_WARNING_TITLE_4_1 || '' || COALESCE(RATING_CURRENT, '') || '(' ||
                   TO_CHAR(A.RATING_DT_CURRENT, 'YYYY/MM/DD') ||
                   V_WARNING_TITLE_4_2 || ROW_NUMBER() OVER(PARTITION BY A.COMPANY_ID, A.CREDIT_ORG_NM ORDER BY A.RATING_DT_CURRENT , A.UPDT_DT ASC) || V_WARNING_TITLE_4_3 || COALESCE(A.CREDIT_ORG_NM, '') AS WARNING_TITLE,

                   A.COMPANY_NM || EXTRACT(YEAR FROM A.RATING_DT_CURRENT) || '��' ||
                   EXTRACT(MONTH FROM A.RATING_DT_CURRENT) || '��' ||
                   EXTRACT(DAY FROM A.RATING_DT_CURRENT) || '��' || ' ' ||
                   CHR(10) || '��ҵ�ⲿ������' || COALESCE(RATING_PREV, '') || '(' ||
                   TO_CHAR(A.RATING_DT_PREV, 'YYYY/MM/DD') || ')' || '�µ�Ϊ' || '' ||
                   COALESCE(RATING_CURRENT, '') || '(' ||
                   TO_CHAR(A.RATING_DT_CURRENT, 'YYYY/MM/DD') || ')' ||
                   ',�µ�����Ϊ' || (NVL(B.RATING_RNK, C.RATING_RNK) -
                   NVL(D.RATING_RNK, E.RATING_RNK)) || '��, �˴��µ�Ϊ�����ڵ�' ||
                   ROW_NUMBER() OVER(PARTITION BY A.COMPANY_ID, A.CREDIT_ORG_NM ORDER BY A.RATING_DT_CURRENT , A.UPDT_DT ASC) || '���µ�, չ��Ϊ' || COALESCE(RATE_FWD_CURRENT, '��') || ', ��������Ϊ' || COALESCE(A.CREDIT_ORG_NM, '') AS WARNING_CONTENT,
                   ROW_NUMBER() OVER(PARTITION BY A.COMPANY_ID, A.CREDIT_ORG_NM ORDER BY A.RATING_DT_CURRENT DESC , A.UPDT_DT DESC) as TMP_CNT
              FROM COMPY_CREDITRATING_INFO A
              LEFT JOIN LKP_RATING_CODE_LIST B
                ON B.RATING_CODE = A.RATING_CURRENT
              LEFT JOIN LKP_RATING_CODE_LIST C
                ON C.RATING_CODE_MOODY = A.RATING_CURRENT
              LEFT JOIN LKP_RATING_CODE_LIST D
                ON D.RATING_CODE = A.RATING_PREV
              LEFT JOIN LKP_RATING_CODE_LIST E
                ON E.RATING_CODE_MOODY = A.RATING_PREV
             WHERE A.RATING_DT_CURRENT >=
                   ADD_MONTHS(SYSDATE, V_RATING_DT_CURRENT_4)
               AND A.CREDITRATING = V_CREDITRATING_4
               -- AND A.UPDT_DT > V_UPDT_DT   modify by raylee 2017-12-22 10:14:53
               -- BELOW ADD BY RAYLEE 2017-12-22 10:14:5
               AND EXISTS(
               SELECT * FROM COMPY_CREDITRATING_INFO T
                 WHERE T.COMPANY_ID = A.COMPANY_ID
                   AND T.UPDT_DT > V_UPDT_DT)) RET
      LEFT JOIN WARNING_REGULATION A1
        ON A1.REGULATION_NM = V_REGULATION_NM_4
      LEFT JOIN LKP_WARNING_SCORE A2
        ON A2.MIN_VAL <= A1.WARNING_SCORE
       AND A2.MAX_VAL > A1.WARNING_SCORE
       AND A2.ISDEL = 0
     WHERE (CNT >= V_CNT_5 OR (CNT < V_CNT_4 AND DESC_LVL >= V_DESC_LVL_4))
      AND RET.UPDT_DT > V_UPDT_DT -- ֻչʾȫ������������ 2017-12-25 16:43:43
      AND TMP_CNT = 1 -- ֻչʾ���µ�һ������
      ;
  V_INSERT_COUNT := V_INSERT_COUNT + SQL%ROWCOUNT;
  COMMIT;
  --����ʱ��
  V_END_DT := SYSDATE;

  --�������ݵ�LOG����
  V_EXEC_STEP := 'STEP6 �������ݵ�LOG����';
  INSERT INTO ETL_TGT_LOADLOG
    (LOADLOG_SID,
     BATCH_SID,
     PROCESS_NM,
     ORIG_RECORD_COUNT,
     DUP_RECORD_COUNT,
     INSERT_COUNT,
     UPDT_COUNT,
     START_DT,
     END_DT,
     START_ROWID,
     END_ROWID)
  VALUES
    (SEQ_ETL_TGT_LOADLOG.NEXTVAL,
     0,
     V_TASK_NAME,
     V_ORIG_RECORD_COUNT,
     V_DUP_RECORD_COUNT,
     V_INSERT_COUNT,
     NVL(V_UPDT_COUNT, 0),
     V_START_DT,
     V_END_DT,
     V_START_ROWID,
     V_END_ROWID);
  COMMIT;

  --������
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    V_ERROR_CD      := SQLCODE;
    V_ERROR_MESSAGE := V_EXEC_STEP || SUBSTR(SQLERRM, 1, 900);
    DBMS_OUTPUT.PUT_LINE('failed! ERROR:' || V_ERROR_CD || ' ,' ||
                         V_ERROR_MESSAGE);
    RAISE_APPLICATION_ERROR(-20021, V_ERROR_MESSAGE);
    RETURN;

    COMMIT;

END SP_WARNINGS_CREDITRATING;
/

prompt
prompt Creating procedure SP_WARNINGS_FINANAUDIT
prompt =========================================
prompt
CREATE OR REPLACE PROCEDURE sp_warnings_finanaudit IS
  /*************************************
  �洢���̣�sp_warnings_finanaudit
  ����ʱ�䣺2017/11/28
  �� �� �ˣ�ZhangCong
  Դ    ��COMPY_FINANAUDIT(��ҵ�Ʊ���Ʊ�)
  Ŀ �� ��TMP_COMPY_WARNINGS(��ҵԤ���ź���ʱ��)
  ��    �ܣ�ˢ��ÿ�ո��µĲƱ�������
             1.���߱������
             2.���߷����
             3.�޷�����������

  ************************************/

  --------------------------------������־����--------------------------------------
  v_error_cd          VARCHAR2(100);
  v_error_message     VARCHAR2(1000);
  v_task_name         etl_tgt_loadlog.process_nm%TYPE; --��������
  v_updt_dt           etl_tgt_loadlog.end_dt%TYPE; --�ϴ�ͬ������ʱ��
  v_start_dt          etl_tgt_loadlog.start_dt%TYPE; --��ʼʱ��
  v_end_dt            etl_tgt_loadlog.end_dt%TYPE; --����ʱ��
  v_start_rowid       etl_tgt_loadlog.start_rowid%TYPE; --��ʼ�к�
  v_end_rowid         etl_tgt_loadlog.end_rowid%TYPE; --��ֹ�к�
  v_insert_count      etl_tgt_loadlog.insert_count%TYPE; --�����¼��
  v_updt_count        etl_tgt_loadlog.updt_count%TYPE; --���¼�¼��
  v_orig_record_count etl_tgt_loadlog.orig_record_count%TYPE; --ԭʼ�ļ�¼��
  v_dup_record_count  etl_tgt_loadlog.dup_record_count%TYPE; --�ظ��ļ�¼��
  v_batch_sid         etl_tgt_loadlog.batch_sid%TYPE := 0; --���κ�

  --------------------------------����ҵ�����-------------------------------------
  v_warn_updt_by   tmp_compy_warnings.updt_by%TYPE := 0; --������
  v_warn_updt_dt   tmp_compy_warnings.updt_dt%TYPE := systimestamp; --����ʱ��
  v_isdel          tmp_compy_warnings.isdel%TYPE := 0; --�Ƿ�ɾ��
  v_status_flag    tmp_compy_warnings.status_flag%TYPE := 0; --����״̬ (0-δ���� 1 -�Ѵ��� LKP_CONSTANT WHERE CONSTANT_TYPE=101)
  v_warning_type   compy_warnings.warning_type%TYPE := '-1'; --������ (1 ����; -1����)
  v_warn_constant1 lkp_constant.constant_nm%TYPE; --���������Ԥ���ȼ�
  v_warn_constant2 lkp_constant.constant_nm%TYPE;
  v_warn_constant3 lkp_constant.constant_nm%TYPE;
  v_regulation_nm1 warning_regulation.regulation_nm%TYPE; --������ƥ��Ԥ���÷ֵ�Ԥ����
  v_regulation_nm2 warning_regulation.regulation_nm%TYPE;
  v_regulation_nm3 warning_regulation.regulation_nm%TYPE;
  v_subject_type   tmp_compy_warnings.subject_type%TYPE := 0;--Ԥ����������(0-��ҵ��1-ծȯ)

BEGIN

  --��������
  v_task_name := 'SP_WARNINGS_FINANAUDIT';

  --��ȡ�ϴ�ͬ�����ݵ�ʱ��
  SELECT nvl(MAX(end_dt), to_date('1900-1-1', 'yyyy-mm-dd'))
    INTO v_updt_dt
    FROM etl_tgt_loadlog
   WHERE process_nm = v_task_name;

  --������ʼ��
  v_start_dt := SYSDATE;

  --��lkp_constant��constant_type = 35��constant_nm��ͬ
  v_warn_constant1 := '�������';
  v_warn_constant2 := '�����';
  v_warn_constant3 := '�޷�(�ܾ�)��ʾ���';

  --��warning_regulation��regulation_nm��ͬ
  v_regulation_nm1 := '�������';
  v_regulation_nm2 := '�����';
  v_regulation_nm3 := '�޷�(�ܾ�)��ʾ���';

  --��ȡ��ʼ��¼��
  SELECT COUNT(*)
    INTO v_orig_record_count
    FROM compy_finanaudit t
    JOIN lkp_charcode k
      ON (t.audit_view_typeid = k.constant_id AND k.constant_type = 35 AND
         k.constant_nm IN
         (v_warn_constant1, v_warn_constant2, v_warn_constant3) AND
         k.isdel = 0)
   WHERE t.isdel = 0
     AND t.updt_dt > v_updt_dt;

  --���Ʊ�����������Ԥ���ܱ�
  INSERT INTO tmp_compy_warnings
    (SUBJECT_ID,--2. Ԥ���������
     SUBJECT_TYPE,--Ԥ����������
     notice_dt, --3. Ԥ���ź�ʱ��
     warning_type, --4. ������
     severity, --5. ���س̶�
     warning_score, --6. �źŷ�ֵ
     warning_title, --7. Ԥ������
     type_id, --8. �źŷ���
     status_flag, --9. ����״̬
     warning_content,--10.Ԥ������
     isdel, --�Ƿ�ɾ��
     updt_by, --������
     src_cd, --Դϵͳ
     updt_dt) --����ʱ��

    SELECT mid.company_id, --2. Ԥ���������
           v_subject_type,
           mid.audit_dt, --3. Ԥ���ź�ʱ��
           v_warning_type, --4. ������
           w.importance, --5. ���س̶�
           g.warning_score, --6. �źŷ�ֵ
           cbs.company_nm||to_char(audit_dt,'yyyy')||'�������ƻ������', --7. Ԥ������
           e.id, --8. �źŷ���
           v_status_flag, --9. ����״̬
           mid.audit_view AS warning_content,--10.Ԥ������
           v_isdel, --�Ƿ�ɾ��
           v_warn_updt_by, --������
           nvl(mid.src_cd,'CSCS'), --Դϵͳ
           v_warn_updt_dt --����ʱ��

      FROM (SELECT t.company_id,
                   t.audit_dt,
                   t.audit_view,
                   t.src_cd,
                   CASE
                     WHEN k.constant_nm = v_warn_constant1 THEN
                      v_regulation_nm1
                     WHEN k.constant_nm = v_warn_constant2 THEN
                      v_regulation_nm2
                     WHEN k.constant_nm = v_warn_constant3 THEN
                      v_regulation_nm3
                     ELSE
                      NULL
                   END AS regulation_nm,
                   row_number() over(PARTITION BY t.company_id, trunc(t.audit_dt), k.constant_nm ORDER BY t.audit_dt DESC) AS rn
              FROM compy_finanaudit t
              JOIN lkp_charcode k
                ON (t.audit_view_typeid = k.constant_id AND k.constant_type = 35 AND
                   k.constant_nm IN
                   (v_warn_constant1, v_warn_constant2, v_warn_constant3) AND
                   k.isdel = 0)
             WHERE t.isdel = 0
               AND t.updt_dt > v_updt_dt) mid
      LEFT JOIN warning_regulation g
        ON (mid.regulation_nm = g.regulation_nm)
      LEFT JOIN lkp_warning_score w
        ON (g.warning_score < w.max_val AND g.warning_score >= w.min_val AND
           w.isdel = 0)
      LEFT JOIN compy_event_type e
        ON (g.regulation_type = e.type_name)
      JOIN compy_basicinfo cbs
        ON (mid.company_id = cbs.company_id)
     WHERE mid.rn = 1;

  v_insert_count := SQL%ROWCOUNT;
  v_updt_count   := 0;

  --����ʱ��
  v_end_dt := SYSDATE;

  COMMIT;

  --�������ݵ�LOG����

  INSERT INTO etl_tgt_loadlog
    (loadlog_sid,
     batch_sid,
     process_nm,
     orig_record_count,
     dup_record_count,
     insert_count,
     updt_count,
     start_dt,
     end_dt,
     start_rowid,
     end_rowid)
    SELECT seq_etl_tgt_loadlog.nextval,
           v_batch_sid,
           v_task_name,
           v_orig_record_count,
           v_dup_record_count,
           v_insert_count,
           v_updt_count,
           v_start_dt,
           v_end_dt,
           v_start_rowid,
           v_end_rowid
      FROM dual;

  COMMIT;

  --������
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    v_error_cd      := SQLCODE;
    v_error_message := substr(SQLERRM, 1, 1000);
    dbms_output.put_line('failed! ERROR:' || v_error_cd || ' ,' ||
                         v_error_message);
    raise_application_error(-20021, v_error_message);
    RETURN;

    COMMIT;

END sp_warnings_finanaudit;
/

prompt
prompt Creating procedure SP_ZLD_RATING_MODEL_IMPORT
prompt =============================================
prompt
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
     GROUP BY parent_rm_name , NAME
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
    SELECT DISTINCT
           v_task_name,
           '�����ظ�',
           d.rm_name,
           CASE
             WHEN COUNT(*) > 1 THEN
              'У׼����ҳ ' || rm_name || '(formular=''' || formular || ''')' || '�����ظ���������' ||
              rm_name || 'ģ��'
           END AS error_msg,
           v_creation_time
      FROM zld_rating_calc_pd_ref d
     GROUP BY d.rm_name,d.formular
    HAVING COUNT(*) > 1;

  --ģ��ָ���ظ�����
  INSERT INTO zld_rating_model_errorlog
    (task_name, error_type, model_name, error_msg, create_time)
    SELECT DISTINCT
           v_task_name,
           '�����ظ�',
           model_name,
           CASE
             WHEN COUNT(*) > 1 THEN
              'ģ��ָ��ҳ�� ģ��:' || model_name || ' ��ģ��:' || sub_model_name || ' ָ��:' || ft_code ||
              '�������ظ���������' || model_name || 'ģ��'
           END AS error_msg,
           v_creation_time
      FROM zld_rating_model_factor
     GROUP BY model_name,sub_model_name,ft_code
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

  INSERT INTO zld_rating_model_errorlog
    (task_name, error_type, model_name, error_msg, create_time)
    SELECT v_task_name, '����ȱʧ', model_name, error_msg, v_creation_time
      FROM (SELECT DISTINCT e.model_name,
                            CASE
                              WHEN c.name IS NULL THEN
                               'ָ�궨��ҳ��,ģ��:' || e.model_name || '  ��ģ��:' || e.sub_model_name ||
                               '����������ģ��ҳ��'
                            END AS error_msg
              FROM zld_rating_model_factor e
              LEFT JOIN zld_rating_model_sub_model c
                ON (c.parent_rm_name = e.model_name AND c.name = e.sub_model_name))
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
       WHERE rms.parent_rm_id IN
             (SELECT rm.id FROM rating_model rm WHERE rm.name = i.model_name);

      --����ģ��ɾ����Ӧ�����
      DELETE FROM rating_calc_pd_ref rpf
       WHERE rpf.rm_id IN (SELECT id FROM rating_model WHERE NAME = i.model_name);

      --���ݳ���ɾ����Ӧ����ģ��ӳ��
      DELETE FROM rating_model_exposure_xw xw WHERE xw.exposure_sid = i.exposure_sid;

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
               1 AS priority
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

  v_task_name := 'ov_error';

  OPEN ov_error_msg FOR
    SELECT t.error_type, t.error_msg
      FROM zld_rating_model_errorlog t
     WHERE t.create_time >= iv_date
      AND rownum <= 1;

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


prompt Done
spool off
set define on
