CREATE TABLE IF NOT EXISTS `t_file_manage`
(
    `id`          bigint(20)                   NOT NULL AUTO_INCREMENT,
    `file_name`   varchar(64) COLLATE utf8_bin NOT NULL COMMENT '文件名称',
    `file_size`   varchar(64) COLLATE utf8_bin          DEFAULT NULL COMMENT '文件大小：2MB',
    `file_ext`    varchar(16) COLLATE utf8_bin          DEFAULT NULL COMMENT '文件后缀',
    `file_type`   tinyint(4)                   NOT NULL COMMENT '文件类型：0-脚本文件 1-数据文件 2-脚本jar文件 3-jmeter ext jar',
    `file_extend` text COLLATE utf8_bin COMMENT '{\n  “dataCount”:”数据量”,\n  “isSplit”:”是否拆分”,\n  “topic”:”MQ主题”,\n  “nameServer”:”mq nameServer”,\n}',
    `customer_id` bigint(20)                   NOT NULL COMMENT '客户id（当前登录用户对应的admin的id，数据隔离使用）',
    `upload_time` timestamp(3)                 NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3) COMMENT '上传时间',
    `upload_path` varchar(128) COLLATE utf8_bin         DEFAULT NULL COMMENT '上传路径：相对路径',
    `is_deleted`  tinyint(1)                   NOT NULL DEFAULT '0',
    `gmt_create`  datetime(3)                  NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `gmt_update`  datetime(3)                  NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
    PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8
  COLLATE = utf8_bin;

CREATE TABLE IF NOT EXISTS `t_script_file_ref`
(
    `id`               bigint(20) NOT NULL AUTO_INCREMENT,
    `file_id`          bigint(20) NOT NULL COMMENT '文件id',
    `script_deploy_id` bigint(20) NOT NULL COMMENT '脚本发布id',
    `gmt_create`       datetime(3) DEFAULT CURRENT_TIMESTAMP(3),
    `gmt_update`       datetime(3) DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;

CREATE TABLE IF NOT EXISTS `t_script_manage`
(
    `id`             bigint(20)  NOT NULL AUTO_INCREMENT,
    `name`           varchar(64) NOT NULL COMMENT '名称',
    `gmt_create`     datetime(3)          DEFAULT CURRENT_TIMESTAMP(3) COMMENT '创建时间',
    `gmt_update`     datetime(3)          DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3) COMMENT '更新时间',
    `customer_id`    bigint(20)           DEFAULT NULL COMMENT '租户id',
    `user_id`        bigint(20)           DEFAULT NULL COMMENT '用户id',
    `script_version` int(11)     NOT NULL DEFAULT '0',
    `is_deleted`     tinyint(1)           DEFAULT '0',
    `feature`        longtext COMMENT '拓展字段',
    PRIMARY KEY (`id`),
    UNIQUE KEY `name` (`name`) USING BTREE COMMENT '名称需要唯一'
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;

CREATE TABLE IF NOT EXISTS `t_script_manage_deploy`
(
    `id`             bigint(20)  NOT NULL AUTO_INCREMENT,
    `script_id`      bigint(20)           DEFAULT NULL,
    `name`           varchar(64) NOT NULL COMMENT '名称',
    `ref_type`       varchar(16)          DEFAULT NULL COMMENT '关联类型(业务活动)',
    `ref_value`      varchar(64)          DEFAULT NULL COMMENT '关联值(活动id)',
    `type`           tinyint(4)  NOT NULL COMMENT '脚本类型;0为jmeter脚本',
    `status`         tinyint(4)  NOT NULL COMMENT '0代表新建，1代表调试通过',
    `gmt_create`     datetime(3)          DEFAULT CURRENT_TIMESTAMP(3) COMMENT '创建时间',
    `gmt_update`     datetime(3)          DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3) COMMENT '更新时间',
    `script_version` int(11)     NOT NULL DEFAULT '0',
    `is_deleted`     tinyint(1)           DEFAULT '0',
    `feature`        longtext COMMENT '拓展字段',
    PRIMARY KEY (`id`),
    UNIQUE KEY `name_version` (`name`, `script_version`) COMMENT '名称加版本需要唯一'
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;

CREATE TABLE IF NOT EXISTS `t_script_tag_ref`
(
    `id`         bigint(20) NOT NULL AUTO_INCREMENT,
    `script_id`  bigint(20) NOT NULL COMMENT '场景发布id',
    `tag_id`     bigint(20) NOT NULL COMMENT '标签id',
    `gmt_create` datetime(3) DEFAULT CURRENT_TIMESTAMP(3),
    `gmt_update` datetime(3) DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;

CREATE TABLE IF NOT EXISTS `t_tag_manage`
(
    `id`         bigint(20)  NOT NULL AUTO_INCREMENT,
    `tag_name`   varchar(64) NOT NULL COMMENT '标签名称',
    `tag_type`   tinyint(4)           DEFAULT NULL COMMENT '标签类型;0为脚本标签',
    `tag_status` tinyint(4)  NOT NULL DEFAULT '0' COMMENT '标签状态;0为可用',
    `gmt_create` datetime(3)          DEFAULT CURRENT_TIMESTAMP(3),
    `gmt_update` datetime(3)          DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;


-- 权限相关 4.5.1
-- 角色表
DROP PROCEDURE IF EXISTS change_field;

DELIMITER $$

CREATE PROCEDURE change_field()

BEGIN

DECLARE count1 INT;

SET count1 = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_schema = DATABASE() AND TABLE_NAME = 't_tro_role' AND COLUMN_NAME = 'application_id');

IF count1 > 0 THEN

alter table t_tro_role
    modify column application_id bigint(20) DEFAULT NULL COMMENT '应用id(4.5.1版本后废弃不用)';

END IF;


SET count1 = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_schema = DATABASE() AND TABLE_NAME = 't_tro_role' AND COLUMN_NAME = 'customer_id');

IF count1 = 0 THEN

alter table t_tro_role
    add column `customer_id` BIGINT(20) COMMENT '租户id' after features;

END IF;


SET count1 = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_schema = DATABASE() AND TABLE_NAME = 't_tro_role' AND COLUMN_NAME = 'alias');

