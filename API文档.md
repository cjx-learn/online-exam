# 在线考试系统 - API 接口文档

## 基础信息

**Base URL:** `http://localhost:8080`

**响应格式:**
```json
{
  "code": 200,
  "message": "成功",
  "data": {}
}
```

---

## 1. 用户接口

### 1.1 学生登录
```
POST /student/login
```

**请求参数:**
```json
{
  "studentNo": "2021001",
  "password": "123456"
}
```

**响应:**
```json
{
  "code": 200,
  "message": "登录成功",
  "data": {
    "id": 1,
    "studentNo": "2021001",
    "realName": "张三",
    "email": "zhangsan@example.com"
  }
}
```

### 1.2 教师登录
```
POST /teacher/login
```

**请求参数:**
```json
{
  "teacherNo": "T001",
  "password": "123456"
}
```

---

## 2. 班级接口

### 2.1 创建班级
```
POST /class/create
```

**请求参数:**
```json
{
  "className": "软件工程2021级1班",
  "courseId": 1,
  "teacherId": 1
}
```

### 2.2 获取班级详情
```
GET /class/{classId}
```

**响应:**
```json
{
  "code": 200,
  "data": {
    "id": 1,
    "className": "软件工程2021级1班",
    "courseId": 1,
    "courseName": "Java程序设计",
    "teacherId": 1,
    "teacherName": "李老师"
  }
}
```

### 2.3 获取班级学生列表
```
GET /class/{classId}/students
```

**响应:**
```json
{
  "code": 200,
  "data": [
    {
      "id": 1,
      "studentNo": "2021001",
      "realName": "张三",
      "status": 1,
      "joinTime": "2025-09-01 00:00:00"
    }
  ]
}
```

---

## 3. 题目接口

### 3.1 获取课程题目列表
```
GET /question/course/{courseId}
```

**响应:**
```json
{
  "code": 200,
  "data": [
    {
      "id": 1,
      "content": "Java中的继承关键字是？",
      "type": 1,
      "options": "[{\"key\":\"A\",\"value\":\"extends\"},{\"key\":\"B\",\"value\":\"implements\"}]",
      "answer": "A",
      "score": 5,
      "difficulty": 1
    }
  ]
}
```

### 3.2 创建题目
```
POST /question/create
```

**请求参数:**
```json
{
  "content": "请简述Java面向对象的三大特性",
  "type": 5,
  "answer": "封装、继承、多态",
  "score": 10,
  "difficulty": 2,
  "courseId": 1
}
```

---

## 4. 考试接口

### 4.1 创建考试
```
POST /exam/create
```

**请求参数:**
```json
{
  "title": "期中考试",
  "classId": 1,
  "startTime": "2025-11-20 09:00:00",
  "endTime": "2025-11-20 11:00:00",
  "duration": 120,
  "questionIds": [1, 2, 3, 4, 5]
}
```

### 4.2 获取班级考试列表
```
GET /exam/class/{classId}
```

**响应:**
```json
{
  "code": 200,
  "data": [
    {
      "id": 1,
      "title": "期中考试",
      "startTime": "2025-11-20 09:00:00",
      "endTime": "2025-11-20 11:00:00",
      "duration": 120,
      "totalScore": 100
    }
  ]
}
```

### 4.3 获取考试详情
```
GET /exam/{examId}
```

**响应:**
```json
{
  "code": 200,
  "data": {
    "id": 1,
    "title": "期中考试",
    "startTime": "2025-11-20 09:00:00",
    "endTime": "2025-11-20 11:00:00",
    "duration": 120,
    "questions": [
      {
        "id": 1,
        "content": "Java中的继承关键字是？",
        "type": 1,
        "options": "[...]",
        "score": 5
      }
    ]
  }
}
```

---

## 5. 答题接口

### 5.1 开始考试
```
POST /exam-record/start
```

**请求参数:**
```json
{
  "examId": 1,
  "studentId": 1
}
```

**响应:**
```json
{
  "code": 200,
  "message": "考试开始",
  "data": {
    "examRecordId": 1,
    "startTime": "2025-11-20 09:05:00"
  }
}
```

