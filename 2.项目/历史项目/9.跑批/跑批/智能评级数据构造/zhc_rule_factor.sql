-- Create table
create table ZHC_RULE_FACTOR
(
  a       VARCHAR2(500),
  b       VARCHAR2(500),
  c       VARCHAR2(500),
  d       VARCHAR2(500),
  e       VARCHAR2(500),
  f       VARCHAR2(500),
  g       NUMBER,
  h       VARCHAR2(500),
  i       VARCHAR2(500),
  j       NUMBER,
  k       NUMBER,
  l       VARCHAR2(500),
  m       VARCHAR2(500),
  n       VARCHAR2(500),
  o       VARCHAR2(500),
  p       VARCHAR2(500),
  q       NUMBER,
  r       NUMBER,
  s       NUMBER(38,10),
  t       NUMBER(38,10),
  u       NUMBER(38,10),
  v       NUMBER(38,10),
  w       NUMBER(38,10),
  x       NUMBER(38,10),
  y       NUMBER(38,10),
  z       VARCHAR2(500),
  aa      VARCHAR2(500),
  updt_dt DATE default sysdate
)
tablespace TBS_CUR_DAT
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
-- Add comments to the columns 
comment on column ZHC_RULE_FACTOR.a
  is '���Ŀͻ���';
comment on column ZHC_RULE_FACTOR.b
  is '��������������';
comment on column ZHC_RULE_FACTOR.c
  is '��������';
comment on column ZHC_RULE_FACTOR.d
  is '��������С��';
comment on column ZHC_RULE_FACTOR.e
  is '����������';
comment on column ZHC_RULE_FACTOR.f
  is '�ⲿ����';
comment on column ZHC_RULE_FACTOR.g
  is '�ͻ������������';
comment on column ZHC_RULE_FACTOR.h
  is '�ͻ����շֲ�';
comment on column ZHC_RULE_FACTOR.i
  is '���ʮ������';
comment on column ZHC_RULE_FACTOR.j
  is '�Ƿ�߷���������';
comment on column ZHC_RULE_FACTOR.k
  is '���Ŷ�������½�_3m';
comment on column ZHC_RULE_FACTOR.l
  is '�������ŷ��շֲ�';
comment on column ZHC_RULE_FACTOR.m
  is '����Ȧ';
comment on column ZHC_RULE_FACTOR.n
  is '�ͻ���ȥһ����ĩ�������������ӵĴ�������_U��';
comment on column ZHC_RULE_FACTOR.o
  is '��ȥһ���������ڼ�¼Y������N������';
comment on column ZHC_RULE_FACTOR.p
  is '��ȥ���������Ƿ����������������';
comment on column ZHC_RULE_FACTOR.q
  is '��ȥ1���Ƿ������������еĲ�����¼';
comment on column ZHC_RULE_FACTOR.r
  is '��ȥ1���Ƿ������������еĹ�ע���¼';
comment on column ZHC_RULE_FACTOR.s
  is '��ͽ��׼۸���ֵ��';
comment on column ZHC_RULE_FACTOR.t
  is '��ȳ��ڽ��';
comment on column ZHC_RULE_FACTOR.u
  is '�����';
comment on column ZHC_RULE_FACTOR.v
  is '�����˻���6�����¾����';
comment on column ZHC_RULE_FACTOR.w
  is '�ͻ���ȥһ����ĩ�������������ӵĴ���_U��';
comment on column ZHC_RULE_FACTOR.x
  is '���ⵣ�����';
comment on column ZHC_RULE_FACTOR.y
  is '����������ⵣ�����';
comment on column ZHC_RULE_FACTOR.z
  is '���';
comment on column ZHC_RULE_FACTOR.aa
  is '��ά����÷�';