IF count1 > 0 THEN

alter table t_tro_role
    modify column `alias` varchar(255) DEFAULT NULL COMMENT '角色别名';

END IF;


SET count1 = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_schema = DATABASE() AND TABLE_NAME = 't_tro_role' AND COLUMN_NAME = 'code');

IF count1 > 0 THEN

alter table t_tro_role
    modify column `code` varchar(20) DEFAULT NULL COMMENT '角色编码';

END IF;


SET count1 = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_schema = DATABASE() AND TABLE_NAME = 't_tro_role' AND COLUMN_NAME = 'description');

IF count1 > 0 THEN

alter table t_tro_role
    modify column `description` varchar(255) DEFAULT NULL COMMENT '角色描述';

END IF;


END $$

DELIMITER ;

CALL change_field();

DROP PROCEDURE IF EXISTS change_field;
-- 权限相关 4.5.1
-- 角色表添加字段完成

-- 备份表
CREATE TABLE IF NOT EXISTS t_tro_role_copy LIKE t_tro_role;
INSERT IGNORE INTO t_tro_role_copy SELECT * FROM t_tro_role;
-- 备份表结束

-- 清除表 t_tro_role
DROP PROCEDURE IF EXISTS delete_table;

DELIMITER $$

CREATE PROCEDURE delete_table()

BEGIN

DECLARE count1 INT;

SET count1 = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
WHERE table_schema = DATABASE() AND TABLE_NAME = 't_tro_role');

IF count1 > 0 THEN

delete from t_tro_role;

END IF;

END $$

DELIMITER ;

CALL delete_table();

DROP PROCEDURE IF EXISTS delete_table;
-- 清除表 t_tro_role 结束


-- 备份表
CREATE TABLE IF NOT EXISTS t_tro_resource_copy LIKE t_tro_resource;
INSERT IGNORE INTO t_tro_resource_copy SELECT * FROM t_tro_resource;
-- 备份表结束

-- 资源表导入sql文件，原表重命名为备份表
-- 清除表 t_tro_resource
DROP PROCEDURE IF EXISTS delete_table;

DELIMITER $$

CREATE PROCEDURE delete_table()

BEGIN

DECLARE count1 INT;

SET count1 = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
WHERE table_schema = DATABASE() AND TABLE_NAME = 't_tro_resource');

IF count1 > 0 THEN