### 5.2 保存答案
```
POST /exam-record/save-answer
```

**请求参数:**
```json
{
  "examRecordId": 1,
  "questionId": 1,
  "userAnswer": "A"
}
```

### 5.3 提交考试
```
POST /exam-record/submit
```

**请求参数:**
```json
{
  "examRecordId": 1
}
```

**响应:**
```json
{
  "code": 200,
  "message": "考试提交成功",
  "data": {
    "objectiveScore": 75,
    "totalScore": 75,
    "needGrading": true
  }
}
```

### 5.4 获取考试记录详情
```
GET /exam-record/{recordId}
```

**响应:**
```json
{
  "code": 200,
  "data": {
    "id": 1,
    "examId": 1,
    "examName": "期中考试",
    "studentId": 1,
    "startTime": "2025-11-20 09:05:00",
    "submitTime": "2025-11-20 10:30:00",
    "objectiveScore": 75,
    "subjectiveScore": 20,
    "totalScore": 95,
    "status": 2,
    "questions": [
      {
        "id": 1,
        "content": "题目内容",
        "type": 1,
        "userAnswer": "A",
        "correctAnswer": "A",
        "score": 5,
        "currentScore": 5,
        "isCorrect": 1
      }
    ]
  }
}
```

---

## 6. 批改接口

### 6.1 获取批改列表
```
GET /grading/class/{classId}
```

**响应:**
```json
{
  "code": 200,
  "data": [
    {
      "id": 1,
      "examName": "期中考试",
      "startTime": "2025-11-20 09:00:00",
      "endTime": "2025-11-20 11:00:00",
      "pendingCount": 15,
      "gradedCount": 5
    }
  ]
}
```

### 6.2 获取学生答案列表
```
GET /grading/exam/{examId}/class/{classId}
```

**响应:**
```json
{
  "code": 200,
  "data": [
    {
      "id": 1,
      "studentName": "张三",
      "studentNo": "2021001",
      "examRecordId": 1,
      "submitTime": "2025-11-20 10:30:00",
      "isGraded": false,
      "subjectiveQuestions": [
        {
          "questionId": 5,
          "content": "请简述Java面向对象的三大特性",
          "score": 10,
          "maxScore": 10,
          "standardAnswer": "封装、继承、多态",
          "userAnswer": "封装、继承、多态...",
          "currentScore": null,
          "comment": null
        }
      ]
    }
  ]
}
```

### 6.3 保存批改结果
```
POST /grading/save
```

**请求参数:**
```json
{
  "examRecordId": 1,
  "answers": [
    {
      "questionId": 5,
      "score": 8,
      "comment": "回答基本正确，但缺少详细说明"
    }
  ]
}
```

**响应:**
```json
{
  "code": 200,
  "message": "批改保存成功"
}
```

---

## 7. 成绩接口

### 7.1 获取学生成绩列表
```
GET /exam-record/student/{studentId}
```

**响应:**
```json
{
  "code": 200,
  "data": [
    {
      "id": 1,
      "examName": "期中考试",
      "totalScore": 95,
      "objectiveScore": 75,
      "subjectiveScore": 20,
      "submitTime": "2025-11-20 10:30:00",
      "status": 2
    }
  ]
}
```

---

## 错误码说明

| 错误码 | 说明 |
|--------|------|
| 200 | 成功 |
| 400 | 请求参数错误 |
| 401 | 未登录或登录已过期 |
| 403 | 无权限访问 |
| 404 | 资源不存在 |
| 500 | 服务器内部错误 |

---

## 数据字段说明

### 题目类型 (type)
- 1: 单选题
- 2: 多选题
- 3: 判断题
- 4: 填空题
- 5: 简答题

### 难度等级 (difficulty)
- 1: 简单
- 2: 中等
- 3: 困难

### 考试记录状态 (status)
- 0: 未开始
- 1: 进行中
- 2: 已完成

### 学生状态 (status)
- 0: 已退出
- 1: 在读

---

