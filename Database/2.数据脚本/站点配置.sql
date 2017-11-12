USE RYNativeWebDB
GO

-- վ������
TRUNCATE TABLE ConfigInfo
GO

SET IDENTITY_INSERT [dbo].[ConfigInfo] ON
INSERT [dbo].[ConfigInfo] ([ConfigID], [ConfigKey], [ConfigName], [ConfigString], [Field1], [Field2], [Field3], [Field4], [Field5], [Field6], [Field7], [Field8], [SortID]) VALUES (1, N'ContactConfig', N'��ϵ��ʽ����', N'����˵��
�ֶ�1���ͷ��绰 
�ֶ�2��������� 
�ֶ�3���ʼ���ַ', N'400-000-7043', N'0755-83547940', N'Sunny@foxuc.cn', N'', N'', N'', N'', N'', 5)
INSERT [dbo].[ConfigInfo] ([ConfigID], [ConfigKey], [ConfigName], [ConfigString], [Field1], [Field2], [Field3], [Field4], [Field5], [Field6], [Field7], [Field8], [SortID]) VALUES (2, N'SiteConfig', N'վ������', N'����˵��
�ֶ�1��վ������
�ֶ�2��վ������ 
�ֶ�3��ͼƬ����(�޸ĺ�30��������Ч)
�ֶ�8����վ�ײ�����', N'����������ҫ��', N'http://ry.foxuc.net', N'http://imagery.foxuc.net', N'', N'', N'', N'', N'Copyright @ 2016 Foxuc.cn , All Rights Reserved.&lt;span&gt;��Ȩ���� �����������Ƽ����޹�˾&lt;/span&gt;&lt;br /&gt;
ICP���֤����B2-20060706 [��ICP��11009383��-4] ������[2012]0873-087��&lt;span&gt;E-MAIL��UCBussiess@foxuc.cn&lt;/span&gt;&lt;br /&gt;', 1)
INSERT [dbo].[ConfigInfo] ([ConfigID], [ConfigKey], [ConfigName], [ConfigString], [Field1], [Field2], [Field3], [Field4], [Field5], [Field6], [Field7], [Field8], [SortID]) VALUES (3, N'GameFullPackageConfig', N'������������', N'�ֶ�1�����ص�ַ
', N'/Download/WHGameFull.exe', N'', N'', N'', N'', N'', N'', N'', 20)
INSERT [dbo].[ConfigInfo] ([ConfigID], [ConfigKey], [ConfigName], [ConfigString], [Field1], [Field2], [Field3], [Field4], [Field5], [Field6], [Field7], [Field8], [SortID]) VALUES (4, N'GameJanePackageConfig', N'�����������', N'�ֶ�1�����ص�ַ
', N'/Download/Plaza.exe', N'', N'', N'', N'', N'', N'', N'', 15)
INSERT [dbo].[ConfigInfo] ([ConfigID], [ConfigKey], [ConfigName], [ConfigString], [Field1], [Field2], [Field3], [Field4], [Field5], [Field6], [Field7], [Field8], [SortID]) VALUES (5, N'EmailConfig', N'��������', N'�ֶ�1�������˺�
�ֶ�2����������
�ֶ�3��SmtpServer�����ṩ��ַsmtp.qq.com�ֶ�4���˿�', N'test@foxuc.com', N'test', N'smtp.qq.com', N'25', N'', N'', N'', N'', 30)
INSERT [dbo].[ConfigInfo] ([ConfigID], [ConfigKey], [ConfigName], [ConfigString], [Field1], [Field2], [Field3], [Field4], [Field5], [Field6], [Field7], [Field8], [SortID]) VALUES (6, N'GameAndroidConfig', N'��׿��������', N'����˵��
�ֶ�1�����ص�ַ 
�ֶ�2�������汾��
�ֶ�3��������ǿ�Ƹ��� 1���� 0����', N'/Download/Plaza.apk', N'V1.0', N'0', N'', N'', N'', N'', N'', 20)
INSERT [dbo].[ConfigInfo] ([ConfigID], [ConfigKey], [ConfigName], [ConfigString], [Field1], [Field2], [Field3], [Field4], [Field5], [Field6], [Field7], [Field8], [SortID]) VALUES (7, N'GameIosConfig', N'ƻ����������', N'����˵��
�ֶ�1�����ص�ַ   
�ֶ�2�������汾�� 
�ֶ�3��������ǿ�Ƹ��� 1���� 0����', N'/Download/Plaza.ipa', N'V1.0', N'0', N'', N'', N'', N'', N'', 15)
INSERT [dbo].[ConfigInfo] ([ConfigID], [ConfigKey], [ConfigName], [ConfigString], [Field1], [Field2], [Field3], [Field4], [Field5], [Field6], [Field7], [Field8], [SortID]) VALUES (8, N'MobilePlatformVersion', N'�ƶ����������', N'����˵��
�ֶ�1������·��   
�ֶ�2�������汾�� 
�ֶ�3����Դ�汾��', N'http://ry.foxuc.com/download/', 0, N'', N'', N'', N'', N'', N'', 0)
SET IDENTITY_INSERT [dbo].[ConfigInfo] OFF

GO