delete from t_tro_resource;

END IF;

END $$

DELIMITER ;

CALL delete_table();

DROP PROCEDURE IF EXISTS delete_table;
-- 清除表 t_tro_resource 结束

-- t_tro_resource 修改字段
DROP PROCEDURE IF EXISTS change_field;

DELIMITER $$

CREATE PROCEDURE change_field()

BEGIN

DECLARE count1 INT;

SET count1 = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_schema = DATABASE() AND TABLE_NAME = 't_tro_resource' AND COLUMN_NAME = 'action');

IF count1 = 0 THEN

alter table t_tro_resource
    add column `action` varchar(255) COMMENT '操作权限: 0:all,1:query,2:create,3:update,4:delete,5:start,6:stop,7:export,8:enable,9:disable' after sequence;

END IF;


SET count1 = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_schema = DATABASE() AND TABLE_NAME = 't_tro_resource' AND COLUMN_NAME = 'customer_id');

IF count1 = 0 THEN

alter table t_tro_resource
    add column customer_id bigint(20) COMMENT '租户id' after features;

END IF;


END $$

DELIMITER ;

CALL change_field();

DROP PROCEDURE IF EXISTS change_field;
-- t_tro_resource 修改字段结束

INSERT IGNORE INTO `t_tro_resource`(`id`, `parent_id`, `type`, `code`, `name`, `alias`, `value`, `sequence`, `action`,
                                     `features`, `customer_id`, `remark`, `create_time`, `update_time`, `is_deleted`)
VALUES (1, NULL, 0, 'dashboard', '系统概览', '',
        '[\"/api/scenemanage/list\",\"/api/report/listReport\",\"/api/application/center/app/switch\",\"/api/settle/accountbook\",\"/api/user/work/bench/access\",\"/api/user/work/bench\"]',
        1000, '[]', NULL, NULL, NULL, '2020-09-01 17:10:02', '2020-11-06 14:19:06', 0);
INSERT IGNORE INTO `t_tro_resource`(`id`, `parent_id`, `type`, `code`, `name`, `alias`, `value`, `sequence`, `action`,
                                     `features`, `customer_id`, `remark`, `create_time`, `update_time`, `is_deleted`)
VALUES (2, NULL, 0, 'linkTease', '链路梳理', '', '', 2400, '[]', NULL, NULL, NULL, '2020-09-01 17:16:56',
        '2020-11-12 20:12:24', 0);
INSERT IGNORE INTO `t_tro_resource`(`id`, `parent_id`, `type`, `code`, `name`, `alias`, `value`, `sequence`, `action`,
                                     `features`, `customer_id`, `remark`, `create_time`, `update_time`, `is_deleted`)
VALUES (3, 2, 0, 'systemFlow', '系统流程', '',
        '[\"/api/link/linkmanage/middleware\",\"/api/link/midlleWare/cascade\",\"/api/link/tech/linkManage\",\"/api/application/center/list\"]',
        2100, '[2,3,4]', NULL, NULL, NULL, '2020-09-01 17:20:17', '2020-11-12 16:51:46', 0);
INSERT IGNORE INTO `t_tro_resource`(`id`, `parent_id`, `type`, `code`, `name`, `alias`, `value`, `sequence`, `action`,
                                     `features`, `customer_id`, `remark`, `create_time`, `update_time`, `is_deleted`)
VALUES (4, 2, 0, 'businessActivity', '业务活动', '',
        '[\"/api/link/business/manage\",\"/api/link/linkmanage/middleware\",\"/api/link/midlleWare/cascade\"]', 2200,
        '[2,3,4]', NULL, NULL, NULL, '2020-09-01 17:26:09', '2020-11-02 20:17:57', 0);
INSERT IGNORE INTO `t_tro_resource`(`id`, `parent_id`, `type`, `code`, `name`, `alias`, `value`, `sequence`, `action`,
                                     `features`, `customer_id`, `remark`, `create_time`, `update_time`, `is_deleted`)
VALUES (5, 2, 0, 'businessFlow', '业务流程', '',
        '[\"/api/link/scene/manage\",\"/api/link/linkmanage/middleware\",\"/api/link/midlleWare/cascade\"]', 2300,
        '[2,3,4]', NULL, NULL, NULL, '2020-09-01 17:26:54', '2020-11-02 20:18:26', 0);
