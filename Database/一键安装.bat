@echo off

TITLE ������������ݿ� �Զ���װ��...��ע�⣺��װ����������ر�

md D:\���ݿ�\����ƽ̨

set rootPath=1.���ݿ�ű�\
osql -E -i "%rootPath%1.���ݿ�ɾ��.sql"
osql -E -i "%rootPath%1_1_��վ��ű�.sql"
osql -E -i "%rootPath%1_2_��̨��ű�.sql"
osql -E -i "%rootPath%2_1_��վ��ű�.sql"
osql -E -i "%rootPath%2_2_��̨��ű�.sql"

set rootPath=2.���ݽű�\
osql -E -i "%rootPath%��ֵ����.sql"
osql -E -i "%rootPath%��̨����.sql"
osql -E -i "%rootPath%ʵ������.sql"
osql -E -i "%rootPath%�ƹ�����.sql"
osql -E -i "%rootPath%�ݵ�����.sql"
osql -E -i "%rootPath%����ҳ��.sql"
osql -E -i "%rootPath%վ������.sql"
osql -E -i "%rootPath%ϵͳ���.sql"
osql -E -i "%rootPath%��վ����.sql"
osql -E -i "%rootPath%ת������.sql"
osql -E -i "%rootPath%��Ա����.sql"

set rootPath=3.�洢����\��ҵ�ű�\
osql -E -i "%rootPath%ÿ��ͳ��(��ҵ).sql"
osql -E -i "%rootPath%ͳ�����˰��(��ҵ).sql"
osql -E -i "%rootPath%ͳ�ƴ����ֵ(��ҵ).sql"

set rootPath=3.�洢����\��������\
osql -d RYAccountsDB -E  -n -i "%rootPath%��ҳ����.sql"
osql -d RYGameMatchDB -E  -n -i "%rootPath%��ҳ����.sql"
osql -d RYGameScoreDB -E  -n -i "%rootPath%��ҳ����.sql"
osql -d RYNativeWebDB -E  -n -i "%rootPath%��ҳ����.sql"
osql -d RYPlatformDB -E  -n -i "%rootPath%��ҳ����.sql"
osql -d RYPlatformManagerDB -E  -n -i "%rootPath%��ҳ����.sql"
osql -d RYRecordDB -E  -n -i "%rootPath%��ҳ����.sql"
osql -d RYTreasureDB -E  -n -i "%rootPath%��ҳ����.sql"

osql -d RYAccountsDB -E  -n -i "%rootPath%���ַ���.sql"
osql -d RYGameMatchDB -E  -n -i "%rootPath%���ַ���.sql"
osql -d RYGameScoreDB -E  -n -i "%rootPath%���ַ���.sql"
osql -d RYNativeWebDB -E  -n -i "%rootPath%���ַ���.sql"
osql -d RYPlatformDB -E  -n -i "%rootPath%���ַ���.sql"
osql -d RYPlatformManagerDB -E  -n -i "%rootPath%���ַ���.sql"
osql -d RYRecordDB -E  -n -i "%rootPath%���ַ���.sql"
osql -d RYTreasureDB -E  -n -i "%rootPath%���ַ���.sql"

set rootPath=3.�洢����\����\
osql -E -i "%rootPath%��ѯָ����ҵĴ������.sql"

set rootPath=3.�洢����\ǰ̨�ű�\�������ݿ�\
osql -E -i "%rootPath%�Ƽ���Ϸ.sql"
osql -E -i "%rootPath%����Ʒ.sql"

set rootPath=3.�洢����\ǰ̨�ű�\�������ݿ�\
osql -E -i "%rootPath%��������.sql"

set rootPath=3.�洢����\ǰ̨�ű�\�û����ݿ�\
osql -E -i "%rootPath%�޸�����.sql"
osql -E -i "%rootPath%�޸�����.sql"
osql -E -i "%rootPath%�̶�����.sql"
osql -E -i "%rootPath%���ƶһ�.sql"
osql -E -i "%rootPath%ÿ��ǩ��.sql"
osql -E -i "%rootPath%�û�ȫ����Ϣ.sql"
osql -E -i "%rootPath%�û������.sql"
osql -E -i "%rootPath%�û�ע��.sql"
osql -E -i "%rootPath%�û���¼.sql"
osql -E -i "%rootPath%��ȡ�û���Ϣ.sql"
osql -E -i "%rootPath%�˻�����.sql"
osql -E -i "%rootPath%��������.sql"
osql -E -i "%rootPath%�����һ�.sql"
osql -E -i "%rootPath%�Զ�ͷ��.sql"

set rootPath=3.�洢����\ǰ̨�ű�\�������ݿ�\
osql -E -i "%rootPath%��������.sql"
osql -E -i "%rootPath%��������.sql"

