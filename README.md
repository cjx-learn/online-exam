# 在线考试系统

基于 Spring Boot + Vue 3 + MySQL 的在线考试系统

## 技术栈

### 后端
- **Spring Boot 2.7.14** - 核心框架
- **Spring MVC** - Web框架
- **MyBatis 2.2.2** - ORM框架
- **MySQL 8.0** - 数据库
- **Druid** - 数据库连接池
- **JWT** - 身份认证
- **Lombok** - 简化代码

### 前端
- **Vue 3** - 前端框架
- **Vite** - 构建工具
- **Vue Router** - 路由管理
- **Pinia** - 状态管理
- **Element Plus** - UI组件库
- **Axios** - HTTP客户端

## 项目结构

```
OnlineExam/
├── backend/                    # 后端项目
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/
│   │   │   │   └── com/exam/
│   │   │   │       ├── config/         # 配置类
│   │   │   │       ├── controller/     # 控制器
│   │   │   │       ├── service/        # 服务层
│   │   │   │       ├── mapper/         # 数据访问层
│   │   │   │       ├── entity/         # 实体类
│   │   │   │       ├── common/         # 公共类
│   │   │   │       └── OnlineExamApplication.java
│   │   │   └── resources/
│   │   │       ├── mapper/             # MyBatis映射文件
│   │   │       └── application.yml     # 配置文件
│   │   └── test/
│   └── pom.xml                         # Maven配置
├── frontend/                   # 前端项目
│   ├── src/
│   │   ├── views/              # 页面组件
│   │   ├── router/             # 路由配置
│   │   ├── utils/              # 工具类
│   │   ├── App.vue             # 根组件
│   │   └── main.js             # 入口文件
│   ├── index.html
│   ├── vite.config.js          # Vite配置
│   └── package.json            # 依赖配置
├── database/                   # 数据库脚本
│   └── schema.sql              # 数据库初始化脚本
└── README.md                   # 项目说明
```

## 环境要求

### 开发环境
- **JDK 1.8+**
- **Maven 3.6+**
- **Node.js 16+**
- **MySQL 8.0+**

## 快速开始

### 1. 数据库配置

1) 安装 MySQL 8.0
2) 创建数据库并导入初始化脚本：

```bash
mysql -u root -p < database/schema.sql
```

3) 修改后端配置文件 `backend/src/main/resources/application.yml`：

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/online_exam?useUnicode=true&characterEncoding=utf8&useSSL=false&serverTimezone=Asia/Shanghai
    username: root
    password: 你的密码
```

### 2. 后端启动

#### 方式一：使用 IDE（推荐）

1) 使用 IntelliJ IDEA 或 Eclipse 导入 Maven 项目
2) 等待依赖下载完成
3) 运行 `OnlineExamApplication.java` 主类

#### 方式二：使用命令行

```bash
# 进入后端目录
cd backend

# 编译打包
mvn clean package -DskipTests

# 运行
java -jar target/online-exam-system-1.0.0.jar
```

后端服务将在 http://localhost:8080/api 启动

### 3. 前端启动

```bash
# 进入前端目录
cd frontend

# 安装依赖
npm install
# 或使用 yarn
yarn install

# 启动开发服务器
npm run dev
# 或使用 yarn
yarn dev
```

前端应用将在 http://localhost:3000 启动

### 4. 访问系统

浏览器访问: http://localhost:3000

默认测试账号：
- 管理员: admin / 123456
- 教师: teacher / 123456
- 学生: student / 123456

## 主要功能

### 学生端
- ✅ 用户登录
- ✅ 查看考试列表（未开始/进行中/已完成）
- ✅ 在线考试（倒计时、自动保存、超时自动提交）
- ✅ 查看成绩和答题详情
- ✅ 查看教师批改意见
- ✅ 题目导航快速跳转

### 教师端
- ✅ 班级管理（创建班级、添加学生）
- ✅ 题库管理（5种题型）
- ✅ 考试管理（创建考试、选择题目）
- ✅ 主观题批改（匿名批改、键盘快捷键）
- ✅ 批改进度可视化
- ✅ 成绩统计

### 核心特性
- ✅ 客观题自动批改（单选、多选、判断）
- ✅ 主观题人工批改（填空、简答）
- ✅ 考试时间严格控制
- ✅ 批改界面学生信息匿名
- ✅ 实时保存答案
- ✅ 响应式界面设计

## 开发说明

### 后端开发

1. **添加依赖**: 在 `pom.xml` 中添加
2. **实体类**: 在 `entity` 包中创建，使用 Lombok 简化代码
3. **Mapper**: 在 `mapper` 包中创建接口，XML 文件放在 `resources/mapper`
4. **Service**: 在 `service` 包中编写业务逻辑
5. **Controller**: 在 `controller` 包中编写接口

### 前端开发

1. **添加依赖**: `npm install package-name`
2. **页面组件**: 在 `src/views` 中创建
3. **路由配置**: 在 `src/router/index.js` 中配置
4. **API 调用**: 使用 `src/utils/request.js` 封装的 axios

### 数据库设计

主要表结构：
- `user` - 用户表
- `exam` - 考试表
- `question` - 题库表
- `exam_question` - 考试题目关联表
- `exam_record` - 考试记录表
- `answer_record` - 答题记录表

详见 `database/schema.sql`

## 常见问题

### 1. 后端启动失败

**问题**: 数据库连接失败
**解决**: 
- 检查 MySQL 服务是否启动
- 确认数据库用户名密码是否正确
- 确认数据库 `online_exam` 是否创建

### 2. 前端启动失败

**问题**: 依赖安装失败
**解决**:
- 检查 Node.js 版本 (需要 16+)
- 清理缓存: `npm cache clean --force`
- 删除 `node_modules` 重新安装

### 3. 跨域问题

**问题**: 前端请求后端接口报跨域错误
**解决**:
- 后端已配置 CORS，检查 `CorsConfig.java`
- 前端代理配置在 `vite.config.js` 中

### 4. 端口占用

**问题**: 端口 8080 或 3000 被占用
**解决**:
- 修改后端端口: `application.yml` 中的 `server.port`
- 修改前端端口: `vite.config.js` 中的 `server.port`

## 部署说明

### 后端部署

```bash
# 打包
mvn clean package -DskipTests

# 运行
java -jar target/online-exam-system-1.0.0.jar
```

### 前端部署

```bash
# 构建
npm run build

# dist 目录部署到 Nginx 或其他服务器
```

## 许可证

MIT License

## 联系方式

如有问题，请提交 Issue 或联系开发者。