INSERT IGNORE INTO `t_tro_resource`(`id`, `parent_id`, `type`, `code`, `name`, `alias`, `value`, `sequence`, `action`,
                                     `features`, `customer_id`, `remark`, `create_time`, `update_time`, `is_deleted`)
VALUES (6, NULL, 0, 'appManage', '应用管理', NULL,
        '[\"/api/application/center/app/switch\",\"/api/application/center/list\",\"/api/application/center/app/info\",\"/api/link/ds/manage\",\"/api/link/ds/enable\",\"/api/link/ds/enable\",\"/api/link/ds/manage/detail\",\"/api/link/guard/guardmanage\",\"/api/link/guard/guardmanage/info\",\"/api/shadow/job/query\",\"/api/shadow/job/query/detail\",\"/api/application/whitelist\",\"/api/global/switch/whitelist\"]',
        3000, '[2,3,4,6]', NULL, NULL, NULL, '2020-09-01 17:31:32', '2020-11-06 11:59:26', 0);
INSERT IGNORE INTO `t_tro_resource`(`id`, `parent_id`, `type`, `code`, `name`, `alias`, `value`, `sequence`, `action`,
                                     `features`, `customer_id`, `remark`, `create_time`, `update_time`, `is_deleted`)
VALUES (8, NULL, 0, 'pressureTestManage', '压测管理', NULL, '', 5300, '[]', NULL, NULL, NULL, '2020-09-01 17:36:41',
        '2020-11-12 20:12:33', 0);
INSERT IGNORE INTO `t_tro_resource`(`id`, `parent_id`, `type`, `code`, `name`, `alias`, `value`, `sequence`, `action`,
                                     `features`, `customer_id`, `remark`, `create_time`, `update_time`, `is_deleted`)
VALUES (9, 8, 0, 'pressureTestManage_pressureTestScene', '压测场景', NULL,
        '[\"/api/application/center/app/switch\",\"/api/scenemanage/list\",\"/api/settle/accountbook\"]', 5100,
        '[2,3,4,5]', NULL, NULL, NULL, '2020-09-01 17:38:28', '2020-11-06 11:59:35', 0);
INSERT IGNORE INTO `t_tro_resource`(`id`, `parent_id`, `type`, `code`, `name`, `alias`, `value`, `sequence`, `action`,
                                     `features`, `customer_id`, `remark`, `create_time`, `update_time`, `is_deleted`)
VALUES (10, 8, 0, 'pressureTestManage_pressureTestReport', '压测报告', NULL, '[\"/api/report/listReport\"]', 5200, '[]',
        NULL, NULL, NULL, '2020-09-01 17:43:10', '2020-11-06 14:18:51', 0);
INSERT IGNORE INTO `t_tro_resource`(`id`, `parent_id`, `type`, `code`, `name`, `alias`, `value`, `sequence`, `action`,
                                     `features`, `customer_id`, `remark`, `create_time`, `update_time`, `is_deleted`)
VALUES (11, NULL, 0, 'configCenter', '配置中心', NULL, '', 6600, '[]', NULL, NULL, NULL, '2020-09-01 17:44:26',
        '2020-11-12 20:12:26', 0);
INSERT IGNORE INTO `t_tro_resource`(`id`, `parent_id`, `type`, `code`, `name`, `alias`, `value`, `sequence`, `action`,
                                     `features`, `customer_id`, `remark`, `create_time`, `update_time`, `is_deleted`)
VALUES (12, 11, 0, 'configCenter_pressureMeasureSwitch', '压测开关设置', NULL, '[\"/api/application/center/app/switch\"]',
        6100, '[6]', NULL, NULL, NULL, '2020-09-01 17:46:04', '2020-11-06 11:59:44', 0);
INSERT IGNORE INTO `t_tro_resource`(`id`, `parent_id`, `type`, `code`, `name`, `alias`, `value`, `sequence`, `action`,
                                     `features`, `customer_id`, `remark`, `create_time`, `update_time`, `is_deleted`)
VALUES (13, 11, 0, 'configCenter_whitelistSwitch', '白名单开关设置', NULL, '[\"/api/global/switch/whitelist\"]', 6200, '[6]',
        NULL, NULL, NULL, '2020-09-01 17:47:15', '2020-11-06 11:59:54', 0);
