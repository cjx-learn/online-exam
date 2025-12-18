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
- **BCrypt** - 密码加密
- **Apache POI** - Excel文件处理
- **Lombok** - 简化代码

### 前端
- **Vue 3** - 前端框架
- **Vite 4.5** - 构建工具
- **Vue Router** - 路由管理
- **Pinia** - 状态管理
- **Element Plus** - UI组件库
- **Axios** - HTTP客户端
- **ECharts** - 数据可视化
- **html2pdf.js** - PDF导出
- **xlsx** - Excel文件处理

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

前端应用将在 http://localhost:5173 启动

### 4. 访问系统

浏览器访问: http://localhost:5173

默认测试账号：
- 管理员: admin / 123456
- 教师: teacher / 123456
- 学生: student / 123456

## 主要功能

### 学生端
- ✅ **用户认证**
  - 安全登录（BCrypt密码加密）
  - 个人信息管理（支持修改姓名、学号、专业、邮箱、手机号）
  - 修改密码

- ✅ **考试功能**
  - 查看考试列表（未开始/进行中/已完成）
  - 在线考试（倒计时、自动保存、超时自动提交）
  - 题目导航快速跳转
  - 简答题支持简单模式/公式模式切换
  - 考试结果实时查看

- ✅ **成绩管理**
  - 查看成绩和答题详情
  - 查看教师批改意见和评分
  - 错题标记和正确答案展示
  - 学情报告（班级排名、与平均分对比）
  - 考试详情PDF导出
  - 成绩证明PDF下载
  - 成绩趋势图表分析

### 教师端
- ✅ **班级管理**
  - 创建和管理班级
  - Excel批量导入学生
  - 学生信息管理
  - 班级成员查看

- ✅ **题库管理**
  - 支持5种题型（单选、多选、判断、填空、简答）
  - 简答题支持LaTeX公式编辑器
  - 题目支持图片上传
  - 题目创建、编辑、删除
  - 题目搜索和筛选

- ✅ **考试管理**
  - 创建考试（选择班级、课程、时间）
  - 从题库选择题目
  - 设置考试时长和总分
  - 考试状态管理

- ✅ **批改评分**
  - 主观题批改（匿名批改、键盘快捷键）
  - 批改进度可视化
  - 批改意见和评分
  - 公式答案渲染显示
  - 批改历史记录

- ✅ **成绩统计**
  - 学生成绩列表
  - 成绩分布统计
  - 高频错题分析（题目、选项、错误率统计）
  - 数据可视化图表
  - 个人信息管理（支持修改姓名、工号、院系、职称、邮箱、手机号）

### 管理员端
- ✅ **用户管理**
  - 学生账号管理（创建、编辑、删除、禁用）
  - 教师账号管理
  - 管理员账号管理
  - Excel批量导入账号

- ✅ **系统管理**
  - 课程管理
  - 系统配置
  - 数据统计
  - 个人信息管理

### 核心特性
- ✅ **安全性**
  - BCrypt密码加密存储
  - JWT身份认证
  - 跨域请求配置
  - 账号状态控制（启用/禁用）

- ✅ **用户体验**
  - 客观题自动批改（单选、多选、判断）
  - 主观题人工批改（填空、简答）
  - 考试时间严格控制
  - 批改界面学生信息匿名
  - 实时保存答案
  - 响应式界面设计
  - 现代化UI设计

- ✅ **数据处理**
  - Excel批量导入学生和题目
  - 考试详情PDF导出
  - 成绩证明PDF下载
  - 成绩数据可视化
  - 高频错题统计分析

- ✅ **LaTeX公式支持**
  - 集成KaTeX公式渲染引擎
  - 支持行内公式和独立公式
  - 可视化公式编辑器（快捷插入、希腊字母面板）
  - 实时预览功能
  - 适用于理工科考试场景

- ✅ **可靠性**
  - 数据库事务处理
  - 错误异常处理
  - 用户信息跨设备同步
  - 数据一致性保证

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

