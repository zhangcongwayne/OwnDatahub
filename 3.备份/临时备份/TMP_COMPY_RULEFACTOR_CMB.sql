-- Create table
create table TMP_COMPY_RULEFACTOR_CMB
(
  company_id     NUMBER(16) not null,
  factor_cd      VARCHAR2(100) not null,
  factor_value   VARCHAR2(300),
  isdel          INTEGER not null,
  src_company_cd VARCHAR2(60),
  src_cd         VARCHAR2(10) not null,
  updt_by        NUMBER(16) not null,
  updt_dt        TIMESTAMP(6) not null,
  record_sid     NUMBER(16),
  loadlog_sid    INTEGER,
  rnk            NUMBER
)
tablespace USERS
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 80K
    next 1M
    minextents 1
    maxextents unlimited
  );
-- Add comments to the columns 
comment on column TMP_COMPY_RULEFACTOR_CMB.company_id
  is '��ҵ��ʶ��';
comment on column TMP_COMPY_RULEFACTOR_CMB.factor_cd
  is 'ָ�����';
comment on column TMP_COMPY_RULEFACTOR_CMB.factor_value
  is 'ָ��ֵ';
comment on column TMP_COMPY_RULEFACTOR_CMB.isdel
  is '�Ƿ�ɾ��';
comment on column TMP_COMPY_RULEFACTOR_CMB.src_company_cd
  is 'Դ��ҵ����';
comment on column TMP_COMPY_RULEFACTOR_CMB.src_cd
  is 'Դϵͳ';
comment on column TMP_COMPY_RULEFACTOR_CMB.updt_by
  is '������';
comment on column TMP_COMPY_RULEFACTOR_CMB.updt_dt
  is '����ʱ��';
comment on column TMP_COMPY_RULEFACTOR_CMB.record_sid
  is '��ˮ�� ';
comment on column TMP_COMPY_RULEFACTOR_CMB.loadlog_sid
  is '��־�� ';
comment on column TMP_COMPY_RULEFACTOR_CMB.rnk
  is '������';