INSERT IGNORE INTO `t_tro_resource`(`id`, `parent_id`, `type`, `code`, `name`, `alias`, `value`, `sequence`, `action`,
                                     `features`, `customer_id`, `remark`, `create_time`, `update_time`, `is_deleted`)
VALUES (14, 11, 0, 'configCenter_blacklist', '黑名单', NULL, '[\"/api/confcenter/wbmnt/query/blist\"]', 6300, '[2,3,4,6]',
        NULL, NULL, NULL, '2020-09-01 17:48:02', '2020-11-06 12:00:05', 0);
INSERT IGNORE INTO `t_tro_resource`(`id`, `parent_id`, `type`, `code`, `name`, `alias`, `value`, `sequence`, `action`,
                                     `features`, `customer_id`, `remark`, `create_time`, `update_time`, `is_deleted`)
VALUES (15, 11, 0, 'configCenter_entryRule', '入口规则', NULL, '[\"/api/api/get\"]', 6400, '[2,3,4]', NULL, NULL, NULL,
        '2020-09-01 17:49:15', '2020-11-02 20:31:16', 0);
INSERT IGNORE INTO `t_tro_resource`(`id`, `parent_id`, `type`, `code`, `name`, `alias`, `value`, `sequence`, `action`,
                                     `features`, `customer_id`, `remark`, `create_time`, `update_time`, `is_deleted`)
VALUES (16, NULL, 0, 'flowAccount', '流量账户', NULL, '[\"/api/settle/accountbook\",\"/api/settle/balance/list\"]', 7000,
        '[]', NULL, NULL, NULL, '2020-09-01 17:51:25', '2020-11-06 14:19:30', 0);
INSERT IGNORE INTO `t_tro_resource`(`id`, `parent_id`, `type`, `code`, `name`, `alias`, `value`, `sequence`, `action`,
                                     `features`, `customer_id`, `remark`, `create_time`, `update_time`, `is_deleted`)
VALUES (307, 11, 0, 'configCenter_operationLog', '操作日志', NULL, '[\"/operation/log/list\"]', 6500, '[]', NULL, NULL,
        NULL, '2020-09-28 15:27:38', '2020-11-12 20:12:28', 0);
INSERT IGNORE INTO `t_tro_resource`(`id`, `parent_id`, `type`, `code`, `name`, `alias`, `value`, `sequence`, `action`,
                                     `features`, `customer_id`, `remark`, `create_time`, `update_time`, `is_deleted`)
VALUES (367, 11, 0, 'configCenter_authorityConfig', '权限管理', NULL,
        '[\"/api/role/list\",\"/api/role/detail\",\"/api/role/add\",\"/api/role/update\",\"/api/role/delete\",\"/api/role/clear\"]',
        6000, '[2,3,4]', NULL, NULL, NULL, '2020-11-10 11:53:09', '2020-11-16 11:35:39', 0);
INSERT IGNORE INTO `t_tro_resource`(`id`, `parent_id`, `type`, `code`, `name`, `alias`, `value`, `sequence`, `action`,
                                     `features`, `customer_id`, `remark`, `create_time`, `update_time`, `is_deleted`)
VALUES (368, NULL, 0, 'scriptManage', '脚本管理', NULL, '[\"/api/scriptManage\"]', 4000, '[2,3,4,7]', NULL, NULL, NULL,
        '2020-11-10 18:55:05', '2020-11-16 18:10:12', 0);

-- 授权表
DROP PROCEDURE IF EXISTS change_field;

DELIMITER $$

CREATE PROCEDURE change_field()

BEGIN

DECLARE count1 INT;

SET count1 = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_schema = DATABASE() AND TABLE_NAME = 't_tro_authority' AND COLUMN_NAME = 'object_type');

IF count1 > 0 THEN

alter table t_tro_authority
    modify column `object_type` tinyint(1) DEFAULT NULL COMMENT '对象类型:0:角色 1:用户(4.5.1版本后废弃不用)';

END IF;


SET count1 = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_schema = DATABASE() AND TABLE_NAME = 't_tro_authority' AND COLUMN_NAME = 'object_id');

IF count1 > 0 THEN

alter table t_tro_authority
    modify column `object_id` varchar(255) DEFAULT NULL COMMENT '对象id:角色,用户(4.5.1版本后废弃不用)';