set rootPath=3.�洢����\ǰ̨�ű�\��վ���ݿ�\
osql -E -i "%rootPath%�������.sql"
osql -E -i "%rootPath%��������.sql"
osql -E -i "%rootPath%��ȡ����.sql"
osql -E -i "%rootPath%����Ʒ.sql"
osql -E -i "%rootPath%���ⷴ��.sql"

set rootPath=3.�洢����\ǰ̨�ű�\������ݿ�\
osql -E -i "%rootPath%�������.sql"
osql -E -i "%rootPath%���߳�ֵ.sql"
osql -E -i "%rootPath%���߶���.sql"
osql -E -i "%rootPath%ʵ����ֵ.sql"
osql -E -i "%rootPath%�ƹ�����.sql"
osql -E -i "%rootPath%�ƹ���Ϣ.sql"
osql -E -i "%rootPath%ƻ����ֵ.sql"
osql -E -i "%rootPath%���ȡ��.sql"
osql -E -i "%rootPath%��Ҵ��.sql"
osql -E -i "%rootPath%���ת��.sql"
osql -E -i "%rootPath%���γ�ֵ.sql"
osql -E -i "%rootPath%��������.sql"
osql -E -i "%rootPath%ת�̳齱.sql"

set rootPath=3.�洢����\��̨�ű�\�ʺſ�\
osql -E -i "%rootPath%��������IP.sql"
osql -E -i "%rootPath%�������ƻ�����.sql"
osql -E -i "%rootPath%�����û�.sql"
osql -E -i "%rootPath%ע��IPͳ��.sql"
osql -E -i "%rootPath%ע�������ͳ��.sql"
osql -E -i "%rootPath%����û�.sql"
osql -E -i "%rootPath%��������.sql"

set rootPath=3.�洢����\��̨�ű�\ƽ̨��\
osql -E -i "%rootPath%����ͳ��.sql"

set rootPath=3.�洢����\��̨�ű�\���ݷ���\
osql -E -i "%rootPath%��ֵͳ��.sql"
osql -E -i "%rootPath%����ͳ��.sql"
osql -E -i "%rootPath%��Ծͳ��.sql"
osql -E -i "%rootPath%�û�ͳ��.sql"
osql -E -i "%rootPath%��ҷֲ�.sql"

set rootPath=3.�洢����\��̨�ű�\Ȩ�޿�\
osql -E -i "%rootPath%Ȩ�޼���.sql"
osql -E -i "%rootPath%�û������.sql"
osql -E -i "%rootPath%����Ա��¼.sql"
osql -E -i "%rootPath%�˵�����.sql"

set rootPath=3.�洢����\��̨�ű�\������\
osql -E -i "%rootPath%��������.sql"

set rootPath=3.�洢����\��̨�ű�\���ֿ�\
osql -E -i "%rootPath%�������.sql"
osql -E -i "%rootPath%��������.sql"
osql -E -i "%rootPath%���ͻ���.sql"

set rootPath=3.�洢����\��̨�ű�\��վ��\
osql -E -i "%rootPath%ɾ��Ʒ��.sql"

set rootPath=3.�洢����\��̨�ű�\��¼��\
osql -E -i "%rootPath%���ͻ�Ա.sql"
osql -E -i "%rootPath%���;���.sql"
osql -E -i "%rootPath%���ͽ��.sql"
osql -E -i "%rootPath%��������.sql"

set rootPath=3.�洢����\��̨�ű�\��ҿ�\
osql -E -i "%rootPath%����ֳ�����.sql"
osql -E -i "%rootPath%��ɾ����.sql"
osql -E -i "%rootPath%ʵ�����.sql"
osql -E -i "%rootPath%ʵ��ͳ��.sql"
osql -E -i "%rootPath%���ݻ���.sql"
osql -E -i "%rootPath%����ʵ��.sql"
osql -E -i "%rootPath%��Ϸ��¼.sql"
osql -E -i "%rootPath%ͳ�Ƽ�¼.sql"
osql -E -i "%rootPath%���ͽ��.sql"
osql -E -i "%rootPath%ת��˰��.sql"
osql -E -i "%rootPath%ͳ�ƴ����ֵ(�ֹ�ִ��).sql"
osql -E -i "%rootPath%ͳ�����˰��(�ֹ�ִ��).sql"

set rootPath=4.������ҵ\
osql -E -i "%rootPath%������ҵ.sql"
osql -E -i "%rootPath%�����ֵͳ��.sql"
osql -E -i "%rootPath%˰��ͳ��.sql"

pause

COLOR 0A
CLS
@echo off
CLS
echo ------------------------------
echo.
echo. ���ݿ⽨�����
echo.
echo ------------------------------

pause