## 最近更新

### v1.3.0 (2025-12-18)

**新功能**
- ✨ LaTeX公式编辑器（FormulaEditor组件）
- ✨ 公式渲染组件（FormulaRenderer组件）
- ✨ 学生答题支持简单模式/公式模式切换
- ✨ 学情分析功能（班级排名、成绩对比、知识点分析）
- ✨ 成绩证明PDF下载功能
- ✨ 头像上传功能
- ✨ 题目图片上传功能

**优化改进**
- 🎨 优化学生考试详情页面，新增学情报告视图
- 🎨 班级排名展示优化（奖牌图标、当前学生高亮）
- 🎨 公式编辑器支持快捷插入和希腊字母面板
- ⚡ 公式渲染采用KaTeX引擎，渲染速度更快

**技术更新**
- � 新复增KaTeX依赖（v0.16.27）
- � 新复增html2pdf.js依赖用于PDF导出

### v1.2.0 (2025-12-06)

**新功能**
- ✨ 支持Excel批量导入学生信息
- ✨ 高频错题统计与分析功能
- ✨ 考试详情PDF导出功能
- ✨ 成绩趋势可视化图表
- ✨ 完善个人信息管理功能

**优化改进**
- 🎨 优化教师批改界面，提升体验
- 🎨 优化成绩统计页面布局
- ⚡ 提升数据加载性能
- 🔧 完善错误提示信息

**Bug修复**
- 🐛 修复用户个人信息更新后跨设备不同步问题
- 🐛 修复登录接口返回数据不完整问题
- 🐛 修复高频错题题目正确率计算错误
- 🐛 修复前端依赖冲突导致启动失败

### v1.1.0 (2025-11-17)
- 🎉 初始版本发布
- ✨ 完整的考试系统功能
- ✨ 学生、教师、管理员三端功能

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

**问题**: 端口 8080 或 5173 被占用
**解决**:
- 修改后端端口: `application.yml` 中的 `server.port`
- 修改前端端口: `vite.config.js` 中的 `server.port`

### 5. Excel 导入失败

**问题**: Excel 文件导入失败
**解决**:
- 确认 Excel 文件格式正确（参考模板）
- 检查文件编码为 UTF-8
- 确认必填字段不为空
- 查看后端日志获取详细错误信息

### 6. PDF 导出失败

**问题**: 考试详情 PDF 导出失败或显示空白
**解决**:
- 检查是否安装 `html2pdf.js` 依赖
- 清除浏览器缓存后重试
- 确认浏览器支持 HTML5 Canvas

### 7. 个人信息修改不生效

**问题**: 修改个人信息后，重新登录显示旧信息
**解决**:
- 确认后端服务已重启（最新版本已修复）
- 清除浏览器 localStorage 缓存
- 退出登录后重新登录

### 8. 前端依赖安装失败

**问题**: npm install 报错 `EPERM` 或 `EACCES`
**解决**:
- Windows: 以管理员身份运行 PowerShell
- 删除 `node_modules` 和 `package-lock.json` 后重新安装
- 使用 `npm install --legacy-peer-deps`
- 清理 npm 缓存: `npm cache clean --force`

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

## 技术支持

如遇到问题，请按以下方式获取帮助：

1. **查看文档**: 先查看本 README 和常见问题部分
2. **查看 Issue**: 在 GitHub Issues 中搜索类似问题
3. **提交 Issue**: 如果是新问题，请提交详细的 Issue（包含错误信息、操作步骤、环境信息）
4. **Pull Request**: 欢迎提交代码改进

## 贡献指南

欢迎贡献代码、报告 Bug、提出建议！

1. Fork 本仓库
2. 创建您的特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交您的修改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启一个 Pull Request

## 许可证

MIT License

Copyright (c) 2025 cjx-learn

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

---

⭐ 如果这个项目对您有帮助，请给个 Star 支持一下！