END IF;


SET count1 = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_schema = DATABASE() AND TABLE_NAME = 't_tro_authority' AND COLUMN_NAME = 'role_id');

IF count1 = 0 THEN

alter table t_tro_authority
    add column role_id varchar(50) DEFAULT NULL COMMENT '角色id' after id;

END IF;


SET count1 = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_schema = DATABASE() AND TABLE_NAME = 't_tro_authority' AND COLUMN_NAME = 'scope');

IF count1 = 0 THEN


alter table t_tro_authority
    add column scope varchar(255) DEFAULT NULL COMMENT '权限范围：0:全部 1:本部门 2:本部门及以下 3:自己及以下 3:仅自己';

END IF;


SET count1 = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_schema = DATABASE() AND TABLE_NAME = 't_tro_authority' AND COLUMN_NAME = 'customer_id');

IF count1 = 0 THEN

alter table t_tro_authority
    add column customer_id bigint(20) DEFAULT NULL COMMENT '租户id' after scope;

END IF;


END $$

DELIMITER ;

CALL change_field();

DROP PROCEDURE IF EXISTS change_field;
-- 授权表修改字段结束

-- 备份表
CREATE TABLE IF NOT EXISTS t_tro_authority_copy LIKE t_tro_authority;
INSERT IGNORE INTO t_tro_authority_copy SELECT * FROM t_tro_authority;
-- 备份表结束

delete
from t_tro_authority
where role_id is null;

-- t_tro_authority 添加字段
DROP PROCEDURE IF EXISTS change_field;

DELIMITER $$

CREATE PROCEDURE change_field()

BEGIN

DECLARE count1 INT;

SET count1 = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_schema = DATABASE() AND TABLE_NAME = 't_tro_authority' AND COLUMN_NAME = 'status');

IF count1 = 0 THEN

alter table t_tro_authority
    add column `status` tinyint(1) DEFAULT '0' COMMENT '是否启用 0:启用;1:禁用' after action;

END IF;

END $$

DELIMITER ;

CALL change_field();

DROP PROCEDURE IF EXISTS change_field;
-- t_tro_authority 添加字段结束

-- 字段添加开始

DROP PROCEDURE IF EXISTS change_field;

DELIMITER $$

CREATE PROCEDURE change_field()

BEGIN

DECLARE count1 INT;

SET count1 = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_schema = DATABASE() AND TABLE_NAME = 't_application_mnt' AND COLUMN_NAME = 'CUSTOMER_ID');

IF count1 = 0 THEN
alter table t_application_mnt add column CUSTOMER_ID bigint(20) DEFAULT NULL COMMENT '租户id' after PRADAR_VERSION;
END IF;

SET count1 = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_schema = DATABASE() AND TABLE_NAME = 't_application_mnt' AND COLUMN_NAME = 'CREATE_TIME');

IF count1 > 0 THEN
alter table t_application_mnt modify column `CREATE_TIME` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间';
END IF;

SET count1 = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_schema = DATABASE() AND TABLE_NAME = 't_application_mnt' AND COLUMN_NAME = 'UPDATE_TIME');

IF count1 > 0 THEN
alter table t_application_mnt modify column `UPDATE_TIME` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间';

END IF;


SET count1 = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_schema = DATABASE() AND TABLE_NAME = 't_operation_log' AND COLUMN_NAME = 'customer_id');

IF count1 = 0 THEN

alter table t_operation_log add column `customer_id` bigint(20) DEFAULT NULL COMMENT '租户id' after end_time;

END IF;


SET count1 = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_schema = DATABASE() AND TABLE_NAME = 't_link_manage_table' AND COLUMN_NAME = 'CUSTOMER_ID');

IF count1 = 0 THEN

alter table t_link_manage_table add column CUSTOMER_ID bigint(20) DEFAULT NULL COMMENT '租户id' after IS_JOB;

END IF;

SET count1 = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_schema = DATABASE() AND TABLE_NAME = 't_link_manage_table' AND COLUMN_NAME = 'USER_ID');

IF count1 = 0 THEN

alter table t_link_manage_table add column `USER_ID` bigint(20) DEFAULT NULL COMMENT '用户id' after CUSTOMER_ID;
END IF;


SET count1 = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_schema = DATABASE() AND TABLE_NAME = 't_business_link_manage_table' AND COLUMN_NAME = 'CUSTOMER_ID');

IF count1 = 0 THEN

alter table t_business_link_manage_table add column CUSTOMER_ID bigint(20) DEFAULT NULL COMMENT '租户id' after IS_CORE;

END IF;

SET count1 = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_schema = DATABASE() AND TABLE_NAME = 't_business_link_manage_table' AND COLUMN_NAME = 'USER_ID');

IF count1 = 0 THEN

alter table t_business_link_manage_table add column `USER_ID` bigint(20) DEFAULT NULL COMMENT '用户id' after CUSTOMER_ID;

END IF;

SET count1 = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_schema = DATABASE() AND TABLE_NAME = 't_scene' AND COLUMN_NAME = 'CUSTOMER_ID');

IF count1 = 0 THEN

alter table t_scene add column CUSTOMER_ID bigint(20) DEFAULT NULL COMMENT '租户id' after IS_CHANGED;

END IF;

SET count1 = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_schema = DATABASE() AND TABLE_NAME = 't_scene' AND COLUMN_NAME = 'USER_ID');

IF count1 = 0 THEN

alter table t_scene add column `USER_ID` bigint(20) DEFAULT NULL COMMENT '用户id' after CUSTOMER_ID;
END IF;

SET count1 = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_schema = DATABASE() AND TABLE_NAME = 't_application_api_manage' AND COLUMN_NAME = 'CUSTOMER_ID');

IF count1 = 0 THEN

alter table t_application_api_manage add column CUSTOMER_ID bigint(20) DEFAULT NULL COMMENT '租户id' after APPLICATION_NAME;

END IF;

SET count1 = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_schema = DATABASE() AND TABLE_NAME = 't_application_api_manage' AND COLUMN_NAME = 'USER_ID');

IF count1 = 0 THEN

alter table t_application_api_manage add column `USER_ID` bigint(20) DEFAULT NULL COMMENT '用户id' after CUSTOMER_ID;

END IF;

SET count1 = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_schema = DATABASE() AND TABLE_NAME = 't_black_list' AND COLUMN_NAME = 'PRINCIPAL_NO');

IF count1 > 0 THEN

alter table t_black_list modify column `PRINCIPAL_NO` varchar(10) DEFAULT NULL COMMENT '负责人工号(废弃不用)';

END IF;

SET count1 = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_schema = DATABASE() AND TABLE_NAME = 't_black_list' AND COLUMN_NAME = 'USER_ID');

IF count1 = 0 THEN

alter table t_black_list add column `USER_ID` bigint(20) DEFAULT NULL COMMENT '用户id' after CUSTOMER_ID;


END IF;

SET count1 = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_schema = DATABASE() AND TABLE_NAME = 't_black_list' AND COLUMN_NAME = 'CUSTOMER_ID');

IF count1 = 0 THEN

alter table t_black_list add column CUSTOMER_ID bigint(20) DEFAULT NULL COMMENT '租户id' after USE_YN;

END IF;

SET count1 = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_schema = DATABASE() AND TABLE_NAME = 't_link_guard' AND COLUMN_NAME = 'customer_id');

IF count1 = 0 THEN

alter table t_link_guard add column customer_id bigint(20) DEFAULT NULL COMMENT '租户id' after groovy;


END IF;

SET count1 = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_schema = DATABASE() AND TABLE_NAME = 't_link_guard' AND COLUMN_NAME = 'user_id');

IF count1 = 0 THEN

alter table t_link_guard add column `user_id` bigint(20) DEFAULT NULL COMMENT '用户id' after customer_id;


END IF;

SET count1 = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_schema = DATABASE() AND TABLE_NAME = 't_application_ds_manage' AND COLUMN_NAME = 'CUSTOMER_ID');

IF count1 = 0 THEN

alter table t_application_ds_manage add column CUSTOMER_ID bigint(20) DEFAULT NULL COMMENT '租户id' after `STATUS`;

END IF;

SET count1 = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_schema = DATABASE() AND TABLE_NAME = 't_application_ds_manage' AND COLUMN_NAME = 'USER_ID');

IF count1 = 0 THEN

alter table t_application_ds_manage add column USER_ID bigint(20) DEFAULT NULL COMMENT '用户id' after CUSTOMER_ID;

END IF;

SET count1 = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_schema = DATABASE() AND TABLE_NAME = 't_shadow_job_config' AND COLUMN_NAME = 'customer_id');

IF count1 = 0 THEN

alter table t_shadow_job_config add column customer_id bigint(20) DEFAULT NULL COMMENT '租户id' after active;

END IF;

SET count1 = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_schema = DATABASE() AND TABLE_NAME = 't_shadow_job_config' AND COLUMN_NAME = 'user_id');

IF count1 = 0 THEN

alter table t_shadow_job_config add column user_id bigint(20) DEFAULT NULL COMMENT '用户id' after CUSTOMER_ID;


END IF;


SET count1 = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_schema = DATABASE() AND TABLE_NAME = 't_tro_user' AND COLUMN_NAME = 'customer_id');

IF count1 = 0 THEN

alter table t_tro_user add column customer_id bigint(20) DEFAULT NULL COMMENT '租户id' after id;

END IF;

SET count1 = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_schema = DATABASE() AND TABLE_NAME = 't_white_list' AND COLUMN_NAME = 'CUSTOMER_ID');

IF count1 = 0 THEN

alter table t_white_list add column CUSTOMER_ID bigint(20) DEFAULT NULL COMMENT '租户id' after `USE_YN`;

END IF;

SET count1 = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_schema = DATABASE() AND TABLE_NAME = 't_white_list' AND COLUMN_NAME = 'USER_ID');

IF count1 = 0 THEN

alter table t_white_list add column USER_ID bigint(20) DEFAULT NULL COMMENT '用户id' after CUSTOMER_ID;

END IF;

SET count1 = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_schema = DATABASE() AND TABLE_NAME = 't_white_list' AND COLUMN_NAME = 'CREATE_TIME');

IF count1 > 0 THEN

alter table t_white_list modify column `CREATE_TIME` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间';

END IF;

SET count1 = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_schema = DATABASE() AND TABLE_NAME = 't_white_list' AND COLUMN_NAME = 'UPDATE_TIME');

IF count1 > 0 THEN

alter table t_white_list modify column `UPDATE_TIME` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间';

END IF;


END $$

DELIMITER ;

CALL change_field();

DROP PROCEDURE IF EXISTS change_field;
-- 字段添加结束

-- 更新字段开始
-- 字段更新
DROP PROCEDURE IF EXISTS update_field;

DELIMITER $$

CREATE PROCEDURE update_field()

BEGIN

DECLARE count1 INT;

SET count1 = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_schema = DATABASE() AND TABLE_NAME = 't_application_mnt' AND COLUMN_NAME = 'customer_id');

IF count1 > 0 THEN

update t_application_mnt
set customer_id=1;

END IF;

SET count1 = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_schema = DATABASE() AND TABLE_NAME = 't_application_ds_manage' AND COLUMN_NAME = 'customer_id');

IF count1 > 0 THEN

update t_application_ds_manage
set customer_id=1;

END IF;

SET count1 = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_schema = DATABASE() AND TABLE_NAME = 't_link_guard' AND COLUMN_NAME = 'customer_id');

IF count1 > 0 THEN

update t_link_guard
set customer_id=1;

END IF;

SET count1 = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_schema = DATABASE() AND TABLE_NAME = 't_white_list' AND COLUMN_NAME = 'customer_id');

IF count1 > 0 THEN

update t_white_list
set customer_id=1;

END IF;

SET count1 = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_schema = DATABASE() AND TABLE_NAME = 't_shadow_job_config' AND COLUMN_NAME = 'customer_id');

IF count1 > 0 THEN

update t_shadow_job_config
set customer_id=1;

END IF;

SET count1 = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_schema = DATABASE() AND TABLE_NAME = 't_tro_user' AND COLUMN_NAME = 'customer_id');

IF count1 > 0 THEN

update t_tro_user
set customer_id=1;

END IF;

SET count1 = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_schema = DATABASE() AND TABLE_NAME = 't_tro_user' AND COLUMN_NAME = 'user_type');

IF count1 > 0 THEN

update t_tro_user
set user_type=1
where id > 1;

END IF;

END $$

DELIMITER ;

CALL update_field();

DROP PROCEDURE IF EXISTS update_field;
-- 更新字段结束